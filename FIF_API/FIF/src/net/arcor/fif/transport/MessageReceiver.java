/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/MessageReceiver.java-arc   1.0   Apr 09 2003 09:34:46   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/MessageReceiver.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:46   goethalo
 * Initial revision.
*/
package net.arcor.fif.transport;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.QueueReceiver;

import net.arcor.fif.common.FIFException;

/**
 * Class for receiving messages from a queue.
 * @author goethalo
 */
public class MessageReceiver {

	/*------------------*
	 * MEMBER VARIABLES *
	 *------------------*/

	/**
	 * The JMS Client to be used by this receiver.
	 */
	private JMSClient jmsClient = null;

	/**
	 * The receiver to use for receiving messages.
	 */
	private QueueReceiver receiver = null;

	/*--------------*
	 * CONSTRUCTORS *
	 *--------------*/

	/**
	 * Constructor.
	 * @param jmsClient  the JMS setup to be used by this receiver.
	 */
	public MessageReceiver(JMSClient jmsClient) {
		this.jmsClient = jmsClient;
	}

	/*---------------------*
	 * GETTERS AND SETTERS *
	 *---------------------*/

	/**
	 * Returns the JMS client that is used by this receiver.
	 * @return JMSClient
	 */
	public JMSClient getJmsClient() {
		return jmsClient;
	}

	/*---------*
	 * METHODS *
	 *---------*/

	/**
	 * Initializes and starts the receiver.
	 * @throws FIFException if the receiver could not be initialized.
	 */
	public void start() throws FIFException {
		// Check precondition
		if (jmsClient == null) {
			throw new FIFException(
				"Cannot start MessageReceiver because"
					+ " no JMS Client object has been set.");
		}

		// Setup the JMSSetup object
		jmsClient.setup();

		// Start the JMS connection
		jmsClient.start();

		// Create the receiver
		receiver = jmsClient.createReceiver();
	}

	/**
	 * Receives a message from the queue.
	 * @param timeOut  the time to wait for a message (in milliseconds).
	 *                 Use a positive value for a normal timeout value,
	 *                 0 for immediate timeout when there is no waiting message in
	 *                 the queue, and a negative value if there is no timeout (i.e.
	 *                 if the application should wait until there is a message)
	 * @return the received message, null if the time-out passed.
	 * @throws FIFException if the message could not be received.
	 */
	public Message receiveMessage(int timeOut) throws FIFException {
		// Check preconditions
		if (jmsClient == null) {
			throw new FIFException(
				"Cannot receive message because no"
					+ " JMSClient object has been initialized.");
		}
		if (receiver == null) {
			throw new FIFException(
				"Cannot receive message because no"
					+ " sender object has been initialized.");
		}

		// Receive the message
		Message msg = null;
		try {
			if (timeOut == 0) {
				msg = receiver.receiveNoWait();
			} else if (timeOut > 0) {
				msg = receiver.receive(timeOut);
			} else if (timeOut < 0) {
				msg = receiver.receive();
			}
		} catch (JMSException jmse) {
			throw new FIFException("Error while receiving message", jmse);
		}

		return msg;
	}

	/**
	 * Receives a message from the queue.
	 * This method waits until a message is available in the queue and
	 * returns it.
	 * @return the received message.
	 * @throws FIFException if the message could not be received.
	 */
	public Message receiveMessage() throws FIFException {
		return receiveMessage(-1);
	}

	/**
	 * Receives a message from the queue.
	 * If a message is already waiting in the queue it is returned,
	 * otherwise null is returned immediately.
	 * @return the received message, null if no message is waiting in the queue.
	 * @throws FIFException if the message could not be received.
	 */
	public Message receiveMessageNoWait() throws FIFException {
		return receiveMessage(0);
	}

	/**
	 * Shuts down the receiver.
	 * @throws FIFException if the receiver could not be shut down.
	 */
	public void shutdown() throws FIFException {
		// Close the receiver
		if (receiver != null) {
			try {
				receiver.close();
			} catch (JMSException jmse) {
				throw new FIFException("Cannot close the receiver.", jmse);
			}
		}

		// Shut down the JMSSetup object
		if (jmsClient != null) {
			jmsClient.shutdown();
		}
	}
}
