/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/RequestReceiver.java-arc   1.5   Nov 29 2012 15:24:32   lejam  $
 *    $Revision:   1.5  $
 *    $Workfile:   RequestReceiver.java  $
 *      $Author:   lejam  $
 *        $Date:   Nov 29 2012 15:24:32  $
 *
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/RequestReceiver.java-arc  $
 * 
 *    Rev 1.5   Nov 29 2012 15:24:32   lejam
 * Added reprocess functionality to processFifRequest IT-k-32482
 * 
 *    Rev 1.4   Nov 23 2010 13:01:08   wlazlow
 * IT-k-29265
 * 
 *    Rev 1.3   Jun 18 2010 17:41:14   schwarje
 * changes for CPCOM Phase 2: new FIF client type accepting SOM orders
 * 
 *    Rev 1.2   May 25 2010 16:33:34   schwarje
 * IT-26029: updates
 * 
 * 
 ***************************************************************************  
 */
package net.arcor.fif.client;

import java.io.IOException;
import java.io.StringWriter;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import net.arcor.fif.common.DOMSerializer;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.db.DataAccess;
import net.arcor.fif.db.FifTransaction;
import net.arcor.fif.db.FifTransactionDataAccess;
import net.arcor.fif.messagecreator.FIFRequest;
import net.arcor.fif.messagecreator.FIFRequestList;
import net.arcor.fif.messagecreator.Request;
import net.arcor.fif.messagecreator.RequestSerializer;
import net.arcor.fif.messagecreator.SimpleParameter;

import org.apache.log4j.Logger;
import org.w3c.dom.Document;

public abstract class RequestReceiver implements Runnable {
	
	protected Logger logger = Logger.getLogger(getClass());

	protected ResponseSender responseSender = null;

	protected FifTransactionDataAccess fifTransactionDAO = null;
	
	public abstract void run();
	
	public RequestReceiver(ResponseSender responseSender) throws FIFException {
		this.responseSender = responseSender;
		fifTransactionDAO = new FifTransactionDataAccess(ClientConfig.getSetting("SynchronousFifClient.FifTransaction.DBAlias"));
	}
	
	/**
	 * @param request
	 * @return
	 */
	protected FifTransaction createFifTransaction(Request request, StringBuffer message) {
		FifTransaction fifTransaction = new FifTransaction();
		String id = null; 
		if (request instanceof FIFRequest)
			id = ((FIFRequest) request).getTransactionID();
		if (request instanceof FIFRequestList)
			id = ((FIFRequestList) request).getID();
		fifTransaction.setTransactionId(id);
		fifTransaction.setClientType(SynchronousFifClient.theClient.getClientType());
		fifTransaction.setClientId(SynchronousFifClient.theClient.getClientId());
		fifTransaction.setRecycleStage(0);
		fifTransaction.setClientRequest(message.toString());
		fifTransaction.setDueDate(new Timestamp(new Date().getTime()));
		fifTransaction.setEntryDate(new Timestamp(new Date().getTime()));
		fifTransaction.setStatus(SynchronousFifClient.FIF_TRANSACTION_STATUS_NEW);
		fifTransaction.setCustomerNumber(extractCustomerNumber(request));
				
		String jmsCorrelationId = null;
	    String jmsReplyTo = null;	
	
		if (request instanceof FIFRequest){
			if(((SimpleParameter)((FIFRequest) request).getParam("jmsCorrelationId")) != null)		
			   jmsCorrelationId =	((SimpleParameter)((FIFRequest) request).getParam("jmsCorrelationId")).getValue();		
			if(((SimpleParameter)((FIFRequest) request).getParam("jmsReplyTo")) != null)		
				jmsReplyTo =	((SimpleParameter)((FIFRequest) request).getParam("jmsReplyTo")).getValue();		
		}
		else if (request instanceof FIFRequestList){
			if(((SimpleParameter)((FIFRequestList) request).getParam("jmsCorrelationId")) != null)		
				   jmsCorrelationId =	((SimpleParameter)((FIFRequestList) request).getParam("jmsCorrelationId")).getValue();		
			if(((SimpleParameter)((FIFRequestList) request).getParam("jmsReplyTo")) != null)		
					jmsReplyTo =	((SimpleParameter)((FIFRequestList) request).getParam("jmsReplyTo")).getValue();						
		}
		fifTransaction.setJmsCorrelationId(jmsCorrelationId);
		fifTransaction.setJmsReplyTo(jmsReplyTo);
		return fifTransaction;
	}

	// tries to find the customer number in the request
	private static String extractCustomerNumber(Request request) {
		List<String> searchParameters = new ArrayList<String>();
		searchParameters.add("customerNumber");
		searchParameters.add("CUSTOMER_NUMBER");
		searchParameters.add("Kundennummer");
		searchParameters.add("sourceCustomerNumber");		
		String customerNumber = getParameterValue(request, searchParameters);
		
		return customerNumber;
	}

	// looks for a FIF parameter in a FIF request, which can be a single request or a request list
	private static String getParameterValue(Request request, List<String> searchParameters) {
		if (request instanceof FIFRequest)
			return ((FIFRequest) request).getParameterValue (searchParameters);
		else if (request instanceof FIFRequestList)
			return ((FIFRequestList) request).getParameterValue (searchParameters);
		else 
			return null;
	}

	/**
	 * @param request
	 * @param requestString
	 * @throws FIFException
	 */
	protected void processFifRequest(Request request) throws FIFException {
		StringBuffer sb = createInternalFifRequest(request);
		processFifRequest(request, sb);
	}
	

    public StringBuffer createInternalFifRequest(Request request) throws FIFException {
    	StringBuffer sb = new StringBuffer();
        Document doc = RequestSerializer.serialize(request);
        StringWriter sw = new StringWriter();
        try {
            DOMSerializer ds = new DOMSerializer();
            ds.serialize(doc, sw);
            sb.append(sw.toString());
        } catch (IOException e) {
            throw new FIFException(e);
        }
        return sb;
    }    

	/**
	 * @param request
	 * @return
	 */
	protected FifTransaction existingFifTransaction(Request request) throws FIFException {
		String id = null; 
		if (request instanceof FIFRequest)
			id = ((FIFRequest) request).getTransactionID();
		if (request instanceof FIFRequestList)
			id = ((FIFRequestList) request).getID();

		FifTransaction fifTransaction = fifTransactionDAO.retrieveFifTransactionById(id, SynchronousFifClient.theClient.getClientType());
		return fifTransaction;
	}
    
    /**
	 * @param request
	 * @param requestString
	 * @throws FIFException
	 */
	protected void processFifRequest(Request request, StringBuffer requestString) throws FIFException {
		FifTransaction fifTransaction = createFifTransaction(request, requestString);
		
		FifTransaction existingFifTransaction = existingFifTransaction(request);
		if (existingFifTransaction != null) {
			logger.info("FifRequest with transactionID " + existingFifTransaction.getTransactionId() + 
					" already exists. Status: " + existingFifTransaction.getStatus());

			boolean bReprocessInd = false;
			if (request instanceof FIFRequest){
				if(((SimpleParameter)((FIFRequest) request).getParam("reprocessInd")) != null)
					bReprocessInd = true;
			}
			if (request instanceof FIFRequestList){
				if(((SimpleParameter)((FIFRequestList) request).getParam("reprocessInd")) != null)
					bReprocessInd = true;
			}
			if(bReprocessInd) {		
				String status = existingFifTransaction.getStatus();
				if (status.equals(SynchronousFifClient.FIF_TRANSACTION_STATUS_COMPLETED_FIF) ||
						status.equals(SynchronousFifClient.FIF_TRANSACTION_STATUS_RESPONSE_SENT)) { 
					logger.info("Reprocessing FifTransaction " + existingFifTransaction.getTransactionId() + 
							". Status (existing transaction): " + existingFifTransaction.getStatus());
					fifTransactionDAO.deleteFifTransaction(existingFifTransaction);	
					fifTransactionDAO.insertFifTransaction(fifTransaction);
					fifTransactionDAO.commit();
				}
			}
			else {
				String status = existingFifTransaction.getStatus();
				if (status.equals(SynchronousFifClient.FIF_TRANSACTION_STATUS_COMPLETED_FIF) ||
						status.equals(SynchronousFifClient.FIF_TRANSACTION_STATUS_RESPONSE_SENT)) { 
					// if it is done, generate the response and send it back, and update the request
					// check, if the client name is the same, only send if it is the same
					resendResponse(existingFifTransaction);
					request.addParam(new SimpleParameter("resentResponse", "Y"));
				}
				else
					logger.info("FifRequest with transactionID " + existingFifTransaction.getTransactionId() + 
						" is still in progress.");
			}
		}
		else {
			fifTransactionDAO.insertFifTransaction(fifTransaction);
			fifTransactionDAO.commit();
		}
	}

	protected abstract void resendResponse(FifTransaction fifTransaction) throws FIFException;

	public DataAccess getFifTransactionDAO() {
		return fifTransactionDAO;
	}
	
}
