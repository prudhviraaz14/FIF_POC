/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/Log4jConfig.java-arc   1.1   Mar 02 2004 11:18:46   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/Log4jConfig.java-arc  $
 * 
 *    Rev 1.1   Mar 02 2004 11:18:46   goethalo
 * SPN-CCB-000020494: Changed way property files are read.  Now the fully qualified property file name must be provided.
 * 
 *    Rev 1.0   Apr 09 2003 09:34:32   goethalo
 * Initial revision.
*/
package net.arcor.fif.common;

import java.util.Enumeration;
import java.util.Properties;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

/**
 * This class contains convenience methods to initialize and configure the
 * log4j logger.
 * @author goethalo
 */
public class Log4jConfig {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(Log4jConfig.class);

    /**
     * Indicates whether this class has been initialized.
     */
    private static boolean initialized = false;

    /**
     * First line inserted in the log file.
     */
    private final static String newLoggingSession =
        "-----------------------------------------------------------------"
            + "---------------";

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Initializes the logger based on the properties in a resource bundle.
     * This method reads the resource bundle, retrieves all the log4j-related
     * properties, and configures the logger based on these properties.
     * A property that is starting with 'log4j' is considered to be a log4j-
     * related property.
     * This method is useful because it allows to put the log4j properties in
     * the same property file as the application.
     *
     * @param props  the resource bundle to retrieve the log4j-related
     *               properties from.
     * @throws FIFException if the logger could not be initialized.
     */
    public static synchronized void init(Properties props)
        throws FIFException {
        // Check preconditions
        if (initialized) {
            throw new FIFException("The logger has already been initialized");
        }
        if (props == null) {
            throw new FIFException(
                "Cannot initialize logger because null "
                    + "ResourceBundle was passed in");
        }

        // Copy over the log4j-related properties to a Properties object
        Properties log4jprops = new Properties();
        Enumeration keys = props.propertyNames();
        while ((keys != null) && (keys.hasMoreElements())) {
            String key = (String) keys.nextElement();
            if (key.toLowerCase().startsWith("log4j")) {
                log4jprops.put(key, props.getProperty(key));
            }
        }
        // Pass these properties to log4j
        PropertyConfigurator.configure(log4jprops);

        // Remember that we successfully initialized
        initialized = true;
        logger.info(newLoggingSession);
        logger.info("Successfully initialized logger.");
    }

    /**
     * Initializes the logger based on a configuration file.
     * @param configFile  the qualified name of the configuration file.
     * @throws FIFException if the logger could not be initialized.
     */
    public static synchronized void init(String configFile)
        throws FIFException {
        // Pass through
        init(FileUtils.readPropertyFile(configFile));
    }
}
