/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/MQJMSClient.java-arc   1.1   Jan 30 2004 10:24:02   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/MQJMSClient.java-arc  $
 * 
 *    Rev 1.1   Jan 30 2004 10:24:02   goethalo
 * IN-000019704: Added related queue name to all exceptions.
 * 
 *    Rev 1.0   Apr 09 2003 09:34:48   goethalo
 * Initial revision.
*/
package net.arcor.fif.transport;

import javax.jms.JMSException;
import javax.jms.Queue;
import javax.jms.QueueConnectionFactory;
import javax.naming.Context;

import com.ibm.mq.jms.JMSC;
import com.ibm.mq.jms.MQQueue;
import com.ibm.mq.jms.MQQueueConnectionFactory;

import net.arcor.fif.common.FIFException;

/**
 * This class extends the JMSClient class and adds MQSeries-specific behaviour.
 * This behaviour is needed because currently no JNDI naming service is
 * available in the Arcor environment.
 *
 * @author goethalo
 */
public class MQJMSClient extends JMSClient {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The channel name of the MQ queue manager to use.
     */
    private String queueManagerChannelName = null;

    /**
     * The host name of the MQ queue manager to use.
     */
    private String queueManagerHostName = null;

    /**
     * The name of the MQ queue manager to use.
     */
    private String queueManagerName = null;

    /**
     * The port number of the MQ queue manager to use.
     */
    private String queueManagerPortNumber = null;

    /**
     * The MQ transport type to use.
     */
    private String queueManagerTransportType = null;

    /**
     * The character encoding to use for the messages.
     */
    private String encoding = null;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     * @param queueName                  the name of the MQ queue to connect
     *                                   to.
     * @param queueManagerName           the name of the MQ queue manager.
     * @param transactedSession          indicates whether this client is transacted.
     * @param messageAcknowledgeMode     indicates which message acknowledge mode
     *                                   to use. Valid values are
     *                                   AUTO_ACKNOWLEDGE and CLIENT_ACKNOWLEDGE.
     * @param queueManagerHostName       the host name where the MQ queue
     *                                   manager resides.
     * @param queueManagerPortNumber     the port number the MQ queue manager
     *                                   listens to.
     * @param queueManagerChannelName    the channel name of the
     *                                   MQ queue manager to use.
     * @param queueManagerTransportType  the transport type to use for the
     *                                   MQ queue manager.
     * @param encoding                   the character encoding to use for the
     *                                    messages that are sent and received
     *
     */
    public MQJMSClient(
        String queueName,
        boolean transactedSession,
        String messageAcknowledgeMode,
        String queueManagerName,
        String queueManagerHostName,
        String queueManagerPortNumber,
        String queueManagerChannelName,
        String queueManagerTransportType,
        String encoding) {
        super(queueName, transactedSession, messageAcknowledgeMode);
        this.queueManagerName = queueManagerName;
        this.queueManagerHostName = queueManagerHostName;
        this.queueManagerPortNumber = queueManagerPortNumber;
        this.queueManagerChannelName = queueManagerChannelName;
        this.queueManagerTransportType = queueManagerTransportType;
        this.encoding = encoding;
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Sets up the jndi context.
     * This implementation returns null because JNDI is not supported
     * in the Arcor environment.
     * @return null
     */
    protected Context setupJndiContext() throws FIFException {
        return null;
    }

    /**
     * Sets up the queue.
     * This implementation uses the Arcor-specific way to create the queue
     * because JNDI is not supported in the Arcor environment.
     * The queue is created from the session object.
     * @return the created <code>Queue</code> object.
     * @throws FIFException if the queue could not be created.
     */
    protected Queue setupQueue() throws FIFException {
        MQQueue q = null;
        try {
            q = (MQQueue) getSession().createQueue(getQueueName());
            q.setTargetClient(JMSC.MQJMS_CLIENT_NONJMS_MQ);
        } catch (JMSException jmse) {
            throw new FIFException(
                "Cannot create the queue for queue name "
                    + getQueueName()
                    + ".",
                jmse);
        }
        return q;
    }

    /**
     * Sets up the queue connection factory.
     * This implementation uses the Arcor-specific way to create the factory
     * because JNDI is not supported in the Arcor environment.
     * @return the created <code>QueueConnectionFactory</code> object.
     * @throws FIFException if the connection factory could not be created.
     */
    protected QueueConnectionFactory setupQueueConnectionFactory()
        throws FIFException {
        MQQueueConnectionFactory factory = null;
        try {
            factory = new MQQueueConnectionFactory();
            factory.setQueueManager(queueManagerName);
            if (queueManagerTransportType.equalsIgnoreCase("BINDINGS")) {
                factory.setTransportType(JMSC.MQJMS_TP_BINDINGS_MQ);
            } else {
                factory.setTransportType(JMSC.MQJMS_TP_CLIENT_MQ_TCPIP);
                factory.setHostName(queueManagerHostName);
                factory.setPort(Integer.parseInt(queueManagerPortNumber));
                factory.setChannel(queueManagerChannelName);
            }
        } catch (JMSException jmse) {
            throw new FIFException(
                "Cannot create the connection factory for queue name "
                    + getQueueName()
                    + ".",
                jmse);
        }

        return factory;
    }

    /**
     * @return String
     */
    public String getEncoding() {
        return encoding;
    }

}
