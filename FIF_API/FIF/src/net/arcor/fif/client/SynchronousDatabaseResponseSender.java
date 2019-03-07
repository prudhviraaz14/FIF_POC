/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousDatabaseResponseSender.java-arc   1.3   Aug 11 2010 16:09:44   schwarje  $
 *    $Revision:   1.3  $
 *    $Workfile:   SynchronousDatabaseResponseSender.java  $
 *      $Author:   schwarje  $
 *        $Date:   Aug 11 2010 16:09:44  $
 *
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousDatabaseResponseSender.java-arc  $
 * 
 *    Rev 1.3   Aug 11 2010 16:09:44   schwarje
 * SPN-FIF-000102917: fixed handling of responses of DB clients
 * 
 *    Rev 1.2   Jun 01 2010 18:01:58   schwarje
 * IT-26029: updates
 * 
 *    Rev 1.1   May 25 2010 16:33:34   schwarje
 * IT-26029: updates
 * 
 * 
 ***************************************************************************  
 */
package net.arcor.fif.client;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.db.DatabaseFifRequest;
import net.arcor.fif.db.DatabaseFifRequestDataAccess;
import net.arcor.fif.db.FifTransaction;
import net.arcor.fif.messagecreator.FIFError;
import net.arcor.fif.messagecreator.FIFReplyListMessage;
import net.arcor.fif.messagecreator.FIFReplyMessage;
import net.arcor.fif.messagecreator.FIFTransactionResult;
import net.arcor.fif.messagecreator.FIFWarning;
import net.arcor.fif.messagecreator.Message;
import net.arcor.fif.messagecreator.OutputParameter;
import net.arcor.fif.messagecreator.ResponseSerializer;

public class SynchronousDatabaseResponseSender extends ResponseSender {

    DatabaseFifRequestDataAccess fifRequestDAO = null;

    /**
     * The list name used for wrapped single requests
     */
    private String artificialListName = null;


	public SynchronousDatabaseResponseSender() throws FIFException {
		super();
		init();
	}
	

	public SynchronousDatabaseResponseSender(DatabaseFifRequestDataAccess fifRequestDAO) throws FIFException {
		super();
		this.fifRequestDAO = fifRequestDAO;
	}

    /**
     * Initializes the message sender.
     */
    protected synchronized void init() throws FIFException {
    	fifRequestDAO = new DatabaseFifRequestDataAccess(
    			ClientConfig.getSetting("SynchronousDatabaseClient.DatabaseAlias"));
    }

    /**
     * Processes a FIF reply Message.
     * Reads the response status of the message and updates the database
     * accordingly.
     * @param response   the FIF reply message to process.
     * @throws FIFException if the message could not be processed.
     */
    private DatabaseFifRequest processSimpleResponse(QueueClientResponseMessage response) throws FIFException {
    	int transactionResult = response.getStatus();
    	DatabaseFifRequest databaseFifRequest = fifRequestDAO.fetchFifRequestById(
    				response.getTransactionID());
    	if (databaseFifRequest == null)
    		throw new FIFException("Couldn't find request " + response.getTransactionID() +
    				" in the database");
    	if (transactionResult == FIFTransactionResult.SUCCESS) {
    		databaseFifRequest.setStatus(SynchronousDatabaseClient.requestStatusCompleted);
    		databaseFifRequest.setErrorText(getResultString(response));
        	Map<String, String> results = new HashMap<String, String>();
        	if (response.getOutputParams() != null)
        		for (Object result : response.getOutputParams())        		
        			results.put(((OutputParameter)result).getName(), ((OutputParameter)result).getValue());
    		databaseFifRequest.setResults(results);        		
    	}
    	
        else if (transactionResult == FIFTransactionResult.CANCELED)
        	databaseFifRequest.setStatus(SynchronousDatabaseClient.requestStatusCanceled);
        else if (transactionResult == FIFTransactionResult.NOT_EXECUTED)
        	databaseFifRequest.setStatus(SynchronousDatabaseClient.requestStatusNotExecuted);
        else {
        	databaseFifRequest.setStatus(SynchronousDatabaseClient.requestStatusFailed);
        	databaseFifRequest.setErrorText(getResultString(response));
        }

    	databaseFifRequest.setEndDate(new Date());
    	return databaseFifRequest;
    	
    }


    private String getResultString(QueueClientResponseMessage response) {
    	String resultString = "";
		for (Object error : response.getErrors())
			resultString += "Error: " + ((FIFError) error).getNumber() + 
				": " + ((FIFError) error).getMessage() + ";"; 
    	
		for (Object warning : response.getWarnings())
			resultString += "Warning: " + ((FIFWarning) warning).getNumber() + 
				": " + ((FIFWarning) warning).getMessage() + ";"; 
		return resultString;
	}


    /**
     * Processes a FIF Reply List Message.
     * Reads the response status of the message and sends a response
     * message to the requesting application.
     * @param response   the <code>FIFReplyListMessage</code> to process.
     * @throws FIFException if the message could not be processed.
     */
    private void processResponseList(QueueClientResponseListMessage response) throws FIFException {
        // Get the list ID - this will also parse the reply
        String listID = response.getID();
        boolean isArtificialList = response.getName().equals(artificialListName);

        logger.debug("Processing FIF reply for transaction list ID: " + listID + ".");

        // loop through the reply list
        for (Object singleResponse : response.getResponses()) {
        	DatabaseFifRequest databaseFifRequest = processSimpleResponse(
        			(QueueClientResponseMessage) singleResponse);        	
        	if (response.getStatus() == QueueClientResponseListMessage.SUCCESS && !isArtificialList)
        		databaseFifRequest.setTransactionListStatus(SynchronousDatabaseClient.requestStatusCompleted);
        	else if (response.getStatus() != QueueClientResponseListMessage.SUCCESS && !isArtificialList)
        		databaseFifRequest.setTransactionListStatus(SynchronousDatabaseClient.requestStatusFailed);
        	fifRequestDAO.updateFifRequest(databaseFifRequest);
        }

        // update the list status
        if (response.getStatus() == QueueClientResponseListMessage.SUCCESS) {
            logger.info("Request list with for list ID " + listID + " succeeded.");
        } else {
            logger.info("Request list with list ID " + listID + " failed.");            
        }

        logger.debug("Successfully processed reply for transaction list id: " + listID + ".");
    }

    
    /**
	 * Shuts down the object.
	 */
    protected synchronized void shutdown() {
        logger.info("Shutting down message receiver...");
    }

	public synchronized void sendResponse(FifTransaction fifTransaction) throws FIFException {
		if (fifTransaction.getClientResponse() == null)
			throw new FIFException("Response for transaction " + fifTransaction.getTransactionId() + 
					" is empty. Cannot resend response.");
			
		// parse it into a response object
		Message response =
    		ResponseSerializer.parseResponseString(fifTransaction.getClientResponse());
				
		// method to update response message to db tables 
		sendResponse(response);
	}

	@Override
	public synchronized void sendResponse(Message message) throws FIFException {
        // Check the reply type
        if (message instanceof QueueClientResponseMessage) {
    		logger.info("Processing response for request " + ((QueueClientResponseMessage)message).getTransactionID());        	
            fifRequestDAO.updateFifRequest(processSimpleResponse((QueueClientResponseMessage) message));
        }
        else if (message instanceof QueueClientResponseListMessage) { 
            logger.info("Processing response for request " + ((QueueClientResponseListMessage)message).getID());
            processResponseList((QueueClientResponseListMessage) message);
        }
        else
            throw new FIFException("Reply message is of unknown type: " + message.getClass().getName());        
	}

}
