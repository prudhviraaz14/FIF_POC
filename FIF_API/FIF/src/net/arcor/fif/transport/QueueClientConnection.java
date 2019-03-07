/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/transport/QueueClientConnection.java-arc   1.1   Nov 23 2010 13:02:42   wlazlow  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/transport/QueueClientConnection.java-arc  $
 * 
 *    Rev 1.1   Nov 23 2010 13:02:42   wlazlow
 * IT-k-29265
 * 
 *    Rev 1.0   Mar 04 2010 18:40:56   schwarje
 * Initial revision.
 * 
*/
package net.arcor.fif.transport;

import javax.jms.JMSException;
import javax.jms.QueueConnection;
import javax.jms.QueueReceiver;
import javax.jms.QueueSender;
import javax.jms.QueueSession;
import javax.jms.Session;

import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.common.FIFException;

import org.apache.log4j.Logger;

import com.ibm.mq.jms.JMSC;
import com.ibm.mq.jms.MQQueue;
import com.ibm.mq.jms.MQQueueConnectionFactory;

public class QueueClientConnection {

	private Logger logger = Logger.getLogger(QueueClientConnection.class);

	/**
	 * The queue session
	 */
	private QueueSession session = null;

	private QueueReceiver queueReceiver = null; 
	private QueueSender queueSender = null; 
		
	private static boolean isTransactionedSession;
	private static String ackMode;
	private static String queueManager;
	private static String queueHost;
	private static int queuePort;
	private static String queueChannel;

	public QueueClientConnection() throws FIFException {
		isTransactionedSession = ClientConfig.getBoolean("transport.TransactionedSession");
		ackMode = ClientConfig.getSetting("transport.AcknowledgeMode");
		queueManager = ClientConfig.getSetting("transport.QueueManagerName");
		queueHost = ClientConfig.getSetting("transport.QueueManagerHostName");
		queuePort = ClientConfig.getInt("transport.QueueManagerPortNumber");
		queueChannel = ClientConfig.getSetting("transport.QueueManagerChannelName");
		
		MQQueueConnectionFactory factory = new MQQueueConnectionFactory();
		try {
			factory.setQueueManager(queueManager);
			factory.setTransportType(JMSC.MQJMS_TP_CLIENT_MQ_TCPIP);
			factory.setHostName(queueHost);
			factory.setPort(queuePort);
			factory.setChannel(queueChannel);
			QueueConnection conn = factory.createQueueConnection();
			int messageAcknowledgeMode;
			if (ackMode.trim().toUpperCase().equals("CLIENT_ACKNOWLEDGE")) {
				messageAcknowledgeMode = Session.CLIENT_ACKNOWLEDGE;
			} else {
				messageAcknowledgeMode = Session.AUTO_ACKNOWLEDGE;
			}
			session = conn.createQueueSession(isTransactionedSession,messageAcknowledgeMode);
			conn.start();
			
		} catch (JMSException e) {
			throw new FIFException(e);
		}

		
	}
	
	public QueueReceiver getQueueReceiver(String queueName) throws FIFException {
		
		if (queueReceiver == null) {
			logger.info("Initializing queue receiver. Creating queue connection for: " +
					"QueueManagerName: " + queueManager + 
					", QueueManagerHostName: " + queueHost +
					", QueueManagerChannelName: " + queueChannel + 
					", QueueManagerPortNumber: " + queuePort +
					", QueueName: " +  queueName);
			try {
				MQQueue receiverQueue = (MQQueue) session.createQueue(queueName);
				receiverQueue.setTargetClient(JMSC.MQJMS_CLIENT_NONJMS_MQ);
				queueReceiver = session.createReceiver(receiverQueue);
			} catch (JMSException e) {
				throw new FIFException(e);
			}
		}
		return queueReceiver;
	}
	
	public QueueSender getQueueSenderForQueueName(String queueName) throws FIFException {
		

		if (queueSender == null) {
			logger.info("Initializing queue sender. Creating queue connection for: " +
					"QueueManagerName: " + queueManager + 
					", QueueManagerHostName: " + queueHost +
					", QueueManagerChannelName: " + queueChannel + 
					", QueueManagerPortNumber: " + queuePort +
					", QueueName: " +  queueName);
			
			try {
				MQQueue senderQueue = (MQQueue) session.createQueue(queueName);
				senderQueue.setTargetClient(JMSC.MQJMS_CLIENT_NONJMS_MQ);
				queueSender = session.createSender(senderQueue);
			} catch (JMSException e) {
				throw new FIFException(e);
			}
		}
		return queueSender;
		
	}
	
	
	public QueueSender getQueueSender() {				
		return queueSender;		
	}
	
	public void setQueueSender(QueueSender queueSender) {				
		this.queueSender=queueSender;		
	}
	
	
	public QueueSender getTempQueueSender(String queueName) throws FIFException {
		logger.info("Initializing temporary queue sender. Creating queue connection for: " +
				"QueueManagerName: " + queueManager + 
				", QueueManagerHostName: " + queueHost +
				", QueueManagerChannelName: " + queueChannel + 
				", QueueManagerPortNumber: " + queuePort +
				", QueueName: " +  queueName);

		
			try {
				MQQueue senderQueue = (MQQueue) session.createQueue(queueName);
				senderQueue.setTargetClient(JMSC.MQJMS_CLIENT_NONJMS_MQ);
				queueSender = session.createSender(senderQueue);
			} catch (JMSException e) {
				throw new FIFException(e);
			}
	       
		return queueSender;
		
	}

	public QueueSession getSession() {
		return session;
	}
}
