package net.arcor.fif.client;

import org.apache.log4j.Logger;

/**
 * Shutdown hook for the QueueClient.
 * The run method of the shutdown hook is called by the VM every time that
 * the application exits.
 * @author goethalo
 */
public class QueueClientShutdownHook extends Thread {

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(QueueClientShutdownHook.class);

    /**
     * Shutdown code.
     */    
    public void run() {
        if (QueueClient.isInitialized()){
            QueueClient.setShutDownHookInvoked();
            logger.info("Shutdown hook invoked...");
            QueueClient.shutdown();
            logger.info("Shutdown hook completed.");
        }
    }
}
