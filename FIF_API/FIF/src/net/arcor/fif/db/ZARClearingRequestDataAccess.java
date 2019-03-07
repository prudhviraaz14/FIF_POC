/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/ZARClearingRequestDataAccess.java-arc   1.1   Jan 29 2013 11:09:46   schwarje  $
 *    $Revision:   1.1  $
 *    $Workfile:   ZARClearingRequestDataAccess.java  $
 *      $Author:   schwarje  $
 *        $Date:   Jan 29 2013 11:09:46  $
 *
 *  
 *  Copyright (C) Vodafone
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/ZARClearingRequestDataAccess.java-arc  $
 * 
 *    Rev 1.1   Jan 29 2013 11:09:46   schwarje
 * IT-32438: updates
 * 
 *    Rev 1.0   Jan 22 2013 07:50:32   schwarje
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

import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;

import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.common.FIFException;


public class ZARClearingRequestDataAccess extends DataAccess {

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement insertZARClearingRequest = null;
    
    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement alterSession = null;
    
	/**
	 * Constructor using default db alias
	 * @throws FIFException
	 */
	public ZARClearingRequestDataAccess() throws FIFException {
		super("default");
		init();
	}
    
	/**
	 * Constructor using db alias from input
	 * @param dbAlias
	 * @throws FIFException
	 */
	public ZARClearingRequestDataAccess(String dbAlias) throws FIFException {
		super(dbAlias);
		init();
	}

    /* (non-Javadoc)
     * @see net.arcor.fif.db.DataAccess#init()
     */
    public synchronized void init() throws FIFException {
    	if (initialized) return;
    	
    	try {    		
    		logger.info("Preparing database statements...");
    		
    		insertZARClearingRequest = conn.prepareStatement(ClientConfig.getSetting(
   					"DataReconciliationClient.ZARClearingRequest.InsertZARClearingRequest"));
        	alterSession = conn.prepareStatement(ClientConfig.getSetting(
    			"DataReconciliationClient.ZARClearingRequest.AlterSession"));

        	// alter session
        	alterSession.execute();

    	} catch (SQLException e) {
    		throw new FIFException(
    				"Error while initializing ZARClearingRequest data access.", e);
    	}
    	    	
    	initialized = true;    	
    }


    /* (non-Javadoc)
     * @see net.arcor.fif.db.DataAccess#closeStatements()
     */
    public synchronized void closeStatements() {
    	try {    		
    		if (insertZARClearingRequest != null)
    			insertZARClearingRequest.close();
    		if (alterSession != null)
    			alterSession.close();
			if (conn != null)
				conn.close();
		} catch (SQLException e) {
			logger.fatal("Cannot close the statements.", e);
		}
    }

	public void insertRequests(List<ZARClearingRequest> zarClearingList) throws FIFException {		
		for (ZARClearingRequest zarClearingRequest : zarClearingList) {
			insertRequest(zarClearingRequest);
		}
	}

	private void insertRequest(ZARClearingRequest zarClearingRequest) throws FIFException {
		logger.info("Inserting ZARClearingRequest " + zarClearingRequest.getClearingID() + 
				" with scenarioType " + zarClearingRequest.getCcmScenario());		
    	try {    	
    		int i = 0;
    		insertZARClearingRequest.clearParameters();
    		insertZARClearingRequest.setString(++i, zarClearingRequest.getClearingID());
    		insertZARClearingRequest.setString(++i, zarClearingRequest.getServiceSubscriptionID());
    		insertZARClearingRequest.setString(++i, zarClearingRequest.getCustomerNumberCCM());
    		insertZARClearingRequest.setString(++i, zarClearingRequest.getCustomerNumberZAR());
    		insertZARClearingRequest.setString(++i, zarClearingRequest.getLocalAreaCode());
    		insertZARClearingRequest.setString(++i, zarClearingRequest.getBeginNumber());
    		insertZARClearingRequest.setString(++i, zarClearingRequest.getEndNumber());
    		insertZARClearingRequest.setString(++i, zarClearingRequest.getCcmScenario());
    		insertZARClearingRequest.setString(++i, zarClearingRequest.getProductCode());
    		insertZARClearingRequest.executeUpdate();
			// required data:
			// - COL_CLEARING_ID (varchar50) - unique identifier
			// - COL_CCM_SS_ID (varchar50) - serviceSubscriptionID
			// - COL_RUF_KUNDENUMMER_CCM - customerNumber CCM
			// - COL_RUF_KUNDENUMMER_ZAR - customerNumber ZAR
			// - COL_ONB_VORWAHL - Vorwahl mit 0
			// - COL_RUF_START - Startnummer
			// - COL_RUF_END - Endnummer (bzw. wieder Startnummer)
			// - COL_CCM_SCENARIO - scenarioType as number 
			// - COL_PRODUCT_CODE - PSM productCode für Rufnummer
			// - COL_INSERT_DATE (DATE) := sysdate
			// - COL_LAST_UPDATE (DATE) := sysdate
			// - COL_LAST_SYSTEM (varchar3) := FIF

    	} catch (SQLException e) {
    		throw new FIFException("Error while inserting ZARClearingRequest " + zarClearingRequest.getClearingID(), e);
    	}		
	}    
}
