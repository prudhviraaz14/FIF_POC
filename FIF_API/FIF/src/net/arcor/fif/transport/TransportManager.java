/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/transport/TransportManager.java-arc   1.4   May 07 2008 14:16:38   schwarje  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/transport/TransportManager.java-arc  $
 * 
 *    Rev 1.4   May 07 2008 14:16:38   schwarje
 * added logging for queue connection
 * 
 *    Rev 1.3   Mar 02 2004 11:19:06   goethalo
 * SPN-CCB-000020494: Changed way property files are read.  Now the fully qualified property file name must be provided.
 * 
 *    Rev 1.2   Dec 17 2003 16:20:18   goethalo
 * IN-000018043: Made reading from resource file stricter.
 * 
 *    Rev 1.1   Jul 16 2003 15:04:38   goethalo
 * Changes for IT-9750-
 * 
 *    Rev 1.0   Apr 09 2003 09:34:48   goethalo
 * Initial revision.
*/
package net.arcor.fif.transport;

import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.StringTokenizer;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;

import org.apache.log4j.Logger;

/**
 * This class implements functionality for managing JMS connections.
 * It contains methods for configuring the JMS Clients and for creating
 * message senders and receivers.
 * @author goethalo
 */
public class TransportManager {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(TransportManager.class);

    /**
     * Indicates whether this class has been initialized.
     */
    private static boolean initialized = false;

    /**
     * Contains the JMS Clients for each alias.
     */
    private static Map clients = null;

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Initializes the transport manager with the settings located in a
     * property file.
     * This method reads the resource bundle, retrieves all the transport-related
     * properties, and configures the transport manager based on these properties.
     * A property that is starting with 'transport' is considered to be a
     * transport-related property.
     * This method is useful because it allows to put the transport-related
     * properties in the same property file as the application.
     *
     * This method initializes and starts the JMSClient for each alias.
     *
     * @param props  the <code>Properties</code> to get the transport-related
     *               settings from
     * @throws FIFException
     */
    public static synchronized void init(Properties props)
        throws FIFException {
        // Check preconditions
        logger.info("Initializing transport manager...");
        if (initialized) {
            throw new FIFException(
                "The transport manager has already been " + "initialized");
        }
        if (props == null) {
            throw new FIFException(
                "Cannot initialize transport manager because null "
                    + "ResourceBundle was passed in");
        }

        // Get the list of defined aliases
        String aliasNames = props.getProperty("transport.aliases");
        if (aliasNames == null) {
            throw new FIFException(
                "Cannot initialize transport manager because"
                    + " no transport.aliases entry was found in the "
                    + "configuration file.");
        }

        // Loop through the list and create a JMSClient for each alias
        clients = new HashMap();
        StringTokenizer st = new StringTokenizer(aliasNames, ",", false);
        while (st.hasMoreTokens()) {
            JMSClient client = null;
            // Get the alias
            String alias = st.nextToken().trim();
            final String keyPrefix = "transport." + alias + ".";

            // Get the type
            String type = getSetting(props, keyPrefix + "QueueType", true);

            // Construct an JMSClient of the correct type
            if (type.trim().toUpperCase().equals("JMS")) {
                // Create a JMSClient with the queue name
                client =
                    new JMSClient(
                        getSetting(props, keyPrefix + "QueueName", true),
                        false,
                        getSetting(props, keyPrefix + "AcknowledgeMode", true));
                logger.debug("Created JMSClient for alias " + alias);
            } else if (type.trim().toUpperCase().equals("MQ")) {
                client =
                    new MQJMSClient(
                        getSetting(props, keyPrefix + "QueueName", true),
                        false,
                        getSetting(props, keyPrefix + "AcknowledgeMode", true),
                        getSetting(props, keyPrefix + "QueueManagerName", true),
                        getSetting(props, keyPrefix + "QueueManagerHostName", true),
                        getSetting(props, keyPrefix + "QueueManagerPortNumber", true),
                        getSetting(props, keyPrefix + "QueueManagerChannelName", true),
                        getSetting(props, keyPrefix + "QueueManagerTransportType", true),
                        getSetting(props, keyPrefix + "Encoding", true));
                logger.info("Creating connection to queue " + 
                		getSetting(props, keyPrefix + "QueueName", true) + 
                		" on queue manager " + 
                		getSetting(props, keyPrefix + "QueueManagerName", true));
                logger.debug("Created MQJMSClient for alias " + alias);
            } else {
                throw new FIFException(
                    "Cannot initialize transport manager "
                        + "because of unknown QueueType for alias: "
                        + alias);
            }

            // Setup and start the client
            client.setup();
            client.start();

            // Put the JMS client in the map
            clients.put(alias, client);
        }

        // Remember that we successfully initialized
        initialized = true;
        logger.info("Successfully initialized transport manager.");
    }

    /**
     * Initializes the transport manager based on a configuration file.
     * @param configFile  the qualified name of the configuration file.
     * @throws FIFException if the transport manager could not be initialized.
     */
    public static synchronized void init(String configFile)
        throws FIFException {
        // Pass through
        init(FileUtils.readPropertyFile(configFile));
    }

    /**
     * Shuts down the transport manager.
     * @throws FIFException if the transport manager could not be shut down.
     */
    public static synchronized void shutdown() throws FIFException {
        // Bail out if we did not initialize
        if (!initialized) {
            return;
        }

        logger.info("Shutting down transport manager...");

        // Shut down each client
        boolean success = true;
        Object[] clientList = clients.values().toArray();
        for (int i = 0; i < clientList.length; i++) {
            try {
                ((JMSClient) clientList[i]).shutdown();
            } catch (FIFException fe) {
                logger.error("Error while shutting down JMS client.", fe);
                success = false;
            }
        }
        if (success == true) {
            logger.info("Successfully shut down transport manager.");
        } else {
            logger.error("Errors while shutting down transport manager.");
        }
    }

    /**
     * Creates a MessageSender for a given alias name.
     * @param alias  the alias to get the sender for
     * @return a new <code>MessageSender</code> for the alias
     * @throws FIFException if the sender could not be created
     */
    public static MessageSender createSender(String alias)
        throws FIFException {
        // Get the JMSClient for the alias
        JMSClient client = (JMSClient) clients.get(alias);
        if (client == null) {
            throw new FIFException(
                "Cannot create a sender for alias "
                    + alias
                    + " because this alias name is unknown.");
        }

        // Create a sender of the correct type
        if (client instanceof MQJMSClient) {
            logger.debug("Created MQMessageSender for alias " + alias);
            return (new MQMessageSender(client));
        } else {
            logger.debug("Created MessageSender for alias " + alias);
            return (new MessageSender(client));
        }
    }

    /**
     * Creates a MessageReceiver for a given alias name.
     * @param alias  the alias to get the receiver for
     * @return a new <code>MessageReceiver</code> for the alias
     * @throws FIFException if the receiver could not be created
     */
    public static MessageReceiver createReceiver(String alias)
        throws FIFException {
        // Get the JMSClient for the alias
        JMSClient client = (JMSClient) clients.get(alias);
        if (client == null) {
            throw new FIFException(
                "Cannot create a receiver for alias "
                    + alias
                    + " because this alias name is unknown.");
        }

        // Create a receiver of the correct type
        if (client instanceof MQJMSClient) {
            logger.debug("Created MQMessageReceiver for alias " + alias);
            return (new MQMessageReceiver(client));
        } else {
            logger.debug("Created MessageReceiver for alias " + alias);
            return (new MessageReceiver(client));
        }
    }

    /**
     * Gets a setting from a configuration file.
     * @param props      the properties to get the setting from
     * @param key        the name of the setting to get
     * @param mandatory  indicates whether the setting is mandatory or not
     * @return a String containing the setting; a null String if the setting
     * was not found and is not mandatory
     * @throws FIFException if a mandatory setting is not found.
     */
    private static String getSetting(
        Properties props,
        String key,
        boolean mandatory)
        throws FIFException {
        String value = props.getProperty(key);
        if (value != null) {
            value = value.trim();
        } else {
            if (mandatory) {
                throw new FIFException(
                    "Cannot initialize transport manager because the following "
                        + "key is "
                        + "missing in the configuration file: "
                        + key);
            }
        }
        return value;
    }

    /**
     * @return boolean
     */
    public static boolean isInitialized() {
        return initialized;
    }

}
