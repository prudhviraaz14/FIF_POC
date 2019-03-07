/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/DatabaseClientMessageReceiver.java-arc   1.18   Feb 12 2008 13:49:46   makuier  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/DatabaseClientMessageReceiver.java-arc  $
 * 
 *    Rev 1.18   Feb 12 2008 13:49:46   makuier
 * Do not raise any error if the result row is already processed.
 * 
 *    Rev 1.17   Aug 20 2007 12:55:10   schwarje
 * IT-19036: added parameters for populating OMTSOrderId
 * 
 *    Rev 1.16   Apr 25 2007 14:32:02   schwarje
 * IT-19232: support for transaction lists
 * 
 *    Rev 1.15   Apr 19 2007 17:14:44   schwarje
 * IT-19232: support for transaction lists in database clients
 * 
 *    Rev 1.14   Jan 24 2007 17:30:14   schwarje
 * SPN-FIF-000050997: catch exceptions during initialisation of clients without new parameters
 * 
 *    Rev 1.13   Jan 17 2007 17:46:12   makuier
 * Addedd new transaction states for cancelation and postponement.
 * SPN-FIF-000046682
 * 
 *    Rev 1.12   Jun 23 2005 13:30:04   goethalo
 * SPN-CCB-000032065: Moved database transaction commit and MQ message acknowledgement together.
 * 
 *    Rev 1.11   Aug 25 2004 13:32:28   goethalo
 * SPN-FIF-000024999: Fixed extraction of action_name tag.
 * 
 *    Rev 1.10   Aug 02 2004 15:26:14   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.9   Jun 14 2004 15:42:56   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.8   May 18 2004 17:03:52   goethalo
 * IT-8410: Improved support for parameter lists in database clients.
 * 
 *    Rev 1.7   Jan 08 2004 14:56:18   goethalo
 * IT-12156: Added support for not using newline characters when printing the result.
 * 
 *    Rev 1.6   Oct 24 2003 13:41:18   goethalo
 * Made result parameter support optional.
 * 
 *    Rev 1.5   Oct 07 2003 14:50:42   goethalo
 * Changes for IT-9811 - Internet By Call with Registration
 * 
 *    Rev 1.4   Sep 10 2003 12:36:30   goethalo
 * Additional changes for IT-10800.
 * 
 *    Rev 1.3   Sep 09 2003 16:34:56   goethalo
 * IT-10800: support for warnings and parameter lists in DB clients.
 * 
 *    Rev 1.2   Jul 16 2003 14:55:20   goethalo
 * Changes for IT-9750.
 * 
 *    Rev 1.1   Apr 14 2003 15:51:08   goethalo
 * Turned off autocommit and enabled manual commits.
 *
 *    Rev 1.0   Apr 09 2003 09:34:28   goethalo
 * Initial revision.
*/
package net.arcor.fif.client;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.messagecreator.FIFCommandResult;
import net.arcor.fif.messagecreator.FIFError;
import net.arcor.fif.messagecreator.FIFMessage;
import net.arcor.fif.messagecreator.FIFReplyListMessage;
import net.arcor.fif.messagecreator.FIFReplyMessage;
import net.arcor.fif.messagecreator.FIFTransactionListResult;
import net.arcor.fif.messagecreator.FIFTransactionResult;
import net.arcor.fif.messagecreator.MessageReceiver;
import net.arcor.fif.messagecreator.OutputParameter;

import org.apache.log4j.Logger;

/**
 * This class is responsible for receiving the reply messages from FIF.
 * It reads the success status of the messages and updates the state of
 * the requests appropriately in the request table.
 *
 * @author goethalo
 */
public class DatabaseClientMessageReceiver implements Runnable {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger =
        Logger.getLogger(DatabaseClientMessageReceiver.class);

    /**
     * The connection to use for the database.
     */
    private Connection conn = null;

    /**
     * The maximum size of the error message in the database.
     */
    private int failureMaxErrorSize = 0;

    /**
     * The prepared statement for updating the request state to 'Complete'
     */
    private PreparedStatement finishedRequestUpdateStmt = null;

    /**
     * The field index of the transaction ID in the completed statement.
     */
    private int finishedRequestUpdateTransactionIDIndex = 0;

    /**
     * The field index of the error message in the completed statement.
     */
    private int finishedRequestUpdateErrorMessageIndex = 0;

    /**
     * The field index of the error message in the completed statement.
     */
    private int finishedRequestUpdateStatusIndex = 0;

    /**
     * The prepared statement for updating the request state to 'CANCELED'
     */
    private PreparedStatement postponementUpdateStmt = null;

    /**
     * The field index of the transaction ID in the cancelation statement.
     */
    private int postponementTransactionIDIndex = 0;

    /**
     * The prepared statement for updating the request state to 'Failure'
     */    
    private PreparedStatement updateTransactionListStmt = null;

    /**
     * The field index of the transaction ID in the failure statement.
     */
    private int updateTransactionListTransactionListIDIndex = 0;

    /**
     * The maximum size of the error message in the database.
     */
    private int updateTransactionListListStatusIndex = 0;

    /**
     * The prepared statement for inserting the return parameters.
     */
    private PreparedStatement returnParamInsertStmt = null;

    /**
     * The field index of the transaction ID in the return parameter statement.
     */
    private int returnTransactionIDIndex = 0;

    /**
     * The field index of the parameter name in the return parameter statement.
     */
    private int returnParamNameIndex = 0;

    /**
     * The field index of the parameter value in the return parameter 
     * statement.
     */
    private int returnParamValueIndex = 0;

    /**
     * The list name used for wrapped single requests
     */
    private String artificialListName = null;

    /**
     * The message receiver.
     */
    private MessageReceiver receiver = null;

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Initializes the message sender.
     */
    protected synchronized void init() throws FIFException {
        logger.info("Initializing message receiver...");
        try {
            // Create the prepared statements
            logger.info("Preparing database statements...");
            conn = DriverManager.getConnection(DatabaseClientConfig.dbAlias);
            conn.setAutoCommit(false);

            logger.info(
                    "Preparing UpdateFinishedRequestStatement: "
                        + DatabaseClientConfig.getSetting(
                            "databaseclient.UpdateFinishedRequestStatement"));
            finishedRequestUpdateStmt =
                conn.prepareStatement(
                    DatabaseClientConfig.getSetting(
                        "databaseclient.UpdateFinishedRequestStatement"));

            
            try {
            	logger.info(
                    "Preparing UpdateDuedateStatement: "
                       + DatabaseClientConfig.getSetting(
                             "databaseclient.UpdateDuedateStatement"));
            	postponementUpdateStmt =
                    conn.prepareStatement(
                        DatabaseClientConfig.getSetting(
                            "databaseclient.UpdateDuedateStatement"));
            } catch (FIFException fe) {
                // Ignore, statement is not provided.
            }

            // Only prepare result param insert statement if it is provided in
            // to configuration file.  This is needed for backwards compatibility
            boolean resultParamStatementProvided = false;

            try {
                DatabaseClientConfig.getSetting(
                    "databaseclient.InsertRequestResultParams");
                resultParamStatementProvided = true;
            } catch (FIFException fe) {
                // Ignore, statement is not provided.
            }
            if (resultParamStatementProvided) {
                logger.info(
                    "Preparing InsertRequestResultParams: "
                        + DatabaseClientConfig.getSetting(
                            "databaseclient.InsertRequestResultParams"));
                returnParamInsertStmt =
                    conn.prepareStatement(
                        DatabaseClientConfig.getSetting(
                            "databaseclient.InsertRequestResultParams"));
                returnTransactionIDIndex =
                    DatabaseClientConfig.getInt(
                        "databaseClient.InsertRequestResultParams.TransactionIDIndex");
                returnParamNameIndex =
                    DatabaseClientConfig.getInt(
                        "databaseClient.InsertRequestResultParams.ReturnParamNameIndex");
                returnParamValueIndex =
                    DatabaseClientConfig.getInt(
                        "databaseClient.InsertRequestResultParams.ReturnParamValueIndex");
            }
            
            if (DatabaseClient.transactionListSupported)
            {
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
            }
            
        } catch (SQLException e) {
            throw new FIFException(
                "Error while initializing message receiver",
                e);
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

        try {
			postponementTransactionIDIndex =
			    DatabaseClientConfig.getInt(
			        "databaseclient.UpdateDuedateStatement."
			            + "TransactionIDIndex");
		} catch (FIFException e) {
			// ignore if not provided
		}

        try {
			artificialListName = DatabaseClientConfig.getSetting("databaseclient.ArtificialListName");
		} catch (FIFException e) {
		}

        // Message Receiver setup
        receiver = new MessageReceiver("receivequeue");
        receiver.start();

        logger.info("Successfully initialized message receiver.");
    }

    /**
     * Starts to process the responses from the queue.
     * @see java.lang.Runnable#run()
     */
    public void run() {
        try {
            boolean timedOut = false;
            while (!(Thread.interrupted())
                && !(DatabaseClient.inErrorStatus())) {
                if (!timedOut) {
                    logger.info("Waiting for response message...");
                }
                // Read the FIF reply message
                FIFMessage msg = (FIFMessage) receiver.receiveMessage(1);

                // Start at the beginning of the loop again if we
                // timed out
                if (msg == null) {
                    timedOut = true;
                    continue;
                }

                // We did not time out. Remember that
                timedOut = false;

                // Process the message.
                processReply(msg);
            }
        } catch (Exception e) {
            if (DatabaseClient.isShutDownHookInvoked() == false) {
                logger.error("Caught fatal exception in message receiver", e);
            }
            DatabaseClient.setErrorStatus();
        }
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
           	outputFileName = writeInvalidReplyToFile(msg);

            // Bail out if we could not extract the transaction ID
            if (transactionID == null) {
            	// Commit the message
            	return;
            }
        } else {
            // Write the received message to an output file, if needed
        	if (!isInList)
        		writeReplyToFile(msg);
        }

        logger.debug("Processing reply for transaction id: " + transactionID + ".");

        try {
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

            // Get the results in string format
            logger.debug("Retrieving the results.");
            String results = "";
            if (msg.getResult().getResults().size() > 0) {
                results = msg.getResult().toString(false);
            }
            if (results.length() > failureMaxErrorSize) {
                results = results.substring(0, failureMaxErrorSize);
            }
            
            if (msg.getResult().getResult() == FIFTransactionResult.SUCCESS) {
            	logger.debug("Handling the success...");
                handleSuccess(msg, results);
            } else if (msg.getResult().getResult() == FIFTransactionResult.CANCELED) {
            	logger.debug("Handling the cancelation...");
                handleCancelation(msg, results);
            } else if (msg.getResult().getResult() == FIFTransactionResult.POSTPONED) {
            	logger.debug("Handling the postponement...");
                handlePostponement(msg, results);
            } else if (msg.getResult().getResult() == FIFTransactionResult.NOT_EXECUTED) {
            	logger.debug("Handling the not executed requests...");
                handleNotExecuted(msg);
            } else {
            	logger.debug("Handling the failure...");
                handleFailure(msg, results);
            }

            logger.debug("Successfully processed reply for transaction id: " + transactionID + ".");
        } catch (SQLException e) {
            throw new FIFException(
                "SQL exception while processing message: "
                    + msg.getMessage() + ". Transaction id: " + transactionID, e);
        }
    }

	/**
     * Handles a not executed transaction.
     * @param msg               the message of containing the transaction response.
     * @throws SQLException
     */
    private void handleNotExecuted(FIFReplyMessage msg) 
        throws SQLException, FIFException {
    	logger.debug("Updating the request row data...");
    	updateTransactionStatus(msg.getTransactionID(), DatabaseClient.requestStatusNotExecuted, null);
        
        if (msg.isValid()) {
            logger.info("Request for transaction id " + msg.getTransactionID() + " was not executed due to an earlier error.");
        }
	}

	/**
     * Handles a postponed transaction.
     * @param msg               the message of containing the transaction response.
     * @param results           the string containing the results.
     * @throws SQLException
     */
    private void handlePostponement(FIFReplyMessage msg, String results) 
        throws SQLException, FIFException {
        // The processing canceled, update the table
    	logger.debug("Updating the request row data...");
    	postponementUpdateStmt.clearParameters();
    	postponementUpdateStmt.setString(
    			postponementTransactionIDIndex,
            msg.getTransactionID());
        int rows = postponementUpdateStmt.executeUpdate();
        if (rows == 0) {
            logger.warn(
                "Could not postpone the duedate for transaction ID: "
                    + msg.getTransactionID());
        }
        
        if (msg.isValid()) {
            logger.info("Request for transaction id " + msg.getTransactionID() + " postponed.");
            if (msg.hasWarnings())
            	logger.info("Reported warnings:\n" + results);
        }
		
	}

	/**
     * Handles a failed transaction.
     * @param msg               the message of containing the transaction response.
     * @param results           the string containing the results.
     * @throws SQLException
     */
	private void handleCancelation(FIFReplyMessage msg, String results)  
        throws SQLException, FIFException {
        // The processing canceled, update the table		
    	logger.debug("Updating the request row data...");
    	updateTransactionStatus(msg.getTransactionID(), DatabaseClient.requestStatusCanceled, 
    			"This transaction is canceled due to the cancellation of the parent transaction.");
    	
        if (msg.isValid()) {
            logger.info("Request for transaction id " + msg.getTransactionID() + " canceled.");
            if (msg.hasWarnings())
            	logger.info("Reported warnings:\n" + results);
        }
		
	}

	/**
     * Handles a failed transaction.
     * @param msg               the message of containing the transaction response.
     * @param results           the string containing the results.
     * @throws SQLException
     */
    private void handleFailure(FIFReplyMessage msg, String results)
        throws SQLException, FIFException {
        // The processing failed, update the table
    	logger.debug("Updating the request row data...");
    	updateTransactionStatus(msg.getTransactionID(), DatabaseClient.requestStatusFailed, results);
    	
        if (msg.isValid()) {
            logger.info("Request for transaction id " + msg.getTransactionID() + " failed.");
            logger.info("Error messages:\n" + results);
        }
    }

    /**
     * Handles a successfull transaction.
     * @param msg               the message of containing the transaction response.
     * @param results           the string containing the results.
     * @throws SQLException
     */
    private void handleSuccess(FIFReplyMessage msg, String results)
        throws SQLException, FIFException {
        // Populate the output parameters, if the statement has been provided
        if (returnParamInsertStmt != null) {
            Iterator iter = msg.getOutputParameters().iterator();
            while (iter.hasNext()) {
                OutputParameter param = (OutputParameter) iter.next();
                returnParamInsertStmt.clearParameters();
                returnParamInsertStmt.setString(returnTransactionIDIndex, msg.getTransactionID());
                returnParamInsertStmt.setString(returnParamNameIndex, param.getName());
                returnParamInsertStmt.setString(returnParamValueIndex, param.getValue());
                try {
					returnParamInsertStmt.executeUpdate();
				} catch (SQLException e) {
					// ignore the unique constraint
					if (e.getErrorCode() != 1)
						throw e;
					logger.warn("The transaction "+ msg.getTransactionID() +" is already processed.");
				}
            }
        }

        // The processing was successfull, update the table
        // Update the state in the DB
    	logger.debug("Updating the request row data...");
    	if (msg.hasWarnings()) {
    		updateTransactionStatus(msg.getTransactionID(), DatabaseClient.requestStatusCompleted, results);
    		logger.info("Request for transaction id " + msg.getTransactionID() + " succeeded.");
    	}
    	else {
    		updateTransactionStatus(msg.getTransactionID(), DatabaseClient.requestStatusCompleted, null);
            logger.info("Request for transaction id " + msg.getTransactionID() 
            		+ " succeeded.  Reported warnings:\n" + results);
    	}
    }

    /**
     * Writes the received message to an output file.
     * The message is only written to the output file if the
     * <code>databaseclient.WriteReplyMessages</code> flag in the configuration
     * file is set to <code>TRUE</code>.
     * The message is written to the directory specified by the
     * <code>databaseclient.ReplyOutputDir</code> setting in the configuration
     * file.
     * @param msg  the message to write to the output file
     * @throws FIFException
     */
    private void writeReplyToFile(FIFReplyMessage msg) throws FIFException {
        // Bail out if the message should not be written to a output file
        if (!DatabaseClientConfig
            .getBoolean("databaseclient.WriteReplyMessages")) {
            return;
        }

        String fileName =
            FileUtils.writeToOutputFile(
                msg.getFormattedXMLMessage(),
                DatabaseClientConfig.getPath("databaseclient.ReplyOutputDir"),
                "reply-" + msg.getTransactionID(),
                ".xml",
                false);

        logger.info("Wrote reply contents to: " + fileName);
    }

    /**
     * Writes the received message list to an output file.
     * The message is only written to the output file if the
     * <code>databaseclient.WriteReplyMessages</code> flag in the configuration
     * file is set to <code>TRUE</code>.
     * The message is written to the directory specified by the
     * <code>databaseclient.ReplyOutputDir</code> setting in the configuration
     * file.
     * @param msg  the message to write to the output file
     * @throws FIFException if the file could not be written.
     */
    private void writeReplyToFile(FIFReplyListMessage msg)
        throws FIFException {
        // Bail out if the message should not be written to a output file
        if (!DatabaseClientConfig.getBoolean("databaseclient.WriteReplyMessages")) {
            return;
        }

        String fileName =
            FileUtils.writeToOutputFile(
                msg.getFormattedXMLMessage(),
                DatabaseClientConfig.getPath("databaseclient.ReplyOutputDir"),
                "reply-list-" + msg.getListName() + "-" + msg.getTransactionListID(), ".xml", false);

        logger.debug("Wrote reply contents to: " + fileName);
    }

    /**
     * Writes the received invalid message to an output file.
     * The message is written to the directory specified by the
     * <code>databaseclient.InvalidReplyOutputDir</code> setting
     * in the configuration file.
     * @param msg  the message to write to the output file
     * @throws FIFException
     */
    private String writeInvalidReplyToFile(FIFReplyMessage msg)
        throws FIFException {
        String fileName = null;
        if (msg.getTransactionID() != null) {
            fileName =
                FileUtils.writeToOutputFile(
                    msg.getFormattedXMLMessage(),
                    DatabaseClientConfig.getPath(
                        "databaseclient.InvalidReplyOutputDir"),
                    "invalid-reply-" + msg.getTransactionID(),
                    ".xml",
                    false);
        } else {
            fileName =
                FileUtils.writeToOutputFile(
                    msg.getFormattedXMLMessage(),
                    DatabaseClientConfig.getPath(
                        "databaseclient.InvalidReplyOutputDir"),
                    "invalid-reply-unknown-transaction-id",
                    ".xml",
                    false);
        }

        logger.info("Wrote invalid reply contents to: " + fileName);
        return fileName;
    }

    /**
     * Writes the received invalid list message to an output file.
     * The message is written to the directory specified by the
     * <code>databaseclient.InvalidReplyOutputDir</code> setting
     * in the configuration file.
     * @param msg  the message to write to the output file
     * @throws FIFException if the file could not be written.
     */
    private String writeInvalidReplyToFile(FIFReplyListMessage msg)
        throws FIFException {
        String fileName = null;
        if (msg.getTransactionListID() != null) {
            fileName =
                FileUtils.writeToOutputFile(
                    msg.getFormattedXMLMessage(),
                    DatabaseClientConfig.getPath(
                        "databaseclient.InvalidReplyOutputDir"),
                    "invalid-reply-list-" + msg.getTransactionListID(),
                    ".xml",
                    false);
        } else {
            fileName =
                FileUtils.writeToOutputFile(
                    msg.getFormattedXMLMessage(),
                    DatabaseClientConfig.getPath(
                        "databaseclient.InvalidReplyOutputDir"),
                    "invalid-reply-unknown-transaction-list-id",
                    ".xml",
                    false);
        }

        logger.debug("Wrote invalid reply list contents to: " + fileName);
        return fileName;
    }

    /**
     * Processes a FIF reply Message.
     * Reads the response status of the message and sends a response
     * message to the requesting application.
     * @param msg   the FIF reply message to process.  This must be either a
     *              <code>FIFReplyMessage</code> or 
     *              <code>FIFReplyListMessage</code> object.
     * @throws FIFException if the message could not be processed.
     */
    public void processReply(FIFMessage msg) throws FIFException, SQLException {
        // Check the reply type
        if (msg instanceof FIFReplyMessage) {
            processSimpleReply((FIFReplyMessage) msg, false);
            ((FIFReplyMessage)msg).acknowledge();
            conn.commit();
        } else if (msg instanceof FIFReplyListMessage) {
            processListReply((FIFReplyListMessage) msg);
            ((FIFReplyListMessage)msg).acknowledge();
            conn.commit();
        } else {
            throw new FIFException(
                "Reply message is of unknown type: "
                    + msg.getClass().getName());
        }
    }    

    /**
     * Processes a FIF Reply List Message.
     * Reads the response status of the message and sends a response
     * message to the requesting application.
     * @param msg   the <code>FIFReplyListMessage</code> to process.
     * @throws FIFException if the message could not be processed.
     */
    private void processListReply(FIFReplyListMessage msg)
        throws FIFException, SQLException {
        // Get the list ID - this will also parse the reply
        String listID = msg.getTransactionListID();
        boolean isArtificialList = msg.getListName().equals(artificialListName);

        // Check if we got a transaction ID
        if (!msg.isValid() || listID == null || listID.length() == 0) {
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
            writeInvalidReplyToFile(msg);

            // Bail out if we could not extract the transaction ID
            if (listID == null) {
                return;
            }
        } else {
            // Write the received message to an output file, if needed
            writeReplyToFile(msg);
        }

        logger.debug(
            "Processing FIF reply for transaction list ID: " + listID + ".");

        // get the result from the whole xml to loop over the single replies
        FIFTransactionListResult result = msg.getResult();

        // loop through the reply list
        Iterator replyIterator = result.getReplies().listIterator();
        while (replyIterator.hasNext()) {
        	FIFReplyMessage reply = (FIFReplyMessage) replyIterator.next();
        	// handle each single reply as standalone reply 
        	processSimpleReply(reply, true);
        }

        // update the list status
        if (result.getResult() == FIFTransactionListResult.SUCCESS) {
        	if (!isArtificialList)
        		updateTransactionListStatus (listID, DatabaseClient.requestStatusCompleted);
            logger.info("Request list with for list ID " + listID + " succeeded.");
        } else {
        	if (!isArtificialList)
        		updateTransactionListStatus (listID, DatabaseClient.requestStatusFailed);
            logger.info("Request list with list ID " + listID + " failed.");
            logger.info("Error messages:\n" + result.toString());
        }

        logger.debug("Successfully processed reply for transaction list id: " + listID + ".");
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
		// Truncate the error message if it is too long
		if (error == null)
			error = "";
		else if (error.length() > failureMaxErrorSize) 
			error = error.substring(0, failureMaxErrorSize);
		finishedRequestUpdateStmt.clearParameters();
		finishedRequestUpdateStmt.setString(finishedRequestUpdateTransactionIDIndex, id);
        if (DatabaseClient.requestStatusDataType.equals(DatabaseClient.requestStatusDataTypeVarchar))
    		finishedRequestUpdateStmt.setString(finishedRequestUpdateStatusIndex, status);
        if (DatabaseClient.requestStatusDataType.equals(DatabaseClient.requestStatusDataTypeNumber))
    		finishedRequestUpdateStmt.setLong(finishedRequestUpdateStatusIndex, Long.parseLong(status));
		finishedRequestUpdateStmt.setString(finishedRequestUpdateErrorMessageIndex, error);
		if (finishedRequestUpdateStmt.executeUpdate() == 0)
			logger.warn("Could not update status to '" + status + "' for transaction ID: " + id);
	}
    
    /**
	 * Shuts down the object.
	 */
    protected synchronized void shutdown() {
        logger.info("Shutting down message receiver...");
        boolean success = true;
        try {
            if (returnParamInsertStmt != null) {
                returnParamInsertStmt.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close statement.", e);
        }
        try {
            if (postponementUpdateStmt != null) {
                postponementUpdateStmt.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close statement.", e);
        }
        try {
            if (updateTransactionListStmt != null) {
            	updateTransactionListStmt.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close statement.", e);
        }
        try {
            if (finishedRequestUpdateStmt != null) {
            	finishedRequestUpdateStmt.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close statement.", e);
        }
        try {
            if (conn != null) {
                conn.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close connection.", e);
        }
        try {
            if (receiver != null) {
                receiver.shutdown();
            }
        } catch (FIFException e1) {
            logger.error("Cannot shutdown message receiver.");
        }

        if (success) {
            logger.info("Successfully shut down message receiver.");
        } else {
            logger.error("Errors while shutting down message receiver.");
        }
    }
}
