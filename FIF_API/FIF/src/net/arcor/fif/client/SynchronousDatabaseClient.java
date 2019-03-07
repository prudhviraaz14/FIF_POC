/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousDatabaseClient.java-arc   1.4   Nov 29 2012 15:26:48   lejam  $
 *    $Revision:   1.4  $
 *    $Workfile:   SynchronousDatabaseClient.java  $
 *      $Author:   lejam  $
 *        $Date:   Nov 29 2012 15:26:48  $
 *
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousDatabaseClient.java-arc  $
 * 
 *    Rev 1.4   Nov 29 2012 15:26:48   lejam
 * Added requestStatusReprocess IT-k-32482
 * 
 *    Rev 1.3   Jun 08 2010 17:35:30   schwarje
 * IT-26029: updates
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

import net.arcor.fif.common.FIFException;
import net.arcor.fif.db.DatabaseFifRequestDataAccess;

/**
 * This class implements a CODB queue client.
 * It reads requests from a queue, creates FIF messages based on the requests,
 * and sends the created messages to FIF.
 * <p>
 * This application needs 2 queues:<br>
 * <li>A queue for reading requests</li>
 * <li>A queue for sending the transformed reply to the requesting application</li> 
 * <p>
 * <b>Property file</b><br>
 * The name of the property file used by the application is defaulted to
 * SynchronousQueueClient.<br>
 * The <code>fif.propertyfile</code> system property can be set to another property
 * file if needed.<br>
 * To do this the following syntax can be used for starting the application:<br>
 * <code>java -Dfif.propertyfile=AnotherFile net.arcor.fif.client.
 * CODBClient</code>
 * @author makuier
 */
public class SynchronousDatabaseClient extends SynchronousFifClient {

	
    /**
     * Indicates whether the client supports transaction lists.
     */
    public static boolean transactionListSupported = false;

	/**
	 * The literal for the status NotStarted in the database.
	 */
    public static String requestStatusNotStarted = null;

	/**
	 * The literal for the status InProgress in the database.
	 */
	public static String requestStatusInProgress = null;

	/**
	 * The literal for the status Reprocess in the database.
	 */
	public static String requestStatusReprocess = null;

	/**
	 * The literal for the status Failed in the database.
	 */
	public static String requestStatusFailed = null;

	/**
	 * The literal for the status Completed in the database.
	 */
	public static String requestStatusCompleted = null;

	/**
	 * The literal for the status NotExecuted in the database.
	 */
	public static String requestStatusNotExecuted = null;

	/**
	 * The literal for the status Canceled in the database.
	 */
	public static String requestStatusCanceled = null;
	
	/**
	 * The literal for the status Canceled in the database.
	 */
	public static String requestStatusDataType = null;
	
	/**
	 * The literal for the status Canceled in the database.
	 */
	public static final String requestStatusDataTypeVarchar = "VARCHAR";
	
	/**
	 * The literal for the status Canceled in the database.
	 */
	public static final String requestStatusDataTypeNumber = "NUMBER";
	

	public void init(String configFile) throws FIFException {
		
		super.init(configFile);
		
		try {
			DatabaseFifRequestDataAccess.setEnableDependentTransactions(
					ClientConfig.getBoolean("SynchronousDatabaseClient.EnableDependentTransactions"));
		} catch (FIFException e) {}
		try {
			DatabaseFifRequestDataAccess.setEnableTransactionLists(
					ClientConfig.getBoolean("SynchronousDatabaseClient.EnableTransactionLists"));
		} catch (FIFException e) {}
		try {
			DatabaseFifRequestDataAccess.setEnableParameterLists(
					ClientConfig.getBoolean("SynchronousDatabaseClient.EnableParameterLists"));
		} catch (FIFException e) {}
		try {
			DatabaseFifRequestDataAccess.setEnableTransactionResults(
					ClientConfig.getBoolean("SynchronousDatabaseClient.EnableTransactionResults"));
		} catch (FIFException e) {}
		try {
			DatabaseFifRequestDataAccess.setMaxErrorLength(
					ClientConfig.getInt("SynchronousDatabaseClient.MaxErrorLength"));
		} catch (FIFException e) {}

		if (enableFailedResponseHandling) {
			DatabaseFifRequestDataAccess fifRequestDAO = new DatabaseFifRequestDataAccess(
	    			ClientConfig.getSetting("SynchronousDatabaseClient.DatabaseAlias"));
			FailedResponseHandler failedResponseHandler = 
				new FailedResponseHandler(
						new SynchronousDatabaseResponseSender(fifRequestDAO));
			addThread(failedResponseHandler, "FailedResponseHandler");
		}		
		
        // Check if we transaction lists are supported
        try {
        	transactionListSupported =
                ClientConfig.getBoolean("SynchronousDatabaseClient.TransactionListSupported");
        } catch (FIFException fe) {}

    	requestStatusCompleted = 
    		ClientConfig.getSetting("SynchronousDatabaseClient.RequestStatusCompleted");
    	requestStatusFailed = 
    		ClientConfig.getSetting("SynchronousDatabaseClient.RequestStatusFailed");
    	requestStatusNotStarted = 
		    ClientConfig.getSetting("SynchronousDatabaseClient.RequestStatusNotStarted");
    	requestStatusInProgress = 
		    ClientConfig.getSetting("SynchronousDatabaseClient.RequestStatusInProgress");
    	requestStatusReprocess = 
		    ClientConfig.getSetting("SynchronousDatabaseClient.RequestStatusReprocess");
    	requestStatusNotExecuted = 
		    ClientConfig.getSetting("SynchronousDatabaseClient.RequestStatusNotExecuted");
    	requestStatusCanceled = 
		    ClientConfig.getSetting("SynchronousDatabaseClient.RequestStatusCanceled");
    	
    	requestStatusDataType = 
		    ClientConfig.getSetting("SynchronousDatabaseClient.RequestStatusDataType");
    	
    	startThreads();
    	
	}
	
	
    /*---------*
     * METHODS *
     *---------*/

	/**
	 * @throws FIFException
	 */
	protected void startRequestReceivers() throws FIFException {
		for (int receiverNumber = 1; receiverNumber <= numberOfRequestReceivers; receiverNumber++) {
		    SynchronousDatabaseRequestReceiver requestReceiver = null;
	    	DatabaseFifRequestDataAccess fifRequestDAO = new DatabaseFifRequestDataAccess(
	    			ClientConfig.getSetting("SynchronousDatabaseClient.DatabaseAlias"));
	    	SynchronousDatabaseResponseSender responseSender = new SynchronousDatabaseResponseSender(fifRequestDAO);
			// Start it as a thread
		    requestReceiver = new SynchronousDatabaseRequestReceiver(responseSender, fifRequestDAO);
		    requestReceiver.init();
		    addThread(requestReceiver, "RequestReceiver-" + receiverNumber);
		}
	}

	/**
	 * @throws FIFException
	 */
    protected void startRecycleRequestHandlers() throws FIFException {
		for (int recycleHandlerNumber = 1; recycleHandlerNumber <= numberOfRecycleHandlers; recycleHandlerNumber++) {
		    RequestHandler recycleRequestHandler = null;
			// Start it as a thread
		    recycleRequestHandler = new RequestHandler(ccmInstanceBase + new Integer(numberOfRequestHandlers + recycleHandlerNumber));
		    recycleRequestHandler.setRecyclingInstance(true);
		    recycleRequestHandler.setResponseSender(new SynchronousDatabaseResponseSender());
		    addThread(recycleRequestHandler, "RecycleRequestHandler-" + recycleHandlerNumber);
		}
	}

	/**
	 * @throws FIFException
	 */
    // TODO so nicht ... neue Klassen erweitern
	protected void startRequestHandlers() throws FIFException {
		for (int requestHandlerNumber = 1; requestHandlerNumber <= numberOfRequestHandlers; requestHandlerNumber++) {
		    RequestHandler requestHandler = null;
			// Start it as a thread
		    requestHandler = new RequestHandler(ccmInstanceBase + requestHandlerNumber);
		    requestHandler.setResponseSender(new SynchronousDatabaseResponseSender());
		    addThread(requestHandler, "RequestHandler-" + requestHandlerNumber);
		}
	}

	public static void main (String[] args) {
		theClient = new SynchronousDatabaseClient();
		theClient.doMain(args);
	}


	@Override
	protected void processArguments(String[] args) {}

}
