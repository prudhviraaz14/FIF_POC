/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/ResponseSender.java-arc   1.2   May 25 2010 16:33:34   schwarje  $
 *    $Revision:   1.2  $
 *    $Workfile:   ResponseSender.java  $
 *      $Author:   schwarje  $
 *        $Date:   May 25 2010 16:33:34  $
 *
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/ResponseSender.java-arc  $
 * 
 *    Rev 1.2   May 25 2010 16:33:34   schwarje
 * IT-26029: updates
 * 
 * 
 ***************************************************************************  
 */
package net.arcor.fif.client;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.db.FifTransaction;
import net.arcor.fif.messagecreator.Message;

import org.apache.log4j.Logger;

public abstract class ResponseSender {

	/**
	 * The log4j logger.
	 */
	protected Logger logger = Logger.getLogger(getClass());
	
	/**
	 * DAO for reading and writing FifTransactions to the database
	 */
	// protected FifTransactionDataAccess fifTransactionDAO = null;

	public abstract void sendResponse(FifTransaction fifTransaction) throws FIFException;

	public abstract void sendResponse(Message message) throws FIFException;
	
	// committing input (IN_PROGRESS etc) (depending on type)
	
	// changing to XML format (only non-queue client)
	
	// writing to request table for requestHandler (same for all)
	
	// populating customer number (same for all)	
	
}
