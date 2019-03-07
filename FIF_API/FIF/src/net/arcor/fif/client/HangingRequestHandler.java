/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/HangingRequestHandler.java-arc   1.0   Jun 01 2010 17:59:46   schwarje  $
 *    $Revision:   1.0  $
 *    $Workfile:   HangingRequestHandler.java  $
 *      $Author:   schwarje  $
 *        $Date:   Jun 01 2010 17:59:46  $
 *
 *  
 *  Copyright (C) Vodafone
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/HangingRequestHandler.java-arc  $
 * 
 *    Rev 1.0   Jun 01 2010 17:59:46   schwarje
 * Initial revision.
 * 
 * 
 ***************************************************************************  
 */
package net.arcor.fif.client;

import java.sql.Timestamp;
import java.util.Date;
import java.util.List;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.db.FifTransaction;
import net.arcor.fif.db.FifTransactionDataAccess;

import org.apache.log4j.Logger;

public class HangingRequestHandler {

	/**
	 * DAO for reading and writing FifTransactions to the database
	 */
	private FifTransactionDataAccess fifTransactionDAO = null;

	/**
	 * the log4j logger for this class
	 */
	private Logger logger = Logger.getLogger(this.getClass());

	private int batchSize = 100;

	private int requestAge = 1440;
	
	public HangingRequestHandler() throws FIFException {
		fifTransactionDAO = new FifTransactionDataAccess(
				ClientConfig.getSetting("SynchronousFifClient.FifTransaction.DBAlias"));
		
		try {
			batchSize = Integer.parseInt(ClientConfig.getSetting("SynchronousFifClient.HangingRequestHandling.BatchSize"));
		} catch (FIFException e) {}
		
		try {
			requestAge = Integer.parseInt(ClientConfig.getSetting("SynchronousFifClient.HangingRequestHandling.RequestAge"));
		} catch (FIFException e) {}		
		
		
		logger.info("Initializing handling of hanging requests with following parameters:" +
				", Batch size: " + batchSize + 
				", Request Age: " + requestAge + " minutes");
	}
	
	public void execute() throws FIFException {		
		while (true) {
			List<FifTransaction> hangingRequests = fifTransactionDAO.retrieveFailedResponses(
					SynchronousFifClient.FIF_TRANSACTION_STATUS_IN_PROGRESS_FIF, 
					SynchronousFifClient.theClient.getClientId(), 
					1, 
					batchSize,
					new Timestamp(new Date().getTime() - requestAge * 60000));
			
			if (hangingRequests != null) {
				logger.info("Retrieved " + hangingRequests.size() + 
						" hanging FifTransactions. Resetting them.");	
				for (FifTransaction fifTransaction : hangingRequests) {
					fifTransaction.setStatus(SynchronousFifClient.FIF_TRANSACTION_STATUS_NEW);
					fifTransactionDAO.updateFifTransaction(fifTransaction);
				}
				if (hangingRequests.size() < batchSize)
					break;
			}
			else break;
		}
	}

}
