/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/XSQLMessageCreatorConnectionManager.java-arc   1.1   Oct 23 2003 10:01:14   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/XSQLMessageCreatorConnectionManager.java-arc  $
 * 
 *    Rev 1.1   Oct 23 2003 10:01:14   goethalo
 * Changes for Apache DBCP.
 * 
 *    Rev 1.0   Apr 09 2003 09:34:46   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Hashtable;
import java.util.Map;

import net.arcor.fif.db.DatabaseConfig;

import org.apache.commons.dbcp.DelegatingConnection;
import org.apache.log4j.Logger;

import oracle.xml.xsql.XSQLConnection;
import oracle.xml.xsql.XSQLConnectionManager;
import oracle.xml.xsql.XSQLPageRequest;

/**
 * Database connection manager for the XSQL Message Creator.
 * This is needed to support encrypted database passwords
 * in the Oracle XSQL engine.
 * @author goethalo
 */
public class XSQLMessageCreatorConnectionManager
    implements XSQLConnectionManager {

    /**
     * The log4j logger
     */
    private static Logger logger =
        Logger.getLogger(XSQLMessageCreatorConnectionManager.class);

    /**
     * Constructor.
     */
    public XSQLMessageCreatorConnectionManager() {
    }

    /**
     * Counter to assign unique number to each connection
     */
    private static long connectionCount = 0;

    /**
     * Map containing the open connections
     */
    private static Map connections = new Hashtable();

    /**
     * Gets an XSQLConnection.
     * The XSQL connection is a wrapper around a connection coming from the
     * database pool.
     * @see oracle.xml.xsql.XSQLConnectionManager#getConnection(java.lang.String, oracle.xml.xsql.XSQLPageRequest)
     */
    public XSQLConnection getConnection(String arg0, XSQLPageRequest arg1)
        throws SQLException {
        String name = arg0 + connectionCount;
        logger.debug(
            "Getting an XSQLConnection from the pool. (name: " + name + ")...");

        // Get a connection from the pool
        Connection conn =
            DriverManager.getConnection(
                DatabaseConfig.JDBC_CONNECT_STRING_PREFIX + arg0);

        // Put this pooled connection in the map so we can close 
        // it in releaseConnection()                
        connections.put(name, conn);
        connectionCount++;

        // Extract the real connection from the pooled connection.
        // This is needed because the XSQL processor only works fine with an
        // Oracle JDBC driver.  If we would pass the pooled connection the XSQL
        // processor would not identify it as a real Oracle connection.
        DelegatingConnection dconn = (DelegatingConnection) conn;
        XSQLConnection xsqlConn = new XSQLConnection(dconn.getDelegate(), name);

        logger.debug("Successfully retrieved XSQLConnection from the pool.");
        return xsqlConn;
    }

    /**
     * Releases an XSQLConnection.
     * @see oracle.xml.xsql.XSQLConnectionManager#releaseConnection(oracle.xml.xsql.XSQLConnection, oracle.xml.xsql.XSQLPageRequest)
     */
    public void releaseConnection(XSQLConnection arg0, XSQLPageRequest arg1) {
        // Try to find the corresponding pooled connection
        Connection conn =
            (Connection) connections.get(arg0.getConnectionName());
        if (conn != null) {
            // Found it.  Close the pooled connection
            try {
                conn.close();
            } catch (SQLException e) {
            }
            // Remove the pooled connection from the map since it is not in
            // use anymore by the XSQL processor
            connections.remove(arg0.getConnectionName());
            logger.debug(
                "Released XSQLConnection from the pool (name: "
                    + arg0.getConnectionName()
                    + ")...");
        } else {
            logger.warn(
                "Cannot release XSQLConnection from the pool (name: "
                    + arg0.getConnectionName()
                    + ")...");
        }
    }
}
