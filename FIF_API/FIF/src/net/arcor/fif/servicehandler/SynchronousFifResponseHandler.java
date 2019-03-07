/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/SynchronousFifResponseHandler.java-arc   1.2   Nov 22 2010 10:36:54   makuier  $
 *    $Revision:   1.2  $
 *    $Workfile:   SynchronousFifResponseHandler.java  $
 *      $Author:   makuier  $
 *        $Date:   Nov 22 2010 10:36:54  $
 *
 *  Function: service handler for synchronous processing in FIF
 *  
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/SynchronousFifResponseHandler.java-arc  $
 * 
 *    Rev 1.2   Nov 22 2010 10:36:54   makuier
 * Adapted to mcf2
 * 
 *    Rev 1.1   Sep 15 2008 09:32:58   schwarje
 * SPN-FIF-000076119: improved request logging for service bus client
 * 
 *    Rev 1.0   Jul 30 2008 16:27:52   schwarje
 * Initial revision.
 * 
 ***************************************************************************  
 */
package net.arcor.fif.servicehandler;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

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
public class SynchronousFifResponseHandler extends SynchronousFifHandler {
	
	public SynchronousFifResponseHandler() throws MCFException {
		super();
	}
	public ServiceResponse<?> execute(final ServiceObjectEndpoint<?> serviceInput)
		throws MCFException {
		
		SynchronousServiceBusClientRequestHandler requestHandler = getRequestHandler();
	
		@SuppressWarnings("unchecked")
		ProviderService service = ((JAXBElement<ProviderService>)(serviceInput.getPayload())).getValue();
		
		OutputData output = getServiceOutputObject(service);		
		HashMap<String, String> header = new HashMap<String, String>();
		header.put("JMSCorrelationID", serviceInput.getCorrelationID());
		header.put("PTF_RequestName", serviceInput.getServiceName());
		ServiceBusRequest busRequest = createServiceBusRequest(output, header);		
		busRequest.setRequestType(ServiceBusRequest.requestTypeResponse);
		busRequest.setStartDate(new Date(System.currentTimeMillis()));
		busRequest.getParameters().put("originalRequestResult", output.isResult() ? "true" : "false");
		if (output.getErrorCode() != null && !(output.getErrorCode().equals("")))
			busRequest.getParameters().put("originalRequestErrorCode", output.getErrorCode());
		if (output.getErrorText() != null && !(output.getErrorText().equals("")))
			busRequest.getParameters().put("originalRequestErrorText", output.getErrorText());

		try {
			// call the FIF client to process the message
			busRequest = requestHandler.processServiceBusReply(busRequest);
		} catch (FIFException e) {
			Throwable attachedException = (e.getCause() != null) ? e.getCause() : e;
			logger.error(e.getMessage(), attachedException);
		}
		
		return null;
	}

}
