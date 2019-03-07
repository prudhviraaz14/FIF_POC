/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/examples/JDBCExample.java-arc   1.0   Apr 09 2003 09:34:36   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/examples/JDBCExample.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:36   goethalo
 * Initial revision.
*/
package net.arcor.fif.examples;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import net.arcor.fif.common.FIFException;

/**
 * Simple JDBC Example
 * @author goethalo
 */
public class JDBCExample {

    /*-------------------*
     * DATABASE SETTINGS *
     *-------------------*/

    /**
     * The JDBC driver name.
     */
    private final static String dbDriver = "oracle.jdbc.driver.OracleDriver";

    /**
     * The database connection string.
     * Format: jdbc:oracle:thin@HOST_NAME:PORT:DB_NAME
     */
    private final static String dbConnectionString =
        "jdbc:oracle:thin:@hpdbvb01:1535:oprccmtd";

    /**
     * The database user name.
     */
    private final static String dbUserName = "ccm_user";

    /**
     * The database user password
     */
    private final static String dbUserPassword = "sphinx";

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The database connection.
     */
    private static Connection conn = null;

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Initializes the database driver and connection.
     */
    public static void init() throws FIFException {
        // Initialize the database driver
        System.err.println("Initializing Database driver...");
        try {
            Class.forName(dbDriver);
        } catch (ClassNotFoundException cnfe) {
            throw new FIFException(
                "Cannot initialize the database driver. "
                    + "Embedded exception:",
                cnfe);
        }

        // Get the database connection
        System.err.println("Initializing Database connection...");
        try {
            conn =
                DriverManager.getConnection(
                    dbConnectionString,
                    dbUserName,
                    dbUserPassword);
        } catch (SQLException sqle) {
            throw new FIFException(
                "Cannot connect to the database. " + "Embedded exception:",
                sqle);
        }

    }

    /**
     * Example for selecting something from the database.
     * @throws FIFException
     */
    public void selectExample() throws FIFException {
        // Example SQL Select statement
        String select =
            "SELECT * from CUSTOMER WHERE CUSTOMER_NUMBER LIKE '%11'";

        // Define objects
        Statement stmt = null;
        ResultSet result = null;

        try {
            // Create a statement
            stmt = conn.createStatement();

            // Execute the statement
            result = stmt.executeQuery(select);

            // Loop through the results
            int count = 0;
            while (result.next()) {
                // Do some stuff
                count++;
                StringBuffer sb = new StringBuffer();
                sb.append("Select row: ");
                sb.append("CustomerNo:");
                sb.append(result.getString("CUSTOMER_NUMBER"));
                sb.append(", EffDate: ");
                sb.append(result.getString("EFFECTIVE_DATE"));
                sb.append(", StateRd: ");
                sb.append(result.getString("STATE_RD"));
                System.err.println(sb.toString());
            }
            System.err.println("Retrieved row count:" + count);
        } catch (SQLException se) {
            throw new FIFException("Could not perform select", se);
        } finally {
            // Cleanup - Very important because Oracle is not cleaning them
            // up automatically
            try {
                result.close();
            } catch (Exception e) {
                // Ignore
            }
            try {
                stmt.close();
            } catch (Exception e) {
                // Ignore
            }
        }
    }

    public void updateExample() throws FIFException {
        // Example SQL Update statement
        String update =
            "UPDATE CUSTOMER SET STATE_RD='ACTIVATED' WHERE CUSTOMER_NUMBER LIKE '%11' AND STATE_RD='ACTIVATED'";

        // Define objects
        Statement stmt = null;

        try {
            // Create a statement
            stmt = conn.createStatement();

            // Execute the statement
            int updatedRows = stmt.executeUpdate(update);

            System.err.println("Updated row count:" + updatedRows);
        } catch (SQLException se) {
            throw new FIFException("Could not perform update", se);
        } finally {
            // Cleanup - Very important because Oracle is not cleaning them
            // up automatically
            try {
                stmt.close();
            } catch (Exception e) {
                // Ignore
            }
        }
    }

    /**
     * JDBC Example application
     * @param args
     */
    public static void main(String[] args) {
        try {
            // Initialize the class
            JDBCExample.init();

            // Get a new instance of the class
            JDBCExample jdbcEx = new JDBCExample();

            // Execute the select
            jdbcEx.selectExample();

            // Execute the update
            jdbcEx.updateExample();
        } catch (FIFException fe) {
            System.err.println("Error occured: ");
            fe.printStackTrace();
        }

    }
}
