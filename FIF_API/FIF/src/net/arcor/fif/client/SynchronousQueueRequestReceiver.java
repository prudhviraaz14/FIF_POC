package net.arcor.fif.client;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import javax.jms.JMSException;
import javax.jms.Queue;
import javax.jms.QueueReceiver;
import javax.jms.QueueSender;
import javax.jms.TransactionRolledBackException;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.db.FifTransaction;
import net.arcor.fif.messagecreator.FIFError;
import net.arcor.fif.messagecreator.FIFRequest;
import net.arcor.fif.messagecreator.FIFRequestList;
import net.arcor.fif.messagecreator.Request;
import net.arcor.fif.messagecreator.RequestSerializer;
import net.arcor.fif.messagecreator.SimpleParameter;
import net.arcor.fif.transport.QueueClientConnection;
import net.arcor.fif.transport.TransportUtils;

public abstract class SynchronousQueueRequestReceiver extends RequestReceiver {

	/**
	 * the maximum number of exceptions while transforming for one transactionID
	 * before FIF sends a response
	 */
	protected static final int transactionExceptionThreshold = 3;
	
	/**
	 * Number of MQ connection retries 
	 */
	protected int noOfRetry = 0;
	
	/**
	 * maximum number of consecutive exception while transforming for any transactionID
	 * before FIF shuts down
	 */
	protected static final int consecutiveExceptionThreshold = 10;
	
	/**
	 * counter for exceptions
	 */
	protected static int consecutiveExceptionCounter = 0;
	
	/**
	 * counter for exceptions per transaction
	 */
	protected static Map<String, Integer> transactionExceptionCounterMap = new HashMap<String, Integer>();
	
	/**
	 * indicates how long (in milliseconds) the Receiver will sleep before 
	 * continuing execution (to finish initialization e.g.)
	 */
	private static final int REQUEUE_SLEEP_TIME = 5000;

	private String encoding;
	
	protected enum TechnicalFailureAction {REQUEUE, RESPONSE, SHUTDOWN, NONE;}; 

	/**
	 * The client response sender.
	 */
	protected QueueClientConnection connection = null;

	/**
	 * The client request receiver.
	 */
	private QueueReceiver clientRequestReceiver = null;

	/**
	 * The client request receiver.
	 */
	private QueueSender requeueingSender = null;
		
	public SynchronousQueueRequestReceiver(ResponseSender responseSender) throws FIFException {
		super (responseSender);
	}
	
	public void run() {		
		try {
			boolean timedOut = false;
			javax.jms.Message message = null;
			while (!(Thread.interrupted()) && (!SynchronousFifClient.theClient.inErrorStatus())) {
				// Wait for a client request...
				try {
					if (!timedOut) {
						logger.info("Waiting for client request...");
					}
					message = clientRequestReceiver.receive(1);
					// Start at the beginning of the loop again if the message is null
					if (message == null) {
						timedOut = true;
						continue;
					}

					// We did not time out. Remember that
					timedOut = false;

					// Process the request
					logger.debug("Processing request...");
					// Get the message text
					String messageText = TransportUtils.getMessageText(message, encoding);
					String jmsCorrelationId = null;
					String jmsReplyTo=null;
					
        	String replyTo="Y";
        	try{
        		replyTo=ClientConfig.getSetting("transport.jmsReplyTo");
        	}catch(Throwable e){
        		logger.info(" ***run::ERROR "+e);
        	}

					if(message.getJMSReplyTo()!=null && replyTo.equals("Y"))
					{
						jmsCorrelationId = message.getJMSCorrelationID();
						if(jmsCorrelationId==null)
							jmsCorrelationId=message.getJMSMessageID();
						
						jmsReplyTo=null;
						//Destination jmsReplyTo = message.getJMSReplyTo();
						//String replyToName = (String)message.get(JMSConstants.JMS_REBASED_REPLY_TO);
						Queue reply = (Queue)message.getJMSReplyTo();
						if(reply!=null)
							 jmsReplyTo = reply.getQueueName();					
					}
					
					TechnicalFailureAction returnValue = 
						processReceivedRequest(messageText, jmsCorrelationId, jmsReplyTo);

					switch (returnValue) {
					case SHUTDOWN:
						connection.getSession().rollback();
						SynchronousFifClient.theClient.setErrorStatus();
						System.exit(1);
						break;
					case REQUEUE:
						requeueingSender.send(message);
						// continue after a failed commit, as this is happening regularly, 
						// whenever MQSeries has problems
						try {
							connection.getSession().commit();
						} catch (JMSException jms) {
							logger.error("Caught JMS exception : " + jms.getLinkedException().getMessage(), jms);
							if (!(jms instanceof TransactionRolledBackException))
								throw jms;
						}
						Thread.sleep(REQUEUE_SLEEP_TIME);
						break;
					case RESPONSE:
					case NONE:
						// continue after a failed commit, as this is happening regularly, 
						// whenever MQSeries has problems
						try {
							connection.getSession().commit();
						} catch (JMSException jms) {
							logger.error("Caught JMS exception : " + jms.getLinkedException().getMessage(), jms);
							if (!(jms instanceof TransactionRolledBackException))
								throw jms;
						}
					}
					noOfRetry=0;
				} catch (JMSException e) {
					logger.info("Lost connection to the queue. Try to reconnect.");
					if (!reconnectQueue()){
						if (e.getLinkedException() != null)
							logger.error("Reached maximum number of retry :" + e.getLinkedException().getMessage(), e);
						else
							logger.error("Reached maximum number of retry. Shutting down.", e);
						SynchronousFifClient.theClient.setErrorStatus();
						System.exit(1);	
					}
				} catch (Exception e) {
					if (SynchronousFifClient.theClient.isShutDownHookInvoked() == false) {
						try {
							connection.getSession().rollback();
						} catch (JMSException e1) {}
						// Set the error status on the QueueClient object
						logger.fatal("Fatal error while processing requests: " + e.getMessage(), e);
					}
					SynchronousFifClient.theClient.setErrorStatus();
					System.exit(1);
				}
			}
		} 		
		finally{
			if (fifTransactionDAO != null)
				fifTransactionDAO.closeStatements();
		}

	}

	private boolean reconnectQueue(){
		int retrySleepTime=5;
		int maxRetry = 10;
		try {
			maxRetry = ClientConfig.getInt("transport.MaxRetry");
			retrySleepTime = ClientConfig.getInt("transport.RetrySleepTime");
			Thread.sleep(retrySleepTime * 1000);
		} catch (Exception e) {
		}
		if (maxRetry<noOfRetry)
			return false;
		try {
			connection.getSession().close();
			init();
		} catch (Exception e) {
		}
		noOfRetry++;
		return true;
	}

	protected abstract TechnicalFailureAction processReceivedRequest(String messageText,String jmsCorrelationId,String jmsReplyTo) throws FIFException;

	protected TechnicalFailureAction handleTechnicalFailure(String transactionType, String transactionId, String exception, String message, String jmsCorrelationId, String jmsReplyTo) throws FIFException {				
		// if the total limit of consecutive exceptions is reached, trigger the shutdown of the FIF client
		if (++consecutiveExceptionCounter >= consecutiveExceptionThreshold) {
			logger.fatal("Shutting down the FIF client after " + consecutiveExceptionThreshold + 
					" consecutive exceptions.");
			return TechnicalFailureAction.SHUTDOWN;		
		}
		int transactionExceptionCounter = 1;
		// if the transactionID could be retrieved, check if this transaction already had some exceptions
		if (!transactionId.equals("unknown")) {
			if (transactionExceptionCounterMap.get(transactionId) == null) 
				transactionExceptionCounterMap.put(transactionId, 1);
			else {
				transactionExceptionCounter = transactionExceptionCounterMap.get(transactionId) + 1;
				transactionExceptionCounterMap.put(transactionId, transactionExceptionCounter);
			}
			
			// send a final response, if this transactionID already exceeded the threshold
			if (transactionExceptionCounter >= transactionExceptionThreshold) {
				createErrorResponse(transactionType, transactionId, "FIF0028", exception + ": " + message, jmsCorrelationId, jmsReplyTo);
				logger.error("Sending error response after " + transactionExceptionThreshold + 
					" consecutive exceptions for transaction " + transactionId + ".");
				return TechnicalFailureAction.RESPONSE;
			}
			// put this message to the end of the queue, if the threshold isn't reached yet
			else {
				logger.error("Requeueing message for transaction " + transactionId + ".");
				return TechnicalFailureAction.REQUEUE;
			}
		}
		return TechnicalFailureAction.NONE;
	}
	
	protected synchronized void init() throws FIFException {
		encoding = ClientConfig.getSetting("transport.Encoding");
		connection = new QueueClientConnection();
		clientRequestReceiver = connection.getQueueReceiver(ClientConfig.getSetting("transport.RequestQueueName"));
		requeueingSender = connection.getQueueSenderForQueueName(ClientConfig.getSetting("transport.RequestQueueName"));
	}
	
	protected void processFifRequestMessage (String message,String jmsCorrelationId,String jmsReplyTo) throws FIFException {	    
		// Parse the request
		Request request = null;		
		StringBuffer beautifiedRequest = new StringBuffer();
		request = RequestSerializer.serializeFromString(message,
				beautifiedRequest, true);
		if(jmsCorrelationId !=null && jmsReplyTo != null){

			   request.addParam(new SimpleParameter("jmsCorrelationId", jmsCorrelationId));
			   request.addParam(new SimpleParameter("jmsReplyTo", jmsReplyTo));

		}
		 
		if (beautifiedRequest.length() == 0){
			writeInvalidRequestMessage(request, message);
			logger.error("An error occured during parsing the request.");
			createErrorResponse(request, "An error occured during parsing.", jmsCorrelationId, jmsReplyTo);
		} else {
			writeRequestMessage(request, beautifiedRequest);
			if (logger.isDebugEnabled())
				logger.debug("Parsed request: " + request.toString());
						
			processFifRequest(request, beautifiedRequest);
		}
	}

	protected void resendResponse(FifTransaction existingFifTransaction) throws FIFException {
		String clientResponse = existingFifTransaction.getClientResponse();
		if (clientResponse != null) {
			responseSender.sendResponse(existingFifTransaction);
			if (existingFifTransaction.getStatus().equals(SynchronousFifClient.FIF_TRANSACTION_STATUS_COMPLETED_FIF)) {
				existingFifTransaction.setStatus(SynchronousFifClient.FIF_TRANSACTION_STATUS_RESPONSE_SENT);
				fifTransactionDAO.updateFifTransaction(existingFifTransaction);
			}			
		}
	}
	
	protected void writeRequestMessage(Request request, StringBuffer beautifiedRequest) throws FIFException {
	    // Bail out if the message should not be written to a output file
	    if (!ClientConfig.getBoolean("SynchronousFifClient.WriteRequestMessages")) {
	        return;
	    }
	
	    String id = null;
	    boolean isList = false;
        if (request instanceof FIFRequest) {
    	    id = ((FIFRequest)request).getTransactionID();
        } else if (request instanceof FIFRequestList) {
    	    id = ((FIFRequestList)request).getID();
    	    isList=true;
        }
	    String fileName =
	        FileUtils.writeToOutputFile(
	        	beautifiedRequest.toString(),
	            ClientConfig.getPath("SynchronousFifClient.RequestOutputDir"),
	            "request-"+(isList ? "list-" + ((FIFRequestList)request).getName() : "") + "-" + id,
	            ".xml",
	            false);
	
	    logger.info("Wrote request message to: " + fileName);
	}
	
	protected void writeInvalidRequestMessage(Request request, String msgText) throws FIFException {
	    // Bail out if the message should not be written to a output file
	    if (!ClientConfig.getBoolean("SynchronousFifClient.WriteInvalidRequestMessages")) {
	        return;
	    }

	    String fileName =
	        FileUtils.writeToOutputFile(
	        	msgText,
	            ClientConfig.getPath("SynchronousFifClient.InvalidRequestDir"),
	            "invalid-request",
	            ".xml",
	            false);
	
	    logger.info("Wrote invalid request message to: " + fileName);
	}

	protected void createErrorResponse(Request request, String errorMsg, String jmsCorrelationId, String jmsReplyTo) throws FIFException {
		logger.info(jmsReplyTo+" createErrorResponse: " + jmsCorrelationId);
		String transactionId = null;
		if (request instanceof FIFRequest)
			transactionId = ((FIFRequest)request).getTransactionID();
		else if (request instanceof FIFRequestList)
			transactionId = ((FIFRequestList)request).getID();
		if (transactionId == null || transactionId.equals("unknown"))
			return;
		ArrayList errors = new ArrayList();
		String errorMessage = "Cannot create FIF message for request. Reason : " + errorMsg;
		errors.add(new FIFError("FIF-API", errorMessage));
		logger.error("Sending error response back to the front end, error message: " + errorMessage);
		
		sendErrorResponse(request.getAction(), transactionId, errors, jmsCorrelationId, jmsReplyTo);
	}

	protected void createErrorResponse(String action, String transactionId, String errorCode, String errorMessage, String jmsCorrelationId, String jmsReplyTo) throws FIFException {
		logger.info(jmsCorrelationId+" createErrorResponse: " + jmsReplyTo);
		ArrayList errors = new ArrayList();
		errors.add(new FIFError(errorCode, errorMessage));
		logger.error("Sending error response back to the front end, error code: " + errorCode + 
				", error message: " + errorMessage);
		sendErrorResponse(action, transactionId, errors, jmsCorrelationId, jmsReplyTo);
	}

	/**
	 * @param request
	 * @param trxId
	 * @param errors
	 * @throws FIFException
	 */
	private void sendErrorResponse(String action, String transactionId, ArrayList errors, String jmsCorrelationId, String jmsReplyTo) throws FIFException {
		logger.info(jmsCorrelationId+" sendErrorResponse: " + jmsReplyTo);
		QueueClientResponseMessage response = new QueueClientResponseMessage(
				QueueClientResponseMessage.FAILURE, action,
				transactionId, jmsCorrelationId, jmsReplyTo, errors);		
		responseSender.sendResponse(response);
	}
}
