package net.arcor.fif.client;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import org.apache.log4j.Logger;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.db.DatabaseConfig;
import net.arcor.fif.messagecreator.FIFError;
import net.arcor.fif.messagecreator.MessageCreatorConfig;

/**
 * This class contains methods for retrieving and caching FIF error mappings. 
 * @author goethalo
 */
public class ErrorMapping {

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
    private static Logger logger = Logger.getLogger(ErrorMapping.class);

    /**
     * A map containing the error mappings.
     */
    private static Map mappings = Collections.synchronizedMap(new HashMap());

    /**
     * Indicates whether the error mapping is enabled.
     */
    private static boolean enabled = false;

    /**
     * Indicates whether the database was initialized by the init method.
     */
    private static boolean initializedDB = false;

    /**
     * The connection to use for the database.
     */
    private static Connection conn = null;

    /**
     * The statement to use for retrieving an error mapping.
     */
    private static PreparedStatement mappingStmt = null;

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Initializes the error mapping.
     * @param props  the properties to use for the configuration.
     * @throws FIFException if the error mapping could not be initialized.
     */
    public synchronized static void init(Properties props)
        throws FIFException {
        // Check preconditions
        if (initialized) {
            throw new FIFException("ErrorMapping has already been initialized.");
        }

        try {
            // Check if the error mapping is enabled
            enabled =
                MessageCreatorConfig.getBoolean(
                    "errormapping.EnableErrorMapping");
        } catch (FIFException fe) {
            // The setting does not exist. Assume that the error mapping 
            // is disabled.
            enabled = false;
        }

        if (enabled == false) {
            // The error mapping is disabled. Bail out...
            logger.info("Error mapping is disabled.");
            initialized = true;
            return;
        }

        // Initialize the error mapping
        logger.info("Error mapping is enabled. Initializing...");

        // Make sure that the database is initialized
        if (DatabaseConfig.isInitialized() == false) {
            DatabaseConfig.init(props);
            initializedDB = true;
        }

        // Get the database alias name
        String dbAlias =
            DatabaseConfig.JDBC_CONNECT_STRING_PREFIX
                + MessageCreatorConfig.getSetting(
                    "errormapping.ErrorMappingDatabaseAlias");

        // Get the select statement for retrieving an error mapping
        String stmt =
            MessageCreatorConfig.getSetting(
                "errormapping.RetrieveErrorMappingStatement");

        try {
            // Create the connection
            conn = DriverManager.getConnection(dbAlias);

            // Prepare the retrieval statement
            mappingStmt = conn.prepareStatement(stmt);
        } catch (SQLException e) {
            throw new FIFException(
                "Error while initializing error mapping.",
                e);
        }

        logger.info("Successfully initialized error mapping.");
        initialized = true;
    }

    /**
     * Initializes the error mapping based on a configuration file.
     * @param configFile  the qualified name of the configuration file.
     * @throws FIFException if the error mapping could not be initialized.
     */
    public static synchronized void init(String configFile)
        throws FIFException {
        // Read the configuration
        Properties config = FileUtils.readPropertyFile(configFile);

        // Pass through
        init(config);
    }

    /**
     * Shuts down the error mapping.
     */
    public static synchronized void shutdown() {
        // Bail out if the error mapping is not enabled.
        if (enabled == false) {
            return;
        }
        boolean success = true;
        logger.info("Shutting down error mapping...");
        try {
            if (mappingStmt != null) {
                mappingStmt.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close statement.", e);
            success = false;
        }
        try {
            if (conn != null) {
                conn.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close connection.", e);
            success = false;
        }
        try {
            if (initializedDB == true) {
                DatabaseConfig.shutdown();
            }
        } catch (FIFException fe) {
            logger.error("Cannot shuitdown database.", fe);
            success = false;
        }

        if (success == true) {
            logger.info("Successfully shut down error mapping.");
        } else {
            logger.error("Errors while shutting down error mapping.");
        }
    }

    /**
     * This method gets an error mapping for a given <code>FIFError</code> 
     * object.
     * @param error  the error object to get the error mapping for.
     * @return the <code>ErrorMapping</code> object. If no mapping was 
     *         found in the database, a copy of the FIFError is returned.
     * @throws FIFException if the error mapping could not be retrieved.
     */
    public static ErrorMappingEntry getErrorMapping(FIFError error)
        throws FIFException {
        // Bail out if the error mapping is disabled
        if (enabled == false) {
            return new ErrorMappingEntry(error.getNumber(), error.getMessage());
        }

        // Check if there is already a mapping in the map            
        ErrorMappingEntry entry =
            (ErrorMappingEntry) mappings.get(error.getNumber());

        if (entry != null) {
            // There is a mapping - return it.
            return entry;
        }

        try {
            // There is no mapping in the map. Retrieve it from the database.
            mappingStmt.setString(1, error.getNumber());
            ResultSet result = mappingStmt.executeQuery();
            if (result.next()) {
                // Found a mapping.  Create a new object and populate it.
                entry =
                    new ErrorMappingEntry(
                        error.getNumber(),
                        result.getString(1));
            } else {
                // No mapping was found.  Add a new object to the map so that
                // we do not go back to the database for this error later.
                entry =
                    new ErrorMappingEntry(
                        error.getNumber(),
                        error.getMessage());
            }

            // Add the mapping to the map.
            mappings.put(error.getNumber(), entry);
        } catch (SQLException sqle) {
            throw new FIFException(
                "Error while retrieving error mapping for error number: "
                    + error
                    + ".");
        }

        return entry;
    }
}
