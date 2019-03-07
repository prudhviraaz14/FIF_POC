/*
 * $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/apps/ImportCSVToDB.java-arc   1.18   Aug 31 2018 10:05:42   punya  $
 *
 * $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/apps/ImportCSVToDB.java-arc  $
 * 
 *    Rev 1.18   Aug 31 2018 10:05:42   punya
 * Check in by Lalit :- Updated file to population of the TRANSACTION_LIST_STATUS to 'NOT_STARTED'
 * 
 *    Rev 1.17   Aug 13 2018 16:43:48   punya
 * Check in by Lalit IT-K34132 Added missing condition
 * 
 *    Rev 1.16   Aug 10 2018 10:01:50   punya
 * Checkin done by Lalit for IT-K34132
 * 
 *    Rev 1.15   Dec 22 2017 11:52:04   naveen.k
 * RMS 171082 - IT-K 33998 Enhance CSV Import with an additional Due date
 * 
 *    Rev 1.14   Jul 04 2017 16:45:14   naveen.k
 * RMS 166822 IT-K 33815 New FIF transaction "Berichtsvorgaben"
 * 
 *    Rev 1.13   Apr 20 2012 08:10:02   schwarje
 * IT-k-31901: CSV import for generic FifRequests
 * 
 *    Rev 1.12   Feb 17 2011 10:34:34   schwarje
 * IT-k-29968: added command line argument for CSV import applications
 * 
 *    Rev 1.11   Oct 01 2010 16:06:58   banania
 * IT-k-000029084: Updating the FIF Request row with the external system id.
 * 
 *    Rev 1.10   Sep 15 2009 15:05:44   schwarje
 * SPN-FIF-000091279: added option to ignore additional columns
 * 
 *    Rev 1.9   Apr 27 2009 14:46:56   makuier
 * Refactored to process read and process a line to avoid out of memory.
 * 
 *    Rev 1.8   Mar 25 2008 15:17:06   schwarje
 * SPN-FIF-000069034: avoid transforming param names to upper case
 * 
 *    Rev 1.7   Jul 24 2007 10:16:44   lejam
 * Corrected loop inserting rows to DB SPN-CCB-000058258
 * 
 *    Rev 1.6   Jul 16 2007 12:13:28   schwarje
 * IT-k-20130: new parameters to ignore first and last line of CSV file
 * 
 *    Rev 1.5   May 23 2007 14:52:56   makuier
 * Separator and column names can come from config file.
 * 
 *    Rev 1.4   Dec 15 2006 11:50:40   wlazlow
 * IT-k-17993
 * 
 *    Rev 1.3   Aug 11 2004 11:15:10   goethalo
 * SPN-FIF-000024699: Added CSV_IMPORT_INFO parameter.
 * 
 *    Rev 1.2   Apr 28 2004 14:14:40   goethalo
 * IT-k-000012599: Added column name validation functionality.
 */
package net.arcor.fif.apps;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.StringTokenizer;
import java.text.SimpleDateFormat;

import net.arcor.fif.common.CSVReader;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.common.Log4jConfig;
import net.arcor.fif.db.DatabaseConfig;

import org.apache.log4j.Logger;

/**
 * Class for importing a CSV file into the FIF request table.
 * 
 * @author goethalo
 *  
 */
public class ImportCSVToDB {

	/*------------------*
	 * MEMBER VARIABLES *
	 *------------------*/

	/**
	 * The log4j logger.
	 */
	private static Logger logger = Logger.getLogger(ImportCSVToDB.class);

	/**
	 * The resource bundle to get the configuration settings from.
	 */
	private static Properties props = null;

	private static String status = null;

	private static boolean isGenericFifRequest = false;
	
	/**
	 * The mandatory column names that have to be defined in the CSV.
	 */
	private static String mandatoryColumnNames = null;

	/**
	 * The optional column names that can be defined in the CSV.
	 */
	private static String optionalColumnNames = null;

	/**
	 * The optional column names that can be defined in the CSV.
	 */
	private static String optionalListNames = null;	
	
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
	 * The insert statement for inserting a FIF request parameter.
	 */
	private static PreparedStatement insertParamListStmt = null;


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
	 * The field index of the transaction ID in the request parameter table.
	 */
	private static int insertParamListTransactionIDFieldIndex = -1;

	/**
	 * The field index of the parameter name in the request parameter table.
	 */
	private static int insertParamListNameFieldIndex = -1;

	/**
	 * The field index of the parameter value in the request parameter table.
	 */
	private static int insertParamListParamFieldIndex = -1;
	
	/**
	 * The field index of the parameter value in the request parameter table.
	 */
	private static int insertParamListParamValueFieldIndex = -1;
	
	/**
	 * The field index of the parameter value in the request parameter table.
	 */
	private static int insertParamListItemNumberFieldIndex = -1;
	
	/**
	 * Indicates, if the first line of the CSV file is ignored.
	 */
	private static boolean ignoreFirstLine = false;	
	
	/**
	 * Indicates, if the last line of the CSV file is ignored.
	 */
	private static boolean ignoreLastLine = false;	
		
	/**
	 * Indicates, if parameters not mentioned in the metadata are ignored
	 */
	private static boolean ignoreAdditionalParameters = false;
	
	/**
	 * Indicates, if the parameter names are converted to upper case.
	 */
	private static boolean convertToUpperCase = true;	
	
	/**
	 * The external system id, which is no defined in the CSV.
	 */
	private static String requestExternalSystemId = null;

	/**
	 * The insert statement for inserting a FIF request parameter.
	 */
	private static PreparedStatement updatexternalSystemIdStatement = null;
	private static PreparedStatement updateStatusStatement = null;
	
	private static Date date=null;
	
	private static Date currentDate=null;
	
	private static String setDate=null;
	
	private static boolean bComitAllowed = true;
	
	private static boolean bCommitPending = false;
	
	private static HashMap<String, String> mapTxnLstID = new HashMap<String, String>();
	
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
		HashMap<String,String> statementBuilder =new HashMap<String,String>();
		ArrayList<String>columnList=new ArrayList<String>();
		ArrayList<String>valueList=new ArrayList<String>();
		// Read the configuration
		props = FileUtils.readPropertyFile(configFile);

		// Initialize the logger
		Log4jConfig.init(props);

		logger.info("Initializing application with property file " + configFile
				+ "...");
		
		try {
			isGenericFifRequest = getBoolean("ImportCSVToDB.IsGenericFifRequest");
		}
		catch (FIFException fe) {}
		
		if (!isGenericFifRequest) {
			// Get the column names
			mandatoryColumnNames = getSetting(
					"ImportCSVToDB.ColumnNames.Mandatory", true);
			optionalColumnNames = getSetting("ImportCSVToDB.ColumnNames.Optional", false);	            
			optionalListNames = getSetting("ImportCSVToDB.ListNames.Optional",false);			
			requestExternalSystemId = getSetting("ImportCSVToDB.insertExternalSystemIdName",false);
		}		
		// Initialize the database
		logger.info("Reading database configuration from client property file "
				+ clientConfigFile);
		DatabaseConfig.init(clientConfigFile);

		// Prepare the statements
		try {
			logger.info("Preparing database statements...");
			conn = DriverManager.getConnection(dbAlias);
			conn.setAutoCommit(false);
			if (!isGenericFifRequest)
			{
				//IT-k-33998 Convert the DUE_DATE value in insert statement to a placeholder.
				String str=getSetting("ImportCSVToDB.InsertRequestStmt", true);
				str=str.replaceAll("\\s+","");
				
				String substr=str.substring(str.indexOf('('),str.length());
				
				String substrcolumns=substr.substring(1,substr.indexOf("VALUES")-1);
				String substrcolumnvalues=substr.substring(substr.indexOf("VALUES")+7,substr.length()-1);
				StringTokenizer columnNames = new StringTokenizer(substrcolumns,",");
				StringTokenizer columnValues = new StringTokenizer(substrcolumnvalues,",");
				while(columnNames.hasMoreTokens()){
					columnList.add(columnNames.nextToken().toUpperCase());
				}
				columnList.add("TRANSACTION_LIST_ID");
        columnList.add("TRANSACTION_LIST_STATUS");
        
				while(columnValues.hasMoreTokens()){
					valueList.add(columnValues.nextToken());
				}
				valueList.add("?");
        valueList.add("?");
				
				if(columnList.contains("DUE_DATE")){
					valueList.remove(columnList.indexOf("DUE_DATE"));
					valueList.add(columnList.indexOf("DUE_DATE"),"?");
				}
				String finalString ="INSERT INTO FIF_REQUEST (";
				
				for (String temp : columnList) {
					finalString=finalString.concat(temp);
					if(temp!=columnList.get(columnList.size()-1))
					finalString=finalString.concat(", ");
					
				}
				int iTemp=0;
				finalString=finalString.concat(") VALUES (");
				for (String temp : valueList) {
					finalString=finalString.concat(temp);
					if(iTemp!=valueList.size()-1)
					finalString=finalString.concat(", ");
					iTemp=iTemp+1;
				}
				finalString=finalString.concat(")"); //Finished reconstruction of Insert statement with DUE_DATE placeholder
				
				logger.info("Preparing InsertRequestStmt: " + finalString);
				insertRequestStmt = conn.prepareStatement(finalString);
				
				logger.info("Preparing InsertRequestStmt: "
						+ getSetting("ImportCSVToDB.InsertParamStmt", true));
				insertParamStmt = conn.prepareStatement(getSetting(
						"ImportCSVToDB.InsertParamStmt", true));
				if(optionalListNames!=null){
				    logger.info("Preparing InsertRequestStmt: "
						+ getSetting("ImportCSVToDB.InsertParamListStmt", true));
				    insertParamListStmt = conn.prepareStatement(getSetting(
						"ImportCSVToDB.InsertParamListStmt", true));
				}
				updatexternalSystemIdStatement = conn.prepareStatement(getSetting(
						"ImportCSVToDB.UpdatexternalSystemIdStatement", true));				
				updateStatusStatement = conn.prepareStatement(
						"UPDATE FIF_REQUEST " +
						"SET STATUS = ? " +
						"WHERE TRANSACTION_ID = ?");	
			}
		} catch (SQLException e) {
			throw new FIFException("Error while initializing CSV importer.", e);
		}

		if (!isGenericFifRequest) {
			// Get the field indexes
			insertParamTransactionIDFieldIndex = getInt("ImportCSVToDB.InsertParamStmt.TransactionIDFieldIndex");
			insertParamNameFieldIndex = getInt("ImportCSVToDB.InsertParamStmt.ParamNameFieldIndex");
			insertParamValueFieldIndex = getInt("ImportCSVToDB.InsertParamStmt.ParamValueFieldIndex");
			if(optionalListNames!=null) {
			   insertParamListTransactionIDFieldIndex = getInt("ImportCSVToDB.InsertParamListStmt.TransactionIDFieldIndex");
			   insertParamListNameFieldIndex = getInt("ImportCSVToDB.InsertParamListStmt.ParamListNameFieldIndex");
			   insertParamListParamFieldIndex = getInt("ImportCSVToDB.InsertParamListStmt.ParamFieldIndex");
			   insertParamListParamValueFieldIndex = getInt("ImportCSVToDB.InsertParamListStmt.ParamValueFieldIndex");
			   insertParamListItemNumberFieldIndex = getInt("ImportCSVToDB.InsertParamListStmt.ListItemNumberFieldIndex");						
			}
			// Get the transaction ID offset
			Date current = new Date();
			transactionIDPrefix = Long.toString(current.getTime());
		}
		
		try {
			ignoreFirstLine = getBoolean("ImportCSVToDB.IgnoreFirstLine");
		} catch (FIFException e) {}

		try {
			ignoreLastLine = getBoolean("ImportCSVToDB.IgnoreLastLine");
		} catch (FIFException e) {}

		try {
			ignoreAdditionalParameters = getBoolean("ImportCSVToDB.IgnoreAdditionalParameters");
		} catch (FIFException e) {}
		
		try {
			convertToUpperCase = getBoolean("ImportCSVToDB.ColumnNames.convertToUpperCase");
		} catch (FIFException e) {}
		
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
	public static void insertRequests(String csvfile) throws FIFException {
		int sequenceNumber = 0;

		// Read the CSV file
		logger.info("Reading CSV file: " + csvfile + "...");
		CSVReader reader = new CSVReader(csvfile, ignoreFirstLine, ignoreLastLine);
		String aSeparator = getSetting("ImportCSVToDB.DesiredSeparator", false);
        String configColumnNames = null;
        if (aSeparator != null)
        	configColumnNames = getSetting("ImportCSVToDB.DesiredColumnNames", true);
        reader.readColumnNames(reader.getReader(),aSeparator,configColumnNames);
		logger.info("Successfully read CSV file.");

		// Read and validate the column names
		ArrayList<String> columns = reader.getColumnNames();
		if (!validateColumns(columns)) {
			logger.fatal("Errors while validating CSV file. "
					+ "Not inserting FIF requests.");
			return;
		}

        int lineNumber = 1;
		try {
            String lineString = reader.getReader().readLine();
            while (lineString != null) {
            	String nextLine = reader.getReader().readLine();
            	if ((lineNumber != 1 || !ignoreFirstLine) &&
            		(nextLine != null || !ignoreLastLine))
            	{	
	                ArrayList<String> values = reader.parseColumns(lineString);
	                if (values != null) {
	                    if (values.size() != reader.getColumnCount()) {
	                        throw new FIFException(
	                            "Invalid column count for line number: "
	                                + lineNumber);
	                    }
	                }
	 				String transactionID = transactionIDPrefix + sequenceNumber;
	 				String transactionListID = transactionIDPrefix +'L'+ (sequenceNumber+10);
	 				//IT-k-33998, If Column DUE_DATE is present check validity and set the date accordingly
	 				if(columns.contains("DUE_DATE")){
	 					setDate=values.get(columns.indexOf("DUE_DATE"));
	 					settingDate(setDate);
	 				}
	 				else{
	 					settingDate(setDate);
	 				}
	 				
	 				//IT-K 34132, If Column TRANSACTION_LIST_ID is present check validity and set the value accordingly
	 				String strTxnLstID = null;
	 				if(columns.contains("TRANSACTION_LIST_ID")){
	 					int strColumnIndex = columns.indexOf("TRANSACTION_LIST_ID");
            columns.add((strColumnIndex+1),"TRANSACTION_LIST_STATUS");
            
	 					strTxnLstID=values!=null?values.get(strColumnIndex):null;
	 					if(strTxnLstID !=null && strTxnLstID.length()>0){
	 						strTxnLstID=strTxnLstID.trim();
	 						if(lineNumber > 1 && mapTxnLstID.containsKey(strTxnLstID)){
	 							transactionListID=mapTxnLstID.get(strTxnLstID);
	 							bComitAllowed = false;
	 						}else{
	 							mapTxnLstID.put(strTxnLstID, transactionListID);
	 							bComitAllowed = true;
	 							processCommit(lineNumber);
	 							
	 						}
	 						values.set(strColumnIndex, transactionListID);
              setTransactionListStatusValue(columns, values, (strColumnIndex+1));
	 					}else{
	 						mapTxnLstID.clear();
	 						bComitAllowed=true;
              setTransactionListStatusValue(columns, values, (strColumnIndex+1));
	 						processCommit(lineNumber);
	 					}	 					
	 				}
					processLine(reader,csvfile,transactionID,columns,values,lineNumber);
    				sequenceNumber++;
            	}
                lineString = nextLine;
                lineNumber++;
			}
            if(bCommitPending){
            	bComitAllowed=true;
            	processCommit(2);
            	bComitAllowed=false;
            }
			logger.info("Successfully inserted requests in the database.");
		} catch (SQLException sqle) {
			throw new FIFException(
					"Error while inserting requests in database.", sqle);
		} catch (IOException e) {
            throw new FIFException(
                    "Cannot read CSV file. Error on line number: " + lineNumber,
                    e);
		}
	}

	private static void insertGenericFifRequests(String filename) throws FIFException {
		// Read the CSV file
		logger.info("Reading CSV file: " + filename + "...");
    	String line = null;
    	BufferedReader reader = null;
    	Statement statement = null;		
    	int updatedRows = 0;
        try {
        	reader = new BufferedReader(new FileReader(filename));
        	statement = conn.createStatement();		
            do {
                line = reader.readLine();
                if (line != null) {
                	line = line.trim();
                	// remove semicolon at the end of the statement
                	if (line.endsWith(";"))
                		line = line.substring(0, line.length() - 1);
                	if (line.toUpperCase().startsWith("INSERT INTO FIF_REQUEST")) {
                		logger.info("Executing the following statement: " + line);
                		updatedRows = statement.executeUpdate(line);
                		if (updatedRows != 1) {
                			logger.error("Wrong number of updated rows (" + updatedRows + ")");
                			throw new FIFException("Wrong number of updated rows (" + updatedRows + ")");
                		}
                	}
                	else {
                		logger.info("Skipping line: " + line); 
                	}
                }
            } while (line != null);
            conn.commit();
        } catch (FIFException fife) {
        	try {
        		conn.rollback();
        	} catch (SQLException e) {}
            throw fife;            
        } catch (IOException ioe) {
        	try {
        		conn.rollback();
        	} catch (SQLException e) {}
            throw new FIFException("Error while reading file " + filename, ioe);            
	    } catch (SQLException sqle) {
	    	logger.error("SQLException caught. Stopping execution. Message: " + 
	    			sqle.getMessage() + "\nDetails:", sqle);
        	try {
        		conn.rollback();
        	} catch (SQLException e) {}
            throw new FIFException("Error while processing statement: " + line, sqle);            
	    } finally {
            try {
            	if (reader != null)
            		reader.close();
            	if (statement != null)
            		statement.close();
			} catch (Exception e) {}
	    }
		
	}
	//IT-k-33998,Function to check the validity of DATE format and sets the DUE_DATE
	private static void settingDate(String setdate) throws FIFException{
		
		try{
			if(setdate!=null&&!setdate.isEmpty()){
				SimpleDateFormat formatter=new SimpleDateFormat("yyyy.MM.dd hh:mm:ss");  
				date=formatter.parse(setdate);
				currentDate=new Date();
				if(date.before(currentDate)){
					date=new Date();
				}
				
			}
			else{
				date=new Date();
			}
		}
		catch(Exception e){
			throw new FIFException("Invalid Date Format, Use CCB date format yyyy.MM.dd hh:mm:ss");
		}
	}
	private static void processLine(CSVReader reader, String csvfile,
			String transactionID, ArrayList<String> columns, ArrayList<String> values, int i) throws SQLException{
		if(values!=null){
			
			// Insert the request
			insertRequestStmt.clearParameters();
			insertRequestStmt.setString(1, transactionID);
			insertRequestStmt.setDate(2,new java.sql.Date(date.getTime()));
			if(columns.contains("TRANSACTION_LIST_ID")){
        logger.debug((values!=null?values.get(columns.indexOf("TRANSACTION_LIST_ID")):null)+" line number --- "+i);
				insertRequestStmt.setString(3, values.get(columns.indexOf("TRANSACTION_LIST_ID")));
        insertRequestStmt.setString(4, values.get(columns.indexOf("TRANSACTION_LIST_STATUS")));
			}else{
				insertRequestStmt.setString(3, "");
				insertRequestStmt.setString(4, "");
			}
			insertRequestStmt.execute();
			if (status != null) {
				logger.debug("Updating the FIF Request row with the status " + status + "...");
				updateStatusStatement.clearParameters();
				updateStatusStatement.setString(1, status);
				updateStatusStatement.setString(2, transactionID);
				updateStatusStatement.executeUpdate();
			}					

			// Insert the parameters
			for (int j = 0; j < reader.getColumnCount(); j++) {
				String value = (String) values.get(j);
				if ((value != null) && (!value.equals(""))) {
					String colName = null;
					// don't convert to upper case, if property is set
					if (convertToUpperCase)
						colName = ((String) columns.get(j)).toUpperCase();
					else
						colName = ((String) columns.get(j));
					
					if(colName.equals(requestExternalSystemId) )
					{
						logger.debug("Updating the FIF Request row with the external system id " + requestExternalSystemId + "...");
						updatexternalSystemIdStatement.clearParameters();
						updatexternalSystemIdStatement.setString(1, value);
						updatexternalSystemIdStatement.setString(2, transactionID);
						updatexternalSystemIdStatement.executeUpdate();
					}
					
					if(colName.indexOf("$")<0 && !colName.equals("DUE_DATE") ){	////IT-k-33998, Column DUE_DATE wont be added to fif_request if present.
					    insertParamStmt.clearParameters();
					    insertParamStmt.setString(
							insertParamTransactionIDFieldIndex,
							transactionID);
					    insertParamStmt.setString(insertParamNameFieldIndex,
							colName);
					    insertParamStmt.setString(insertParamValueFieldIndex,
							(String) values.get(j));
					    insertParamStmt.execute();
					}else if(optionalListNames!=null){
						insertParamListStmt.clearParameters();
						insertParamListStmt.setString(insertParamListTransactionIDFieldIndex,transactionID);
						
						
						if(!colName.matches("[A-Za-z,_,0-9]+\\$[A-Za-z,_,0-9]+\\$[0-9]+"))
						{
							logger.fatal("Errors while validating CSV file. "
									+ "Column name: " + colName + " has invalid format");
							return;
						}
						
						String paramListName = colName.substring(0,colName.indexOf("$"));
						String param = colName.substring(colName.indexOf("$")+1,colName.lastIndexOf("$"));
						String listItemNumber = colName.substring(colName.lastIndexOf("$")+1,colName.length());

						insertParamListStmt.setString(insertParamListNameFieldIndex,paramListName);
						insertParamListStmt.setString(insertParamListParamFieldIndex,param);
						insertParamListStmt.setString(insertParamListParamValueFieldIndex,(String) values.get(j));
						insertParamListStmt.setString(insertParamListItemNumberFieldIndex,listItemNumber);							
					
						insertParamListStmt.execute();
					}
				}

			}

			// Add the CSV info parameter
			insertParamStmt.clearParameters();
			insertParamStmt.setString(insertParamTransactionIDFieldIndex,
					transactionID);
			insertParamStmt.setString(insertParamNameFieldIndex,
					"CSV_IMPORT_INFO");
			insertParamStmt.setString(insertParamValueFieldIndex, "Line: "
					+ (i + 1) + ", Source: " + csvfile);
			insertParamStmt.execute();

			// Commit the insert (moved to processCommit Method below)
			//conn.commit(); 
			processCommit(i);
			
		}
		
	}
	
	public static void processCommit(int lineNumber)throws SQLException{
		if(lineNumber > 1 && bComitAllowed){
			conn.commit();
			bCommitPending=false;
      logger.debug(" commit "+(lineNumber-1));
		}else{
			bCommitPending=true;
		}
		bComitAllowed = false;
	}
	
	public static void setTransactionListStatusValue(ArrayList<String> localColumns, ArrayList<String> localValues,int strLocalColumnIndex){
		if(localColumns.contains("TRANSACTION_LIST_STATUS")){
			localValues.add(strLocalColumnIndex,"NOT_STARTED");
		}
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
			appName = "ImportCSVToDB";
		}

		if (args.length < 1) {
			System.err.println(appName
					+ ": imports a CSV file into the FIF request database\n");
			System.err.println("Usage: " + appName + " csvfilename.csv\n");
			System.exit(0);
		} // Set the config file name
		String configFile = "ImportCSVToDB.properties";
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
	        if (isGenericFifRequest) {
	        	insertGenericFifRequests(args[0]);
	        	return;
	        }
	        else 
	        	insertRequests(args[0]);

		} catch (FIFException fe) {
			logger.fatal("Cannot import CSV file.", fe);
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

	/**
	 * Gets a configuration setting from the configuration file.
	 * 
	 * @param key
	 *            the key to get the setting for.
	 * @return the <code>boolean</code> value of the setting.
	 * @throws FIFException
	 *             if the key was not found in the configuration file.
	 */
	private static boolean getBoolean(String key) throws FIFException {
		String value = getSetting(key, true);
		return (value.compareTo("false") > 0) ? true : false;
	}

	/**
	 * Validates the columns in the CSV file.
	 * 
	 * @param inputColumns
	 *            the columns read from the CSV file.
	 * @return true if the validation passed, false if not.
	 * @throws FIFException
	 *             if the columns did not pass the validation.
	 */
	private static boolean validateColumns(ArrayList<String> inputColumns) {
		boolean error = false;
		
		// Parse the mandatory column names
		Set<String> mandatoryColumns = new HashSet<String>();
		StringTokenizer st = new StringTokenizer(mandatoryColumnNames, ",",
				false);
		while (st.hasMoreTokens()) {
			String columnName = st.nextToken().trim().toUpperCase();
			if (!mandatoryColumns.add(columnName)) {
				logger
						.error("Column name "
								+ columnName
								+ " is defined more than once in "
								+ "ImportCSVToDB.ColumnNames.Mandatory property file key.");
				error = true;
			}
		}
						
		// Parse the optional column names
		Set<String> optionalColumns = new HashSet<String>();
		if ((optionalColumnNames != null)
				&& (!optionalColumnNames.trim().equals(""))) {
			st = new StringTokenizer(optionalColumnNames, ",", false);
			while (st.hasMoreTokens()) {
				String columnName = st.nextToken().trim().toUpperCase();
				if (!optionalColumns.add(columnName)) {
					logger
							.error("Column name "
									+ columnName
									+ " is defined more than once in "
									+ "ImportCSVToDB.ColumnNames.Optional property file key.");
					error = true;
				}
			}

		}
		
		// Parse the optional list column names
		Set<String> listColumns = new HashSet<String>();
		if ((optionalListNames != null)
				&& (!optionalListNames.trim().equals(""))) {
			st = new StringTokenizer(optionalListNames, ",", false);
			while (st.hasMoreTokens()) {
				String columnName = st.nextToken().trim().toUpperCase();
				if (!listColumns.add(columnName)) {
					logger
							.error("Column name "
									+ columnName
									+ " is defined more than once in "
									+ "ImportCSVToDB.ColumnNames.Optional property file key.");
					error = true;
				}
			}

		}		
		
		// Parse the CSV input columns
		Set<String> inputColumnSet = new HashSet<String>();
		Iterator<String> iter = inputColumns.iterator();
		while (iter.hasNext()) {
			String columnName = ((String) iter.next()).toUpperCase();
			if ( columnName.indexOf("$") < 0 )
				if( !inputColumnSet.add(columnName)  ) {
				logger.error("Column " + columnName
						+ " is provided more than once in CSV file.");
				error = true;
			}
		}
		
//		 Parse the CSV input list columns
		Set<String> inputListColumnSet = new HashSet<String>();
		iter = inputColumns.iterator();
		while (iter.hasNext()) {
			String columnName = ((String) iter.next()).toUpperCase();
			if (columnName.indexOf("$") > 0 )
				if (!inputListColumnSet.add(columnName)) {
				logger.error("Column " + columnName
						+ " is provided more than once in CSV file.");
				error = true;
			}
		}

		if (error) {
			return false;
		}

		// Validate that all mandatory columns are provided
		iter = mandatoryColumns.iterator();
		while (iter.hasNext()) {
			String columnName = (String) iter.next();
			if (!inputColumnSet.contains(columnName)) {
				logger.error("Mandatory column " + columnName
						+ " is not provided in CSV file.");
				error = true;
			}
		}

		// Validate that no non-defined columns are provided
		iter = inputColumnSet.iterator();
		while (iter.hasNext()) {
			String columnName = (String) iter.next();
			if ((!mandatoryColumns.contains(columnName))
					&& (!optionalColumns.contains(columnName))) {
				if (!ignoreAdditionalParameters) {
					if(!columnName.equals("DUE_DATE") && !columnName.equals("TRANSACTION_LIST_ID")){ ////IT-k-33998,No Error will be raised if Column DUE_DATE is present.
					logger.error("Column " + columnName
							+ " appears in CSV file but is not defined as a valid"
							+ "column.");
					error = true;
					}
				}
			}
		}

		//Validate list columns
		iter = inputListColumnSet.iterator();
		while (iter.hasNext()) {
			String columnName = (String) iter.next();
			Iterator<String> iterList = listColumns.iterator();
			boolean found = false;
			while(iterList.hasNext()){
				String subColumnName = (String) iterList.next();
				if(columnName.indexOf(subColumnName)>=0){
					found=true;
					break;
				}					
			}
			if (!found) {
				logger.error("Column " + columnName
						+ " appears in CSV file but is not defined as a valid"
						+ "column.");
				error = true;
			}
		}
		
		return (!error);
	}
}