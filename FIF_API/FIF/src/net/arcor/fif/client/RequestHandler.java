/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/RequestHandler.java-arc   1.48   Jan 25 2019 14:44:32   lejam  $
 *    $Revision:   1.48  $
 *    $Workfile:   RequestHandler.java  $
 *      $Author:   lejam  $
 *        $Date:   Jan 25 2019 14:44:32  $
 *
 *  Function: abstract superclass for handling fif request in all client types
 *  
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/RequestHandler.java-arc  $
 * 
 *    Rev 1.48   Jan 25 2019 14:44:32   lejam
 * SPN-FIF-000135593 Corrected the population of transactionID in case of the exception in ProcessRequest
 * 
 *    Rev 1.47   Jun 19 2015 14:57:22   schwarje
 * PPM-95514: improved handling of server crashes
 * 
 *    Rev 1.46   Jun 03 2015 14:04:50   schwarje
 * PPM-95514: remove slash from filename when logging XML files
 * 
 *    Rev 1.45   Apr 12 2012 11:33:20   schwarje
 * SPN-FIF-000120034: also allow requestLists with only one element, raise FIF0030, if > 1 request
 * 
 *    Rev 1.44   Apr 03 2012 16:05:18   schwarje
 * IT-k-31884: new SLS-FIF trx to execute DML statements directly on the database
 * 
 *    Rev 1.43   Mar 07 2012 13:56:14   schwarje
 * SPN-CCB-000119158: fixed retrieval of customerNumber from reply, if no CDATA is provided
 * 
 *    Rev 1.42   Oct 18 2011 10:11:06   schwarje
 * IT-28900: support for prioritized requests
 * 
 *    Rev 1.41   May 17 2011 17:36:22   schwarje
 * SPN-CCB-000111944: properly initialize ServerHandlerPool
 * 
 *    Rev 1.40   Mar 02 2011 16:40:28   schwarje
 * SPN-FIF-000109481: update customerNumber in FIF_TRANSACTION after each recycling step
 * 
 *    Rev 1.39   Jan 21 2011 14:49:06   schwarje
 * SPN-FIF-000108556: implemented ServerHandlerPool for SBUS-FIF-Clients
 *
 *    Rev 1.38   Nov 23 2010 13:01:08   wlazlow
 * IT-k-29265
 * 
 *    Rev 1.37   Oct 13 2010 19:23:02   schwarje
 * SPN-FIF-000105218:
 * - extended info message for blocking
 * - reset recyclingStatus after blocking a request
 * - return standard error response, whenever the reply from the FIF backend cannot be parsed
 * 
 *    Rev 1.36   Oct 07 2010 18:45:22   schwarje
 * SPN-FIF-000105032: added regular expression for DB errors (for FIF recycling)
 *
 *    Rev 1.35   Sep 28 2010 09:54:46   lejam
 * Added a defaulting of transactionID and pointer check to createFailedRequestNotification SPN-FIF-102422.
 * 
 *    Rev 1.34   Sep 16 2010 09:57:16   schwarje
 * SPN-FIF-000104130: fixed creation of reply message
 * 
 *    Rev 1.33   Sep 14 2010 16:34:44   schwarje
 * SPN-FIF-000103773: fixed service bus clients
 * 
 *    Rev 1.32   Sep 08 2010 12:00:02   schwarje
 * SPN-FIF-000103422: send error response instead of raising an exception if a crap reply comes back from FIF
 * 
 *    Rev 1.31   Jul 29 2010 08:19:24   schwarje
 * IT-27143: improved logging
 * 
 *    Rev 1.30   Jul 20 2010 07:15:24   schwarje
 * SPN-FIF-000101345: fixed wrong response message
 * 
 *    Rev 1.29   Jul 06 2010 18:22:02   schwarje
 * CPCOM 2 updates
 * 
 *    Rev 1.28   Jun 14 2010 20:03:20   schwarje
 * IT-26029: fixed recycling, fixed wrong statement in configuration, fixed creation of failed notifications, fixed concurrency problem when selecting requests in the request handler
 * 
 *    Rev 1.27   Jun 09 2010 18:01:56   schwarje
 * IT-26029: changed select interval to milliseconds
 * 
 *    Rev 1.26   Jun 08 2010 17:35:30   schwarje
 * IT-26029: updates
 * 
 *    Rev 1.25   Jun 01 2010 18:01:58   schwarje
 * IT-26029: updates
 * 
 *    Rev 1.24   May 25 2010 16:33:32   schwarje
 * IT-26029: updates
 * 
 *    Rev 1.23   Mar 11 2010 13:43:06   schwarje
 * IT-26029: Decomissioning MQReader
 * 
 *    Rev 1.22   Mar 11 2010 13:13:08   schwarje
 * IT-26029: Decomissioning MQReader
 * 
 *    Rev 1.20   Dec 15 2009 16:36:12   makuier
 * Do not populate the failed result if value is larger than 4000.
 * 
 *    Rev 1.19   Nov 05 2009 16:01:46   schwarje
 * SPN-FIF-000093205: restart backend process, if the specific error message is returned. Rerun the same request exactly once in this case.
 * 
 *    Rev 1.18   Oct 14 2009 14:48:18   makuier
 * WriteInvalidRequestMessage added.
 * 
 *    Rev 1.17   Aug 14 2009 13:20:58   makuier
 * Use Timestamp instead of date.
 * 
 *    Rev 1.16   Jul 14 2009 17:18:58   schwarje
 * write request files to filesystem
 * 
 *    Rev 1.15   Jun 10 2009 12:15:36   makuier
 * Added a pointer check.
 * 
 *    Rev 1.14   Jun 04 2009 12:37:54   schwarje
 * SPN-FIF-000087150: propagate request list parameters to each single request
 * 
 *    Rev 1.13   Mar 26 2009 16:44:40   schwarje
 * SPN-FIF-000084593: made SyncFIFClient thread-safe when running multithreaded
 * 
 *    Rev 1.12   Feb 25 2009 15:49:00   schwarje
 * SPN-FIF-000082822: also create a handleFailedFifRequest request after technical errors returned from the backend
 * 
 *    Rev 1.11   Feb 19 2009 15:18:02   makuier
 * Initialize the queue connection.
 * 
 *    Rev 1.10   Feb 09 2009 15:47:56   makuier
 * send to a sessioned queue.
 * 
 *    Rev 1.9   Jan 14 2009 11:47:42   makuier
 * Made writeResponse.. protected.
 * 
 *    Rev 1.8   Dec 16 2008 11:08:48   makuier
 * Moved processReply fromCODBQueueClientRequestHandler.
 * 
 *    Rev 1.7   Nov 07 2008 11:24:08   makuier
 * Manual rollback flag added.
 * 
 *    Rev 1.6   Oct 02 2008 13:05:36   makuier
 * Handle request lists.
 * 
 *    Rev 1.5   Aug 21 2008 17:02:30   schwarje
 * IT-22684: added support for populating output parameters on service bus requests
 * 
 *    Rev 1.4   Feb 28 2008 19:31:56   schwarje
 * IT-20793: updated
 * 
 *    Rev 1.3   Feb 28 2008 15:25:32   schwarje
 * IT-20793: added processing of events
 * 
 *    Rev 1.2   Feb 06 2008 20:04:06   schwarje
 * IT-20058: updated
 * 
 *    Rev 1.1   Jan 30 2008 13:06:52   schwarje
 * IT-20058: updated
 * 
 *    Rev 1.0   Jan 29 2008 17:44:14   schwarje
 * Initial revision.
 * 
 ***************************************************************************  
 */
package net.arcor.fif.client;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import net.arcor.fif.common.DateUtils;
import net.arcor.fif.common.FIFErrorLiterals;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FIFTechnicalException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.db.DatabaseConfig;
import net.arcor.fif.db.FailedRequestNotification;
import net.arcor.fif.db.FailedRequestNotificationDataAccess;
import net.arcor.fif.db.FifTransaction;
import net.arcor.fif.db.FifTransactionDataAccess;
import net.arcor.fif.db.GenericDataAccess;
import net.arcor.fif.messagecreator.FIFCommandResult;
import net.arcor.fif.messagecreator.FIFError;
import net.arcor.fif.messagecreator.FIFInvalidRequestException;
import net.arcor.fif.messagecreator.FIFReplyListMessage;
import net.arcor.fif.messagecreator.FIFReplyMessage;
import net.arcor.fif.messagecreator.FIFReplyMessageFactory;
import net.arcor.fif.messagecreator.FIFRequest;
import net.arcor.fif.messagecreator.FIFRequestList;
import net.arcor.fif.messagecreator.FIFTransactionListResult;
import net.arcor.fif.messagecreator.FIFTransactionResult;
import net.arcor.fif.messagecreator.Message;
import net.arcor.fif.messagecreator.MessageCreator;
import net.arcor.fif.messagecreator.MessageCreatorFactory;
import net.arcor.fif.messagecreator.ParameterList;
import net.arcor.fif.messagecreator.ParameterListItem;
import net.arcor.fif.messagecreator.Request;
import net.arcor.fif.messagecreator.RequestSerializer;
import net.arcor.fif.messagecreator.SimpleParameter;
import net.arcor.fif.transport.ServerHandler;
import net.arcor.fif.transport.ServerHandlerPool;

import org.apache.log4j.Logger;


/**
 * parent class for all synchronous fif message handlers
 * @author schwarje
 *
 */
public class RequestHandler implements Runnable {

	private static Object regularLock = new Object();
	private static Object recycleLock = new Object();
	private static List<FifTransaction> newFifTransactions = null;
	private static List<FifTransaction> recycleFifTransactions = null;
	private static int batchSize = 100;
	protected static boolean useServerHandlerPool = false;
	
	/**
	 * DAO for reading and writing FifTransactions to the database
	 */
	private FifTransactionDataAccess fifTransactionDAO = null;
	
	/**
	 * DAO for writing FIF requests for failed transactions to the database
	 */
	private static FailedRequestNotificationDataAccess failedRequestNotificationDAO = null;
	
	/**
	 * DAO for writing FIF requests for failed transactions to the database
	 */
	private static GenericDataAccess genericDAO = null;
	
	/**
	 * pointer to the FIF client which instantiated this request handler
	 */
	private ResponseSender responseSender = null;
	
	/**
	 * indicates if this instance processes recycling requests or regular requests
	 */
	private boolean recyclingInstance = false;

	/**
	 * indicates how long (in seconds) the requestHandler sleeps before selecting 
	 * the next batch of requests for processing
	 */
	private static int selectInterval = 60000; 

	/**
	 * indicates, if the respective FIF client supports prioritzed requests 
	 */
	private static boolean enablePrioritizedRequests = false; 

	/**
	 * the log4j logger for this class
	 */
	protected static Logger logger = Logger.getLogger(RequestHandler.class);

	/**
	 * indicates if recycling is used for the client
	 */
	protected static boolean enableRecycling = false;
	
	/**
	 * indicates if a notification is created, if the Fif request failed
	 */
	protected static boolean createFailedRequestNotification = false;
	
	/**
	 * list of action names for which failed request notifications are created
	 */
	protected static Set<String> failedRequestNotificationActionNames = new HashSet<String>();
	
	/**
	 * indicates if entries in FIF_TRANSACTION are deleted after completion
	 */
	protected static boolean deleteAfterCompletion = false;
	
	/**
	 * indicates, if the request is deleted from the FIF_TRANSACTION table, if no 
	 * customer number was found for the request.
	 */
	protected static boolean deleteUnidentifiedRequestsAfterCompletion = true;	
		
	/**
	 * list of action names for which completed requests are deleted right away from FIF_TRANSACTION 
	 */
	protected static Set<String> deleteAfterCompletionActionNames = new HashSet<String>();
	
	/**
	 * indicates if recycling is already initialized, done only once, not for every thread
	 */
	protected static boolean recyclingInitialized = false;
	
	/**
	 * indicates if failed request handling is already initialized, done only once, not for every thread
	 */
	protected static boolean failedRequestHandlingInitialized = false;	
	
	/**
	 * indicates if certain actions are blocked by this request handler
	 */
	protected static boolean blockActionNames = false;	
	
	/**
	 * indicates if action name blocking is already initialized, done only once, not for every thread
	 */
	protected static boolean blockActionNamesInitialized = false;	
	
	/**
	 * list of action names for which requests are blocked
	 */
	protected static Set<String> blockActionNamesActionNames = new HashSet<String>();
		
	/**
	 * time in minutes, a request is postponed in case of blocked actions
	 */	
	private static int blockedActionDelay;

	/**
	 * the maximum recycling level, indicates how often a message will be recycled before 
	 * it is sent back to the requestor 
	 */
	protected static int maxRecycleStage = 0;
	
	/**
	 * the recycle delay in seconds for each recycle stage
	 */
	protected static HashMap<Integer, Integer> recycleDelays = null;
	
	/**
	 * list of error messages for which requests are recycled 
	 */
	protected static HashSet<String> recycledErrors = null;
	
	/**
	 * list of error messages for which requests are recycled 
	 */
	protected static HashSet<Pattern> recycledErrorsRegex = null;

	/**
	 * reference to server handler which processes the request in the backend
	 */
	private ServerHandler serverHandler;
	
	private boolean isTestInstance = true;
	
	private static FifTransactionDataAccess batchReceiverDAO = null;

	/**
	 * constructor, ses up recycling and the server handler
	 * @throws FIFException
	 */
	protected RequestHandler() throws FIFException {
		try {
			useServerHandlerPool = ClientConfig.getBoolean("SynchronousFifClient.UseServerHandlerPool");
		} catch (FIFException e) {}
		init();
     	if (!useServerHandlerPool)
         	serverHandler = new ServerHandler();
	}

	/**
	 * constructor, ses up recycling and the server handler
	 * @throws FIFException
	 */
	public RequestHandler(String instanceName) throws FIFException {
		try {
			useServerHandlerPool = ClientConfig.getBoolean("SynchronousFifClient.UseServerHandlerPool");
		} catch (FIFException e) {}
		init();
     	if (!useServerHandlerPool)
     		serverHandler = new ServerHandler(instanceName);
	}

	/**
	 * constructor, ses up recycling and the server handler
	 * @throws FIFException
	 */
	public RequestHandler(String instanceName, boolean isServiceBusClient) throws FIFException {
		try {
			useServerHandlerPool = ClientConfig.getBoolean("SynchronousFifClient.UseServerHandlerPool");
		} catch (FIFException e) {}
		if (isServiceBusClient)
     		setupFailedRequestHandling();
     	else 
     		init();
     	if (!useServerHandlerPool)
    		serverHandler = new ServerHandler(instanceName);
	}

	/**
	 * initializes the handling of failed FIF requests
	 * @throws FIFException
	 */
	private static void setupFailedRequestHandling() throws FIFException {
		if (failedRequestHandlingInitialized)
			return;
		
		failedRequestHandlingInitialized = true;
		
		logger.info("Setting up handling of failed FIF transactions.");
		
		try {
			createFailedRequestNotification = ClientConfig.getBoolean("SynchronousFifClient.FailedRequestNotification");
		} catch (FIFException e) {}
		
		if (!createFailedRequestNotification)
			return;

		String actionNames = ClientConfig.getSetting("SynchronousFifClient.FailedRequestNotification.ActionNames");
		
		// read the action names for which failed request notifications are created
		failedRequestNotificationActionNames.addAll(readStringList(actionNames));
		
		// disable FailedRequestNotification if the list of action names is empty, makes no sense anyway then
		if (failedRequestNotificationActionNames.size() == 0) {
			createFailedRequestNotification = false;
			return;
		}
		
		logger.info("This client creates notifications for failed FifRequests " +
				"for the following action names: " + actionNames);
		
		failedRequestNotificationDAO = new FailedRequestNotificationDataAccess(
				ClientConfig.getSetting("SynchronousFifClient.FailedRequestNotification.DBAlias"));
	}

	/**
	 * initializes the handling of failed FIF requests
	 * @throws FIFException
	 */
	private static void setupActionNameBlocking() throws FIFException {
		if (blockActionNamesInitialized)
			return;
		
		blockActionNamesInitialized = true;
		
		logger.info("Setting up blocking of action names.");
		
		try {
			blockActionNames = ClientConfig.getBoolean("SynchronousFifClient.BlockActionNames");
		} catch (FIFException e) {}
		
		if (!blockActionNames)
			return;

		String actionNames = ClientConfig.getSetting("SynchronousFifClient.BlockActionNames.ActionNames");
		
		// read the action names for which failed request notifications are created
		blockActionNamesActionNames.addAll(readStringList(actionNames));
		
		// disable FailedRequestNotification if the list of action names is empty, makes no sense anyway then
		if (blockActionNamesActionNames.size() == 0) {
			blockActionNames = false;
			return;
		}
		
		blockedActionDelay = ClientConfig.getInt("SynchronousFifClient.BlockActionNames.Delay");
		
		logger.info("This client blocks all requests for " + blockedActionDelay + 
				" minutes which contain at least one of the following action names: " + actionNames);
	}

	private static Set<String> readStringList(String stringList) {
		return readStringList(stringList, ",");
	}
	
	/**
	 * @param actionNames
	 * @return
	 */
	private static Set<String> readStringList(String stringList, String separator) {
		Set<String> returnObject = new HashSet<String>();
		if (stringList != null && !stringList.trim().equals(""))
			for (String singleString : stringList.split(separator))
				if (!singleString.trim().equals(""))
					returnObject.add(singleString.trim());
		return returnObject;
	}
	
	/**
	 * sets up recycling, read following information from the property file and the database:
	 * - number of recycling stages
	 * - recycling delays per stage
	 * - error messages to recycle
	 * @throws FIFException
	 */
	private static void setupRecycling() throws FIFException {		
		// make sure this is done only once
		if (recyclingInitialized)
			return;
		
		recyclingInitialized = true;
		
		logger.info("Setting up recycling of failed FIF requests.");
		
	    try {
			enableRecycling = ClientConfig.getBoolean("RequestHandler.EnableRecycling");
		} catch (FIFException e) {}

		// if there is no recycling, there is no need to continue
		if (!enableRecycling)
			return;
		
		// get the number of recycle stages and the delays (in seconds) for each stage
		maxRecycleStage = ClientConfig.getInt("RequestHandler.MaxRecycleStage");								
		recycleDelays = new HashMap<Integer, Integer>();
		for (int i = 1;i <= maxRecycleStage;i++)
			recycleDelays.put(i, ClientConfig.getInt("RequestHandler.RecycleDelay.Stage" + i));

		// read the errors to recycle from the database and put them in a collection
		recycledErrors = new HashSet<String>();
		recycledErrorsRegex = new HashSet<Pattern>();
		Connection connection = null;
		Statement retrieveRecycledErrorStmt = null;
		try {			
	        String dbAlias = ClientConfig.getSetting("RequestHandler.RecycledErrorsDBAlias");
	        connection = DriverManager.getConnection(DatabaseConfig.JDBC_CONNECT_STRING_PREFIX + dbAlias);
	        connection.setAutoCommit(false);
	        retrieveRecycledErrorStmt = connection.createStatement();
	        
			String sql = ClientConfig.getSetting("RequestHandler.RetrieveRecycledErrorStmt");
			
			// retrieve from database
			ResultSet result = retrieveRecycledErrorStmt.executeQuery(sql);

			// Pattern for checking, if the error code is a simple error code
			// and not a regular expression
			Pattern pattern = Pattern.compile("^[A-Za-z0-9]+$");
			
			// populate result
			while (result.next()) {
				String errorCode = result.getString(1);
				Matcher matcher = pattern.matcher(errorCode);
				if (matcher.find())
					recycledErrors.add(errorCode);
				else
					recycledErrorsRegex.add(Pattern.compile(errorCode));
			}
		} catch (SQLException e) {
			throw new FIFException(e);
		} finally {
			try {
				if (retrieveRecycledErrorStmt != null)
					retrieveRecycledErrorStmt.close();
			} catch (SQLException e) {}
			try {
				if (connection != null)
					connection.close();
			} catch (SQLException e) {}
		}
		
			
	}

	/**
	 * method to check if the request has to be recycled, which is done under the following circumstances:
	 * - recycling is enabled
	 * - maximum recycling stage is not reached yet
	 * - one of the errors returned from FifInterface is in the list of error messages to be recycled
	 * @param recycleStage the current recycle stage of the request
	 * @param replyMsg the answer to the request from FifInterface
	 * @return if the message should be recycled
	 * @throws FIFException
	 */
	protected static boolean shouldWeRecycle (int recycleStage, Message replyMsg) throws FIFException {		
		// check if recycling is enabled
	    if (!enableRecycling)
	    	return false;
	    	
	    if (recycleStage >= maxRecycleStage) {
	    	logger.debug("Reached final recycling stage " + maxRecycleStage + 
	    			". This request will no longer be recycled.");
	    	return false;
	    }
	    
	    ArrayList<FIFError> results = extractErrors(replyMsg);	    
	    
	    // loop through the list to check if one of the errors is a recycle lists
	    for (FIFError item : results) {
    		if (recycledErrors.contains(item.getNumber()))
    			return true;	    
    		else 
    			for (Pattern errorPattern : recycledErrorsRegex)
    				if (errorPattern.matcher(item.getNumber()).find())
    					return true;
	    }
	    	
		return false;
	}


	/**
	 * @param replyMsg
	 * @param results
	 * @throws FIFException
	 */
	protected static ArrayList<FIFError> extractErrors(Message replyMsg) throws FIFException {
		ArrayList results = new ArrayList();
		ArrayList<FIFError> errors = new ArrayList<FIFError>();
		
		// put all errors from fif in a list
	    if (replyMsg instanceof FIFReplyMessage)
	    	results.addAll(((FIFReplyMessage)replyMsg).getResult().getResults());
	    
	    else if (replyMsg instanceof FIFReplyListMessage) 
	    	for (Object item : ((FIFReplyListMessage)replyMsg).getResult().getReplies())
	    		if (item instanceof FIFReplyMessage)
	    			results.addAll(((FIFReplyMessage)item).getResult().getResults());
		
	    for (Object item : results)
	    	if (item instanceof FIFCommandResult) {
	    		ArrayList commandResults = ((FIFCommandResult) item).getResults();
	    		if (commandResults != null)
	    			for (Object commandResult : commandResults)
	    				if (commandResult instanceof FIFError)
	    					errors.add((FIFError)commandResult);
	    	}
	    
		return errors;
	}
	
	/**
	 * @param request
	 * @return
	 * @throws FIFException
	 */
	protected Message processRequest(Request request) throws FIFException {
		
		Message requestMessage = null;
		String transactionID = null;
		// sent the message to the server handler which calls the backend fif process
		String reply = null;
		Message replyMsg = null; 
		try {
			if (request instanceof FIFRequest){
				transactionID = ((FIFRequest)request).getTransactionID();
				requestMessage = processSimpleRequest((FIFRequest)request);
			    // Write the sent message, if needed.
				writeSentMessage(requestMessage, transactionID, request.getAction(),false);
			} else if (request instanceof FIFRequestList){
				transactionID = ((FIFRequestList)request).getID();
				requestMessage = processRequestList((FIFRequestList)request);
				// Write the sent message, if needed.
				long start = System.currentTimeMillis();
				writeSentMessage(requestMessage,transactionID, ((FIFRequestList)request).getName(),false);
				logger.debug("Saving sent message duration: " + (System.currentTimeMillis() - start));
			}	
			
			if (useServerHandlerPool) {
				ServerHandler sh = ServerHandlerPool.getServerHandler();
				try {
					reply = sh.processMessage(requestMessage.getMessage(), true);
				} finally {
					ServerHandlerPool.returnServerHandler(sh);
				}				
			}
			else 
				reply = serverHandler.processMessage(requestMessage.getMessage(), true);
		} catch (FIFInvalidRequestException e) {
			logger.info("Error during creation of FIF message (transactionID: " +
					transactionID + "): " + e.getMessage());
			replyMsg = FIFReplyMessageFactory.createFailureMessage(request, FIFErrorLiterals.FIF0020.name(), e.getMessage());
		} catch (FIFTechnicalException e) {
			logger.info(e.getMessage());
			replyMsg = FIFReplyMessageFactory.createFailureMessage(request, e.getErrorCode(), e.getMessage());
		}				
		
		/*if (replyMsg == null && reply == null) {
			logger.info("The server has crashed while processing request " + transactionID);
			replyMsg = FIFReplyMessageFactory.createFailureMessage(request, FIFErrorLiterals.FIF0010.name(), "The server has crashed while processing the message.");
		} 
		else */
		if (replyMsg == null) {
	        // Create a Message containing the received data
	        replyMsg = FIFReplyMessageFactory.createMessage(reply);

	        // check if the transaction ids match, if not somethings badly wrong
	        // for simple requests
	        if (replyMsg != null && replyMsg instanceof FIFReplyMessage && 
	        	((FIFReplyMessage)replyMsg).getTransactionID() != null) {
	        	if (!((FIFReplyMessage)replyMsg).getTransactionID().equals(transactionID))
	        		replyMsg = FIFReplyMessageFactory.createFailureMessage(
	        				request, 
	        				FIFErrorLiterals.FIF0011.name(), 
	        				"Transaction id of the reply doesn't match the " +
	        				"transaction id of the request. Something is badly wrong here!");
	        	else
	    	        // process the reply
	    			processReply(replyMsg);
	        }
	        // for transaction lists
        	else if (replyMsg != null && replyMsg instanceof FIFReplyListMessage && 
		        	((FIFReplyListMessage)replyMsg).getTransactionListID() != null) {
	        	if (!((FIFReplyListMessage)replyMsg).getTransactionListID().equals(transactionID))
	        		replyMsg = FIFReplyMessageFactory.createFailureMessage(
	        				request, 
	        				FIFErrorLiterals.FIF0011.name(), 
	        				"Transaction List id of the reply doesn't match the " +
	        				"transaction List id of the request. Something is badly wrong here!");
	        	else
	    	        // process the reply
	    			processReply(replyMsg);
        	}
	        // if both don't apply, this must be an invalid reply, which also has to be handled 
        	else 
        		replyMsg = FIFReplyMessageFactory.createFailureMessage(
        				request, 
        				FIFErrorLiterals.FIF0018.name(), 
        				"The reply returned from the FIF backend could not be parsed. " +
        				"FIF-API cannot determine, if the request was processed successfully.");
		}
		
		// handle failed single requests 
		if (replyMsg instanceof FIFReplyMessage) {
			FIFReplyMessage replyMessage = (FIFReplyMessage) replyMsg;
		
			// check, if recycling needs to be done and set the parameters needed for recycling			
			if (replyMessage.getResult().getResult() == FIFTransactionResult.FAILURE) {
				if (shouldWeRecycle(request.getRecycleStage(), replyMessage)) {
					replyMessage.setRecycleMessage(true);
					replyMessage.setRecycleDelay(recycleDelays.get(request.getRecycleStage() + 1));				
				}
					
				else if (createFailedRequestNotification)
					createFailedRequestNotification(request, extractErrors(replyMessage), transactionID);
			}
		}
			
		// handle failed request lists 
		else if (replyMsg instanceof FIFReplyListMessage) {
			FIFReplyListMessage replyListMessage = (FIFReplyListMessage) replyMsg;
			if (replyListMessage.getResult().getResult() == FIFTransactionListResult.FAILURE) {

				FIFReplyMessage failedReply = null;

				// loop through the requests and look for the failed one				
				for (Object singleReply : replyListMessage.getResult().getReplies()) {
					if (singleReply instanceof FIFReplyMessage) {
						failedReply = (FIFReplyMessage) singleReply;
						if (failedReply.getResult().getResult() == FIFTransactionResult.FAILURE)
							break;
						else 
							failedReply = null;
					}
				}
				
				if (shouldWeRecycle(request.getRecycleStage(), failedReply)) {
					replyListMessage.setRecycleMessage(true);
					replyListMessage.setRecycleDelay(recycleDelays.get(request.getRecycleStage() + 1));				
				}
				
				else if (createFailedRequestNotification)
					createFailedRequestNotification(request, extractErrors(failedReply), transactionID);
			}
		}
		
		// Log the success
	    logger.info("Successfully processed request for id: " + transactionID);
		
		return replyMsg;
	}
	
	private Message processRequestList(FIFRequestList requestList) throws FIFException {
		List<Message> requestMsgList = new LinkedList<Message>();
		
		//header parameter list
		List<SimpleParameter> transactionListParams = requestList.getHeaderList();
		
		Iterator requestIter = requestList.getRequests().iterator();
		while (requestIter.hasNext()) {
			FIFRequest request = (FIFRequest) requestIter.next();
			// add all the request list params to each request, if no parameter
			// with the same name already exists there
			if (transactionListParams != null){
				for (SimpleParameter sp : transactionListParams)
					if (request.getParam(sp.getName()) == null)
						request.getParams().put(sp.getName(), sp);
			}
			Message requestMsg = processSimpleRequest(request);
			logger.debug("Adding request message to lists: " + requestMsg);
			requestMsgList.add(requestMsg);
		}
	
		long start = System.currentTimeMillis(); 
		Message listMsg = RequestSerializer.createFIFTransactionList(requestList.getID(), requestList
				.getName(), requestList.getOMTSOrderID(), requestList.getManualRollback(),transactionListParams,requestMsgList);
		logger.debug("Serialization duration: " + (System.currentTimeMillis() - start));
		return listMsg;
	}


	private Message processSimpleRequest(FIFRequest request) throws FIFException {
		// Get the message creator
		long start = System.currentTimeMillis();
		MessageCreator mc =
			MessageCreatorFactory.getMessageCreator(request.getAction());
		logger.debug("Getting message creator duration: " + (System.currentTimeMillis() - start));
		
		if (isTestInstance  && request.getParams().containsKey("OVERRIDE_SYSTEM_DATE"))
			DateUtils.setOverrideDateTime(
					((SimpleParameter)request.getParams().get("OVERRIDE_SYSTEM_DATE")).getValue());		
		else
			DateUtils.setOverrideDateTime((Date)null);					
		
		// Create the message
		start = System.currentTimeMillis();
		Message requestMessage = mc.createMessage(request);
		logger.debug("Transforming message duration: " + (System.currentTimeMillis() - start));
		
		// TODO error response for invalid ones
		return requestMessage;
	}


	private void processReply(Message replyMessage) throws FIFException
	{
        // Check the reply type
		if (replyMessage instanceof FIFReplyMessage) {
			processSimpleReply((FIFReplyMessage) replyMessage, false);            
		} else if (replyMessage instanceof FIFReplyListMessage) {
			processListReply((FIFReplyListMessage) replyMessage);            
		} else {
			throw new FIFException(
					"Reply message is of unknown type: "
					+ replyMessage.getClass().getName());
		}
	}

    private void processListReply(FIFReplyListMessage msg) throws FIFException {
        // Get the list ID - this will also parse the reply
        String listID = msg.getTransactionListID();

        // Check if we got a transaction ID
        if ((!msg.isValid()) || (listID == null) || (listID.length() == 0)) {
            // We did not get a transaction ID and the message
            // is invalid.  This means that FIF gave us 'crap'.
            // We have to log this as an error and put this invalid
            // message in a special directory.

            // Log an error
            String error = "Received invalid reply list message from FIF";
            if (listID != null) {
                error += " for transaction list ID " + listID;
            }
            error += ".";
            logger.error(error);
            logger.error("Error messages:\n" + msg.getResult().toString());

            // Write the invalid reply
            writeInvalidReplyMessage(msg);

            // Bail out if we could not extract the transaction ID
            if (listID == null) {
                return;
            }
        } else {
            // Write the received message to an output file, if needed
        	writeReplyMessage(msg);
        }

        logger.debug(
            "Processing FIF reply for transaction list ID: " + listID + ".");

    }

	/**
     * Processes a FIF reply Message.
     * Reads the response status of the message and updates the database
     * accordingly.
     * @param msg   the FIF reply message to process.
     * @throws FIFException if the message could not be processed.
     */
	private void processSimpleReply(FIFReplyMessage msg, boolean isInList) throws FIFException {
        // Get the transaction ID - this will also parse the reply

    	String transactionID = msg.getTransactionID();
        // Make sure that the transaction ID does not contain empty characters
        if ((transactionID != null) && (transactionID.trim().length() == 0)) {
            transactionID = null;
        }

        // Check if we got a transaction ID
        String outputFileName = null;

        if (!isInList && (!msg.isValid())
            || (transactionID == null)
            || (transactionID.length() == 0)) {
            // We did not get a transaction ID and the message
            // is invalid.  This means that FIF gave us 'crap'.
            // We have to log this as an error and put this invalid
            // message in a special directory.

            // Log an error
            String error = "Received invalid reply message from FIF";
            if (transactionID != null) {
                error += " for transaction ID " + transactionID + ".";
            } else {
                error += ": No transaction ID in reply message.";
            }
            logger.error(error);

            if (transactionID != null) {
                logger.error("Error messages:\n" + msg.getResult().toString());
            }

            // Write the invalid reply
           	writeInvalidReplyMessage(msg);

            // Bail out if we could not extract the transaction ID
            if (transactionID == null) {
            	return;
            }
        } else {
        	if (!isInList)
        		writeReplyMessage(msg);
        }

        logger.debug("Processing reply for transaction id: " + transactionID + ".");

        // Add an additional error message to the results
        if (!isInList && !msg.isValid()) {
        	String errorMsg =
        		"Received invalid reply from FIF. "
        		+ "Stored this invalid reply in file: "
        		+ outputFileName;
        	FIFError error = new FIFError("FIF-API", errorMsg);
        	ArrayList<FIFError> errors = new ArrayList<FIFError>();
        	errors.add(error);
        	FIFCommandResult commandResult =
        		new FIFCommandResult(
        				"FIF-API",
        				FIFCommandResult.FAILURE,
        				errors);
        	msg.getResult().addResult(commandResult);
        }
        logger.debug("Successfully processed reply for transaction id: " + transactionID + ".");
    }

	/**
	 * Writes a sent message to the sent message directory.
	 * The message is only written to the directory if it is
	 * configured in the property file
	 * @param msg     the message to be sent
	 * @param id      the transaction id of the message
	 * @param action  the action the message is related to
	 * @throws FIFException
	 */
	private void writeSentMessage(Message msg, String id, String action,boolean isList)
	    throws FIFException {
	    // Bail out if the message should not be written to a output file
	    if (!ClientConfig.getBoolean("SynchronousFifClient.WriteSentMessages")) {
	        return;
	    }
	
	    String fileName =
	        FileUtils.writeToOutputFile(
	            msg.getMessage(),
	            ClientConfig.getPath("SynchronousFifClient.SentOutputDir"),
	            "sent-"+(isList?"list-":"")+ action.replace("/", "") + "-" + id,
	            ".xml",
	            false);
	
	    logger.info("Wrote sent message to: " + fileName);
	}

	/**
	 * Writes the received message to an output file.
	 * The message is only written to the directory if it is
	 * configured in the property file
	 * @param msg  the message to write to the output file
	 * @throws FIFException
	 */
	private void writeReplyMessage(Message msg) throws FIFException {
	    // Bail out if the message should not be written to a output file
	    if (!ClientConfig
	        .getBoolean("SynchronousFifClient.WriteReplyMessages")) {
	        return;
	    }
	
	    String id = null;
	    String xml = null;
	    boolean isList = false;
        if (msg instanceof FIFReplyMessage) {
    	    id = ((FIFReplyMessage)msg).getTransactionID();
    	    xml = ((FIFReplyMessage)msg).getFormattedXMLMessage();       	
        } else if (msg instanceof FIFReplyListMessage) {
    	    id = ((FIFReplyListMessage)msg).getTransactionListID();
    	    xml = ((FIFReplyListMessage)msg).getFormattedXMLMessage();
    	    isList=true;
        }
	    String fileName =
	        FileUtils.writeToOutputFile(
	        	xml,
	            ClientConfig.getPath("SynchronousFifClient.ReplyOutputDir"),
	            "reply-"+(isList?"list-":"") + id,
	            ".xml",
	            false);
	
	    logger.info("Wrote reply message to: " + fileName);
	}

	
	/**
	 * Writes the received message to an output file.
	 * The message is only written to the directory if it is
	 * configured in the property file
	 * @param msg  the message to write to the output file
	 * @throws FIFException
	 */
	private void writeInvalidReplyMessage(Message msg) throws FIFException {
        String fileName = null;
        if (msg instanceof FIFReplyMessage) {
        	if (((FIFReplyMessage)msg).getTransactionID() != null) {
        		fileName =
        			FileUtils.writeToOutputFile(
        					((FIFReplyMessage)msg).getFormattedXMLMessage(),
        					ClientConfig.getPath(
        							"SynchronousFifClient.InvalidReplyOutputDir"),
        							"invalid-reply-" + ((FIFReplyMessage)msg).getTransactionID(), ".xml", false);
        	} else {
        		fileName =
        			FileUtils.writeToOutputFile(
        					((FIFReplyMessage)msg).getFormattedXMLMessage(),
        					ClientConfig.getPath(
        							"SynchronousFifClient.InvalidReplyOutputDir"),
        							"invalid-reply-unknown-transaction-id", ".xml", false);
        	}
        } else if (msg instanceof FIFReplyListMessage) {
        	if (((FIFReplyListMessage)msg).getTransactionListID() != null) {
        		fileName =
        			FileUtils.writeToOutputFile(
        					((FIFReplyListMessage)msg).getFormattedXMLMessage(),
        					ClientConfig.getPath(
        							"SynchronousFifClient.InvalidReplyOutputDir"),
        							"invalid-reply-" + ((FIFReplyListMessage)msg).getTransactionListID(), ".xml", false);
        	} else {
        		fileName =
        			FileUtils.writeToOutputFile(
        					((FIFReplyListMessage)msg).getFormattedXMLMessage(),
        					ClientConfig.getPath(
        							"SynchronousFifClient.InvalidReplyOutputDir"),
        							"invalid-reply-unknown-transaction-id", ".xml", false);
        	}
        }

        logger.info("Wrote invalid reply contents to: " + fileName);
	}

	protected static void createFailedRequestNotification(Request request, String errorCode, String errorText) throws FIFException {
		if (!createFailedRequestNotification || request == null)
			return;
		ArrayList<FIFError> errors = new ArrayList<FIFError>();
		errors.add(new FIFError(errorCode, errorText));
		createFailedRequestNotification(request, errors, ((FIFRequest)request).getTransactionID());
	}
	
	/**
	 * @param request
	 * @param errors
	 * @param transactionID
	 * @throws FIFException
	 */
	protected static void createFailedRequestNotification(Request request, ArrayList<FIFError> errors, String transactionID) throws FIFException {		
		FIFRequest failedRequest = null;
		// find the request, that originally led to the failure
		if (request instanceof FIFRequest)
			failedRequest = (FIFRequest) request;		
		else if (request instanceof FIFRequestList) {
			for (Object singleRequest : ((FIFRequestList)request).getRequests())
				if (singleRequest instanceof FIFRequest){
					// if no transactionID provided use the one from first FIF request
					if(transactionID == null || (transactionID != null && transactionID.length() == 0))
						transactionID = ((FIFRequest) singleRequest).getTransactionID();
					if (((FIFRequest) singleRequest).getTransactionID().equals(transactionID)) {
						failedRequest = (FIFRequest) singleRequest;
						break;
					}
				}
		}
		else 
			throw new FIFException("Illegal type of reply message. Just a safety exception which should never be thrown.");
		
		// TODO geht so noch nicht für SbusClient
		if(failedRequest != null) {
			if (failedRequestNotificationActionNames.contains(failedRequest.getAction())) {		
				FailedRequestNotification failedRequestNotification = new FailedRequestNotification();
				failedRequestNotification.setExternalSystemID(transactionID);
				failedRequestNotification.setRequestParams(failedRequest.getParams());
				failedRequestNotification.setRequestErrors(errors);
				failedRequestNotification.setActionName(failedRequest.getAction());
				failedRequestNotificationDAO.insertFailedRequestNotification(failedRequestNotification);
				logger.info("Created failed request notification (FIF-Trx handleFailedFifRequest) for request " +
						transactionID + " with transactionID " + failedRequestNotification.getId());
			}
		}
	}
	
	/**
	 * @throws FIFException
	 */
	public void init() throws FIFException {
		if (batchReceiverDAO == null)
			batchReceiverDAO = new FifTransactionDataAccess(ClientConfig.getSetting("SynchronousFifClient.FifTransaction.DBAlias"));
		
		try {
			useServerHandlerPool = ClientConfig.getBoolean("SynchronousFifClient.UseServerHandlerPool");
		} catch (FIFException e) {}
		
		// sets up all recycling related objects
    	setupRecycling();

    	// sets up all data required for handling of failed FIF requests
    	setupFailedRequestHandling();
    	
    	// sets up all data required for blocking of certain action names
    	setupActionNameBlocking();
    	
    	// configures the treatment of completed requests, i.e. if they are deleted or not after completion
		try {
			deleteAfterCompletion = ClientConfig.getBoolean("SynchronousFifClient.DeleteAfterCompletion");
		} catch (FIFException e) {}	
    	
		try {
			deleteUnidentifiedRequestsAfterCompletion = ClientConfig.getBoolean(
					"SynchronousFifClient.DeleteUnidentifiedRequestsAfterCompletion");
		} catch (FIFException e) {}			
    	
		try {
			enablePrioritizedRequests = ClientConfig.getBoolean("RequestHandler.EnablePrioritizedRequests");
		} catch (FIFException e) {}			
		
		String actionNames = null;
		try {
			actionNames = ClientConfig.getSetting("SynchronousFifClient.DeleteAfterCompletion.ActionNames");
		} catch (FIFException e) {}		
			
		// read the action names for which failed request notifications are created
		deleteAfterCompletionActionNames.addAll(readStringList(actionNames));
			
		fifTransactionDAO = new FifTransactionDataAccess(ClientConfig.getSetting("SynchronousFifClient.FifTransaction.DBAlias"));
		
		try {
			selectInterval = Integer.parseInt(ClientConfig.getSetting("RequestHandler.SelectInterval"));
		} catch (FIFException e) {			
		} catch (NumberFormatException e) {}
		
		try {
			batchSize = Integer.parseInt(ClientConfig.getSetting("RequestHandler.BatchSize"));
		} catch (FIFException e) {			
		} catch (NumberFormatException e) {}
	}
	
	/* (non-Javadoc)
	 * @see java.lang.Runnable#run()
	 */
	public void run() {
		int exceptionCounter = 0;
		while (!Thread.interrupted() && exceptionCounter <= 10) {
			try {
				FifTransaction fifTransaction = 
					(recyclingInstance) ? 
						getNextRecycleFifTransaction() :
						getNextRegularFifTransaction();
					processTransaction(fifTransaction);	
				exceptionCounter = 0;
			} catch (FIFException e) {
				logger.fatal("Exception was raised, see details: ", e);
				exceptionCounter++;
			}
		}
	}

	private static FifTransaction getNextRegularFifTransaction() throws FIFException {
		synchronized (regularLock) {
			return getNextFifTransaction(false);
		}
	}

	private static FifTransaction getNextRecycleFifTransaction() throws FIFException {
		synchronized (recycleLock) {
			return getNextFifTransaction(true);
		}
	}
	
	private static FifTransaction getNextFifTransaction(boolean recyclingInstance) throws FIFException {
		List<FifTransaction> transactionList = 
			(recyclingInstance) ? recycleFifTransactions : newFifTransactions;
		FifTransaction fifTransaction = null;
		boolean sleepBeforeRetrieving = false;
		while (fifTransaction == null) {
			if (sleepBeforeRetrieving)  {
				try {
					sleepBeforeRetrieving = false;
					Thread.sleep(selectInterval);
				} catch (InterruptedException e) {
					logger.info(e);
				}
			}
				
			if (transactionList == null || transactionList.size() == 0) {
				transactionList = 
					batchReceiverDAO.retrievePendingFifTransactions(
							(recyclingInstance) ? 
									SynchronousFifClient.FIF_TRANSACTION_STATUS_IN_RECYCLING : 
									SynchronousFifClient.FIF_TRANSACTION_STATUS_NEW, 
							SynchronousFifClient.theClient.getClientId(),
							batchSize,
							(recyclingInstance) ? false : enablePrioritizedRequests);
				if (transactionList != null && transactionList.size() > 0)
					logger.info("Retrieved " + transactionList.size() + " FIF transactions to be processed.");
				else { 
					sleepBeforeRetrieving = true;
					continue;
				}
			}
			
			fifTransaction = transactionList.remove(0);
		}
		
		if (recyclingInstance)
			recycleFifTransactions = transactionList;
		else
			newFifTransactions = transactionList;
		
		fifTransaction.setStatus(SynchronousFifClient.FIF_TRANSACTION_STATUS_IN_PROGRESS_FIF);
		logger.info("Setting status of FifTransaction " + fifTransaction.getTransactionId() + 
				" to " + fifTransaction.getStatus());
		batchReceiverDAO.updateFifTransaction(fifTransaction);
		
		return fifTransaction;
	}

	/**
	 * executes an SQL statement directly on the database without going to CcmFifInterface
	 * @param fifTransaction
	 * @param request
	 * @throws FIFException
	 */
	private void processSQLRequest(FifTransaction fifTransaction, Request request) throws FIFException {
		QueueClientResponseMessage responseMessage = null;
		ArrayList errors = new ArrayList();
		
		if (!(request instanceof FIFRequest) && ((FIFRequestList)request).getRequests().size() > 1) {
			logger.error("FIF0030: The FifTransaction executeSQL may only be processed as single request, not as a request list of more than one request.");
			FIFError error = new FIFError(FIFErrorLiterals.FIF0030.name(), "The FifTransaction executeSQL may only be processed as single request, not as a request list of more than one request.");
			errors.add(error);
			responseMessage = new QueueClientResponseMessage(
					QueueClientResponseMessage.FAILURE,
					request.getAction(),
					fifTransaction.getTransactionId(),
					errors);
		}
		else {
			FIFRequest fifRequest = null;
			if (request instanceof FIFRequest)
				fifRequest = (FIFRequest) request;
			else if (request instanceof FIFRequestList)
				fifRequest = (FIFRequest)((FIFRequestList) request).getRequests().get(0);
			// get a new database connection, if there's none yet
			if (genericDAO == null) {
				genericDAO = new GenericDataAccess(ClientConfig.getSetting("SynchronousFifClient.FifTransaction.DBAlias"));
				try {
					genericDAO.setMaxUpdatedRows(ClientConfig.getInt("SynchronousFifClient.SQLRequest.MaxUpdatedRows"));
				} catch (FIFException e) {}
			}
			
			String userName = ((SimpleParameter)fifRequest.getParam("userName")).getValue();
			String referencedTicket = ((SimpleParameter)fifRequest.getParam("referencedTicket")).getValue();
			ParameterList statementsParameterList = ((ParameterList)fifRequest.getParam("statements"));
			LinkedList<String> statements = new LinkedList<String>(); 
			for (Object listItem : statementsParameterList.getItems()) {
				statements.add(((SimpleParameter)((ParameterListItem)listItem).getParam("statement")).getValue());
			}
			
			logger.info("The following statements are executed by user '" + userName + 
					"' for ticket '" + referencedTicket + "'.");
			try {
				genericDAO.executeStatementList(statements);
				// everything ok, create a positive response
				responseMessage = new QueueClientResponseMessage(
						QueueClientResponseMessage.SUCCESS,
						request.getAction(),
						fifTransaction.getTransactionId(),
						errors);			
			} catch (FIFException e) {
				FIFError error = new FIFError(FIFErrorLiterals.FIF0029.name(), e.getMessage());
				errors.add(error);
				// exception raised, create a negative response
				responseMessage = new QueueClientResponseMessage(
						QueueClientResponseMessage.FAILURE,
						request.getAction(),
						fifTransaction.getTransactionId(),
						errors);
			}
		}
		
		// save the result to the FIF_TRANSACTION table
		fifTransaction.setClientResponse(responseMessage.getMessage());
		fifTransaction.setStatus(SynchronousFifClient.FIF_TRANSACTION_STATUS_COMPLETED_FIF);
		fifTransaction.setEndDate(new Timestamp(new Date().getTime()));
		logger.info("Setting status of FifTransaction " + fifTransaction.getTransactionId() + 
				" to " + fifTransaction.getStatus());
		fifTransactionDAO.updateFifTransaction(fifTransaction);
		
		// "send a response", in this case, this is the update of the FIF_REQUEST table 
		if (responseSender != null)
			responseSender.sendResponse(responseMessage);
		else 
			logger.debug("No response handler defined for client " + this.getClass().getName());
		fifTransaction.setStatus(SynchronousFifClient.FIF_TRANSACTION_STATUS_RESPONSE_SENT);
    	logger.info("Setting status of FifTransaction " + fifTransaction.getTransactionId() + 
			" to " + fifTransaction.getStatus());
    	fifTransactionDAO.updateFifTransaction(fifTransaction);
		deleteAfterCompletion(fifTransaction, request);
	}
	
	private void processTransaction(FifTransaction fifTransaction) throws FIFException {
		logger.info("Processing FifTransaction " + fifTransaction.getTransactionId() + 
				" for client " + fifTransaction.getClientType());
		Request request = RequestSerializer.serializeFromString(fifTransaction.getClientRequest(), null, true);
		
		if (isSQLRequest(request))
			processSQLRequest(fifTransaction, request);
		else	
			processFifTransaction(fifTransaction, request);
	}
	
	private boolean isSQLRequest(Request request) {

		if (request instanceof FIFRequest) {
			if (((FIFRequest)request).getAction().equals("executeSQL"))
				return true;
		}
		else
			for (Object singleRequest : ((FIFRequestList)request).getRequests()) 
				if (((FIFRequest)singleRequest).getAction().equals("executeSQL"))
					return true;
						
		return false;	
	}

	/**
	 * @param fifTransaction
	 * @param request 
	 * @throws FIFException
	 */
	private void processFifTransaction(FifTransaction fifTransaction, Request request) throws FIFException {
		request.setRecycleStage(fifTransaction.getRecycleStage());
		
		if (isActionBlocked(fifTransaction.getTransactionId(), request)) {
			Timestamp newDueDate = new Timestamp(new Date().getTime() + blockedActionDelay * 60000);
			fifTransaction.setDueDate(newDueDate);			
			fifTransaction.setStatus(SynchronousFifClient.FIF_TRANSACTION_STATUS_NEW);
			fifTransaction.setRecycleStage(0);
			fifTransactionDAO.updateFifTransaction(fifTransaction);
			return;
		}
		
		Message replyMessage = processRequest(request);
		String updatedCustomerNumber = getCustomerNumberFromReply(replyMessage);
		if (updatedCustomerNumber != null && updatedCustomerNumber.length() > 0)
			fifTransaction.setCustomerNumber(updatedCustomerNumber);

		boolean recycleMessage = false;
		int recycleDelay = 0;			

		if (replyMessage instanceof FIFReplyListMessage) {
			recycleMessage = ((FIFReplyListMessage) replyMessage).getRecycleMessage();
			recycleDelay = ((FIFReplyListMessage) replyMessage).getRecycleDelay();			
		}			
		else if (replyMessage instanceof FIFReplyMessage) {
			recycleMessage = ((FIFReplyMessage) replyMessage).getRecycleMessage();
			recycleDelay = ((FIFReplyMessage) replyMessage).getRecycleDelay();
		}

		if (recycleMessage) {
			Timestamp newDueDate = new Timestamp(new Date().getTime() + recycleDelay * 60000);
			fifTransaction.setStatus(SynchronousFifClient.FIF_TRANSACTION_STATUS_IN_RECYCLING);
			fifTransaction.setDueDate(newDueDate);
			fifTransaction.setRecycleStage(fifTransaction.getRecycleStage() + 1);
			if (logger.isDebugEnabled())
				logger.debug("Transaction " + fifTransaction.getTransactionId() + 
						" will be recycled. New recycle stage: " + fifTransaction.getRecycleStage() + 
						", new due date: " + fifTransaction.getDueDate());
			logger.info("Setting status of FifTransaction " + fifTransaction.getTransactionId() + 
					" to " + fifTransaction.getStatus());
			fifTransactionDAO.updateFifTransaction(fifTransaction);
		}
		else {			
			Message responseMessage = getResponseMessage(replyMessage);
			fifTransaction.setClientResponse(responseMessage.getMessage());
			fifTransaction.setStatus(SynchronousFifClient.FIF_TRANSACTION_STATUS_COMPLETED_FIF);
			fifTransaction.setEndDate(new Timestamp(new Date().getTime()));
			logger.info("Setting status of FifTransaction " + fifTransaction.getTransactionId() + 
					" to " + fifTransaction.getStatus());
			fifTransactionDAO.updateFifTransaction(fifTransaction);
			responseMessage.setJmsCorrelationId(fifTransaction.getJmsCorrelationId());
			responseMessage.setJmsReplyTo(fifTransaction.getJmsReplyTo());
			if (responseSender != null)
				responseSender.sendResponse(responseMessage);
			else 
				logger.debug("No response handler defined for client " + this.getClass().getName());
			fifTransaction.setStatus(SynchronousFifClient.FIF_TRANSACTION_STATUS_RESPONSE_SENT);
        	logger.info("Setting status of FifTransaction " + fifTransaction.getTransactionId() + 
				" to " + fifTransaction.getStatus());
        	fifTransactionDAO.updateFifTransaction(fifTransaction);
			deleteAfterCompletion(fifTransaction, request);
		}
	}

	private Message getResponseMessage(Message replyMessage) throws FIFException {
		if (replyMessage instanceof FIFReplyListMessage)
        	return new QueueClientResponseListMessage((FIFReplyListMessage) replyMessage);
        else if (replyMessage instanceof FIFReplyMessage)
        	return new QueueClientResponseMessage((FIFReplyMessage) replyMessage);
        else 
        	throw new FIFException("Illegal type of reply message");
	}

	private boolean isActionBlocked(String transactionId, Request request) {
		if (!blockActionNames)
			return false;
		if (request instanceof FIFRequest) {
			if (blockActionNamesActionNames.contains(((FIFRequest)request).getAction())) {
				logger.info("Request " + transactionId + " is postponed by " + 
						blockedActionDelay + " minutes because the action " + 
						((FIFRequest)request).getAction() + " is currently blocked.");
				return true;
			}
		}
		else
			for (Object singleRequest : ((FIFRequestList)request).getRequests()) {
				if (blockActionNamesActionNames.contains(((FIFRequest)singleRequest).getAction())) {
					logger.info("Request " + transactionId + " is postponed by " + 
						blockedActionDelay + " minutes because the action " + 
							((FIFRequest)singleRequest).getAction() + " is currently blocked.");
					return true;
				}
		}
		return false;	
	}

	private String getCustomerNumberFromReply(Message replyMessage) throws FIFException {
		if (replyMessage == null)
			return null;
		
		Matcher matcher = Pattern.compile("<customer_number>.*</customer_number>")
								.matcher(replyMessage.getMessage());
		if (matcher.find()) {
			String customerNumberPart = matcher.toMatchResult().group();			
			String customerNumber = null;
			if (customerNumberPart.startsWith("<customer_number><![CDATA["))
				customerNumber = customerNumberPart.substring(26, 38);
			else
				customerNumber = customerNumberPart.substring(17, 29);			
			logger.debug("Customer number found in FIF reply: " + customerNumber);
			return customerNumber;
		}
		return null;
	}

	private void deleteAfterCompletion(FifTransaction fifTransaction, Request request) throws FIFException {
		// change status and save response or for certain action names, just delete the request again
		boolean delete = false;
		// if the client is set to delete everything after completion, set the variable
		if (deleteAfterCompletion)
			delete = true;
		// TODO eine Variante noch verdeckt, blockieren sich gegenseitig
		// if the customer number, the request would be useless for the anonymizer
		// and can be deleted, if requested.
		else if (deleteUnidentifiedRequestsAfterCompletion && 
				fifTransaction.getCustomerNumber() == null) {
			delete = true;
		}
		// otherwise check the action name of the request or all action names in case of a request list
		// In a request list, the entry in FIF_TRANSACTION is only deleted, if all action names within are to be deleted
		else {
			if (request instanceof FIFRequest) {
				if (deleteAfterCompletionActionNames.contains(((FIFRequest)request).getAction()))
					delete = true;
			}
			else if (request instanceof FIFRequestList) {
				delete = true;
				for (Object singleRequest : ((FIFRequestList)request).getRequests()) {
					if (singleRequest instanceof FIFRequest && 
							!deleteAfterCompletionActionNames.contains(((FIFRequest)singleRequest).getAction())) {
						delete = false;
						break;
					}
				}
			}
		}
		if (delete) {
			logger.info("Deleting FifTransaction " + fifTransaction.getTransactionId() + 
					" (status: " + fifTransaction.getStatus() + ") from the database.");
			fifTransactionDAO.deleteFifTransaction(fifTransaction);
			fifTransactionDAO.commit();
		}
	}

	public boolean isRecyclingInstance() {
		return recyclingInstance;
	}

	public void setRecyclingInstance(boolean recyclingInstance) {
		this.recyclingInstance = recyclingInstance;
	}

	public ResponseSender getResponseSender() {
		return responseSender;
	}

	public void setResponseSender(ResponseSender responseSender) {
		this.responseSender = responseSender;
	}

	public FifTransactionDataAccess getFifTransactionDAO() {
		return fifTransactionDAO;
	}

	
}
