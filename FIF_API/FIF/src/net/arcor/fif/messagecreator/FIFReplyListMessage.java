/*
 * $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/FIFReplyListMessage.java-arc   1.4   Jan 25 2019 14:46:36   lejam  $
 *
 * $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/FIFReplyListMessage.java-arc  $
 * 
 *    Rev 1.4   Jan 25 2019 14:46:36   lejam
 * SPN-FIF-000135593 Added support of FIFReplyListMessage to createFailureMessage
 * 
 *    Rev 1.3   Mar 04 2010 18:49:54   schwarje
 * IT-26029: redesign of FIF clients
 * 
 *    Rev 1.2   Aug 02 2004 15:26:18   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.1   Jun 15 2004 16:19:36   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.0   Jun 14 2004 15:42:02   goethalo
 * Initial revision.
 */
package net.arcor.fif.messagecreator;

import java.io.IOException;
import java.io.StringWriter;

import javax.jms.JMSException;

import net.arcor.fif.common.DOMSerializer;
import net.arcor.fif.common.FIFException;

import org.apache.log4j.Logger;
import org.apache.xerces.dom.DOMImplementationImpl;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * This class represents a reply list message coming from FIF.
 * It contains functionality to parse the reply and extract the error status and
 * error codes from it.
 * @author goethalo
 */
public class FIFReplyListMessage extends FIFMessage {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(FIFReplyListMessage.class);

    /**
     * The message received from FIF.
     */
    private javax.jms.Message message = null;

    /**
     * The result list container.
     */
    private FIFTransactionListResult result = null;

    /**
     * The parsed XML document.
     */
    private Document doc = null;

    /**
     * Indicates whether the message has been parsed already.
     */
    private boolean parsed = false;

    /**
     * indicates, if the request should be recycled
     */
    private boolean recycleMessage = false;

    /**
     * indicates after which time (in seconds) the request should be rerun, if it is to be recycled 
     */
    private int recycleDelay = 0;

    /*-------------*
     * CONSTRUCTOR *
     *-------------*/

    /**
     * Constructor.
     * @param message        the JMS message containing the FIF reply list.
     * @param messageString  the String contained in the JMS message.
     * @param doc            the XML document represented by the message.
     */
    protected FIFReplyListMessage(
        javax.jms.Message message,
        String messageString,
        Document doc) {
        this.message = message;
        setMessage(messageString);
        this.doc = doc;
        result = new FIFTransactionListResult();
    }

    /**
     * Constructor.
     * @param request  the request for which the CcmFifInterface crashed
     */
    protected FIFReplyListMessage(FIFRequestList request, String errorCode, String errorText) {
    	parsed = true;
    	result = new FIFTransactionListResult();
    	if (request != null) {
    		for (Object singleRequest : request.getRequests()) {
    			if (singleRequest instanceof FIFRequest) {
    				FIFRequest fifRequest = (FIFRequest) singleRequest;
    				FIFReplyMessage singleReply = new FIFReplyMessage(fifRequest, errorCode, errorText);
    				result.addReply(singleReply);
    			}
    		}
			result.setTransactionListID(request.getID());
        }
    	result.addError(new FIFError (errorCode, errorText));
    	result.setResult(FIFTransactionListResult.FAILURE);
    	setMessage(errorText);
    }

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * Gets the XML document.
     * @see net.arcor.fif.messagecreator.Message#getDocument()
     */
    public Document getDocument() throws FIFException {
        if (!parsed) {
            parse();
        }
        return doc;
    }

    /**
     * Gets the transaction list ID.
     * @return the transaction list ID.
     * @throws FIFException if the transaction list ID could not be retrieved.
     */
    public String getTransactionListID() throws FIFException {
        if (!parsed) {
            parse();
        }
        return (result.getTransactionListID());
    }

    /**
     * Gets the transaction list name.
     * @return the transaction list name.
     * @throws FIFException if the transaction list name could not be retrieved.
     */
    public String getListName() throws FIFException {
        if (!parsed) {
            parse();
        }
        return (result.getListName());
    }

    /**
     * Determines whether the received message is valid.
     * The message is valid if it could successfully be parsed.
     * @return boolean true if the message is valid, false if not.
     * @throws FIFException if the state could not be returned. 
     */
    public boolean isValid() throws FIFException {
        if (!parsed) {
            parse();
        }
        return (result.isValid());
    }

    /**
     * Gets the transaction list result.
     * @return the transaction list result.
     * @throws FIFException if the result could not be returned.
     */
    public FIFTransactionListResult getResult() throws FIFException {
        if (!parsed) {
            parse();
        }
        return (result);
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Acknowledges the receival of the FIF reply message from the queue.
     * This method should be called when the acknowledge mode is set to
     * CLIENT_ACKNOWLEDGE whenever a message has been successfully processed.
     * When the acknowledge mode is set the AUTO_ACKNOWLEDGE the behaviour
     * is undefined and depending on the middleware.  MQSeries throws an
     * exception in this case.
     * @throws FIFException  if the message could not be acknowledged.
     */
    public void acknowledge() throws FIFException {
        try {
            if (message != null) {
                message.acknowledge();
            }
        } catch (JMSException e) {
            throw new FIFException("Cannot acknowledge the message.", e);
        }
    }

    /**
     * Constructs the formatted XML representation of the reply text message.
     * Formatted means that each tag is on a new line and that the tags are
     * indented.
     * @return a <code>String</code> containing the formatted XML, the
     * non-formatted message text if the received message is invalid.
     */
    public String getFormattedXMLMessage() throws FIFException {
        // Parse the document if it was not done so far
        if (!parsed) {
            parse();
        }

        if (((!isValid()) && (result.getTransactionListID() == null))
            || (doc == null)) {
            return (getMessage());
        }

        // Create a DOM serializer
        DOMSerializer serializer = new DOMSerializer();

        // Populated the formatted XML
        StringWriter sw = new StringWriter();
        try {
            serializer.serialize(doc, sw);
            return (sw.toString());
        } catch (IOException ioe) {
            logger.error("Cannot serialize XML document: " + getMessage(), ioe);
            return (getMessage());
        }
    }

    /**
     * Parses the data contained in the message.
     */
    private synchronized void parse() throws FIFException {
        if (parsed) {
            // Bail out if the message was parsed already
            return;
        } else {
            // Set the parsed flag to true
            parsed = true;
        }

        result = new FIFTransactionListResult();

        if (getMessage() == null) {
            // Bail out if no message text was provided
            setInvalid(
                "Cannot parse reply list message: no content in received "
                    + "queue message.");
            return;
        }

        // Parse the message
        if (doc == null) {
            return;
        }

        // Extract the transaction list ID and name
        extractTransactionListID();
        logger.debug("Parsing message for list ID " + getTransactionListID());
        extractListName();

        // Extract the state
        extractTransactionListState();

        // Extract the embedded transactions
        extractTransactions();

        logger.debug(
            "Successfully parsed message for list ID "
                + getTransactionListID());
    }

    /**
     * Extracts the transaction list ID from the document.
     */
    private void extractTransactionListID() {
        NodeList IDNodes = doc.getElementsByTagName(XMLTags.transactionListID);
        if ((IDNodes != null) && (IDNodes.getLength() == 1)) {
            result.setTransactionListID(
                getElementText((Element) IDNodes.item(0)).trim());
        }
    }

    /**
     * Extracts the list name from the document
     */
    private void extractListName() throws FIFException {
        NodeList nameNodes =
            doc.getElementsByTagName(XMLTags.transactionListName);
        if ((nameNodes != null) && (nameNodes.getLength() == 1)) {
            result.setListName(
                getElementText((Element) nameNodes.item(0)).trim());
            logger.debug("List name is: " + getListName() + ".");
        }
    }

    /**
     * Extracts the transaction state from the document.
     */
    private void extractTransactionListState() throws FIFException {
        // Get the transaction state
        NodeList stateNodes =
            doc.getElementsByTagName(XMLTags.transactionListState);
        if ((stateNodes == null) || (stateNodes.getLength() != 1)) {
            setInvalid(
                "Message is not of correct format: "
                    + "no <transaction_list_state> tag in message. Message"
                    + getMessage());
            return;
        }
        Element stateNode = (Element) stateNodes.item(0);
        String state = getElementText(stateNode);
        if (state == null) {
            setInvalid(
                "Message is not of correct format: "
                    + "value of <transaction_list_state> is empty. Message: "
                    + getMessage());
            return;
        }

        if (state
            .toUpperCase()
            .equals(XMLTags.transactionListStateSucceeded)) {
            // Set the SUCCESS state on the result object
            result.setResult(FIFTransactionListResult.SUCCESS);
        } else if (
            state.toUpperCase().equals(XMLTags.transactionListStateFailed)) {
            // Set the FAILURE state on the result object
            result.setResult(FIFTransactionListResult.FAILURE);
        } else {
            setInvalid(
                "Message is not of correct format: "
                    + "invalid <transaction_list_state>. Message: "
                    + getMessage());
        }
    }

    /**
     * Extracts the list of embedded transactions from the document
     */
    private void extractTransactions() throws FIFException {
        NodeList transactionNodes =
            doc.getElementsByTagName(XMLTags.transactionRoot);
        if ((transactionNodes == null)
            || (transactionNodes.getLength() == 0)) {
            setInvalid(
                "Message is not of correct format: "
                    + "No <CcmFifCommandList> tags found in document. Message: "
                    + getMessage());
            return;
        }

        for (int i = 0; i < transactionNodes.getLength(); i++) {
            // Get a transaction
            Element transactionNode = (Element) transactionNodes.item(i);

            // Import the transaction subtree in a new document
            DOMImplementation domImpl = new DOMImplementationImpl();
            Document doc =
                domImpl.createDocument(null, XMLTags.transactionRoot, null);
            Node transactionRoot = doc.getDocumentElement();
            Node importedTransaction = doc.importNode(transactionNode, true);
            transactionRoot.appendChild(importedTransaction);

            // Create a reply message for the simple transaction and add it
            // to the result list.
            result.addReply(new FIFReplyMessage(doc));
        }
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

    /**
     * Sets the result list state to invalid.
     * @param message  the message to set on the result list.
     */
    protected void setInvalid(String message) {
        logger.error(message);
        FIFError error = new FIFError("FIF-API", message);
        result.addError(error);
        result.setResult(FIFTransactionListResult.INVALID_REPLY);
    }

	public int getRecycleDelay() {
		return recycleDelay;
	}

	public void setRecycleDelay(int recycleDelay) {
		this.recycleDelay = recycleDelay;
	}

	public boolean getRecycleMessage() {
		return recycleMessage;
	}

	public void setRecycleMessage(boolean recycleMessage) {
		this.recycleMessage = recycleMessage;
	}

}
