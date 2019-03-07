/*
 * Created on Apr 26, 2004
 *
 * To change the template for this generated file go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
package net.arcor.fif.apps;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.lang.Math;
import java.util.Date;
import java.util.Properties;
import java.util.StringTokenizer;

import org.apache.log4j.Logger;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.common.Log4jConfig;
import net.arcor.fif.db.DatabaseConfig;


/**
 * @author iarizova
 *
 */
public class ReconfigureNTAServiceCharacteristics {
	/*------------------*
	 * MEMBER VARIABLES *
	 *------------------*/

	/**
	 * The log4j logger.
	 */
	private static Logger logger = Logger.getLogger(ReconfigureNTAServiceCharacteristics.class);

	/**
	 * The resource bundle to get the configuration settings from.
	 */
	private static Properties props = null;

	/**
	 * The prefix to use in front of the transaction ID
	 */
	private static String transactionIDPrefix = null;

	/**
	 * The connection to use for the database.
	 */
	private static Connection conn = null;

	/**
	 * The select statement for selecting customer_numbers and service_subscriptions.
	 */
	private static PreparedStatement selectReconfiguredServicesStmt = null;
	
	/**
	 * The field index of the parameter serviceCodeList in the select query
	 */
	private static int serviceCodeListIndex = -1;
	
	/**
	 * The field index of the parameter customerNumber in the select query
	 */
	private static int customerNumberIndex = -1;
	
	/**
	 * The field index of the parameter serviceCharacteristicList in the select query
	 */
	private static int serviceCharacteristicListIndex = -1;
	
	/**
	 * The field index of the parameter compareValue in the select query
	 */
	private static int compareValueIndex = -1;
	
	/**
	 * The field index of the parameter serviceSubscriptionIdIndex in the select list of the query
	 */
	private static int serviceSubscriptionIdIndex=-1;

	/**
	 * The field index of the parameter serviceCharactCodeIndex in the select list of the query
	 */
	private static int serviceCharactCodeIndex=-1;
	
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
	 * The desire date of services' reconfiguration
	 */
	private static String desiredDate;


	/**
	 * The customer_number whom reconfigured services belong
	 */
	private static String customerNumber;
	
	
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
	 * Initializes the application.
	 * @throws FIFException
	 */
	private static void init(String configFile, String clientConfigFile)
		throws FIFException {
		// Read the configuration
		props = FileUtils.readPropertyFile(configFile);

		// Initialize the logger
		Log4jConfig.init(props);
 
		desiredDate =
			getSetting("ReconfigureNTAServiceCharacteristics.DesireDate");
			
		customerNumber =
			getSetting("ReconfigureNTAServiceCharacteristics.customerNumber");

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
				"Preparing SelectReconfiguredServicesStmt: "
					+ getSetting("ReconfigureNTAServiceCharacteristics.SelectReconfiguredServicesStmt"));
			selectReconfiguredServicesStmt=
				conn.prepareStatement(
					getSetting("ReconfigureNTAServiceCharacteristics.SelectReconfiguredServicesStmt"));
					
			logger.info(
				"Preparing InsertRequestStmt: "
					+ getSetting("ReconfigureNTAServiceCharacteristics.InsertRequestStmt"));
			insertRequestStmt =
				conn.prepareStatement(
					getSetting("ReconfigureNTAServiceCharacteristics.InsertRequestStmt"));
					
			logger.info(
				"Preparing InsertParamStmt: "
					+ getSetting("ReconfigureNTAServiceCharacteristics.InsertParamStmt"));
			insertParamStmt =
				conn.prepareStatement(
					getSetting("ReconfigureNTAServiceCharacteristics.InsertParamStmt"));
		} catch (SQLException e) {
			e.printStackTrace();
			throw new FIFException("Error while initializing CSV importer.", e);
		}
        catch (Exception e) {
			e.printStackTrace();
			throw new FIFException("Error while initializing CSV importer.", e);
		}
		
		serviceCodeListIndex = 
			getInt("ReconfigureNTAServiceCharacteristics.serviceCodeListIndex");
		customerNumberIndex =
			getInt("ReconfigureNTAServiceCharacteristics.customerNumberIndex");
		serviceCharacteristicListIndex = 
			getInt("ReconfigureNTAServiceCharacteristics.serviceCharacteristicListIndex");
		compareValueIndex =
			getInt("ReconfigureNTAServiceCharacteristics.compareValueIndex");
		serviceSubscriptionIdIndex = 
			getInt("ReconfigureNTAServiceCharacteristics.serviceSubscriptionIdIndex");
		serviceCharactCodeIndex =
			getInt("ReconfigureNTAServiceCharacteristics.serviceCharactCodeIndex");

		insertParamTransactionIDFieldIndex =
			getInt("ReconfigureNTAServiceCharacteristics.InsertParamStmt.TransactionIDFieldIndex");
		insertParamNameFieldIndex =
			getInt("ReconfigureNTAServiceCharacteristics.InsertParamStmt.ParamNameFieldIndex");
		insertParamValueFieldIndex =
			getInt("ReconfigureNTAServiceCharacteristics.InsertParamStmt.ParamValueFieldIndex");


		// Get the transaction ID offset
		Date date = new Date();
		transactionIDPrefix = "DBRecNTA_" + Math.abs(date.hashCode()) + "_";

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
			if (selectReconfiguredServicesStmt != null) {
				selectReconfiguredServicesStmt.close();
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
	 * @throws FIFException if the requests could not be inserted.
	 */
	public static void createFIFRequests() throws FIFException {
		int sequenceNumber = 0;

		logger.info(
			"Creating parameters for reconfiguration requests in the database...");

		int count = 0;
		String aliasNames = getSetting("ReconfigureNTAServiceCharacteristics.queryParameterAliases");
//		logger.info("1");
		StringTokenizer st = new StringTokenizer(aliasNames, ",", false);
//		logger.info("2");
		try {
		    while (st.hasMoreTokens()) {
			   String alias = st.nextToken().trim();
			   String keyPrefix = "ReconfigureNTAServiceCharacteristics." + alias + ".";
			   String serviceCodeList = 
				   getSetting(keyPrefix + "serviceCodeList");
//			   logger.info("3");
			   String serviceCharacteristicCodeList =
				   getSetting(keyPrefix + "serviceCharacteristicCodeList");
//			   logger.info("4");
			   String compareValue = 
				   getSetting(keyPrefix + "configuredValue");

			   // Insert the requests
//			   logger.info("5");
			   StringTokenizer stServiceCode = new StringTokenizer(serviceCodeList, ",", false);
			   while (stServiceCode.hasMoreTokens())
			   {
				   String serviceCode = stServiceCode.nextToken().trim();
				   StringTokenizer stCharactCode = new StringTokenizer(serviceCharacteristicCodeList, ",", false);
//				   logger.info("serviceCode " + serviceCode + ", stCharactCode " + stCharactCode);
				   while (stCharactCode.hasMoreTokens())
				   {
                       String charactCode = stCharactCode.nextToken().trim();
   					   selectReconfiguredServicesStmt.clearParameters();
					   selectReconfiguredServicesStmt.setString(serviceCodeListIndex, serviceCode);
					   selectReconfiguredServicesStmt.setString(customerNumberIndex, customerNumber);
					   selectReconfiguredServicesStmt.setString(serviceCharacteristicListIndex, charactCode);
					   selectReconfiguredServicesStmt.setString(compareValueIndex, compareValue);

					   ResultSet resultSet = selectReconfiguredServicesStmt.executeQuery();

 					   while (resultSet.next())
					   {
						  String serviceSubscriptionId = resultSet.getString(serviceSubscriptionIdIndex);
						  String serviceCharactCode    = resultSet.getString(serviceCharactCodeIndex);
                          String configuredValue       = resultSet.getString(3);

// 						  System.out.println(serviceCode + "  " + serviceSubscriptionId + "   " + serviceCharactCode + "   " + configuredValue);
					
						  count++;
						  String transactionID = transactionIDPrefix + count;
						  
//					  	  logger.info("serviceSubscriptionId " + serviceSubscriptionId + ", serviceCharactCode " + serviceCharactCode);
						  
						  // Insert the request
						  insertRequestStmt.clearParameters();
						  insertRequestStmt.setString(1, transactionID);
						  insertRequestStmt.execute();
						  
						// Insert the parameters
						// 1. service subscription id
						  insertParamStmt.clearParameters();
						  insertParamStmt.setString(
									insertParamTransactionIDFieldIndex,
									transactionID);
						  insertParamStmt.setString(
									insertParamNameFieldIndex,
									"SERVICE_SUBSCRIPTION_ID");
						  insertParamStmt.setString(
									insertParamValueFieldIndex,
						            serviceSubscriptionId);
						  insertParamStmt.execute();
						  
//						  logger.info("service subscription id");
						  
                         //2. desire date
		  				  insertParamStmt.setString(
						 		    insertParamNameFieldIndex,
								    "DESIRED_DATE");
						  insertParamStmt.setString(
								    insertParamValueFieldIndex,
						            desiredDate);
						  insertParamStmt.execute();
						  
//						logger.info("desire date");
						  
						  //3. service characteristic code
					      insertParamStmt.setString(
								    insertParamNameFieldIndex,
								    "SERVICE_CHAR_CODE");
					      insertParamStmt.setString(
								    insertParamValueFieldIndex,
						            serviceCharactCode);
					      insertParamStmt.execute();
					      
//						  logger.info("service characteristic code");

						  //4. CONFIGURED_VALUE
						  insertParamStmt.setString(
								    insertParamNameFieldIndex,
								    "CONFIGURED_VALUE");
						  insertParamStmt.setString(
								    insertParamValueFieldIndex,
						            compareValue);
						  insertParamStmt.execute();
						  
//						logger.info("CONFIGURED_VALUE");

						  //5. CUSTOMER_NUMBER
						  insertParamStmt.setString(
								    insertParamNameFieldIndex,
								    "CUSTOMER_NUMBER");
						  insertParamStmt.setString(
								    insertParamValueFieldIndex,
						            customerNumber);
						  insertParamStmt.execute();
						  
//						logger.info("CUSTOMER_NUMBER");
					   }
				   }
			   }
			}
//			logger.info("commit");
			conn.commit();
		}
        catch (SQLException sqle) {
			    logger.error("DB Error: " + sqle.getErrorCode() + "  " + sqle.getMessage());
			    throw new FIFException(
				    "Error while inserting requests in database.",
				     sqle);
		}

		
		logger.info("Successfully inserted " + count + " requests in the database.");
	}

	/**
	 * Main.
	 * @param args  the command-line arguments
	 */
	public static void main(String[] args) {
		String configFile = "ReconfigureNTAServiceCharacteristics.properties";
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
			createFIFRequests();
		} catch (FIFException fe) {
			logger.fatal("Cannot create reconfiguration queries.", fe);
			fe.printStackTrace();
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
			logger.error("Missing key in configuration file. Key: " + key);
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
			logger.error("Configuration value should be a number.  Key: " + key);
			throw new FIFException(
				"Configuration value should be a number.  Key: " + key,
				nfe);
		}
		return (value);
	}

}
