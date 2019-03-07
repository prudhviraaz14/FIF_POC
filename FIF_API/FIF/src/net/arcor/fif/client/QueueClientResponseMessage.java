/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/QueueClientResponseMessage.java-arc   1.11   Dec 20 2018 12:13:24   Lalitpise  $
    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/QueueClientResponseMessage.java-arc  $
 * 
 *    Rev 1.11   Dec 20 2018 12:13:24   Lalitpise
 * IT-K34257 removed methods addJmsReplyTo and addJmsCorrelationID methods
 * 
 *    Rev 1.8   Jun 01 2010 18:02:00   schwarje
 * IT-26029: updates
 * 
 *    Rev 1.7   May 25 2010 16:33:28   schwarje
 * IT-26029: updates
 * 
 *    Rev 1.6   Jun 15 2004 16:19:32   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.5   Jun 14 2004 15:43:02   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.4   Oct 07 2003 14:50:44   goethalo
 * Changes for IT-9811 - Internet By Call with Registration
 * 
 *    Rev 1.3   Sep 10 2003 12:36:44   goethalo
 * Additional changes for IT-10800.
 * 
 *    Rev 1.2   Sep 09 2003 16:34:58   goethalo
 * IT-10800: support for warnings and parameter lists in DB clients.
*/
package net.arcor.fif.client;

import java.io.IOException;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Iterator;

import net.arcor.fif.common.DOMSerializer;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.messagecreator.FIFCommandResult;
import net.arcor.fif.messagecreator.FIFError;
import net.arcor.fif.messagecreator.FIFReplyMessage;
import net.arcor.fif.messagecreator.FIFResult;
import net.arcor.fif.messagecreator.FIFTransactionResult;
import net.arcor.fif.messagecreator.FIFWarning;
import net.arcor.fif.messagecreator.Message;
import net.arcor.fif.messagecreator.OutputParameter;

import org.apache.xerces.dom.DOMImplementationImpl;
import org.w3c.dom.DOMException;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Text;

/**
 * This class represents a response message for the Queue Client.
 * @author goethalo
 */
public class QueueClientResponseMessage extends Message {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /** The transaction was successfully validated before sending to FIF */
    public static int VALIDATED = 1;

    /** The transaction was successfully executed by FIF */
    public static int SUCCESS = 2;

    /** The transaction failed in FIF */
    public static int FAILURE = 3;

    /** The transaction was not executed in FIF */
    public static int NOT_EXECUTED = 4;

    /**
     * The status of the FIF transaction the response message is related to.
     */
    private int status = FAILURE;

    /**
     * The action name the response is for.
     */
    private String actionName = null;

    /**
     * The transaction ID the response is for.
     */
    private String transactionID = null;

     /**
	 * The jmsCorrelation ID the response is for.
     */
	private String jmsCorrelationId = null;
	
	/**
     * Using the ReplyTo mechanism the default for QueueClients.
     */
	private String jmsReplyTo = null;
	
    /**
     * The output parameters to be put in the response.
     */
    private ArrayList outputParams = new ArrayList();

    /**
     * The list of <code>FIFError</code> objects related to the reply.
     */
    private ArrayList errors = new ArrayList();

    /**
     * The list of <code>FIFWarning</code> objects related to the reply.
     */
    private ArrayList warnings = new ArrayList();

    /**
     * Indicates whether the message text has already been generated.
     */
    private boolean generated = false;

    /**
     * The response XML document.
     */
    private Document response = null;

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Constructor.
     * @param status         the status to construct the message for (SUCCESS/FAILURE).
     * @param actionName     the name of the action the client request was related to.
     * @param transactionID  the transaction ID of the client request.
     * @param errors         the list of <code>FIFError</code> objects that have to be 
     *                       included in the response.
     */
    public QueueClientResponseMessage(
        int status,
        String actionName,
        String transactionID,
		String jmsCorrelationId,
		String jmsReplyTo,
        ArrayList errors) {
        this.status = status;
        this.actionName = actionName;
        this.transactionID = transactionID;
		this.jmsCorrelationId = jmsCorrelationId;
		this.jmsReplyTo = jmsReplyTo;
        if (errors != null)
        	this.errors.addAll(errors);
    }
    
    /**
     * Constructor.
     * @param status         the status to construct the message for (SUCCESS/FAILURE).
     * @param actionName     the name of the action the client request was related to.
     * @param transactionID  the transaction ID of the client request.
     * @param errors         the list of <code>FIFError</code> objects that have to be 
     *                       included in the response.
     */
    public QueueClientResponseMessage(
            int status,
            String actionName,
            String transactionID,
            ArrayList errors) {
            this.status = status;
            this.actionName = actionName;
            this.transactionID = transactionID;
            if (errors != null)
            	this.errors.addAll(errors);
        }

    /**
     * Constructor.
     * @param msg  the reply returned by FIF.
     */
    public QueueClientResponseMessage(FIFReplyMessage msg)
        throws FIFException {
        FIFTransactionResult result = msg.getResult();

        // Set the result
        if (result.getResult() == FIFTransactionResult.SUCCESS) {
            status = SUCCESS;
        } else if (result.getResult() == FIFTransactionResult.NOT_EXECUTED) {
            status = NOT_EXECUTED;
        } else {
            status = FAILURE;
        }

        // Set the action name and transaction ID
        actionName = result.getActionName();
        transactionID = result.getTransactionID();

        // Set the output parameters
        outputParams = msg.getOutputParameters();

        // Copy over the errors and warnings
        errors = new ArrayList();
        warnings = new ArrayList();
        for (int i = 0; i < result.getResults().size(); i++) {
            FIFCommandResult commandResult =
                (FIFCommandResult) result.getResults().get(i);

            for (int j = 0;
                (commandResult.getResults() != null)
                    && (j < commandResult.getResults().size());
                j++) {
                FIFResult fifResult =
                    (FIFResult) commandResult.getResults().get(j);
                if (fifResult instanceof FIFError) {
                    errors.add(fifResult);
                } else {
                    warnings.add(fifResult);
                }
            }
        }
    }

    /**
     * Generates the XML response message for the client application.
     * @throws FIFException if the response could not be generated.
     * @return  the DOM <code>Document</code> containing the response message.
     */
    private void generateResponse() throws FIFException {
        // Bail out if the response was already generated
        if (generated == true) {
            return;
        }
        generated = true;

        // Create the DOM tree (and include the DTD name)
        DOMImplementation domImpl = new DOMImplementationImpl();
        response =
            domImpl.createDocument(
                null,
                QueueClientXMLTags.responseRoot,
                domImpl.createDocumentType(
                    QueueClientXMLTags.responseRoot,
                    null,
                    QueueClientXMLTags.responseDTDName));

        // Add the action name
        addActionName(response);

        // Add the transaction ID to the document
        addTransactionID(response);

        // Add the transaction result to the document
        addTransactionResult(response);

        // Add the output parameters to the document
        addOutputParams(response);

        // Add the error list to the document
        addErrors(response);

        // Add the warning list to the document
        addWarnings(response);

        // Set the response message
        try {
            DOMSerializer serializer = new DOMSerializer();
            StringWriter sw = new StringWriter();
            serializer.serialize(response, sw);
            setMessage(sw.toString());
        } catch (IOException ioe) {
            throw new FIFException(
                "Cannot serialize generated response list message.",
                ioe);
        }
    }

    /**
     * Adds the warning list to the document
     * @param doc  the document to add the warning list to.
     */
    private void addWarnings(Document doc) {
        // Bail out if there are no warnings
        if ((warnings == null) || (warnings.size() == 0)) {
            return;
        }

        // Add the warning-list tag to the document 
        Element warningRoot =
            addElement(
                doc,
                doc.getDocumentElement(),
                QueueClientXMLTags.warningList,
                null);

        // Add the warnings
        for (int i = 0; i < warnings.size(); i++) {
            FIFWarning warning = (FIFWarning) warnings.get(i);

            // Add the warning object
            Element warningElement =
                addElement(doc, warningRoot, QueueClientXMLTags.warning, null);

            // Add the error number and text
            addElement(
                doc,
                warningElement,
                QueueClientXMLTags.warningNumber,
                warning.getNumber());
            addElement(
                doc,
                warningElement,
                QueueClientXMLTags.warningMessage,
                warning.getMessage());
        }
    }

    /**
     * Adds the error list to the document
     * @param doc  the document to add the error list to.
     */
    private void addErrors(Document doc) throws FIFException {
        // Bail out if the transaction did not fail
        if (status != FAILURE) {
            return;
        }

        // Add the error-list tag to the document 
        Element errorRoot =
            addElement(
                doc,
                doc.getDocumentElement(),
                QueueClientXMLTags.errorList,
                null);

        // Add the errors
        for (int i = 0;(errors != null) && (i < errors.size()); i++) {
            FIFError error = (FIFError) errors.get(i);

            // Get the error mapping
            ErrorMappingEntry mappedError = null;
            mappedError = ErrorMapping.getErrorMapping(error);

            // Add the error object
            Element errorElement =
                addElement(doc, errorRoot, QueueClientXMLTags.error, null);

            // Add the error number and text
            addElement(
                doc,
                errorElement,
                QueueClientXMLTags.errorNumber,
                mappedError.getNumber());
            addElement(
                doc,
                errorElement,
                QueueClientXMLTags.errorMessage,
                mappedError.getMessage());
        }
    }

    /**
     * Adds the output parameters to the document
     * @param doc  the document to add the output parameters to.
     */
    private void addOutputParams(Document doc) throws DOMException {
        if ((outputParams != null) && (outputParams.size() > 0)) {
            Element outputParamsElement =
                addElement(
                    doc,
                    doc.getDocumentElement(),
                    QueueClientXMLTags.outputParams,
                    null);
            Iterator iter = outputParams.iterator();
            while (iter.hasNext()) {
                OutputParameter param = (OutputParameter) iter.next();
                Element outputParamElement =
                    addElement(
                        doc,
                        outputParamsElement,
                        QueueClientXMLTags.outputParam,
                        param.getValue());
                outputParamElement.setAttribute(
                    QueueClientXMLTags.outputParamName,
                    param.getName());
            }
        }
    }

    /**
     * Adds the transaction result to the document
     * @param doc  the document to add the result to.
     */
    private void addTransactionResult(Document doc) {
        String statusString = null;
        if (status == SUCCESS) {
            statusString = QueueClientXMLTags.transactionStatusSuccess;
        } else if (status == NOT_EXECUTED) {
            statusString = QueueClientXMLTags.transactionStatusNotExecuted;
        } else if (status == VALIDATED) {
            statusString = QueueClientXMLTags.transactionStatusValidated;
        } else {
            statusString = QueueClientXMLTags.transactionStatusFailure;
        }

        addElement(
            doc,
            doc.getDocumentElement(),
            QueueClientXMLTags.transactionResult,
            statusString);
    }

    /**
     * Adds the transaction ID to the document
     * @param doc  the document to add the transaction ID to.
     */
    private void addTransactionID(Document doc) {
        if ((transactionID == null) || (transactionID.trim().length() == 0)) {
            transactionID = QueueClientXMLTags.unknownValue;
        }
        addElement(
            doc,
            doc.getDocumentElement(),
            QueueClientXMLTags.transactionId,
            transactionID);
    }

    /**
     * Adds the action name to the document
     * @param doc  the document to add the action name to.
     */
    private void addActionName(Document doc) {
        // Add the action name to the document
        if ((actionName == null) || (actionName.trim().length() == 0)) {
            actionName = QueueClientXMLTags.unknownValue;
        }
        addElement(
            doc,
            doc.getDocumentElement(),
            QueueClientXMLTags.actionName,
            actionName);
    }
    
    /**
     * Adds an element to the document.
     *
     * @param doc     the document to add the element to.
     * @param parent  the parent to add the element to.
     * @param name    the name of the element to add.
     * @param value   the text value of the element to add.
     *                 use null if no text value should be added.
     * @return the newly added Element
     */
    private static Element addElement(
        Document doc,
        Element parent,
        String name,
        String value) {
        // Create a new element
        Element element = doc.createElement(name);

        if (value != null) {
            // Create the text
            Text text = doc.createCDATASection(value);

            // Add the text
            element.appendChild(text);
        }

        // Append the element to the parent
        parent.appendChild(element);

        // Return the created element
        return element;
    }

    /**
     * Gets the XML document.
     * @see net.arcor.fif.messagecreator.Message#getDocument()
     */
    public Document getDocument() throws FIFException {
        if (!generated) {
            generateResponse();
        }

        return response;
    }

    /**
     * Gets the message XML in text format.
     * @return the message XML string.
     */
    public String getMessage() throws FIFException {
        if (!generated) {
            generateResponse();
        }
        return (super.getMessage());
    }

    /**
     * Gets the action name.
     * @return the action name.
     */
    public String getActionName() {
        return actionName;
    }

    /**
     * Gets the status.
     * @return the status.
     */
    public int getStatus() {
        return status;
    }

    /**
     * Sets the status
     * @param status  the status to be set
     */
    public void setStatus(int status) {
        this.status = status;
    }

    /**
     * Gets the transaction ID.
     * @return the transaction ID.
     */
    public String getTransactionID() {
        return transactionID;
    }

    /**
     * Gets the error list.
     * @return the <code>ArrayList</code> object containing the 
     * <code>FIFError</code> objects.
     */
    public ArrayList getErrors() {
        return errors;
    }

    /**
     * Gets the warning list.
     * @return the <code>ArrayList</code> object containing the 
     * <code>FIFWarning</code> objects.
     */
    public ArrayList getWarnings() {
        return warnings;
    }

	public ArrayList getOutputParams() {
		return outputParams;
	}

    /**
     * Gets the jmsCorrelation ID.
     * @return the jmsCorrelation ID.
     */	
    public String getJmsCorrelationId() {
        return jmsCorrelationId;
    }

    /**
     * Gets the jmsReplyTo.
     * @return the jmsReplyTo.
     */
    public String getJmsReplyTo() {
        return jmsReplyTo;
    }
}
