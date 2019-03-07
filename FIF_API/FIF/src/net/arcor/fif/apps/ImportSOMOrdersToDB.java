/*
 * $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/apps/ImportSOMOrdersToDB.java-arc   1.3   Aug 15 2018 20:41:50   lejam  $
 *
 * $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/apps/ImportSOMOrdersToDB.java-arc  $
 * 
 *    Rev 1.3   Aug 15 2018 20:41:50   lejam
 * SPN-FIF-000135290 Fixed the parameter defaulting from the metadata
 * 
 *    Rev 1.2   Jul 17 2018 10:15:42   makuier
 * Use setNull when number/boolean value  is null.
 * 
 *    Rev 1.1   Jul 05 2018 12:27:48   punya
 * Check In by Lalit SPN-CCB-000135131
 * 
 *    Rev 1.0   Oct 19 2015 12:58:34   schwarje
 * Initial revision.
 * 
 */
package net.arcor.fif.apps;

import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Types;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Properties;
import java.util.Set;

import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.common.CSVReader;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FIFFunctionalException;
import net.arcor.fif.common.FIFTechnicalException;
import net.arcor.fif.common.Log4jConfig;
import net.arcor.fif.db.DatabaseConfig;
import net.arcor.fif.messagecreator.MessageCreator;
import net.arcor.fif.messagecreator.MessageCreatorConfig;
import net.arcor.fif.messagecreator.MessageCreatorFactory;
import net.arcor.fif.messagecreator.Request;
import net.arcor.fif.messagecreator.RequestFactory;
import net.arcor.fif.messagecreator.SimpleParameter;
import net.arcor.fif.messagecreator.SimpleParameterMetaData;

import org.apache.log4j.Logger;

/**
 * Class for importing a CSV file into the FIF request table.
 * 
 * @author goethalo
 *  
 */
public class ImportSOMOrdersToDB {

	/*------------------*
	 * MEMBER VARIABLES *
	 *------------------*/

	/**
	 * The log4j logger.
	 */
	private static Logger logger = Logger.getLogger(ImportSOMOrdersToDB.class);

	/**
	 * The resource bundle to get the configuration settings from.
	 */
	private static Properties props = null;

	/**
	 * The connection to use for the database.
	 */
	private static Connection conn = null;

	/**
	 * The statement and parameters for the stored procedure call.
	 */
	private static CallableStatement callfunctionStmt = null;	
	private static ArrayList<String> callFunctionParameters = new ArrayList<String>();
	private static ArrayList<String> callFunctionParameterTypes = new ArrayList<String>();

	/**
	 * CCB/FIF date format.
	 */
	private static SimpleDateFormat sdfFIF = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");

	
	/**
	 * The database alias name to use to retrieve a connection from the
	 * connection pool.
	 */
	public static final String dbAlias = DatabaseConfig.JDBC_CONNECT_STRING_PREFIX + "requestdb";

	/*---------*
	 * METHODS *
	 *---------*/

	/**
	 * Initializes the application.
	 * 
	 * @throws FIFException
	 */
	private static void init(String configFile)
			throws FIFException {
		
		// Read the configuration
		ClientConfig.init(configFile);
				
		// Initialize the logger
		Log4jConfig.init(configFile);
		logger.info("Initializing application with property file " + configFile + "...");
		
		// Initialize the database
		logger.info("Reading database configuration from client property file " + configFile);
		DatabaseConfig.init(configFile);

		// initialize the "client" (FIF infrastructure used for validation)
		MessageCreatorConfig.init(configFile);
		
		// Prepare the statements
		try {
			logger.info("Preparing database statements...");
			conn = DriverManager.getConnection(dbAlias);
			conn.setAutoCommit(false);
			
			callfunctionStmt = conn.prepareCall(
					"{?= call " + ClientConfig.getSetting("ImportSOMOrdersToDB.Statement") + "}");
			
			int parameterCounter = 1;
			
			// read parameters and their data types from configuration
			while(true) {
				String parameterName = null;
				String parameterType = null;
				try {
					parameterName = ClientConfig.getSetting("ImportSOMOrdersToDB.Statement.ParameterNames." + parameterCounter);
					parameterType = ClientConfig.getSetting("ImportSOMOrdersToDB.Statement.ParameterTypes." + parameterCounter).toUpperCase();
					if (!(parameterType.equals("VARCHAR") ||
							parameterType.equals("NUMBER") || 
							parameterType.equals("BOOLEAN") || 
							parameterType.equals("DATE")))
						throw new FIFTechnicalException("Unknown parameter type " + parameterType);						
				} catch (FIFException e) {
					break;
				}
				callFunctionParameters.add(parameterName);
				callFunctionParameterTypes.add(parameterType);				
				parameterCounter++;				
			}
			
			
		} catch (SQLException e) {
			throw new FIFException("Error while initializing CSV importer.", e);
		}

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
			if (callfunctionStmt != null)
				callfunctionStmt.close();
		} catch (SQLException e) {
			logger.error("Cannot close statement.", e);
			success = false;
		}
		try {
			if (conn != null)
				conn.close();
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

		if (success)
			logger.info("Successfully shut down application.");
		else
			logger.error("Errors while shutting down application.");		
	}

	/**
	 * reads the CSV file and calls the stored procedure for the SOM creation.
	 * 
	 * @throws FIFException
	 *             if the requests could not be inserted.
	 */
	public static void insertRequests(String csvfile) throws FIFException {

		int lineNumber = 1;
		
		Request request = null;
		String action = ClientConfig.getSetting("ImportSOMOrdersToDB.ActionName");
	
		// Create the FIF message creator and retrieve metadata for the current action
		MessageCreator mc = MessageCreatorFactory.getMessageCreator(action);			
		ArrayList mpmd = mc.getMessageParamMetaData();
		
		// Read the CSV file
		logger.info("Reading CSV file: " + csvfile + "...");
		CSVReader reader = new CSVReader(csvfile);
        reader.readColumnNames(reader.getReader(), null, null);
		logger.info("Successfully read CSV file.");

		// Read and validate the column names
		ArrayList<String> columns = reader.getColumnNames();
		validateColumns(columns, mpmd);

		try {			
			String lineString = reader.getReader().readLine().trim();
			while (lineString != null) {
				// allow empty lines (after trim), just skip them
				if (lineString.length() == 0) {
					logger.info("Skipping empty line after line " + (lineNumber - 1));
					lineString = reader.getReader().readLine();
				}
				// process line with content
				else {
					logger.info("Processing line " + lineNumber + ": " + lineString);
					try {
						ArrayList<String> values = reader.parseColumns(lineString);
			            if (values != null && values.size() != reader.getColumnCount())
			            	throw new FIFFunctionalException("Invalid column count for line number: " + lineNumber);
			            
			            // create a FIF request object
			    		request = RequestFactory.createRequest(action);		
			    		request.addParam(new SimpleParameter("csvImportInfo", "Line: " + lineNumber + ", Source: " + csvfile));
			    		int columnCounter = 0;
			            for (String columnName : columns) {          	
			            	String paramValue = values.get(columnCounter++).trim();
			            	if(paramValue != null && !paramValue.equals(""))
			            		request.addParam(new SimpleParameter(columnName, paramValue));
			            	else
			            		request.addParam(new SimpleParameter(columnName));
			            }
			
			    		// Populate the default values and validate mandatory params, process parameter validations
			    		mc.populateDefaultsAndValidate(request);            
			            
			            processRequest(request);
					} catch (FIFException e) {
						logger.error("Error on line " + lineNumber + ", file: " + csvfile + ": " + e.getMessage());
						if (logger.isDebugEnabled())
							logger.debug(e.getMessage(), e);
					}
		            
		            lineNumber++;
		            lineString = reader.getReader().readLine();
				}
			}
		} catch (IOException ioe) {
			throw new FIFTechnicalException(ioe);
		}
		
	}

	/**
	 * calls the configured stored procedure to create the SOMs 
	 * @param request
	 * @throws FIFException
	 */
	private static void processRequest(Request request) throws FIFException {
		try {
			callfunctionStmt.clearParameters();
			// the output will contain the log message from the stored procedure
			callfunctionStmt.registerOutParameter(1, Types.VARCHAR);
			
			for (int i = 0; i < callFunctionParameters.size(); i++) {
				SimpleParameter parameter = null;
				String value = null;
				parameter = (SimpleParameter) request.getParam(callFunctionParameters.get(i));
				if (parameter != null)
					value = parameter.getValue();
				String type = callFunctionParameterTypes.get(i).toUpperCase();
				if (type.equals("VARCHAR"))
					callfunctionStmt.setString(i+2, value);
				else if (type.equals("NUMBER")){
					if (value == null || value.trim().isEmpty())
						callfunctionStmt.setNull(i+2,java.sql.Types.INTEGER);
					else
						callfunctionStmt.setLong(i+2, Long.parseLong(value));
				}else if (type.equals("BOOLEAN")) {
					if (value == null || value.trim().isEmpty())
						callfunctionStmt.setNull(i+2,java.sql.Types.BOOLEAN);
					else
						callfunctionStmt.setBoolean(i+2, value.equals("true"));
				} else if (type.equals("DATE")) {
					if (value != null && value.length()>0) {
						java.util.Date date = sdfFIF.parse(value);
						java.sql.Date sqlDate = new java.sql.Date(date.getTime());  					
						callfunctionStmt.setDate(i+2, sqlDate);
					}
					else callfunctionStmt.setDate(i+2, null);
				}
				else throw new FIFTechnicalException("Unknown parameter type " + type);				
			}

			callfunctionStmt.execute();
            String result = callfunctionStmt.getString(1);			
			logger.info(result);
			// Commit the procedure call
			conn.commit();
		} catch (SQLException sqle) {
			throw new FIFTechnicalException(sqle.getMessage(), sqle);
		} catch (ParseException pe) {
			throw new FIFTechnicalException(pe.getMessage(), pe);
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
			appName = "ImportSOMOrdersToDB";
		}

		if (args.length < 1) {
			System.err.println(appName
					+ ": imports a CSV file to process COM orders\n");
			System.err.println("Usage: " + appName + " csvfilename.csv\n");
			System.exit(0);
		} 
		
		// Set the config file name
		String configFile = "ImportSOMOrdersToDB.properties";
		if (System.getProperty("fif.propertyfile") != null) {
			configFile = System.getProperty("fif.propertyfile");
		}

		try {
			// Initialize the application
			init(configFile);
			
			// Insert the requests
	        insertRequests(args[0]);

		} catch (FIFException fe) {
			logger.fatal("Cannot import CSV file.", fe);
		} finally {
			shutdown();
		}
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
	private static void validateColumns(ArrayList<String> inputColumns, ArrayList mpmd) throws FIFException {
		
		Set<String> mandatoryColumns = new HashSet<String>();
		Set<String> optionalColumns = new HashSet<String>();
		for (Object parameter : mpmd) {
			if (parameter instanceof SimpleParameterMetaData) {
				SimpleParameterMetaData spmd = (SimpleParameterMetaData) parameter;
				if (spmd.isMandatory()) mandatoryColumns.add(spmd.getName());
				else optionalColumns.add(spmd.getName());
			}
			else throw new FIFTechnicalException("Only simple parameters are supported");				
		}
					
		// Parse the CSV input columns
		Set<String> inputColumnSet = new HashSet<String>();

		// check for duplicates
		for (String inputColumn : inputColumns)
			if ( inputColumn.indexOf("$") < 0 && !inputColumnSet.add(inputColumn)) 
				throw new FIFFunctionalException("Column " + inputColumn
						+ " is provided more than once in CSV file.");

		// Validate that all mandatory columns are provided
		for (String mandatoryColumn : mandatoryColumns)
			if (!inputColumnSet.contains(mandatoryColumn))
				throw new FIFFunctionalException("Mandatory column " + mandatoryColumn	+ " is not provided in CSV file.");		

		// Validate that no non-defined columns are provided
		for (String inputColumn : inputColumnSet)
			if (!mandatoryColumns.contains(inputColumn) && !optionalColumns.contains(inputColumn))
				throw new FIFFunctionalException("Column " + inputColumn + " appears in CSV file but is not defined as a valid column.");
	}
}