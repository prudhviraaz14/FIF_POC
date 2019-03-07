package net.arcor.fif.client;

import org.apache.log4j.Logger;

/**
 * Shutdown hook
 * The run method of the shutdown hook is called by the VM every time that
 * the application exits.
 * @author goethalo
 */
public class ShutdownHook extends Thread {

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(ShutdownHook.class);

    /**
     * Shutdown code.
     */    
    public void run() {
        if (SynchronousFifClient.theClient.isInitialized()){
        	SynchronousFifClient.theClient.setShutDownHookInvoked();
            logger.info("Shutdown hook invoked...");
            SynchronousFifClient.theClient.shutdown();
            logger.info("Shutdown hook completed.");
        }
    }
}
