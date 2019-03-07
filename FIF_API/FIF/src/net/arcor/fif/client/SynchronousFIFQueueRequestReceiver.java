package net.arcor.fif.client;

import net.arcor.fif.common.FIFException;

public class SynchronousFIFQueueRequestReceiver extends
		SynchronousQueueRequestReceiver {
	
	public SynchronousFIFQueueRequestReceiver(ResponseSender responseSender) throws FIFException {
		super (responseSender);
	}

	protected TechnicalFailureAction processReceivedRequest(String message,String jmsCorrelationId,String jmsReplyTo)
			throws FIFException {
		if (logger.isDebugEnabled())			
			logger.debug("Received request message: " + message);		
		processFifRequestMessage(message,jmsCorrelationId,jmsReplyTo);
		return TechnicalFailureAction.NONE;
	}

}
