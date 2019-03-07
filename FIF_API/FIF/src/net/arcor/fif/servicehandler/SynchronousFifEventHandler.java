/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/SynchronousFifEventHandler.java-arc   1.5   Nov 22 2010 10:36:54   makuier  $
 *    $Revision:   1.5  $
 *    $Workfile:   SynchronousFifEventHandler.java  $
 *      $Author:   makuier  $
 *        $Date:   Nov 22 2010 10:36:54  $
 *
 *  Function: service handler for synchronous processing in FIF
 *  
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/SynchronousFifEventHandler.java-arc  $
 * 
 *    Rev 1.5   Nov 22 2010 10:36:54   makuier
 * Adapted to mcf2
 * 
 *    Rev 1.4   Sep 15 2008 09:32:56   schwarje
 * SPN-FIF-000076119: improved request logging for service bus client
 * 
 *    Rev 1.3   Jul 30 2008 16:27:34   schwarje
 * IT-k-23569: new FIF client for reading responses for service bus requests initiated from CCM
 * 
 *    Rev 1.2   May 05 2008 16:18:04   schwarje
 * SPN-FIF-000070336: improved logging for SynchonousServiceBusClient
 * 
 *    Rev 1.1   Feb 28 2008 19:28:14   schwarje
 * IT-20793: updated
 * 
 *    Rev 1.0   Feb 28 2008 15:16:46   schwarje
 * Initial revision.
 * 
 ***************************************************************************  
 */
package net.arcor.fif.servicehandler;

import java.util.Date;
import java.util.HashMap;

import javax.xml.bind.JAXBElement;

import net.arcor.epsm_basetypes_001.OutputData;
import net.arcor.epsm_basetypes_001.ProviderService;
import net.arcor.fif.client.ServiceBusRequest;
import net.arcor.fif.client.SynchronousServiceBusClientRequestHandler;
import net.arcor.fif.common.FIFException;
import net.arcor.mcf2.exception.base.MCFException;
import net.arcor.mcf2.model.ServiceObjectEndpoint;
import net.arcor.mcf2.model.ServiceResponse;



/**
 * The SynchronousFifServiceHandler handles service bus requests for
 * FIF synchronously, i.e. it waits for FifInterface to process the message 
 * and returns the result of the request to the service bus
 * @author schwarje
 *
 */
public class SynchronousFifEventHandler extends SynchronousFifHandler {
	
	public SynchronousFifEventHandler() throws MCFException {
		super();
	}
	
	public ServiceResponse<?> execute(final ServiceObjectEndpoint<?> serviceInput)
		throws MCFException{
		
		SynchronousServiceBusClientRequestHandler requestHandler = getRequestHandler();
	
		@SuppressWarnings("unchecked")
		ProviderService service = ((JAXBElement<ProviderService>)(serviceInput.getPayload())).getValue();
		
		OutputData output = getEventOutputObject(service);
		HashMap<String, String> header = new HashMap<String, String>();
		header.put("JMSCorrelationID", serviceInput.getCorrelationID());
		header.put("PTF_RequestName", serviceInput.getServiceName());
		ServiceBusRequest busRequest = createServiceBusRequest(output, header);
		busRequest.setRequestType(ServiceBusRequest.requestTypeEvent);
		busRequest.setStartDate(new Date(System.currentTimeMillis()));
		busRequest.getParameters().put("originalRequestResult", output.isResult() ? "true" : "false");
		if (output.getErrorCode() != null && !(output.getErrorCode().equals("")))
			busRequest.getParameters().put("originalRequestErrorCode", output.getErrorCode());
		if (output.getErrorText() != null && !(output.getErrorText().equals("")))
			busRequest.getParameters().put("originalRequestErrorText", output.getErrorText());
		
		try {
			// call the FIF client to process the message
			busRequest = requestHandler.processServiceBusRequest(busRequest);
		} catch (FIFException e) {
			Throwable attachedException = (e.getCause() != null) ? e.getCause() : e;
			logger.error(e.getMessage(), attachedException);
			return null;
		}
		
		// variables for the response
		boolean result = true;
		String errorCode = null;
		String errorText = null;
		
		// check if message will be recycled
		if (busRequest.getStatus().equals(ServiceBusRequest.requestStatusInRecycling)) {
			result = false;
			errorCode = busRequest.getErrorCode();
			errorText = "Request failed with FIF error message " + busRequest.getErrorText() + 
					". The message will be automatically resent after " + busRequest.getRecycleDelay() + 
					" seconds.";
		}
		else if (busRequest.getStatus().equals(ServiceBusRequest.requestStatusFailed)) { 
			result = false;
			errorCode = busRequest.getErrorCode();
			errorText = busRequest.getErrorText();
		}
		else if (!(busRequest.getStatus().equals(ServiceBusRequest.requestStatusCompleted)))
			throw new MCFException("Illegal status of service bus request.");
		
		String logMessage = "Finished processing of service bus request. Status: " + busRequest.getStatus();
		if (!result) 
			logMessage += ", error code: " + errorCode + ", error text: " + errorText;
		logger.info(logMessage);
	
		if (busRequest.getStatus().equals(ServiceBusRequest.requestStatusInRecycling))
			// TODO currently (1.26) recycling is done by raising a technical exception
			// will be changed some time in the future (hopefully)
			throw new MCFException("Message has to be processed again.");
	
		return null;
	}

}
