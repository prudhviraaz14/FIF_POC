package net.arcor.fif.servicehandler;

import java.util.Date;

import javax.xml.bind.JAXBElement;

import net.arcor.fif.client.ServiceBusRequest;
import net.arcor.fif.client.SynchronousServiceBusClientRequestHandler;
import net.arcor.fif.common.FIFException;
import net.arcor.mcf2.model.ServiceObjectEndpoint;
import net.arcor.mcf2.model.ServiceResponse;

import com.vodafone.mcf2.ws.exception.FunctionalException;
import com.vodafone.mcf2.ws.exception.FunctionalRuntimeException;
import com.vodafone.mcf2.ws.exception.TechnicalException;
import com.vodafone.mcf2.ws.exception.TechnicalRuntimeException;
import com.vodafone.mcf2.ws.model.impl.ServiceResponseSoap;
import com.vodafone.mcf2.ws.service.SoapEndpoint;
import com.vodafone.mcf2.ws.service.SoapOperation;

import net.arcor.fif.fif_createterminatewebticketcontract_001.CreateTerminateWebTicketContractRequest;
import net.arcor.fif.fif_createterminatewebticketcontract_001.CreateTerminateWebTicketContractResponse;

@SoapEndpoint(soapAction = "/FIF-001/CreateTerminateWebTicketContract", context = "de.vodafone.esb.service.sbus.fif.fif_001", schema = "classpath:FIF-001.xsd")
public class CreateTerminateWebTicketContractImpl extends SoapServiceImpl 
            implements SoapOperation<CreateTerminateWebTicketContractRequest, CreateTerminateWebTicketContractResponse> {

    public ServiceResponse<CreateTerminateWebTicketContractResponse> invoke(ServiceObjectEndpoint<CreateTerminateWebTicketContractRequest> serviceObject)
			throws FunctionalException, TechnicalException,FunctionalRuntimeException, TechnicalRuntimeException {

		SynchronousServiceBusClientRequestHandler requestHandler = getRequestHandler();
    	
    	String correlationID = serviceObject.getSbusCorrelationID();
    	if (correlationID == null || correlationID.equals(""))
    		correlationID = serviceObject.getCorrelationID();
    	String packageName = serviceObject.getJavaPackage();
    	
    	CreateTerminateWebTicketContractRequest request = new CreateTerminateWebTicketContractRequest();
    	Object payload = serviceObject.getPayload();
		if (payload instanceof JAXBElement)
			request = (CreateTerminateWebTicketContractRequest)((JAXBElement) payload).getValue();
		else
			request = serviceObject.getPayload();		
    	
    	CreateTerminateWebTicketContractResponse output = new CreateTerminateWebTicketContractResponse();
		ServiceBusRequest busRequest = createServiceBusRequest(request,correlationID,packageName,"CreateTerminateWebTicketContract");
		busRequest.setRequestType(ServiceBusRequest.requestTypeService);
		busRequest.setStartDate(new Date(System.currentTimeMillis()));
		
	
		try {
			// call the FIF client to process the message	
			busRequest = requestHandler.processServiceBusRequest(busRequest);
			
			if (busRequest.getStatus().equals(ServiceBusRequest.requestStatusCompleted))
				output.setResult(true);
			if (busRequest.getStatus().equals(ServiceBusRequest.requestStatusFailed)) {
				output.setResult(false);				
				output.setErrorCode(busRequest.getErrorCode());
				output.setErrorText(busRequest.getErrorText());				
				throw new FunctionalException(busRequest.getErrorCode(), busRequest.getErrorText());
			}			
		} catch (FIFException e) {
			Throwable attachedException = (e.getCause() != null) ? e.getCause() : e;
			logger.error(e.getMessage(), attachedException);
			throw new TechnicalException("FIF0031","Unknown exception raised: " + attachedException.getMessage());
		}
		return new ServiceResponseSoap<CreateTerminateWebTicketContractResponse>(output);
	}

}
