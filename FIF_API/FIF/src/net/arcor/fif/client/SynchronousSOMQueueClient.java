package net.arcor.fif.client;

import net.arcor.fif.common.FIFException;

public class SynchronousSOMQueueClient extends SynchronousQueueClient {

	/**
	 * @throws FIFException
	 */
	protected void startRequestReceivers() throws FIFException {
		for (int receiverNumber = 1; receiverNumber <= numberOfRequestReceivers; receiverNumber++) {
		    SynchronousSOMQueueRequestReceiver requestReceiver = null;
			// Start it as a thread
		    requestReceiver = new SynchronousSOMQueueRequestReceiver(new SynchronousQueueResponseSender());
		    requestReceiver.init();
		    addThread(requestReceiver, "RequestReceiver-" + receiverNumber);
		}
	}

	public static void main (String[] args) {
		theClient = new SynchronousSOMQueueClient();
		theClient.doMain(args);
	}

}
