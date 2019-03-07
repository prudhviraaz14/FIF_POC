/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/apps/ReceiveMessage.java-arc   1.1   Mar 02 2004 11:18:36   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/apps/ReceiveMessage.java-arc  $
 * 
 *    Rev 1.1   Mar 02 2004 11:18:36   goethalo
 * SPN-CCB-000020494: Changed way property files are read.  Now the fully qualified property file name must be provided.
 * 
 *    Rev 1.0   Apr 09 2003 09:34:26   goethalo
 * Initial revision.
*/
package net.arcor.fif.apps;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.Log4jConfig;
import net.arcor.fif.messagecreator.Message;
import net.arcor.fif.messagecreator.MessageReceiver;
import net.arcor.fif.transport.TransportManager;

import org.apache.log4j.Logger;

/**
 * This application receives Messages from the queue.
 * It useful to test what is being put in the queue by other applications.
 * <p>
 * <b>Usage:</b><br>
 * <code>java net.arcor.fif.apps.ReceiveMessage <i>[-loop]</i></code>
 * <p>
 * <b>Options:</b><br>
 * <code>-loop</code>   reads all the messages that are being put in the queue.
 * <p>
 * <b>Property file</b><br>
 * The property file is defaulted to ReceiveMessage.<br>
 * The <code>fif.propertyfile</code> system property can be set to another property
 * file if needed.<br>
 * To do this the following syntax can be used for starting the application:<br>
 * <code>java -Dfif.propertyfile=AnotherFile net.arcor.fif.apps.ReceiveMessage
 * <i>[-loop]</i></code>
 * @author goethalo
 */
public class ReceiveMessage {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(ReceiveMessage.class);

    /**
     * Indicates whether all the messages that are being put in the queue should
     * be read.
     */
    private static boolean loop = false;

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Initializes the application.
     * @throws FIFException
     */
    private static void init(String configFile) throws FIFException {
        // Initialize the logger
        Log4jConfig.init(configFile);

        logger.info("Initializing application...");

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

    /**
     * Receives a message from the queue.
     * @param args
     */
    public static void main(String[] args) {
        if (args.length >= 1) {
            if (args[0].trim().equalsIgnoreCase("-loop")) {
                loop = true;
            }
        }

        // Set the config file name
        String configFile = "ReceiveMessage.properties";

        try {
            // Initialize the application
            init(configFile);

            // Create a receiver
            MessageReceiver receiver = new MessageReceiver("inqueue");
            receiver.start();

            do {
                logger.info("Waiting for message...");
                Message msg = receiver.receiveMessage();
                logger.info("Received message:\n" + msg.getMessage());
            } while (loop);

            // Shutdown the receiver
            receiver.shutdown();
        } catch (FIFException fe) {
            logger.fatal("Cannot receive message.", fe);
        } finally {
            shutdown();
        }
    }
}
