/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/DatabaseFifRequestDataAccess.java-arc   1.5   Feb 14 2019 18:16:52   lejam  $
 *    $Revision:   1.5  $
 *    $Workfile:   DatabaseFifRequestDataAccess.java  $
 *      $Author:   lejam  $
 *        $Date:   Feb 14 2019 18:16:52  $
 *
 *  
 *  Copyright (C) Vodafone
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/DatabaseFifRequestDataAccess.java-arc  $
 * 
 *    Rev 1.5   Feb 14 2019 18:16:52   lejam
 * IT-k-34229 Added fetchFifRequestResult
 * 
 *    Rev 1.4   Jan 29 2013 11:09:48   schwarje
 * IT-32438: updates
 * 
 *    Rev 1.3   Jan 17 2013 15:27:36   schwarje
 * IT-32438: added inserting of FifRequests, new parameters
 * 
 *    Rev 1.2   Nov 29 2012 15:20:24   lejam
 * Added request status as sql param to retrievePendingFifRequests IT-k-32482
 * 
 *    Rev 1.1   Jun 01 2010 18:03:30   schwarje
 * IT-26029: updates
 * 
 *    Rev 1.0   May 25 2010 16:27:18   schwarje
 * Initial revision.
 * 
 * 
 ***************************************************************************  
 */
package net.arcor.fif.db;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.common.FIFException;


public class DatabaseFifRequestDataAccess extends DataAccess {

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement fetchFifRequestById = null;

    /**
     * The prepared statement for retrieving the request lists
     */
    private PreparedStatement fetchFifRequestListById = null;

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement fetchFifRequestParam = null;

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement fetchFifRequestParamList = null;

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement fetchPendingFifRequests = null;

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement lockFifRequest = null;

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement updateFifRequest = null;

    /**
     * The prepared statement for inserting the FifRequest result
     */
    private PreparedStatement insertFifRequestResult = null;

    /**
     * The prepared statement for retrieving the FifRequest result
     */
    private PreparedStatement fetchFifRequestResult = null;

    /**
     * The prepared statement for inserting a new FifRequest
     */
    private PreparedStatement insertFifRequest = null;

    /**
     * The prepared statement for inserting a new FifRequest
     */
    private PreparedStatement insertFifRequestParam = null;

    /**
     * The prepared statement for inserting a new FifRequest
     */
    private PreparedStatement insertFifRequestParamList = null;

    /**
     * The prepared statement for inserting a new FifRequest
     */
    private PreparedStatement fifRequestsForExternalSystemIdExists = null;
    
	/**
	 * indicates the maximum length of the error message in the respective DB 
	 */
	private static int maxErrorLength = 4000;
	
	/**
	 * indicates, if the respective FIF clent supports parameter lists
	 */
	private static boolean enableParameterLists = true;
	
	/**
	 * indicates, if the respective FIF clent supports tranasaction lists
	 */
	private static boolean enableTransactionLists = true;
	
	/**
	 * indicates, if the respective FIF clent supports dependent transactions
	 */
	private static boolean enableDependentTransactions = true;	
	
	/**
	 * indicates, if the respective FIF clent supports result parameters
	 */
	private static boolean enableTransactionResults = true;	
	
	/**
	 * indicates, if the respective FIF clent supports result parameters
	 */
	private static boolean enableInsertFifRequest = false;	
	
	/**
	 * indicates, if the respective FIF clent supports result parameters
	 */
	private static boolean enableExternalSystemId = false;	
	
	/**
	 * indicates, if the respective FIF clent supports result parameters
	 */
	private static boolean enableFifRequestsForExternalSystemIdExists = false;	
   
	/**
	 * Constructor using default db alias
	 * @throws FIFException
	 */
	public DatabaseFifRequestDataAccess() throws FIFException {
		super("default");
		init();
	}
    
	/**
	 * Constructor using db alias from input
	 * @param dbAlias
	 * @throws FIFException
	 */
	public DatabaseFifRequestDataAccess(String dbAlias) throws FIFException {
		super(dbAlias);
		init();
	}
    
    /* (non-Javadoc)
     * @see net.arcor.fif.db.DataAccess#init()
     */
    public void init() throws FIFException {
    	if (initialized) return;
    	
    	try {
			enableInsertFifRequest = ClientConfig.getBoolean(
					"SynchronousDatabaseClient.FifRequest.EnableInsertFifRequest");
		} catch (FIFException e) {}
    	try {
    		enableExternalSystemId = ClientConfig.getBoolean(
					"SynchronousDatabaseClient.FifRequest.EnableExternalSystemId");
		} catch (FIFException e) {}
    	try {
    		enableFifRequestsForExternalSystemIdExists = ClientConfig.getBoolean(
					"SynchronousDatabaseClient.FifRequest.EnableFifRequestsForExternalSystemIdExists");
		} catch (FIFException e) {}

    	try {    		
    		logger.info("Preparing database statements...");
    		
    		fetchFifRequestById = conn.prepareStatement(ClientConfig.getSetting(
					"SynchronousDatabaseClient.FifRequest.FetchFifRequestById"));
    		fetchFifRequestParam = conn.prepareStatement(ClientConfig.getSetting(
					"SynchronousDatabaseClient.FifRequest.FetchFifRequestParam"));
    		fetchPendingFifRequests = conn.prepareStatement(ClientConfig.getSetting(
   					"SynchronousDatabaseClient.FifRequest.FetchPendingFifRequests"));
    		lockFifRequest = conn.prepareStatement(ClientConfig.getSetting(
					"SynchronousDatabaseClient.FifRequest.LockFifRequest"));
    		updateFifRequest = conn.prepareStatement(ClientConfig.getSetting(
    				"SynchronousDatabaseClient.FifRequest.UpdateFifRequest"));
    		if (enableParameterLists) {
    			fetchFifRequestParamList = conn.prepareStatement(ClientConfig.getSetting(
						"SynchronousDatabaseClient.FifRequest.FetchFifRequestParamList"));
    			if (enableInsertFifRequest)
    				insertFifRequestParamList = conn.prepareStatement(ClientConfig.getSetting(
    						"SynchronousDatabaseClient.FifRequest.InsertFifRequestParamList"));    			

    		}
    		if (enableTransactionResults) {
    			insertFifRequestResult = conn.prepareStatement(ClientConfig.getSetting(
    					"SynchronousDatabaseClient.FifRequest.InsertFifRequestResult"));
    			fetchFifRequestResult = conn.prepareStatement(ClientConfig.getSetting(
    					"SynchronousDatabaseClient.FifRequest.FetchFifRequestResult"));
    		}
    		if (enableInsertFifRequest) {
    			insertFifRequest = conn.prepareStatement(ClientConfig.getSetting(
    				"SynchronousDatabaseClient.FifRequest.InsertFifRequest"));
    			insertFifRequestParam = conn.prepareStatement(ClientConfig.getSetting(
					"SynchronousDatabaseClient.FifRequest.InsertFifRequestParam"));    			
    		}
    		if (enableTransactionLists)
    			fetchFifRequestListById = conn.prepareStatement(ClientConfig.getSetting(
    					"SynchronousDatabaseClient.FifRequest.FetchFifRequestListById"));
    		if (enableFifRequestsForExternalSystemIdExists)
    			fifRequestsForExternalSystemIdExists = conn.prepareStatement(ClientConfig.getSetting(
    				"SynchronousDatabaseClient.FifRequest.FifRequestsForExternalSystemIdExists"));
    		
    	} catch (SQLException e) {
    		throw new FIFException(
    				"Error while initializing Fif request data access.", e);
    	}
    	initialized = true;    	
    }

	/**
	 * method for updating a fif transaction in the FIF_TRANSACTION table
	 * @param fifRequest
	 * @throws FIFException
	 */
	public synchronized void updateFifRequest(DatabaseFifRequest fifRequest) throws FIFException {
        if (updateFifRequest == null)
        	throw new FIFException("Database access is not properly initialized");
        
    	try {
			int i = 1;
			updateFifRequest.clearParameters();
			updateFifRequest.setTimestamp(i++, 
					(fifRequest.getDueDate() != null) ?
							new Timestamp(fifRequest.getDueDate().getTime()) : 
							null);
			updateFifRequest.setTimestamp(i++, 
					(fifRequest.getStartDate() != null) ?
							new Timestamp(fifRequest.getStartDate().getTime()) : 
							null);
			updateFifRequest.setTimestamp(i++, 
					(fifRequest.getEndDate() != null) ?
							new Timestamp(fifRequest.getEndDate().getTime()) : 
							null);
			// TODO also aufpassen
			updateFifRequest.setString(i++, fifRequest.getStatus());
			// truncate error message before writing it
			String errorText = fifRequest.getErrorText();
			if (errorText != null && errorText.length() > maxErrorLength)
				errorText = errorText.substring(0, maxErrorLength);
			updateFifRequest.setString(i++, errorText);
			if (enableTransactionLists)
				updateFifRequest.setString(i++, fifRequest.getTransactionListStatus());
			updateFifRequest.setString(i++, fifRequest.getTransactionId());
			if (logger.isDebugEnabled())
				logger.debug("Executing statement: " + 
						ClientConfig.getSetting("SynchronousDatabaseClient.FifRequest.UpdateFifRequest") + 
						", parameters: " + fifRequest.getStartDate() + 
						", " + fifRequest.getEndDate() + 
						", " + fifRequest.getStatus() + 
						", " + fifRequest.getErrorText() + 
						", " + fifRequest.getTransactionListStatus() + 
						", " + fifRequest.getTransactionId());
			int updatedRows = updateFifRequest.executeUpdate();
			
			if (enableTransactionResults && fifRequest.getResults() != null)
				for (String name : fifRequest.getResults().keySet()) {
					try {
						insertFifRequestResult.clearParameters();
						insertFifRequestResult.setString(1, fifRequest.getTransactionId());
						insertFifRequestResult.setString(2, name);
						insertFifRequestResult.setString(3, fifRequest.getResults().get(name));
						insertFifRequestResult.executeUpdate();
					} catch (SQLException e) {
						// ignore the unique constraint
						if (e.getErrorCode() != 1)
							throw new FIFException(e);
					}
				}
			
			if (updatedRows == 0) {
				try {
					conn.rollback();
				} catch (SQLException e1) {}				
				throw new FIFException(updatedRows + " rows were updated. Should have been more.");
			}
			
			commit();
		} catch (SQLException e) {
			try {
				conn.rollback();
			} catch (SQLException e1) {}
			throw new FIFException("Error while updating the Fif table: " + e.getMessage(), e);
		}
    }
    
    /**
     * method for retrieving return_value from FIF_REQUEST_RESULT table
     * @param transactionID
     * @param parameterName
     * @return parameterValue
     * @throws FIFException
     */
    public synchronized String fetchFifRequestResult(String transactionID, String parameterName) throws FIFException {
    	try {
    		fetchFifRequestResult.clearParameters();
    		fetchFifRequestResult.setString(1, transactionID);
    		fetchFifRequestResult.setString(2, parameterName);
			if (logger.isDebugEnabled())
				logger.debug("Executing statement: " + 
						ClientConfig.getSetting("SynchronousDatabaseClient.FifRequest.FetchFifRequestResult") + 
						", parameters: " + transactionID + ", " + parameterName);
			ResultSet result = fetchFifRequestResult.executeQuery();
			
			ArrayList<String> parameterValues = new ArrayList<String>();
			while (result.next())
				parameterValues.add(result.getString(1));
			result.close();
			String parameterValue = null;
			if (!parameterValues.isEmpty())
				parameterValue = parameterValues.get(0);
			return parameterValue;
		} catch (SQLException e) {
			throw new FIFException(e);
		}
    }

  /**
     * method for retrieving a specific fif transaction from the FIF_TRANSACTION table
     * @param transactionListId
     * @param clientType
     * @return one FifRequest retrieved by the statement
     * @throws FIFException
     */
    public synchronized ArrayList<DatabaseFifRequest> fetchFifRequestListById(String transactionListId) throws FIFException {
    	if (transactionListId == null || transactionListId.equals(""))
    		throw new FIFException("Invalid transactionID.");
    	try {
    		fetchFifRequestListById.clearParameters();
    		fetchFifRequestListById.setString(1, transactionListId);
			if (logger.isDebugEnabled())
				logger.debug("Executing statement: " + 
						ClientConfig.getSetting("SynchronousDatabaseClient.FifRequest.FetchFifRequestListById") + 
						", parameters: " + transactionListId);
			ResultSet result = fetchFifRequestListById.executeQuery();

			ArrayList<DatabaseFifRequest> requests = new ArrayList<DatabaseFifRequest>();
    		while (result.next()) 
    			requests.add(fetchFifRequestById(
    					result.getString(1)));    		
    		result.close();
    		return requests;
		} catch (SQLException e) {
			throw new FIFException(e);
		}
    }
    
    /**
     * method for retrieving a specific fif transaction from the *_FIF_REQUEST table
     * @param transactionId
     * @param clientType
     * @return one FifRequest retrieved by the statement
     * @throws FIFException
     */
    public synchronized DatabaseFifRequest fetchFifRequestById(String transactionId) throws FIFException {
    	if (transactionId == null || transactionId.equals(""))
    		throw new FIFException("Invalid transactionID.");
    	try {
    		logger.info("Retrieving FifRequest " + transactionId);
			int i = 1;
			fetchFifRequestById.clearParameters();
			fetchFifRequestById.setString(i++, transactionId);
			if (logger.isDebugEnabled())
				logger.debug("Executing statement: " + 
						ClientConfig.getSetting("SynchronousDatabaseClient.FifRequest.FetchFifRequestById") + 
						", parameters: " + transactionId);
			ResultSet result = fetchFifRequestById.executeQuery();
			DatabaseFifRequest request = null;	
    		if (result.next())
    			request = extractFifRequest(result);    			    		
    		result.close();
    		if (request == null)
    			logger.info("FifRequest " + transactionId + " couldn't be found.");    		
    		return request;
		} catch (SQLException e) {
			throw new FIFException(e);
		}
    }
    
    /**
     * method for retrieving a specific fif transaction from the *_FIF_REQUEST table
     * @param transactionId
     * @param clientType
     * @return one FifRequest retrieved by the statement
     * @throws FIFException
     */
    public synchronized boolean fifRequestsForExternalSystemIdExists(String externalSystemId) throws FIFException {
    	if (externalSystemId == null || externalSystemId.equals(""))
    		throw new FIFException("Invalid externalSystemId.");
    	try {
    		fifRequestsForExternalSystemIdExists.clearParameters();
    		fifRequestsForExternalSystemIdExists.setString(1, externalSystemId);
			if (logger.isDebugEnabled())
				logger.debug("Executing statement: " + 
						ClientConfig.getSetting("SynchronousDatabaseClient.FifRequest.FifRequestsForExternalSystemIdExists") + 
						", parameters: " + externalSystemId);
			ResultSet result = fifRequestsForExternalSystemIdExists.executeQuery();
			boolean fifRequestsForExternalSystemIdExists = result.next();
    		result.close();
    		return fifRequestsForExternalSystemIdExists;
		} catch (SQLException e) {
			throw new FIFException(e);
		}
    }

    /**
     * method for retrieving one batch of pending fif transaction from the *_FIF_REQUEST table
     * @param status
     * @param clientId
     * @param batchSize
     * @return list of FifTransactions
     * @throws FIFException
     */
    public synchronized ArrayList<String> retrievePendingFifRequests(int batchSize, String requestStatus) throws FIFException {
    	try {
			fetchPendingFifRequests.clearParameters();
			fetchPendingFifRequests.setString(1, requestStatus);
			fetchPendingFifRequests.setInt(2, batchSize);
			if (logger.isDebugEnabled())
				logger.debug("Executing statement: " + 
						ClientConfig.getSetting("SynchronousDatabaseClient.FifRequest.FetchPendingFifRequests") + 
						", parameters: " + requestStatus+ ", " + batchSize);
			ResultSet result = fetchPendingFifRequests.executeQuery();
			
			ArrayList<String> transactionIds = new ArrayList<String>();
			while (result.next())
				transactionIds.add(result.getString(1));
			result.close();
			return transactionIds;
		} catch (SQLException e) {
			throw new FIFException(e);
		}
    }

    /**
     * method for retrieving a batch of fif transaction from the FIF_TRANSACTION table
     * with specific properties as mentioned in the parameters
     * @param status
     * @param clientId
     * @param retries
     * @param batchSize
     * @param age
     * @return list of FifTransactions
     * @throws FIFException
     */
    public synchronized void lockFifRequest(DatabaseFifRequest dbFifRequest) throws FIFException {
    	try {
    		lockFifRequest.clearParameters();
    		lockFifRequest.setString(1, dbFifRequest.getTransactionId());
    		lockFifRequest.setString(2, dbFifRequest.getStatus());
			if (logger.isDebugEnabled())
				logger.debug("Executing statement: " + 
						ClientConfig.getSetting("SynchronousDatabaseClient.FifRequest.LockFifRequest") + 
						", parameters: " + dbFifRequest.getTransactionId() + ", " + dbFifRequest.getStatus());
    		ResultSet result = lockFifRequest.executeQuery();
    		boolean locked = result.next();
    		result.close();
    		if (locked)
    			logger.info("Request " + dbFifRequest.getTransactionId() + " successfully locked.");
    		else
    			throw new FIFException("Couldn't lock request " + dbFifRequest.getTransactionId()); 
		} catch (SQLException e) {
			throw new FIFException(e);
		}
    }

    /**
     * helper method for extracting query result into FifTransaction objects
     * @param result
     * @return list of FifTransactions
     * @throws SQLException
     */
    private synchronized DatabaseFifRequest extractFifRequest(ResultSet result) throws SQLException {
		int i = 1;
		DatabaseFifRequest databaseFifRequest = new DatabaseFifRequest();
		databaseFifRequest.setTransactionId(result.getString(i++));
		databaseFifRequest.setStatus(result.getString(i++));
		if (enableTransactionLists) {
			databaseFifRequest.setTransactionListId(result.getString(i++));
			databaseFifRequest.setTransactionListStatus(result.getString(i++));
		}
		if (enableDependentTransactions)
			databaseFifRequest.setDependentTransactionId(result.getString(i++));
		databaseFifRequest.setDueDate(result.getTimestamp(i++)); // TODO format date
		databaseFifRequest.setStartDate(result.getTimestamp(i++));
		databaseFifRequest.setEndDate(result.getTimestamp(i++));
		databaseFifRequest.setActionName(result.getString(i++));
		if (enableExternalSystemId)
			databaseFifRequest.setExternalSystemId(result.getString(i++));
		
		Map<String, String> parameters = new HashMap<String, String>();
		fetchFifRequestParam.clearParameters();
		fetchFifRequestParam.setString(1, databaseFifRequest.getTransactionId());
		ResultSet paramResult = fetchFifRequestParam.executeQuery();
		while (paramResult.next())
			parameters.put(paramResult.getString(1), paramResult.getString(2));
		paramResult.close();
		databaseFifRequest.setParameters(parameters);
		
		if (enableParameterLists) {
			fetchFifRequestParamList.clearParameters();
			fetchFifRequestParamList.setString(1, databaseFifRequest.getTransactionId());
			ResultSet paramListResult = fetchFifRequestParamList.executeQuery();
			
			Map<String, List<Map<String, String>>> parameterLists = new HashMap<String, List<Map<String, String>>>();
			String currentListName = null;
			String currentItem = null;
			Map<String, String> currentListItem = null;
			List<Map<String, String>> currentList = null;
			while (paramListResult.next()) {
				String parameterListName = paramListResult.getString(1);
				String listItemNumber = paramListResult.getString(2);
				String parameterName = paramListResult.getString(3);
				String value = paramListResult.getString(4);
				
				if (!parameterListName.equals(currentListName)) {
					if (currentList != null) {
						if (currentListItem != null)
							currentList.add(currentListItem);
						parameterLists.put(currentListName, currentList);
					}
					currentList = new ArrayList<Map<String, String>>();
					currentListName = parameterListName;
					currentListItem = new HashMap<String, String>();
					currentItem = listItemNumber;
				}
				
				else if (!listItemNumber.equals(currentItem)) {
					if (currentListItem != null)
						currentList.add(currentListItem);
					currentListItem = new HashMap<String, String>();
					currentItem = listItemNumber;				
				}
			
				currentListItem.put(parameterName, value);				
			}
			paramListResult.close();
			if (currentList != null) {
				if (currentListItem != null)
					currentList.add(currentListItem);
				parameterLists.put(currentListName, currentList);
			}
			databaseFifRequest.setParameterLists(parameterLists);		
		}		
		return databaseFifRequest;
	}
    
	/**
	 * @param fifRequest
	 * @throws FIFException
	 */
	public void insertFifRequest(DatabaseFifRequest fifRequest) throws FIFException {
		int i = 0;
		try {
			// fif_request (or similar)
			insertFifRequest.clearParameters();
			insertFifRequest.setString(++i, fifRequest.getTransactionId());
			insertFifRequest.setString(++i, fifRequest.getStatus());
			insertFifRequest.setString(++i, fifRequest.getActionName());			
			insertFifRequest.setInt(++i, fifRequest.getPriority());			
			insertFifRequest.setTimestamp(++i, new Timestamp(fifRequest.getDueDate().getTime()));
			if (enableExternalSystemId)
				insertFifRequest.setString(++i, fifRequest.getExternalSystemId());
			insertFifRequest.executeUpdate();
			
			// fif_request_param (or similar)
			for (String key : fifRequest.getParameters().keySet()) {
				int j = 0;
				insertFifRequestParam.clearParameters();
				insertFifRequestParam.setString(++j, fifRequest.getTransactionId());
				insertFifRequestParam.setString(++j, key);
				insertFifRequestParam.setString(++j, fifRequest.getParameters().get(key));
				insertFifRequestParam.executeUpdate();
			}

			// fif_request_param_list (or similar)
			if (fifRequest.getParameterLists() != null) {
				for (String key : fifRequest.getParameterLists().keySet()) {
					List<Map<String, String>> parameterList = fifRequest.getParameterLists().get(key);
					int listItemCounter = 0;
					for (Map<String, String> oneParameterList : parameterList) {
						listItemCounter++;
						for (String listItemKey : oneParameterList.keySet()) {
							int k = 0;
							insertFifRequestParamList.clearParameters();
							insertFifRequestParamList.setString(++k, fifRequest.getTransactionId());
							insertFifRequestParamList.setString(++k, key);
							insertFifRequestParamList.setString(++k, listItemKey);
							insertFifRequestParamList.setString(++k, oneParameterList.get(listItemKey));
							insertFifRequestParamList.setInt(++k, listItemCounter);
							insertFifRequestParamList.executeUpdate();
						}
					}
				}
			}
			logger.info("Inserted FifRequest, actionName = " + fifRequest.getActionName() + 
					", with ID " + fifRequest.getTransactionId() + ".");
		} catch (SQLException e) {
			throw new FIFException(e);
		}
	}

    /* (non-Javadoc)
     * @see net.arcor.fif.db.DataAccess#closeStatements()
     */
    public void closeStatements() {
    	try {
    		if (fetchFifRequestById != null)
        		fetchFifRequestById.close();
    		if (fetchFifRequestParam != null)
        		fetchFifRequestParam.close();
    		if (fetchFifRequestParamList != null)
        		fetchFifRequestParamList.close();
    		if (fetchPendingFifRequests != null)
    			fetchPendingFifRequests.close();
    		if (lockFifRequest != null)
    			lockFifRequest.close();
    		if (updateFifRequest != null)
    			updateFifRequest.close();
    		if (insertFifRequestResult != null)
    			insertFifRequestResult.close();
    		if (insertFifRequest != null)
    			insertFifRequest.close();
    		if (insertFifRequestParam != null)
    			insertFifRequestParam.close();
    		if (insertFifRequestParamList != null)
    			insertFifRequestParamList.close();
			if (conn != null)
				conn.close();
		} catch (SQLException e) {
			logger.fatal("Cannot close the statements.", e);
		}
    }

	public static boolean isEnableDependentTransactions() {
		return enableDependentTransactions;
	}

	public static void setEnableDependentTransactions(
			boolean enableDependentTransactions) {
		DatabaseFifRequestDataAccess.enableDependentTransactions = enableDependentTransactions;
	}

	public static boolean isEnableTransactionLists() {
		return enableTransactionLists;
	}

	public static void setEnableTransactionLists(boolean enableTransactionLists) {
		DatabaseFifRequestDataAccess.enableTransactionLists = enableTransactionLists;
	}

	public static int getMaxErrorLength() {
		return maxErrorLength;
	}

	public static void setMaxErrorLength(int maxErrorLength) {
		DatabaseFifRequestDataAccess.maxErrorLength = maxErrorLength;
	}

	public static boolean isEnableParameterLists() {
		return enableParameterLists;
	}

	public static void setEnableParameterLists(boolean enableParameterLists) {
		DatabaseFifRequestDataAccess.enableParameterLists = enableParameterLists;
	}

	public static boolean isEnableTransactionResults() {
		return enableTransactionResults;
	}

	public static void setEnableTransactionResults(boolean enableTransactionResults) {
		DatabaseFifRequestDataAccess.enableTransactionResults = enableTransactionResults;
	}

}
