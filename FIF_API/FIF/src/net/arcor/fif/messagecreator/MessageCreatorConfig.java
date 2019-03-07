/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/MessageCreatorConfig.java-arc   1.3   Mar 02 2004 11:18:54   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/MessageCreatorConfig.java-arc  $
 * 
 *    Rev 1.3   Mar 02 2004 11:18:54   goethalo
 * SPN-CCB-000020494: Changed way property files are read.  Now the fully qualified property file name must be provided.
 * 
 *    Rev 1.2   Dec 17 2003 16:08:20   goethalo
 * IN-000018043: Made reading from resource file stricter.
 * 
 *    Rev 1.1   Oct 07 2003 14:51:28   goethalo
 * Changes for IT-9811 - Internet By Call with Registration
 * 
 *    Rev 1.0   Apr 09 2003 09:34:38   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.io.File;
import java.util.Properties;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;

import org.apache.log4j.Logger;

/**
 * This class is responsible for configuring the FIF message creator.
 * It reads the configuration from the configuration files and
 * initializes the needed classes.
 * @author goethalo
 */
public class MessageCreatorConfig {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * Indicates whether this class has been initialized.
     */
    private static boolean initialized = false;

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(MessageCreatorConfig.class);

    /**
     * The properties to get the settings from.
     */
    private static Properties props = null;

    /**
     * Configuration settings
     */
    private static boolean writeToOutputFile = false;

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * Gets the properties.
     * @return  the properties.
     */
    public static Properties getConfigProperties() {
        return props;
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Initializes the MessageCreator module.
     * This reads the configuration file and initializes the message creator
     * metadata.  The file name set in the <code>configFile</code>
     * member variable is used to open the configuration file.
     * @throws FIFException if the class could not be properly initialized
     */
    public synchronized static void init(Properties props)
        throws FIFException {
        // Check preconditions
        if (initialized) {
            throw new FIFException("MessageCreator has already been initialized.");
        }

        // Log the startup of the application
        logger.info("Initializing FIF Message Creator...");

        // Set the config file
        MessageCreatorConfig.props = props;

        // Initialize the metadata
        MessageCreatorMetaData.init();

        logger.info("Successfully initialized FIF Message Creator.");

        // Set the initialized flag
        initialized = true;
    }

    /**
     * Shuts down the message creator configuration.
     */
    public static synchronized void shutdown() throws FIFException {
        // Bail out if the class has not been initialized.
        if (initialized == false) {
            return;
        }

        logger.info("Shutting down FIF Message Creator...");
        MessageCreatorMetaData.shutdown();
        logger.info("Successfully shut down FIF Message Creator.");

        initialized = false;
    }

    /**
     * Initializes the MessageCreator module.
     * This reads the configuration file and initializes the message creator
     * metadata.  The file name passed in the <code>configFile</code>
     * parameter is used to open the configuration file.
     * @param configFile  the name of the configuration file to use for
     * configuring the MessageCreator module.
     * @throws FIFException if the MessageCreator could not be
     * properly initialized.
     */
    public synchronized static void init(String configFile)
        throws FIFException {
        // Delegate the call
        init(FileUtils.readPropertyFile(configFile));
    }

    /**
     * Gets a configuration setting from the configuration file.
     * @param key  the key to get the setting for
     * @return a <code>String</code> containing the setting
     * @throws FIFException if the key was not found in the
     * configuration file.
     */
    public static String getSetting(String key) throws FIFException {
        String value = props.getProperty(key);
        if (value != null) {
            value = value.trim();
        } else {
            throw new FIFException(
                "Missing key in configuration file. Key: " + key);
        }
        return value;
    }

    /**
     * Gets a configuration setting from the configuration file
     * formatted as a path.
     * The absolute path of the settings is constructed, including the
     * ending slash.
     * @param key  the key to get the setting for
     * @return a <code>String</code> containing the absolute path.
     * @throws FIFException if the key was not found in the
     * configuration file.
     */
    public static String getPath(String key) throws FIFException {
        String path = new File(getSetting(key)).getAbsolutePath();
        if (!path.endsWith(System.getProperty("file.separator"))) {
            path += System.getProperty("file.separator");
        }
        return path;
    }

    /**
     * Gets a configuration setting from the configuration file.
     * @param key  the key to get the setting for.
     * @return true if the value of the key is "true", false if not.
     * @throws FIFException if the key was not found in the configuration file.
     */
    public static boolean getBoolean(String key) throws FIFException {
        return (getSetting(key).toLowerCase().equals("true"));
    }
}
