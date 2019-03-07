/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousQueueResponseSender.java-arc   1.8   Dec 18 2018 13:55:24   Lalitpise  $
 *    $Revision:   1.8  $
 *    $Workfile:   SynchronousQueueResponseSender.java  $
 *      $Author:   Lalitpise  $
 *        $Date:   Dec 18 2018 13:55:24  $
 *
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousQueueResponseSender.java-arc  $
 * 
 *    Rev 1.8   Dec 18 2018 13:55:24   Lalitpise
 * IT-K34257 ReplyTo Machanism defaulted to "Y".
 * 
 *    Rev 1.7   Nov 23 2010 13:36:42   wlazlow
 * IT-k-29265
 * 
 *    Rev 1.6   Nov 23 2010 13:01:08   wlazlow
 * IT-k-29265
 * 
 *    Rev 1.5   Nov 04 2010 17:03:02   schwarje
 * SPN-FIF-000105542: create a seperate queue session and connection for each QueueClientResponseSender
 * 
 *    Rev 1.4   Oct 18 2010 17:41:46   schwarje
 * SPN-FIF-000105542: do the commit in the synchronized part while sending responses
 * 
 *    Rev 1.3   Sep 14 2010 10:35:50   schwarje
 * fixed file name of log files
 * 
 *    Rev 1.2   Jul 06 2010 18:22:04   schwarje
 * CPCOM 2 updates
 * 
 *    Rev 1.1   May 25 2010 16:33:36   schwarje
 * IT-26029: updates
 * 
 * 
 ***************************************************************************  
 */
package net.arcor.fif.client;

import javax.jms.JMSException;
import javax.jms.Queue;
import javax.jms.QueueSender;
import javax.jms.Session;
import javax.jms.TemporaryQueue;
import javax.jms.TextMessage;

import com.ibm.mq.jms.MQQueueSession;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.db.FifTransaction;
import net.arcor.fif.messagecreator.Message;
import net.arcor.fif.transport.QueueClientConnection;


public class SynchronousQueueResponseSender extends ResponseSender {

	/**
	 * The client response sender.
	 */
	protected QueueSender clientResponseSender = null;

	/**
	 * The client response sender.
	 */
	protected QueueClientConnection connection = null;
	
	/**
	 * Initializes the message sender.
	 */
	protected void init() throws FIFException {
		connection = new QueueClientConnection();
		clientResponseSender = connection.getQueueSenderForQueueName(ClientConfig.getSetting("transport.ResponseQueueName"));
	}

	public SynchronousQueueResponseSender() throws FIFException {
		super();
		init();
	}
	
	public void sendResponse(Message response) throws FIFException { 
    	if (response instanceof QueueClientResponseListMessage)
    		writeResponseMessage(
    				((QueueClientResponseListMessage)response).getMessage(),
    				((QueueClientResponseListMessage)response).getName(),
    				((QueueClientResponseListMessage)response).getID());    	
    	else if (response instanceof QueueClientResponseMessage)
    		writeResponseMessage(
    				((QueueClientResponseMessage)response).getMessage(),
    				((QueueClientResponseMessage)response).getActionName(),
    				((QueueClientResponseMessage)response).getTransactionID());
    	else 
    		logger.warn("Unexpected class of response message: " + response.getClass().getName());
    	
        sendMessage(response.getMessage(),response.getJmsCorrelationId(),response.getJmsReplyTo());
    	
	}

	public void sendResponse(FifTransaction fifTransaction) throws FIFException {		
		if (fifTransaction.getClientResponse() == null)
			throw new FIFException("Response for transaction " + fifTransaction.getTransactionId() + 
					" is empty. Cannot resend response.");
							 
		   sendMessage(fifTransaction.getClientResponse(),fifTransaction.getJmsCorrelationId(),fifTransaction.getJmsReplyTo());
	}

	/**
	 * @throws JMSException
	 */
	private void commit() throws FIFException {
		try {
			connection.getSession().commit();
		} catch (JMSException e) {
			throw new FIFException(e);
		}
	}


	protected void writeResponseMessage(String message, String name, String id)throws FIFException {
        // Bail out if the message should not be written to a output file
        if (!ClientConfig
            .getBoolean("SynchronousFifClient.WriteResponseMessages")) {
            return;
        }

        String fileName =
            FileUtils.writeToOutputFile(message,
                ClientConfig.getPath("SynchronousFifClient.ResponseOutputDir"),
                "response-" + name + "-" + id,
                ".xml",
                false);

        logger.info("Wrote response message to: " + fileName);
	}

	
	private void sendMessage(String message,String jmsCorrelationId,String jmsReplyTo) throws FIFException {
		TextMessage textMsg = null;
        try {   	
        	String reply="Y";
        	try{
        		reply=ClientConfig.getSetting("transport.jmsReplyTo");
        	}catch(Throwable e){
        		logger.info(" ***sendMessage:::ERROR "+e);
        	}
        	
        	if(jmsCorrelationId != null 
        			&& jmsReplyTo !=null
        			&& reply.equals("Y")){
        		sendToReplyTo(message, jmsCorrelationId,jmsReplyTo);
        	}else{
        		textMsg = connection.getSession().createTextMessage();            
                textMsg.setText(message);
                clientResponseSender.send(textMsg);                    
            	commit();		        		
        	}
         } catch (JMSException e) {
        	 logger.info(" sendMessage:JMSException "+e);
            throw new FIFException(e);         
        }
       
       
	}
	private void sendToReplyTo(String message, String jmsCorrelationId,	String jmsReplyTo) throws FIFException {
		QueueSender tmp = connection.getQueueSender();
		try {			
			 QueueSender clientResponseSender2 = connection.getTempQueueSender(jmsReplyTo);
		     TextMessage textMsg = null;
		     textMsg = connection.getSession().createTextMessage();
			 textMsg.setText(message);
			
			 if (jmsCorrelationId != null)				
				     textMsg.setJMSMessageID(jmsCorrelationId);
		     clientResponseSender2.send(textMsg);
			 commit();				
			 clientResponseSender2.close();		
		} catch (JMSException e) {
			logger.info(" sendToReplyTo:JMSException "+e);
			throw new FIFException(e);
		}finally{
			 connection.setQueueSender(tmp);
		}
	}
}
