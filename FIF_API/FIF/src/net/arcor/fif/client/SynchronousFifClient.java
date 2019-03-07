package net.arcor.fif.client;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.lang.management.ManagementFactory;
import java.util.ArrayList;
import java.util.List;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.Log4jConfig;
import net.arcor.fif.db.DatabaseConfig;
import net.arcor.fif.messagecreator.MessageCreatorConfig;

import org.apache.log4j.Logger;

/**
 * This class implements a CODB queue client.
 * It reads requests from a queue, creates FIF messages based on the requests,
 * and sends the created messages to FIF.
 * <p>
 * This application needs 2 queues:<br>
 * <li>A queue for reading requests</li>
 * <li>A queue for sending the transformed reply to the requesting application</li> 
 * <p>
 * <b>Property file</b><br>
 * The name of the property file used by the application is defaulted to
 * SynchronousQueueClient.<br>
 * The <code>fif.propertyfile</code> system property can be set to another property
 * file if needed.<br>
 * To do this the following syntax can be used for starting the application:<br>
 * <code>java -Dfif.propertyfile=AnotherFile net.arcor.fif.client.
 * CODBClient</code>
 * @author makuier
 */
public abstract class SynchronousFifClient {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

	protected static final String FIF_TRANSACTION_STATUS_NEW = "NEW";
	protected static final String FIF_TRANSACTION_STATUS_COMPLETED_FIF = "COMPLETED_FIF";
	protected static final String FIF_TRANSACTION_STATUS_RESPONSE_SENT = "RESPONSE_SENT";
	protected static final String FIF_TRANSACTION_STATUS_LATE_RESPONSE = "LATE_RESPONSE";
	protected static final String FIF_TRANSACTION_STATUS_RESPONSE_FAILED = "RESPONSE_FAILED";
	protected static final String FIF_TRANSACTION_STATUS_IN_PROGRESS_FIF = "IN_PROGRESS_FIF";
	protected static final String FIF_TRANSACTION_STATUS_IN_RECYCLING = "IN_RECYCLING";

	protected List<Thread> threads = new ArrayList<Thread>();
	
	protected int numberOfRequestReceivers = 1;
	protected int numberOfRequestHandlers = 7;
	protected int numberOfRecycleHandlers = 1;
	protected boolean enableFailedResponseHandling = true;
	protected String ccmInstanceBase;
	
	
    /**
     * The log4j logger.
     */
	protected static SynchronousFifClient theClient = null;

    /**
     * The log4j logger.
     */
	protected Logger logger = Logger.getLogger(getClass());

    /**
     * Indicates whether there is an error status.
     */
    protected boolean errorStatus = false;

    /**
     * Indicates whether the shutdown hook is being invoked.
     */
    protected boolean shutDownHookInvoked = false;

    /**
     * Indicates whether this class is initialzed.
     */
    protected boolean initialized = false;

    /**
     * Object used for locking.
     */
    protected Object lock = new Object();

    protected String clientType = null;
    protected String clientId = null;
    
    /*---------*
     * METHODS *
     *---------*/

    /**
     * Indicates whether the client is in error status.
     * @return the error status
     */
    public boolean inErrorStatus() {
        synchronized (lock) {
            return errorStatus;
        }
    }

    /**
     * Sets the client in error status.
     */
    public void setErrorStatus() {
        synchronized (lock) {
            errorStatus = true;
        }
    }

    /**
     * Indicates whether the shutdown hook is invoked.
     * @return true if invoked, false if not.
     */
    public boolean isShutDownHookInvoked() {
        synchronized (lock) {
            return shutDownHookInvoked;
        }
    }

    /**
     * Sets the shutdown hook invocation to true.
     */
    protected void setShutDownHookInvoked() {
        synchronized (lock) {
            shutDownHookInvoked = true;
        }
    }

    /**
     * Determines whether this class is initialized.
     * @return true if initialize, false if not.
     */
    protected boolean isInitialized() {
        return initialized;
    }

    /**
     * Initializes the application.
     * @param configFile  the name of the property file to get the settings from.
     * @throws FIFException if the application could not be initialized.
     */
    public void init(String configFile) throws FIFException {
        // Bail out if the client was initialized already
        if (initialized == true) {
            return;
        }

        // Set the initialized flag
        initialized = true;
        
        logger.info("Initializing " + getClass() + " application with property file " + configFile);

        // Initialize the queue client config
        ClientConfig.init(configFile);

        // Initialize the logger
        Log4jConfig.init(configFile);

        DatabaseConfig.init(configFile);

		numberOfRequestReceivers = ClientConfig.getInt("SynchronousFifClient.NumberOfRequestReceivers");
		numberOfRequestHandlers = ClientConfig.getInt("SynchronousFifClient.NumberOfRequestHandlers");
		numberOfRecycleHandlers = ClientConfig.getInt("SynchronousFifClient.NumberOfRecycleHandlers");

        // Initialize the message creator
		MessageCreatorConfig.init(configFile);
		
    	clientType = ClientConfig.getSetting("SynchronousFifClient.ClientType");
    	clientId = ClientConfig.getSetting("SynchronousFifClient.ClientId");
		ccmInstanceBase = ClientConfig.getSetting("ServerHandler.ServerInstanceBase");
		
		try {
			enableFailedResponseHandling = ClientConfig.getBoolean("SynchronousFifClient.FailedResponseHandling");		
		} catch (FIFException e) {}
		
		boolean recyclingEnabled = false;
		try {
			recyclingEnabled = ClientConfig.getBoolean("RequestHandler.EnableRecycling");
		} catch (FIFException e) {}
		
		if (numberOfRecycleHandlers == 0 && recyclingEnabled)
			throw new FIFException("Recycling is enabled, but no recycling handlers are configured.");
    	
		try {
			if (ClientConfig.getBoolean("SynchronousFifClient.HangingRequestHandling")) {
				HangingRequestHandler hangingRequestHandler = new HangingRequestHandler();
				hangingRequestHandler.execute();
			}
		} catch (FIFException e) {
			logger.error("Exception while updating hanging requests.", e);
		}
		
        logger.info("Successfully initialized " + getClass() + " application.");
    }

	/**
	 * @throws FIFException
	 */
	protected void startThreads() throws FIFException {
		// start the requestReceiver    	    
    	startRequestReceivers();

    	// start the threads for regular processing        	
    	startRequestHandlers();
    	
    	// start the threads for recycling
    	startRecycleRequestHandlers();
    	
    	try {
    		for (Thread thread : threads) {
    			if (thread != null) {    				
    	    		thread.start();
    			}
    		}
    		
    		for (Thread thread : threads) {
    			if (thread != null) {    				
    				thread.join();
    			}
    		}
    	} catch (InterruptedException e) {
    		throw new FIFException("Processing interrupted", e);
    	}
	}
    
    protected abstract void startRequestReceivers() throws FIFException;
    protected abstract void startRequestHandlers() throws FIFException;
    protected abstract void startRecycleRequestHandlers() throws FIFException;
    

    /**
     * Shuts down the application.
     */
    public synchronized void shutdown() {
        // Bail out if the class has not been initialized.
        if (initialized == false) {
            return;
        }

        boolean success = true;
        logger.info("Shutting down " + getClass().getName() + " application...");
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
        
        killChildren();
                        
        if (success) {
            logger.info("Successfully shut down " + getClass().getName() + " application.");
        } else {
            logger.error("Errors while shutting down " + getClass().getName() + " application.");
        }

        initialized = false;
    }
    
    private void killChildren() {
    	// If there are no request handler, there's nothing to kill
    	if (numberOfRequestHandlers + numberOfRecycleHandlers == 0)
    		return;
        try {			
        	String serverProcessName = null;
			try {
				serverProcessName = ClientConfig.getSetting("ServerHandler.ServerProcessName");
			} catch (FIFException e) { 
				logger.error("If this happens, we should have bigger problems.",e);
			}
			
			// get parent PID and user first
			String pidHelper = ManagementFactory.getRuntimeMXBean().getName();
			logger.info(pidHelper);
			String pid = pidHelper.substring(0, pidHelper.indexOf("@"));
			Process findUser = Runtime.getRuntime().exec("whoami");
			String user = new BufferedReader(new InputStreamReader(findUser.getInputStream())).readLine().trim();

			logger.info("PID of this process: " + pid);
			logger.info("Creator of this process: " + user);
			logger.info("Server process name: " + serverProcessName);			

			// run a ps to retrieve all active processes
			Process findChildrenPid = Runtime.getRuntime().exec("ps -f");
			BufferedReader findChildrenReader = new BufferedReader(new InputStreamReader(findChildrenPid.getInputStream()));
			String childPidString = findChildrenReader.readLine(); 
			while (childPidString != null) {
				logger.info("Current line: " + childPidString);
				// scan all lines for relevant content (the child CcmFifInterface processes)
			    if (childPidString.contains(pid) && childPidString.contains(serverProcessName)) {
			    	String childPid = childPidString.substring(
			    			childPidString.indexOf(user) + user.length(), 
			    			childPidString.indexOf(pid)).trim();
					String killCommand = "kill -9 " + childPid;
					logger.info("Running command: " + killCommand);
					Runtime.getRuntime().exec(killCommand);
			    }
				childPidString = findChildrenReader.readLine();			    	
			}
			findChildrenReader.close();
			if (findChildrenPid.exitValue() != 0)
				findChildrenPid.destroy();
			if (findUser.exitValue() != 0)
				findUser.destroy();

		} catch (IOException e) {
			logger.error("Problem while trying to kill all backend processes.", e);
		}
		
	}

	public void doMain(String[] args) {    	
        // Register the shutdown hook
        ShutdownHook shutdownHook = new ShutdownHook();
        shutdownHook.setName("shutdown");
        Runtime.getRuntime().addShutdownHook(shutdownHook);
        processArguments(args);
        
        // Set the config file name
        String configFile = "SynchronousFifClient";
        if (System.getProperty("fif.propertyfile") != null) {
            configFile = System.getProperty("fif.propertyfile");
        }
        try {
            // Initialize the application
            init(configFile);
        } catch (FIFException e) {
            logger.fatal("Caught exception", e);
            e.printStackTrace();
        } finally {
            shutdown();
        }
    }
    
    protected abstract void processArguments(String[] args);

	protected void addThread(Runnable runnable, String threadName) {
		logger.info("Adding thread " + threadName + " of type " + runnable.getClass().getName());
		Thread thread = null;
		thread = new Thread(runnable);
		thread.setName(threadName);
		threads.add(thread);
	}

	public String getClientType() {
		return clientType;
	}

	public void setClientType(String clientType) {
		this.clientType = clientType;
	}

	public String getClientId() {
		return clientId;
	}

	public void setClientId(String clientId) {
		this.clientId = clientId;
	}

}
