/*
 $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousTestFrameworkClient.java-arc   1.0   Jun 01 2010 18:06:26   schwarje  $

 $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousTestFrameworkClient.java-arc  $
 * 
 *    Rev 1.0   Jun 01 2010 18:06:26   schwarje
 * Initial revision.
 * 
 */

package net.arcor.fif.client;

import net.arcor.fif.common.FIFException;

/**
 * This class implements a testframework client. It reads requests from an input
 * XML file , creates a TFProcessMessage object for creating the FIF messages
 * based on the requests in the XML file and sending/receiving the created
 * messages to/from FIF.
 * 
 * @author BANANIA
 */
public class SynchronousTestFrameworkClient extends SynchronousFifClient {

	/*------------------*
	 * MEMBER VARIABLES *
	 *------------------*/


	private String fileName = null;
	/*---------*
	 * METHODS *
	 *---------*/

	/**
	 * Initializes the application.
	 * 
	 * @throws FIFException
	 */
	public void init(String configFile) throws FIFException {
		super.init(configFile);
		
		
    	startThreads();
    	
	}

	public static void main (String[] args) {
		theClient = new SynchronousTestFrameworkClient();
		theClient.doMain(args);
	}

    protected void processArguments(String[] args) {
    	if (args.length > 0)
    		fileName = args[0];
    }
	
	/**
	 * @throws FIFException
	 */
	protected void startRequestReceivers() throws FIFException {
	    if (numberOfRequestReceivers == 0) 
	    	return;
		SynchronousTestFrameworkRequestReceiver requestReceiver = null;
	    requestReceiver = new SynchronousTestFrameworkRequestReceiver(null);
	    requestReceiver.init(fileName);
	    addThread(requestReceiver, "RequestReceiver-1");
	}

	/**
	 * @throws FIFException
	 */
    protected void startRecycleRequestHandlers() throws FIFException {
	}

	/**
	 * @throws FIFException
	 */
	protected void startRequestHandlers() throws FIFException {
	    if (numberOfRequestHandlers == 0) 
	    	return;
	    RequestHandler requestHandler = null;
	    requestHandler = new RequestHandler(ccmInstanceBase + 1);
	    requestHandler.setResponseSender(null);
	    addThread(requestHandler, "RequestHandler-1" );
	}

	
}
