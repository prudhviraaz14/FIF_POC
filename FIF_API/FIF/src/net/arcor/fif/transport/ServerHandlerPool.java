package net.arcor.fif.transport;

import java.util.LinkedList;
import java.util.List;

import org.apache.log4j.Logger;

import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.client.RequestHandler;
import net.arcor.fif.common.FIFException;

public class ServerHandlerPool {

	private static List<ServerHandler> serverHandlers = new LinkedList<ServerHandler>();
	private static boolean initialized = false;
	protected static Logger logger = Logger.getLogger(ServerHandlerPool.class);
	
	public static void init() throws FIFException {
		// read parameters for starting serverHandlers
		String instanceBase = ClientConfig.getSetting("ServerHandler.ServerInstanceBase");
		int numberOfInstances = ClientConfig.getInt("SynchronousFifClient.NumberOfRequestHandlers");
		logger.info("Initializing ServerHandlerPool with " + numberOfInstances + " instances.");
		
		// start all the server handlers and put them in a list
		for (int i = 1; i <= numberOfInstances; i++) {
			serverHandlers.add(new ServerHandler(instanceBase + i));
		}
		
		if (!initialized)
			initialized = true;		
	}
	
	public synchronized static ServerHandler getServerHandler() throws FIFException {
		if (!initialized)
			init();
		if (logger.isDebugEnabled())
			logger.debug("Taking ServerHandler from pool. Current pool size (before fetch): " + serverHandlers.size());
		if (!serverHandlers.isEmpty())
			return serverHandlers.remove(0);
		throw new FIFException("No more ServerHandler is available. " +
				"Maybe there are more message consumers that Backend processes configured.");
	}
	
	public static void returnServerHandler(ServerHandler serverHandler) {
		if (serverHandler == null)
			return;
		serverHandlers.add(serverHandler);
		if (logger.isDebugEnabled())
			logger.debug("Putting ServerHandler back into the pool. Current pool size (after put): " + serverHandlers.size());
	}
}
