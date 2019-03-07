/*
 * $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/client/QueueClientMessageReceiver.java-arc   1.3   Aug 02 2004 15:26:14   goethalo  $
 *
 * $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/client/QueueClientMessageReceiver.java-arc  $
 * 
 *    Rev 1.3   Aug 02 2004 15:26:14   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.2   Jun 14 2004 15:43:02   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 */
package net.arcor.fif.client;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.messagecreator.FIFMessage;
import net.arcor.fif.messagecreator.FIFReplyListMessage;
import net.arcor.fif.messagecreator.FIFReplyMessage;
import net.arcor.fif.messagecreator.MessageReceiver;
import net.arcor.fif.transport.TransportManager;

import org.apache.log4j.Logger;

/**
 * This class is responsible for receiving the reply messages from FIF.
 * It reads the success status of the messages and sends the appropriate
 * response message in the response queue of the requesting application.
 *
 * @author goethalo 
 */
public class QueueClientMessageReceiver implements Runnable {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger =
        Logger.getLogger(QueueClientMessageSender.class);

    /**
     * The client response sender.
     */
    private net.arcor.fif.transport.MessageSender clientResponseSender = null;

    /**
     * The FIF message receiver.
     */
    private net.arcor.fif.messagecreator.MessageReceiver FIFMessageReceiver =
        null;

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Initializes the message sender.
     */
    protected synchronized void init() throws FIFException {
        logger.info("Initializing QueueClientMessageReceiver...");

        // Client Response Sender setup
        logger.debug("Initializing client response sender...");
        clientResponseSender =
            TransportManager.createSender("ClientResponseQueue");
        clientResponseSender.start();
        logger.debug("Successfully initialized client response sender.");

        // FIF Message Receiver setup
        logger.debug("Initializing FIF message receiver...");
        FIFMessageReceiver = new MessageReceiver("FIFReplyQueue");
        FIFMessageReceiver.start();
        logger.debug("Successfully initialized FIF message receiver.");

        logger.info("Successfully initialized QueueClientMessageReceiver.");
    }

    /**
     * Starts to process the responses from the queue.
     * @see java.lang.Runnable#run()
     */
    public void run() {
        try {
            boolean timedOut = false;
            while (!(Thread.interrupted()) && !(QueueClient.inErrorStatus())) {
                if (!timedOut) {
                    logger.info("Waiting for response message...");
                }
                // Read the FIF reply message
                FIFMessage msg =
                    (FIFMessage) FIFMessageReceiver.receiveMessage(1);

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
            if (QueueClient.isShutDownHookInvoked() == false) {
                logger.fatal("Caught exception in message receiver", e);
            }
            QueueClient.setErrorStatus();
        }
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
    public void processReply(FIFMessage msg) throws FIFException {
        // Check the reply type
        if (msg instanceof FIFReplyMessage) {
            processSimpleReply((FIFReplyMessage) msg);
            ((FIFReplyMessage)msg).acknowledge();
        } else if (msg instanceof FIFReplyListMessage) {
            processListReply((FIFReplyListMessage) msg);
            ((FIFReplyListMessage)msg).acknowledge();            
        } else {
            throw new FIFException(
                "Reply message is of unknown type: "
                    + msg.getClass().getName());
        }
    }

    /**
     * Processes a Simple FIF reply Message.
     * Reads the response status of the message and sends a response
     * message to the requesting application.
     * @param msg   the <code>FIFReplyMessage</code> to process.
     * @throws FIFException if the message could not be processed.
     */
    private void processSimpleReply(FIFReplyMessage msg) throws FIFException {
        // Get the transaction ID - this will also parse the reply
        String transactionID = msg.getTransactionID();

        // Check if we got a transaction ID
        String outputFileName = null;
        if ((!msg.isValid())
            || (transactionID == null)
            || (transactionID.length() == 0)) {
            // We did not get a transaction ID and the message
            // is invalid.  This means that FIF gave us 'crap'.
            // We have to log this as an error and put this invalid
            // message in a special directory.

            // Log an error
            String error = "Received invalid reply message from FIF";
            if (transactionID != null) {
                error += " for transaction ID " + transactionID;
            }
            error += ".";
            logger.error(error);
            logger.error("Error messages:\n" + msg.getResult().toString());

            // Write the invalid reply
            outputFileName = writeInvalidReplyToFile(msg);

            // Bail out if we could not extract the transaction ID
            if (transactionID == null) {
                return;
            }
        } else {
            // Write the received message to an output file, if needed
            writeReplyToFile(msg);
        }

        logger.debug(
            "Processing FIF reply for transaction id: " + transactionID + ".");

        // Add an additional error message to the results
        QueueClientResponseMessage response =
            new QueueClientResponseMessage(msg);

        // Send the response to the requesting application
        clientResponseSender.sendMessage(response.getMessage());

        // Write the sent response, if needed
        writeResponseMessage(response);

        // Log the response status         
        if (response.getStatus() == QueueClientResponseMessage.SUCCESS) {
            // Log the success
            logger.info(
                "Request for transaction id " + transactionID + " succeeded.");
        } else {
            // Log the failure
            logger.info(
                "Request for transaction id " + transactionID + " failed.");
            logger.info("Error messages:\n" + msg.getResult().toString());
        }

        logger.debug(
            "Successfully processed reply for transaction id: "
                + transactionID
                + ".");
    }

    /**
     * Processes a FIF Reply List Message.
     * Reads the response status of the message and sends a response
     * message to the requesting application.
     * @param msg   the <code>FIFReplyListMessage</code> to process.
     * @throws FIFException if the message could not be processed.
     */
    private void processListReply(FIFReplyListMessage msg)
        throws FIFException {
        // Get the list ID - this will also parse the reply
        String listID = msg.getTransactionListID();

        // Check if we got a transaction ID
        String outputFileName = null;
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
            outputFileName = writeInvalidReplyToFile(msg);

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

        // Add an additional error message to the results
        QueueClientResponseListMessage response =
            new QueueClientResponseListMessage(msg);

        // Send the response to the requesting application
        clientResponseSender.sendMessage(response.getMessage());

        // Write the sent response, if needed
        writeResponseMessage(response);

        // Log the response status         
        if (response.getStatus() == QueueClientResponseListMessage.SUCCESS) {
            // Log the success
            logger.info(
                "Request list with for list ID " + listID + " succeeded.");
        } else {
            // Log the failure
            logger.info("Request list with list ID " + listID + " failed.");
            logger.info("Error messages:\n" + msg.getResult().toString());
        }

        logger.debug(
            "Successfully processed reply for transaction list id: " + listID + ".");
    }

    /**
     * Writes the received message to an output file.
     * The message is only written to the output file if the
     * <code>queueclient.WriteReplyMessages</code> flag in the configuration
     * file is set to <code>TRUE</code>.
     * The message is written to the directory specified by the
     * <code>queueclient.ReplyOutputDir</code> setting in the configuration
     * file.
     * @param msg  the message to write to the output file
     * @throws FIFException if the file could not be written.
     */
    private void writeReplyToFile(FIFReplyMessage msg) throws FIFException {
        // Bail out if the message should not be written to a output file
        if (!QueueClientConfig.getBoolean("queueclient.WriteReplyMessages")) {
            return;
        }

        String fileName =
            FileUtils.writeToOutputFile(
                msg.getFormattedXMLMessage(),
                QueueClientConfig.getPath("queueclient.ReplyOutputDir"),
                "reply-" + msg.getActionName() + "-" + msg.getTransactionID(),
                ".xml",
                false);

        logger.debug("Wrote reply contents to: " + fileName);
    }

    /**
     * Writes the received message list to an output file.
     * The message is only written to the output file if the
     * <code>queueclient.WriteReplyMessages</code> flag in the configuration
     * file is set to <code>TRUE</code>.
     * The message is written to the directory specified by the
     * <code>queueclient.ReplyOutputDir</code> setting in the configuration
     * file.
     * @param msg  the message to write to the output file
     * @throws FIFException if the file could not be written.
     */
    private void writeReplyToFile(FIFReplyListMessage msg)
        throws FIFException {
        // Bail out if the message should not be written to a output file
        if (!QueueClientConfig.getBoolean("queueclient.WriteReplyMessages")) {
            return;
        }

        String fileName =
            FileUtils.writeToOutputFile(
                msg.getFormattedXMLMessage(),
                QueueClientConfig.getPath("queueclient.ReplyOutputDir"),
                "reply-list-"
                    + msg.getListName()
                    + "-"
                    + msg.getTransactionListID(),
                ".xml",
                false);

        logger.debug("Wrote reply contents to: " + fileName);
    }

    /**
     * Writes the received invalid message to an output file.
     * The message is written to the directory specified by the
     * <code>queueclient.InvalidReplyOutputDir</code> setting
     * in the configuration file.
     * @param msg  the message to write to the output file
     * @throws FIFException if the file could not be written.
     */
    private String writeInvalidReplyToFile(FIFReplyMessage msg)
        throws FIFException {
        String fileName = null;
        if (msg.getTransactionID() != null) {
            fileName =
                FileUtils.writeToOutputFile(
                    msg.getFormattedXMLMessage(),
                    QueueClientConfig.getPath(
                        "queueclient.InvalidReplyOutputDir"),
                    "invalid-reply-" + msg.getTransactionID(),
                    ".xml",
                    false);
        } else {
            fileName =
                FileUtils.writeToOutputFile(
                    msg.getFormattedXMLMessage(),
                    QueueClientConfig.getPath(
                        "queueclient.InvalidReplyOutputDir"),
                    "invalid-reply-unknown-transaction-id",
                    ".xml",
                    false);
        }

        logger.debug("Wrote invalid reply contents to: " + fileName);
        return fileName;
    }

    /**
     * Writes the received invalid list message to an output file.
     * The message is written to the directory specified by the
     * <code>queueclient.InvalidReplyOutputDir</code> setting
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
                    QueueClientConfig.getPath(
                        "queueclient.InvalidReplyOutputDir"),
                    "invalid-reply-list-" + msg.getTransactionListID(),
                    ".xml",
                    false);
        } else {
            fileName =
                FileUtils.writeToOutputFile(
                    msg.getFormattedXMLMessage(),
                    QueueClientConfig.getPath(
                        "queueclient.InvalidReplyOutputDir"),
                    "invalid-reply-unknown-transaction-list-id",
                    ".xml",
                    false);
        }

        logger.debug("Wrote invalid reply list contents to: " + fileName);
        return fileName;
    }

    /**
     * Writes a sent KBA response message to an output file.
     * The message is only written to the directory if the
     * <code>queueclient.WriteResponseMessages</code> setting
     * is set to <code>true</code> in the configuration file. 
     * @param response  the message to be written.
     * @throws FIFException if response message could not be written.
     */
    private void writeResponseMessage(QueueClientResponseMessage response)
        throws FIFException {
        // Bail out if the message should not be written to a output file
        if (!QueueClientConfig
            .getBoolean("queueclient.WriteResponseMessages")) {
            return;
        }

        String fileName =
            FileUtils.writeToOutputFile(
                response.getMessage(),
                QueueClientConfig.getPath("queueclient.ResponseOutputDir"),
                "response-"
                    + response.getActionName()
                    + "-"
                    + response.getTransactionID(),
                ".xml",
                false);

        logger.debug("Wrote response message to: " + fileName);
    }

    /**
     * Writes a sent KBA response list message to an output file.
     * The message is only written to the directory if the
     * <code>queueclient.WriteResponseMessages</code> setting
     * is set to <code>true</code> in the configuration file. 
     * @param response  the message to be written.
     * @throws FIFException if response message could not be written.
     */
    private void writeResponseMessage(QueueClientResponseListMessage response)
        throws FIFException {
        // Bail out if the message should not be written to a output file
        if (!QueueClientConfig
            .getBoolean("queueclient.WriteResponseMessages")) {
            return;
        }

        String fileName =
            FileUtils.writeToOutputFile(
                response.getMessage(),
                QueueClientConfig.getPath("queueclient.ResponseOutputDir"),
                "response-list-" + response.getName() + "-" + response.getID(),
                ".xml",
                false);

        logger.debug("Wrote response message to: " + fileName);
    }
    /**
     * Shuts down the object.
     */
    protected synchronized void shutdown() {
        logger.info("Shutting down queue message receiver...");
        boolean success = true;

        try {
            if (clientResponseSender != null) {
                clientResponseSender.shutdown();
                clientResponseSender = null;
            }
        } catch (FIFException e) {
            logger.error("Cannot shutdown client reply sender.");
            success = false;
        }

        try {
            if (FIFMessageReceiver != null) {
                FIFMessageReceiver.shutdown();
                FIFMessageReceiver = null;
            }
        } catch (FIFException e) {
            logger.error("Cannot shutdown FIF message receiver.");
            success = false;
        }

        if (success) {
            logger.info("Successfully shut down queue message receiver.");
        } else {
            logger.error("Errors while shutting down queue message receiver.");
        }
    }

}
