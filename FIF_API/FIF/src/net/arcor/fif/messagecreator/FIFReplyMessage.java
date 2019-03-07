/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/FIFReplyMessage.java-arc   1.20   Feb 11 2009 13:45:36   makuier  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/FIFReplyMessage.java-arc  $
 * 
 *    Rev 1.20   Feb 11 2009 13:45:36   makuier
 * Handle request list in failure message
 * 
 *    Rev 1.19   Nov 07 2008 12:35:40   makuier
 * do not populate output if no command matching the id is found. 
 * 
 *    Rev 1.18   Feb 28 2008 19:28:38   schwarje
 * IT-20793: updated
 * 
 *    Rev 1.17   Feb 28 2008 15:25:54   schwarje
 * IT-20793: added processing of events
 * 
 *    Rev 1.16   Feb 06 2008 20:05:38   schwarje
 * IT-20058: update
 * 
 *    Rev 1.15   Feb 05 2008 14:52:26   schwarje
 * SPN-FIF-000067066: parse FIF reply correctly, if it contains more than one action name or package name tag
 * 
 *    Rev 1.14   Jan 30 2008 08:26:36   schwarje
 * IT-20058: Redesign of FIF service bus client
 * 
 *    Rev 1.13   Jul 25 2007 21:00:14   makuier
 * package name added.
 * 
 *    Rev 1.12   Jan 17 2007 18:01:02   makuier
 * handle the cancelation and postponement.
 * SPN-FIF-000046682
 * 
 *    Rev 1.11   Dec 13 2006 13:30:02   makuier
 * Take the first value if there is more than one transaction_id tag in the tree. 
 * SPN-FIF-000048903
 * 
 *    Rev 1.10   Aug 25 2004 13:32:34   goethalo
 * SPN-FIF-000024999: Fixed extraction of action_name tag.
 * 
 *    Rev 1.9   Aug 02 2004 15:26:18   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.8   Jun 15 2004 16:19:36   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.7   Jun 14 2004 15:43:06   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.6   Dec 17 2003 14:56:00   goethalo
 * Changes for IT-9245: ISDN changes.
 * 
 *    Rev 1.5   Nov 26 2003 10:35:40   goethalo
 * IN-000018341: Additional fixes.
 * 
 *    Rev 1.4   Oct 07 2003 14:51:28   goethalo
 * Changes for IT-9811 - Internet By Call with Registration
 * 
 *    Rev 1.3   Sep 10 2003 12:38:28   goethalo
 * Additional changes for IT-10800
 * 
 *    Rev 1.2   Sep 09 2003 16:37:00   goethalo
 * IT-10800: added warning support.
 * 
 *    Rev 1.1   Jul 16 2003 14:59:28   goethalo
 * Changes for IT-9750
 * 
 *    Rev 1.0   Apr 09 2003 09:34:36   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.io.IOException;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Iterator;

import javax.jms.JMSException;

import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import net.arcor.fif.common.DOMSerializer;
import net.arcor.fif.common.FIFException;

/**
 * This class represents a single reply message coming from FIF.
 * It contains functionality to parse the reply and extract the error status and
 * error codes from it.
 * @author goethalo
 */
public class FIFReplyMessage extends FIFMessage {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/
    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(FIFReplyMessage.class);

    /**
     * The message received from FIF.
     */
    private javax.jms.Message message = null;

    /**
     * The result container.
     */
    private FIFTransactionResult result = null;

    /**
     * Indicates whether to return the warnings.
     */
    private boolean returnWarnings = false;

    /**
     * The list of output parameters.
     */
    private ArrayList outputParameters = null;

    /**
     * The parsed XML document.
     */
    private Document doc = null;

    /**
     * Indicates whether the message has been parsed already.
     */
    private boolean parsed = false;

    /**
     * Indicates whether the reply message contains warnings.
     */
    private boolean hasWarnings = false;

    /**
     * Indicates whether this reply is part of a transaction list.
     */
    private boolean embeddedInList = false;

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
     * @param message        the JMS message containing the FIF reply.
     * @param messageString  the String contained in the JMS message.
     * @param doc            the XML document representing the reply message.
     */
    protected FIFReplyMessage(
        javax.jms.Message message,
        String messageString,
        Document doc) {
        this.message = message;
        setMessage(messageString);
        this.doc = doc;
        result = new FIFTransactionResult();
    }

    /**
     * Constructor.
     * @param doc  the XML document representing the reply message.
     */
    protected FIFReplyMessage(Document doc) {
        this.doc = doc;
        embeddedInList = true;
        setMessage("Reply part of a transaction list.");
        result = new FIFTransactionResult();
    }

    /**
     * Constructor.
     * @param request  the request for which the CcmFifInterface crashed
     */
    protected FIFReplyMessage(Request request, String errorCode, String errorText) {
    	parsed = true;
    	result = new FIFTransactionResult();
    	result.setResult(FIFTransactionResult.FAILURE);
    	if (request != null) {
    		if (request instanceof FIFRequest){
    			result.setTransactionID(((SimpleParameter)request.getParam("transactionID")).getValue());
        		result.setActionName(request.getAction());
    		}
    		if (request instanceof FIFRequestList){
    			result.setTransactionID(((FIFRequestList)request).getID());
        		result.setActionName(((FIFRequestList)request).getName());
    		}
        	if (request.getParam("packageName") != null)
        		result.setPackageName(((SimpleParameter)request.getParam("packageName")).getValue());
        }
    	ArrayList<FIFResult> results = new ArrayList<FIFResult>();
    	results.add(new FIFError (errorCode, errorText));
    	FIFCommandResult commandResult = 
    		new FIFCommandResult(
    				"failed_request", 
    				FIFCommandResult.FAILURE,
    				results);
    	result.addResult(commandResult);
    	setMessage(errorText);   
    }

    /**
     * Constructor.
     * Only accessible in this package for testing purposes.
     */
    protected FIFReplyMessage() {
        super();
        result = new FIFTransactionResult();
    }

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * Determines whether the reply message contains an error message.
     * @return true if the message contains an error message, false if not.
     */
    public boolean isError() throws FIFException {
        if (!parsed) {
            parse();
        }
        if (result.getResult() != FIFTransactionResult.SUCCESS) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * Gets the result from the FIF reply message.
     * @return the result of the FIF transaction.
     */
    public FIFTransactionResult getResult() throws FIFException {
        if (!parsed) {
            parse();
        }
        return result;
    }

    /**
     * Gets the action name from the reply message.
     * @return the ID, null if no action name was found in the reply.
     */
    public String getActionName() throws FIFException {
        if (!parsed) {
            parse();
        }
        return (result.getActionName());
    }

    /**
     * Gets the action name from the reply message.
     * @return the ID, null if no action name was found in the reply.
     */
    public String getPackageName() throws FIFException {
        if (!parsed) {
            parse();
        }
        return (result.getPackageName());
    }

    /**
     * Gets the transaction ID from the reply message.
     * @return the ID, null if no transaction ID was found in the reply.
     */
    public String getTransactionID() throws FIFException {
        if (!parsed) {
            parse();
        }
        return (result.getTransactionID());
    }

    /**
     * Determines whether the received message is valid.
     * The message is valid if it could successfully be parsed.
     * @return boolean true if the message is valid, false if not.
     */
    public boolean isValid() throws FIFException {
        if (!parsed) {
            parse();
        }
        return (result.isValid());
    }

    /**
     * Determines whether the received message contains warnings.
     * @return true if the message contains warnings, false if not.
     */
    public boolean hasWarnings() throws FIFException {
        if (!parsed) {
            parse();
        }
        return hasWarnings;
    }

    /**
     * Determines whether the warning in the received message should be
     * returned.
     * @return true if the warnings should be returned, false if not.
     */
    public boolean returnWarnings() throws FIFException {
        if (!parsed) {
            parse();
        }
        return returnWarnings;
    }

    /**
     * Gets the output parameters that should be returned to the caller. 
     * @return the array containing the <code>OutputParameter</code> objects to
     * be returned.
     */
    public ArrayList getOutputParameters() throws FIFException {
        if (!parsed) {
            parse();
        }
        return outputParameters;
    }

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
        if (embeddedInList) {
            return;
        }
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
        if (embeddedInList) {
            return null;
        }
        // Parse the document if it was not done so far
        if (!parsed) {
            parse();
        }

        if (((!isValid()) && (result.getTransactionID() == null))
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

        // Create a new result container
        result = new FIFTransactionResult();

        // Create a new output parameter container
        outputParameters = new ArrayList();

        if (getMessage() == null) {
            // Bail out if no message text was provided
            setInvalid(
                "Cannot parse reply message: no content in received "
                    + "queue message.");
            return;
        }

        // Parse the message
        if (doc == null) {
            return;
        }

        // Extract the transaction ID
        extractTransactionID();
        logger.debug(
            "Parsing message for transaction ID " + getTransactionID() + "...");

        // Extract the action name
        extractActionName();

        // Extract the package name
        extractPackageName();

        // Extract the transaction state
        Node stateNode = extractTransactionState();
        if (stateNode == null) {
            return;
        }

        // Determine of the warnings should be returned for this action
        determineReturnWarnings();

        // Extract the top-level warnings, if needed.
        if (returnWarnings == true) {
            extractTopLevelWarnings(stateNode);
        }

        // Extract the execution states of each command.
        extractCommandStates();

        // Extract the output parameters
        extractOutputParameters();

        logger.debug(
            "Successfully parsed message for transaction ID "
                + getTransactionID()
                + ".");
    }

    /**
     * Extracts the transaction ID from the document.
     */
    private void extractTransactionID() {
        NodeList IDNodes = doc.getElementsByTagName(XMLTags.transactionId);
        if ((IDNodes != null) && (IDNodes.getLength() >= 1) && (IDNodes.item(0) != null)) {
        	String transactionID = getElementText((Element) IDNodes.item(0));
        	if (transactionID != null) {
	            result.setTransactionID(
	                transactionID.trim());
        	}
        }
    }

    /**
     * Extracts the action name from the document
     */
    private void extractActionName() throws FIFException {
        NodeList nameNodes = doc.getElementsByTagName(XMLTags.replyActionName);
        if ((nameNodes != null) && (nameNodes.getLength() >= 1) && (nameNodes.item(0) != null)) {
        	String actionName = getElementText((Element) nameNodes.item(0));
        	if (actionName != null) {
        		result.setActionName(actionName.trim());
        	}	
            logger.debug("Action name is: " + getActionName() + ".");
        }
    }

    /**
     * Extracts the package name from the document
     */
    private void extractPackageName() throws FIFException {
        NodeList nameNodes = doc.getElementsByTagName(XMLTags.replyPackageName);
        if ((nameNodes != null) && (nameNodes.getLength() >= 1) && (nameNodes.item(0) != null)) {
        	String packageName = getElementText((Element) nameNodes.item(0));
        	if (packageName != null) {
        		result.setPackageName(packageName.trim());
        	}	
            logger.debug("package name is: " + getPackageName() + ".");
        }
    }

    /**
     * Extracts the transaction state from the document.
     */
    private Node extractTransactionState() throws FIFException {
        // Get the transaction state
        NodeList stateNodes =
            doc.getElementsByTagName(XMLTags.transactionState);
        if ((stateNodes == null) || (stateNodes.getLength() != 1)) {
            setInvalid(
                "Message is not of correct format: "
                    + "no <transaction_state> tag in message. Message"
                    + getMessage());
            return null;
        }
        Element stateNode = (Element) stateNodes.item(0);
        String state = getElementText(stateNode);
        if (state == null) {
            setInvalid(
                "Message is not of correct format: "
                    + "<transaction_state> is unknown. Message: "
                    + getMessage());
            return null;
        }

        if (state.toUpperCase().equals(XMLTags.transactionStateSucceeded)) {
            // Set the SUCCESS state on the result object
            result.setResult(FIFTransactionResult.SUCCESS);
        } else if (
                state.toUpperCase().equals(XMLTags.transactionStateFailed)) {
                // Set the FAILURE state on the result object
                result.setResult(FIFTransactionResult.FAILURE);
        } else if (
                state.toUpperCase().equals(XMLTags.transactionStateCanceled)) {
                // Set the CANCELED state on the result object
                result.setResult(FIFTransactionResult.CANCELED);
        } else if (
                state.toUpperCase().equals(XMLTags.transactionStatePostpones)) {
                // Set the POSTPONED state on the result object
                result.setResult(FIFTransactionResult.POSTPONED);
        } else if (
            state.toUpperCase().equals(XMLTags.transactionStateNotExecuted)) {
            result.setResult(FIFTransactionResult.NOT_EXECUTED);
        } else {
            setInvalid(
                "Message is not of correct format: "
                    + "invalid <transaction_state>. Message: "
                    + getMessage());
            return null;
        }

        return stateNode;
    }

    /**
     * Determines whether the warnings should be returned for this
     * action.
     */
    private void determineReturnWarnings() throws FIFException {
        if (MessageCreatorMetaData.hasActionMapping(getActionName())) {
            try {
                returnWarnings =
                    MessageCreatorMetaData
                        .getActionMapping(getActionName())
                        .returnWarnings();
            } catch (FIFException fe) {
                returnWarnings = false;
            }
        }
    }

    /**
     * Extracts the top level warnings from the transaction.
     * @param stateNode  the node containing the transaction state.
     */
    private void extractTopLevelWarnings(Node stateNode) throws FIFException {
        // Get the top-level warnings in case of success
        if (result.getResult() == FIFTransactionResult.SUCCESS) {
            // Get the warnings
            Node warningListNode = stateNode.getNextSibling();
            NodeList warningNodes = null;

            if ((warningListNode != null)
                && (warningListNode instanceof Element)) {
                if (warningListNode
                    .getNodeName()
                    .equals(XMLTags.commandWarningList)) {
                    warningNodes = warningListNode.getChildNodes();
                }
            }

            // Set the hasWarnings flag        
            if ((hasWarnings == false)
                && (warningNodes != null)
                && (warningNodes.getLength() != 0)) {
                hasWarnings = true;
            }

            // Create the warning objects
            ArrayList warnings = null;
            if (hasWarnings == true) {
                warnings = new ArrayList();
                for (int j = 0;
                    (warningNodes != null) && (j < warningNodes.getLength());
                    j++) {
                    Element warning = (Element) warningNodes.item(j);
                    Element number =
                        (Element) warning.getElementsByTagName(
                            XMLTags.commandWarningType).item(
                            0);
                    Element message =
                        (Element) warning.getElementsByTagName(
                            XMLTags.commandWarningDescription).item(
                            0);
                    warnings.add(
                        new FIFWarning(
                            getElementText(number),
                            getElementText(message)));
                }
            }

            if (hasWarnings == true) {
                result.addResult(
                    new FIFCommandResult(
                        result.getActionName(),
                        FIFCommandResult.SUCCESS,
                        warnings));
            }
        }
    }

    /**
     * Extracts the execution states of the individual commands
     * in the transaction.
     */
    private void extractCommandStates() throws FIFException {
        // Get all the execution state nodes
        NodeList commandStateNodes =
            doc.getElementsByTagName(XMLTags.executionState);
        if ((!embeddedInList)
            && ((commandStateNodes == null)
                || (commandStateNodes.getLength() == 0))) {
            return;
        }

        // Loop through the command execution state nodes
        for (int i = 0; i < commandStateNodes.getLength(); i++) {
            // Get the command state
            Element commandStateElement = (Element) commandStateNodes.item(i);
            String commandState = getElementText(commandStateElement);
            if (commandState == null) {
                setInvalid(
                    "Message is not of correct format: "
                        + "Command state unknown. Message: "
                        + getMessage());
                return;
            }

            // Get the command node
            Node command = commandStateElement.getParentNode();
            if (command.getNodeType() != Node.ELEMENT_NODE) {
                setInvalid(
                    "Message is not of correct format: "
                        + "Parent of command state is not an element node."
                        + " Message: "
                        + getMessage());
                return;
            }

            // Get the command name
            String commandName = ((Element) command).getTagName();

            // Get the command results
            ArrayList results = getResults((Element) command);

            // Check the state
            if (commandState
                .toUpperCase()
                .equals(XMLTags.executionStateSuccess)) {
                if (result.getResult() == FIFTransactionResult.SUCCESS) {
                    // The command was executed and commited        
                    result.addResult(
                        new FIFCommandResult(
                            commandName,
                            FIFCommandResult.SUCCESS,
                            results));
                } else {
                    // The command was executed but rolled back        
                    result.addResult(
                        new FIFCommandResult(
                            commandName,
                            FIFCommandResult.ROLLED_BACK,
                            null));
                }
            } else if (
                commandState.toUpperCase().equals(
                    XMLTags.executionStateNotExecuted)) {
                // The command was not executed
                result.addResult(
                    new FIFCommandResult(
                        commandName,
                        FIFCommandResult.NOT_EXECUTED,
                        null));
            } else if (
                commandState.toUpperCase().equals(
                    XMLTags.executionStateFailed)) {
                // The command failed
                result.addResult(
                    new FIFCommandResult(
                        commandName,
                        FIFCommandResult.FAILURE,
                        results));
            }
        }
    }

    /**
     * Extracts the output parameters from the document.
     */
    private void extractOutputParameters() throws FIFException {
        if (result.getResult() == FIFTransactionResult.SUCCESS) {
            // Get the output parameter metadata
            ArrayList outputParamMetaData = null;
            if (MessageCreatorMetaData.hasActionMapping(getActionName())) {
                try {
                    outputParamMetaData =
                        MessageCreatorMetaData
                            .getActionMapping(getActionName())
                            .getOutputParams();
                } catch (FIFException fe) {
                    outputParamMetaData = null;
                }
            }

            if ((outputParamMetaData == null)
                || (outputParamMetaData.size() == 0)) {
                // Bail out if there is no metadata
                logger.debug("No output param metadata");
                return;
            }

            // Populate the output parameters
            Iterator iter = outputParamMetaData.iterator();
            while (iter.hasNext()) {
                OutputParameterMetaData pmd =
                    (OutputParameterMetaData) iter.next();
                OutputParameter param = getOutputParameter(pmd);
                if (param != null) {
                    outputParameters.add(param);
                } else {
                    // An error occured
                    return;
                }
            }
        }
    }

    /**
     * Gets an output parameter from the document.
     * @param pmd  the metadata related to the output parameter.
     * @return  the output parameter.
     */
    private OutputParameter getOutputParameter(OutputParameterMetaData pmd) {
        Element root = null;
        OutputParameter param = null;

        // See if we have to search based on command id
        if ((pmd.getResponseCommandID() != null)
            && (!pmd.getResponseCommandID().equals(""))) {
            NodeList commandNodes = doc.getElementsByTagName(XMLTags.commandID);
            try {
                if ((commandNodes == null)
                    || (commandNodes.getLength() == 0)) {
                    // Command not found.  Set an empty value.
                    param = new OutputParameter(pmd.getOutputName(), "");
                    logger.debug(
                        pmd.getResponseCommandID()
                            + " not found in response message");
                    return param;
                } else {
                    for (int i = 0; i < commandNodes.getLength(); i++) {
                        Element current = (Element) commandNodes.item(i);
                        String commandID = getElementText(current);
                        if (commandID != null
                            && commandID.equals(pmd.getResponseCommandID())) {
                            // Command found.  Set its value.
                            root = (Element) current.getParentNode();
                            logger.debug(
                                pmd.getResponseCommandID()
                                    + " node found in response message");
                            break;
                        }
                    }
                }
            } catch (FIFException fe) {
                // This should never happen... (how typical)
                // But let's log an error anyway, just in case ;-)
                setInvalid("Problems while getting output parameters" + fe);
                return null;
            }

        }
        // Try to find the output parameter in the document
        logger.debug(
            "Getting " + pmd.getResponseName() + " from response message");
        NodeList outputNodes = null;
        if (root != null) {
            outputNodes = root.getElementsByTagName(pmd.getResponseName());
        }
        try {
            if ((outputNodes == null) || (outputNodes.getLength() == 0)) {
                // Parameter not found.  Set an empty value.
                param = new OutputParameter(pmd.getOutputName(), "");
                logger.debug(
                    pmd.getResponseName() + " not found in response message");
            } else {
                // Parameter found.  Set its value.
                param =
                    new OutputParameter(
                        pmd.getOutputName(),
                        getElementText((Element) outputNodes.item(0)));
                logger.debug(
                    pmd.getResponseName() + " found in response message");
            }
        } catch (FIFException fe) {
            // This should never happen... (how typical)
            // But let's log an error anyway, just in case ;-)
            setInvalid("Problems while getting output parameters" + fe);
            return null;
        }
        return param;
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
     * Sets the result state to invalid.
     * @param message  the message to set on the result.
     */
    protected void setInvalid(String message) {
        logger.error(message);
        FIFError error = new FIFError("FIF-API", message);
        ArrayList errors = new ArrayList();
        errors.add(error);
        FIFCommandResult commandResult =
            new FIFCommandResult("FIF-API", FIFCommandResult.FAILURE, errors);
        result.setResult(FIFTransactionResult.INVALID_REPLY);
        result.addResult(commandResult);
    }

    /**
     * Gets the result messages contained in a node of the DOM tree.
     * @param command  the command container to get the results from.
     * @return an <code>ArrayList</code> object containing FIFResult objects.
     */
    private ArrayList getResults(Element command) {
        ArrayList results = new ArrayList();

        // Get the errors
        NodeList errorNodes =
            command.getElementsByTagName(XMLTags.commandError);
        for (int j = 0;
            (errorNodes != null) && (j < errorNodes.getLength());
            j++) {
            Element error = (Element) errorNodes.item(j);
            Element number =
                (Element) error.getElementsByTagName(
                    XMLTags.commandErrorType).item(
                    0);
            Element message =
                (Element) error.getElementsByTagName(
                    XMLTags.commandErrorDescription).item(
                    0);
            results.add(
                new FIFError(getElementText(number), getElementText(message)));
        }

        if (returnWarnings == true) {
            // Get the warnings
            NodeList warningNodes =
                command.getElementsByTagName(XMLTags.commandWarning);

            // Set the hasWarnings flag        
            if ((hasWarnings == false)
                && (warningNodes != null)
                && (warningNodes.getLength() != 0)) {
                hasWarnings = true;
            }

            // Create the warning objects
            for (int j = 0;
                (warningNodes != null) && (j < warningNodes.getLength());
                j++) {
                Element warning = (Element) warningNodes.item(j);
                Element number =
                    (Element) warning.getElementsByTagName(
                        XMLTags.commandWarningType).item(
                        0);
                Element message =
                    (Element) warning.getElementsByTagName(
                        XMLTags.commandWarningDescription).item(
                        0);
                results.add(
                    new FIFWarning(
                        getElementText(number),
                        getElementText(message)));
            }
        }

        return results;
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
