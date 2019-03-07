/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/FifTransactionDataAccess.java-arc   1.9   Oct 20 2011 08:04:24   schwarje  $
 *    $Revision:   1.9  $
 *    $Workfile:   FifTransactionDataAccess.java  $
 *      $Author:   schwarje  $
 *        $Date:   Oct 20 2011 08:04:24  $
 *
 *  
 *  Copyright (C) Vodafone
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/FifTransactionDataAccess.java-arc  $
 * 
 *    Rev 1.9   Oct 20 2011 08:04:24   schwarje
 * IT-28900: fixed initialization, if priority is not used
 * 
 *    Rev 1.8   Oct 18 2011 10:12:18   schwarje
 * IT-28900: support for prioritized requests
 * 
 *    Rev 1.7   May 26 2011 07:29:46   schwarje
 * fixed NullPointerException
 * 
 *    Rev 1.6   May 26 2011 07:12:24   schwarje
 * fixed compile error
 * 
 *    Rev 1.5   May 25 2011 08:25:58   schwarje
 * SPN-FIF-000112611: truncate customerNumber before writing to FIF_TRANSACTION, if it exceeds 12
 * 
 *    Rev 1.4   Nov 23 2010 13:04:12   wlazlow
 * IT-k-29265
 * 
 *    Rev 1.3   Jun 01 2010 18:03:30   schwarje
 * IT-26029: updates
 * 
 *    Rev 1.2   May 25 2010 16:26:24   schwarje
 * IT-26029: updates
 * 
 * 
 ***************************************************************************  
 */
package net.arcor.fif.db;

import java.sql.Clob;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;

import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.common.FIFException;


public class FifTransactionDataAccess extends DataAccess {

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement fetchRecTransById = null;

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement fetchPendingFifTransaction = null;

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement fetchPendingPriorityFifTransaction = null;

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement checkPriorityFifTransactions = null;
    
    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement fetchFailedResponses = null;

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement deleteFifTransaction = null;

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement updateFifTransaction = null;

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement insertFifTransaction = null;

   
	/**
	 * Constructor using default db alias
	 * @throws FIFException
	 */
	public FifTransactionDataAccess() throws FIFException {
		super("default");
		init();
	}
    
	/**
	 * Constructor using db alias from input
	 * @param dbAlias
	 * @throws FIFException
	 */
	public FifTransactionDataAccess(String dbAlias) throws FIFException {
		super(dbAlias);
		init();
	}
    
    /* (non-Javadoc)
     * @see net.arcor.fif.db.DataAccess#init()
     */
    public void init() throws FIFException {
    	if (initialized) return;
    	initialized = true;    	
    	
    	try {    		
    		logger.info("Preparing database statements...");
    		fetchRecTransById = conn.prepareStatement(ClientConfig.getSetting(
    				"SynchronousFifClient.FifTransaction.RetrieveFifTransactionsById"));
    		fetchPendingFifTransaction = conn.prepareStatement(ClientConfig.getSetting(
    				"SynchronousFifClient.FifTransaction.RetrievePendingFifTransactions"));
        	try {    		    		
        		fetchPendingPriorityFifTransaction = conn.prepareStatement(ClientConfig.getSetting(
        				"SynchronousFifClient.FifTransaction.RetrievePendingPriorityFifTransactions"));
        		checkPriorityFifTransactions = conn.prepareStatement(ClientConfig.getSetting(
    					"SynchronousFifClient.FifTransaction.CheckPriorityFifTransactions"));
            } catch (FIFException e) {}
    		fetchFailedResponses = conn.prepareStatement(ClientConfig.getSetting(
    				"SynchronousFifClient.FifTransaction.RetrieveFailedResponses"));
    		deleteFifTransaction = conn.prepareStatement(ClientConfig.getSetting(
    				"SynchronousFifClient.FifTransaction.DeleteFifTransaction"));
    		updateFifTransaction = conn.prepareStatement(ClientConfig.getSetting(
    				"SynchronousFifClient.FifTransaction.UpdateFifTransaction"));
    		insertFifTransaction = conn.prepareStatement(ClientConfig.getSetting(
    				"SynchronousFifClient.FifTransaction.InsertFifTransaction"));
    	} catch (SQLException e) {
    		throw new FIFException(
    				"Error while initializing Fif transaction data access.", e);
    	}
    }

    /**
     * method for inserting a fif transaction into the FIF_TRANSACTION table
     * @param fifTransaction
     * @throws FIFException
     */
    public synchronized void insertFifTransaction(FifTransaction fifTransaction) throws FIFException {
    	if (insertFifTransaction == null)
    		throw new FIFException("Logging of database access is not properly initialized");

        try {
        	if (fifTransaction.getCustomerNumber() != null &&
        		fifTransaction.getCustomerNumber().length() > 12) {
        		logger.warn("Truncating customerNumber (" + fifTransaction.getCustomerNumber() + 
        			") before inserting into database.");
        		fifTransaction.setCustomerNumber(fifTransaction.getCustomerNumber().substring(0, 12));
        	}
			int i = 1;
			insertFifTransaction.clearParameters();
			insertFifTransaction.setString(i++, fifTransaction.getTransactionId());
			insertFifTransaction.setString(i++, fifTransaction.getClientType());
			insertFifTransaction.setString(i++, fifTransaction.getClientId());			
			insertFifTransaction.setClob(i++, getClob(fifTransaction.getClientRequest()));
			insertFifTransaction.setClob(i++, getClob(fifTransaction.getClientResponse()));			
			insertFifTransaction.setTimestamp(i++, fifTransaction.getDueDate());
			insertFifTransaction.setTimestamp(i++, fifTransaction.getEntryDate());
			insertFifTransaction.setString(i++, fifTransaction.getStatus());
			insertFifTransaction.setInt(i++, fifTransaction.getRecycleStage());
			insertFifTransaction.setString(i++, fifTransaction.getCustomerNumber());
			insertFifTransaction.setString(i++, fifTransaction.getClientType());
			insertFifTransaction.setInt(i++, fifTransaction.getResponseRetryCount());
			insertFifTransaction.setString(i++, fifTransaction.getJmsCorrelationId());
			insertFifTransaction.setString(i++, fifTransaction.getJmsReplyTo());
			logger.info("Saving FifTransaction " + fifTransaction.getTransactionId() + 
					" to the database.");
			insertFifTransaction.executeUpdate();
        }
        catch (SQLException e) {
			if (e.getErrorCode() != 1) {
				try {
		 			conn.rollback();
		 		} catch (SQLException e1) {}   		 			
		 		throw new FIFException("Error while inserting into the Fif table: " + e.getMessage(), e);
		 	}
		}
    }

	/**
	 * method for updating a fif transaction in the FIF_TRANSACTION table
	 * @param fifTransaction
	 * @throws FIFException
	 */
	public synchronized void updateFifTransaction(FifTransaction fifTransaction) throws FIFException {
        if (updateFifTransaction == null)
        	throw new FIFException("Logging of database access is not properly initialized");
        
    	try {
        	if (fifTransaction.getCustomerNumber() != null &&
            	fifTransaction.getCustomerNumber().length() > 12) {
        		logger.warn("Truncating customerNumber (" + fifTransaction.getCustomerNumber() + 
        			") before inserting into database.");
        		fifTransaction.setCustomerNumber(fifTransaction.getCustomerNumber().substring(0, 12));
        	}
			int i = 1;
			updateFifTransaction.clearParameters();
			updateFifTransaction.setTimestamp(i++, fifTransaction.getDueDate());
			updateFifTransaction.setTimestamp(i++, fifTransaction.getEndDate());
			updateFifTransaction.setString(i++, fifTransaction.getStatus());
			updateFifTransaction.setInt(i++, fifTransaction.getRecycleStage());
			updateFifTransaction.setClob(i++, getClob(fifTransaction.getClientResponse()));
			updateFifTransaction.setString(i++, fifTransaction.getCustomerNumber());
			updateFifTransaction.setString(i++, fifTransaction.getClientType());
			updateFifTransaction.setInt(i++, fifTransaction.getResponseRetryCount());
			updateFifTransaction.setString(i++, fifTransaction.getJmsCorrelationId());
			updateFifTransaction.setString(i++, fifTransaction.getJmsReplyTo());	
			updateFifTransaction.setString(i++, fifTransaction.getTransactionId());
			updateFifTransaction.setString(i++, fifTransaction.getClientType());																	
			int updatedRows = updateFifTransaction.executeUpdate();
			
			if (updatedRows != 1) {
				try {
					conn.rollback();
				} catch (SQLException e1) {}				
				throw new FIFException(updatedRows + " rows were updated. Should have been only one.");
			}
			
			commit();
		} catch (SQLException e) {
			if (e.getErrorCode() != 1){
				try {
					conn.rollback();
				} catch (SQLException e1) {}
				throw new FIFException("Error while updating the Fif table: " + e.getMessage(), e);
			}
		}
    }
    /**
     * method for deleting a fif transaction from the FIF_TRANSACTION table
     * @param fifTransaction
     * @throws FIFException
     */
    public synchronized void deleteFifTransaction(FifTransaction fifTransaction) throws FIFException {
        if (deleteFifTransaction == null)
        	throw new FIFException("Logging of database access is not properly initialized");
        
    	try {
			int i = 1;
			deleteFifTransaction.clearParameters();
			deleteFifTransaction.setString(i++, fifTransaction.getTransactionId());
			deleteFifTransaction.setString(i++, fifTransaction.getClientType());
			logger.info("Deleting FifTransaction " + fifTransaction.getTransactionId() + 
					" from the database.");
			deleteFifTransaction.executeUpdate();
		} catch (SQLException e) {
			if (e.getErrorCode() != 1){
				try {
					conn.rollback();
				} catch (SQLException e1) {}
				throw new FIFException("Error while updating into the Fif table: " + e.getMessage(), e);
			}
		}
    }
    
    /**
     * method for retrieving a specific fif transaction from the FIF_TRANSACTION table
     * @param transactionId
     * @param clientType
     * @return one FifTransaction retrieved by the statement
     * @throws FIFException
     */
    public synchronized FifTransaction retrieveFifTransactionById(String transactionId, String clientType) throws FIFException {
        if (fetchRecTransById == null)
        	throw new FIFException("Logging of database access is not properly initialized");
        
    	try {
			fetchRecTransById.clearParameters();
			fetchRecTransById.setString(1, transactionId);
			fetchRecTransById.setString(2, clientType);
			if (logger.isDebugEnabled())
				logger.debug("Executing statement: " + 
						ClientConfig.getSetting("SynchronousFifClient.FifTransaction.RetrieveFifTransactionsById") + 
						", parameters: " + transactionId + 
						", " + clientType);
			ResultSet result = fetchRecTransById.executeQuery();
			ArrayList<FifTransaction> theList = extractQueryResult(result);
			if (theList == null || theList.size() == 0)
				return null;
			return theList.get(0);
		} catch (SQLException e) {
			throw new FIFException(e);
		}
    }

    /**
     * method for retrieving one batch of pending fif transaction from the FIF_TRANSACTION table
     * @param status
     * @param clientId
     * @param batchSize
     * @return list of FifTransactions
     * @throws FIFException
     */
    public synchronized ArrayList<FifTransaction> retrievePendingFifTransactions(String status,
    		String clientId, int batchSize, boolean enablePrioritizedRequests) throws FIFException {
        if (fetchPendingFifTransaction == null)
        	throw new FIFException("Logging of database access is not properly initialized");
        
    	try {
    		int numberOfPriorityRequests = 0;
    		// check for priority requests
    		if (enablePrioritizedRequests) {
        		int j = 1;
    			checkPriorityFifTransactions.clearParameters();
    			checkPriorityFifTransactions.setString(j++, status);
    			checkPriorityFifTransactions.setString(j++, clientId);    			
    			ResultSet checkResult = checkPriorityFifTransactions.executeQuery();
    			if (logger.isDebugEnabled())
    				logger.debug("Executing statement: " + 
    						ClientConfig.getSetting("SynchronousFifClient.FifTransaction.CheckPriorityFifTransactions") + 
    						", parameters: " + status + 
    						", " + clientId);
    			
    			if (checkResult.next()) {
    				numberOfPriorityRequests = checkResult.getInt(1);    				
    				if (numberOfPriorityRequests > 0)
    					logger.info("Found " + numberOfPriorityRequests + 
    							" prioritized requests, which are processed next.");
    			}
    			else
    				throw new FIFException ("Something wrong with the priority statement. " +
    						"Pls contact development.");
    		}
    		PreparedStatement statement = (numberOfPriorityRequests > 0) ? 
    				fetchPendingPriorityFifTransaction : fetchPendingFifTransaction;
    		
    		int i = 1;
    		statement.clearParameters();
    		statement.setString(i++, status);
    		statement.setString(i++, clientId);
    		statement.setInt(i++, batchSize);
			if (logger.isDebugEnabled())
				logger.debug("Executing statement: " + 
						ClientConfig.getSetting("SynchronousFifClient.FifTransaction.RetrievePendingFifTransactions") + 
						", parameters: " + status + 
						", " + clientId + 
						", " + batchSize);
			ResultSet result = statement.executeQuery();
			
			return extractQueryResult(result);
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
    public synchronized ArrayList<FifTransaction> retrieveFailedResponses(
    		String status, String clientId, int retries, int batchSize, Timestamp age) throws FIFException {
        if (fetchFailedResponses == null)
        	throw new FIFException("Logging of database access is not properly initialized");
        
    	try {
    		int i = 1;
    		fetchFailedResponses.clearParameters();
    		fetchFailedResponses.setString(i++, status);
    		fetchFailedResponses.setString(i++, clientId);
    		fetchFailedResponses.setTimestamp(i++, age);    		
    		fetchFailedResponses.setInt(i++, retries);
    		fetchFailedResponses.setInt(i++, batchSize);
			if (logger.isDebugEnabled())
				logger.debug("Executing statement: " + 
						ClientConfig.getSetting("SynchronousFifClient.FifTransaction.RetrieveFailedResponses") + 
						", parameters: " + status + 
						", " + clientId + 
						", " + age.toString() + 
						", " + retries + 
						", " + batchSize);
    		ResultSet result = fetchFailedResponses.executeQuery();
			
			return extractQueryResult(result);
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
    private synchronized ArrayList<FifTransaction> extractQueryResult(ResultSet result) throws SQLException {
    	ArrayList<FifTransaction> theList = null;
		boolean hasResult = result.next();
		if (hasResult) {
			theList = new ArrayList<FifTransaction>();
			do {
				FifTransaction fifTransaction = new FifTransaction();
				fifTransaction.setTransactionId(result.getString("TRANSACTION_ID"));
				fifTransaction.setClientType(result.getString("CLIENT_TYPE"));
				fifTransaction.setClientId(result.getString("CLIENT_ID"));
				fifTransaction.setDueDate(result.getTimestamp("DUE_DATE"));
				fifTransaction.setEntryDate(result.getTimestamp("ENTRY_DATE"));
				fifTransaction.setEndDate(result.getTimestamp("END_DATE"));				
				fifTransaction.setCustomerNumber(result.getString("CUSTOMER_NUMBER"));
				fifTransaction.setStatus(result.getString("STATUS"));
				fifTransaction.setRecycleStage(result.getInt("RECYCLE_STAGE"));
				fifTransaction.setResponseRetryCount(result.getInt("RESPONSE_RETRY_COUNT"));				
				Clob clientRequest = result.getClob("CLIENT_REQUEST");
				if (clientRequest != null)
					fifTransaction.setClientRequest(
							clientRequest.getSubString(1, (int) result.getClob("CLIENT_REQUEST").length()));				
				Clob clientResponse = result.getClob("CLIENT_RESPONSE");
				if (clientResponse != null)
					fifTransaction.setClientResponse(
							clientResponse.getSubString(1, (int) result.getClob("CLIENT_RESPONSE").length()));
				fifTransaction.setJmsCorrelationId(result.getString("JMS_CORRELATION_ID"));
				fifTransaction.setJmsReplyTo(result.getString("JMS_REPLY_TO"));
				
				theList.add(fifTransaction);
			} while ((result.next()));
		}
		return theList;
	}
    
    /* (non-Javadoc)
     * @see net.arcor.fif.db.DataAccess#closeStatements()
     */
    public void closeStatements() {
    	try {
    		fetchRecTransById.close();
			fetchPendingFifTransaction.close();
			if (checkPriorityFifTransactions != null)
				checkPriorityFifTransactions.close();
			if (fetchPendingPriorityFifTransaction != null)
				fetchPendingPriorityFifTransaction.close();
			fetchFailedResponses.close();
			deleteFifTransaction.close();
			updateFifTransaction.close();
			insertFifTransaction.close();
			if (conn != null)
				conn.close();
		} catch (SQLException e) {
			logger.fatal("Cannot close the statements.", e);
		}
    }

}
