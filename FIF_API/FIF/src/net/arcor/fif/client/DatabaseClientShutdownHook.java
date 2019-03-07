package net.arcor.fif.client;

import org.apache.log4j.Logger;

/**
 * Shutdown hook for the DatabaseClient.
 * The run method of the shutdown hook is called by the VM every time that
 * the application exits.
 * @author goethalo
 */
public class DatabaseClientShutdownHook extends Thread {

    /**
     * The log4j logger.
     */
    private static Logger logger =
        Logger.getLogger(QueueClientShutdownHook.class);

    /**
     * Shutdown code.
     */
    public void run() {
        if (DatabaseClient.isInitialized()) {
            DatabaseClient.setShutDownHookInvoked();
            logger.info("Shutdown hook invoked...");
            DatabaseClient.shutdown();
            logger.info("Shutdown hook completed.");
        }
    }

}
