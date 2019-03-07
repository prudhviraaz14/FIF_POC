/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousServiceBusClient.java-arc   1.2   Jan 18 2013 07:46:54   schwarje  $
 *    $Revision:   1.2  $
 *    $Workfile:   SynchronousServiceBusClient.java  $
 *      $Author:   schwarje  $
 *        $Date:   Jan 18 2013 07:46:54  $
 *
 *  Function: main class for the synchronous service bus client
 *  
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousServiceBusClient.java-arc  $
 * 
 *    Rev 1.2   Jan 18 2013 07:46:54   schwarje
 * IT-32438: Allow switching off the MessageCreator
 * 
 *    Rev 1.1   Jun 01 2010 18:01:54   schwarje
 * IT-26029: updates
 * 
 *    Rev 1.0   Jan 29 2008 17:44:16   schwarje
 * Initial revision.
 * 
 ***************************************************************************  
 */
package net.arcor.fif.client;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.Log4jConfig;
import net.arcor.fif.db.DatabaseConfig;
import net.arcor.fif.messagecreator.MessageCreatorConfig;

import org.apache.log4j.Logger;
import org.springframework.context.support.FileSystemXmlApplicationContext;

public class SynchronousServiceBusClient {

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(SynchronousServiceBusClient.class);

    /**
     * Indicates whether there is an error.
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
     * Indicates whether this class is initialzed.
     */
    private static String beanConfigurationFile = null;

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
        
        // Initialize the client config
        ClientConfig.init(configFile);

        // Initialize the logger
        Log4jConfig.init(configFile);
        
        // Initialize the database
        DatabaseConfig.init(configFile);
        
        logger.info("Initializing ServiceBusClient application with property file " + configFile + "...");
        
        boolean initializeMessageCreator =  true;
        try {
			initializeMessageCreator = ClientConfig.getBoolean("SynchronousServiceBusClient.InitializeMessageCreator");
		} catch (FIFException e) {}
        
        if (initializeMessageCreator)
        	// Initialize the message creator
        	MessageCreatorConfig.init(configFile);

        logger.info("Successfully initialized ServiceBusClient application.");
    }
        
    /**
     * Shuts down the <code>SynchronousServiceBusClient</code> application.
     */
    public static synchronized void shutdown() {
        // Bail out if the class has not been initialized.
        if (initialized == false) {
            return;
        }

        boolean success = true;
        logger.info("Shutting down SynchronousServiceBusClient application...");
        try {
            // Shut down message creator
            MessageCreatorConfig.shutdown();
        } catch(Exception e) {
            success = false;
            logger.error("Cannot shutdown message creator", e);
        }        

        if (success) {
            logger.info("Successfully shut down SynchronousServiceBusClient application.");
        } else {
            logger.error("Errors while shutting down SynchronousServiceBusClient application.");
        }

        initialized = false;
    }

    /**
     * Starts the client.
     * @throws FIFException if the client could not be started.
     */
    public static void start() throws FIFException {

        // get the location of the Spring bean configuration file
        beanConfigurationFile = ClientConfig.getSetting("servicebusclient.BeanConfigurationFile");

        // run the mcf listener and sender
        new FileSystemXmlApplicationContext(beanConfigurationFile);
        
    }

    /*------*
     * MAIN *
     *------*/

    /**
     * Starts the <code>SynchronousServiceBusClient</code>.
     * @param args  the command-line arguments.
     */
    public static void main(String[] args) {
        // Register the shutdown hook
        ShutdownHook shutdownHook = new ShutdownHook();
        shutdownHook.setName("shutdown");
        Runtime.getRuntime().addShutdownHook(shutdownHook);

        // Set the config file name
        String configFile = "SynchronousServiceBusClient";
        if (System.getProperty("fif.propertyfile") != null) {
            configFile = System.getProperty("fif.propertyfile");
        }

        try {            

            // Initialize the application
            SynchronousServiceBusClient.init(configFile);

            // Start the client
            SynchronousServiceBusClient.start();
        } catch (FIFException e) {
            logger.fatal("Caught exception", e);
            e.printStackTrace();
        }
    }
}
