/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/MessageSender.java-arc   1.1   Aug 02 2004 15:26:24   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/MessageSender.java-arc  $
 * 
 *    Rev 1.1   Aug 02 2004 15:26:24   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.0   Apr 09 2003 09:34:48   goethalo
 * Initial revision.
*/
package net.arcor.fif.transport;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.QueueSender;
import javax.jms.TextMessage;

import net.arcor.fif.common.FIFException;

/**
 * Class for sending messages to a queue.
 * @author goethalo
 */
public class MessageSender {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The JMS Setup to be used by this sender.
     */
    private JMSClient jmsClient = null;

    /**
     * The sender to use for sending messages.
     */
    private QueueSender sender = null;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     * @param jmsClient  the JMS client to be used by this sender.
     */
    public MessageSender(JMSClient jmsClient) {
        this.jmsClient = jmsClient;
    }

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * Returns the JMS Client that is used by this sender.
     * @return JMSClient
     */
    public JMSClient getJmsClient() {
        return jmsClient;
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Initializes and starts the sender.
     * @throws FIFException if the sender could not be initialized.
     */
    public void start() throws FIFException {
        // Check precondition
        if (jmsClient == null) {
            throw new FIFException(
                "Cannot start MessageSender because no"
                    + " JMSClient object has been set.");
        }

        // Setup the JMS Client object
        jmsClient.setup();

        // Start the JMS Client
        jmsClient.start();

        // Create the sender
        sender = jmsClient.createSender();
    }

    /**
     * Sends a message to the queue.
     * @param msg  the message to be sent.
     * @throws FIFException if the message could not be sent.
     */
    public void sendMessage(Message msg) throws FIFException {
        // Check preconditions
        if (jmsClient == null) {
            throw new FIFException(
                "Cannot send message because no"
                    + " JMSSetup object has been initialized.");
        }
        if (sender == null) {
            throw new FIFException(
                "Cannot send message because no"
                    + " sender object has been initialized.");
        }
        if (msg == null) {
            throw new FIFException(
                "Cannot send message because passed"
                    + " in message object is null.");
        }

        // Send the message
        try {
            sender.send(msg);
        } catch (JMSException jmse) {
            throw new FIFException("Error while sending message", jmse);
        }
    }

    /**
     * Sends a <code>String</code> message to the queue.
     * The <code>String</code> is converted to a JMS text message
     * and then sent to the queue.
     * @param msg  the <code>String</code> to be sent.
     * @throws FIFException
     */
    public void sendMessage(String msg) throws FIFException {
        // Check preconditions
        if (jmsClient == null) {
            throw new FIFException(
                "Cannot send message because no"
                    + " JMSClient object has been initialized.");
        }

        // Create a text message
        TextMessage textMsg = null;
        try {
            textMsg = jmsClient.getSession().createTextMessage();
            textMsg.setText(msg);
        } catch (JMSException e) {
            throw new FIFException("Cannot create text message");
        }

        // Send the message
        sendMessage(textMsg);
    }

    /**
     * Shuts down the sender.
     * @throws FIFException if the sender could not be shut down.
     */
    public void shutdown() throws FIFException {
        // Close the sender
        if (sender != null) {
            try {
                sender.close();
            } catch (JMSException jmse) {
                throw new FIFException("Cannot close the sender.", jmse);
            }
        }

        // Shut down the JMSClient object
        if (jmsClient != null) {
            jmsClient.shutdown();
        }
    }

}
