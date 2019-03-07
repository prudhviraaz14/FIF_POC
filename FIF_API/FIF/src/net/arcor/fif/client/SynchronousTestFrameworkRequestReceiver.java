/*
 $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousTestFrameworkRequestReceiver.java-arc   1.17   Sep 30 2015 10:11:38   schwarje  $

 $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousTestFrameworkRequestReceiver.java-arc  $
 * 
 *    Rev 1.17   Sep 30 2015 10:11:38   schwarje
 * read XMLs with encoding
 * 
 *    Rev 1.16   Jul 07 2015 08:11:16   schwarje
 * PPM-95514: support EAI action names in TFW
 * 
 *    Rev 1.15   Nov 04 2013 10:57:32   schwarje
 * skip empty processingStatus
 * 
 *    Rev 1.14   Sep 26 2013 08:45:02   schwarje
 * delete empty existing, configured and status tags
 * 
 *    Rev 1.13   Dec 16 2011 09:30:36   schwarje
 * TFW: conditional file insertion in SOM parts
 * 
 *    Rev 1.12   Oct 26 2011 14:37:34   schwarje
 * TF-Fix: added new line while parsing file
 * 
 *    Rev 1.11   Oct 21 2011 13:06:38   banania
 * Read the xml content first in a string and change it if required before parsing it.
 * 
 *    Rev 1.10   Oct 14 2011 15:43:04   schwarje
 * IT-28900: allow replacement of whole files in SOM
 * 
 *    Rev 1.9   Aug 08 2011 08:13:30   schwarje
 * BKS requests for TF
 * 
 *    Rev 1.8   Aug 01 2011 15:53:26   schwarje
 * SPN-FIF-000114339: changed parameter name for logging SOMs
 * 
 *    Rev 1.7   Jul 14 2011 08:18:58   schwarje
 * IT-30480: Handling of large OfficeNet orders
 * 
 *    Rev 1.6   Jun 07 2011 16:01:30   schwarje
 * fixed wrong reporting of failed requests
 *    Rev 1.5   Oct 01 2010 19:04:54   schwarje
 * handle empty transaction builder results
 *  
 *    Rev 1.4   Jul 29 2010 17:38:44   schwarje
 * fixed result of TrxBuilder-Request
 * 
 *    Rev 1.3   Jun 24 2010 17:54:12   schwarje
 * CPCOM Phase 2: new FIF client type accepting SOM orders
 * 
 *    Rev 1.2   Jun 09 2010 18:02:24   schwarje
 * IT-26029: catch all exceptions
 * 
 *    Rev 1.1   Jun 09 2010 16:12:32   schwarje
 * IT-26029: updates for automated tests
 * 
 *    Rev 1.0   Jun 01 2010 18:06:28   schwarje
 * Initial revision.
 * 
*/
package net.arcor.fif.client;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.io.StringWriter;
import java.nio.CharBuffer;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.MatchResult;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.FactoryConfigurationError;
import javax.xml.parsers.ParserConfigurationException;

import net.arcor.fif.ccmtestframework.TFBKSRequest;
import net.arcor.fif.ccmtestframework.TFDocumentSerializer;
import net.arcor.fif.ccmtestframework.TFRequestList;
import net.arcor.fif.ccmtestframework.TFRequestSerializer;
import net.arcor.fif.ccmtestframework.TFSQLRequest;
import net.arcor.fif.ccmtestframework.TFSomPart;
import net.arcor.fif.ccmtestframework.TFTrxBuilderRequest;
import net.arcor.fif.ccmtestframework.TFXMLTags;
import net.arcor.fif.common.DOMSerializer;
import net.arcor.fif.common.DateUtils;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.common.ParsingErrorHandler;
import net.arcor.fif.db.DatabaseConfig;
import net.arcor.fif.db.FifTransaction;
import net.arcor.fif.messagecreator.EntityResolver;
import net.arcor.fif.messagecreator.FIFRequest;
import net.arcor.fif.messagecreator.FIFRequestList;
import net.arcor.fif.messagecreator.InvalidRequest;
import net.arcor.fif.messagecreator.Message;
import net.arcor.fif.messagecreator.OutputParameter;
import net.arcor.fif.messagecreator.Request;
import net.arcor.fif.messagecreator.RequestSerializer;
import net.arcor.fif.messagecreator.ResponseSerializer;
import net.arcor.fif.messagecreator.SimpleParameter;
import net.arcor.fif.transport.ServiceBusInterface;

import org.apache.log4j.Logger;
import org.apache.xerces.parsers.DOMParser;
import org.apache.xpath.XPathAPI;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

public class SynchronousTestFrameworkRequestReceiver extends RequestReceiver {

	/**
	 * The log4j logger.
	 */
	private static Logger logger = Logger.getLogger(SynchronousTestFrameworkRequestReceiver.class);

	/**
	 * The connection to use for the database.
	 */
	private Connection conn = null;

    private String fileName = null;


	public SynchronousTestFrameworkRequestReceiver(ResponseSender responseSender) throws FIFException {
		super (responseSender);
	}
	
	/**
	 * Initializes the application.
	 * 
	 * @throws FIFException
	 */
	protected void init(String fileName) throws FIFException {
		this.fileName  = fileName;
		
		try {
			conn = DriverManager.getConnection(DatabaseConfig.JDBC_CONNECT_STRING_PREFIX + "requestdb");
			conn.setAutoCommit(false);
		} catch (SQLException e) {
			throw new FIFException(
					"Error while initializing database connection.", e);
		}
	}


	/**
	 * Processes a FIF request list
	 * 
	 * @param root
	 *            the root of the XML document to serialize.
	 * @return void
	 * @throws FIFException
	 *             if the request could not be serialized.
	 */
	private boolean processRequestList(Element root) throws FIFException {
		// Populate the request list attributes
		boolean success = true;
		TFRequestList requestList = new TFRequestList();
		requestList.setID(TFDocumentSerializer.getElementText(root,
				TFXMLTags.requestListId));
		requestList.setName(TFDocumentSerializer.getElementText(root,
				TFXMLTags.requestListName));

		// Loop through the embedded requests
		NodeList requests = ((Element) root.getElementsByTagName(
				TFXMLTags.requests).item(0)).getChildNodes();
		for (int i = 0; i < requests.getLength(); i++) {
			Node requestRootNode = requests.item(i);
			if (requestRootNode.getNodeType() != Node.ELEMENT_NODE)
				continue;

			Element requestRoot = (Element) requestRootNode;
			if (requestRoot.getNodeName() != TFXMLTags.requestRoot
					&& requestRoot.getNodeName() != TFXMLTags.sqlRequestRoot
					&& requestRoot.getNodeName() != TFXMLTags.bksRequestRoot
					&& requestRoot.getNodeName() != TFXMLTags.trxBuilderRequestRoot
					&& requestRoot.getNodeName() != TFXMLTags.transactionList)
				continue;

			Request request = TFRequestSerializer.serializeRequest(requestRoot, true);
			if (request instanceof FIFRequest) {
				success = processFifInterfaceRequest(request);
				if (!success) {
					break;
				}
			} else if (request instanceof FIFRequestList) {
				success = processFifInterfaceRequest(request);
				if (!success) {
					break;
				}
			} else if (request instanceof TFSQLRequest) {
				success = processSQLRequest((TFSQLRequest) request);
				if (!success) {
					break;
				}
			} else if (request instanceof TFTrxBuilderRequest) {
				success = processTrxBuilderRequest((TFTrxBuilderRequest) request);
				if (!success) {
					break;
				}
			} else if (request instanceof TFBKSRequest) {
				success = processBKSRequest((TFBKSRequest) request);
				if (!success) {
					break;
				}
			} else if (request instanceof InvalidRequest) {
				success = false;
			}
		}
		return success;
	}

	private static String writeSomMessage(StringBuffer som, String orderID) throws FIFException {

		// Return if the message should not be written to a output file
		if (orderID == null)
			orderID = "unknown-id";
		String fileName = FileUtils.writeToOutputFile(som.toString(),
				ClientConfig.getPath("SynchronousSOMQueueClient.SOMRequestDir"), "som" + "-"
					+ orderID, ".xml", false);

		logger.info("Wrote SOM message to: " + fileName);
		return fileName;
	}

	private static String writeBKSMessage(String bksMessage, String transactionID) throws FIFException {

		// Return if the message should not be written to a output file
		if (transactionID == null)
			transactionID = "unknown-id";
		String fileName = FileUtils.writeToOutputFile(bksMessage,
				ClientConfig.getPath("testframework.BKSMessageDir"), "bks" + "-"
					+ transactionID, ".xml", false);

		logger.info("Wrote BKS message to: " + fileName);
		return fileName;
	}

	/**
	 * Processes a simple FIF request. It writes to and reads from the queues
	 * 
	 * @param request
	 *            the serialized FIF request object.
	 * @return the error state of the reply message.
	 * @throws FIFException
	 *             if the request could not be processed.
	 */
	private boolean processFifInterfaceRequest(Request request) throws FIFException {
		boolean success = true;
		String transactionID = null;
		String action = null;
		if (request instanceof FIFRequest) {
			transactionID = ((FIFRequest)request).getTransactionID();
			action = ((FIFRequest)request).getAction();
		}
		else if (request instanceof FIFRequestList) {
			transactionID = ((FIFRequestList)request).getID();
			action = ((FIFRequestList)request).getName();
		}
		FifTransaction existingFifTransaction = 
			fifTransactionDAO.retrieveFifTransactionById(transactionID, SynchronousFifClient.theClient.getClientType());
		if (existingFifTransaction != null)
			fifTransactionDAO.deleteFifTransaction(existingFifTransaction);

		logger.info("Processing FIF request with transactionID: " + transactionID);		
		processFifRequest(request);
		FifTransaction fifTransaction = 
			fifTransactionDAO.retrieveFifTransactionById(transactionID, SynchronousFifClient.theClient.getClientType());		
		logger.info(fifTransaction.getClientRequest());
		writeRequestMessage(fifTransaction, action);
		
		logger.info("Waiting for response for request with transactionID: " + transactionID);
		String response = null;
		while (true) {
			fifTransaction = fifTransactionDAO.retrieveFifTransactionById(
					transactionID, SynchronousFifClient.theClient.getClientType());
			
			if (fifTransaction != null && 
				!fifTransaction.getStatus().equals(SynchronousFifClient.FIF_TRANSACTION_STATUS_IN_PROGRESS_FIF) &&
				!fifTransaction.getStatus().equals(SynchronousFifClient.FIF_TRANSACTION_STATUS_NEW)) {
				fifTransactionDAO.deleteFifTransaction(fifTransaction);
				fifTransactionDAO.commit();
				response = fifTransaction.getClientResponse();
				writeResponseMessage(fifTransaction, action);
				break;
			}
			try {
				Thread.sleep(500);
			} catch (InterruptedException e) {}
		}
			
		logger.info("Received message:\n" + response);
		
		// parse it into a response object
		Message responseMessage =
    		ResponseSerializer.parseResponseString(response);

		if (responseMessage instanceof QueueClientResponseMessage) {
			if (((QueueClientResponseMessage)responseMessage).getStatus() != QueueClientResponseMessage.SUCCESS)
				success = false;
		}
		else if (responseMessage instanceof QueueClientResponseListMessage) {
			if (((QueueClientResponseListMessage)responseMessage).getStatus() != QueueClientResponseListMessage.SUCCESS)
				success = false;
		}
		
		// Process the message.
		processOutputParams(responseMessage);
		// if (processReply((FIFReplyMessage) msg, false)) {success = false;}

		return success;
	}

	/**
	 * Processes a FIF reply Message output-params. Reads the out-put params and
	 * store the values into a hash map. The key is the action name.
	 * 
	 * @param msg
	 *            the FIF reply message to process.
	 * @throws FIFException
	 *             if the message could not be processed.
	 */
	private void processOutputParams(Message message)
			throws FIFException {
		if (message instanceof QueueClientResponseListMessage)
			for (Object responseObject : ((QueueClientResponseListMessage)message).getResponses())
				processOutputParams(
						((QueueClientResponseMessage)responseObject).getOutputParams(),
						((QueueClientResponseMessage)responseObject).getTransactionID());

		if (message instanceof QueueClientResponseMessage)
			processOutputParams(
					((QueueClientResponseMessage)message).getOutputParams(),
					((QueueClientResponseMessage)message).getTransactionID());
		
	}

	private void processOutputParams(ArrayList outputParams, String transactionID) {
		if (outputParams == null) 
			return;
		Iterator iter = outputParams.iterator();
		while (iter.hasNext()) {
			OutputParameter param = (OutputParameter) iter.next();
			String outParamName = param.getName();
			String outParamValue = param.getValue();
			TFRequestSerializer.outputParameters.put(transactionID + outParamName, outParamValue);
		}		
	}

	/**
	 * runs the desired query and, if applicable, compares the result of the
	 * query with the expected result.
	 * 
	 * @param request
	 *            the SQL request from the scenario file
	 * @return
	 */
	private boolean processSQLRequest(TFSQLRequest request) {
		boolean success = TFRequestSerializer.replaceParameters(request);
		if (success) {
			try {
				Statement stmt = conn.createStatement();
				logger.info("Running statement: " + request.getStatement());
				if (request.getOutputParams().size() == 0
						&& request.getResultParams().size() == 0) {
					if (request.getStatement().trim().toUpperCase().startsWith("INSERT")) {
						stmt.executeUpdate(request.getStatement());
						conn.commit();
					}
					else
						stmt.execute(request.getStatement());
				} else {
					ResultSet rs = stmt.executeQuery(request.getStatement());
					if (rs.next()) {
						success = processResultParams(request, rs);
						if (success)
							processSQLRequestOutputParams(request, rs);
					}
				}
			} catch (SQLException e) {
				logger.error("Error while executing statement.\n", e);
				success = false;
			}
		}
		return success;
	}

	public static String readFileIntoString (String filename) throws FIFException {
		StringBuffer output = new StringBuffer();
		InputStreamReader reader = null;
		logger.debug("Reading file " + filename);
        try {
            reader = new InputStreamReader(new FileInputStream(filename), "ISO-8859-1");
            char[] buffer = new char[1024];
            while (reader.read(buffer) > 0) {
            	output.append(buffer);
            	buffer = new char[1024];
            }
            reader.close();
        } catch (IOException ioe) {
            throw new FIFException("Error while reading file " + filename, ioe);
        }
        return output.toString().trim();
	}

	public static String replaceFiles(String somPartString, Map params) throws FIFException {
		
		String pattern = "\\{file:[^\\}]+\\}";
		String returnString = new String(somPartString);
		 
		Iterable<MatchResult> matches = TFRequestSerializer.findMatches(pattern, somPartString);
		if (matches != null) {
			boolean matchFound = false;
			for (MatchResult r : matches) {
				matchFound = true;
				String matchResult = somPartString.substring(r.start(), r.end());
				
				// file:xyz.xml => just replace file				
				// file:(key=value)xyz.xml => replace, if condition is true
				if (matchResult.startsWith("{file:(")) {
					String key = matchResult.substring(7, matchResult.indexOf("="));
					String value = matchResult.substring(matchResult.indexOf("=") + 1, matchResult.indexOf(")"));
					String fileName = matchResult.substring(matchResult.indexOf(")") + 1, matchResult.length() - 1);
					boolean replaceFile = false;
					Object o = params.get(key);
					if (params != null &&
							params.get(key) instanceof SimpleParameter &&
							((SimpleParameter)params.get(key)).getValue().equals(value))
						replaceFile = true;
					returnString = returnString.replace(
							matchResult, 
							(replaceFile) ? readFileIntoString(fileName) : "");
				}
				else {				
					String fileName = somPartString.substring(r.start()+6, r.end()-1);
					returnString = returnString.replace(matchResult, readFileIntoString(fileName));
				}
			}
			if (matchFound)
				returnString = replaceFiles(returnString, params);
		}
		return returnString;
	}

	private boolean processTrxBuilderRequest(TFTrxBuilderRequest request) throws FIFException {
		boolean success = false;
		List<TFSomPart> parts = request.getSomParts();
		StringBuffer som = new StringBuffer();
		// loop through
		for (TFSomPart part : parts) {
			String somPartString = readFileIntoString(part.getFilename());
			logger.debug("Before replacement: " + somPartString);
			somPartString = replaceFiles(somPartString, part.getParams());
			somPartString = TFRequestSerializer.replaceParameters(somPartString, part.getParams());
			logger.debug("After replacement: " + somPartString);
			somPartString = somPartString.replace("<existing></existing>", "");
			somPartString = somPartString.replace("<configured></configured>", "");
			somPartString = somPartString.replace("<existing/>", "");
			somPartString = somPartString.replace("<configured/>", "");
			somPartString = somPartString.replace("<completionStatusNewCcbId></completionStatusNewCcbId>", "");
			somPartString = somPartString.replace("<completionStatusOldCcbId></completionStatusOldCcbId>", "");
			somPartString = somPartString.replace("<previousCompletionStatusNewCcbId></previousCompletionStatusNewCcbId>", "");
			somPartString = somPartString.replace("<previousCompletionStatusOldCcbId></previousCompletionStatusOldCcbId>", "");
			somPartString = somPartString.replace("<processingStatus></processingStatus>", "");
			logger.debug("After removing empty configured/existing elements: " + somPartString);
			som.append(somPartString);
		}
		logger.info("Complete SOM: " + som);
		
		Document somDocument = null;
		
		try {
			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
			DocumentBuilder db = dbf.newDocumentBuilder();
			somDocument = db.parse(new ByteArrayInputStream(som.toString().getBytes("ISO-8859-1")));
		} catch (FactoryConfigurationError e) {
			logger.error("Exception while parsing SOM", e);
		} catch (ParserConfigurationException e) {
			logger.error("Exception while parsing SOM", e);
		} catch (SAXException e) {
			logger.error("Exception while parsing SOM", e);
		} catch (IOException e) {
			logger.error("Exception while parsing SOM", e);
		}
				
		if (somDocument != null) {
			DOMSerializer serializer = new DOMSerializer();
			StringWriter writer = new StringWriter();
			try {
				serializer.serialize(somDocument, writer, true);
				writeSomMessage(writer.getBuffer(), request.getTransactionID());
			} catch (IOException e) {
				logger.error("Exception while serializing SOM", e);
				writeSomMessage(som, request.getTransactionID());
			}
			
			try {
				somDocument = SynchronousSOMQueueRequestReceiver.extractSomDocument(somDocument, request.getTransactionType());				
				somDocument = SynchronousSOMQueueRequestReceiver.truncateSOM_2_0(somDocument, request.getTransactionID(), request.getTransactionType());
				
				String transformer = SynchronousSOMQueueRequestReceiver.getTransactionBuilder(somDocument, request.getTransactionType());
				logger.info("Transforming request " + request.getTransactionID() + 
						" with transaction builder " + transformer);
				Document fifDocument = SynchronousSOMQueueRequestReceiver.transformSomDocument(somDocument, transformer);
				if (fifDocument == null)
					throw new FIFException("No request to be sent to FIF, no transaction builder trigger fired.");
				
				fifDocument = SynchronousSOMQueueRequestReceiver.enrichFifRequest(
						fifDocument, somDocument, 
						request.getTransactionID(), 
						request.getTransactionType(), 
						request.getOverrideSystemDate());
				String fifRequestString = SynchronousSOMQueueRequestReceiver.serializeFifDocument(fifDocument);

				Request fifRequest = RequestSerializer.serializeFromString(fifRequestString, null, true);
				success = processFifInterfaceRequest(fifRequest);				
			} catch (Throwable e) {
				logger.error("Exception while processing SOM", e);
			}
		}
		else {
			writeSomMessage(som, request.getTransactionID());
		}
		
		return success;

	}
	
	private boolean processBKSRequest(TFBKSRequest request) throws FIFException {
		boolean success = false;
		boolean send = false;
		try {
			send = ClientConfig.getBoolean("testframework.SendBKSRequest");			
		}
		catch (Exception e) {}
			
		if (!send) return false;
		
		ServiceBusInterface.init(null);

		ArrayList<String> keys = new ArrayList<String>(); 
		ArrayList<String> values = new ArrayList<String>(); 
		for (Object key : request.getParams().keySet()) {
			keys.add((String)key);
			String value = ((SimpleParameter) request.getParams().get(key)).getValue();
			values.add(value == null ? "" : (String)value);
		}
			
		String [] keysArray = new String [keys.size()];
		String [] valuesArray = new String [keys.size()];
		String [] outputArray = new String [3];
		try {
			ServiceBusInterface.processRequest(
					"Y", 
					request.getPackageName(), 
					request.getServiceName(), 
					null, 
					"0", 
					keys.toArray(keysArray), 
					values.toArray(valuesArray),
					outputArray);
			success = handleBKSResult(request, outputArray);
		}
		catch (Throwable t){
			logger.error("Exception: ", t);
		}
		return success;
	}

	private boolean handleBKSResult(TFBKSRequest request, String[] outputArray) throws FIFException {
		logger.info("Received the following response from BKS: " + outputArray[0] + 
				", " + outputArray[1]);
		
		if (outputArray[2] != null && outputArray[2].length() > 0) {			
			// parse BKS answer
			DOMParser parser = new DOMParser();

			try {
				ParsingErrorHandler handler = new ParsingErrorHandler();
				parser.setFeature("http://xml.org/sax/features/validation", false);
				parser.setErrorHandler(handler);
	            parser.setEntityResolver(new EntityResolver());			
				parser.parse(new InputSource(new StringReader(outputArray[2])));

				if (handler.isError())
					throw new FIFException("XML parser reported the following errors:\n" + handler.getErrors());
				else if (handler.isWarning()) {
					logger.warn("XML parser reported warnings:\n" + handler.getWarnings());
				}
				
				// Beautify the original request
				StringBuffer beautifiedRequest = new StringBuffer();
				DOMSerializer serializer = new DOMSerializer();
				StringWriter writer = new StringWriter();
				try {
					serializer.serialize(parser.getDocument(), writer, true);
					beautifiedRequest.append(writer.toString());
				} catch (Exception e) {
					logger.warn("Cannot beautify BKS message.", e);
					beautifiedRequest.append(outputArray[2]);
				}
				writeBKSMessage(beautifiedRequest.toString(), request.getTransactionID());
				
				for (String xpathExpression : request.getResultParamList()) {
					String actualResult = XPathAPI.eval(parser.getDocument(), xpathExpression).str();
					String expectedResult = request.getResultParams().get(xpathExpression);
					logger.info("Executed the following XPath expression: " + xpathExpression);
					logger.info("Expected result: " + expectedResult + ", Actual result: " + actualResult);
					if (!actualResult.equals(expectedResult))
						return false;
				}
			} catch (FIFException fe) {
				throw fe;
			} catch (Exception e) {
				throw new FIFException("Exception raised while parsing SOM request.", e);
			} 
		}
		else 
			return false;
		
		return true;
	}

	/**
	 * checks if the results of the SQL statement matches the expected result
	 * 
	 * @param request
	 * @param rs
	 *            the SQL result sitting on the current row
	 * @return true if the results are as expected
	 * @throws SQLException
	 */
	private static boolean processResultParams(TFSQLRequest request,
			ResultSet rs) throws SQLException {
		if (request.getResultParams() == null)
			return true;
		boolean success = true;
		String columnName = null;
		String resultString = null;
		String expectedResult = null;
		Iterator iter = request.getResultParams().keySet().iterator();
		while (iter.hasNext()) {
			columnName = (String) iter.next();
			resultString = getColumnAsString(rs, columnName);
			expectedResult = ((SimpleParameter) request.getResultParams().get(
					columnName)).getValue();
			if (!resultString.equals(expectedResult)) {
				logger.error("Result '" + resultString
						+ "' doesn't match the expected result '"
						+ expectedResult + "'");
				success = false;
			} else {
				logger.info(columnName + " matches the expected result.");
			}
		}
		return success;
	}

	/**
	 * adds output parameters to the list of parameters
	 * 
	 * @param request
	 * @param rs
	 *            the SQL result sitting on the current row
	 * @throws SQLException
	 */
	private void processSQLRequestOutputParams(TFSQLRequest request,
			ResultSet rs) throws SQLException {
		if (request.getOutputParams() == null)
			return;
		if (request.getTransactionId() == null) {
			logger.warn("Cannot process output parameters "
					+ "because transaction id is missing.");
			return;
		}
		String paramName = null;
		String outputString = null;
		Iterator iter = request.getOutputParams().keySet().iterator();
		while (iter.hasNext()) {
			paramName = (String) iter.next();
			outputString = getColumnAsString(rs, paramName);
			logger.info("Output parameter " + paramName + ", Value: " + outputString);
			TFRequestSerializer.outputParameters.put(request.getTransactionId() + paramName, outputString);
		}
	}

	/**
	 * returns the content of a column in the result set as a string
	 * 
	 * @param rs
	 *            the result set
	 * @param columnName
	 *            the column name to check
	 * @return the column content as string
	 * @throws SQLException
	 */
	private static String getColumnAsString(ResultSet rs, String columnName)
			throws SQLException {
		int columnType = rs.getMetaData().getColumnType(
				rs.findColumn(columnName));
		switch (columnType) {
		case Types.BIGINT:
		case Types.NUMERIC:
		case Types.INTEGER:
			return rs.getBigDecimal(columnName).toString();
		case Types.DATE:
			return DateUtils.getDateInFifFormat(rs.getDate(columnName));
		case Types.VARCHAR:
		case Types.CHAR:
			return rs.getString(columnName);
		}
		return null;
	}



	@Override
	protected void resendResponse(FifTransaction fifTransaction) throws FIFException {}

	@Override
	public void run() {
		try {
			
			// Copy the file content to a string and change it if required
			String requestListString = readFileIntoString(fileName);
			requestListString = replaceFiles(requestListString, null);
			// Create the request
			Document doc = TFDocumentSerializer.serializeDocFromString(requestListString);
			Request request = null;

			Element root = doc.getDocumentElement();

			// Determine the request type
			logger.debug("Root tagname is: " + root.getTagName());
			if (root.getTagName().equals(TFXMLTags.requestListRoot)) {
				boolean success = processRequestList(root);
				if (success) logger.info("Test scenario was processed successfully.");
				else logger.info("Test scenario failed.");
			} else {
				throw new FIFException("Request is of unknown type. Type: "
						+ request.getClass().getName());
			}

		} catch (FIFException e) {
			logger.fatal("Cannot process message.", e);		
		} catch (Exception e) {
			logger.fatal("Cannot process message.", e);
		}
		System.exit(1);
	}


	
	private void writeRequestMessage(FifTransaction fifTransaction, String action) throws FIFException {
	    // Bail out if the message should not be written to a output file
	    if (!ClientConfig.getBoolean("SynchronousFifClient.WriteRequestMessages")) {
	        return;
	    }
	
	    String fileName =
	        FileUtils.writeToOutputFile(
	        		fifTransaction.getClientRequest(),
	            ClientConfig.getPath("SynchronousFifClient.RequestOutputDir"),
	            "request-" + action.replace("/", "") + "-" + fifTransaction.getTransactionId(), ".xml",
	            false);
	
	    logger.info("Wrote request message to: " + fileName);
	}

	private void writeResponseMessage(FifTransaction fifTransaction, String action) throws FIFException {
        // Bail out if the message should not be written to a output file
        if (!ClientConfig.getBoolean("SynchronousFifClient.WriteResponseMessages")) {
            return;
        }

	    String fileName =
	        FileUtils.writeToOutputFile(
	        		fifTransaction.getClientResponse(),
	            ClientConfig.getPath("SynchronousFifClient.ResponseOutputDir"),
	            "response-" + action.replace("/", "") + "-" + fifTransaction.getTransactionId(), ".xml",
	            false);

        logger.info("Wrote response message to: " + fileName);
	}

	
	
	
	
	
}
