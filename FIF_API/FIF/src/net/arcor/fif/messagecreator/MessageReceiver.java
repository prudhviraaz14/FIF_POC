/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/MessageReceiver.java-arc   1.1   Jun 14 2004 15:43:08   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/MessageReceiver.java-arc  $
 * 
 *    Rev 1.1   Jun 14 2004 15:43:08   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.0   Apr 09 2003 09:34:38   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.transport.MQJMSClient;
import net.arcor.fif.transport.TransportManager;

import org.apache.log4j.Logger;

/**
 * This class contains methods for receiving <code>Message</code> objects that
 * have been put into the queue by FIF.
 * It is a thin wrapper around the functionality implemented in the
 * <code>net.arcor.fif.transport</code> package that provides additional
 * convenience methods for users of the <code>MessageCreator</code>.
 * <p>
 * <b>NOTE:</b> Before creating a <code>MessageReceiver</code> object the
 * <code>TransportManager</code> should be initialized.  This is done by
 * calling the <code>TransportManager.init<code> method and passing in the
 * name of the configuration file to read the transport settings from.
 * @author goethalo
 */
public class MessageReceiver {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(MessageReceiver.class);

    /**
     * The JMS Message Receiver to use for receiving messages.
     */
    private net.arcor.fif.transport.MessageReceiver receiver = null;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     * @param queueAlias  The alias name of the queue to construct this object
     *                     for.
     *                     The alias names are defined in the property file.
     * @throws FIFException if the object could not be created.
     */
    public MessageReceiver(String queueAlias) throws FIFException {
        // Make sure that the transport manager is initialized
        if (!TransportManager.isInitialized()) {
            throw new FIFException(
                "Cannot create MessageReceiver because the "
                    + "TransportManager is not initialized.");
        }

        // Get a new receiver  from the transport manager
        receiver = TransportManager.createReceiver(queueAlias);

        logger.debug(
            "Successfully constructed MessageReceiver for alias " + queueAlias);
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Starts the <code>MessageReceiver</code>.
     * This method should be called before any message is read from the queue.
     * @throws FIFException if the <code>MessageReceiver</code> could not be
     * started.
     */
    public void start() throws FIFException {
        // Start the sender
        logger.debug("Starting the MessageReceiver...");
        receiver.start();
        logger.debug("Successfully started the MessageReceiver.");
    }

    /**
     * Receives a <code>Message</code> from the queue.
     * @param timeOut  the time to wait for a message (in milliseconds).
     *                 Use a positive value for a normal timeout value,
     *                 0 for immediate timeout when there is no waiting message in
     *                 the queue, and a negative value if there is no timeout (i.e.
     *                 if the application should wait until there is a message)
     * @return the received <code>Message</code>, null if the time-out passed.
     * The type of the received message is a <code>FIFReplyMessage</code>.
     * @throws FIFException if the message could not be sent.
     */
    public Message receiveMessage(int timeOut) throws FIFException {
        // Receive the message
        javax.jms.Message msg = receiver.receiveMessage(timeOut);
        if (msg == null) {
            // We have a timeout. Bail out.
            return null;
        }

        // Create a Message containing the received data
        Message replyMsg =
            FIFReplyMessageFactory.createMessage(
                msg,
                ((MQJMSClient) receiver.getJmsClient()).getEncoding());

        // Log the received message
        if (logger.isDebugEnabled()) {
            logger.debug("Received reply message: " + replyMsg.getMessage());
        }

        // Return the message
        return replyMsg;
    }

    /**
     * Receives a message from the queue.
     * This method waits until a message is available in the queue and
     * returns it.
     * @return the received <code>Message</code>
     * @throws FIFException if the message could not be received.
     */
    public Message receiveMessage() throws FIFException {
        return receiveMessage(-1);
    }

    /**
     * Receives a message from the queue.
     * If a message is already waiting in the queue it is returned,
     * otherwise null is returned immediately.
     * @return the received <code>Message</code>, null if the time-out passed.
     * @throws FIFException if the message could not be received.
     */
    public Message receiveMessageNoWait() throws FIFException {
        return receiveMessage(0);
    }

    /**
     * Shuts down the <code>MessageReceiver</code>.
     * This method should be called when no more message have to be received
     * from the queue.  Typically this method is called before shutting down the
     * application.
     * @throws FIFException if the <code>MessageReceiver</code> could not be
     * shut down.
     */
    public void shutdown() throws FIFException {
        logger.debug("Shutting down the MessageReceiver...");
        receiver.shutdown();
        logger.debug("Successfully shut down the MessageReceiver.");
    }
}
