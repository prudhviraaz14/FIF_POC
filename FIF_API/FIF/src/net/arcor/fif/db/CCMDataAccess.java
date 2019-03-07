/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/CCMDataAccess.java-arc   1.1   Jan 29 2013 11:09:48   schwarje  $
 *    $Revision:   1.1  $
 *    $Workfile:   CCMDataAccess.java  $
 *      $Author:   schwarje  $
 *        $Date:   Jan 29 2013 11:09:48  $
 *
 *  
 *  Copyright (C) Vodafone
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/CCMDataAccess.java-arc  $
 * 
 *    Rev 1.1   Jan 29 2013 11:09:48   schwarje
 * IT-32438: updates
 * 
 *    Rev 1.0   Jan 17 2013 15:30:28   schwarje
 * Initial revision.
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

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.common.FIFException;


public class CCMDataAccess extends DataAccess {

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement getProductCodeForServiceSubscription = null;

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement getCustomerNumberForServiceSubscription = null;
    
	/**
	 * Constructor using default db alias
	 * @throws FIFException
	 */
	public CCMDataAccess() throws FIFException {
		super("default");
		init();
	}
    
	/**
	 * Constructor using db alias from input
	 * @param dbAlias
	 * @throws FIFException
	 */
	public CCMDataAccess(String dbAlias) throws FIFException {
		super(dbAlias);
		init();
	}
    
	public CCMDataAccess(Connection conn) throws FIFException {
		super(conn);
		init();
	}

    /* (non-Javadoc)
     * @see net.arcor.fif.db.DataAccess#init()
     */
    public synchronized void init() throws FIFException {
    	if (initialized) return;
    	
    	try {    		
    		logger.info("Preparing database statements...");
    		
    		getProductCodeForServiceSubscription = conn.prepareStatement(ClientConfig.getSetting(
   					"DataReconciliationClient.CCMData.GetProductCodeForServiceSubscription"));
    		getCustomerNumberForServiceSubscription = conn.prepareStatement(ClientConfig.getSetting(
   					"DataReconciliationClient.CCMData.GetCustomerNumberForServiceSubscription"));

    	} catch (SQLException e) {
    		throw new FIFException(
    				"Error while initializing CCM data access.", e);
    	}
    	initialized = true;    	
    }


    /* (non-Javadoc)
     * @see net.arcor.fif.db.DataAccess#closeStatements()
     */
    public synchronized void closeStatements() {
    	try {    		
    		if (getProductCodeForServiceSubscription != null)
    			getProductCodeForServiceSubscription.close();
    		if (getCustomerNumberForServiceSubscription != null)
    			getCustomerNumberForServiceSubscription.close();
			if (conn != null)
				conn.close();
		} catch (SQLException e) {
			logger.fatal("Cannot close the statements.", e);
		}
    }

    public synchronized String getProductCodeForServiceSubscription (String serviceSubscriptionID) throws FIFException {
    	logger.info("Retrieving productCode for serviceSubscriptionID " + serviceSubscriptionID);
    	try {    	
    		getProductCodeForServiceSubscription.clearParameters();
    		getProductCodeForServiceSubscription.setString(1, serviceSubscriptionID);
    		getProductCodeForServiceSubscription.setString(2, serviceSubscriptionID);
    		ResultSet result = getProductCodeForServiceSubscription.executeQuery();

    		String productCode = null;
    		if (result.next())
    			productCode = result.getString(1);
    		result.close();
    		return productCode;
    	} catch (SQLException e) {
    		throw new FIFException("Error while retrieving productCode for serviceSubscriptionID "
    				+ serviceSubscriptionID, e); 
    	}
    }

    public synchronized String getCustomerNumberForServiceSubscription (String serviceSubscriptionID) throws FIFException {
    	logger.info("Retrieving customerNumber for serviceSubscriptionID " + serviceSubscriptionID);
    	try {    	
    		getCustomerNumberForServiceSubscription.clearParameters();
    		getCustomerNumberForServiceSubscription.setString(1, serviceSubscriptionID);
    		ResultSet result = getCustomerNumberForServiceSubscription.executeQuery();

    		String customerNumber = null;
    		if (result.next())
    			customerNumber = result.getString(1);
    		result.close();
    		return customerNumber;
    	} catch (SQLException e) {
    		throw new FIFException("Error while retrieving customerNumber for serviceSubscriptionID "
    				+ serviceSubscriptionID, e);
    	}
    }    
}
