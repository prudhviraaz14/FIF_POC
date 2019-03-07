/*
 $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/DatabaseConfig.java-arc   1.6   Jan 15 2019 16:49:22   lejam  $

 $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/DatabaseConfig.java-arc  $
 * 
 *    Rev 1.6   Jan 15 2019 16:49:22   lejam
 * SPN-FIF-000135751 Added DB connection verification
 * 
 *    Rev 1.5   Aug 02 2004 15:26:18   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.4   Mar 02 2004 11:18:48   goethalo
 * SPN-CCB-000020494: Changed way property files are read.  Now the fully qualified property file name must be provided.
 * 
 *    Rev 1.3   Dec 17 2003 16:06:28   goethalo
 * IN-000018043: Made reading from resource file stricter.
 * 
 *    Rev 1.2   Oct 23 2003 10:00:48   goethalo
 * Changes for Apache DBCP
 * 
 *    Rev 1.1   Jul 16 2003 14:57:42   goethalo
 * Changes for IT-9750
 * 
 *    Rev 1.0   Apr 09 2003 09:34:34   goethalo
 * Initial revision.
 */
package net.arcor.fif.db;

import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Properties;
import java.util.StringTokenizer;

import org.apache.commons.dbcp.ConnectionFactory;
import org.apache.commons.dbcp.DriverManagerConnectionFactory;
import org.apache.commons.dbcp.PoolableConnectionFactory;
import org.apache.commons.dbcp.PoolingDriver;
import org.apache.commons.pool.ObjectPool;
import org.apache.commons.pool.impl.GenericObjectPool;
import org.apache.log4j.Logger;

import net.arcor.fif.common.Cryptography;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;

/**
 * Class containing utilities to configure the database
 * pool.
 * @author goethalo
 */
public class DatabaseConfig {

	/*------------------*
	 * MEMBER VARIABLES *
	 *------------------*/

	/**
	 * The prefix to use in front of the alias name to get a JDBC connection from the pool.
	 */
	public final static String JDBC_CONNECT_STRING_PREFIX = "jdbc:apache:commons:dbcp:";

	/**
	 * The log4j logger.
	 */
	private static Logger logger = Logger.getLogger(DatabaseConfig.class);

	/**
	 * Indicates whether this class has been initialized.
	 */
	private static boolean initialized = false;

	/**
	 * Indicates whether the database passwords are encrypted.
	 */
	private static boolean encrypt = true;

	/*---------*
	 * METHODS *
	 *---------*/

	/**
	 * Sets whether encrypted database passwords are to be used.
	 * By default encryption is used.  Call this method before
	 * calling initDatabase if encryption should be disabled.
	 * @param encrypt
	 */
	public static void useEncryption(boolean encrypt) {
		DatabaseConfig.encrypt = encrypt;
	}

	/**
	 * Initializes the database with the settings set in
	 * a property file.
	 * This method reads the resource bundle, retrieves all the database-related
	 * properties, and configures the connection pool based on these properties.
	 * A property that is starting with 'db' is considered to be a database-
	 * related property.
	 * This method is useful because it allows to put the database properties in
	 * the same property file as the application.
	 *
	 * @param appProps  the <code>Properties</code> to get the database
	 *                  settings from
	 * @throws FIFException
	 */
	public static synchronized void init(Properties appProps) throws FIFException {
		// Check preconditions
		logger.info("Initializing database...");
		if (initialized) {
			throw new FIFException("The database has already been initialized");
		}
		if (appProps == null) {
			throw new FIFException("Cannot initialize database because null "
					+ "ResourceBundle was passed in");
		}

		// Get the list of defined aliases
		String aliasNames = appProps.getProperty("db.aliases");
		if (aliasNames == null) {
			throw new FIFException(
					"Cannot initialize database because"
							+ " no db.aliases entry was found in the configuration file.");
		}

		// Create a connection pool for each defined alias
		StringTokenizer st = new StringTokenizer(aliasNames, ",", false);
		while (st.hasMoreTokens()) {
			String alias = st.nextToken().trim();
			String keyPrefix = "db." + alias + ".";
			String driver = getSetting(appProps, keyPrefix + "Driver", true);
			String connectString = getSetting(appProps, keyPrefix
					+ "ConnectString", true);
			String user = getSetting(appProps, keyPrefix + "User", true);
			String password = getSetting(appProps, keyPrefix + "Password", true);
			String maximumConnectionCount = getSetting(appProps, keyPrefix
					+ "MaximumConnectionCount", false);
			int maxConnectionCountInt = 0;
			try {
				maxConnectionCountInt = Integer
						.parseInt(maximumConnectionCount);
			} catch (Exception e) {
			}

			// Create the Properties object for the apache pool
			Properties dbProps = new Properties();
			dbProps.put("user", user);

			if (encrypt) {
				// Decrypt the password
				String encryptionKey = getSetting(appProps, keyPrefix
						+ "EncryptionKey", true);
				password = Cryptography.ccbDecrypt(encryptionKey, password,
						true);
			}
			dbProps.put("password", password);

			try {
				// Register the real driver
				Class.forName(driver);

				// Create and register the connection pool
				ObjectPool connectionPool = new GenericObjectPool(null,
						maxConnectionCountInt,
						GenericObjectPool.WHEN_EXHAUSTED_FAIL,
						GenericObjectPool.DEFAULT_MAX_WAIT,
						GenericObjectPool.DEFAULT_MAX_IDLE);
				ConnectionFactory connectionFactory = new DriverManagerConnectionFactory(
						connectString, dbProps);
				PoolableConnectionFactory poolableConnectionFactory = new PoolableConnectionFactory(
						connectionFactory, connectionPool, null, null, false,
						true);
				Class.forName("org.apache.commons.dbcp.PoolingDriver");
				PoolingDriver poolingDriver = (PoolingDriver) DriverManager
						.getDriver("jdbc:apache:commons:dbcp:");
				poolingDriver.registerPool(alias, connectionPool);
			} catch (Exception e) {
				throw new FIFException(
						"Cannot create poolable connection factory for alias "
								+ alias, e);
			}
      
		    logger.info("Veryfing DB connection for alias:" + alias + " connectString:" + connectString + " user:" + user);
			try {
				Connection connectionCheck = DriverManager.getConnection(JDBC_CONNECT_STRING_PREFIX + alias);
				PreparedStatement connectionCheckStmt = connectionCheck.prepareStatement("select 1 from dual");
			} catch (SQLException sqle) {
				throw new FIFException("Cannot create database connection for " + alias, sqle);
			}

		}

		// Remember that we successfully initialized
		initialized = true;
		logger.info("Successfully initialized database.");
	}

	/**
	 * Initializes the database based on a configuration file.
	 * @param configFile  the qualified name of the configuration file.
	 * @throws FIFException if the database could not be initialized.
	 */
	public static synchronized void init(String configFile) throws FIFException {
		// Pass through
		init(FileUtils.readPropertyFile(configFile));
	}

	/**
	 * Shuts down the database connections.
	 * This method should be called before exiting the application.
	 * @throws FIFException
	 */
	public static synchronized void shutdown() throws FIFException {
		// Bail out if the database was not initialized
		if (initialized == false) {
			return;
		}
		logger.info("Shutting down database...");
		// Nothing to do here since we use the apache connection pool now
		initialized = false;
		logger.info("Successfully shut down database.");
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
	private static String getSetting(Properties props, String key,
			boolean mandatory) throws FIFException {
		String value = props.getProperty(key);
		if (value != null) {
			value = value.trim();
		} else {
			if (mandatory) {
				throw new FIFException(
						"Cannot initialize database because the following key is "
								+ "missing in the configuration file: " + key);
			}

		}
		return value;
	}

	/**
	 * Determines whether the database is initialized.
	 * @return true if the database is initialized, false if not.
	 */
	public static boolean isInitialized() {
		return initialized;
	}

}