/*
 * $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/FIFReplyMessageFactory.java-arc   1.5   Jan 25 2019 14:46:36   lejam  $
 *
 * $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/FIFReplyMessageFactory.java-arc  $
 * 
 *    Rev 1.5   Jan 25 2019 14:46:36   lejam
 * SPN-FIF-000135593 Added support of FIFReplyListMessage to createFailureMessage
 * 
 *    Rev 1.4   Feb 28 2008 15:25:54   schwarje
 * IT-20793: added processing of events
 * 
 *    Rev 1.3   Feb 06 2008 20:05:38   schwarje
 * IT-20058: update
 * 
 *    Rev 1.2   Jan 30 2008 08:26:36   schwarje
 * IT-20058: Redesign of FIF service bus client
 * 
 *    Rev 1.1   Sep 19 2005 15:23:04   banania
 * Added use of entity resolver for finding dtds.
 * 
 *    Rev 1.0   Jun 14 2004 15:42:02   goethalo
 * Initial revision.
 */
package net.arcor.fif.messagecreator;

import java.io.StringReader;

import javax.jms.BytesMessage;
import javax.jms.TextMessage;

import org.apache.log4j.Logger;
import org.apache.xerces.parsers.DOMParser;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.xml.sax.InputSource;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.ParsingErrorHandler;
import net.arcor.fif.transport.TransportUtils;

/**
 * Factory for creating <code>FIFReplyMessage</code> and 
 * <code>FIFReplyListMessage</code> objects
 * @author goethalo
 */
public final class FIFReplyMessageFactory {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/
    /**
     * The log4j logger.
     */
    private static Logger logger =
        Logger.getLogger(FIFReplyMessageFactory.class);

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Creates a <code>Message</code> object for a given JMS message.
     * The type of Message to create is determined based on the root node type of 
     * the XML document contained in the message.
     * @param msg       the JMS message to create a <code>Message</code> object for. 
     * @param encoding  the encoding of the JMS message
     * @return a <code>FIFReplyMessage</code> or 
     * <code>FIFReplyListMessage</code> object.
     * @throws FIFException if the message could not be created.
     */
    public static Message createMessage(javax.jms.Message msg, String encoding)
        throws FIFException {
        // Make sure it is a TextMessage or BytesMessage
        if (!((msg instanceof BytesMessage) || (msg instanceof TextMessage))) {
            throw new FIFException(
                "Wrong message type received "
                    + "(should be a TextMessage or BytesMessage.\n"
                    + "Received Message: "
                    + msg.toString());
        }

        // Get the message string
        String msgString = TransportUtils.getMessageText(msg, encoding);
        return createMessageHelper (msg, msgString);
    }
    
    /**
     * Creates a <code>Message</code> object for a given JMS message.
     * The type of Message to create is determined based on the root node type of 
     * the XML document contained in the message.
     * @param String  the message as String
     * @return a <code>FIFReplyMessage</code> or 
     * <code>FIFReplyListMessage</code> object.
     * @throws FIFException if the message could not be created.
     */
    public static Message createMessage(String msgString)
        throws FIFException {

    	return createMessageHelper (null, msgString);            
    }

	/**
	 * helper method to create and parse the message
	 * @param msgString
	 * @return
	 */
	private static Message createMessageHelper(javax.jms.Message msg, String msgString) {
		// Parse the message string
        String error = null;
        DOMParser parser = new DOMParser();
        try {
            ParsingErrorHandler handler = new ParsingErrorHandler();
            parser.setFeature("http://xml.org/sax/features/validation", true);
            parser.setErrorHandler(handler);
            parser.setEntityResolver(new EntityResolver());
            parser.parse(new InputSource(new StringReader(msgString)));

            if (handler.isError()) {
                error = "Cannot parse reply message:\n" + handler.getErrors();
            } else if (handler.isWarning()) {
                logger.warn(
                    "XML parser reported warnings:\n" + handler.getWarnings());
            }
        } catch (Exception e) {
            error = "Cannot parse reply message: " + e.toString();
        }

        if (error != null) {
            // Create invalid message and bail out.
            FIFReplyMessage reply = new FIFReplyMessage(msg, msgString, null);
            reply.setInvalid(error);
            return reply;
        }

        // Create and return the appropriate message type
        Document doc = parser.getDocument();
        Element root = doc.getDocumentElement();

        if (root.getTagName().equals(XMLTags.transactionRoot)) {
            return (new FIFReplyMessage(msg, msgString, doc));
        } else if (root.getTagName().equals(XMLTags.transactionListRoot)) {
            return (new FIFReplyListMessage(msg, msgString, doc));
        } else {
            // Create invalid message and bail out.
            FIFReplyMessage reply = new FIFReplyMessage(msg, msgString, doc);
            reply.setInvalid(
                "Reply message is of unknown type: " + root.getTagName());
            return reply;
        }
	}
    
    /**
     * Creates a <code>Message</code> object for a given JMS message.
     * The type of Message to create is determined based on the root node type of 
     * the XML document contained in the message.
     * @param String  the message as String
     * @return a <code>FIFReplyMessage</code> or 
     * <code>FIFReplyListMessage</code> object.
     * @throws FIFException if the message could not be created.
     */
    public static Message createFailureMessage(Request request, String errorCode, String errorText) {
    	Message reply = null;
    	if(request instanceof FIFRequest)
    		reply = new FIFReplyMessage(request, errorCode, errorText);
    	else if (request instanceof FIFRequestList)
    		reply = new FIFReplyListMessage((FIFRequestList)request, errorCode, errorText);
    	return reply;    	            
    }

}
