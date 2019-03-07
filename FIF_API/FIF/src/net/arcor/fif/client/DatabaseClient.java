/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/DatabaseClient.java-arc   1.8   Apr 25 2007 14:32:02   schwarje  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/DatabaseClient.java-arc  $
 * 
 *    Rev 1.8   Apr 25 2007 14:32:02   schwarje
 * IT-19232: support for transaction lists
 * 
 *    Rev 1.7   Apr 19 2007 17:14:44   schwarje
 * IT-19232: support for transaction lists in database clients
 * 
 *    Rev 1.6   Aug 02 2004 15:26:12   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.5   Jan 26 2004 16:39:54   goethalo
 * IT-10018: Added AutoShutdown functionality.
 * 
 *    Rev 1.4   Jan 08 2004 18:04:30   goethalo
 * Added queue emulation support. To enable emulation set DatabaseClient.EmulateQueues=true
 * 
 *    Rev 1.3   Dec 08 2003 13:08:42   goethalo
 * Added support for threaded sender.
 * 
 *    Rev 1.2   Oct 07 2003 14:50:42   goethalo
 * Changes for IT-9811 - Internet By Call with Registration
 * 
 *    Rev 1.1   Jul 16 2003 14:55:20   goethalo
 * Changes for IT-9750.
 * 
 *    Rev 1.0   Apr 09 2003 09:34:28   goethalo
 * Initial revision.
*/
package net.arcor.fif.client;

import org.apache.log4j.Logger;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.Log4jConfig;
import net.arcor.fif.db.DatabaseConfig;
import net.arcor.fif.messagecreator.MessageCreatorConfig;
import net.arcor.fif.transport.TransportManager;

/**
 * This class implements a FIF database client.
 * It reads requests from the databse, creates FIF messages based on retrieved
 * data, and sends the created messages to FIF.
 * In order to use this client the following database tables need to exist:
 * <i>Insert table descriptions here</i>
 * <b>Property file</b>
 * The name of the property file used by the application is defaulted to
 * DatabaseClient.
 * The <code>fif.propertyfile</code> system property can be set to another property
 * file if needed.
 * To do this the following syntax can be used for starting the application:
 * <code>java -Dfif.propertyfile=AnotherFile net.arcor.fif.client.
 * DatabaseClient</code>
 * @author goethalo
 */
public final class DatabaseClient {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(DatabaseClient.class);

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

    /**
     * Indicates whether the sending should be emulated.
     */
    public static boolean emulateQueues = false;

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
	
    /**
     * Indicates whether the client should shut down when all requests
     * have been processed. I.e. when there are no more NOT_STARTED entries
     * in the database.
     */
    public static boolean autoShutdown = false;

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
        DatabaseClientConfig.init(configFile);

        // Initialize the logger
        Log4jConfig.init(configFile);

        logger.info(
            "Initializing DatabaseClient with property file "
                + configFile
                + "...");

        // Initialize the database
        DatabaseConfig.init(configFile);

        // Initialize the message creator
        MessageCreatorConfig.init(configFile);

        // Check if we are in queue emulation and auto-shutdown mode
        try {
            emulateQueues =
                DatabaseClientConfig.getBoolean("databaseclient.EmulateQueues");
        } catch (FIFException fe) {
            // Ignore
        }
        if (emulateQueues == true) {
            try {
                autoShutdown =
                    DatabaseClientConfig.getBoolean(
                        "databaseclient.AutoShutdown");
                logger.warn(
                    "Automatically shutting down when all requests "
                        + "have been processed.");
            } catch (FIFException fe) {
                // Ignore
            }
        }

        // Initialize the transport manager
        if (emulateQueues == false) {
            TransportManager.init(configFile);
        } else {
            logger.warn("Emulating queues. Not starting transport manager.");
        }


        // Check if we transaction lists are supported
        try {
        	transactionListSupported =
                DatabaseClientConfig.getBoolean("databaseclient.TransactionListSupported");
        } catch (FIFException fe) {
            // Ignore
        }

        // read transaction states from the properties 
    	requestStatusCompleted = 
		    DatabaseClientConfig.getSetting("databaseclient.RequestStatusCompleted");
    	requestStatusFailed = 
		    DatabaseClientConfig.getSetting("databaseclient.RequestStatusFailed");
    	requestStatusNotStarted = 
		    DatabaseClientConfig.getSetting("databaseclient.RequestStatusNotStarted");
    	requestStatusInProgress = 
		    DatabaseClientConfig.getSetting("databaseclient.RequestStatusInProgress");
    	requestStatusNotExecuted = 
		    DatabaseClientConfig.getSetting("databaseclient.RequestStatusNotExecuted");
    	requestStatusCanceled = 
		    DatabaseClientConfig.getSetting("databaseclient.RequestStatusCanceled");
    	
    	requestStatusDataType = 
		    DatabaseClientConfig.getSetting("databaseclient.RequestStatusDataType");
    	
        logger.info("Successfully initialized DatabaseClient.");
    }

    /**
     * Shuts down the application.
     */
    public static synchronized void shutdown() {
        // Bail out if the class has not been initialized.
        if (initialized == false) {
            return;
        }

        boolean success = true;
        logger.info("Shutting down DatabaseClient...");
        try {
            // Shut down message creator
            MessageCreatorConfig.shutdown();
        } catch (Exception e) {
            success = false;
            logger.error("Cannot shutdown message creator", e);
        }
        try {
            // Shut down the database
            DatabaseConfig.shutdown();
        } catch (Exception e) {
            success = false;
            logger.error("Cannot shutdown database connection", e);
        }
        try {
            // Shut down the transport manager
            if (emulateQueues == false) {
                TransportManager.shutdown();
            }
        } catch (Exception e) {
            success = false;
            logger.error("Cannot shutdown transport manager", e);
        }

        if (success) {
            logger.info("Successfully shut down DatabaseClient.");
        } else {
            logger.error("Errors while shutting down DatabaseClient.");
        }

        initialized = false;
    }

    /**
     * Starts the client.
     * @throws FIFException if the client could not be started.
     */
    public static void start() throws FIFException {
        DatabaseClientMessageSender dbcmSender = null;
        DatabaseClientThreadedSender dbctmSender = null;
        DatabaseClientMessageReceiver dbcmReceiver = null;

        try {
            // Start the message sender, if needed
            Thread sender = null;
            if (DatabaseClientConfig
                .getBoolean("databaseclient.StartSender")) {
                // Create the db client message sender and initialize it
                boolean threaded = false;
                try {
                    if (DatabaseClientConfig
                        .getBoolean("databaseclient.UseMultipleThreads")) {
                        threaded = true;
                    }
                } catch (FIFException fe) {
                    // Ignore
                }
                if (threaded) {
                    dbctmSender = new DatabaseClientThreadedSender();
                    dbctmSender.init();
                    sender = new Thread(dbctmSender);
                } else {
                    dbcmSender = new DatabaseClientMessageSender();
                    dbcmSender.init();
                    sender = new Thread(dbcmSender);
                }

                // Start it as a thread
                sender.setName("sender");
                sender.start();
            } else {
                logger.info("Not starting Sender.");
            }

            // Start the message receiver, if needed
            Thread receiver = null;
            if ((DatabaseClientConfig
                .getBoolean("databaseclient.StartReceiver"))
                && (emulateQueues == false)) {
                // Create the db client message receiver and initialize it
                dbcmReceiver = new DatabaseClientMessageReceiver();
                dbcmReceiver.init();

                // Start it as a thread
                receiver = new Thread(dbcmReceiver);
                receiver.setName("receiver");
                receiver.start();
            } else {
                if (emulateQueues == false) {
                    logger.info("Not starting Receiver.");
                } else {
                    logger.info("Not starting Receiver in emulate mode.");
                }
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
            if (dbcmSender != null) {
                dbcmSender.shutdown();
            }
            if (dbctmSender != null) {
                dbctmSender.shutdown();
            }
            if (dbcmReceiver != null) {
                dbcmReceiver.shutdown();
            }
        }
    }

    /*------*
     * MAIN *
     *------*/

    /**
     * Starts the <code>DatabaseClient</code>.
     */
    public static void main(String[] args) {
        // Register the shutdown hook
        DatabaseClientShutdownHook shutdownHook =
            new DatabaseClientShutdownHook();
        shutdownHook.setName("shutdown");
        Runtime.getRuntime().addShutdownHook(shutdownHook);

        // Set the config file name
        String configFile = "DatabaseClient";
        if (System.getProperty("fif.propertyfile") != null) {
            configFile = System.getProperty("fif.propertyfile");
        }

        try {
            // Initialize the application
            DatabaseClient.init(configFile);

            // Start the database client
            DatabaseClient.start();
        } catch (FIFException e) {
            logger.fatal("Caught exception", e);
            e.printStackTrace();
        } finally {
            // Shut down the application
            DatabaseClient.shutdown();
        }
    }
}
