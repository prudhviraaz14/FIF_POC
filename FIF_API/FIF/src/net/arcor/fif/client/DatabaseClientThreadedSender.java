/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/client/DatabaseClientThreadedSender.java-arc   1.1   Aug 02 2004 15:26:14   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/client/DatabaseClientThreadedSender.java-arc  $
 * 
 *    Rev 1.1   Aug 02 2004 15:26:14   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.0   Dec 08 2003 13:07:46   goethalo
 * Initial revision.
*/
package net.arcor.fif.client;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.messagecreator.MessageCreatorMetaData;
import net.arcor.fif.messagecreator.ParameterList;
import net.arcor.fif.messagecreator.ParameterListItem;
import net.arcor.fif.messagecreator.ParameterListMetaData;
import net.arcor.fif.messagecreator.ParameterMetaData;
import net.arcor.fif.messagecreator.Request;
import net.arcor.fif.messagecreator.RequestFactory;
import net.arcor.fif.messagecreator.SimpleParameter;

import org.apache.log4j.Logger;

/**
 * This class is responsible for sending FIF messages based on requests
 * in the database table.
 * It reads the requests from the database, creates a FIF message for this
 * request, and sends the message to FIF.
 * It additionally updates the state of the requests appropriately in the
 * request table.
 * This is the threaded version of the database client.  It allows using
 * multiple threads for sending messages.  This is usefull when the 
 * MessageCreator is relatively slow in generating FIF requests.
 *
 * @author goethalo
 */
public class DatabaseClientThreadedSender implements Runnable {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger =
        Logger.getLogger(DatabaseClientThreadedSender.class);

    /**
     * The connection to use for the database.
     */
    private Connection conn = null;

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement requestStmt = null;

    /**
     * The field name of the transaction ID in the request table.
     */
    private String requestTransactionIDFieldName = null;

    /**
     * The field name of the action in the request table.
     */
    private String requestActionFieldName = null;

    /**
     * The prepared statement for retrieving the request parameters
     */
    private PreparedStatement requestParamStmt = null;

    /**
     * The prepared statement for retrieving the request parameter lists.
     */
    private PreparedStatement requestParamListStmt = null;

    /**
     * The field index of the transaction ID in the statement.
     */
    private int requestParamListTransactionIDFieldIndex = 0;

    /**
     * The field index of the parameter list in the statement.
     */
    private int requestParamListParamListFieldIndex = 0;

    /**
     * The field name of the parameter in the parameter list table.
     */
    private String requestParamListParamFieldName = null;

    /**
     * The field name of the parameter value in the parameter list table.
     */
    private String requestParamListValueFieldName = null;

    /**
     * List containing the sending threads.
     */
    private ArrayList threads = null;

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Initializes the message sender.
     */
    public void init() throws FIFException {
        // Database-related setup
        try {
            // Create the prepared statements
            logger.info("Preparing database statements...");
            conn = DriverManager.getConnection(DatabaseClientConfig.dbAlias);
            conn.setAutoCommit(false);
            logger.info(
                "Preparing RetrieveRequestsStatement: "
                    + DatabaseClientConfig.getSetting(
                        "databaseclient.RetrieveRequestsStatement"));
            requestStmt =
                conn.prepareStatement(
                    DatabaseClientConfig.getSetting(
                        "databaseclient.RetrieveRequestsStatement"));
            // Set the batch size
            if (DatabaseClientConfig.getInt("databaseclient.RequestBatchSize")
                > 0) {
                logger.info(
                    "Set request batch size to "
                        + DatabaseClientConfig.getSetting(
                            "databaseclient.RequestBatchSize"));
                requestStmt.setMaxRows(
                    DatabaseClientConfig.getInt(
                        "databaseclient.RequestBatchSize"));
            }

            logger.info(
                "Preparing RetrieveParamsStatement: "
                    + DatabaseClientConfig.getSetting(
                        "databaseclient.RetrieveParamsStatement"));
            requestParamStmt =
                conn.prepareStatement(
                    DatabaseClientConfig.getSetting(
                        "databaseclient.RetrieveParamsStatement"));

            // Only prepare the param list statement if it is provided in
            // to configuration file.  This is needed for backwards compatibility
            boolean paramListStatementProvided = false;

            try {
                DatabaseClientConfig.getSetting(
                    "databaseclient.RetrieveParamListStatement");
                paramListStatementProvided = true;
            } catch (FIFException fe) {
                // Ignore, statement is not provided.
            }
            if (paramListStatementProvided) {
                logger.info(
                    "Preparing RetrieveParamListStatement: "
                        + DatabaseClientConfig.getSetting(
                            "databaseclient.RetrieveParamListStatement"));
                requestParamListStmt =
                    conn.prepareStatement(
                        DatabaseClientConfig.getSetting(
                            "databaseclient.RetrieveParamListStatement"));
                requestParamListTransactionIDFieldIndex =
                    DatabaseClientConfig.getInt(
                        "databaseclient."
                            + "RetrieveParamListStatement.TransactionIDFieldIndex");
                requestParamListParamListFieldIndex =
                    DatabaseClientConfig.getInt(
                        "databaseclient."
                            + "RetrieveParamListStatement.ParamListFieldIndex");
                requestParamListParamFieldName =
                    DatabaseClientConfig.getSetting(
                        "databaseclient."
                            + "RetrieveParamListStatement.ParamNameFieldName");
                requestParamListValueFieldName =
                    DatabaseClientConfig.getSetting(
                        "databaseclient."
                            + "RetrieveParamListStatement.ParamValueFieldName");

            }
        } catch (SQLException e) {
            throw new FIFException(
                "Error while initializing message sender",
                e);
        }

        // Field names
        requestTransactionIDFieldName =
            DatabaseClientConfig.getSetting(
                "databaseclient.RetrieveRequestsStatement."
                    + "TransactionIDFieldName");
        requestActionFieldName =
            DatabaseClientConfig.getSetting(
                "databaseclient.RetrieveRequestsStatement."
                    + "ActionFieldName");

        logger.info("Successfully initialized message sender.");
    }

    /**
     * Starts to process the requests from the database.
     * @see java.lang.Runnable#run()
     */
    public void run() {
        try {
            // Start the sending threads.
            startSendingThreads();

            boolean hasResult = true;
            while (!(Thread.interrupted())
                && !(DatabaseClient.inErrorStatus())) {
                // Retrieve the request to be processed
                if (hasResult) {
                    logger.info("Waiting for requests in database...");
                    logger.debug("Retrieving requests from the database...");
                }
                ResultSet result = requestStmt.executeQuery();

                // Process the requests
                hasResult = result.next();

                if (hasResult) {
                    logger.debug(
                        "Successfully retrieved requests from database.");
                    logger.info("Processing requests...");

                    do {
                        processRequest(
                            result
                                .getString(requestTransactionIDFieldName)
                                .trim(),
                            result.getString(requestActionFieldName));
                    } while (
                        (result.next()) && !(DatabaseClient.inErrorStatus()));

                    logger.info("Successfully processed requests.");
                }
                result.close();

                // Sleep...
                if (hasResult) {
                    logger.info(
                        "Sleeping before processing next batch of requests...");
                }
                Thread.sleep(
                    DatabaseClientConfig.getInt(
                        "databaseclient.RequestSleepTime"));
            }
        } catch (FIFException fe) {
            // Set the error status on the DatabaseClient object
            if (DatabaseClient.isShutDownHookInvoked() == false) {
                logger.fatal("Fatal error while processing requests", fe);
            }
            DatabaseClient.setErrorStatus();
        } catch (InterruptedException ie) {
            // Set the error status on the DatabaseClient object
            if (DatabaseClient.isShutDownHookInvoked() == false) {
                logger.fatal("DatabaseClientMessageSender interrupted", ie);
            }
            DatabaseClient.setErrorStatus();
        } catch (SQLException e) {
            // Set the error status on the DatabaseClient object
            if (DatabaseClient.isShutDownHookInvoked() == false) {
                logger.fatal(
                    "Fatal database error while processing requests",
                    e);
            }
            DatabaseClient.setErrorStatus();
        }
    }

    /**
     * Processes a database request.
     * Reads the parameters from the database, creates a message, and
     * sends this message to FIF
     * @param id      the ID of the request to be processed
     * @param action  the action to create the message for
     * @throws FIFException
     */
    public void processRequest(String id, String action) throws FIFException {
        try {
            logger.info(
                "Creating request for id: "
                    + id
                    + ", action: "
                    + action
                    + ".");
            // Define a null error string and null message
            String error = null;

            // Check if an action mapping exists for the passed in action
            Request request = null;

            if (MessageCreatorMetaData.hasActionMapping(action)) {
                // Create a request object
                request = RequestFactory.createRequest(action);
            } else {
                // Populate the error string with an error message.
                StringBuffer sb = new StringBuffer();
                sb.append("Cannot create message for request. ");
                sb.append("Reason: no action mapping found for action name ");
                sb.append("'");
                sb.append(action);
                sb.append("'.");
                error = sb.toString();
            }

            if (error == null) {
                // Set the action ID
                request.addParam(new SimpleParameter("transactionID", id));

                // Retrieve the parameters
                requestParamStmt.clearParameters();
                requestParamStmt.setString(1, id);
                ResultSet result = requestParamStmt.executeQuery();
                while (result.next()) {
                    // Add the parameter to the request
                    request.addParam(
                        new SimpleParameter(
                            result.getString(
                                DatabaseClientConfig.getSetting(
                                    "databaseclient.RetrieveParamsStatement."
                                        + "ParamNameFieldName")),
                            result.getString(
                                DatabaseClientConfig.getSetting(
                                    "databaseclient.RetrieveParamsStatement."
                                        + "ParamValueFieldName"))));
                }

                // Retrieve the parameter lists, if needed
                if (requestParamListStmt != null) {
                    // Get the parameter metadata
                    ArrayList paramMetadata = null;
                    paramMetadata =
                        MessageCreatorMetaData
                            .getActionMapping(action)
                            .getMessageParams();

                    // Loop through the parameter metadata and add the lists to the request
                    Iterator iter = paramMetadata.iterator();
                    while (iter.hasNext()) {
                        ParameterMetaData pmd = (ParameterMetaData) iter.next();
                        if (pmd instanceof ParameterListMetaData) {
                            ParameterList list =
                                new ParameterList(pmd.getName());

                            requestParamStmt.clearParameters();
                            requestParamListStmt.setString(
                                requestParamListTransactionIDFieldIndex,
                                id);
                            requestParamListStmt.setString(
                                requestParamListParamListFieldIndex,
                                pmd.getName());
                            result = requestParamListStmt.executeQuery();
                            while (result.next()) {
                                ParameterListItem item =
                                    new ParameterListItem();
                                item.addParam(
                                    new SimpleParameter(
                                        result.getString(
                                            requestParamListParamFieldName),
                                        result.getString(
                                            requestParamListValueFieldName)));
                                list.addItem(item);
                            }

                            request.addParam(list);
                        }
                    }
                }

                // Generate and send the message
                generateAndSendMessage(request);
            }
        } catch (SQLException e) {
            logger.error("Could not process request for id: " + id, e);
        } catch (FIFException fe) {
            logger.error(
                "Error while processing request for id: "
                    + id
                    + ", action: "
                    + action,
                fe);
            throw fe;
        }
    }

    /**
     * Starts the sending threads
     * @throws FIFException
     */
    private void startSendingThreads() throws FIFException {
        int threadCount =
            DatabaseClientConfig.getInt("databaseclient.NumberOfThreads");
        logger.info("Starting " + threadCount + " message sending threads.");
        threads = new ArrayList(threadCount);
        for (int i = 0; i < threadCount; i++) {
            Thread thread = new DatabaseClientSendingThread();
            thread.setName("sender-" + (i + 1));
            threads.add(thread);
            thread.start();
        }
    }

    /**
     * Delegates the generation and sending of a message to a
     * sending thread.
     * @param request  the request to be processed.
     * @throws FIFException
     */
    private void generateAndSendMessage(Request request) throws FIFException {
        try {
            logger.info("Waiting for available sending thread...");
            DatabaseClientSendingThread st = null;
            do  {
                for (int i = 0; i < threads.size(); i++) {
                    if (((DatabaseClientSendingThread) threads.get(i))
                        .getStatus()
                        == DatabaseClientSendingThread.STATUS_IDLE) {
                        logger.debug("Found available thread: " + ((Thread)threads.get(i)).getName());
                        st = (DatabaseClientSendingThread) threads.get(i);
                        logger.debug("Processing request");
                        st.processRequest(request);
                        break;
                    }
                }
                Thread.sleep(1);
            } while (st == null);
        } catch (InterruptedException ie) {
            throw new FIFException("Thread interrupted", ie);
        }
    }

    /**
     * Shuts down the object.
     */
    protected void shutdown() {
        logger.info("Shutting down message sender...");
        boolean success = true;
        // Shut down the sending threads
        if (threads != null) {
            for (int i = 0; i < threads.size(); i++) {
                ((Thread) threads.get(i)).interrupt();
            }
        }
        try {
            if (requestStmt != null) {
                requestStmt.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close statement.", e);
            success = false;
        }
        try {
            if (requestParamStmt != null) {
                requestParamStmt.close();
            }
        } catch (SQLException e) {
            logger.error("Cannot close statement.", e);
            success = false;
        }
        try {
            if (requestParamListStmt != null) {
                requestParamListStmt.close();
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

        if (success) {
            logger.info("Successfully shut down message sender.");
        } else {
            logger.error("Errors while shutting down message sender.");
        }
    }

}
