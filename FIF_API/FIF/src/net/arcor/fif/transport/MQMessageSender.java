/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/MQMessageSender.java-arc   1.0   Apr 09 2003 09:34:48   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/MQMessageSender.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:48   goethalo
 * Initial revision.
*/
package net.arcor.fif.transport;

import javax.jms.BytesMessage;
import javax.jms.JMSException;

import net.arcor.fif.common.FIFException;

/**
 * Extension of the MessageSender containing MQ-specific code.
 * @author goethalo
 */
public class MQMessageSender extends MessageSender {

    /**
     * Constructor.
     * @param jmsClient  the JMS client to be used by this sender.
     */
    public MQMessageSender(JMSClient jmsClient) {
        super(jmsClient);
    }

    /**
     * Sends a <code>String</code> message to the queue.
     * The <code>String</code> is converted to a JMS byte message
     * and then sent to the queue.
     * The passed in <code>String</code> object will be converted to
     * bytes using the encoding type specified in the <code>JMSClient</code>
     * object.
     * This is needed to resolve some issues with MQSeries and text messages.
     * @param msg       the text to be sent as a <code>BytesMessage</code>
     *                   to the queue
     * @throws FIFException if the message could not be sent.
     */
    public void sendMessage(String msg) throws FIFException {
        // Check preconditions
        MQJMSClient jmsClient = (MQJMSClient) getJmsClient();
        if (jmsClient == null) {
            throw new FIFException(
                "Cannot send message because no"
                    + " JMSClient object has been initialized.");
        }

        // Create a bytes message
        BytesMessage outMsg = null;
        try {
            outMsg = jmsClient.getSession().createBytesMessage();
        } catch (JMSException e) {
            throw new FIFException("Cannot create bytes message", e);
        }
        // Convert the string message to bytes and set it on the message
        try {
            outMsg.writeBytes(msg.getBytes(jmsClient.getEncoding()));
        } catch (Exception e) {
            throw new FIFException("Cannot convert message to bytes", e);
        }
        sendMessage(outMsg);
    }
}
