package net.arcor.fif.client;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.Log4jConfig;
import net.arcor.fif.messagecreator.MessageCreatorConfig;
import net.arcor.fif.transport.TransportManager;

import org.apache.log4j.Logger;

/**
 * This class implements a FIF queue client.
 * It reads requests from a queue, creates FIF messages based on the requests,
 * and sends the created messages to FIF.
 * <p>
 * This application needs 4 queues:<br>
 * <li>A queue for reading requests</li>
 * <li>A queue for sending the generated messages to FIF</li>
 * <li>A queue for reading the reply from FIF</li>
 * <li>A queue for sending the transformed reply to the requesting 
 * application</li> 
 * <p>
 * <b>Property file</b><br>
 * The name of the property file used by the application is defaulted to
 * QueueClient.<br>
 * The <code>fif.propertyfile</code> system property can be set to another property
 * file if needed.<br>
 * To do this the following syntax can be used for starting the application:<br>
 * <code>java -Dfif.propertyfile=AnotherFile net.arcor.fif.client.
 * QueueClient</code>
 * @author goethalo
 */
public class QueueClient {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(QueueClient.class);

    /**
     * Indicates whether there is an error status.
     */
    private static boolean errorStatus = false;

    /**
     * Indicates whether the shutdown hook is being invoked.
     */
    private static boolean shutDownHookInvoked = false;

    /**
     * Indicates whether this class is initialzed.
     */
    private static boolean initialized = false;

    /**
     * Object used for locking.
     */
    private static Object lock = new Object();

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Indicates whether the client is in error status.
     * @return the error status
     */
    public static boolean inErrorStatus() {
        synchronized (lock) {
            return errorStatus;
        }
    }

    /**
     * Sets the client in error status.
     */
    protected static void setErrorStatus() {
        synchronized (lock) {
            errorStatus = true;
        }
    }

    /**
     * Indicates whether the shutdown hook is invoked.
     * @return true if invoked, false if not.
     */
    protected static boolean isShutDownHookInvoked() {
        synchronized (lock) {
            return shutDownHookInvoked;
        }
    }

    /**
     * Sets the shutdown hook invocation to true.
     */
    protected static void setShutDownHookInvoked() {
        synchronized (lock) {
            shutDownHookInvoked = true;
        }
    }

    /**
     * Determines whether this class is initialized.
     * @return true if initialize, false if not.
     */
    protected static boolean isInitialized() {
        return initialized;
    }

    /**
     * Initializes the application.
     * @param configFile  the name of the property file to get the settings from.
     * @throws FIFException if the application could not be initialized.
     */
    public static synchronized void init(String configFile)
        throws FIFException {
        // Bail out if the client was initialized already
        if (initialized == true) {
            return;
        }

        // Set the initialized flag
        initialized = true;

        // Initialize the queue client config
        QueueClientConfig.init(configFile);

        // Initialize the logger
        Log4jConfig.init(configFile);

        logger.info(
            "Initializing QueueClient application with property file "
                + configFile
                + "...");

        // Initialize the message creator
        MessageCreatorConfig.init(configFile);

        // Initialize the transport manager
        TransportManager.init(configFile);

        // Initialize the error mapping
        ErrorMapping.init(configFile);

        logger.info("Successfully initialized QueueClient application.");
    }

    /**
     * Shuts down the <code>QueueClient</code> application.
     */
    public static synchronized void shutdown() {
        // Bail out if the class has not been initialized.
        if (initialized == false) {
            return;
        }

        boolean success = true;
        logger.info("Shutting down QueueClient application...");
        try {
            // Shut down message creator
            MessageCreatorConfig.shutdown();
        } catch(Exception e) {
            success = false;
            logger.error("Cannot shutdown message creator", e);
        }        
        try {
            // Shut down the error mapping
            ErrorMapping.shutdown();
        } catch (Exception e) {
            success = false;
            logger.error("Cannot shutdown error mapping", e);
        }
        try {
            // Shut down the transport manager
            TransportManager.shutdown();
        } catch (Exception e) {
            success = false;
            logger.error("Cannot shutdown transport manager", e);
        }

        if (success) {
            logger.info("Successfully shut down QueueClient application.");
        } else {
            logger.error("Errors while shutting down QueueClient application.");
        }

        initialized = false;
    }

    /**
     * Starts the client.
     * @throws FIFException if the client could not be started.
     */
    public static void start() throws FIFException {
        QueueClientMessageSender qcmSender = null;
        QueueClientMessageReceiver qcmReceiver = null;
        try {
            // Start the message sender, if needed
            Thread sender = null;
            if (QueueClientConfig.getBoolean("queueclient.StartSender")) {
                // Create the queue client message sender and initialize it
                qcmSender = new QueueClientMessageSender();
                qcmSender.init();

                // Start it as a thread
                sender = new Thread(qcmSender);
                sender.setName("sender");
                sender.start();
            } else {
                logger.info("Not starting Sender.");
            }

            // Start the message receiver, if needed
            Thread receiver = null;

            if (QueueClientConfig.getBoolean("queueclient.StartReceiver")) {
                // Create the queue client message receiver and initialize it
                qcmReceiver = new QueueClientMessageReceiver();
                qcmReceiver.init();

                // Start it as a thread
                receiver = new Thread(qcmReceiver);
                receiver.setName("receiver");
                receiver.start();
            } else {
                logger.info("Not starting Receiver.");
            }

            // Wait until the threads are done
            if (sender != null) {
                sender.join();
            }
            if (receiver != null) {
                if (errorStatus) {
                    receiver.interrupt();
                } else {
                    receiver.join();
                }
            }
        } catch (InterruptedException e) {
            throw new FIFException("Processing interrupted", e);
        } finally {
            if (qcmSender != null) {
                qcmSender.shutdown();
            }
            if (qcmReceiver != null) {
                qcmReceiver.shutdown();
            }
        }
    }

    /*------*
     * MAIN *
     *------*/

    /**
     * Starts the <code>QueueClient</code>.
     * @param args  the command-line arguments.
     */
    public static void main(String[] args) {
        // Register the shutdown hook
        QueueClientShutdownHook shutdownHook = new QueueClientShutdownHook();
        shutdownHook.setName("shutdown");
        Runtime.getRuntime().addShutdownHook(shutdownHook);

        // Set the config file name
        String configFile = "QueueClient";
        if (System.getProperty("fif.propertyfile") != null) {
            configFile = System.getProperty("fif.propertyfile");
        }

        try {
            // Initialize the application
            QueueClient.init(configFile);

            // Start the database client
            QueueClient.start();
        } catch (FIFException e) {
            logger.fatal("Caught exception", e);
            e.printStackTrace();
        } finally {
            QueueClient.shutdown();
        }
    }
}
