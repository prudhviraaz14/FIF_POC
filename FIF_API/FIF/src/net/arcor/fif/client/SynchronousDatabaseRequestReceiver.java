/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousDatabaseRequestReceiver.java-arc   1.5   Feb 14 2019 18:20:54   lejam  $
 *    $Revision:   1.5  $
 *    $Workfile:   SynchronousDatabaseRequestReceiver.java  $
 *      $Author:   lejam  $
 *        $Date:   Feb 14 2019 18:20:54  $
 *
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousDatabaseRequestReceiver.java-arc  $
 * 
 *    Rev 1.5   Feb 14 2019 18:20:54   lejam
 * IT-k-34229 Added getting paramValue as reference from FIF_REQUEST_RESULT.
 * 
 *    Rev 1.4   Nov 29 2012 15:28:40   lejam
 * Added request reprocess functionality IT-k-32482
 * 
 *    Rev 1.3   Nov 18 2011 13:53:18   schwarje
 * SPN-FIF-000116663: handle IOExceptions in database clients
 * 
 *    Rev 1.2   Jun 01 2010 18:01:56   schwarje
 * IT-26029: updates
 * 
 *    Rev 1.1   May 25 2010 16:33:34   schwarje
 * IT-26029: updates
 * 
 * 
 ***************************************************************************  
 */
package net.arcor.fif.client;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Map;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.db.DatabaseFifRequest;
import net.arcor.fif.db.DatabaseFifRequestDataAccess;
import net.arcor.fif.db.FifTransaction;
import net.arcor.fif.messagecreator.FIFRequest;
import net.arcor.fif.messagecreator.FIFRequestList;
import net.arcor.fif.messagecreator.MessageCreatorMetaData;
import net.arcor.fif.messagecreator.ParameterList;
import net.arcor.fif.messagecreator.ParameterListItem;
import net.arcor.fif.messagecreator.Request;
import net.arcor.fif.messagecreator.SimpleParameter;

public class SynchronousDatabaseRequestReceiver extends RequestReceiver {
		
	
	/********************************************************/

    DatabaseFifRequestDataAccess fifRequestDAO = null;

    /**
     * The maximum size of the error message in the database.
     */
    private int batchSize = 100;
    
    /**
     * sleep time after no request was found
     */
    private long sleepTime = 60000;
    
    /**
     * Indicates, if the OMTS order id is populated on top of the transaction list
     */
    private boolean populateOmtsOrderId = false;

    /**
     * The client default parameter name for the OMTS order id
     */
    private String defaultOmtsOrderIdParameterName = null;

    /**
     * The list name used for wrapped single requests
     */
    private String artificialListName = null;
    
    /**
     * Indicates, if a single request is wrapped in a FIF transaction list
     */
    private boolean wrapRequestInTransactionList = false;

	private long postponeDelay = 6 * 60 * 60 * 1000;
    
    /*---------*
     * METHODS *
     *---------*/

    /**
     * Initializes the message sender.
     */
    public void init() throws FIFException {
        try {
        	postponeDelay = 60000 * ClientConfig.getInt("SynchronousDatabaseClient.PostponeDelay");
		} catch (FIFException e) {}            
        try {
			batchSize = ClientConfig.getInt("SynchronousDatabaseClient.BatchSize");
		} catch (FIFException e) {}            
        try {
			wrapRequestInTransactionList = ClientConfig.getBoolean("SynchronousDatabaseClient.WrapRequestInTransactionList");
		} catch (FIFException e) {}
        try {
			artificialListName = ClientConfig.getSetting("SynchronousDatabaseClient.ArtificialListName");
		} catch (FIFException e) {}
        try {
			populateOmtsOrderId = ClientConfig.getBoolean("SynchronousDatabaseClient.PopulateOmtsOrderId");
		} catch (FIFException e) {}
        try {
			defaultOmtsOrderIdParameterName = ClientConfig.getSetting("SynchronousDatabaseClient.DefaultOmtsOrderIdParameterName");
		} catch (FIFException e) {}
        try {
    		sleepTime = ClientConfig.getInt("SynchronousDatabaseClient.RequestSleepTime") * 60000;
    	} catch (FIFException e) {}
    	
        logger.info("Successfully initialized message sender.");
    }

    /**
     * Starts to process the requests from the database.
     * @see java.lang.Runnable#run()
     */
    public void run() {
        try {
        	boolean requestsFound = false;
            while (!Thread.interrupted()
                && !SynchronousFifClient.theClient.inErrorStatus()) {
                // Retrieve the request to be processed
                if (requestsFound)
                    logger.info("Waiting for requests in database...");

                ArrayList<String> notStartedRequests = fifRequestDAO.retrievePendingFifRequests(batchSize, SynchronousDatabaseClient.requestStatusNotStarted);
                ArrayList<String> reprocessRequests = fifRequestDAO.retrievePendingFifRequests(batchSize, SynchronousDatabaseClient.requestStatusReprocess);

                ArrayList<String> pendingRequests = new ArrayList<String>();
                pendingRequests.addAll(notStartedRequests);
                pendingRequests.addAll(reprocessRequests);
                

                if (pendingRequests.size() > 0) {
                	requestsFound = true;
                	logger.debug("Successfully retrieved requests from database.");
                    logger.info("Processing requests...");

                    String currentTransactionListId = null;
                    for (String transactionId : pendingRequests) {
                    	DatabaseFifRequest dbFifRequest = fifRequestDAO.fetchFifRequestById(transactionId);
                    	// if transaction lists are not supported or the list id is empty, 
                    	// process the request as single request
                    	if (dbFifRequest.getTransactionListId() == null || 
                    		dbFifRequest.getTransactionListId().trim().equals(""))
							processSimpleRequest(dbFifRequest);

                        // otherwise this request is part of a transaction list
                    	else {
                    		if (!dbFifRequest.getTransactionListId().equals(currentTransactionListId))
                    			processTransactionList(dbFifRequest.getTransactionListId());
                    		currentTransactionListId = dbFifRequest.getTransactionListId();
                    	}
                    }

                    logger.info("Successfully processed requests.");
                }
                else 
                	requestsFound = false;

                if (!requestsFound)
                	Thread.sleep(sleepTime);
            }
        } catch (FIFException fe) {
            // Set the error status on the DatabaseClient object
            if (SynchronousFifClient.theClient.isShutDownHookInvoked() == false) {
                logger.fatal("Fatal error while processing requests", fe);
            }
            SynchronousFifClient.theClient.setErrorStatus();
        } catch (InterruptedException ie) {
            // Set the error status on the DatabaseClient object
            if (SynchronousFifClient.theClient.isShutDownHookInvoked() == false) {
                logger.fatal("DatabaseClientMessageSender interrupted", ie);
            }
            SynchronousFifClient.theClient.setErrorStatus();
        } catch (Exception e) {
            if (SynchronousFifClient.theClient.isShutDownHookInvoked() == false) {
                logger.fatal("Fatal exception while processing requests", e);
            }
            SynchronousFifClient.theClient.setErrorStatus();        	
        }
    }

    /**
     * Processes a simple database request.
     * Reads the parameters from the database, creates a message, and
     * sends this message to FIF
     * @param id      the ID of the request to be processed
     * @param action  the action to create the message for
     * @param depActionID  the request this transaction depends on
     * @throws FIFException
     */
    private void processSimpleRequest(DatabaseFifRequest dbFifRequest) throws FIFException {
        logger.info("Processing request for id: " + dbFifRequest.getTransactionId() + 
        		", action: " + dbFifRequest.getActionName() + "...");
        
        if (dbFifRequest.getDependentTransactionId() != null) {
        	DatabaseFifRequest dependentFifRequest = 
        		fifRequestDAO.fetchFifRequestById(dbFifRequest.getDependentTransactionId());
        	if (dependentFifRequest != null && 
        		!dependentFifRequest.getStatus().equals(SynchronousDatabaseClient.requestStatusCompleted)) {
        		if (dependentFifRequest.getStatus().equals(SynchronousDatabaseClient.requestStatusFailed) ||
        				dependentFifRequest.getStatus().equals(SynchronousDatabaseClient.requestStatusCanceled)) {
        			if (dbFifRequest.getStartDate() == null)
        				dbFifRequest.setStartDate(new Date());
        			dbFifRequest.setEndDate(new Date());
        			dbFifRequest.setStatus(SynchronousDatabaseClient.requestStatusCanceled);
        			logger.info("Request " + dbFifRequest.getTransactionId() + 
        					" is cancelled because the parent request " + dependentFifRequest.getTransactionId() + 
        					" was not completed.");
        		}
        		else {
        			if (dbFifRequest.getStartDate() == null)
        				dbFifRequest.setStartDate(new Date());
        			dbFifRequest.setDueDate(new Date(dbFifRequest.getDueDate().getTime() + postponeDelay));
        			logger.info("Request " + dbFifRequest.getTransactionId() + 
        					" is postponed by " + postponeDelay/60000 + 
        					" minutes because the parent request " + dependentFifRequest.getTransactionId() + 
        					" is still open.");
        		}
    			fifRequestDAO.updateFifRequest(dbFifRequest);
    			return;
        	}
        }
        
        // Define a null error string and null message
        String error = null;
        FIFRequest request = null;
        
		if (!(MessageCreatorMetaData.hasActionMapping(dbFifRequest.getActionName()))) {
			// Populate the error string with an error message.
			error = "Cannot create message for request. Reason: no action mapping found "
					+ "for action name '" + dbFifRequest.getActionName() + "'.";
			
			dbFifRequest.setErrorText(error);
        	dbFifRequest.setStatus(SynchronousDatabaseClient.requestStatusFailed);
        	dbFifRequest.setStartDate(new Date());
        	dbFifRequest.setEndDate(new Date());
            fifRequestDAO.updateFifRequest(dbFifRequest);
		} 
		else {
			try {
				request = createSimpleRequest(dbFifRequest);
			} catch (FIFException e) {
				dbFifRequest.setStartDate(new Date());
	        	dbFifRequest.setEndDate(new Date());
	            dbFifRequest.setStatus(SynchronousDatabaseClient.requestStatusFailed);
	        	String errorText = ("Couldn't create FifRequest from request in the database. " +
	        			"Reason: " + e.getMessage());
	        	if (errorText.length() > 4000)
	        		errorText = errorText.substring(0, 4000);
	            dbFifRequest.setErrorText(errorText);
	            fifRequestDAO.updateFifRequest(dbFifRequest);	
	            logger.error("Request: " + dbFifRequest.getTransactionId() + ", " + errorText);
	            return;
			}
			FIFRequestList requestList = null;
			// TODO check what this weird thing does
			if (wrapRequestInTransactionList) {
				requestList = new FIFRequestList();
				requestList.addRequest(request);
				String omtsOrderId = retrieveOmtsOrderId(request);
				if (omtsOrderId != null && !omtsOrderId.equals(""))
					requestList.setOMTSOrderID(omtsOrderId);
				requestList.setID(dbFifRequest.getTransactionId());
				requestList.setName(artificialListName);
				if (dbFifRequest.getStatus().equals(SynchronousDatabaseClient.requestStatusReprocess))
					requestList.addParam(new SimpleParameter("reprocessInd", "Y"));
			}

			boolean locked = true;
            try {
				fifRequestDAO.lockFifRequest(dbFifRequest);
			} catch (FIFException e) {
				if (logger.isDebugEnabled())
					logger.debug("Exception while locking request " + dbFifRequest.getTransactionId(), e);
				locked = false;
			}
			
			if (locked) {
	    		// process the request the "normal" way
				try {
		            processFifRequest((requestList == null) ? request : requestList);
		            
		            boolean resentResponse = false;
					if(requestList == null) {
						if(((SimpleParameter)(request.getParam("resentResponse")) != null))
							resentResponse = true;
					}
					else {
						if(((SimpleParameter)(requestList.getParam("resentResponse")) != null))
							resentResponse = true;
					}

					// if not just existing response resent
					if(!resentResponse) {
			            // No error, set the in progress state
						dbFifRequest.setStartDate(new Date());
			            dbFifRequest.setStatus(SynchronousDatabaseClient.requestStatusInProgress);
			            fifRequestDAO.updateFifRequest(dbFifRequest);
		        	} 

		        	// Log the success
		            logger.info("Successfully processed request for id: " + dbFifRequest.getTransactionId() + 
		            		", action: " + dbFifRequest.getActionName());
		            
				} catch (FIFException e) {
					// SPN-FIF-000116663 fail requests with illegal characters in the parameters
					if (e.getDetail() instanceof IOException) {
			        	dbFifRequest.setStartDate(new Date());
			        	dbFifRequest.setEndDate(new Date());
			            dbFifRequest.setStatus(SynchronousDatabaseClient.requestStatusFailed);
			        	String errorText = ("Couldn't create FifRequest from request in the database. " +
			        			"Reason: " + ((IOException)e.getDetail()).getMessage());
			        	if (errorText.length() > 4000)
			        		errorText = errorText.substring(0, 4000);
			            dbFifRequest.setErrorText(errorText);
			            fifRequestDAO.updateFifRequest(dbFifRequest);	
			            logger.error("Request: " + dbFifRequest.getTransactionId() + ", " + errorText);
					}
					else throw e;
				}
			}
			else
                logger.info("Cannot lock request id: " + dbFifRequest.getTransactionId() + 
                		", action: " + dbFifRequest.getActionName() + ". Skipping...");
		}
    }

	/**
	 * creates a request, adds parameters and parameter lists from the 
	 * database and creates a FIF message for the action
	 * @param id			Transaction ID of the request
	 * @param action		action to perform
	 * @param depActionID	request, on which this request depends 
	 * @return				FIF message
	 * @throws FIFException
	 */
	private FIFRequest createSimpleRequest(DatabaseFifRequest dbFifRequest) throws FIFException {
		FIFRequest request = new FIFRequest();
		// Create a request object
		request.setAction(dbFifRequest.getActionName());
		
		// Set the standard parameters
		request.addParam(new SimpleParameter("transactionID", dbFifRequest.getTransactionId()));
		if (dbFifRequest.getTransactionListId() != null)
			request.addParam(new SimpleParameter("requestListId", dbFifRequest.getTransactionListId()));
		if (dbFifRequest.getStatus().equals(SynchronousDatabaseClient.requestStatusReprocess))
			request.addParam(new SimpleParameter("reprocessInd", "Y"));

		for (String parameterName : dbFifRequest.getParameters().keySet()) {
			String parameterValue = dbFifRequest.getParameters().get(parameterName); 
			request.addParam(new SimpleParameter(
					parameterName, getParameterValueForName(dbFifRequest, parameterName, parameterValue)));
		}

		if (dbFifRequest.getParameterLists() != null)
			for (String parameterListName : dbFifRequest.getParameterLists().keySet()) {
				ParameterList list = new ParameterList(parameterListName);			
				for (Map<String, String> listItem : dbFifRequest.getParameterLists().get(parameterListName)) {
					ParameterListItem parameterListItem = new ParameterListItem();
					for (String parameterName : listItem.keySet()) {
						String parameterValue = listItem.get(parameterName); 
						parameterListItem.addParam(new SimpleParameter(
								parameterName, getParameterValueForName(dbFifRequest, parameterName, parameterValue)));
					}
					list.addItem(parameterListItem);
				}
				request.addParam(list);
			}	

		return request;
	}

	/**
	 * Gets the parameter value for the parameter name straight or as a reference of the dependent transaction
	 * @param dbFifRequest
	 * @param parameterName
	 * @throws FIFException
	 */
	private String getParameterValueForName(DatabaseFifRequest dbFifRequest, String parameterName, String parameterValue) throws FIFException
	{
		String returnValue = null;
		if (parameterValue.contains(":")
			&& dbFifRequest.getDependentTransactionId() != null 
			&& dbFifRequest.getDependentTransactionId().equals(parameterValue.substring(0,parameterValue.indexOf(":")))) {
			String returnParam = parameterValue.substring(parameterValue.indexOf(":")+1);
			returnValue = fifRequestDAO.fetchFifRequestResult(dbFifRequest.getDependentTransactionId(), returnParam);
			if(returnValue == null)
	            throw new FIFException(
	                    "Referenced value: " + parameterValue + ", for parameter: " + parameterName + ", not found.");
		}
		else
			returnValue = parameterValue;
		return returnValue;
	}
	
	/**
	 * processes a transaction list:
	 * - retrieves all requests
	 * - processs requests one by one
	 * - bundles and sends a FIFReplyListMessage
	 * @param transactionListId		ID of the transaction list
	 * @throws FIFException
	 */
	private void processTransactionList(String transactionListId) throws FIFException
	{
		// retrieve requests
		boolean errorInList = false;
		logger.debug("Retrieving all requests for transaction list " + transactionListId);
		ArrayList<DatabaseFifRequest> requests = fifRequestDAO.fetchFifRequestListById(transactionListId);

		// loop through the requests to see if they were already processed 
		for (DatabaseFifRequest databaseFifRequest : requests) {
			if (!databaseFifRequest.getStatus().equals(SynchronousDatabaseClient.requestStatusNotStarted)) {
				logger.debug("Request for transaction list " + transactionListId 
						+ "is already processed. Skipping this request.");
				return;
			}
		}
		
		String transactionListOmtsOrderId = null;

    	FIFRequestList requestList = new FIFRequestList();

    	for (DatabaseFifRequest databaseFifRequest : requests) {
			logger.info("Processing request for id: " + databaseFifRequest.getTransactionId() + 
					", action: " + databaseFifRequest.getActionName() + "...");

			// Define a null error string and null message
			String error = null;

			// Check if an action mapping exists for the passed in action
			if (!(MessageCreatorMetaData.hasActionMapping(databaseFifRequest.getActionName()))) {
				// Populate the error string with an error message.
				error = "Cannot create message for request. Reason: no action mapping found "
						+ "for action name '" + databaseFifRequest.getActionName() + "'.";
			} 
			else {
				FIFRequest fifRequest = createSimpleRequest(databaseFifRequest);
	        	requestList.addRequest(fifRequest);

                // get the order id for the OMTS notification from the request
                if (transactionListOmtsOrderId == null && populateOmtsOrderId)
                	transactionListOmtsOrderId = retrieveOmtsOrderId(fifRequest);
			}
			
			// write the IN_PROGRESS record
			databaseFifRequest.setStatus(SynchronousDatabaseClient.requestStatusInProgress);
			databaseFifRequest.setStartDate(new Date());
			fifRequestDAO.updateFifRequest(databaseFifRequest);

			// Update the state in the DB
			if (error == null) {
				// Log the success
				logger.info("Successfully processed request for id: " + databaseFifRequest.getTransactionId() + 
						", action: " + databaseFifRequest.getActionName());
			} else {
				// There was an error, set the failure state
				databaseFifRequest.setStatus(SynchronousDatabaseClient.requestStatusFailed);
				databaseFifRequest.setEndDate(new Date());
				fifRequestDAO.updateFifRequest(databaseFifRequest);
				errorInList = true;
				// Log the error
				logger.error(error);
			}                
		}
		
		// send and write full sent message
		if (!errorInList) {
			if (transactionListOmtsOrderId != null)
				requestList.setOMTSOrderID(transactionListOmtsOrderId);
        	requestList.setID(transactionListId);
        	requestList.setName("db-client-list");
			
	        processFifRequest(requestList);
	        for (DatabaseFifRequest databaseFifRequest : requests) {
	        	databaseFifRequest.setTransactionListStatus(SynchronousDatabaseClient.requestStatusInProgress);
	        	fifRequestDAO.updateFifRequest(databaseFifRequest);
	        }
		}
		else {
	        for (DatabaseFifRequest databaseFifRequest : requests) {
	        	databaseFifRequest.setTransactionListStatus(SynchronousDatabaseClient.requestStatusFailed);
	        	databaseFifRequest.setEndDate(new Date());
	        	fifRequestDAO.updateFifRequest(databaseFifRequest);
	        }
		}
	}

    /**
     * checks, if there is a parameter for the OTMSOrderId in the request and returns its value
     * @param request
     * @return the OMTS order id for the request
     */
    private String retrieveOmtsOrderId(Request request) {
    	if (!populateOmtsOrderId)
    		return null;
    	
    	// set the client default for the parameter name
    	String omtsOrderIdParameterName = defaultOmtsOrderIdParameterName;
    	
    	// check, if there is a specific paramter name for the current action
    	try {
    		omtsOrderIdParameterName = ClientConfig.getSetting("databaseclient.OmtsOrderIdParameterName." + request.getAction());    		
		} catch (FIFException e) {}

		// return the value of the parameter
		SimpleParameter sp = (SimpleParameter)request.getParam(omtsOrderIdParameterName);
		return (sp == null) ? null : sp.getValue();
    }
    
    /**
     * Shuts down the object.
     */
    protected void shutdown() {
        logger.info("Shutting down message sender...");
    }
	
	/**********************************************************/
	public SynchronousDatabaseRequestReceiver(ResponseSender responseSender, DatabaseFifRequestDataAccess fifRequestDAO) throws FIFException {
		super (responseSender);
		this.fifRequestDAO = fifRequestDAO;
	}

	protected void resendResponse(FifTransaction existingFifTransaction) throws FIFException {
		String clientResponse = existingFifTransaction.getClientResponse();
		if (clientResponse != null) {
			responseSender.sendResponse(existingFifTransaction);
			if (existingFifTransaction.getStatus().equals(SynchronousFifClient.FIF_TRANSACTION_STATUS_COMPLETED_FIF)) {
				existingFifTransaction.setStatus(SynchronousFifClient.FIF_TRANSACTION_STATUS_RESPONSE_SENT);
				fifTransactionDAO.updateFifTransaction(existingFifTransaction);
			}			
		}
	}
}
