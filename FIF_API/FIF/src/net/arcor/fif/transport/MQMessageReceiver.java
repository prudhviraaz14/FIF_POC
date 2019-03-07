/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/MQMessageReceiver.java-arc   1.2   Nov 26 2003 10:36:46   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/MQMessageReceiver.java-arc  $
 * 
 *    Rev 1.2   Nov 26 2003 10:36:46   goethalo
 * IN-000018341: Additional fixes.  Reading the MQ Bytes Message is now done in only one place.
 * 
 *    Rev 1.1   Nov 25 2003 13:55:08   goethalo
 * IN-000018341: Added code to remove all newline characters from response message.
 * 
 *    Rev 1.0   Apr 09 2003 09:34:48   goethalo
 * Initial revision.
*/
package net.arcor.fif.transport;

import javax.jms.BytesMessage;
import javax.jms.Message;

import net.arcor.fif.common.FIFException;

/**
 * Extension of the MessageReceiver containing MQ-specific code.
 * @author goethalo
 */
public class MQMessageReceiver extends MessageReceiver {

    /**
     * Constructor.
     * @param jmsClient
     */
    public MQMessageReceiver(JMSClient jmsClient) {
        super(jmsClient);
    }

    /**
     * Receives a message from the queue and converts it to a String.
     * This assumes that the message is a <code>BytesMessage</code>.
     * The method converst the <code>BytesMessage</code> to a <code>String</code>
     * using the encoding type that is set in the <code>JMSClient</code> object
     * related to this receiver.
     * This is needed to resolve some issues with MQSeries and text messages.
     * @return the <code>String</code> contained in the message
     * @throws FIFException if the message could not be received and converted.
     */
    public String receiveString() throws FIFException {
        // Receive the message
        Message msg = receiveMessage();

        // Make sure it is a BytesMessage
        if (msg instanceof BytesMessage) {
            return TransportUtils.getMessageText(
                msg,
                ((MQJMSClient) getJmsClient()).getEncoding());
        } else {
            throw new FIFException(
                "receiveString failed because the received "
                    + "message is not a TextMessage");
        }
    }

}
