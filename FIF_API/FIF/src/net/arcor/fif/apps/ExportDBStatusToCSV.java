/*
 * $ Header: $
 *
 * $ Log: $
 */
package net.arcor.fif.apps;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Properties;
import java.util.StringTokenizer;

import org.apache.log4j.Logger;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.common.Log4jConfig;
import net.arcor.fif.db.DatabaseConfig;

/**
 * Class for exporting the status of the FIF requests to a CSV file.
 * @author goethalo
 *
 */
public class ExportDBStatusToCSV {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(ExportDBStatusToCSV.class);

    /**
     * The properties to get the configuration settings from.
     */
    private static Properties props = null;

    /**
     * The connection to use for the database.
     */
    private static Connection conn = null;

    /**
     * The insert statement for inserting a FIF request.
     */
    private static PreparedStatement retrieveRequestStmt = null;

    /**
     * The field name of the transaction ID field in the request table.
     */
    private static String transactionIDFieldName = null;

    /**
     * The field name of the status field in the request table.
     */
    private static String statusFieldName = null;

    /**
     * The field name of the error text field in the request table.
     */
    private static String errorTextFieldName = null;

    /**
     * The field name of the creation date field in the request table.
     */
    private static String creationDateFieldName = null;

    /**
     * The field name of the start date field in the request table.
     */
    private static String startDateFieldName = null;

    /**
     * The field name of the start date field in the request table.
     */
    private static String endDateFieldName = null;

    /**
     * The insert statement for inserting a FIF request parameter.
     */
    private static PreparedStatement retrieveParamStmt = null;

    /**
     * The field name of the parameter name field in the request parameter table.
     */
    private static String paramNameFieldName = null;

    /**
     * The field name of the parameter value field in the request parameter table.
     */
    private static String paramValueFieldName = null;

    /**
     * The database alias name to use to retrieve a connection from
     * the connection pool.
     */
    public static final String dbAlias =
        DatabaseConfig.JDBC_CONNECT_STRING_PREFIX + "requestdb";

    /**
     * The names of the parameters to be exported.
     */
    private static String exportParameterNames = null;

    /**
     * The names to be used for the parameter columns to be exported.
     */
    private static String exportColumnNames = null;

    /**
     * The parameters to put in the CSV columns.
     */
    private static ArrayList params = null;

    /**
     * The column names to use in the CSV report.
     */
    private static ArrayList columnNames = null;

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Initializes the application.
     * @throws FIFException
     */
    private static void init(String configFile, String clientConfigFile)
        throws FIFException {
        // Read the configuration
        props = FileUtils.readPropertyFile(configFile);

        // Initialize the logger
        Log4jConfig.init(props);

        logger.info(
            "Initializing application with property file "
                + configFile
                + "...");

        // Initialize the database
        logger.info(
            "Reading database configuration from client property file "
                + clientConfigFile);
        DatabaseConfig.init(clientConfigFile);

        // Prepare the statements
        try {
            logger.info("Preparing database statements...");
            conn = DriverManager.getConnection(dbAlias);
            conn.setAutoCommit(false);
            logger.info(
                "Preparing RetrieveRequestsStmt: "
                    + getSetting("ExportDBStatusToCSV.RetrieveRequestsStmt"));
            retrieveRequestStmt =
                conn.prepareStatement(
                    getSetting("ExportDBStatusToCSV.RetrieveRequestsStmt"));
            logger.info(
                "Preparing RetrieveParamsStmt: "
                    + getSetting("ExportDBStatusToCSV.RetrieveParamsStmt"));
            retrieveParamStmt =
                conn.prepareStatement(
                    getSetting("ExportDBStatusToCSV.RetrieveParamsStmt"));
        } catch (SQLException e) {
            throw new FIFException("Error while initializing CSV exporter.", e);
        }

        // Get the field indexes
        transactionIDFieldName =
            getSetting(
                "ExportDBStatusToCSV.RetrieveRequestsStatement."
                    + "TransactionIDFieldName");
        statusFieldName =
            getSetting(
                "ExportDBStatusToCSV.RetrieveRequestsStatement."
                    + "StatusFieldName");
        errorTextFieldName =
            getSetting(
                "ExportDBStatusToCSV.RetrieveRequestsStatement."
                    + "ErrorTextFieldName");
        creationDateFieldName =
            getSetting(
                "ExportDBStatusToCSV.RetrieveRequestsStatement."
                    + "CreationDateFieldName");
        startDateFieldName =
            getSetting(
                "ExportDBStatusToCSV.RetrieveRequestsStatement."
                    + "StartDateFieldName");
        endDateFieldName =
            getSetting(
                "ExportDBStatusToCSV.RetrieveRequestsStatement."
                    + "EndDateFieldName");
        paramNameFieldName =
            getSetting(
                "ExportDBStatusToCSV.RetrieveParamsStmt."
                    + "ParamNameFieldName");
        paramValueFieldName =
            getSetting(
                "ExportDBStatusToCSV.RetrieveParamsStmt."
                    + "ParamValueFieldName");

        // Get the export parameters and columns
        exportParameterNames =
            getSetting("ExportDBStatusToCSV.ExportParameterNames");
        exportColumnNames = getSetting("ExportDBStatusToCSV.ExportColumnNames");

        // Parse the export parameters
        params = new ArrayList();
        StringTokenizer st =
            new StringTokenizer(exportParameterNames, ",", false);
        while (st.hasMoreTokens()) {
            params.add(st.nextToken().trim());
        }

        // Parse the column names
        columnNames = new ArrayList();
        st = new StringTokenizer(exportColumnNames, ",", false);
        while (st.hasMoreTokens()) {
            columnNames.add(st.nextToken().trim());
        }

        logger.info("Successfully initialized application.");
    }

    /**
     * Shuts down the application.
     * @throws FIFException
     */
    private static void shutdown() {
        boolean success = true;
        logger.info("Shutting down application...");
        try {
            if (retrieveRequestStmt != null) {
                retrieveRequestStmt.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close statement.", e);
            success = false;
        }
        try {
            if (retrieveParamStmt != null) {
                retrieveParamStmt.close();
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
            // Shut down the database
            DatabaseConfig.shutdown();
        } catch (Exception e) {
            success = false;
            logger.error("Cannot shutdown database connection", e);
        }

        if (success) {
            logger.info("Successfully shut down application.");
        } else {
            logger.error("Errors while shutting down application.");
        }
    }

    /**
     * Creates a CSV report.
     * @throws FIFException if the report could not be created.
     */
    public static void createReport(String csvfile) throws FIFException {
        try {
            logger.info("Creating the CSV report...");
            // Create the CSV file
            BufferedWriter writer = new BufferedWriter(new FileWriter(csvfile));

            // Add the columns
            StringBuffer columns = new StringBuffer();
            for (int i = 0; i < columnNames.size(); i++) {
                if (i != 0) {
                    columns.append(";");
                }
                columns.append(columnNames.get(i));
            }
            columns.append("\n");
            writer.write(columns.toString());

            // Read the requests
            ResultSet requests = retrieveRequestStmt.executeQuery();

            while (requests.next()) {
                // Read all the request parameters
                String transactionID =
                    requests.getString(transactionIDFieldName);
                retrieveParamStmt.clearParameters();
                retrieveParamStmt.setString(1, transactionID);
                ResultSet foundParams = retrieveParamStmt.executeQuery();
                HashMap paramMap = new HashMap();
                while (foundParams.next()) {
                    paramMap.put(
                        foundParams.getString(paramNameFieldName),
                        foundParams.getString(paramValueFieldName));
                }

                // Create the CSV line
                StringBuffer values = new StringBuffer();
                for (int i = 0; i < params.size(); i++) {
                    if (i != 0) {
                        values.append(";");
                    }
                    String name = (String) params.get(i);
                    String value = null;
                    if (name.equals("@TRANSACTION_ID")) {
                        value = transactionID;
                    } else if (name.equals("@STATUS")) {
                        value = requests.getString(statusFieldName);
                    } else if (name.equals("@ERROR_TEXT")) {
                        value = requests.getString(errorTextFieldName);
                    } else if (name.equals("@CREATION_DATE")) {
                        value = requests.getString(creationDateFieldName);
                    } else if (name.equals("@START_DATE")) {
                        value = requests.getString(startDateFieldName);
                    } else if (name.equals("@END_DATE")) {
                        value = requests.getString(endDateFieldName);
                    } else {
                        value = (String) paramMap.get(name);
                    }

                    if (value != null) {
                        values.append("\"");
                        values.append(value);
                        values.append("\"");
                    }
                }
                values.append("\n");
                writer.write(values.toString());
            }

            // Close the CSV file
            writer.flush();
            writer.close();
            logger.info("Successfully created the CSV report.");
        } catch (IOException ioe) {
            throw new FIFException(
                "Cannot write to CSV file " + csvfile + ".",
                ioe);
        } catch (SQLException sqle) {
            throw new FIFException("Error while retrieving requests.", sqle);
        }
    }

    /**
     * Main.
     * @param args  the command-line arguments
     */
    public static void main(String[] args) {
        if (args.length == 0) {
            System.err.println("");
        }

        if (args.length < 1) {
            System.err.println(
                "ExportDBStatusToCSV: Exports the status of the FIF requests to a CSV file.\n");
            System.err.println("Usage: ExportDBStatusToCSV csvfilename.csv\n");
            System.exit(0);
        } // Set the config file name
        String configFile = "ExportDBStatusToCSV.properties";
        if (System.getProperty("fif.propertyfile") != null) {
            configFile = System.getProperty("fif.propertyfile");
        } // Set the database client config file
        String clientConfigFile = "SAPFIFDatabaseClient";
        if (System.getProperty("fif.clientpropertyfile") != null) {
            clientConfigFile = System.getProperty("fif.clientpropertyfile");
        }

        try {
            // Initialize the application
            init(configFile, clientConfigFile);
            // Insert the requests
            createReport(args[0]);
        } catch (Exception e) {
            logger.fatal("Cannot create CSV report.", e);
            e.printStackTrace();
        } finally {
            shutdown();
        }
    }

    /**
     * Gets a configuration setting from the configuration file.
     * @param key  the key to get the setting for
     * @return a <code>String</code> containing the setting
     * @throws FIFException if the key was not found in the
     * configuration file.
     */
    private static String getSetting(String key) throws FIFException {
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
     * Gets a configuration setting from the configuration file.
     * @param key  the key to get the setting for.
     * @return the <code>int</code> value of the setting.
     * @throws FIFException if the key was not found in the configuration file.
     */
    private static int getInt(String key) throws FIFException {
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
