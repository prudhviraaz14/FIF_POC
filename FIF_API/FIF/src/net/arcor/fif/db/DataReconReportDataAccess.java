/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/DataReconReportDataAccess.java-arc   1.3   Jun 07 2017 14:32:24   naveen.k  $
 *    $Revision:   1.3  $
 *    $Workfile:   DataReconReportDataAccess.java  $
 *      $Author:   naveen.k  $
 *        $Date:   Jun 07 2017 14:32:24  $
 *
 *  
 *  Copyright (C) Vodafone
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/DataReconReportDataAccess.java-arc  $
 * 
 *    Rev 1.3   Jun 07 2017 14:32:24   naveen.k
 * PPM 197512 RMS 161608,Project TKG
 * 
 *    Rev 1.2   Jan 29 2013 11:09:46   schwarje
 * IT-32438: updates
 * 
 *    Rev 1.1   Jan 18 2013 07:48:58   schwarje
 * IT-32438: added relatedObject
 * 
 *    Rev 1.0   Jan 17 2013 15:29:40   schwarje
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
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Date;

import net.arcor.ccm.epsm_ccm_consolidatesubscriptiondata_001.ActionItem;
import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.common.FIFException;


public class DataReconReportDataAccess extends DataAccess {

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement insertDataReconReport = null;

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement insertDataReconReportAction = null;
      
    private PreparedStatement getReportIDStmt = null;
    
	/**
	 * Constructor using default db alias
	 * @throws FIFException
	 */
	public DataReconReportDataAccess() throws FIFException {
		super("default");
		init();
	}
    
	/**
	 * Constructor using db alias from input
	 * @param dbAlias
	 * @throws FIFException
	 */
	public DataReconReportDataAccess(String dbAlias) throws FIFException {
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
    		
    		insertDataReconReport = conn.prepareStatement(ClientConfig.getSetting(
   					"DataReconciliationClient.DataReconReport.InsertDataReconReport"));
    		insertDataReconReportAction = conn.prepareStatement(ClientConfig.getSetting(
   					"DataReconciliationClient.DataReconReportAction.InsertDataReconReportAction"));
			getReportIDStmt = conn.prepareStatement(ClientConfig.getSetting(
					"DataReconciliationClient.GetReportID.Statement"));

    	} catch (SQLException e) {
    		throw new FIFException(
    				"Error while initializing Fif request data access.", e);
    	}
    	initialized = true;    	
    }


    /* (non-Javadoc)
     * @see net.arcor.fif.db.DataAccess#closeStatements()
     */
    public synchronized void closeStatements() {
    	try {    		
    		if (getReportIDStmt != null)
    			getReportIDStmt.close();
    		if (insertDataReconReport != null)
    			insertDataReconReport.close();
    		if (insertDataReconReportAction != null)
    			insertDataReconReportAction.close();
			if (conn != null)
				conn.close();
		} catch (SQLException e) {
			logger.fatal("Cannot close the statements.", e);
		}
    }

    public synchronized void insertDataReconReport (DataReconReport dataReconReport) throws FIFException {
    	
    	try {    	
        	insertDataReconReport.clearParameters();
        	int i = 1;
        	logger.info("Inserting entry into data_recon_report with report_id = " + dataReconReport.getReportID());
        	insertDataReconReport.setString(i++, dataReconReport.getReportID());
        	insertDataReconReport.setString(i++, dataReconReport.getCustomerNumber());
        	insertDataReconReport.setString(i++, dataReconReport.getBundleID());
        	insertDataReconReport.setString(i++, dataReconReport.getOrderID());
        	insertDataReconReport.setInt(i++, dataReconReport.getOrderPositionNumber());
        	insertDataReconReport.setTimestamp(i++, new Timestamp(dataReconReport.getReportTime().getTime()));
        	insertDataReconReport.setString(i++, dataReconReport.isBksResult() ? "Y" : "N");
        	insertDataReconReport.setString(i++, dataReconReport.getBksErrorCode());
        	insertDataReconReport.setString(i++, dataReconReport.getBksErrorText());
        	insertDataReconReport.setString(i++, dataReconReport.isValidatedCCM() ? "Y" : "N");
        	insertDataReconReport.setString(i++, dataReconReport.isValidatedAIDA() ? "Y" : "N");
        	insertDataReconReport.setString(i++, dataReconReport.isValidatedZAR() ? "Y" : "N");
        	insertDataReconReport.setString(i++, dataReconReport.isValidatedCramer() ? "Y" : "N");
        	insertDataReconReport.setString(i++, dataReconReport.isProcessedCCM() ? "Y" : "N");
        	insertDataReconReport.setString(i++, dataReconReport.isProcessedAIDA() ? "Y" : "N");
        	insertDataReconReport.setString(i++, dataReconReport.isProcessedZAR() ? "Y" : "N");
        	insertDataReconReport.setString(i++, dataReconReport.isProcessedCramer() ? "Y" : "N");
        	insertDataReconReport.setString(i++, dataReconReport.isProcessedSLS() ? "Y" : "N"); 
        	insertDataReconReport.setString(i++, dataReconReport.getSbusCorrelationID()); 
        	insertDataReconReport.setTimestamp(i++, new Timestamp(new Date().getTime())); // AUDIT_UPDATE_DATE_TIME
        	insertDataReconReport.setString(i++, "FIF"); // AUDIT_UPDATE_USER_ID
        	insertDataReconReport.setString(i++, dataReconReport.isValidatedInfPort() ? "Y" : "N");
        	insertDataReconReport.setString(i++, dataReconReport.isProcessedInfPort() ? "Y" : "N");
        	
        	insertDataReconReport.executeUpdate();
        	
    		int itemCounter = 0;
    		if (dataReconReport.getActionItems() != null) {
	        	for (ActionItem item : dataReconReport.getActionItems()) {
	        		int j = 1;
	        		insertDataReconReportAction.clearParameters();
	            	insertDataReconReportAction.setString(j++, dataReconReport.getReportID());
	            	String itemID = (new Integer(++itemCounter)).toString();
	            	if (itemID.length() < 2) 
	            		itemID = "0" + itemID;
	            	insertDataReconReportAction.setString(j++, itemID);            	
	            	insertDataReconReportAction.setString(j++, item.getScenarioType());
	            	insertDataReconReportAction.setString(j++, item.getActionType());
	            	insertDataReconReportAction.setString(j++, item.getValidatingSystem()); // CLEARING_SYSTEM
	            	insertDataReconReportAction.setString(j++, item.getErrorCode());
	            	insertDataReconReportAction.setString(j++, item.getErrorMessage());
	            	insertDataReconReportAction.setString(j++, item.getCcmValue());
	            	insertDataReconReportAction.setString(j++, item.getAidaValue());
	            	insertDataReconReportAction.setString(j++, item.getZarValue());
	            	insertDataReconReportAction.setString(j++, item.getCramerValue());
	            	insertDataReconReportAction.setString(j++, item.getLeadingSystem());
	            	insertDataReconReportAction.setString(j++, item.getServiceSubscriptionId());
	            	insertDataReconReportAction.setString(j++, item.getServiceCharCode());
	            	insertDataReconReportAction.setString(j++, item.getServiceCharDescription());            	
	            	insertDataReconReportAction.setString(j++, item.getDataType());
	            	insertDataReconReportAction.setString(j++, item.getTargetValue());
	            	insertDataReconReportAction.setString(j++, item.getRelatedObjectId());
	            	insertDataReconReportAction.setString(j++, item.getRelatedObjectType());
	            	insertDataReconReportAction.setTimestamp(j++, new Timestamp(new Date().getTime())); // AUDIT_UPDATE_DATE_TIME
	            	insertDataReconReportAction.setString(j++, "FIF"); // AUDIT_UPDATE_USER_ID 
	            	insertDataReconReportAction.setString(j++, item.getInfportValue());
	        		logger.debug("Inserting item into data_recon_report_action with report_id = " + dataReconReport.getReportID() + " and item number " + itemCounter);
	            	insertDataReconReportAction.executeUpdate();
	        	}
    		}
    	} catch (SQLException e) {
    		throw new FIFException("Error while initializing Fif request data access.", e);
    	}
    }
    

	/**
	 * @throws SQLException
	 */
	public synchronized String generateReportID() throws SQLException {
		String id = null; 
		ResultSet result = getReportIDStmt.executeQuery();		
		if (result.next())
			id = result.getString(1);
		result.close();
		return id;
	}

}
