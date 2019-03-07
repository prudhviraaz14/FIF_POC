/*
 * $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/apps/ImportCSMToDB.java-arc   1.2   Jun 29 2016 16:33:52   lalit.kumar-nayak  $
 *
 * $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/apps/ImportCSMToDB.java-arc  $
 * 
 *    Rev 1.2   Jun 29 2016 16:33:52   lalit.kumar-nayak
 * RMS 151375 : ELSAA : extented order types
 * 
 *    Rev 1.1   Aug 18 2014 13:32:08   makuier
 * improved line processing.
 * 
 *    Rev 1.0   May 27 2014 09:53:32   makuier
 * Initial revision.
 * 
 */
package net.arcor.fif.apps;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Properties;
import java.util.Set;

import net.arcor.fif.common.CSMReader;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.common.Log4jConfig;
import net.arcor.fif.db.DatabaseConfig;

import org.apache.log4j.Logger;

/**
 * Class for importing a CSM file into the FIF request table.
 * 
 * @author makuier
 *  
 */
public class ImportCSMToDB {

	/*------------------*
	 * MEMBER VARIABLES *
	 *------------------*/

	/**
	 * The log4j logger.
	 */
	private static Logger logger = Logger.getLogger(ImportCSMToDB.class);

	/**
	 * The resource bundle to get the configuration settings from.
	 */
	private static Properties props = null;

	private static String status = null;
	

	/**
	 * The prefix to use in front of the transaction ID
	 */
	private static String transactionIDPrefix = null;

	/**
	 * The connection to use for the database.
	 */
	private static Connection conn = null;

	/**
	 * The insert statement for inserting a FIF request.
	 */
	private static PreparedStatement insertRequestStmt = null;

	/**
	 * The insert statement for inserting a FIF request parameter.
	 */
	private static PreparedStatement insertParamStmt = null;
	
	/**
	 * The field index of the transaction ID in the request parameter table.
	 */
	private static int insertParamTransactionIDFieldIndex = -1;

	/**
	 * The field index of the parameter name in the request parameter table.
	 */
	private static int insertParamNameFieldIndex = -1;

	/**
	 * The field index of the parameter value in the request parameter table.
	 */
	private static int insertParamValueFieldIndex = -1;

	/**
	 * The external system id, which is no defined in the CSM.
	 */
	private static String requestExternalSystemId = null;

	/**
	 * The insert statement for inserting a FIF request parameter.
	 */
	private static PreparedStatement updatexternalSystemIdStatement = null;
	private static PreparedStatement updateStatusStatement = null;
	
	/**
	 * The database alias name to use to retrieve a connection from the
	 * connection pool.
	 */
	public static final String dbAlias = DatabaseConfig.JDBC_CONNECT_STRING_PREFIX
			+ "requestdb";

	/*---------*
	 * METHODS *
	 *---------*/

	/**
	 * Initializes the application.
	 * 
	 * @throws FIFException
	 */
	private static void init(String configFile, String clientConfigFile)
			throws FIFException {
		// Read the configuration
		props = FileUtils.readPropertyFile(configFile);

		// Initialize the logger
		Log4jConfig.init(props);

		logger.info("Initializing application with property file " + configFile
				+ "...");
		
		// Initialize the database
		logger.info("Reading database configuration from client property file "
				+ clientConfigFile);
		DatabaseConfig.init(clientConfigFile);

		// Prepare the statements
		try {
			logger.info("Preparing database statements...");
			conn = DriverManager.getConnection(dbAlias);
			conn.setAutoCommit(false);
			logger.info("Preparing InsertRequestStmt: "
					+ getSetting("ImportCSMToDB.InsertRequestStmt", true));
			insertRequestStmt = conn.prepareStatement(getSetting(
					"ImportCSMToDB.InsertRequestStmt", true));
			logger.info("Preparing InsertRequestStmt: "
					+ getSetting("ImportCSMToDB.InsertParamStmt", true));
			insertParamStmt = conn.prepareStatement(getSetting(
					"ImportCSMToDB.InsertParamStmt", true));
			updatexternalSystemIdStatement = conn.prepareStatement(getSetting(
					"ImportCSMToDB.UpdatexternalSystemIdStatement", true));				
			updateStatusStatement = conn.prepareStatement(
					"UPDATE FIF_REQUEST " +
							"SET STATUS = ? " +
					"WHERE TRANSACTION_ID = ?");	

		} catch (SQLException e) {
			throw new FIFException("Error while initializing CSM importer.", e);
		}

		// Get the field indexes
		insertParamTransactionIDFieldIndex = getInt("ImportCSMToDB.InsertParamStmt.TransactionIDFieldIndex");
		insertParamNameFieldIndex = getInt("ImportCSMToDB.InsertParamStmt.ParamNameFieldIndex");
		insertParamValueFieldIndex = getInt("ImportCSMToDB.InsertParamStmt.ParamValueFieldIndex");
		// Get the transaction ID offset
		Date current = new Date();
		transactionIDPrefix = Long.toString(current.getTime());
		
		logger.info("Successfully initialized application.");
	}

	/**
	 * Shuts down the application.
	 * 
	 * @throws FIFException
	 */
	private static void shutdown() {
		boolean success = true;
		logger.info("Shutting down application...");
		try {
			if (insertRequestStmt != null) {
				insertRequestStmt.close();
			}
			if (updatexternalSystemIdStatement != null) {
				updatexternalSystemIdStatement.close();
			}
			if (updateStatusStatement != null) {
				updateStatusStatement.close();
			}
		} catch (SQLException e) {
			logger.error("Cannot close statement.", e);
			success = false;
		}
		try {
			if (insertParamStmt != null) {
				insertParamStmt.close();
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
	 * Inserts the request in the FIF request table.
	 * 
	 * @throws FIFException
	 *             if the requests could not be inserted.
	 */
	public static void insertRequests(String CSMfile) throws FIFException {
		int sequenceNumber = 0;

		CSMReader reader = new CSMReader(CSMfile);
        int lineNumber = 0;
        String lineString=null;
        boolean OrderTypeStored = false;
        HashMap<String,String> ValuesCCD = new  HashMap<String,String>() ;
        HashMap<String,String> values =new  HashMap<String,String>() ;
        String OrderType = null;
        
		try {

			while (true) {
				lineString = reader.getReader().readLine();
								
				if (values == null)
					values = new  HashMap<String,String>() ;
				if (ValuesCCD == null)
					ValuesCCD = new  HashMap<String,String>() ;
				
				if (lineString==null)
					break;	
					
				// Find the Header line Text
				String HeaderLine = lineString.substring(0,13);
				if(HeaderLine != null)
					HeaderLine = HeaderLine.trim();
				
				//Read line with AUFTHEADER10 for  FINAL DEACTIVATION , SUSPEND SUBSCRIPTION and RESUME SUBSCRIPTION and read
				//one extra line AUFTHEADER10 for CHANGE CARRIER DATA
				
				if( HeaderLine.equals("AUFTHEADER10") || HeaderLine.equals("AUFTKNDDAT10"))
						{					
							lineNumber++;				
							//If the line  AUFTHEADER10 already processed for CHANGE CARRIER DATA 
							//It will jump to 3rd line to parse other parameters from line 
							if(!OrderTypeStored)
							{
								try {
									values = reader.parseColumns(lineString);
									OrderType= values.get("orderType").toString();									
									
								} catch (FIFException e) {
									logger.warn("The action is not supported. line skiped.");
									continue;
								}
							}							
							
							String transactionID = transactionIDPrefix + sequenceNumber;
							// Process the first line AUFTHEADER10 only for 3 ordertypes
							if( OrderType != null && OrderType.equals("FINAL DEACTIVATION")
									|| OrderType.equals("SUSPEND SUBSCRIPTION")
									|| OrderType.equals("RESUME SUBSCRIPTION"))
							{
								processLine(reader,CSMfile,transactionID,values,lineNumber);
							}		
							
							// Process the first line + 3rd line  for 3 ordertype CHANGE CARRIER DATA
							if (OrderType != null && OrderType.equals("CHANGE CARRIER DATA") && HeaderLine.equals("AUFTHEADER10"))
								{
								// Skip next line
									lineNumber = lineNumber+1;	
									//First line parsed value stored in ValuesCCD
									ValuesCCD.putAll(values);
									// Set to true to stop processing the first line again			
									OrderTypeStored = true;	
									//Continue to next line
									continue;				
									
								}
							// Process the  line AUFTKNDDAT10+ 3rd line  forordertype CHANGE CARRIER DATA
							else if (OrderTypeStored && HeaderLine.equals("AUFTKNDDAT10"))
							{
									HashMap<String,String> Extravalues ;
									HashMap<String,String> CombValue = new  HashMap<String,String>() ;	
									try {
									Extravalues = reader.parseColumnsExtraLine(lineString);
									} catch (FIFException e) {
										logger.warn("The action is not supported. line skiped.");
										continue;
									}
									//store data from AUFTHEADER10 + AUFTKNDDAT10
									CombValue.putAll(ValuesCCD);
									CombValue.putAll(Extravalues);
									OrderTypeStored =false;	
									ValuesCCD =null;
									//Process line for CHANGE CARRIER DATA
									processLine(reader,CSMfile,transactionID,CombValue,lineNumber);							
								
							}
						
							sequenceNumber++;
						
						}
			}
			logger.info("Successfully inserted requests in the database.");
		} catch (SQLException sqle) {
			throw new FIFException(
					"Error while inserting r equests in database.", sqle);
		} catch (IOException e) {
            throw new FIFException(
                    "Cannot read CSM file. Error on line number: " + lineNumber,
                    e);
		}
	}
	
	private static void processLine(CSMReader reader, String CSMfile,
			String transactionID, HashMap<String,String> values, int i) throws SQLException{
		// Insert the request
		insertRequestStmt.clearParameters();
		insertRequestStmt.setString(1, transactionID);	
		insertRequestStmt.execute();
		if (status != null) {
			logger.debug("Updating the FIF Request row with the status " + status + "...");
			updateStatusStatement.clearParameters();
			updateStatusStatement.setString(1, status);
			updateStatusStatement.setString(2, transactionID);
			updateStatusStatement.executeUpdate();
		}					
		logger.debug ("ValuestoInsert"+values);
		// Insert the parameters
        Set<String> keys = values.keySet();
		Iterator<String> keyiter = keys.iterator();
		while (keyiter.hasNext()){
			String colName = keyiter.next();
			String value = (String) values.get(colName);
			if ((value != null) && (!value.equals(""))) {
				if(colName.equals(requestExternalSystemId) )
				{
					logger.debug("Updating the FIF Request row with the external system id " + requestExternalSystemId + "...");
					updatexternalSystemIdStatement.clearParameters();
					updatexternalSystemIdStatement.setString(1, value);
					updatexternalSystemIdStatement.setString(2, transactionID);
					updatexternalSystemIdStatement.executeUpdate();
				}
				
				if(colName.indexOf("$")<0){	
					logger.debug ("keyToInsert"+colName);
					logger.debug ("ValueToInsert"+value);
				    insertParamStmt.clearParameters();
				    insertParamStmt.setString(insertParamTransactionIDFieldIndex,transactionID);
				    
				    if (colName.equals("actionFD")||colName.equals("actionSS")||colName.equals("actionCCD")||colName.equals("actionRS"))
				    	colName = "action";
				    insertParamStmt.setString(insertParamNameFieldIndex,colName);
				    insertParamStmt.setString(insertParamValueFieldIndex,value);
				    insertParamStmt.execute();
				}
			}

		}

		// Add the CSM info parameter
		insertParamStmt.clearParameters();
		insertParamStmt.setString(insertParamTransactionIDFieldIndex,
				transactionID);
		insertParamStmt.setString(insertParamNameFieldIndex,
				"CSM_IMPORT_INFO");
		insertParamStmt.setString(insertParamValueFieldIndex, "Line: "
				+ (i + 1) + ", Source: " + CSMfile);
		insertParamStmt.execute();

		// Commit the insert
		conn.commit();
	}

	/**
	 * Main.
	 * 
	 * @param args
	 *            the command-line arguments
	 */
	public static void main(String[] args) {
		if (args.length == 0) {
			System.err.println("");
		}
		String appName = System.getProperty("fif.appname");
		if (appName == null) {
			appName = "ImportCSMToDB";
		}

		if (args.length < 1) {
			System.err.println(appName
					+ ":imports a CSM file into the FIF request database\n");
			System.err.println("Usage: " + appName + " CSMfilename.CSM\n");
			System.exit(0);
		} // Set the config file name
		String configFile = "ImportCSMToDB.properties";
		if (System.getProperty("fif.propertyfile") != null) {
			configFile = System.getProperty("fif.propertyfile");
		} // Set the database client config file
		String clientConfigFile = "SAPFIFDatabaseClient";
		if (System.getProperty("fif.clientpropertyfile") != null) {
			clientConfigFile = System.getProperty("fif.clientpropertyfile");
		}

		if (args.length > 1)
			status = args[1];
		
		try {
			// Initialize the application
			init(configFile, clientConfigFile);
			// Insert the requests
        	insertRequests(args[0]);

		} catch (FIFException fe) {
			logger.fatal("Cannot import CSM file.", fe);
			fe.printStackTrace();
		} finally {
			shutdown();
		}
	}

	/**
	 * Gets a configuration setting from the configuration file.
	 * 
	 * @param key
	 *            the key to get the setting for
	 * @return a <code>String</code> containing the setting
	 * @throws FIFException
	 *             if the key was not found in the configuration file.
	 */
	private static String getSetting(String key, boolean mandatory)
			throws FIFException {
		String value = props.getProperty(key);
		if (value != null) {
			value = value.trim();
		} else if (mandatory) {
			throw new FIFException("Missing key in configuration file. Key: "
					+ key);
		}
		return value;
	}

	/**
	 * Gets a configuration setting from the configuration file.
	 * 
	 * @param key
	 *            the key to get the setting for.
	 * @return the <code>int</code> value of the setting.
	 * @throws FIFException
	 *             if the key was not found in the configuration file.
	 */
	private static int getInt(String key) throws FIFException {
		int value = 0;
		try {
			value = Integer.parseInt(getSetting(key, true));
		} catch (NumberFormatException nfe) {
			throw new FIFException(
					"Configuration value should be a number.  Key: " + key, nfe);
		}
		return (value);
	}
}