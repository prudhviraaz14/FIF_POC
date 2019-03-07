package net.arcor.fif.client;

import java.io.IOException;
import java.io.StringWriter;
import java.text.SimpleDateFormat;
import java.util.GregorianCalendar;
import java.util.HashSet;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;

import net.arcor.fif.common.DOMSerializer;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.common.XMLHelpers;
import net.arcor.fif.db.FifTransaction;
import net.arcor.fif.messagecreator.RequestSerializer;
import net.arcor.fif.messagecreator.somtofif.SOMToFIFTransformationProvider;

import org.apache.log4j.Logger;
import org.apache.xpath.XPathAPI;
import org.apache.xpath.objects.XObject;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.sun.org.apache.xml.internal.serialize.OutputFormat;
import com.sun.org.apache.xml.internal.serialize.XMLSerializer;

import de.arcor.kba.om.datatransformer.server.HierarchicalDataTransformer;
import de.arcor.kba.om.datatransformer.server.exception.TransformationException;
import de.arcor.kba.om.datatransformer.server.model.DefaultXMLAdapter;

public class SynchronousSOMQueueRequestReceiver extends
		SynchronousQueueRequestReceiver {
	
	private static int maxSeatsPerRequest = 50;
	private static int dependentFunctionThreshold = 100;

	protected synchronized void init() throws FIFException {
		super.init();
		try {
			maxSeatsPerRequest = ClientConfig.getInt("SynchronousSOMQueueClient.MaxSeatsPerRequest");
		} catch (FIFException e) {}
		try {
			dependentFunctionThreshold = ClientConfig.getInt("SynchronousSOMQueueClient.DependentFunctionThreshold");
		} catch (FIFException e) {}
	}
	
	public SynchronousSOMQueueRequestReceiver(ResponseSender responseSender) throws FIFException {
		super (responseSender);
	}
	protected TechnicalFailureAction processReceivedRequest (String message,String jmsCorrelationId,String jmsReplyTo) throws FIFException {
		StringBuffer beautifiedRequest = null;
		Document requestDocument = null;
		try {
			// parse the message into a DOM document
			if (logger.isDebugEnabled())
				logger.debug("Request message before cleaning: " + message);				
			message = cleanMessageString(message);
			if (logger.isDebugEnabled())
				logger.debug("Request message after cleaning: " + message);						
			beautifiedRequest = new StringBuffer();
			requestDocument = RequestSerializer.serializeSOMRequest(message, beautifiedRequest);
		} catch (Exception e) {
			createErrorResponse("unknown", "unknown", "FIF0027", "Request could not be parsed." + e.getMessage(), jmsCorrelationId, jmsReplyTo);
			logger.error("Exception: ", e);
			return handleTechnicalFailure("unknown", "unknown", e.getClass().getName(), e.getMessage(), jmsCorrelationId, jmsReplyTo);
		}
		
		// read the simple parameters from the request
		String transactionId = XMLHelpers.getTextElement(requestDocument, "transactionId");
		String transactionType = XMLHelpers.getTextElement(requestDocument, "transactionType");
		if (transactionId == null || transactionId.trim().equals(""))
			transactionId = "unknown";
		if (transactionType == null || transactionType.trim().equals(""))
			transactionType = "unknown";
		String somVersion = XMLHelpers.getTextElement(requestDocument, "somVersion");
		
		writeSOMRequest(beautifiedRequest, transactionId, transactionType);
		
		if (transactionId.equals("unknown"))
			createErrorResponse(transactionType, transactionId, "FIF0021", "No transactionId provided.", jmsCorrelationId, jmsReplyTo);
		else if (transactionType.equals("unknown"))
			createErrorResponse(transactionType, transactionId, "FIF0022", "No transactionType provided.", jmsCorrelationId, jmsReplyTo);
		else if (somVersion == null || somVersion.trim().equals(""))
			createErrorResponse(transactionType, transactionId, "FIF0023", "No somVersion provided.", jmsCorrelationId, jmsReplyTo);				
		else {			
			logger.info("Received SOM with RequestID: " + transactionId + 
					". Transaction Type: " + transactionType + 
					". SOM Version: " + somVersion);
			String request = null;
			try {
				FifTransaction existingFifTransaction = 
					fifTransactionDAO.retrieveFifTransactionById(
							transactionId, 
							SynchronousFifClient.theClient.getClientType());
				
				if (existingFifTransaction == null) {					
					Document somDocument = extractSomDocument(requestDocument, transactionType);
					if (logger.isDebugEnabled()) 
						logSOM(somDocument, transactionId, false);
					
					somDocument = truncateSOM_2_0(somDocument, transactionId, transactionType);				
					
					String transformer = getTransactionBuilder(somDocument, transactionType);
					if (transformer == null)
						createErrorResponse(transactionType, transactionId, "FIF0026", "Couldn't find a suitable TransactionBuilder for this SOM.", jmsCorrelationId, jmsReplyTo);
					else {
						logger.info("Transforming request " + transactionId + 
								" with transaction builder " + transformer);
						Document fifDocument = transformSomDocument(somDocument, transformer);
						if (fifDocument == null)
							createErrorResponse(transactionType, transactionId, "FIF0025", "No request to be sent to FIF, no transaction builder trigger fired.", jmsCorrelationId, jmsReplyTo);
						else {
							fifDocument = enrichFifRequest(fifDocument, somDocument, transactionId, transactionType, null);
							request = serializeFifDocument(fifDocument);
						}
						// reset the exception counter
						consecutiveExceptionCounter = 0;
						transactionExceptionCounterMap.remove(transactionId);
					}
				}
				else 
					logger.info("FifTransaction " + transactionId + 
							" is already in the database. Skipping ...");
			} catch (FIFException e) {
				logger.error("Exception: ", e);
				createErrorResponse(transactionType, transactionId, "FIF0024", e.getMessage(),jmsCorrelationId, jmsReplyTo);
			} catch (Exception e) {				
				logger.error("Exception: ", e);
				return handleTechnicalFailure(transactionType, transactionId, e.getClass().getName(), e.getMessage(), jmsCorrelationId, jmsReplyTo);
			}
			if (request != null)
				processFifRequestMessage(request,jmsCorrelationId,jmsReplyTo);			
		}
		return TechnicalFailureAction.NONE;
	}
	
	
	protected static Document truncateSOM_2_0(Document somDocument, String transactionID, String transactionType) throws TransformerException, FIFException {
		if (!transactionType.equals("execute"))
			return somDocument;
		
		Logger localLogger = Logger.getLogger(SynchronousSOMQueueRequestReceiver.class);
		
		// count the number of total seats
        int totalNumberOfSeats = new Double(XPathAPI.eval(somDocument, "count(/*/lineCreation/*/seat | /*/lineChange/*/seat)").num()).intValue();
		
		// if below threshold, just continue. The SOM will be small enough to be easily processed
        if (totalNumberOfSeats <= maxSeatsPerRequest)
        	return somDocument;

        localLogger.info("Big OfficeNet order " + transactionID + 
        		" with > " + maxSeatsPerRequest + 
        		" seats. This order will be truncated and processed in chunks.");

        // check, if the site is already complete. If not, we can just 
        // remove all seats and dependent functions, as they wont be needed
        boolean isSiteComplete = Boolean.parseBoolean(
        		XPathAPI.eval(
        				somDocument, 
        				"count(/*/*/*/voice[processingType = 'IGNORE' or processingStatus = 'completedOPM' or processingStatus = 'completedCCM']) > 0").toString());
        
        int numberOfCompletedSeats = new Double(XPathAPI.eval(somDocument, "count(/*/*/*/seat[processingStatus = 'completedOPM'])").num()).intValue();
        boolean completedSeatsExist = XPathAPI.eval(somDocument, "count(/*/*/*/seat[processingStatus = 'completedCCM' or processingStatus = 'completedOPM']) > 0").bool();

        int keepCounter = 0;
        Set<String> removed = new HashSet<String>();
        
        boolean relevantFunctionsRemoved = false;
        Element functionsElement = (Element) somDocument.getElementsByTagName("functions").item(0);
        NodeList seats = somDocument.getElementsByTagName("seat");

        // If the site in not complete yet, no seats or dependent functions would be created anyway
        // Therefore all seats and dependent functions will just be removed from the SOM
        if (!isSiteComplete || !completedSeatsExist) {
    		for (int listCounter = seats.getLength() - 1; listCounter >= 0; listCounter--) {
    			Node seat = seats.item(listCounter);
    			NodeList seatElements = seat.getChildNodes();
    			int elementCounter = -1;
    			while (++elementCounter < seatElements.getLength()) {
					String ID = extractID(seat);
					functionsElement.removeChild(seat);
					if (!isSiteComplete)
						localLogger.info("Removed seat " + ID + " because site is incomplete.");
					if (!completedSeatsExist)
						localLogger.info("Removed seat " + ID + " because no seat is completed yet.");
					removed.add(ID);
					break;
    			}			
    		}
    		
    		// remove all dependent functions
    		removeDependentFunctions (somDocument, functionsElement, removed, "hardware");
    		removeDependentFunctions (somDocument, functionsElement, removed, "installationSvc");
        }    
        
        // If we now reached a number of seats below the threshold, we have to check again for
        // completed dependent functions. This step has quite a bad performance, but shouldnt happen usually
        // as dependent functions are supposed to be finished before the seat
        // This is done by performing the following steps:
        // 1) check all hardwares:
        //    processingStatus = completedOPM ==> keep function and parent function
        //    processingStatus != completedOPM ==> remove function
        // 2) check all installation services:
        //    processingStatus = completedOPM ==> keep function and parent function
        //    processingStatus != completedOPM ==> remove function
        // 3) check all seats:
        //    processingStatus = completedOPM ==> keep function 
        //    processingStatus = completedCCM ==> keep function
        //    other processingStatus ==> TODO ???? 
        else if (numberOfCompletedSeats <= maxSeatsPerRequest) {
            Set<String> keep = new HashSet<String>();

            int hardwareCounter = 0;
            int installationSvcCounter = 0;
            boolean relevantHardwareFunctionsRemoved = false;
            boolean relevantInstallationSvcFunctionsRemoved = false;
            
            NodeList hardwares = somDocument.getElementsByTagName("hardware");
    		for (int listCounter = hardwares.getLength() - 1; listCounter >= 0; listCounter--) {
    			Node hardware = hardwares.item(listCounter);
    			NodeList hardwareElements = hardware.getChildNodes();
    			int elementCounter = -1;
				String ID = extractID(hardware);
				String refFunctionID = null;
				String processingStatus = null;
    			while (++elementCounter < hardwareElements.getLength() && 
    					(refFunctionID == null || processingStatus == null)) {
    				if (hardwareElements.item(elementCounter).getNodeName().equals("processingStatus")) 
    					processingStatus = hardwareElements.item(elementCounter).getTextContent();
    				if (hardwareElements.item(elementCounter).getNodeName().equals("refFunctionID"))
    					refFunctionID = extractRefFunctionID(hardwareElements.item(elementCounter));
    			}
    			if (processingStatus != null && processingStatus.equals("completedOPM")) {
					if (++hardwareCounter > dependentFunctionThreshold) {
	    				functionsElement.removeChild(hardware);
	    				localLogger.info("Removed " + processingStatus + " hardware " + ID + " because the threshold for dependent services is reached.");						
	    				relevantHardwareFunctionsRemoved = true;
					}
					else {
						keep.add(refFunctionID);
					}
    			}
    			else {
    				functionsElement.removeChild(hardware);
    				localLogger.info("Removed " + processingStatus + " hardware " + ID);
    			}
    		}

            NodeList installationServices = somDocument.getElementsByTagName("installationSvc");
    		for (int listCounter = installationServices.getLength() - 1; listCounter >= 0; listCounter--) {
    			Node installationService = installationServices.item(listCounter);
    			NodeList installationServiceElements = installationService.getChildNodes();
    			int elementCounter = -1;
				String ID = extractID(installationService);
				String refFunctionID = null;
				String processingStatus = null;
    			while (++elementCounter < installationServiceElements.getLength() && 
    					(refFunctionID == null || processingStatus == null)) {
    				if (installationServiceElements.item(elementCounter).getNodeName().equals("processingStatus")) 
    					processingStatus = installationServiceElements.item(elementCounter).getTextContent();
    				if (installationServiceElements.item(elementCounter).getNodeName().equals("refFunctionID"))
    					refFunctionID = extractRefFunctionID(installationServiceElements.item(elementCounter));
    			}
    			if (processingStatus != null && processingStatus.equals("completedOPM")) {
					if (++installationSvcCounter > dependentFunctionThreshold) {
	    				functionsElement.removeChild(installationService);
	    				localLogger.info("Removed " + processingStatus + " installationService " + ID + " because the threshold for dependent services is reached.");						
	    				relevantInstallationSvcFunctionsRemoved = true;
					}
					else {
						keep.add(refFunctionID);
					}
    			}
    			else {
    				functionsElement.removeChild(installationService);
    				localLogger.info("Removed " + processingStatus + " installationService " + ID);
    			}
    		}

    		relevantFunctionsRemoved = relevantHardwareFunctionsRemoved || relevantInstallationSvcFunctionsRemoved;
    		
        	// remove all seats, which are not required
    		for (int listCounter = seats.getLength() - 1; listCounter >= 0; listCounter--) {
    			Node seat = seats.item(listCounter);
				String ID = extractID(seat);
    			if (keep.contains(ID))
    				continue;
    			
    			String processingStatus = extractProcessingStatus(seat);
				if (processingStatus.equals("completedOPM") )
					keep.add(ID);
				else {
					functionsElement.removeChild(seat);						
					localLogger.info("Removed seat " + ID);
				}
            }        		
        }
        
        // The typical case with more completed seats than the threshold and a complete seat.
        // Here we do the following:
        // 1) remove all seats with processingStatus = completedCCM
        // 2) remove all seats with processingStatus = completedCCM exceeding the max number
        // 3) remove all dependent functions of the removed seats
        else {
    		for (int listCounter = seats.getLength() - 1; listCounter >= 0; listCounter--) {
    			Node seat = seats.item(listCounter);    			
    			String processingStatus = extractProcessingStatus(seat);
				String ID = extractID(seat);
    			
				if (processingStatus.equals("completedOPM") && keepCounter >= maxSeatsPerRequest)
					relevantFunctionsRemoved = true;
				
				if (!processingStatus.equals("completedOPM") || keepCounter >= maxSeatsPerRequest) {
					functionsElement.removeChild(seat);						
					localLogger.info("Removed " + processingStatus + " seat " + ID);
					removed.add(ID);
				}
				else
					keepCounter++;
    		}
    		
    		removeDependentFunctions (somDocument, functionsElement, removed, "hardware");
    		removeDependentFunctions (somDocument, functionsElement, removed, "installationSvc");
        }
        
		// add an attribute to the SOM, which TrxBuilder can use to handle the removal of functions
		if (relevantFunctionsRemoved)
			somDocument.getDocumentElement().setAttribute("relevantFunctionsRemoved", "true");

		logSOM(somDocument, transactionID, true);
		
		return somDocument;
	}

	
	private static String extractProcessingStatus(Node function) throws FIFException {
		NodeList functionElements = function.getChildNodes();
		int elementCounter = -1;
		while (++elementCounter < functionElements.getLength()) {
			if (functionElements.item(elementCounter).getNodeName().equals("processingStatus"))
				return functionElements.item(elementCounter).getTextContent();
		}
		throw new FIFException("Function without processingStatus.");
	}

	private static String extractRefFunctionID(Node refFunctionIDElement) throws FIFException {
		NodeList refFunctionIDElements = refFunctionIDElement.getChildNodes();
		int refFunctionIDElementCounter = -1;
		while (++refFunctionIDElementCounter < refFunctionIDElements.getLength()) {
			String elementName = refFunctionIDElements.item(refFunctionIDElementCounter).getNodeName();
			if (elementName != null && elementName.equals("configured")) {
				return refFunctionIDElements.item(refFunctionIDElementCounter).getTextContent();
			}							
		}
		refFunctionIDElementCounter = -1;
		while (++refFunctionIDElementCounter < refFunctionIDElements.getLength()) {
			String elementName = refFunctionIDElements.item(refFunctionIDElementCounter).getNodeName();
			if (elementName != null && elementName.equals("existing")) {
				return refFunctionIDElements.item(refFunctionIDElementCounter).getTextContent();
			}							
		}
		throw new FIFException("Function without refFunctionID.");
	}
	
	private static String extractID(Node function) throws FIFException {
		if (function.getAttributes().getNamedItem("ID") != null)
			return function.getAttributes().getNamedItem("ID").getTextContent();
		throw new FIFException("Function without @ID.");
	}

	private static void removeDependentFunctions(Document somDocument, Element functionsElement, Set<String> removed, String functionName) throws FIFException {
		Logger localLogger = Logger.getLogger(SynchronousSOMQueueRequestReceiver.class);
		NodeList hardwares = somDocument.getElementsByTagName(functionName);		
		for (int listCounter = hardwares.getLength() - 1; listCounter >= 0; listCounter--) {
			Node hardware = hardwares.item(listCounter);
			NodeList hardwareElements = hardware.getChildNodes();
			int elementCounter = -1;
			while (++elementCounter < hardwareElements.getLength()) {
				if (hardwareElements.item(elementCounter).getNodeName().equals("refFunctionID")) {
					String refFunctionID = extractRefFunctionID(hardwareElements.item(elementCounter));
					if (removed.contains(refFunctionID)) {
						functionsElement.removeChild(hardware);
						localLogger.info("Removed hardware for seat " + refFunctionID);
					}															
					break;
				}
			}
		}
	}

	private String cleanMessageString(String message) {		
		Pattern pattern = Pattern.compile("<ProcessFifOrderRequest[^>]+>");
		Matcher matcher = pattern.matcher(message);
		message = matcher.replaceFirst("<ProcessFifOrderRequest>");
		
		pattern = Pattern.compile("xmlns=\".*?\"");
		matcher = pattern.matcher(message);
		message = matcher.replaceAll("");

		pattern = Pattern.compile("(<[/]{0,1})([a-zA-Z0-9]+:)(.*?)([/]{0,1}>)");
		matcher = pattern.matcher(message);
		StringBuffer buffer = new StringBuffer();
		int currentStart = 0;
		while (matcher.find()) {
			buffer.append(message.substring(currentStart, matcher.start()));
			buffer.append(matcher.group(1));
			buffer.append(matcher.group(3));
			buffer.append(matcher.group(4));
			currentStart = matcher.end();
		};
		buffer.append(message.substring(currentStart, message.length()));
		
		return buffer.toString();
	}

	private static void logSOM(Document somDocument, String transactionID, boolean saveSOM) throws FIFException {
		Logger localLogger = Logger.getLogger(SynchronousSOMQueueRequestReceiver.class);
		if (!localLogger.isDebugEnabled() && !saveSOM)
			return;
		
		StringBuffer beautifiedRequest = new StringBuffer();
		// Beautify the original request
		DOMSerializer serializer = new DOMSerializer();
		StringWriter writer = new StringWriter();
		try {
			serializer.serialize(somDocument, writer, true);
			beautifiedRequest.append(writer.toString());
		} catch (Exception e) {
			localLogger.warn("Cannot beautify original request.", e);
		}
					
		if (!localLogger.isDebugEnabled())
			localLogger.debug(beautifiedRequest);
		
		if (saveSOM)
			writeSomMessage(beautifiedRequest, transactionID);
	}

	private void writeSOMRequest(StringBuffer beautifiedRequest, String transactionId, String transactionType) throws FIFException {
	    // Bail out if the message should not be written to a output file
	    if (!ClientConfig.getBoolean("SynchronousSOMQueueClient.WriteSOMRequests"))
	        return;
	
	    String fileName = FileUtils.writeToOutputFile(
	        		beautifiedRequest.toString(), ClientConfig.getPath("SynchronousSOMQueueClient.SOMRequestDir"),
	        		"SOMRequest-" + transactionType + "-" + transactionId, ".xml", false);
	
	    logger.info("Wrote SOM request to: " + fileName);
	}

	/**
	 * @param fifDocument
	 * @return
	 */
	protected static String serializeFifDocument(Document fifDocument) throws FIFException {
		String request;
		OutputFormat format = new OutputFormat (fifDocument); 
		StringWriter sw = new StringWriter ();    
		XMLSerializer serial = new XMLSerializer (sw,format);
		try {
			serial.serialize(fifDocument);
		} catch (IOException e) {
			throw new FIFException(e);
		}

		request = sw.toString();
		return request;
	}

	protected static Document enrichFifRequest(Document fifDocument, Document somDocument, String transactionId, 
			String transactionType, GregorianCalendar overrideSystemDate) throws TransformerException {

        // insert transaction id in text-node /request-list/request-list-id		
        NodeList nodeList = XPathAPI.selectNodeList(fifDocument, "/request-list/request-list-id");
        Node node = nodeList.item(0);
        if (node != null && node.getNodeType() == Node.ELEMENT_NODE) {
            Element element = (Element) node;
            element.setTextContent(transactionId);
        }

        nodeList = XPathAPI.selectNodeList(fifDocument, "/request-list/request-list-name");
        Element el = (Element) nodeList.item(0);
        if (el != null) {
            el.setTextContent(transactionType);
        }

        // set (or replace if exists) the <request-param name="transactionID"> with the
        // transaction ID concatenated with a counter for uniqueness
        nodeList = XPathAPI.selectNodeList(fifDocument, "/request-list/requests/request/request-params");
        SimpleDateFormat sdfFIF = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");
        for (int i = 0; i < nodeList.getLength(); i++) {
            Element element = (Element) nodeList.item(i);

            // check if the transactionID already exists
            NodeList transactionIdNodeList = XPathAPI.selectNodeList(element,
                    "request-param[@name='transactionID']");
            if (transactionIdNodeList.getLength() == 1) {
                // node exists, replace contents
                transactionIdNodeList.item(0).setTextContent(transactionId + "_" + i);
            } else {
                // node does not exist, create it
                Element newElement = fifDocument.createElement("request-param");
                newElement.setAttribute("name", "transactionID");
                newElement.setTextContent(transactionId + "_" + i);
                element.appendChild(newElement);
                // Extension for test framework
                if (overrideSystemDate != null) {
                    Element overrideSystemDateElement = fifDocument.createElement("request-param");
                    overrideSystemDateElement.setAttribute("name", "OVERRIDE_SYSTEM_DATE");
                    overrideSystemDateElement.setTextContent(sdfFIF.format(overrideSystemDate.getTime()));
                    overrideSystemDate.setTimeInMillis(overrideSystemDate.getTimeInMillis() + 300000);
                    element.appendChild(overrideSystemDateElement);
                }
                	
            }
        }
		return fifDocument;
	}

	protected static String getTransactionBuilder(Document somDocument, String transactionType) throws FIFException, TransformerException {		
		String transactionBuilderFilename = null;
		String configHeader = "SynchronousSOMQueueClient.TrxBuilderSelection.";
		
		Logger logger = Logger.getLogger(SynchronousSOMQueueRequestReceiver.class);
		logger.info("Trying to find the proper TrxBuilder for transactionType: " + transactionType);
		try {
			transactionBuilderFilename = ClientConfig.getSetting(configHeader + transactionType + ".Filename");
		} catch (FIFException e) {}
		
		if (transactionBuilderFilename == null) {
			int counter = 0;
			while (true) {				
				String xPathExpression = null;
				try {
					xPathExpression = ClientConfig.getSetting(configHeader + transactionType + 
							"." + ++counter + ".XPathExpression");
				} catch (FIFException e) {
					break;
				}				
				logger.debug("Executing XPath expression: " + xPathExpression);
				XObject result = XPathAPI.eval(somDocument, xPathExpression);
				if (result.bool()) {
					transactionBuilderFilename = ClientConfig.getSetting(configHeader + transactionType + 
							"." + counter + ".Filename");
					break;
				}
			}			
		}
		return transactionBuilderFilename;
	}

	protected static Document transformSomDocument(Document somDocument, String transformer) throws TransformationException, FIFException, TransformerException {
		HierarchicalDataTransformer genericTransformerService = 
        	HierarchicalDataTransformer.getInstance();
        Document fifDocument =  genericTransformerService.transform(SOMToFIFTransformationProvider
		        .getInstance(transformer), new DefaultXMLAdapter(somDocument));

        // check if the fifDocument contains at least on request
		NodeList nodeList = XPathAPI.selectNodeList(fifDocument, "/request-list/requests/*");
		if (nodeList.getLength() == 0) {
			return null;
        }
		
        return fifDocument;
	}

	/**
	 * @param requestDocument
	 * @return
	 * @throws TransformerFactoryConfigurationError
	 * @throws TransformerConfigurationException
	 * @throws TransformerException
	 */
	protected static Document extractSomDocument(Document requestDocument, String transactionType) throws TransformerFactoryConfigurationError, TransformerConfigurationException, TransformerException {
		String rootElement = requestDocument.getDocumentElement().getNodeName();
		Document somDocument = null;
		
		if (rootElement.equals("order"))
			somDocument = requestDocument;
		else {
			NodeList orderElements = requestDocument.getElementsByTagName("order");
			Element orderElement = (Element) orderElements.item(0);

			TransformerFactory tf = TransformerFactory.newInstance();
			Transformer xf = tf.newTransformer();
			DOMResult dr = new DOMResult();
			xf.transform(new DOMSource(orderElement), dr);
			somDocument = (Document) dr.getNode();
		}	
		
        // add transactionType to SOM
        NodeList nodeList = XPathAPI.selectNodeList(somDocument, "/order");
    	Element orderElement = (Element) nodeList.item(0);

        if (orderElement != null) {
            Element firstTransactionTypeElement = somDocument.createElement("transactionType");
            Element secondTransactionTypeElement = somDocument.createElement("transactionType");
            secondTransactionTypeElement.setTextContent(transactionType);
            orderElement.appendChild(firstTransactionTypeElement);
            firstTransactionTypeElement.appendChild(secondTransactionTypeElement);
        }	       
        
		return somDocument;
	}


	private static String writeSomMessage(StringBuffer som, String orderID) throws FIFException {
		Logger localLogger = Logger.getLogger(SynchronousSOMQueueRequestReceiver.class);
		// Return if the message should not be written to a output file
		if (orderID == null)
			orderID = "unknown-id";
		String fileName = FileUtils.writeToOutputFile(som.toString(),
				ClientConfig.getPath("SynchronousSOMQueueClient.SOMRequestDir"), "som" + "-"
					+ orderID, ".xml", false);

		localLogger.info("Wrote SOM message to: " + fileName);
		return fileName;
	}

}
