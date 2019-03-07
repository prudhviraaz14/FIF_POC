package net.arcor.fif.transport;

import java.io.UnsupportedEncodingException;

import javax.jms.BytesMessage;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.TextMessage;

import net.arcor.fif.common.FIFException;

/**
 * This class contains utilities related to the transport package.
 * @author goethalo
 */
public class TransportUtils {

    /**
     * Extracts the text from a JMS message.
     * @param msg       the JMS message to extract the text from.
     *                  Currently supported types are <code>TextMessage</code> 
     *                  and <code>BytesMessagey</code>.
     * @param encoding  the text encoding that was used in the message.
     * @return the text contained in the JMS message.
     * @throws FIFException if the text cannot be extracted from the message.
     */
    public static String getMessageText(Message msg, String encoding)
        throws FIFException {
        if (msg == null) {
            throw new FIFException("Passed in message is null.");
        }
        String msgText = null;
        if (msg instanceof BytesMessage) {
            try {
                // Extract the text of the message
                byte[] buffer = new byte[256 * 1024];
                int length = 0;
                String msgString = "";
                while ((length = ((BytesMessage) msg).readBytes(buffer)) >0 ){
                	msgString += new String(buffer,0,length,encoding);
                }
                msgText = msgString.replaceAll("\n", "");
            } catch (UnsupportedEncodingException e) {
                throw new FIFException(
                    "Encoding not supported for BytesMessage: "
                        + msg.toString(),
                    e);
            } catch (JMSException e) {
                throw new FIFException(
                    "Cannot read text from BytesMessage: " + msg.toString(),
                    e);
            }
        } else if (msg instanceof TextMessage) {
            try {
                msgText = ((TextMessage) msg).getText();
            } catch (JMSException e) {
                throw new FIFException(
                    "Cannot read text from TextMessage: " + msg.toString(),
                    e);
            }
        } else {
            throw new FIFException(
                "Wrong message type received "
                    + "(should be a TextMessage or BytesMessage). "
                    + "Received Message: "
                    + msg.toString());
        }

        return msgText;
    }
}
