/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousQueueClient.java-arc   1.4   Jun 18 2010 17:39:26   schwarje  $
 *    $Revision:   1.4  $
 *    $Workfile:   SynchronousQueueClient.java  $
 *      $Author:   schwarje  $
 *        $Date:   Jun 18 2010 17:39:26  $
 *
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousQueueClient.java-arc  $
 * 
 *    Rev 1.4   Jun 18 2010 17:39:26   schwarje
 * changes for CPCOM Phase 2: new FIF client type accepting SOM orders
 * 
 *    Rev 1.3   Jun 01 2010 18:01:58   schwarje
 * IT-26029: updates
 * 
 *    Rev 1.2   May 25 2010 16:33:36   schwarje
 * IT-26029: updates
 * 
 * 
 ***************************************************************************  
 */
package net.arcor.fif.client;

import net.arcor.fif.common.FIFException;

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
public abstract class SynchronousQueueClient extends SynchronousFifClient {


	public void init(String configFile) throws FIFException {
		super.init(configFile);
		
		if (enableFailedResponseHandling) {
			FailedResponseHandler failedResponseHandler = 
				new FailedResponseHandler(new SynchronousQueueResponseSender());
			addThread(failedResponseHandler, "FailedResponseHandler");
		}			
		
    	startThreads();
    	
	}
	
	/**
	 * @throws FIFException
	 */
    protected void startRecycleRequestHandlers() throws FIFException {
		for (int recycleHandlerNumber = 1; recycleHandlerNumber <= numberOfRecycleHandlers; recycleHandlerNumber++) {
		    RequestHandler recycleRequestHandler = null;
			// Start it as a thread
		    recycleRequestHandler = new RequestHandler(ccmInstanceBase + new Integer(numberOfRequestHandlers + recycleHandlerNumber));
		    recycleRequestHandler.setRecyclingInstance(true);
		    recycleRequestHandler.setResponseSender(new SynchronousQueueResponseSender());		    
		    addThread(recycleRequestHandler, "RecycleRequestHandler-" + recycleHandlerNumber);
		}
	}

	/**
	 * @throws FIFException
	 */
	protected void startRequestHandlers() throws FIFException {
		for (int requestHandlerNumber = 1; requestHandlerNumber <= numberOfRequestHandlers; requestHandlerNumber++) {
		    RequestHandler requestHandler = null;
			// Start it as a thread
		    requestHandler = new RequestHandler(ccmInstanceBase + requestHandlerNumber);
		    requestHandler.setResponseSender(new SynchronousQueueResponseSender());
		    addThread(requestHandler, "RequestHandler-" + requestHandlerNumber);
		}
	}

	@Override
	protected void processArguments(String[] args) {}

}
