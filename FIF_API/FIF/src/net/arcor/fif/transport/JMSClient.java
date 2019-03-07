/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/JMSClient.java-arc   1.1   Jan 30 2004 10:24:12   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/JMSClient.java-arc  $
 * 
 *    Rev 1.1   Jan 30 2004 10:24:12   goethalo
 * IN-000019704: Added related queue name to all exceptions.
 * 
 *    Rev 1.0   Apr 09 2003 09:34:46   goethalo
 * Initial revision.
*/
package net.arcor.fif.transport;

import javax.jms.JMSException;
import javax.jms.Queue;
import javax.jms.QueueConnection;
import javax.jms.QueueConnectionFactory;
import javax.jms.QueueReceiver;
import javax.jms.QueueSender;
import javax.jms.QueueSession;
import javax.jms.Session;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import net.arcor.fif.common.FIFException;

/**
 * This class contains functionality for setting up and starting a JMS
 * connection to a queue.
 * The implementations of the methods follow the official JMS way to create
 * and setup the different objects.  These methods can be overridden in a
 * derived class if non-JMS compliant behaviour is needed when for example
 * no naming and directory service is available.
 *
 * @author goethalo
 */
public class JMSClient {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The name of the queue to connect to
     */
    private String queueName = null;

    /**
     * Indicates if the object has been setup correctly.
     */
    private boolean setup = false;

    /**
     * The JNDI context to use for retrieving the
     * <code>QueueConnectionFactory</code> and <code>Queue</code> objects.
     */
    private Context jndiContext = null;

    /**
     * The connection factory to use for creating <code>QueueConnection</code>
     * objects.
     */
    private QueueConnectionFactory connectionFactory = null;

    /**
     * The queue.
     */
    private Queue queue = null;

    /**
     * The connection to the queue
     */
    private QueueConnection connection = null;

    /**
     * The session to use for the queue
     */
    private QueueSession session = null;

    /**
     * Indicates whether the session is transacted.
     */
    private boolean transactedSession = false;

    /**
     * The message acknowledge mode to use for the session.
     */
    private int messageAcknowledgeMode = Session.AUTO_ACKNOWLEDGE;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     * @param queueName               the name of the queue to set.
     * @param transactedSession       indicates whether this client is transacted.
     * @param messageAcknowledgeMode  indicates which message acknowledge mode
     *                                 to use. Valid values are
     *                                 AUTO_ACKNOWLEDGE and CLIENT_ACKNOWLEDGE.
     */
    public JMSClient(
        String queueName,
        boolean transactedSession,
        String messageAcknowledgeMode) {
        this.queueName = queueName;
        this.transactedSession = transactedSession;
        if (messageAcknowledgeMode
            .trim()
            .toUpperCase()
            .equals("CLIENT_ACKNOWLEDGE")) {
            this.messageAcknowledgeMode = Session.CLIENT_ACKNOWLEDGE;
        } else {
            this.messageAcknowledgeMode = Session.AUTO_ACKNOWLEDGE;
        }
    }

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * @return QueueConnection
     */
    public QueueConnection getConnection() {
        return connection;
    }

    /**
     * @return QueueConnectionFactory
     */
    public QueueConnectionFactory getConnectionFactory() {
        return connectionFactory;
    }

    /**
     * @return Context
     */
    public Context getJndiContext() {
        return jndiContext;
    }

    /**
     * @return String
     */
    public String getQueueName() {
        return queueName;
    }

    /**
     * @return QueueSession
     */
    public QueueSession getSession() {
        return session;
    }

    /**
     * @return int
     */
    public int getMessageAcknowledgeMode() {
        return messageAcknowledgeMode;
    }

    /**
     * Determines whether the session is transacted.
     * @return boolean
     */
    public boolean isTransactedSession() {
        return transactedSession;
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Sets up the JMS objects.
     * @throws FIFException if the setup failed.
     */
    public void setup() throws FIFException {
        // Set up the objects
        jndiContext = setupJndiContext();
        connectionFactory = setupQueueConnectionFactory();
        connection = setupQueueConnection();
        session = setupQueueSession();
        queue = setupQueue();

        // Set the flag to true
        setup = true;
    }

    /**
     * Starts the connection to the queue.
     * @throws FIFException if the connection could not be started.
     */
    public void start() throws FIFException {
        if (!setup) {
            throw new FIFException(
                "Cannot start the JMS client because "
                    + "the object was not setup correctly");
        }

        try {
            connection.start();
        } catch (JMSException jmse) {
            throw new FIFException(
                "Cannot start the JMS connection for queue name "
                    + getQueueName()
                    + ".",
                jmse);
        }
    }

    /**
     * Shuts down the JMS objects.
     * @throws FIFException if the shutdown failed.
     */
    public void shutdown() throws FIFException {
        try {
            if (connection != null) {
                connection.close();
                connection = null;
            }
            if (session != null) {
                session.close();
                session = null;
            }
        } catch (JMSException jmse) {
            throw new FIFException(
                "Cannot shutdown JMS objects for queue name "
                    + getQueueName()
                    + ".",
                jmse);
        }
    }

    /**
     * Creates a receiver for the queue session.
     * This implementation uses the standard JMS way to create the Receiver.
     * Override this method if special behaviour is needed.
     * @return the created <code>QueueReceiver</code> object.
     * @throws FIFException if the receiver could not be created.
     */
    public QueueReceiver createReceiver() throws FIFException {
        if (!setup) {
            throw new FIFException(
                "Cannot create the queue receiver because "
                    + "the JMS client was not setup correctly");
        }

        try {
            return session.createReceiver(queue);
        } catch (JMSException jmse) {
            throw new FIFException(
                "Cannot create the queue receiver for queue name "
                    + getQueueName()
                    + ".",
                jmse);
        }
    }

    /**
     * Creates a sender for the queue session.
     * @return the created <code>QueueSender</code> object.
     * @throws FIFException if the sender could not be created.
     */
    public QueueSender createSender() throws FIFException {
        if (!setup) {
            throw new FIFException(
                "Cannot create the queue sender because "
                    + "the JMS client was not setup correctly");
        }

        try {
            return session.createSender(queue);
        } catch (JMSException jmse) {
            throw new FIFException(
                "Cannot create the queue sender for queue name "
                    + getQueueName()
                    + ".",
                jmse);
        }
    }

    /**
     * Sets up the jndi context.
     * This implementation uses the standard JMS way to create the factory.
     * Override this method if special behaviour is needed.
     * @return the created <code>Context</code> object.
     * @throws FIFException if the jndi context could not be created.
     */
    protected Context setupJndiContext() throws FIFException {
        Context context = null;
        try {
            context = new InitialContext();
        } catch (NamingException ne) {
            throw new FIFException(
                "Cannot create the JNDI context for queue name "
                    + getQueueName()
                    + ".",
                ne);
        }
        return context;
    }

    /**
     * Sets up the queue connection factory.
     * This implementation uses the standard JMS way to create the factory.
     * Override this method if special behaviour is needed.
     * @return the created <code>QueueConnectionFactory</code> object.
     * @throws FIFException if the connection factory could not be created.
     */
    protected QueueConnectionFactory setupQueueConnectionFactory()
        throws FIFException {
        QueueConnectionFactory factory = null;
        try {
            factory =
                (QueueConnectionFactory) jndiContext.lookup(
                    "QueueConnectionFactory");
        } catch (NamingException ne) {
            throw new FIFException(
                "Cannot create the connection factory for queue name "
                    + getQueueName()
                    + ".",
                ne);
        }
        return factory;
    }

    /**
     * Sets up the queue.
     * This implementation uses the standard JMS way to create the queue.
     * Override this method if special behaviour is needed.
     * @return the created <code>Queue</code> object.
     * @throws FIFException if the queue could not be created.
     */
    protected Queue setupQueue() throws FIFException {
        Queue q = null;
        try {
            q = (Queue) jndiContext.lookup(queueName);
        } catch (NamingException ne) {
            throw new FIFException(
                "Cannot create the queue for queue name "
                    + getQueueName()
                    + ".",
                ne);
        }
        return q;
    }

    /**
     * Sets up the connection to the queue.
     * This implementation uses the standard JMS way to create the connection.
     * Override this method if special behaviour is needed.
     * @return the created <code>QueueConnection</code> object.
     * @throws FIFException if the queue connection could not be created.
     */
    protected QueueConnection setupQueueConnection() throws FIFException {
        QueueConnection conn = null;
        try {
            conn = connectionFactory.createQueueConnection();
        } catch (JMSException jmse) {
            throw new FIFException(
                "Cannot create the connection for queue name "
                    + getQueueName()
                    + ".",
                jmse);
        }
        return conn;
    }

    /**
     * Sets up the queue session.
     * This implementation uses the standard JMS way to create the session.
     * Override this method if special behaviour is needed.
     * @return the created <code>QueueSession</code> object.
     * @throws FIFException if the session could not be created.
     */
    protected QueueSession setupQueueSession() throws FIFException {
        QueueSession session = null;
        try {
            session =
                connection.createQueueSession(
                    isTransactedSession(),
                    getMessageAcknowledgeMode());
        } catch (JMSException jmse) {
            throw new FIFException(
                "Cannot create the session for queue name "
                    + getQueueName()
                    + ".",
                jmse);
        }
        return session;
    }

}
