/*
 * $ Header: $
 *
 * $ Log: $
 */
package net.arcor.fif.messagecreator;

import java.io.File;
import java.io.IOException;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Types;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.log4j.Logger;
import org.apache.xerces.dom.DOMImplementationImpl;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Text;

import net.arcor.fif.common.DOMSerializer;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.common.XSLTErrorListener;
import net.arcor.fif.db.DatabaseConfig;

/**
 * Message creator for the ISIS migration.
 * This creator executes a list of SQL statements to retrieve the
 * migration data.  It then represents this data in XML format and
 * passes this to an XSLT transformer.
 * 
 * @author goethalo
 *
 */
public class ISISMessageCreator extends FIFMessageCreator {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(ISISMessageCreator.class);

    /**
     * The name of the XSLT file to process.
     */
    String xsltFileName = null;

    /**
     * The XSLT transformer.
     */
    private Transformer transformer = null;

    /**
     * The XSLT error listener.
     */
    private XSLTErrorListener listener = null;

    /**
     * The Oracle date format.
     */
    private final SimpleDateFormat oracleDateFormat =
        new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.S");

    /**
     * The FIF date format.
     */
    private final SimpleDateFormat fifDateFormat =
        new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");

    /**
     * The initial select to retrieve the migration steps.
     */
    private static final String initialSelect =
        "SELECT * FROM im_migration_control WHERE customer_number = ? AND contract_number = ? ORDER BY stepid";

    /**
     * The list of selects to perform for each migration action.
     */
    private static final ISISMessageCreatorSQLInfo[] sqlInfo =
        new ISISMessageCreatorSQLInfo[] {

        // Create Order Form
        new ISISMessageCreatorSQLInfo(
            "CreateOrderForm",
            "im_create_order_form_params",
            "CREATE_ORDER_FORM"),

        // Create Comment                            
        new ISISMessageCreatorSQLInfo(
            "AddCseComment",
            "IM_ADD_CSE_COMMENT_PARAMS",
            "CREATE_COMMENT"),

        // Add Product Commitment                         
        new ISISMessageCreatorSQLInfo(
            "AddProductCommitment",
            "im_add_prod_comm_params",
            "ADD_PROD_COMM"),

        // Add Product Subscription                         
        new ISISMessageCreatorSQLInfo(
            "AddProductSubscription",
            "IM_ADD_PROD_SUBSCR_PARAMS",
            "ADD_PROD_SUBSCR"),

        // Add Service Subscription                          
        new ISISMessageCreatorSQLInfo(
            "AddServiceSubscription",
            "IM_ADD_SERV_SUBSCR_PARAMS",
            "ADD_SERV_SUBSCR",
            new ISISMessageCreatorSQLInfo[] {
            // Access Numbers
            new ISISMessageCreatorSQLInfo(
                "IM_ACCESS_NUMBER_PARAMS",
                "ACCESS_NUMBER"),
            // Service Location
            new ISISMessageCreatorSQLInfo(
                "IM_SERVICE_LOCATION_PARAMS",
                "SERVICE_LOCATION"),
            // Configured Values
            new ISISMessageCreatorSQLInfo(
                "IM_CONFIGURED_VALUE_PARAMS",
                "CONFIGURED_VALUE"),
            // Directory entries
            new ISISMessageCreatorSQLInfo(
                "IM_DIRECTORY_ENTRY_PARAMS",
                "DIRECTORY_ENTRY"),
            // Address Characteristics
            new ISISMessageCreatorSQLInfo(
                "IM_ADDRESS_CHAR_PARAMS",
                "ADDRESS")}),

        // Configure Price Plan Subscription                 
        new ISISMessageCreatorSQLInfo(
            "ConfigurePricePlanSubscription",
            "IM_CONFIG_PRICE_PLAN_PARAMS",
            "CONFIG_PRICE_PLAN",
            new ISISMessageCreatorSQLInfo[] {
            // Selected Destinations
            new ISISMessageCreatorSQLInfo(
                "IM_SELECTED_DESTINATION_PARAMS",
                "SELECTED_DESTINATION"),
            // Contributing Items
            new ISISMessageCreatorSQLInfo(
                "IM_CONTRIBUTING_ITEM_PARAMS",
                "CONTRIBUTING_ITEM")}),

        // Set state on service subscription                            
        new ISISMessageCreatorSQLInfo(
            "SetStateServSubscr",
            "IM_STATE_SERV_SUBSCR_PARAMS",
            "SET_STATE_SERV_SUBSCR"),

        // Reconfigure Service Subscription                            
        new ISISMessageCreatorSQLInfo(
            "ReconfigureServiceSubscription",
            "IM_RECONFIG_SERV_SUBSCR_PARAMS",
            "RECONFIG_SERV_SUBSCR"),

        // Sign Order Form                            
        new ISISMessageCreatorSQLInfo(
            "SignOrderForm",
            "IM_SIGN_ORDER_FORM_PARAMS",
            "SIGN_ORDER_FORM"),

        // Renegotiate Order Form                            
        new ISISMessageCreatorSQLInfo(
            "RenegotiateOrderForm",
            "IM_RENEGOTIA_ORDER_FORM_PARAMS",
            "RENEGOTIATE_ORDER_FORM"),

        // Terminate Order Form                            
        new ISISMessageCreatorSQLInfo(
            "TerminateOrderForm",
            "IM_TERMINATE_ORDER_FORM_PARAMS",
            "TERMINATE_ORDER_FORM")
        };

    /**
     * The initial select statement.
     */
    private PreparedStatement initialStmt = null;

    /**
     * The map containing the statements.
     */
    private Map statements = null;

    /**
     * The map containing the sql info.
     */
    private Map sqlInfoMap = null;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor
     * @param action
     * @throws FIFException
     */
    public ISISMessageCreator(String action) throws FIFException {
        super(action);
        init();
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Generates a message.
     * @see net.arcor.fif.messagecreator.MessageCreator#generateMessage(net.arcor.fif.messagecreator.Request)
     */
    protected Message generateMessage(Request request) throws FIFException {
        // Generating XML representation of retrieved data
        Document doc = generateXMLData(request);

        // Log and write the resulting XML document, if needed
        if ((MessageCreatorConfig
            .getBoolean("messagecreator.ISIS.WriteIntermediateFiles"))
            || (logger.isDebugEnabled())) {
            StringWriter sw = new StringWriter();
            try {
                DOMSerializer ds = new DOMSerializer();
                ds.serialize(doc, sw);
                if (logger.isDebugEnabled()) {
                    logger.debug(
                        "Generated XML representation of request:\n"
                            + sw.toString());
                }
                String transactionID =
                    ((SimpleParameter) request.getParam("transactionID"))
                        .getValue();
                writeXML(sw.toString(), transactionID);
            } catch (IOException e) {
                logger.error("Cannot write XML representation of request.", e);
            }
        }

        // Transform the document
        logger.debug("Transforming XML representation with XSLT...");
        StringWriter sw = new StringWriter();

        // Clear the errors from the listener
        listener.clear();

        try {
            // Transform the document
            transformer.transform(new DOMSource(doc), new StreamResult(sw));

            // Check the error listener
            if (listener.isError()) {
                throw new FIFException(
                    "XSLT transformer reported the following errors:\n"
                        + listener.getErrors());
            } else if (listener.isWarning()) {
                logger.warn(
                    "XSLT transformer reported warnings:\n"
                        + listener.getWarnings());
            }
        } catch (Exception e) {
            throw new FIFException(
                "Cannot transform Request. Action: "
                    + getAction()
                    + "XSLT File: "
                    + xsltFileName,
                e);
        }

        // Create the Message object
        return (new FIFMessage(sw.toString()));
    }

    /**
     * Gets additional data from the database and generates an XML representation of it.
     * @param request
     * @return
     */
    private Document generateXMLData(Request request) throws FIFException {
        // Create the DOM tree (and include the DTD name)
        DOMImplementation domImpl = new DOMImplementationImpl();
        Document doc = domImpl.createDocument(null, "ROWSET", null);
        Element root = doc.getDocumentElement();

        String transactionID =
            ((SimpleParameter) request.getParam("transactionID")).getValue();
        String customerNumber =
            ((SimpleParameter) request.getParam("CUSTOMER_NUMBER")).getValue();
        String contractNumber =
            ((SimpleParameter) request.getParam("CONTRACT_NUMBER")).getValue();
        String accountNumber =
            ((SimpleParameter) request.getParam("ACCOUNT_NUMBER")).getValue();
        String addressID =
            ((SimpleParameter) request.getParam("ADDRESS_ID")).getValue();

        // Log the start of the creation
        logger.info(
            "Creating ISIS message for action: "
                + getAction()
                + ", transaction ID: "
                + transactionID
                + "...");

        try {
            // Retrieve the actions
            initialStmt.clearParameters();
            initialStmt.setString(1, customerNumber);
            initialStmt.setString(2, contractNumber);
            ResultSet actions = initialStmt.executeQuery();
            int rowNum = 0;
            // Loop through the actions
            while (actions.next()) {
                // Create a node
                Element node = doc.createElement("ROW");
                node.setAttribute("num", Integer.toString(++rowNum));

                // Add the general info
                addElement(doc, node, "TRANSACTION_ID", transactionID);
                addElement(doc, node, "CUSTOMER_NUMBER", customerNumber);
                addElement(
                    doc,
                    node,
                    "CONTRACT_NUMBER",
                    actions.getString("CONTRACT_NUMBER"));
                addElement(doc, node, "ACCOUNT_NUMBER", accountNumber);
                addElement(doc, node, "ADDRESS_ID", addressID);

                // Add the parameter row to the node
                String actionName = actions.getString("ACTION");
                String stepID = actions.getString("STEPID");
                PreparedStatement paramStmt =
                    (PreparedStatement) statements.get(actionName);
                if (paramStmt != null) {
                    paramStmt.clearParameters();
                    paramStmt.setString(1, stepID);
                    ResultSet params = paramStmt.executeQuery();

                    if (params.next()) {
                        Element row =
                            addParamsNode(doc, node, actionName, params);

                        // Add child parameters if needed.
                        ISISMessageCreatorSQLInfo info =
                            (ISISMessageCreatorSQLInfo) sqlInfoMap.get(
                                actionName);
                        if ((info != null)
                            && (info.getChildSelects() != null)) {
                            for (int i = 0;
                                i < info.getChildSelects().length;
                                i++) {
                                ISISMessageCreatorSQLInfo childInfo =
                                    info.getChildSelects()[i];
                                PreparedStatement childParamStmt =
                                    (PreparedStatement) statements.get(
                                        actionName
                                            + "."
                                            + childInfo.getTableName());
                                if (childParamStmt != null) {
                                    childParamStmt.clearParameters();
                                    childParamStmt.setString(1, stepID);
                                    ResultSet childParams =
                                        childParamStmt.executeQuery();
                                    while (childParams.next()) {
                                        addParamsNode(
                                            doc,
                                            row,
                                            actionName
                                                + "."
                                                + childInfo.getTableName(),
                                            childParams);
                                    }
                                }

                            }
                        }

                    }
                }

                // Add the node to the root
                root.appendChild(node);
            }

        } catch (SQLException e) {
            throw new FIFException("Error while generating XML data.", e);
        }
        logger.info(
            "Successfully created ISIS message for action: "
                + getAction()
                + ", transaction ID: "
                + transactionID
                + ".");
        return doc;
    }

    /**
     * Adds a parameter node to a passed in node.
     * @param doc    the XML document.
     * @param node   the node to add the parameters to
     * @param params the ResultSet containing the parameters.
     */
    private Element addParamsNode(
        Document doc,
        Element node,
        String action,
        ResultSet params)
        throws SQLException {
        ISISMessageCreatorSQLInfo info =
            (ISISMessageCreatorSQLInfo) sqlInfoMap.get(action);
        Element element = doc.createElement(info.getTagName());
        Element row = doc.createElement(info.getTagName() + "_ROW");
        row.setAttribute("num", "1");

        // Loop through the fields
        ResultSetMetaData md = params.getMetaData();
        int columns = md.getColumnCount();
        for (int i = 0; i < columns; i++) {
            String name = md.getColumnName(i + 1);
            String value = null;

            if ((md.getColumnType(i + 1) == Types.DATE)
                || (md.getColumnType(i + 1) == Types.TIME)
                || (md.getColumnType(i + 1) == Types.TIMESTAMP)) {
                value = formatDate(params.getString(name));
            } else {
                value = params.getString(name);
            }
            if ((value != null) && !(value.trim().equals(""))) {
                addElement(doc, row, name.toUpperCase(), value);
            }
        }

        element.appendChild(row);
        node.appendChild(element);
        return row;
    }

    /**
     * Initializes the object.
     * @throws FIFException
     */
    private void init() throws FIFException {
        // Read the XSLT file
        File xsltFile = null;
        SimpleParameter param =
            (SimpleParameter) getCreatorParams().get("filename");
        xsltFileName =
            MessageCreatorConfig.getPath("messagecreator.ISIS.Directory")
                + param.getValue();
        xsltFile = new File(xsltFileName);
        if (!xsltFile.exists()) {
            throw new FIFException(
                "Cannot find XSLT file for Action: "
                    + getAction()
                    + ". Filename: "
                    + xsltFileName);
        }
        logger.debug("Using XSLT file: " + xsltFileName);

        // Create an XSLT transformer
        StreamSource xsltSource = new StreamSource(xsltFile);
        TransformerFactory transFact = TransformerFactory.newInstance();
        Templates cachedXSLT;
        try {
            cachedXSLT = transFact.newTemplates(xsltSource);
            transformer = cachedXSLT.newTransformer();
            listener = new XSLTErrorListener();
            transformer.setErrorListener(listener);
        } catch (TransformerConfigurationException e) {
            logger.error(
                "Error while creating XSLT transformer for action "
                    + getAction(),
                e);
            throw new FIFException(
                "Cannot create XSLT transformer for action " + getAction(),
                e);
        }

        // Create the prepared statements
        createPreparedStatements();
    }

    /**
     * Creates the prepared statements.
     */
    private void createPreparedStatements() throws FIFException {
        try {
            logger.info("Creating prepared statements...");
            // Get a database connection
            String dbAlias =
                MessageCreatorConfig.getSetting("messagecreator.ISIS.DBAlias");
            Connection conn =
                DriverManager.getConnection(
                    DatabaseConfig.JDBC_CONNECT_STRING_PREFIX + dbAlias);

            // Prepare the initial select statement
            initialStmt = conn.prepareStatement(initialSelect);

            // Populate the statement map
            statements = new HashMap();
            sqlInfoMap = new HashMap();
            for (int i = 0; i < sqlInfo.length; i++) {
                ISISMessageCreatorSQLInfo info = sqlInfo[i];
                String sqlStmt =
                    "SELECT * FROM "
                        + info.getTableName()
                        + " P WHERE P.STEPID=?";
                PreparedStatement stmt = conn.prepareStatement(sqlStmt);
                statements.put(info.getAction(), stmt);
                sqlInfoMap.put(info.getAction(), info);
                logger.debug("Prepared statement for " + info.getAction());

                if (info.getChildSelects() != null) {
                    for (int j = 0; j < info.getChildSelects().length; j++) {
                        ISISMessageCreatorSQLInfo childInfo =
                            info.getChildSelects()[j];
                        String childSqlStmt =
                            "SELECT * FROM "
                                + childInfo.getTableName()
                                + " P WHERE P.STEPID=?";
                        PreparedStatement childStmt =
                            conn.prepareStatement(childSqlStmt);
                        statements.put(
                            info.getAction() + "." + childInfo.getTableName(),
                            childStmt);
                        sqlInfoMap.put(
                            info.getAction() + "." + childInfo.getTableName(),
                            childInfo);
                        logger.debug(
                            "Prepared statement for "
                                + info.getAction()
                                + "."
                                + childInfo.getTableName());
                    }
                }
            }
        } catch (SQLException e) {
            throw new FIFException(
                "Error while creating prepared statements.",
                e);
        }

        logger.info("Successfully created prepared statements.");

    }

    /**
     * Writes the XML representation of the request to an output file.
     * The message is only written to the output file if the
     * <code>messagecreator.XSLT.WriteIntermediateFiles</code> flag in the
     * configuration file is set to <code>TRUE</code>.
     * @param xml  the xml to be written to a file.
     * @throws FIFException
     */
    private void writeXML(String xml, String transactionID)
        throws FIFException {
        // Bail out if the xml should not be written to a output file
        if (!MessageCreatorConfig
            .getBoolean("messagecreator.ISIS.WriteIntermediateFiles")) {
            return;
        }

        String fileName =
            FileUtils.writeToOutputFile(
                xml,
                MessageCreatorConfig.getPath(
                    "messagecreator.ISIS.IntermediateDir"),
                "intermediate-" + getAction() + "-" + transactionID,
                ".xml",
                false);

        logger.debug("Wrote intermediate XML file to: " + fileName);
    }

    /**
     * Adds an element to the document.
     *
     * @param doc     the document to add the element to.
     * @param parent  the parent to add the element to.
     * @param name    the name of the element to add.
     * @param value   the text value of the element to add.
     *                 use null if no text value should be added.
     * @return the newly added Element
     */
    private Element addElement(
        Document doc,
        Element parent,
        String name,
        String value) {
        // Create a new element
        Element element = doc.createElement(name);

        if (value != null) {
            // Create the text
            Text text = doc.createCDATASection(value);

            // Add the text
            element.appendChild(text);
        }

        // Append the element to the parent
        parent.appendChild(element);

        // Return the created element
        return element;
    }

    /**
     * Formats a date in FIF format.
     * @param inputDate
     * @return
     */
    private String formatDate(String inputDate) {
        Date date = null;
        if (inputDate == null) {
            return ("");
        }
        try {
            date = oracleDateFormat.parse(inputDate);
        } catch (ParseException e) {
            return ("");
        }

        // Return the date in FIF format            
        return (fifDateFormat.format(date));

    }
}
