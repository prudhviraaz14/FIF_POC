/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/FifServletClient.java-arc   1.1   Jun 13 2015 11:00:18   schwarje  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/FifServletClient.java-arc  $
 * 
 *    Rev 1.1   Jun 13 2015 11:00:18   schwarje
 * PPM-95514: added debug logging for current env variables
 * 
 *    Rev 1.0   Jun 10 2015 13:23:52   schwarje
 * Initial revision.
*/
package net.arcor.fif.client;

import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.ResourceBundle;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.servlet.http.HttpServlet;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.Log4jConfig;
import net.arcor.fif.db.DatabaseConfig;
import net.arcor.fif.messagecreator.MessageCreatorConfig;

import org.apache.log4j.Logger;
import org.springframework.context.support.FileSystemXmlApplicationContext;

public class FifServletClient extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(FifServletClient.class);

    /**
     * Indicates whether there is an error.
     */
    protected static boolean errorStatus = false;

    /**
     * Indicates whether the shutdown hook is being invoked.
     */
    protected static boolean shutDownHookInvoked = false;

    /**
     * Indicates whether this class is initialzed.
     */
    protected static boolean initialized = false;

    /**
     * Object used for locking.
     */
    protected static Object lock = new Object();

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Indicates whether the client is in error status.
     * @return the error status
     */
    protected static boolean inErrorStatus() {
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
     * Shuts down the <code>EaiClient</code> application.
     */
    public static synchronized void shutdown() {
        // Bail out if the class has not been initialized.
        if (initialized == false) {
            return;
        }

        boolean success = true;
        logger.info("Shutting down EaiClient application...");
        try {
            // Shut down message creator
            MessageCreatorConfig.shutdown();
        } catch(Exception e) {
            success = false;
            logger.error("Cannot shutdown message creator", e);
        }        

        if (success) {
            logger.info("Successfully shut down EaiClient application.");
        } else {
            logger.error("Errors while shutting down EaiClient application.");
        }

        initialized = false;
    }

    /**
     * Starts the client.
     * @throws FIFException if the client could not be started.
     */
    public static void start() throws Exception {

        String beanConfigurationFile = null;
        try {
			// get the location of the Spring bean configuration file
			beanConfigurationFile = ClientConfig.getSetting("servicebusclient.BeanConfigurationFile");
		} catch (FIFException e) {
			logger.error(e.getMessage());
			throw e;
		}

        // run the mcf listener and sender
        new FileSystemXmlApplicationContext(beanConfigurationFile);
        
    }

    /*------*
     * MAIN *
     *------*/

    /**
     * Starts the <code>EaiClient</code>.
     * @param args  the command-line arguments.
     */
    public void init() {
    	
        // Register the shutdown hook
        ShutdownHook shutdownHook = new ShutdownHook();
        shutdownHook.setName("shutdown");
        Runtime.getRuntime().addShutdownHook(shutdownHook);

        try {            
        	InitialContext iniCtx = new InitialContext();
        	Context envCtx = (Context) iniCtx.lookup("java:comp/env");
        	String configurationFile = (String) envCtx.lookup("configurationFile");

        	ResourceBundle rb = ResourceBundle.getBundle("config/" + configurationFile);
            // Initialize the client config
            ClientConfig.init(rb);

            // Initialize the logger
            Log4jConfig.init(ClientConfig.getProps());
            
            // Initialize the database
            DatabaseConfig.init(ClientConfig.getProps());

            MessageCreatorConfig.init(ClientConfig.getProps());
            
            if (logger.isDebugEnabled()) {
            	String logString = "Current environment settings:";
                List<String> sortedKeyList = new LinkedList<String>(System.getenv().keySet());
                Collections.sort(sortedKeyList);
	            for (String key : sortedKeyList)
	            	logString += "\n" + key + "=" + System.getenv(key);
	            logger.debug(logString);
            }
            
            // Start the client
            start();
        } catch (FIFException e) {
            logger.fatal("Caught exception", e);
        } catch (final Exception e) {
        	logger.fatal("Caught exception", e);
    		System.exit(1);
    	}

    }
}
