/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/DatabaseClientMessageSender.java-arc   1.24   May 13 2009 10:42:22   lejam  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/DatabaseClientMessageSender.java-arc  $
 * 
 *    Rev 1.24   May 13 2009 10:42:22   lejam
 * Added sorting of message list using ActionComparator IT-24729,IT-25224
 * 
 *    Rev 1.23   Jan 27 2009 17:46:18   lejam
 * Added request locking functionality to FIF-API database client to allow multiple running instances of the application SPN-FIF-82246
 * 
 *    Rev 1.22   Dec 17 2008 16:46:12   schwarje
 * SPN-FIF-000073486: write an IN_PROGRESS record (with start date) before writing the FAILED record
 * 
 *    Rev 1.21   Nov 07 2008 11:24:06   makuier
 * Manual rollback flag added.
 * 
 *    Rev 1.20   Aug 08 2008 15:49:02   wlazlow
 * IT-21113
 * 
 *    Rev 1.19   Sep 26 2007 15:36:08   schwarje
 * SPN-FIF-000061017: populate requestListId in case of a request list of a db client
 * 
 *    Rev 1.18   Aug 20 2007 12:55:10   schwarje
 * IT-19036: added parameters for populating OMTSOrderId
 * 
 *    Rev 1.17   Aug 16 2007 19:23:06   lejam
 * Added support for OMTSOrderId on the request list level IT-19036
 * 
 *    Rev 1.16   May 29 2007 14:24:42   schwarje
 * SPN-FIF-000055940: when updating transaction status, also check if there is an error message
 * 
 *    Rev 1.15   Apr 25 2007 14:32:00   schwarje
 * IT-19232: support for transaction lists
 * 
 *    Rev 1.14   Apr 19 2007 17:14:44   schwarje
 * IT-19232: support for transaction lists in database clients
 * 
 *    Rev 1.13   Jan 24 2007 17:30:12   schwarje
 * SPN-FIF-000050997: catch exceptions during initialisation of clients without new parameters
 * 
 *    Rev 1.12   Jan 17 2007 17:54:18   makuier
 * Handle the dependent transaction id.
 * SPN-FIF-000046682.
 * 
 *    Rev 1.11   Aug 25 2004 13:32:28   goethalo
 * SPN-FIF-000024999: Fixed extraction of action_name tag.
 * 
 *    Rev 1.10   Aug 02 2004 15:26:14   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.9   May 18 2004 17:03:52   goethalo
 * IT-8410: Improved support for parameter lists in database clients.
 * 
 *    Rev 1.8   Jan 26 2004 16:40:04   goethalo
 * IT-10018: Added AutoShutdown functionality.
 * 
 *    Rev 1.7   Jan 08 2004 18:04:36   goethalo
 * Added queue emulation support. To enable emulation set DatabaseClient.EmulateQueues=true
 * 
 *    Rev 1.6   Nov 04 2003 14:54:44   goethalo
 * Added more error logging.
 * 
 *    Rev 1.5   Oct 08 2003 10:19:56   goethalo
 * IT-9811: Changed 'transactionId' parameter to 'transactionID'
 * 
 *    Rev 1.4   Sep 09 2003 16:34:58   goethalo
 * IT-10800: support for warnings and parameter lists in DB clients.
 * 
 *    Rev 1.3   Jul 16 2003 14:55:22   goethalo
 * Changes for IT-9750.
 * 
 *    Rev 1.2   May 12 2003 13:31:28   goethalo
 * Do not exit when an invalid action name is passed in. Consider this as a normal error.
 * 
 *    Rev 1.1   Apr 14 2003 15:51:08   goethalo
 * Turned off autocommit and enabled manual commits.
 *
 *    Rev 1.0   Apr 09 2003 09:34:30   goethalo
 * Initial revision.
*/
package net.arcor.fif.client;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.messagecreator.ActionComparator;
import net.arcor.fif.messagecreator.Message;
import net.arcor.fif.messagecreator.MessageCreator;
import net.arcor.fif.messagecreator.MessageCreatorFactory;
import net.arcor.fif.messagecreator.MessageCreatorMetaData;
import net.arcor.fif.messagecreator.MessageSender;
import net.arcor.fif.messagecreator.ParameterList;
import net.arcor.fif.messagecreator.ParameterListItem;
import net.arcor.fif.messagecreator.ParameterListMetaData;
import net.arcor.fif.messagecreator.ParameterMetaData;
import net.arcor.fif.messagecreator.Request;
import net.arcor.fif.messagecreator.RequestFactory;
import net.arcor.fif.messagecreator.RequestSerializer;
import net.arcor.fif.messagecreator.SimpleParameter;

import org.apache.log4j.Logger;

/**
 * This class is responsible for sending FIF messages based on requests
 * in the database table.
 * It reads the requests from the database, creates a FIF message for this
 * request, and sends the message to FIF.
 * It additionally updates the state of the requests appropriately in the
 * request table.
 *
 * @author goethalo
 */
public class DatabaseClientMessageSender implements Runnable {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger =
        Logger.getLogger(DatabaseClientMessageSender.class);

    /**
     * The connection to use for the database.
     */
    private Connection conn = null;

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement requestStmt = null;

    /**
     * The field name of the transaction ID in the request table.
     */
    private String requestTransactionIDFieldName = null;

    /**
     * The field name of the action in the request table.
     */
    private String requestActionFieldName = null;

    /**
     * The field name of the transaction list ID in the request table.
     */
    private String requestTransactionListIDFieldName = null;

    /**
     * The field name of the dependent transaction ID in the request table.
     */
    private String requestDependentTransactionIDFieldName = null;

    /**
     * The prepared statement for retrieving a transaction list
     */
    private PreparedStatement transactionListStmt = null;

    /**
     * The field name of the transaction ID in the request table.
     */
    private String transactionListTransactionIDFieldName = null;

    /**
     * The field name of the status in the request table.
     */
    private String transactionListStatusFieldName = null;

    /**
     * The field name of the action in the request table.
     */
    private String transactionListActionFieldName = null;

    /**
     * The prepared statement for retrieving the request parameters
     */
    private PreparedStatement requestParamStmt = null;

    /**
     * The prepared statement for retrieving the request parameter lists.
     */
    private PreparedStatement requestParamListStmt = null;

    /**
     * The field index of the transaction ID in the statement.
     */
    private int requestParamListTransactionIDFieldIndex = 0;

    /**
     * The field index of the parameter list in the statement.
     */
    private int requestParamListParamListFieldIndex = 0;

    /**
     * The field name of the list item number in the parameter list table.
     */
    private String requestParamListItemNumberFieldName = null;

    /**
     * The field name of the parameter in the parameter list table.
     */
    private String requestParamListParamFieldName = null;

    /**
     * The field name of the parameter value in the parameter list table.
     */
    private String requestParamListValueFieldName = null;

    /**
     * The prepared statement for locking the request for update to 'In Progress'
     */
    private PreparedStatement stateNotStartedLockStmt = null;

    /**
     * The prepared statement for updating the request state to 'In Progress'
     */
    private PreparedStatement inProgressUpdateStmt = null;

    /**
     * The prepared statement for updating a finished request
     */
    private PreparedStatement finishedRequestUpdateStmt = null;

    /**
     * The field index of the transaction ID in the finished request statement.
     */
    private int finishedRequestUpdateTransactionIDIndex = 0;

    /**
     * The field index of the error message in the finished request statement.
     */
    private int finishedRequestUpdateErrorMessageIndex = 0;

    /**
     * The field index of the status in the finished request statement.
     */
    private int finishedRequestUpdateStatusIndex = 0;

    /**
     * The maximum size of the error message in the database.
     */
    private int failureMaxErrorSize = 0;

    /**
     * The prepared statement for updating a whole transaction list
     */    
    private PreparedStatement updateTransactionListStmt = null;

    /**
     * The field index of the transaction list ID in the transaction list statement.
     */
    private int updateTransactionListTransactionListIDIndex = 0;

    /**
     * The field index of the transaction list status in the transaction list statement.
     */
    private int updateTransactionListListStatusIndex = 0;

    /**
     * The message sender.
     */
    private MessageSender sender = null;

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
    
    /*---------*
     * METHODS *
     *---------*/

    /**
     * Initializes the message sender.
     */
    public void init() throws FIFException {
        // Database-related setup
        try {
            // Create the prepared statements
            logger.info("Preparing database statements...");
            conn = DriverManager.getConnection(DatabaseClientConfig.dbAlias);
            conn.setAutoCommit(false);
            logger.info(
                "Preparing RetrieveRequestsStatement: "
                    + DatabaseClientConfig.getSetting(
                        "databaseclient.RetrieveRequestsStatement"));
            requestStmt =
                conn.prepareStatement(
                    DatabaseClientConfig.getSetting(
                        "databaseclient.RetrieveRequestsStatement"));
            // Set the batch size
            if (DatabaseClientConfig.getInt("databaseclient.RequestBatchSize")
                > 0) {
                logger.info(
                    "Set request batch size to "
                        + DatabaseClientConfig.getSetting(
                            "databaseclient.RequestBatchSize"));
                requestStmt.setMaxRows(
                    DatabaseClientConfig.getInt(
                        "databaseclient.RequestBatchSize"));
            }

            logger.info(
                "Preparing RetrieveParamsStatement: "
                    + DatabaseClientConfig.getSetting(
                        "databaseclient.RetrieveParamsStatement"));
            requestParamStmt =
                conn.prepareStatement(
                    DatabaseClientConfig.getSetting(
                        "databaseclient.RetrieveParamsStatement"));

            // Only prepare the param list statement if it is provided in
            // to configuration file.  This is needed for backwards compatibility
            boolean paramListStatementProvided = false;

            try {
                DatabaseClientConfig.getSetting(
                    "databaseclient.RetrieveParamListStatement");
                paramListStatementProvided = true;
            } catch (FIFException fe) {
                // Ignore, statement is not provided.
            }
            if (paramListStatementProvided) {
                logger.info(
                    "Preparing RetrieveParamListStatement: "
                        + DatabaseClientConfig.getSetting(
                            "databaseclient.RetrieveParamListStatement"));
                requestParamListStmt =
                    conn.prepareStatement(
                        DatabaseClientConfig.getSetting(
                            "databaseclient.RetrieveParamListStatement"));
                requestParamListTransactionIDFieldIndex =
                    DatabaseClientConfig.getInt(
                        "databaseclient."
                            + "RetrieveParamListStatement.TransactionIDFieldIndex");
                requestParamListParamListFieldIndex =
                    DatabaseClientConfig.getInt(
                        "databaseclient."
                            + "RetrieveParamListStatement.ParamListFieldIndex");
                requestParamListItemNumberFieldName =
                    DatabaseClientConfig.getSetting(
                        "databaseclient."
                            + "RetrieveParamListStatement.ParamListItemNumberFieldName");
                requestParamListParamFieldName =
                    DatabaseClientConfig.getSetting(
                        "databaseclient."
                            + "RetrieveParamListStatement.ParamNameFieldName");
                requestParamListValueFieldName =
                    DatabaseClientConfig.getSetting(
                        "databaseclient."
                            + "RetrieveParamListStatement.ParamValueFieldName");

            }

            logger.info(
                "Preparing RetrieveStateNotStartedForUpdateStatement: "
                    + DatabaseClientConfig.getSetting(
                        "databaseclient.RetrieveStateNotStartedForUpdateStatement"));
            stateNotStartedLockStmt =
                conn.prepareStatement(
                    DatabaseClientConfig.getSetting(
                        "databaseclient.RetrieveStateNotStartedForUpdateStatement"));

            logger.info(
                "Preparing UpdateStateInProgressStatement: "
                    + DatabaseClientConfig.getSetting(
                        "databaseclient.UpdateStateInProgressStatement"));
            inProgressUpdateStmt =
                conn.prepareStatement(
                    DatabaseClientConfig.getSetting(
                        "databaseclient.UpdateStateInProgressStatement"));

            logger.info(
                "Preparing UpdateFinishedRequestStatement: "
                    + DatabaseClientConfig.getSetting(
                        "databaseclient.UpdateFinishedRequestStatement"));
            finishedRequestUpdateStmt =
                conn.prepareStatement(
                    DatabaseClientConfig.getSetting(
                        "databaseclient.UpdateFinishedRequestStatement"));

            logger.info("Successfully prepared database statements.");
        } catch (SQLException e) {
            throw new FIFException(
                "Error while initializing message sender",
                e);
        }

        // Field names
        requestTransactionIDFieldName =
            DatabaseClientConfig.getSetting(
                "databaseclient.RetrieveRequestsStatement."
                    + "TransactionIDFieldName");
        requestActionFieldName =
            DatabaseClientConfig.getSetting(
                "databaseclient.RetrieveRequestsStatement."
                    + "ActionFieldName");
        try {
			requestDependentTransactionIDFieldName =
			    DatabaseClientConfig.getSetting(
			        "databaseclient.RetrieveRequestsStatement."
			            + "DependentTransactionIDFieldName");
		} catch (FIFException e) {
			// ignore if not provided
		}
        finishedRequestUpdateTransactionIDIndex =
            DatabaseClientConfig.getInt(
                "databaseclient.UpdateFinishedRequestStatement."
                    + "TransactionIDIndex");
        finishedRequestUpdateStatusIndex =
            DatabaseClientConfig.getInt(
                "databaseclient.UpdateFinishedRequestStatement."
                    + "StatusIndex");
        finishedRequestUpdateErrorMessageIndex =
            DatabaseClientConfig.getInt(
                "databaseclient.UpdateFinishedRequestStatement."
                    + "ErrorMessageIndex");
        failureMaxErrorSize =
            DatabaseClientConfig.getInt(
                "databaseclient.MaxErrorMessageSize");        
        
        if (DatabaseClient.transactionListSupported)
        {
            try {
    			requestTransactionListIDFieldName =
    			    DatabaseClientConfig.getSetting(
    			        "databaseclient.RetrieveRequestsStatement."
    			            + "TransactionListIDFieldName");

				logger.info("Preparing UpdateTransactionListStateStatement: "
					+ DatabaseClientConfig.getSetting("databaseclient.UpdateTransactionListStateStatement"));
				updateTransactionListStmt = conn.prepareStatement(DatabaseClientConfig
					.getSetting("databaseclient.UpdateTransactionListStateStatement"));

				updateTransactionListTransactionListIDIndex =
				    DatabaseClientConfig.getInt(
				        "databaseclient.UpdateTransactionListStateStatement."
				            + "TransactionListIDIndex");
				updateTransactionListListStatusIndex =
				    DatabaseClientConfig.getInt(
				        "databaseclient.UpdateTransactionListStateStatement."
				            + "TransactionListStatusIndex");
				
				logger.info("Preparing RetrieveTransactionListRequestsStatement: "
						+ DatabaseClientConfig.getSetting("databaseclient.RetrieveTransactionListRequestsStatement"));
					transactionListStmt = conn.prepareStatement(DatabaseClientConfig
						.getSetting("databaseclient.RetrieveTransactionListRequestsStatement"));

				transactionListTransactionIDFieldName = DatabaseClientConfig
						.getSetting("databaseclient.RetrieveTransactionListRequestsStatement."
								+ "TransactionIDFieldName");
				transactionListStatusFieldName = DatabaseClientConfig
						.getSetting("databaseclient.RetrieveTransactionListRequestsStatement."
								+ "StatusFieldName");
				transactionListActionFieldName = DatabaseClientConfig
						.getSetting("databaseclient.RetrieveTransactionListRequestsStatement."
								+ "ActionNameFieldName");
			} catch (SQLException e) {
	            throw new FIFException("Error while initializing message sender",e);
			}

        }
        
        // Message Sender setup
        if (DatabaseClient.emulateQueues == false) {
            sender = new MessageSender("sendqueue");
            sender.start();
        }

        try {
			wrapRequestInTransactionList = DatabaseClientConfig.getBoolean("databaseclient.WrapRequestInTransactionList");
			artificialListName = DatabaseClientConfig.getSetting("databaseclient.ArtificialListName");
			populateOmtsOrderId = DatabaseClientConfig.getBoolean("databaseclient.PopulateOmtsOrderId");
			defaultOmtsOrderIdParameterName = DatabaseClientConfig.getSetting("databaseclient.DefaultOmtsOrderIdParameterName");
		} catch (FIFException e) {
		}
        
        logger.info("Successfully initialized message sender.");
    }

    /**
     * Starts to process the requests from the database.
     * @see java.lang.Runnable#run()
     */
    public void run() {
        try {
            boolean hasResult = true;
            boolean dependentTransactionIDFieldNameProvided = 
            	(requestDependentTransactionIDFieldName != null &&
            			requestDependentTransactionIDFieldName != "");
            while (!(Thread.interrupted())
                && !(DatabaseClient.inErrorStatus())) {
                // Retrieve the request to be processed
                if (hasResult) {
                    logger.info("Waiting for requests in database...");
                    logger.debug("Retrieving requests from the database...");
                }
                ResultSet result = requestStmt.executeQuery();

                // Process the requests
                hasResult = result.next();

                if (hasResult) {
                    logger.debug("Successfully retrieved requests from database.");
                    logger.info("Processing requests...");

                    do {
                    	// if transaction lists are not supported or the list id is empty, 
                    	// process the request as single request
                    	String transactionListId = (DatabaseClient.transactionListSupported) ?
                    			result.getString(requestTransactionListIDFieldName) : null;
                    	if (transactionListId == null || transactionListId.trim().equals(""))
							processSimpleRequest(result.getString(requestTransactionIDFieldName).trim(),
									null,
									result.getString(requestActionFieldName),
									(dependentTransactionIDFieldNameProvided) ? result
											.getString(requestDependentTransactionIDFieldName) : null);

                        // otherwise this request is part of a transaction list
                    	else 
                    		processTransactionList(transactionListId.trim());
                    } while (
                        (result.next()) && !(DatabaseClient.inErrorStatus()));

                    logger.info("Successfully processed requests.");
                }
                result.close();

                // Sleep...
                if (hasResult && !DatabaseClient.autoShutdown) {
                    logger.info("Sleeping before processing next batch of requests...");
                } else if (hasResult && DatabaseClient.autoShutdown) {
                    logger.warn("All requests have been processed. Shutting down...");
                    return;
                }
                Thread.sleep(DatabaseClientConfig.getInt("databaseclient.RequestSleepTime"));
            }
        } catch (FIFException fe) {
            // Set the error status on the DatabaseClient object
            if (DatabaseClient.isShutDownHookInvoked() == false) {
                logger.fatal("Fatal error while processing requests", fe);
            }
            DatabaseClient.setErrorStatus();
        } catch (InterruptedException ie) {
            // Set the error status on the DatabaseClient object
            if (DatabaseClient.isShutDownHookInvoked() == false) {
                logger.fatal("DatabaseClientMessageSender interrupted", ie);
            }
            DatabaseClient.setErrorStatus();
        } catch (SQLException e) {
            // Set the error status on the DatabaseClient object
            if (DatabaseClient.isShutDownHookInvoked() == false) {
                logger.fatal("Fatal database error while processing requests", e);
            }
            DatabaseClient.setErrorStatus();
        } catch (Exception e) {
            if (DatabaseClient.isShutDownHookInvoked() == false) {
                logger.fatal("Fatal exception while processing requests", e);
            }
            DatabaseClient.setErrorStatus();        	
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
    private void processSimpleRequest(String id, String listId, String action, String depActionID) throws FIFException {
        try {
            logger.info("Processing request for id: " + id + ", action: " + action + "...");
            
            // Define a null error string and null message
            String error = null;
            Message msg = null;

            // Check if an action mapping exists for the passed in action
            if (!(MessageCreatorMetaData.hasActionMapping(action))) {
				// Populate the error string with an error message.
				error = "Cannot create message for request. Reason: no action mapping found " 
					+ "for action name '" + action + "'.";
			}
            else {
            	try {
            		Request request = createSimpleRequest(id, listId, action, depActionID);
                    // Get the message creator
                    MessageCreator mc =
                        MessageCreatorFactory.getMessageCreator(action);

                    // Create the message
                    msg = mc.createMessage(request);
                    
                    if (wrapRequestInTransactionList) {
                    	LinkedList<Message> messageList = new LinkedList<Message>();
                    	messageList.add(msg);
                    	msg = RequestSerializer.createFIFTransactionList(
        						((SimpleParameter)request.getParam("transactionID")).getValue(), 
        						artificialListName,
        						retrieveOmtsOrderId(request), null, null,
        						messageList);
                    }
				} catch (FIFException fe) {
					// The creation of the message failed.
					// Populate the error string with an error message.
					StringBuffer sb = new StringBuffer();
					sb.append("Cannot create message for request. ");
					sb.append("Reason: ");
					sb.append(fe.getMessage());
					logger.error("Caught exception", fe);
					error = sb.toString();
				}
            }

            // Send the message
            if (error == null) {
                
                stateNotStartedLockStmt.setString(1, id);

                ResultSet result = stateNotStartedLockStmt.executeQuery();

                // if locked send to queue
                if (result.next()) {
                    logger.info("Successfully locked request id: " + id + ", action: " + action+ ". Sending to queue...");
            	
	            	if (DatabaseClient.emulateQueues == false) {
	                    sender.sendMessage(msg);
	                } else {
	                    logger.info("Emulating queues. Not sending mesage.");
	                }
	
	                // No error, set the in progress state
	                updateTransactionStatus(id, DatabaseClient.requestStatusInProgress, null);
	                conn.commit();

	                // Write the sent message, if needed.
	                writeSentMessage(msg, id, action);

	                // Log the success
	                logger.info("Successfully processed request for id: " + id + ", action: " + action);
                } else {
	                // Skip the request, already processed
	                logger.info("Cannot lock request id: " + id + ", action: " + action + ". Skipping...");
                }

            } else {
                updateTransactionStatus(id, DatabaseClient.requestStatusInProgress, null);
            	updateTransactionStatus(id, DatabaseClient.requestStatusFailed, error);
                conn.commit();

                // Log the error
                logger.error(error);
            }
        } catch (SQLException e) {
            logger.error("Could not process request for id: " + id, e);
        } catch (FIFException fe) {
            logger.error("Error while processing request for id: "
                    + id + ", action: " + action, fe);
            throw fe;
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
	 * @throws SQLException
	 */
	private Request createSimpleRequest(String id, String listId, String action, String depActionID) throws FIFException, SQLException {
		Request request;
		// Create a request object
		request = RequestFactory.createRequest(action);
		
		// Set the standard parameters
		request.addParam(new SimpleParameter("transactionID", id));
		if (listId != null)
			request.addParam(new SimpleParameter("requestListId", listId));
		if (depActionID != null)
			request.addParam(new SimpleParameter("dependentTransactionID", depActionID));

		// Retrieve the parameters
		requestParamStmt.clearParameters();
		requestParamStmt.setString(1, id);
		ResultSet result = requestParamStmt.executeQuery();
		while (result.next()) {
		    // Add the parameter to the request
		    request.addParam(
		        new SimpleParameter(
		            result.getString(
		                DatabaseClientConfig.getSetting(
		                    "databaseclient.RetrieveParamsStatement."
		                        + "ParamNameFieldName")),
		            result.getString(
		                DatabaseClientConfig.getSetting(
		                    "databaseclient.RetrieveParamsStatement."
		                        + "ParamValueFieldName"))));
		}

		// Retrieve the parameter lists, if needed
		if (requestParamListStmt != null) {
		    // Get the parameter metadata
		    ArrayList paramMetadata = null;
		    paramMetadata =
		        MessageCreatorMetaData
		            .getActionMapping(action)
		            .getMessageParams();

		    // Loop through the parameter metadata and add the lists to the request
		    Iterator iter = paramMetadata.iterator();
		    while (iter.hasNext()) {
		        ParameterMetaData pmd = (ParameterMetaData) iter.next();
		        if (pmd instanceof ParameterListMetaData) {
		            ParameterList list =
		                new ParameterList(pmd.getName());
		            requestParamListStmt.clearParameters();
		            requestParamListStmt.setString(
		                requestParamListTransactionIDFieldIndex,
		                id);
		            requestParamListStmt.setString(
		                requestParamListParamListFieldIndex,
		                pmd.getName());
		            result = requestParamListStmt.executeQuery();

		            String currentItemNumber = null;
		            ParameterListItem item = null;
		            while (result.next()) {
		                String itemNumber =
		                    result.getString(
		                        requestParamListItemNumberFieldName);
		                if (!itemNumber.equals(currentItemNumber)) {
		                    currentItemNumber = itemNumber;
		                    item = new ParameterListItem();
		                    list.addItem(item);
		                }
		                item.addParam(
		                    new SimpleParameter(
		                        result.getString(
		                            requestParamListParamFieldName),
		                        result.getString(
		                            requestParamListValueFieldName)));
		            }
		            request.addParam(list);
		        }
		    }
		}
		return request;
	}

	/**
	 * processes a transaction list:
	 * - retrieves all requests
	 * - processs requests one by one
	 * - bundles and sends a FIFReplyListMessage
	 * @param transactionListId		ID of the transaction list
	 * @throws FIFException
	 * @throws SQLException
	 */
	private void processTransactionList(String transactionListId) throws FIFException, SQLException
	{
		ResultSet result = null;
		try {
			// retrieve requests
			boolean errorInList = false;
			logger.debug("Retrieving all requests for transaction list " + transactionListId);
			transactionListStmt.clearParameters();
			transactionListStmt.setString(1, transactionListId);
			result = transactionListStmt.executeQuery();

			// loop through the requests to see if they were already processed 
			while (result.next())
			{
				if (!(result.getString(transactionListStatusFieldName).equals(DatabaseClient.requestStatusNotStarted))) {
					logger.debug("Request for transaction list " + transactionListId 
							+ "is already processed. Skipping this request.");
					result.close();
					return;
				}
			}
			result.close();
			
			// loop through and handle the single requests
			LinkedList<Message> messageList = new LinkedList<Message>();
			result = transactionListStmt.executeQuery();
			String transactionListOmtsOrderId = null;
			while (result.next() && !errorInList)
			{
			    String id = result.getString(transactionListTransactionIDFieldName);
				String action = result.getString(transactionListActionFieldName);
				logger.info("Processing request for id: " + id + ", action: " + action + "...");

				// Define a null error string and null message
				String error = null;

				// Check if an action mapping exists for the passed in action
				if (!(MessageCreatorMetaData.hasActionMapping(action))) {
					// Populate the error string with an error message.
					error = "Cannot create message for request. Reason: no action mapping found "
							+ "for action name '" + action + "'.";
				} else {
					try {
						Request request = createSimpleRequest(id, transactionListId, action, null);
	                    // Get the message creator
	                    MessageCreator mc =
	                        MessageCreatorFactory.getMessageCreator(action);

	                    // Create the message
	                    Message msg = mc.createMessage(request);
	                    msg.setAction(action);
	                    
	                    // get the order id for the OMTS notification from the request
	                    if (transactionListOmtsOrderId == null && populateOmtsOrderId)
	                    	transactionListOmtsOrderId = retrieveOmtsOrderId(request);

						messageList.add(msg);
					} catch (FIFException fe) {
						// The creation of the message failed.
						// Populate the error string with an error message.
						StringBuffer sb = new StringBuffer();
						sb.append("Cannot create message for request. ");
						sb.append("Reason: ");
						sb.append(fe.getMessage());
						logger.error("Caught exception", fe);
						error = sb.toString();
					}
				}

				// write the IN_PROGRESS record
				updateTransactionStatus(id, DatabaseClient.requestStatusInProgress, null);

				// Update the state in the DB
				if (error == null) {
					// Log the success
					logger.info("Successfully processed request for id: " + id + ", action: " + action);
				} else {
					// There was an error, set the failure state
					updateTransactionStatus(id, DatabaseClient.requestStatusFailed, error);
					errorInList = true;
					// Log the error
					logger.error(error);
				}                
			}
			
			// send and write full sent message
			if (!errorInList) {
				ActionComparator actionComp = new ActionComparator();
				Collections.sort(messageList, actionComp);

				Message messageToSend = RequestSerializer.createFIFTransactionList(
						transactionListId, "dummy", transactionListOmtsOrderId,null,null,messageList);
			    if (DatabaseClient.emulateQueues == false) {
			        sender.sendMessage(messageToSend);
			    } else {
			        logger.info("Emulating queues. Not sending mesage.");
			    }
			    updateTransactionListStatus(transactionListId, DatabaseClient.requestStatusInProgress);
                // Write the sent message, if needed.
                writeSentMessage(messageToSend, transactionListId, "dummy");
			}
			else {
				updateTransactionListStatus(transactionListId, DatabaseClient.requestStatusFailed);
			}
		} finally {
			result.close();       		
			conn.commit();
		}
	}

	/**
	 * sets the transaction list status for all requests in a transaction list
	 * @param transactionListId		id of the transaction list
	 * @param status				desired status 
	 * @throws SQLException
	 */
	private void updateTransactionListStatus(String transactionListId, String status) throws SQLException {
		// update the other transactions of the transaction list
		updateTransactionListStmt.clearParameters();
        if (DatabaseClient.requestStatusDataType.equals(DatabaseClient.requestStatusDataTypeVarchar))
        	updateTransactionListStmt.setString(updateTransactionListListStatusIndex, status);
        if (DatabaseClient.requestStatusDataType.equals(DatabaseClient.requestStatusDataTypeNumber))
        	updateTransactionListStmt.setLong(updateTransactionListListStatusIndex, Long.parseLong(status));
		updateTransactionListStmt.setString(updateTransactionListTransactionListIDIndex, transactionListId);
		if (updateTransactionListStmt.executeUpdate() == 0) {
			logger.warn("Could not update status to '" + status + "' for transaction list ID: "
				+ transactionListId);
		}
	}

	/**
	 * sets the status for a transaction
	 * @param id		transaction id of the request
	 * @param status	desired status
	 * @param error		error message (optional) 
	 * @throws SQLException
	 */
	private void updateTransactionStatus(String id, String status, String error) throws SQLException {
		int rows = 0;
        if (status.equals(DatabaseClient.requestStatusFailed) && error != null){
    		// Truncate the error message if it is too long
            if (error != null && error.length() > failureMaxErrorSize)
            	error = error.substring(0, failureMaxErrorSize);
            finishedRequestUpdateStmt.clearParameters();
            finishedRequestUpdateStmt.setString(finishedRequestUpdateTransactionIDIndex, id);
            if (DatabaseClient.requestStatusDataType.equals(DatabaseClient.requestStatusDataTypeVarchar))
        		finishedRequestUpdateStmt.setString(finishedRequestUpdateStatusIndex, status);
            if (DatabaseClient.requestStatusDataType.equals(DatabaseClient.requestStatusDataTypeNumber))
        		finishedRequestUpdateStmt.setLong(finishedRequestUpdateStatusIndex, Long.parseLong(status));
            finishedRequestUpdateStmt.setString(finishedRequestUpdateErrorMessageIndex, error);
            rows = finishedRequestUpdateStmt.executeUpdate();
        }
        // use different statement for InProgress, because start date is set instead of end date
        else if (status.equals(DatabaseClient.requestStatusInProgress)){
        	inProgressUpdateStmt.clearParameters();
        	inProgressUpdateStmt.setString(1, id);
            rows = inProgressUpdateStmt.executeUpdate();
        }
        if (rows == 0) {
            logger.warn("Could not update status to '" + status + "' for transaction ID: " + id);
        }        	
	}
	
    /**
     * Writes a sent message to the sent message directory.
     * The messages is only written to the directory if the
     * <code>databaseclient.WriteSentMessages</code> setting
     * is set to <code>true</code>
     * @param msg     the message to be sent
     * @param id      the transaction id of the message
     * @param action  the action the message is related to
     * @throws FIFException
     */
    private void writeSentMessage(Message msg, String id, String action)
        throws FIFException {
        // Bail out if the message should not be written to a output file
        if (!DatabaseClientConfig.getBoolean("databaseclient.WriteSentMessages")) {
            return;
        }

        String fileName =
            FileUtils.writeToOutputFile(
                msg.getMessage(),
                DatabaseClientConfig.getPath("databaseclient.SentOutputDir"),
                action + "-" + id,
                ".xml",
                false);

        logger.info("Wrote sent message to: " + fileName);
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
    		omtsOrderIdParameterName = DatabaseClientConfig.getSetting("databaseclient.OmtsOrderIdParameterName." + request.getAction());    		
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
        boolean success = true;
        try {
            if (requestStmt != null) {
                requestStmt.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close statement.", e);
            success = false;
        }
        try {
            if (requestParamStmt != null) {
                requestParamStmt.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close statement.", e);
            success = false;
        }
        try {
            if (requestParamListStmt != null) {
                requestParamListStmt.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close statement.", e);
            success = false;
        }
        try {
            if (stateNotStartedLockStmt != null) {
            	stateNotStartedLockStmt.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close statement.", e);
            success = false;
        }
        try {
            if (inProgressUpdateStmt != null) {
                inProgressUpdateStmt.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close statement.", e);
            success = false;
        }
        try {
            if (updateTransactionListStmt != null) {
            	updateTransactionListStmt.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close statement.", e);
            success = false;
        }
        try {
            if (finishedRequestUpdateStmt != null) {
            	finishedRequestUpdateStmt
            	.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close statement.", e);
            success = false;
        }
        try {
            if (conn != null) {
                conn.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close connection.", e);
            success = false;
        }
        try {
            if (sender != null) {
                sender.shutdown();
            }
        } catch (FIFException e1) {
            logger.error("Cannot shutdown message sender.");
            success = false;
        }

        if (success) {
            logger.info("Successfully shut down message sender.");
        } else {
            logger.error("Errors while shutting down message sender.");
        }
    }
}
