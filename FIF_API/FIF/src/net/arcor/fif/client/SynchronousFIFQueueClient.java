package net.arcor.fif.client;

import net.arcor.fif.common.FIFException;

public class SynchronousFIFQueueClient extends SynchronousQueueClient {

	
	protected void startRequestReceivers() throws FIFException {
		for (int receiverNumber = 1; receiverNumber <= numberOfRequestReceivers; receiverNumber++) {
		    SynchronousQueueRequestReceiver requestReceiver = null;
			// Start it as a thread
		    requestReceiver = new SynchronousFIFQueueRequestReceiver(new SynchronousQueueResponseSender());
		    requestReceiver.init();
		    addThread(requestReceiver, "RequestReceiver-" + receiverNumber);
		}
	}

	public static void main (String[] args) {
		theClient = new SynchronousFIFQueueClient();
		theClient.doMain(args);
	}


}
