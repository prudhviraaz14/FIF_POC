/*
 * $ Header: $
 *
 * $ Log: $
 */
package net.arcor.fif.client;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.messagecreator.Message;
import net.arcor.fif.messagecreator.MessageCreator;
import net.arcor.fif.messagecreator.MessageCreatorFactory;
import net.arcor.fif.messagecreator.MessageSender;
import net.arcor.fif.messagecreator.Request;
import net.arcor.fif.messagecreator.SimpleParameter;

import org.apache.log4j.Logger;

/**
 * Thread responsible for sending messages.
 * @author goethalo
 *
 */
public class DatabaseClientSendingThread extends Thread {

    /*------------------*
      * MEMBER VARIABLES *
      *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger =
        Logger.getLogger(DatabaseClientThreadedSender.class);

    /**
     * The connection to use for the database.
     */
    private Connection conn = null;

    /**
     * The prepared statement for updating the request state to 'In Progress'
     */
    private PreparedStatement inprogressUpdateStmt = null;

    /**
     * The prepared statement for updating the request state to 'Failure'
     */
    private PreparedStatement failureUpdateStmt = null;

    /**
     * The field index of the transaction ID in the failure statement.
     */
    private int failureTransactionIDIndex = 0;

    /**
     * The field index of the error message in the failure statement.
     */
    private int failureErrorMessageIndex = 0;

    /**
     * The maximum size of the error message in the database.
     */
    private int failureMaxErrorSize = 0;

    /**
     * The message sender.
     */
    private MessageSender sender = null;

    /**
     * The status levels.
     */
    public final static int STATUS_NEW = 0;
    public final static int STATUS_INITIALIZED = 1;
    public final static int STATUS_IDLE = 2;
    public final static int STATUS_PROCESSING = 3;
    public final static int STATUS_SHUTTINGDOWN = 5;
    public final static int STATUS_DEAD = 6;

    /**
     * The status of the thread.
     */
    private int status = 0;

    /**
     * The request that is currently being processed.
     */
    private Request currentRequest = null;

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Sets the status.
     */
    private synchronized void setStatus(int status) {
        this.status = status;
    }

    /**
     * Gets the status
     * @return the status.
     */
    public synchronized int getStatus() {
        return status;
    }

    /**
     * Notifies the sending thread to process a request.
     * @param request the request to be processed.
     * @throws FIFException if the request could not be processed.
     */
    public void processRequest(Request request) throws FIFException {
        logger.debug("ProcessRequest called.");
        if (status != STATUS_IDLE) {
            throw new FIFException("Cannot process request because thread is not IDLE");
        }
        this.currentRequest = request;
        setStatus(STATUS_PROCESSING);
    }

    /**
     * Initializes the message sender.
     */
    public void init() throws FIFException {
        logger.info("Initializing message sending thread.");
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

            logger.info(
                "Preparing UpdateStateInProgressStatement: "
                    + DatabaseClientConfig.getSetting(
                        "databaseclient.UpdateStateInProgressStatement"));
            inprogressUpdateStmt =
                conn.prepareStatement(
                    DatabaseClientConfig.getSetting(
                        "databaseclient.UpdateStateInProgressStatement"));

            logger.info(
                "Preparing UpdateStateFailureStatement: "
                    + DatabaseClientConfig.getSetting(
                        "databaseclient.UpdateStateFailureStatement"));
            failureUpdateStmt =
                conn.prepareStatement(
                    DatabaseClientConfig.getSetting(
                        "databaseclient.UpdateStateFailureStatement"));

            logger.info("Successfully prepared database statements.");
        } catch (SQLException e) {
            throw new FIFException(
                "Error while initializing message sending thread.",
                e);
        }

        // Field names
        failureTransactionIDIndex =
            DatabaseClientConfig.getInt(
                "databaseclient.UpdateStateFailureStatement."
                    + "TransactionIDIndex");
        failureErrorMessageIndex =
            DatabaseClientConfig.getInt(
                "databaseclient.UpdateStateFailureStatement."
                    + "ErrorMessageIndex");
        failureMaxErrorSize =
            DatabaseClientConfig.getInt(
                "databaseclient.UpdateStateFailureStatement.MaxErrorMessageSize");

        // Message Sender setup
        sender = new MessageSender("sendqueue");
        sender.start();

        logger.info("Successfully initialized message sending thread.");
        setStatus(STATUS_INITIALIZED);
    }

    /**
     * Starts processing send requests.
     * @see java.lang.Runnable#run()
     */
    public void run() {
        try {
            // Initialize the class
            init();

            setStatus(STATUS_IDLE);

            while (!(Thread.interrupted())
                && !(DatabaseClient.inErrorStatus())) {
                if (getStatus() == STATUS_PROCESSING) {
                    generateAndSendMessage();
                }
                Thread.sleep(1);
            }
        } catch (FIFException fe) {
            logger.fatal("Caught exception.", fe);
            DatabaseClient.setErrorStatus();
        } catch (InterruptedException ie) {
            if (DatabaseClient.isShutDownHookInvoked() == false) {
                logger.fatal("Thread interrupted", ie);
            }
            DatabaseClient.setErrorStatus();
        } catch (SQLException e) {
            // Set the error status on the DatabaseClient object
            if (DatabaseClient.isShutDownHookInvoked() == false) {
                logger.fatal(
                    "Fatal database error while processing requests",
                    e);
            }
            DatabaseClient.setErrorStatus();
        } finally {
            shutdown();
        }
    }

    /**
     * Generates and sends the message for the current request. 
     */
    private void generateAndSendMessage() throws SQLException, FIFException {
        // Start processing the request
        setStatus(STATUS_PROCESSING);
        String action = currentRequest.getAction();
        String transactionId =
            ((SimpleParameter) (currentRequest.getParam("transactionID")))
                .getValue();
        logger.info(
            "Generating and sending message for id: "
                + transactionId
                + ", action: "
                + action
                + "...");

        // Update the status in the database
        inprogressUpdateStmt.clearParameters();
        inprogressUpdateStmt.setString(1, transactionId);
        inprogressUpdateStmt.executeUpdate();
        conn.commit();

        // Get a message creator
        logger.debug("Getting message creator.");
        MessageCreator mc = MessageCreatorFactory.getMessageCreator(action);
        logger.debug("Got message creator.");

        // Create the message
        Message msg = null;
        String error = null;

        try {
            logger.debug("Creating message.");
            msg = mc.createMessage(currentRequest);
            logger.debug("Created message.");
        } catch (FIFException fe) {
            // The creation of the message failed.
            // Populate the error string with an error message.
            StringBuffer sb = new StringBuffer();
            sb.append("Cannot create message for request. ");
            sb.append("Reason: ");
            sb.append(fe.getMessage());
            logger.error("Caught exception.", fe);
            error = sb.toString();
        }
        // Send the message
        if (error == null) {
            sender.sendMessage(msg);
        }

        // Update the state in the DB
        if (error == null) {
            // Write the sent message, if needed.
            writeSentMessage(msg, transactionId, action);

            // Log the success
            logger.info(
                "Successfully generated and sent message for id: "
                    + transactionId
                    + ", action: "
                    + action);
        } else {
            // There was an error, set the failure state
            failureUpdateStmt.clearParameters();
            failureUpdateStmt.setString(
                failureTransactionIDIndex,
                transactionId);
            // Truncate the error message if it is too long
            if (error.length() > failureMaxErrorSize) {
                failureUpdateStmt.setString(
                    failureErrorMessageIndex,
                    error.substring(0, failureMaxErrorSize));
            } else {
                failureUpdateStmt.setString(failureErrorMessageIndex, error);
            }
            failureUpdateStmt.executeUpdate();
            conn.commit();

            // Log the error
            logger.error(error);
        }
        setStatus(STATUS_IDLE);
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
        if (!DatabaseClientConfig
            .getBoolean("databaseclient.WriteSentMessages")) {
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
     * Shuts down the object.
     */
    protected void shutdown() {
        setStatus(STATUS_SHUTTINGDOWN);
        logger.info("Shutting down message sending thread...");
        boolean success = true;
        try {
            if (inprogressUpdateStmt != null) {
                inprogressUpdateStmt.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close statement.", e);
            success = false;
        }
        try {
            if (failureUpdateStmt != null) {
                failureUpdateStmt.close();
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
            logger.info("Successfully shut down message sending thread.");
        } else {
            logger.error("Errors while shutting down message sending thread.");
        }
        setStatus(STATUS_DEAD);
    }

}
