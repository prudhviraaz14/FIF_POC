/*
 * $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/QueueClientResponseListMessage.java-arc   1.2   Oct 07 2010 17:35:08   lejam  $
 *
 * $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/QueueClientResponseListMessage.java-arc  $
 * 
 *    Rev 1.2   Oct 07 2010 17:35:08   lejam
 * Corrected creation of KBA response messages SPN-FIF-105031
 * 
 *    Rev 1.1   May 25 2010 16:33:28   schwarje
 * IT-26029: updates
 * 
 *    Rev 1.0   Jun 14 2004 15:41:22   goethalo
 * Initial revision.
 */
package net.arcor.fif.client;

import java.io.IOException;
import java.io.StringWriter;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import net.arcor.fif.common.DOMSerializer;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.messagecreator.FIFError;
import net.arcor.fif.messagecreator.FIFReplyListMessage;
import net.arcor.fif.messagecreator.FIFReplyMessage;
import net.arcor.fif.messagecreator.FIFTransactionListResult;
import net.arcor.fif.messagecreator.Message;

import org.apache.xerces.dom.DOMImplementationImpl;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.Text;

/**
 * This class represents a response list message for the Queue Client.
 * @author goethalo
 */
public class QueueClientResponseListMessage extends Message {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /** The request list was successfully executed by FIF */
    public static int SUCCESS = 1;

    /** The request list failed in FIF */
    public static int FAILURE = 2;

    /**
     * The status of the FIF transaction the response message is related to.
     */
    private int status = FAILURE;

    /**
     * The name of the request list the response is for.
     */
    private String listName = null;

    /**
     * The ID of the request list the response is for.
     */
    private String listID = null;

    /**
     * The list of errors related to the request list.
     */
    private List errors = new LinkedList();

    /**
     * The list of responses in the list.
     */
    private List responses = new LinkedList();

    /**
     * The response list XML document.
     */
    private Document responseList = null;

    /**
     * Indicates whether the message text has already been generated.
     */
    private boolean generated = false;

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Constructor.
     * @param status    the status to construct the message for (SUCCESS/FAILURE).
     * @param listName  the request list name the response message is related to.
     * @param listID    the request list ID the response message is related to.
     * @param errors    the list of <code>FIFError</code> objects that have to be 
     *                  included in the response.  These errors are related to the
     *                  request list object.
     */
    public QueueClientResponseListMessage(
        int status,
        String listName,
        String listID,
        List errors) {
        this.listName = listName;
        this.status = status;
        this.listID = listID;
        this.errors = errors;
    }

    /**
     * Constructor.
     * @param msg  the reply list returned by FIF.
     */
    public QueueClientResponseListMessage(FIFReplyListMessage msg)
        throws FIFException {
        FIFTransactionListResult result = msg.getResult();

        // Set the result
        if (result.getResult() == FIFTransactionListResult.SUCCESS) {
            status = SUCCESS;
        } else {
            status = FAILURE;
        }

        // Set the list name and list transaction ID
        listName = result.getListName();
        listID = result.getTransactionListID();

        // Copy over the replies
        for (int i = 0; i < result.getReplies().size(); i++) {
            FIFReplyMessage reply =
                (FIFReplyMessage) result.getReplies().get(i);

            addResponse(new QueueClientResponseMessage(reply));
        }
    }

    /**
     * Adds a response to the response list.
     * @param response  the response add to the response list.
     */
    public void addResponse(QueueClientResponseMessage response)
        throws FIFException {
        logger.debug(
            "Adding response message to response list: "
                + response
                + ", text: "
                + response.getMessage());
        responses.add(response);
    }

    /**
     * Gets the message string.
     * @return the message string.
     */
    public String getMessage() throws FIFException {
        if (!generated) {
            generateResponse();
        }

        return (super.getMessage());
    }

    /**
     * Gets the XML document.
     * @see net.arcor.fif.messagecreator.Message#getDocument()
     */
    public Document getDocument() throws FIFException {
        if (!generated) {
            generateResponse();
        }
        return responseList;
    }

    /**
     * Gets the name of the response list.
     * @return the name of the response list.
     */
    public String getName() {
        return listName;
    }

    /**
     * Gets the ID of the response list.
     * @return the ID of the response list.
     */
    public String getID() {
        return listID;
    }

    /**
     * Gets the status.
     * @return the status.
     */
    public int getStatus() {
        return status;
    }

    /**
     * Gets the errors.
     * @return the errors.
     */
    public List getErrors() {
        return errors;
    }

    /**
     * Generates the XML response list message for the client application.
     * @throws FIFException if the response could not be generated.
     * @return  the DOM <code>Document</code> containing the response 
     * list message.
     */
    private void generateResponse() throws FIFException {
        // Bail out if the response was already generated
        if (generated == true) {
            return;
        }
        generated = true;

        // Create the DOM tree (and include the DTD name)
        DOMImplementation domImpl = new DOMImplementationImpl();
        Document doc =
            domImpl.createDocument(
                null,
                QueueClientXMLTags.responseListRoot,
                domImpl.createDocumentType(
                    QueueClientXMLTags.responseListRoot,
                    null,
                    QueueClientXMLTags.responseListDTDName));

        // Add the list ID to the document
        addListID(doc);

        // Add the list name
        addListName(doc);

        // Add the list result to the document
        addListResult(doc);

        // Add the error list to the document
        addListErrors(doc);

        // Add the responses
        addResponses(doc);

        // Set the response list
        this.responseList = doc;

        // Create a DOM serializer
        DOMSerializer serializer = new DOMSerializer();

        // Serialize the XML to a string
        StringWriter sw = new StringWriter();
        try {
            serializer.serialize(responseList, sw);
            setMessage(sw.toString());
        } catch (IOException ioe) {
            throw new FIFException(
                "Cannot serialize response list XML document",
                ioe);
        }
    }

    /**
     * Adds the list ID to the document
     * @param doc  the document to add the list ID to.
     */
    private void addListID(Document doc) {
        // Add the action name to the document
        if ((listID == null) || (listID.trim().length() == 0)) {
            listID = QueueClientXMLTags.unknownValue;
        }
        addElement(
            doc,
            doc.getDocumentElement(),
            QueueClientXMLTags.requestListID,
            listID);
    }

    /**
     * Adds the list name to the document
     * @param doc  the document to add the list name to.
     */
    private void addListName(Document doc) {
        // Add the action name to the document
        if ((listName == null) || (listName.trim().length() == 0)) {
            listName = QueueClientXMLTags.unknownValue;
        }
        addElement(
            doc,
            doc.getDocumentElement(),
            QueueClientXMLTags.requestListName,
            listName);
    }

    /**
     * Adds the list result to the document
     * @param doc  the document to add the list name to.
     */
    private void addListResult(Document doc) {
        addElement(
            doc,
            doc.getDocumentElement(),
            QueueClientXMLTags.requestListResult,
            (status == SUCCESS)
                ? QueueClientXMLTags.transactionStatusSuccess
                : QueueClientXMLTags.transactionStatusFailure);
    }

    /**
     * Adds the list errors to the document
     * @param doc  the document to add the list name to.
     */
    private void addListErrors(Document doc) throws FIFException {
        // Bail out if the transaction did not fail or if we do not have errors.
        if ((status != FAILURE) || (errors == null) || (errors.size() == 0)) {
            return;
        }

        // Add the error-list tag to the document 
        Element errorRoot =
            addElement(
                doc,
                doc.getDocumentElement(),
                QueueClientXMLTags.requestListErrors,
                null);

        // Add the errors
        Iterator iter = errors.iterator();
        while (iter.hasNext()) {
            FIFError error = (FIFError) iter.next();

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
     * Adds the responses to the document
     * @param doc  the document to add the list name to.
     */
    private void addResponses(Document doc) throws FIFException {
        // Bail out if there are no responses
        if (responses.size() == 0) {
            return;
        }

        // Add the responses tag to the document 
        Element responsesRoot =
            addElement(
                doc,
                doc.getDocumentElement(),
                QueueClientXMLTags.responses,
                null);

        // Add the responses to the responses root
        Iterator iter = responses.iterator();
        while (iter.hasNext()) {
            QueueClientResponseMessage response =
                (QueueClientResponseMessage) iter.next();
            // Get the root of the response document
            Document responseDoc = response.getDocument();
            Node responseRoot = responseDoc.getDocumentElement();

            // Import the response root in the response list document 
            Node importedResponse = doc.importNode(responseRoot, true);
            responsesRoot.appendChild(importedResponse);
        }
    }

    /**
     * Adds an element to the document.
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

	public List getResponses() {
		return responses;
	}

    
}
