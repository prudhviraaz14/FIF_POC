/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/SynchronousFifHandler.java-arc   1.4   Nov 22 2010 10:36:56   makuier  $
 *    $Revision:   1.4  $
 *    $Workfile:   SynchronousFifHandler.java  $
 *      $Author:   makuier  $
 *        $Date:   Nov 22 2010 10:36:56  $
 *
 *  Function: service handler for synchronous processing in FIF
 *  
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/SynchronousFifHandler.java-arc  $
 * 
 *    Rev 1.4   Nov 22 2010 10:36:56   makuier
 * Adapted to mcf2
 * 
 *    Rev 1.3   Mar 09 2009 16:12:38   makuier
 * Added support for multi threading
 * 
 *    Rev 1.2   Sep 15 2008 09:32:58   schwarje
 * SPN-FIF-000076119: improved request logging for service bus client
 * 
 *    Rev 1.1   Jul 30 2008 16:27:34   schwarje
 * IT-k-23569: new FIF client for reading responses for service bus requests initiated from CCM
 * 
 ***************************************************************************  
 */
package net.arcor.fif.servicehandler;

import java.util.HashMap;

import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.client.RequestHandler;
import net.arcor.fif.client.SynchronousServiceBusClientRequestHandler;
import net.arcor.mcf2.exception.base.MCFException;
import net.arcor.mcf2.model.ServiceObjectEndpoint;
import net.arcor.mcf2.model.ServiceResponse;

public abstract class SynchronousFifHandler extends FifServiceHandler {

	private static HashMap<String, RequestHandler> handlerMap = new HashMap<String, RequestHandler>();
	private static HashMap<String, Integer> threadNumberMap = new HashMap<String, Integer>();
	private static Integer noOfActiveHndThreads=1;

	public static HashMap<String, RequestHandler> getHandlerMap() {
		return handlerMap;
	}

	public static HashMap<String, Integer> getThreadNumberMap() {
		return threadNumberMap;
	}

	public static Integer getNoOfActiveHndThreads() {
		return noOfActiveHndThreads;
	}

	public static void setNoOfActiveHndThreads(Integer noOfActiveHndThreads) {
		SynchronousFifHandler.noOfActiveHndThreads = noOfActiveHndThreads;
	}

	/** (non-Javadoc)
	 * @see net.arcor.mcf.service.wf.WorkflowServiceHandler#processRequest(java.lang.Object, java.util.Map)
	 * main method for processing a request, automatically called from MCF when a message
	 * is put on the in queue
	 */
	public abstract ServiceResponse<?> execute(final ServiceObjectEndpoint<?> serviceInput)	throws MCFException;

	public SynchronousFifHandler() throws MCFException {
		super();
	}
	/**
	 * @param requestHandler
	 * @return
	 * @throws MCFException
	 */
	protected SynchronousServiceBusClientRequestHandler getRequestHandler() throws MCFException {
		SynchronousServiceBusClientRequestHandler requestHandler = null;
		try {
			// get the next available number
			requestHandler = 
				(SynchronousServiceBusClientRequestHandler)handlerMap.get(Thread.currentThread().getName());
			if (requestHandler == null){
				if (!threadNumberMap.containsKey(Thread.currentThread().getName())){
					threadNumberMap.put(Thread.currentThread().getName(), noOfActiveHndThreads);
					noOfActiveHndThreads++;
				}
        	    String  ccmInstanceBase = ClientConfig.getSetting("ServerHandler.ServerInstanceBase");
				String currentExt = threadNumberMap.get(Thread.currentThread().getName()).toString();
				requestHandler = new SynchronousServiceBusClientRequestHandler(ccmInstanceBase+currentExt);
				handlerMap.put(Thread.currentThread().getName(), requestHandler);
			}
		} catch (Exception e) {
			logger.fatal("Exception caught while initializing SynchronousFifHandler. " +
					"See exception for details: ", e);
			throw new MCFException("Exception caught while initializing SynchronousFifHandler. " +
					"See exception for details: ");
		}
		return requestHandler;
	}

}
