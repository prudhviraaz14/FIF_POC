/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/FailedResponseHandler.java-arc   1.1   Oct 13 2010 19:21:56   schwarje  $
 *    $Revision:   1.1  $
 *    $Workfile:   FailedResponseHandler.java  $
 *      $Author:   schwarje  $
 *        $Date:   Oct 13 2010 19:21:56  $
 *
 *  Function: response handler for sending responses which previously couldn't be sent
 *  
 *  Copyright (C) Vodafone
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/FailedResponseHandler.java-arc  $
 * 
 *    Rev 1.1   Oct 13 2010 19:21:56   schwarje
 * SPN-FIF-000105218: count retries for failed responses
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

public class FailedResponseHandler implements Runnable {

	private ResponseSender responseSender = null;
	
	/**
	 * DAO for reading and writing FifTransactions to the database
	 */
	private FifTransactionDataAccess fifTransactionDAO = null;

	/**
	 * the log4j logger for this class
	 */
	private Logger logger = Logger.getLogger(this.getClass());

	private int maxRetries = 5;

	private int batchSize = 100;

	private int resendDelay = 360;
	
	private int sleepTime = 60;
	
	public FailedResponseHandler(ResponseSender responseSender) throws FIFException {
		this.responseSender = responseSender;
		fifTransactionDAO = new FifTransactionDataAccess(
				ClientConfig.getSetting("SynchronousFifClient.FifTransaction.DBAlias"));
		
		try {
			maxRetries = Integer.parseInt(ClientConfig.getSetting("SynchronousFifClient.FailedResponseHandling.MaxRetries"));
		} catch (FIFException e) {}
		
		try {
			batchSize = Integer.parseInt(ClientConfig.getSetting("SynchronousFifClient.FailedResponseHandling.BatchSize"));
		} catch (FIFException e) {}
		
		try {
			sleepTime = Integer.parseInt(ClientConfig.getSetting("SynchronousFifClient.FailedResponseHandling.SleepTime"));
		} catch (FIFException e) {}		
		
		try {
			resendDelay = Integer.parseInt(ClientConfig.getSetting("SynchronousFifClient.FailedResponseHandling.ResendDelay"));
		} catch (FIFException e) {}		
		
		
		logger.info("Initializing handling of previously failed responses with following parameters:" +
				" Maximum number of retries: " + maxRetries + 
				", Batch size: " + batchSize + 
				", Sleep Time: " + sleepTime + " minutes" + 
				", Resend Delay: " + resendDelay + " minutes");
	}
	
	public void run() {		
		try {
			while (!Thread.interrupted()) {
				List<FifTransaction> failedResponses = fifTransactionDAO.retrieveFailedResponses(
						SynchronousFifClient.FIF_TRANSACTION_STATUS_COMPLETED_FIF, 
						SynchronousFifClient.theClient.getClientId(), 
						maxRetries, 
						batchSize,
						new Timestamp(new Date().getTime() - resendDelay * 60000));
				
				boolean isError = false;
				
				if (failedResponses != null) {
					logger.info("Retrieved " + failedResponses.size() + 
							" FifTransactions with unsent responses. Resending responses now.");	
					for (FifTransaction fifTransaction : failedResponses) {
						try {
							if (fifTransaction.getClientResponse() == null) {
								fifTransaction.setStatus(SynchronousFifClient.FIF_TRANSACTION_STATUS_RESPONSE_FAILED);
								logger.info("Response for transaction " + fifTransaction.getTransactionId() + 
										" is empty. Cannot resend response.");
							}
							else {
								try {
									responseSender.sendResponse(fifTransaction);
									fifTransaction.setStatus(SynchronousFifClient.FIF_TRANSACTION_STATUS_LATE_RESPONSE);
								} catch (FIFException e) {
									logger.error("Error while resending response for transaction " + 
											fifTransaction.getTransactionId() + " to the frontend", e);
									fifTransaction.setResponseRetryCount(fifTransaction.getResponseRetryCount() + 1);
									if (fifTransaction.getResponseRetryCount() >= maxRetries) {
										logger.info("Exceeding maximum number of retries (" + maxRetries + 
												") for resending responses. No longer trying for request " + 
												fifTransaction.getTransactionId());
										fifTransaction.setStatus(SynchronousFifClient.FIF_TRANSACTION_STATUS_RESPONSE_FAILED);
									}
								}													
							}
							fifTransactionDAO.updateFifTransaction(fifTransaction);
						} catch (FIFException e) {
							logger.error("Error while resending response for transaction " + 
									fifTransaction.getTransactionId() + " to the frontend", e);
							isError = true;
						}
					}
				}
				if (failedResponses == null || failedResponses.size() < batchSize || isError)
					Thread.sleep(sleepTime * 60000);
			}
		} catch (FIFException e) {
			logger.error("Error while retrieving FifTransactions for resending responses.", e);
		} catch (InterruptedException e) {
			logger.error(e);
		}
	}



}
