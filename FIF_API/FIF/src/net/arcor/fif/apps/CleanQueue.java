package net.arcor.fif.apps;

import javax.jms.Message;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.Log4jConfig;
import net.arcor.fif.transport.MessageReceiver;
import net.arcor.fif.transport.TransportManager;

import org.apache.log4j.Logger;

/**
 * This application cleans a queue.
 * <p><b>Usage:</b><p>
 * <code>java net.arcor.fif.apps.CleanQueue <i>queueAlias</i></code>
 * <p>Where <i>queuename</i> is the alias name of the queue to put the message in.
 * <p><b>Property file</b><p>
 * The property file is defaulted to CleanQueue.
 * The <code>fif.propertyfile</code> system property can be set to another property
 * file if needed.
 *  
 * @author goethalo
 */
public class CleanQueue {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(SendMessage.class);

    /**
     * Initializes the application.
     * @throws FIFException
     */
    private static void init(String configFile) throws FIFException {
        // Initialize the logger
        Log4jConfig.init(configFile);

        logger.info(
            "Initializing application with property file "
                + configFile
                + "...");

        // Initialize the transport manager if the message should be sent
        TransportManager.init(configFile);

        logger.info("Successfully initialized application.");
    }

    /**
     * Shuts down the application.
     * @throws FIFException
     */
    private static void shutdown() {
        boolean success = true;
        logger.info("Shutting down application...");
        try {
            // Shut down the transport manager if needed
            TransportManager.shutdown();
        } catch (Exception e) {
            success = false;
            logger.error("Cannot shutdown transport manager", e);
        }

        if (success) {
            logger.info("Successfully shut down application.");
        } else {
            logger.error("Errors while shutting down application.");
        }
    }

    public static void main(String[] args) {
        if (args.length < 1) {
            System.err.println("CleanQueue: Cleans a queue.");
            System.err.println("\nUsage: CleanQueue queueAlias");
            System.err.println(
                "Where queueAlias is the alias name of the queue to clean.");
            System.exit(0);
        }

        String queue = args[0];

        // Set the config file name
        String configFile = "CleanQueue.properties";
        if (System.getProperty("fif.propertyfile") != null) {
            configFile = System.getProperty("fif.propertyfile");
        }

        try {
            // Initialize the application
            init(configFile);

            // Clean the queue
            MessageReceiver receiver = TransportManager.createReceiver(queue);
            receiver.start();
            int msgCount = 0;

            logger.info(
                "Cleaning queue "
                    + queue
                    + " ("
                    + receiver.getJmsClient().getQueueName()
                    + ")...");

            Message msg = null;
            do {
                msg = receiver.receiveMessageNoWait();
                if (msg != null) {
                    msgCount++;
                }
            } while (msg != null);

            receiver.shutdown();

            logger.info("Cleaned " + msgCount + " messages from queue.");
        } catch (FIFException e) {
            logger.fatal("Cannot send message.", e);
            e.printStackTrace();
        } finally {
            shutdown();
        }
    }
}
