/*
 $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/ResponseSerializer.java-arc   1.2   Jun 09 2010 17:57:06   schwarje  $

 $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/ResponseSerializer.java-arc  $
 * 
 *    Rev 1.2   Jun 09 2010 17:57:06   schwarje
 * fixed null pointer
 * 
 *    Rev 1.1   Jun 01 2010 18:05:32   schwarje
 * IT-26029: updates
 * 
 *    Rev 1.0   May 25 2010 16:34:18   schwarje
 * Initial revision.
 * 
*/
package net.arcor.fif.messagecreator;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;

import net.arcor.fif.client.QueueClientResponseListMessage;
import net.arcor.fif.client.QueueClientResponseMessage;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.ParsingErrorHandler;

import org.apache.log4j.Logger;
import org.apache.xerces.parsers.DOMParser;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * Class that serializes Request objects to and from XML format.
 * @author goethalo
 */
public class ResponseSerializer {

	/*------------------*
	 * MEMBER VARIABLES *
	 *------------------*/

	/**
	 * The log4j logger.
	 */
	private static Logger logger = Logger.getLogger(ResponseSerializer.class);

	/*---------*
	 * METHODS *
	 *---------*/

	/**
	 * Gets the text contained in an element given the tagname of the element
	 * and the parent element.
	 * @param parent   the parent element
	 * @param tagName  the tag name of the element to take the text for
	 * @return a <code>String</code> containing the element text, null if an
	 * element with the passed in tagname was not found.
	 */
	private static String getElementText(Element parent, String tagName) {
		Element element = (Element) (parent.getElementsByTagName(tagName)
				.item(0));
		if (element == null) {
			return null;
		}
		return (getElementText(element));
	}

	/**
	 * Gets the text contained in an element.
	 *
	 * @param element  the element to take the text from
	 * @return a <code>String</code> containing the text of the element,
	 * null if the element contains no text.
	 */
	private static String getElementText(Element element) {
		if (element == null) {
			return null;
		}
		Node child = element.getFirstChild();
		if (child != null) {
			return (child.getNodeValue());
		} else {
			return null;
		}
	}

	public static Message parseResponseString(String response) throws FIFException {

    	Document doc = getDocumentFromMessageString(response);    	
    	Element root = doc.getDocumentElement();
    	if (root.getNodeName().equals("response-list")) {
    		String listID = getElementText(root, XMLTags.requestListId);
    		String listName = getElementText(root, XMLTags.requestListName);
    		int status = 
    			(getElementText(root, "request-list-result").equals("SUCCESS")) ? 
    					QueueClientResponseListMessage.SUCCESS : 
    					QueueClientResponseListMessage.FAILURE;
    		
    		QueueClientResponseListMessage message = 
    			new QueueClientResponseListMessage(status, listName, listID, null);

    		NodeList responseElements = root.getElementsByTagName("response");
    		for (int i = 0; i < responseElements.getLength();i++) {
    			Element responseElement = (Element) responseElements.item(i);
    			message.getResponses().add(parseSingleResponse(responseElement));    			
    		}
    		
    		return message;
    	}
    	else if (root.getNodeName().equals("response")){
    		return parseSingleResponse(root);
    	}
    	throw new FIFException("Invalid response message found.");
	}

	
	private static QueueClientResponseMessage parseSingleResponse(Element root) throws FIFException {

		String actionName = getElementText(root, XMLTags.actionName);
		String transactionID = getElementText(root, "transaction-id");
		
		int status = 0;
		String statusString = getElementText(root, "transaction-result");
		if (statusString.equals("FAILURE")) status = QueueClientResponseMessage.FAILURE;
		else if (statusString.equals("SUCCESS")) status = QueueClientResponseMessage.SUCCESS;
		else if (statusString.equals("NOT_EXECUTED")) status = QueueClientResponseMessage.NOT_EXECUTED;

		QueueClientResponseMessage singleResponse = 
			new QueueClientResponseMessage(
					status,
					actionName,
					transactionID,
					null);
		
		NodeList errorElements = root.getElementsByTagName("error");
		ArrayList<FIFError> errors = new ArrayList<FIFError>();
		for (int errorCounter = 0; errorCounter < errorElements.getLength();errorCounter++) {
			Element errorElement = (Element) errorElements.item(errorCounter);
			String errorCode = getElementText(errorElement, "number");
			String errorText = getElementText(errorElement, "message");
			errors.add(new FIFError(errorCode, errorText));
		}
		if (singleResponse.getErrors() != null && errors != null)
			singleResponse.getErrors().addAll(errors);
		
		NodeList warningElements = root.getElementsByTagName("warning");
		ArrayList<FIFWarning> warnings = new ArrayList<FIFWarning>();
		for (int warningCounter = 0; warningCounter < warningElements.getLength();warningCounter++) {
			Element warningElement = (Element) warningElements.item(warningCounter);
			String warningCode = getElementText(warningElement, "number");
			String warningText = getElementText(warningElement, "message");
			warnings.add(new FIFWarning(warningCode, warningText));
		}
		if (singleResponse.getWarnings() != null && warnings != null)
			singleResponse.getWarnings().addAll(warnings);
		
		NodeList outputParamElements = root.getElementsByTagName("output-param");
		ArrayList<OutputParameter> outputParameters = new ArrayList<OutputParameter>();
		for (int outputParameterCounter = 0; outputParameterCounter < outputParamElements.getLength();outputParameterCounter++) {
			Element outputParameterElement = (Element) outputParamElements.item(outputParameterCounter);
			String name = outputParameterElement.getAttribute("name");
			NodeList childNodes = outputParameterElement.getChildNodes();
			if (childNodes != null) {
				Node valueNode = childNodes.item(0);
				if (valueNode != null)
					outputParameters.add(new OutputParameter(name, valueNode.getNodeValue()));
			}
		}

		if (singleResponse.getOutputParams() != null && outputParameters != null)
			singleResponse.getOutputParams().addAll(outputParameters);
		return singleResponse;
	}

	private static Document getDocumentFromMessageString(String messageText) throws FIFException {
        try {
            DOMParser parser = new DOMParser();
            ParsingErrorHandler handler = new ParsingErrorHandler();
            parser.setErrorHandler(handler);
            parser.setEntityResolver(new EntityResolver());
            parser.parse(new InputSource(new StringReader(messageText)));

            if (handler.isError()) {
                logger.error(
                    "XML Parsing Errors while generating XML document "
                        + "for message: "
                        + messageText);
                throw new FIFException(
                    "XML parser reported the following errors:\n"
                        + handler.getErrors());
            }
            return (parser.getDocument());
        } catch (SAXException e) {
            throw new FIFException("Cannot parse message string for response message.", e);
        } catch (IOException e) {
            throw new FIFException("Cannot parse message string for response message.", e);
        }
    }


	
}