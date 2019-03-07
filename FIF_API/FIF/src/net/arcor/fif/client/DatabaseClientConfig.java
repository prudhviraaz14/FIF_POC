/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/client/DatabaseClientConfig.java-arc   1.4   Mar 02 2004 11:18:38   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/client/DatabaseClientConfig.java-arc  $
 * 
 *    Rev 1.4   Mar 02 2004 11:18:38   goethalo
 * SPN-CCB-000020494: Changed way property files are read.  Now the fully qualified property file name must be provided.
 * 
 *    Rev 1.3   Dec 17 2003 15:51:54   goethalo
 * IN-000018043: Made reading from resource file stricter.
 * 
 *    Rev 1.2   Oct 23 2003 10:00:26   goethalo
 * Changes for Apache DBCP.
 * 
 *    Rev 1.1   Jul 16 2003 14:55:20   goethalo
 * Changes for IT-9750.
 * 
 *    Rev 1.0   Apr 09 2003 09:34:28   goethalo
 * Initial revision.
*/
package net.arcor.fif.client;

import java.io.File;
import java.util.Properties;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.db.DatabaseConfig;

import org.apache.log4j.Logger;

/**
 * This class contains the configuration for the DatabaseConfig application.
 * @author goethalo
 */
public class DatabaseClientConfig {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(DatabaseClientConfig.class);

    /**
     * The properties to get the configuration settings from.
     */
    private static Properties props = null;

    /**
     * The database alias name to use to retrieve a connection from
     * the connection pool.
     */
    public static final String dbAlias =
        DatabaseConfig.JDBC_CONNECT_STRING_PREFIX + "requestdb";

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Initializes the <code>DatabaseClient</code> application.
     * @param configFile  the name of the property file to get the settings from.
     * @throws FIFException
     */
    public static synchronized void init(String configFile)
        throws FIFException {
        // Read the configuration
        props = FileUtils.readPropertyFile(configFile);
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

    /**
     * Gets a configuration setting from the configuration file.
     * @param key  the key to get the setting for.
     * @return the <code>int</code> value of the setting.
     * @throws FIFException if the key was not found in the configuration file.
     */
    public static int getInt(String key) throws FIFException {
        int value = 0;
        try {
            value = Integer.parseInt(getSetting(key));
        } catch (NumberFormatException nfe) {
            throw new FIFException(
                "Configuration value should be a number.  Key: " + key,
                nfe);
        }
        return (value);
    }
}
