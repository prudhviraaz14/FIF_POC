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
import java.util.HashSet;
import java.util.ArrayList;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.Properties;
import java.util.StringTokenizer;


import org.apache.log4j.Logger;

import net.arcor.fif.common.CSVReader;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.common.Log4jConfig;
import net.arcor.fif.db.DatabaseConfig;


/**
 * @author iarizova
 *
 */
public class ProcessDBAGVoiceProductCSV {
	/*------------------*
	 * MEMBER VARIABLES *
	 *------------------*/

	/**
	 * The log4j logger.
	 */
	private static Logger logger = Logger.getLogger(ProcessDBAGVoiceProductCSV.class);

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
	 * The select statement for selecting customer_numbers and service_subscriptions
	 * for new configured Access Number Ranges.
	 */
	private static PreparedStatement selectReconfServSubsForANRStmt = null;
	
	/**
	 * The select statement for selecting customer_numbers and service_subscriptions
	 * for new configured Main Acess Numbers.
	 */
	private static PreparedStatement selectReconfServSubsForMANStmt = null;
	
	/**
	 * The field index of the parameter begin_range in the select query
	 */
	private static int selectBeginRangeIndex = -1;
	
	/**
	 * The field index of the parameter end_range in the select query
	 */
	private static int selectEndRangeIndex = -1;
	
	/**
	 * The field index of the first parameter MAIN_ACCESS_NUM in the select query
	 */
	private static int MainAccessNumber1Index = -1;
	
	/**
	 * The field index of the second parameter MAIN_ACCESS_NUM in the select query
	 */
	private static int MainAccessNumber2Index = -1;
	
	/**
	 * The field index of the third parameter MAIN_ACCESS_NUM in the select query
	 */
	private static int MainAccessNumber3Index = -1;

	/**
	 * The insert statement for inserting a FIF request parameter.
	 */
	private static PreparedStatement insertParamStmt = null;
	
	/**
	 * The insert statement for inserting a FIF request.
	 */
	private static PreparedStatement insertAllocRequestStmt = null;
	private static PreparedStatement insertReconfRequestStmt = null;

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
	 * The field index of the service code in the original CSV file.
	 */
	private static int serviceCodeIndex = -1;
	
	/**
	 * The national telephone code.
	 */
	private static String countryPhoneCode;
	
	/**
	 * The maximal possible ammount of access number ranges (or access numbers) in a CSV file
	 */
	private static int maxANRAmount;
	
	/**
	 * The field index of the parameter city code in the original CSV file.
	 */
	private static int cityCodeIndex = -1;
	
	/**
	 * The field index of the parameter main access number in the original CSV file.
	 */
	private static ArrayList mainNumberIndexes = new ArrayList();
	
	/**
	 * The field indexes of the parameter begin range in the original CSV file.
	 */
	private static ArrayList beginRangeIndexes = new ArrayList();
	
	/**
	 * The field indexes of the parameter end range in the original CSV file.
	 */
	private static ArrayList endRangeIndexes = new ArrayList();
	
	/**
	 * The list of 'Mehrgeraetanschluss' services
	 */
	private static HashSet mainAccesNumberServices = new HashSet();
	
	/**
	 * The list of 'Anlageanschluss' services
	 */
	private static HashSet accesNumberRangeServices = new HashSet();
	
	/**
	 * The desire date of services' reconfiguration
	 */
	private static String desiredDate;


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
		
		// Get the national phone code
		countryPhoneCode = 
			getSetting("ProcessDBAGVoiceProductCSV.CountryCode");
			
		maxANRAmount = 	
			getInt("ProcessDBAGVoiceProductCSV.MaxANRAmount");
			
		desiredDate =
			getSetting("ProcessDBAGVoiceProductCSV.DesireDate");
			
		// Get the field indexes of access numbers 
		cityCodeIndex =
			getInt("ProcessDBAGVoiceProductCSV.CityCodeIndex");
			
		String stringList =
			getSetting("ProcessDBAGVoiceProductCSV.MainNumberIndex");
		    
		StringTokenizer stList = new StringTokenizer(stringList, ",", false);
		while (stList.hasMoreTokens())
		{
			String str = stList.nextToken().trim();
			mainNumberIndexes.add(new Integer(str));
		}
		
		stringList =
				getSetting("ProcessDBAGVoiceProductCSV.BeginRangeIndex");
		stList = new StringTokenizer(stringList, ",", false);
		while (stList.hasMoreTokens())
		{
			String str = stList.nextToken().trim();
			beginRangeIndexes.add(new Integer(str));
		}
		
		
		stringList =
				getSetting("ProcessDBAGVoiceProductCSV.EndRangeIndex");
		stList = new StringTokenizer(stringList, ",", false);
		while (stList.hasMoreTokens())
		{
			String str = stList.nextToken().trim();
			endRangeIndexes.add(new Integer(str));
		}
		

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
				"Preparing selectReconfServSubsForANRStmt: "
					+ getSetting("ProcessDBAGVoiceProductCSV.SelectReconfServSubsForANRStmt"));
			selectReconfServSubsForANRStmt =
				conn.prepareStatement(
					getSetting("ProcessDBAGVoiceProductCSV.SelectReconfServSubsForANRStmt"));

			logger.info(
				"Preparing selectReconfServSubsForMANStmt: "
					+ getSetting("ProcessDBAGVoiceProductCSV.SelectReconfServSubsForMANStmt"));
			selectReconfServSubsForMANStmt =
				conn.prepareStatement(
					getSetting("ProcessDBAGVoiceProductCSV.SelectReconfServSubsForMANStmt"));

			logger.info(
				"Preparing InsertRequestStmt: "
					+ getSetting("ProcessDBAGVoiceProductCSV.InsertAllocRequestStmt"));
			insertAllocRequestStmt =
				conn.prepareStatement(
					getSetting("ProcessDBAGVoiceProductCSV.InsertAllocRequestStmt"));
					
			logger.info(
				"Preparing InsertRequestStmt: "
					+ getSetting("ProcessDBAGVoiceProductCSV.InsertReconfRequestStmt"));
			insertReconfRequestStmt =
				conn.prepareStatement(
					getSetting("ProcessDBAGVoiceProductCSV.InsertReconfRequestStmt"));

			logger.info(
				"Preparing InsertRequestParamStmt: "
					+ getSetting("ProcessDBAGVoiceProductCSV.InsertParamStmt"));
			insertParamStmt =
				conn.prepareStatement(
					getSetting("ProcessDBAGVoiceProductCSV.InsertParamStmt"));
		} catch (SQLException e) {
			logger.error("DB Error: " + e.getErrorCode() + "  " + e.getMessage());
			e.printStackTrace();
			throw new FIFException("Error while initializing DB queries.", e);
		}
        catch (Exception e) {
        	logger.error("Error while initializing CSV importer. " + e.getMessage());
			e.printStackTrace();
			throw new FIFException("Error while initializing CSV importer.", e);
		}

		logger.info("Successfully prepared database statements");

		// Get the field indexes
		selectBeginRangeIndex = 
			getInt("ProcessDBAGVoiceProductCSV.SelectCustNumbServSubsStmt.RangeBeginIndex");
		selectEndRangeIndex = 
			getInt("ProcessDBAGVoiceProductCSV.SelectCustNumbServSubsStmt.RangeEndIndex");
		MainAccessNumber1Index=
			getInt("ProcessDBAGVoiceProductCSV.SelectCustNumbServSubsStmt.MainAccessNumber1");
		MainAccessNumber2Index=
			getInt("ProcessDBAGVoiceProductCSV.SelectCustNumbServSubsStmt.MainAccessNumber2");
		MainAccessNumber3Index=
			getInt("ProcessDBAGVoiceProductCSV.SelectCustNumbServSubsStmt.MainAccessNumber3");
			

        serviceCodeIndex = 			
			getInt("ProcessDBAGVoiceProductCSV.ServiceCodeIndex");

			
		insertParamTransactionIDFieldIndex =
			getInt("ProcessDBAGVoiceProductCSV.InsertParamStmt.TransactionIDFieldIndex");
		insertParamNameFieldIndex =
			getInt("ProcessDBAGVoiceProductCSV.InsertParamStmt.ParamNameFieldIndex");
		insertParamValueFieldIndex =
			getInt("ProcessDBAGVoiceProductCSV.InsertParamStmt.ParamValueFieldIndex");

		// Get the transaction ID offset
		SimpleDateFormat df = new SimpleDateFormat("MMdHms");
		Date now = new Date();
		
		transactionIDPrefix = "DBAGVD_" + df.format(now) + "_";
		
		// Load lists of 'Mehrgeraetanschluss' and 'Anlageanschluss' services
		// which are processed differently
		
		String serviceCodeList =
		    getSetting("ProcessDBAGVoiceProductCSV.MainAccesNumberServices");
		    
		StringTokenizer stServiceCode = new StringTokenizer(serviceCodeList, ",", false);
		while (stServiceCode.hasMoreTokens())
		{
			String serviceCode = stServiceCode.nextToken().trim();
			mainAccesNumberServices.add(serviceCode);
		}
		
		serviceCodeList =
			getSetting("ProcessDBAGVoiceProductCSV.AccesNumberRangeServices");
		    
		stServiceCode = new StringTokenizer(serviceCodeList, ",", false);
		while (stServiceCode.hasMoreTokens())
		{
			String serviceCode = stServiceCode.nextToken().trim();
			accesNumberRangeServices.add(serviceCode);
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
			if (selectReconfServSubsForANRStmt != null) {
				selectReconfServSubsForANRStmt.close();
			}
		} catch (SQLException e) {
			logger.error("Cannot close statement.", e);
			success = false;
		}
		try {
			if (selectReconfServSubsForMANStmt != null) {
				selectReconfServSubsForMANStmt.close();
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
	public static void processOriginalCSVFile(String csvfile) throws FIFException {

		// Read the CSV file
		logger.info("Reading CSV file: " + csvfile + "...");
		CSVReader reader = new CSVReader(csvfile);
		reader.read(null,null);
		logger.info("Successfully read CSV file.");
		ArrayList columns = reader.getColumnNames();
		ArrayList lines = reader.getLines();

		// Insert the requests
		logger.info(
			"Creating CSV file for reconfiguration requests in the database...");

		try {
			for (int i = 0; i < reader.getLineCount(); i++) {
					
				String transactionID = transactionIDPrefix + i + "_";
				ArrayList values = (ArrayList) lines.get(i);
				String serviceCode = (String) values.get(serviceCodeIndex);
					
				if (mainAccesNumberServices.contains(serviceCode))
				{
					processMainAccessNumberService(values, transactionID);
				}
				else if (accesNumberRangeServices.contains(serviceCode))
				{
					processAccessNumberRangeService(values, transactionID);
				}
				else
				{
					logger.error("The string " + (i+1)+  " in the source CSV file is wrong." +
					             "The service code " + serviceCode + " does not belong to service code groups " +
					             "defined by the variable ProcessDBAGVoiceProductCSV.MainAccesNumberServices " +
					             " and ProcessDBAGVoiceProductCSV.AccesNumberRangeServices of the properties file");
					             
					continue;
				}
				
				transactionID += "A";
				
				// insert request for creating new PS
				// Insert the request
				insertAllocRequestStmt.clearParameters();
				insertAllocRequestStmt.setString(1, transactionID);
				insertAllocRequestStmt.execute();

				// Insert the parameters
				for (int j = 0; j < reader.getColumnCount(); j++) {
					String value = (String) values.get(j);
					if ((value != null) && (!value.equals(""))) {
						insertParamStmt.clearParameters();
						insertParamStmt.setString(
							insertParamTransactionIDFieldIndex,
							transactionID);
						insertParamStmt.setString(
							insertParamNameFieldIndex,
							(String) columns.get(j));
						insertParamStmt.setString(
							insertParamValueFieldIndex,
							(String) values.get(j));
						insertParamStmt.execute();
					}
				}
				
				insertParamStmt.setString(
							insertParamNameFieldIndex,
							"DESIRED_DATE");
				insertParamStmt.setString(
							 insertParamValueFieldIndex,
							 desiredDate);
				insertParamStmt.execute(); 
			}

			conn.commit();
		}
		catch (SQLException sqle) {
			logger.error("DB error: " + sqle.getErrorCode() + sqle.getMessage());
			throw new FIFException(
				"Commit error.",
				sqle);
		}
	}

	public static void processAccessNumberRangeService(ArrayList values, String transactionID) throws FIFException 
	{
		for (int i = 0; i< maxANRAmount; i++)
		{
		  	String startRange = countryPhoneCode + 
								(String) values.get(cityCodeIndex) +
								(String) values.get(((Integer)mainNumberIndexes.get(0)).intValue()) +
								(String) values.get(((Integer)beginRangeIndexes.get(i)).intValue());
			String endRange   = countryPhoneCode + 
								(String) values.get(cityCodeIndex) +
								(String) values.get(((Integer)mainNumberIndexes.get(0)).intValue()) +
								(String) values.get(((Integer)endRangeIndexes.get(i)).intValue());

			if (((String) values.get(((Integer)beginRangeIndexes.get(i)).intValue())).equals("") ||
			    ((String) values.get(((Integer)endRangeIndexes.get(i)).intValue())).equals(""))
			{
				continue;
			}

			int count = 0;
			
			logger.debug("Selecting query's parameters for ACCESS_NUMBER_RANGE: from " + startRange + 
                                                                                ", to " + endRange);

            try {

				selectReconfServSubsForANRStmt.clearParameters();
				selectReconfServSubsForANRStmt.setString(selectBeginRangeIndex, startRange);
				selectReconfServSubsForANRStmt.setString(selectEndRangeIndex, endRange);
				
				ResultSet resultSet = selectReconfServSubsForANRStmt.executeQuery();

				while (resultSet.next())
				{
					String customerNumber = resultSet.getString(1);
					String serviceSubscriptionId = resultSet.getString(2);
					String serviceSubscriptionCode = resultSet.getString(4);
					String accessNumber = resultSet.getString(5);
					
					StringTokenizer stTokenizer = new StringTokenizer(accessNumber, ";", false);
					stTokenizer.nextToken(); // skip country code
					String cityCode = stTokenizer.nextToken().trim();
					String localNumber = stTokenizer.nextToken().trim();
									
					logger.debug("customer_number: " + customerNumber + ", " + 
								 "service_subscription_id: "  + serviceSubscriptionId + ", " +
								 "service_subscription_code: "  + serviceSubscriptionCode + ", " +
								 "cityCode: " + cityCode + ", " +
								 "localNumber: " + localNumber);


                    // insert parameters request to DB
					insertReconfRequestStmt.clearParameters();
					insertReconfRequestStmt.setString(1, transactionID + "R" + count);
					insertReconfRequestStmt.execute();
						  
				  // Insert the parameters
				  // 1. service subscription id
					insertParamStmt.clearParameters();
					insertParamStmt.setString(
							  	insertParamTransactionIDFieldIndex,
								transactionID + "R" + count);
					insertParamStmt.setString(
							  	insertParamNameFieldIndex,
							  	"SERVICE_SUBSCRIPTION_ID");
					insertParamStmt.setString(
							  	insertParamValueFieldIndex,
							 	 serviceSubscriptionId);
					insertParamStmt.execute();
						  						  
				   //2. desire date
					insertParamStmt.setString(
							  	insertParamNameFieldIndex,
							  	"DESIRED_DATE");
					insertParamStmt.setString(
							 	 insertParamValueFieldIndex,
							 	 desiredDate);
					insertParamStmt.execute();
						  						  
					//3. service characteristic code
					insertParamStmt.setString(
							 	 insertParamNameFieldIndex,
							  	"SERVICE_CHAR_CODE");
					insertParamStmt.setString(
							  	insertParamValueFieldIndex,
								serviceSubscriptionCode);
					insertParamStmt.execute();
					      

					//4. CONFIGURED_VALUE
					insertParamStmt.setString(
							  	insertParamNameFieldIndex,
							  	"CITY_CODE");
					insertParamStmt.setString(
							  	insertParamValueFieldIndex,
								cityCode);
					insertParamStmt.execute();
					
					insertParamStmt.setString(
								insertParamNameFieldIndex,
								"LOCAL_NUMBER");
					insertParamStmt.setString(
								insertParamValueFieldIndex,
								localNumber);
					insertParamStmt.execute();
						  
					//5. CUSTOMER_NUMBER
					insertParamStmt.setString(
							 	 insertParamNameFieldIndex,
							  	"CUSTOMER_NUMBER");
					insertParamStmt.setString(
							  	insertParamValueFieldIndex,
							  	customerNumber);
					insertParamStmt.execute();

					count++;                 
				}
				
				
			}
			catch (SQLException sqle) {
				logger.error("Error while executing DB requests." + sqle.getErrorCode() + sqle.getMessage());
				throw new FIFException(
					"Error while inserting requests in database.",
					sqle);
			}
			
			logger.debug("   For the range: start range " + startRange + ", end range " + endRange +				        " it was " + count + " rows selected");

		}
	}
	
	public static void processMainAccessNumberService(ArrayList values, String transactionID) throws FIFException 
	{
		String callNumber1 = countryPhoneCode + 
							(String) values.get(cityCodeIndex) +
							(String) values.get(((Integer)mainNumberIndexes.get(0)).intValue());
		String callNumber2 = countryPhoneCode + 
							(String) values.get(cityCodeIndex) +
							(String) values.get(((Integer)mainNumberIndexes.get(1)).intValue());
		String callNumber3 = countryPhoneCode + 
							(String) values.get(cityCodeIndex) +
							(String) values.get(((Integer)mainNumberIndexes.get(2)).intValue());


		int count = 0;

        logger.debug("Selecting query's parameters for MAIN_ACCESS_NUM: " + callNumber1 + ", " 
                                                                          + callNumber2 + ", "
                                                                          + callNumber3);

		try {

			selectReconfServSubsForMANStmt.clearParameters();
			selectReconfServSubsForMANStmt.setString(MainAccessNumber1Index, callNumber1);
			selectReconfServSubsForMANStmt.setString(MainAccessNumber2Index, callNumber2);
			selectReconfServSubsForMANStmt.setString(MainAccessNumber3Index, callNumber3);
				
			ResultSet resultSet = selectReconfServSubsForMANStmt.executeQuery();

			logger.debug("Selected: ");
			while (resultSet.next())
			{
				String customerNumber = resultSet.getString(1);
				String serviceSubscriptionId = resultSet.getString(2);
				String serviceSubscriptionCode = resultSet.getString(4);
				String accessNumber = resultSet.getString(5);
				
				StringTokenizer stTokenizer = new StringTokenizer(accessNumber, ";", false);
				stTokenizer.nextToken(); // skip country code
				String cityCode = stTokenizer.nextToken().trim();
				String localNumber = stTokenizer.nextToken().trim();
									
				logger.debug("customer_number: " + customerNumber + ", " + 
							 "service_subscription_id: "  + serviceSubscriptionId + ", " +
							 "service_subscription_code: "  + serviceSubscriptionCode + ", " +
							 "cityCode: " + cityCode + ", " +
							 "localNumber: " + localNumber);

				count++;
				
				// insert parameters request to DB
				insertReconfRequestStmt.clearParameters();
				insertReconfRequestStmt.setString(1, transactionID + "R" + count);
				insertReconfRequestStmt.execute();
						  
			  // Insert the parameters
			  // 1. service subscription id
				insertParamStmt.clearParameters();
				insertParamStmt.setString(
							insertParamTransactionIDFieldIndex,
							transactionID + "R" + count);
				insertParamStmt.setString(
							insertParamNameFieldIndex,
							"SERVICE_SUBSCRIPTION_ID");
				insertParamStmt.setString(
							insertParamValueFieldIndex,
							 serviceSubscriptionId);
				insertParamStmt.execute();
						  						  
			   //2. desire date
				insertParamStmt.setString(
							insertParamNameFieldIndex,
							"DESIRED_DATE");
				insertParamStmt.setString(
							 insertParamValueFieldIndex,
							 desiredDate);
				insertParamStmt.execute();
						  						  
				//3. service characteristic code
				insertParamStmt.setString(
							 insertParamNameFieldIndex,
							"SERVICE_CHAR_CODE");
				insertParamStmt.setString(
							insertParamValueFieldIndex,
							serviceSubscriptionCode);
				insertParamStmt.execute();
					      

				//4. CONFIGURED_VALUE
				insertParamStmt.setString(
							insertParamNameFieldIndex,
							"CITY_CODE");
				insertParamStmt.setString(
							insertParamValueFieldIndex,
							cityCode);
				insertParamStmt.execute();
					
				insertParamStmt.setString(
							insertParamNameFieldIndex,
							"LOCAL_NUMBER");
				insertParamStmt.setString(
							insertParamValueFieldIndex,
							localNumber);
				insertParamStmt.execute();
						  
				//5. CUSTOMER_NUMBER
				insertParamStmt.setString(
							 insertParamNameFieldIndex,
							"CUSTOMER_NUMBER");
				insertParamStmt.setString(
							insertParamValueFieldIndex,
							customerNumber);
				insertParamStmt.execute();
			}
			logger.info("There are " + count + " rows selected for MAIN_ACCESS_NUM: " + callNumber1 + ", " 
																					  + callNumber2 + ", "
																					  + callNumber3);
		}
		catch (SQLException sqle) {
			logger.error("Error while executing DB requests." + sqle.getErrorCode() + sqle.getMessage());
			throw new FIFException(
				"Error while inserting requests in database.",
				sqle);
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
				"ProcessDBAGVoiceProductCSV: process a CSV file from Telematik in order to  \n");
			System.err.println(
				"                               migrate DBAG clients. Created for the IT-11332\n");
			System.err.println("Usage: ProcessDBAGVoiceProductCSV csvfilename.csv\n");
			System.exit(0);
		} // Set the config file name
		String configFile = "ProcessDBAGVoiceProductCSV.properties";
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
			processOriginalCSVFile(args[0]);
		} catch (FIFException fe) {
			logger.fatal("Cannot import CSV file.", fe);
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
