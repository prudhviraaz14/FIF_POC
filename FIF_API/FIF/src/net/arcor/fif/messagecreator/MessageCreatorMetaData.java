/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/MessageCreatorMetaData.java-arc   1.10   Nov 21 2013 08:51:52   schwarje  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/MessageCreatorMetaData.java-arc  $
 * 
 *    Rev 1.10   Nov 21 2013 08:51:52   schwarje
 * IT-k-32850: generic validation of input parameters configured in metadata (first use case: CCB date format)
 * 
 *    Rev 1.9   Jun 18 2010 17:42:32   schwarje
 * changes for CPCOM Phase 2: new FIF client type accepting SOM orders
 * 
 *    Rev 1.8   Sep 19 2005 15:23:38   banania
 * Added use of entity resolver for finding dtds.
 * 
 *    Rev 1.7   Aug 02 2004 15:26:20   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.6   Mar 02 2004 11:18:54   goethalo
 * SPN-CCB-000020494: Changed way property files are read.  Now the fully qualified property file name must be provided.
 * 
 *    Rev 1.5   Dec 17 2003 14:56:06   goethalo
 * Changes for IT-9245: ISDN changes.
 * 
 *    Rev 1.4   Dec 04 2003 15:04:04   goethalo
 * Removed call the setReadOnly. (Not supported by new Oracle JDBC driver)
 * 
 *    Rev 1.3   Oct 23 2003 10:01:12   goethalo
 * Changes for Apache DBCP.
 * 
 *    Rev 1.2   Oct 07 2003 14:51:28   goethalo
 * Changes for IT-9811 - Internet By Call with Registration
 * 
 *    Rev 1.1   May 12 2003 13:30:50   goethalo
 * Added hasActionMapping method.
 * 
 *    Rev 1.0   Apr 09 2003 09:34:38   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import net.arcor.fif.common.ParsingErrorHandler;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.db.DatabaseConfig;

import org.apache.log4j.Logger;
import org.apache.xerces.parsers.DOMParser;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

/**
 * This class contains the metadata for the FIF Message Creator.
 * It has methods for parsing the the metadata XML file and storing it in the
 * internal structures.  It also contains methods for getting information about
 * the metadata.
 *
 * @author goethalo
 */
public class MessageCreatorMetaData {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger =
        Logger.getLogger(MessageCreatorMetaData.class);

    /**
     * The name of the configuration metadata XML file.
     */
    private static String metaDataFile = null;

    /**
     * Indicates whether reference data should be supported.
     */
    private static boolean supportReferenceData = false;

    /**
     * The database connection to use for retrieving reference data.
     */
    private static Connection refDataConn = null;

    /**
     * Indicates whether this class has been initialized.
     */
    private static boolean initialized = false;

    /**
     * Contains the request definitions.
     */
    private static Map requestDefinitions = null;

    /**
     * Contains the message definitions.
     */
    private static Map messageDefinitions = null;

    /**
     * Contains the message creators definitions.
     */
    private static Map messageCreatorDefinitions = null;

    /**
     * Contains the action mappings.
     */
    private static Map actionMappings = null;

    /**
     * The statement for retrieving default values from the database.
     */
    private static final String defaultValueSelect =
        "SELECT PI.VALUE FROM PARAMETER_ITEM PI "
            + "WHERE PI.GROUP_CODE=? AND PI.ITEM_IDENTIFIER=? "
            + "AND PI.EFFECTIVE_STATUS='ACTIVE' "
            + "AND PI.EFFECTIVE_DATE="
            + "(SELECT MAX(EFFECTIVE_DATE) FROM PARAMETER_ITEM "
            + "WHERE GROUP_CODE=PI.GROUP_CODE "
            + "AND ITEM_IDENTIFIER=PI.ITEM_IDENTIFIER "
            + "AND EFFECTIVE_DATE < SYSDATE)";

    /**
     * The prepared statement for retrieving default values from the database.
     */
    private static PreparedStatement defaultValueStmt = null;

    /**
     * Indicates whether the database was initialized for this class.
     */
    private static boolean initializedDB = false;

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Initializes this class.
     * This populates the internal structures based on the contents of the
     * metadata XML files and validates the retrieved metadata.
     * @throws FIFException if the metadata could not be retrieved
     * or if the metadata failed the validations.
     */
    public synchronized static void init() throws FIFException {
        // Bail out if the class is already initialized
        if (initialized) {
            return;
        }

        // Set the metadata file
        if (metaDataFile == null) {
            metaDataFile =
                MessageCreatorConfig.getPath("messagecreator.MetaDataDir")
                    + MessageCreatorConfig.getSetting(
                        "messagecreator.MetaDataFile");
        }

        // Determine whether reference data should be supported
        try {
            supportReferenceData =
                MessageCreatorConfig.getBoolean(
                    "messagecreator.EnableReferenceDataSupport");
        } catch (FIFException fe) {
            supportReferenceData = false;
        }

        if (supportReferenceData == true) {
            // Make sure that the database is initialized
            if (DatabaseConfig.isInitialized() == false) {
                DatabaseConfig.init(MessageCreatorConfig.getConfigProperties());
                initializedDB = true;
            }

            // Get the database connection for reference data
            try {
                refDataConn =
                    DriverManager.getConnection(
                        DatabaseConfig.JDBC_CONNECT_STRING_PREFIX
                            + MessageCreatorConfig.getSetting(
                                "messagecreator.ReferenceDataDBAlias"));
                defaultValueStmt =
                    refDataConn.prepareStatement(defaultValueSelect);
            } catch (SQLException sqle) {
                throw new FIFException(
                    "Cannot create database connection for reference data",
                    sqle);
            }
        }

        // Parse the XML file containing the metadata
        logger.info("Parsing message metadata...");
        parseMetaDataFile();
        logger.info("Successfully parsed message metadata.");

        if (logger.isDebugEnabled()) {
            logger.debug(
                "Read the following message metadata:" + staticToString());
        }

        // Validate the metadata
        logger.info("Validating message metadata...");
        validateMetaData();
        logger.info("Successfully validated message metadata.");

        // Set the initialized flag
        initialized = true;
    }

    /**
     * Shuts down the message creator.
     */
    public static synchronized void shutdown() throws FIFException {
        // Bail out if the class has not been initialized.
        if (initialized == false) {
            return;
        }

        boolean success = true;

        try {
            // Close the statement
            if (defaultValueStmt != null) {
                defaultValueStmt.close();
            }
        } catch (SQLException sqle) {
            success = false;
            logger.error("Cannot close SQL statement for reference data", sqle);
        }

        try {
            // Close the connection
            if (refDataConn != null) {
                refDataConn.close();
            }
        } catch (SQLException sqle) {
            success = false;
            logger.error(
                "Cannot close database connection for reference data",
                sqle);
        }

        try {
            if (initializedDB == true) {
                DatabaseConfig.shutdown();
            }
        } catch (FIFException fe) {
            success = false;
            logger.error("Cannot shutdown database.", fe);
        }

        if (success == false) {
            throw new FIFException("Errors while shutting down message creator.");
        }

        initialized = false;
    }

    /**
     * Gets the class name for a request type.
     * @param requestType  the request type to get the class name for.
     * @return a <code>String</code> containing the class name for the request
     * type
     * @throws FIFException if no request class was found for the
     * passed in request type.
     */
    public static String getRequestClassName(String requestType)
        throws FIFException {
        RequestDefinition definition =
            (RequestDefinition) requestDefinitions.get(requestType);
        if (definition == null) {
            throw new FIFException(
                "Cannot find request class name for request type"
                    + requestType);
        }
        return definition.getClassName();
    }

    /**
     * Gets the class name for a message type.
     * @param messageType  the message type to get the class name for.
     * @return a <code>String</code> containing the class name for the message
     * type
     * @throws FIFException if no request class was found for the
     * passed in message type.
     */
    public static String getMessageClassName(String messageType)
        throws FIFException {
        MessageDefinition definition =
            (MessageDefinition) messageDefinitions.get(messageType);
        if (definition == null) {
            throw new FIFException(
                "Cannot find request class name for message type"
                    + messageType);
        }
        return definition.getClassName();
    }

    /**
     * Gets the message creator for a message creator type.
     * @param messageCreatorType  the message creator type to get the message
     *                             creator definition for.
     * @return a <code>MessageCreatorDefinition</code> object containing the
     * definition for the message creator type
     * @throws FIFException if no message creator definition was
     * found for the passed in message creator type.
     */
    public static MessageCreatorDefinition getMessageCreatorDefinition(String messageCreatorType)
        throws FIFException {
        MessageCreatorDefinition definition =
            (MessageCreatorDefinition) messageCreatorDefinitions.get(
                messageCreatorType);
        if (definition == null) {
            throw new FIFException(
                "Cannot find message creator definition for message "
                    + "creator type"
                    + messageCreatorType);
        }
        return definition;
    }

    /**
     * Gets the action mapping for a given action.
     * @param action  the action to get the action mapping for.
     * @return an <code>ActionMapping</code> object containing the mapping for
     * the action
     * @throws FIFException if action mapping was found for
     * the passed in action.
     */
    public static ActionMapping getActionMapping(String action)
        throws FIFException {
        ActionMapping mapping = (ActionMapping) actionMappings.get(action);
        if (mapping == null) {
            throw new FIFInvalidRequestException(
                "Cannot find action mapping for action " + action);
        }
        return mapping;
    }

    /**
     * Determines whether an action mapping exists for a given action name.
     * @param action  the action name to find an action mapping for
     * @return true if an action mapping exists for the action name, 
     * false if not.
     */
    public static boolean hasActionMapping(String action) {
        boolean exists = actionMappings.containsKey(action);
        return exists;
    }

    /**
     * Parses the XML file containing the metadata and stores its contents
     * in the internal structures.
     * @throws FIFException if the metadata could not be parsed.
     */
    private synchronized static void parseMetaDataFile() throws FIFException {
        try {
            // Create a DOM parser
            DOMParser parser = new DOMParser();

            // Parse the XML metadata file with DTD validation
            ParsingErrorHandler handler = new ParsingErrorHandler();
            parser.setFeature("http://xml.org/sax/features/validation", true);
            parser.setErrorHandler(handler);
            parser.setEntityResolver(new EntityResolver());            
            parser.parse(metaDataFile);

            if (handler.isError()) {
                throw new FIFException(
                    "Errors while parsing metadata file "
                        + metaDataFile
                        + ":\n"
                        + handler.getErrors());
            } else if (handler.isWarning()) {
                logger.warn(
                    "Warnings while parsing metadata file "
                        + metaDataFile
                        + ":\n"
                        + handler.getWarnings());
            }

            // Get the document
            Document doc = parser.getDocument();
            NodeList definitions = null;

            // Parse the request definitions
            requestDefinitions = new HashMap();
            definitions = doc.getElementsByTagName(XMLTags.requestDefinition);
            parseRequestDefinitions(definitions);

            // Parse the message definitions
            messageDefinitions = new HashMap();
            definitions = doc.getElementsByTagName(XMLTags.messageDefinition);
            parseMessageDefinitions(definitions);

            // Parse the message creation definitions
            messageCreatorDefinitions = new HashMap();
            definitions =
                doc.getElementsByTagName(XMLTags.messageCreatorDefinition);
            parseMessageCreatorDefinitions(definitions);

            // Parse the action mappings
            actionMappings = new HashMap();
            definitions = doc.getElementsByTagName(XMLTags.actionMapping);
            parseActionMappings(definitions);
        } catch (SAXException e) {
            throw new FIFException(
                "Cannot parse metadata file " + metaDataFile,
                e);
        } catch (IOException e) {
            throw new FIFException(
                "Cannot parse metadata file " + metaDataFile,
                e);
        }
    }

    /**
     * Parses the request definitions.
     * @param definitions  the node list containing the request definitions
     */
    private static void parseRequestDefinitions(NodeList definitions)
        throws FIFException {
        int elementCount = definitions.getLength();
        for (int i = 0; i < elementCount; i++) {
            Element requestDefinition = (Element) definitions.item(i);
            String typeName =
                getElementText(requestDefinition, XMLTags.requestType);
            String className =
                getElementText(requestDefinition, XMLTags.requestClass);
            requestDefinitions.put(
                typeName,
                new RequestDefinition(typeName, className));
        }
    }

    /**
     * Parses the message definitions.
     * @param definitions  the node list containing the message definitions.
     */
    private static void parseMessageDefinitions(NodeList definitions)
        throws FIFException {
        int elementCount = definitions.getLength();
        for (int i = 0; i < elementCount; i++) {
            Element messageDefinition = (Element) definitions.item(i);
            String typeName =
                getElementText(messageDefinition, XMLTags.messageType);
            String className =
                getElementText(messageDefinition, XMLTags.messageClass);
            messageDefinitions.put(
                typeName,
                new MessageDefinition(typeName, className));
        }
    }

    /**
     * Parses the message creator definitions.
     * @param definitions  the node list containing the message creator definitions.
     */
    private static void parseMessageCreatorDefinitions(NodeList definitions)
        throws FIFException {
        int elementCount = definitions.getLength();
        for (int i = 0; i < elementCount; i++) {
            Element messageCreatorDefinition = (Element) definitions.item(i);
            String creatorType =
                getElementText(messageCreatorDefinition, XMLTags.creatorType);
            String creatorClass =
                getElementText(messageCreatorDefinition, XMLTags.creatorClass);
            String creatorInputRequest =
                getElementText(
                    messageCreatorDefinition,
                    XMLTags.creatorInputRequestType);
            String creatorOutputMessage =
                getElementText(
                    messageCreatorDefinition,
                    XMLTags.creatorOutputMessageType);

            // Parse the parameters
            NodeList params =
                messageCreatorDefinition.getElementsByTagName(
                    XMLTags.paramName);
            ArrayList mcParams = new ArrayList();
            for (int j = 0; j < params.getLength(); j++) {
                Element param = (Element) params.item(j);
                mcParams.add(param.getFirstChild().getNodeValue());
            }

            messageCreatorDefinitions.put(
                creatorType,
                new MessageCreatorDefinition(
                    creatorType,
                    creatorClass,
                    mcParams,
                    creatorInputRequest,
                    creatorOutputMessage));
        }
    }

    /**
     * Parses the action mappings.
     * @param mappings  the node list containing the action mappings.
     */
    private static void parseActionMappings(NodeList mappings)
        throws FIFException {
        int elementCount = mappings.getLength();
        for (int i = 0; i < elementCount; i++) {
            Element mapping = (Element) mappings.item(i);

            String actionName = getElementText(mapping, XMLTags.actionName);

            // Parse the message creation section
            Map mcParams = new HashMap();
            Element mc =
                (Element) mapping.getElementsByTagName(
                    XMLTags.messageCreation).item(
                    0);
            String creatorType = getElementText(mc, XMLTags.creatorType);
            NodeList params = mc.getElementsByTagName(XMLTags.creatorParam);
            for (int j = 0; j < params.getLength(); j++) {
                Element param = (Element) params.item(j);
                String paramName = getElementText(param, XMLTags.paramName);
                String paramValue = getElementText(param, XMLTags.paramValue);
                mcParams.put(
                    paramName,
                    new SimpleParameter(paramName, paramValue));
            }

            // Parse the message parameters section
            ArrayList msgParams = new ArrayList();
            Element message =
                (Element) mapping.getElementsByTagName(
                    XMLTags.messageParameters).item(
                    0);
            params = message.getChildNodes();
            for (int k = 0; k < params.getLength(); k++) {
                Node param = params.item(k);
                if (param.getNodeType() == Node.ELEMENT_NODE) {
                    ParameterMetaData pmd = parseParamNode((Element) param);
                    if (pmd != null) {
                        msgParams.add(pmd);
                    }
                }
            }

            // Parse the response handling section
            Element responseHandling =
                (Element) mapping.getElementsByTagName(
                    XMLTags.responseHandling).item(
                    0);
            String returnWarningsText =
                getElementText(responseHandling, XMLTags.returnWarnings);
            boolean returnWarnings = returnWarningsText.equals("true");
            ArrayList outputParams = new ArrayList();
            params = responseHandling.getElementsByTagName(XMLTags.outputParam);
            for (int l = 0; l < params.getLength(); l++) {
                Element param = (Element) params.item(l);
                String responseCommandID =
                    getElementText(param, XMLTags.responseCommandID);
                if (responseCommandID == null) {
                    responseCommandID = "";
                }
                String responseParamName =
                    getElementText(param, XMLTags.responseParamName);
                String outputParamName =
                    getElementText(param, XMLTags.outputParamName);
                outputParams.add(
                    new OutputParameterMetaData(
                        responseCommandID,
                        responseParamName,
                        outputParamName));
            }

            // Create the action mapping object
            actionMappings.put(
                actionName,
                new ActionMapping(
                    actionName,
                    creatorType,
                    mcParams,
                    msgParams,
                    returnWarnings,
                    outputParams));
        }
    }

    /**
     * Parses a message parameter node and returns its ParameterMetaData
     * representation.
     * @param param  the element node to parse
     * @return a ParameterMetaData object containing the parsed data
     */
    private static ParameterMetaData parseParamNode(Element param)
        throws FIFException {
        ParameterMetaData pmd = null;

        if (param.getNodeName().equals(XMLTags.messageParam)) {
            // We have a simple message parameter.
            // Parse its contents
            String name = getElementText(param, XMLTags.paramName);
            String mandatoryString =
                getElementText(param, XMLTags.paramMandatory);
            boolean mandatory = false;
            if ((mandatoryString == null)
                || (mandatoryString.equals("true"))) {
                mandatory = true;
            }

            // Get the default value and validation method
            String defaultValue = getDefaultValue(param);            
            String validationMethod = getValidationMethod(param);

            if (validationMethod != null)
            	logger.debug("Validation method " + validationMethod
            			+ " will be applied for parameter " + name + ".");
            
            // Put the contents in a simple parameter metadata object
            pmd = new SimpleParameterMetaData(name, mandatory, defaultValue, validationMethod);
        } else if (param.getNodeName().equals(XMLTags.messageParamList)) {
            // We have a parameter list.
            // Get its name and mandatory info
            String name = getElementText(param, XMLTags.paramListName);
            String mandatoryString =
                getElementText(param, XMLTags.paramListMandatory);
            boolean mandatory = false;
            if (mandatoryString == null || mandatoryString.equals("true")) {
                mandatory = true;
            }
            pmd = new ParameterListMetaData(name, mandatory);

            // Recursively populate the parameter list parameters...
            NodeList listParams = param.getChildNodes();
            for (int i = 0; i < listParams.getLength(); i++) {
                Node listParam = listParams.item(i);
                if (listParam.getNodeType() == Node.ELEMENT_NODE) {
                    ParameterMetaData plmd =
                        parseParamNode((Element) listParam);
                    if (plmd != null) {
                        ((ParameterListMetaData) pmd).addParamMetaData(plmd);
                    }
                }
            }
        }

        return pmd;
    }

    /**
     * Gets the default value for a parameter.
     * @param parent  the element node of the parameter to get the default 
     *                value for.
     * @return the default value for the parameter.
     */
    private static String getDefaultValue(Element parent) throws FIFException {
        NodeList defaultValueNodes =
            parent.getElementsByTagName(XMLTags.paramDefaultValue);
        if ((defaultValueNodes != null)
            && (defaultValueNodes.getLength() != 0)) {
            // We have a normal default value, return this value
            return (getElementText(parent, XMLTags.paramDefaultValue));
        }

        NodeList refdataDefaultNodes =
            parent.getElementsByTagName(XMLTags.paramDefaultRefDataValue);
        if ((refdataDefaultNodes != null)
            && (refdataDefaultNodes.getLength() != 0)) {
            // We have a default value coming from reference data.

            // Make sure that reference data is supported
            if (supportReferenceData == false) {
                throw new FIFException(
                    "Reference data default values are not "
                        + "supported for this client.");
            }

            Element refdataInfo = (Element) refdataDefaultNodes.item(0);
            return (
                getRefDataDefaultValue(
                    getElementText(refdataInfo, XMLTags.groupCode),
                    getElementText(refdataInfo, XMLTags.itemIdentifier)));
        }

        return ("");
    }

    /**
     * Gets the validation method for a parameter.
     * @param parent  the element node of the parameter to get the default 
     *                value for.
     * @return the validation method for the parameter.
     */
    private static String getValidationMethod(Element parent) throws FIFException {
        NodeList validationMethodNodes =
            parent.getElementsByTagName(XMLTags.paramValidationMethod);
        if ((validationMethodNodes != null)
            && (validationMethodNodes.getLength() != 0)) {
        	String validationMethod = getElementText(parent, XMLTags.paramValidationMethod);             
        	return validationMethod;
        }
        return null;
    }

    /**
     * Gets a default value from the reference data database.
     * @param groupCode       the group code for the default value.
     * @param itemIdentifier  the item identifier for the default value.
     * @return the default value.
     */
    private static String getRefDataDefaultValue(
        String groupCode,
        String itemIdentifier) {
        String value = "";
        try {
            defaultValueStmt.clearParameters();
            defaultValueStmt.setString(1, groupCode);
            defaultValueStmt.setString(2, itemIdentifier);
            ResultSet result = defaultValueStmt.executeQuery();
            if (result.next()) {
                value = result.getString(1);
            }
        } catch (SQLException sqle) {
            value = "";
        }
        return value;
    }

    /**
     * Gets the text contained in an element given the tagname of the element
     * and the parent element.
     * @param parent   the parent element
     * @param tagName  the tag name of the element to take the text for
     * @return a <code>String</code> containing the element text, null if an
     * element with the passed in tagname was not found.
     */
    private static String getElementText(Element parent, String tagName) {
        Element element =
            (Element) (parent.getElementsByTagName(tagName).item(0));
        if (element == null) {
            return null;
        }
        return (element.getFirstChild().getNodeValue());
    }

    /**
     * Writes the contents of this object as a <code>String</code>
     * @see java.lang.Object#toString()
     */
    private static String staticToString() {
        StringBuffer sb = new StringBuffer();
        sb.append("\n*** REQUEST DEFINITIONS *** ");
        Object[] list = requestDefinitions.values().toArray();
        for (int i = 0; i < list.length; i++) {
            sb.append(((RequestDefinition) list[i]).toString());
        }
        sb.append("\n\n*** MESSAGE DEFINITIONS *** ");
        list = messageDefinitions.values().toArray();
        for (int i = 0; i < list.length; i++) {
            sb.append(((MessageDefinition) list[i]).toString());
        }
        sb.append("\n\n*** MESSAGE CREATOR DEFINITIONS ***");
        list = messageCreatorDefinitions.values().toArray();
        for (int i = 0; i < list.length; i++) {
            sb.append(((MessageCreatorDefinition) list[i]).toString());
        }
        sb.append("\n\n*** ACTION MAPPINGS *** ");
        list = actionMappings.values().toArray();
        for (int i = 0; i < list.length; i++) {
            sb.append(((ActionMapping) list[i]).toString());
        }
        sb.append("\n");
        return sb.toString();
    }

    /**
     * Validates the metadata.
     * @throws FIFException if the validation failed.
     */
    private static void validateMetaData() throws FIFException {
        // Validate the request definitions
        validateRequestDefinitions();

        // Validate the message definitions
        validateMessageDefinitions();

        // Validate the message creator definitions
        validateMessageCreatorDefinitions();

        // Validate the action mappings
        validateActionMappings();
    }

    /**
     * Validates the request definitions
     * @throws FIFException if the validation failed.
     */
    private static void validateRequestDefinitions() throws FIFException {
        // Validate that the specified request classes are valid
        Object[] definitions = requestDefinitions.values().toArray();
        for (int i = 0; i < definitions.length; i++) {
            RequestDefinition definition = (RequestDefinition) definitions[i];
            String className = definition.getClassName();

            // Validate that the class exists
            Class creatorClass = null;
            try {
                creatorClass = (Class.forName(className));
            } catch (ClassNotFoundException cnfe) {
                throw new FIFException(
                    "Could not find class "
                        + className
                        + " for request type "
                        + definition.getTypeName());
            }

            // Validate that the class is of the correct type
            try {
                if (!(creatorClass.newInstance() instanceof Request)) {
                    throw new Exception("WrongType");
                }
            } catch (Exception e) {
                throw new FIFException(
                    "Class "
                        + className
                        + " is not derived from Request. "
                        + "Request type: "
                        + definition.getTypeName());
            }
        }
    }

    /**
     * Validates the message definitions
     * @throws FIFException if the validation failed.
     */
    private static void validateMessageDefinitions() throws FIFException {
        // Validate that the specified message classes are valid
        Object[] definitions = messageDefinitions.values().toArray();
        for (int i = 0; i < definitions.length; i++) {
            MessageDefinition definition = (MessageDefinition) definitions[i];
            String className = definition.getClassName();

            // Validate that the class exists
            Class creatorClass = null;
            try {
                creatorClass = (Class.forName(className));
            } catch (ClassNotFoundException cnfe) {
                throw new FIFException(
                    "Could not find class "
                        + className
                        + " for message type "
                        + definition.getTypeName());
            }

            // Validate that the class is of the correct type
            try {
                if (!(creatorClass.newInstance() instanceof Message)) {
                    throw new Exception("WrongType");
                }
            } catch (Exception e) {
                throw new FIFException(
                    "Class "
                        + className
                        + " is not derived from Message. "
                        + "Message type: "
                        + definition.getTypeName());
            }
        }
    }

    /**
     * Validates the message creator definitions.
     * @throws FIFException if the validation failed.
     */
    private static void validateMessageCreatorDefinitions()
        throws FIFException {

        Object[] definitions = messageCreatorDefinitions.values().toArray();
        for (int i = 0; i < definitions.length; i++) {
            MessageCreatorDefinition definition =
                (MessageCreatorDefinition) definitions[i];

            // Validate that the specified message creator exists
            String className = definition.getClassName();
            Class creatorClass = null;
            try {
                creatorClass = (Class.forName(className));
            } catch (ClassNotFoundException cnfe) {
                throw new FIFException(
                    "Could not find class "
                        + className
                        + " for message creator type"
                        + definition.getTypeName());
            }

            // Validate that the class is of the correct type
            try {
                if (!(MessageCreator.class.isAssignableFrom(creatorClass))) {
                    throw new Exception("WrongType");
                }
            } catch (Exception e) {
                throw new FIFException(
                    "Class "
                        + className
                        + " is not derived from "
                        + "MessageCreator. Message creator type: "
                        + definition.getTypeName());
            }

            // Validate that the specified input request type and output
            // message type exist
            if (requestDefinitions.get(definition.getInputRequestType())
                == null) {
                throw new FIFException(
                    "Input request type "
                        + definition.getInputRequestType()
                        + " is not defined in the request definitions section."
                        + " Message creator type: "
                        + definition.getTypeName());
            }
            if (messageDefinitions.get(definition.getOutputMessageType())
                == null) {
                throw new FIFException(
                    "Output message type "
                        + definition.getOutputMessageType()
                        + " is not defined in the message definitions section."
                        + " Message creator type: "
                        + definition.getTypeName());
            }

        }
    }

    /**
     * Validates the action mappings.
     * @throws FIFException if the validation failed.
     */
    private static void validateActionMappings() throws FIFException {
        // Loop through the action mappings
        Object[] mappings = actionMappings.values().toArray();
        for (int i = 0; i < mappings.length; i++) {
            ActionMapping mapping = (ActionMapping) mappings[i];

            // Message creator validations

            // Ensure that the message creator definition exists
            MessageCreatorDefinition mcd =
                (MessageCreatorDefinition) messageCreatorDefinitions.get(
                    mapping.getCreatorType());
            if (mcd == null) {
                throw new FIFException(
                    "No message creator defined for creator type "
                        + mapping.getCreatorType()
                        + ". (ActionMapping: "
                        + mapping.getActionName()
                        + ")");
            }

            // Ensure that all the message creator parameters are provided
            ArrayList paramNames = mcd.getParamNames();
            for (int j = 0; j < paramNames.size(); j++) {
                SimpleParameter paramValue =
                    (SimpleParameter) mapping.getCreatorParams().get(
                        paramNames.get(j));
                if ((paramValue == null)
                    || (paramValue.getValue() == null)
                    || (paramValue.getValue().trim().length() == 0)) {
                    throw new FIFException(
                        "Missing message creator parameter: "
                            + paramNames.get(j)
                            + " is not specified for action-mapping "
                            + mapping.getActionName());
                }
            }

            // Ensure that the message parameters are of the right type
            MessageCreatorDefinition creator =
                getMessageCreatorDefinition(mapping.getCreatorType());
            String creatorClassName = creator.getClassName();

            // Get a message creator object
            MessageCreator messageCreator =
                MessageCreatorFactory.getMessageCreator(
                    mapping.getActionName());

            // Validate the creator metadata
            messageCreator.validateParamMetaData(mapping.getMessageParams());
        }
    }

    /*---------*
     * TESTING *
     *---------*/

    /**
     * Sets the initialized.
     * <b>Should only be used for testing purposes.</b>
     * @param initialized The initialized to set
     */
    protected static void setInitialized(boolean initialized) {
        MessageCreatorMetaData.initialized = initialized;
    }

    /**
     * Sets the metaDataFile.
     * <b>Should only be used for testing purposes.</b>
     * @param metaDataFile The metaDataFile to set
     */
    protected static void setMetaDataFile(String metaDataFile) {
        MessageCreatorMetaData.metaDataFile = metaDataFile;
    }

}
