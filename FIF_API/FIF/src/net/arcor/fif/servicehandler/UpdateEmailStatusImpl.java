package net.arcor.fif.servicehandler;

import java.util.Date;

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

import de.vodafone.esb.service.sbus.fif.fif_001.UpdateEmailStatusRequest;
import de.vodafone.esb.service.sbus.fif.fif_001.UpdateEmailStatusResponse;

@SoapEndpoint(soapAction = "/FIF-001/UpdateEmailStatus", context = "de.vodafone.esb.service.sbus.fif.fif_001", schema = "classpath:FIF-001.xsd")
public class UpdateEmailStatusImpl extends SoapServiceImpl 
            implements SoapOperation<UpdateEmailStatusRequest, UpdateEmailStatusResponse> {

    public ServiceResponse<UpdateEmailStatusResponse> invoke(ServiceObjectEndpoint<UpdateEmailStatusRequest> serviceObject)
			throws FunctionalException, TechnicalException,FunctionalRuntimeException, TechnicalRuntimeException {

		SynchronousServiceBusClientRequestHandler requestHandler = getRequestHandler();
    	
    	String correlationID = serviceObject.getSbusCorrelationID();
    	if (correlationID == null || correlationID.equals(""))
    		correlationID = serviceObject.getCorrelationID();
    	String packageName = serviceObject.getJavaPackage();
    	UpdateEmailStatusRequest request = serviceObject.getPayload();
    	
    	UpdateEmailStatusResponse output = new UpdateEmailStatusResponse();
		ServiceBusRequest busRequest = createServiceBusRequest(request,correlationID,packageName,"UpdateEmailStatus");
		busRequest.setRequestType(ServiceBusRequest.requestTypeService);
		busRequest.setStartDate(new Date(System.currentTimeMillis()));
		
	
		try {
			// call the FIF client to process the message	
			busRequest = requestHandler.processServiceBusRequest(busRequest);
			
			output.setValidationId(request.getValidationId());
			output.setCallingSystem(request.getCallingSystem());
			output.setEmail(request.getEmail());
			
			if (busRequest.getStatus().equals(ServiceBusRequest.requestStatusCompleted))
				output.setStatus("0");
			if (busRequest.getStatus().equals(ServiceBusRequest.requestStatusFailed)) {
				output.setStatus("1");				
				output.setErrorCode(busRequest.getErrorCode());
				output.setErrorMessage(busRequest.getErrorText());				
				throw new FunctionalException(busRequest.getErrorCode(), busRequest.getErrorText());
			}			
		} catch (FIFException e) {
			Throwable attachedException = (e.getCause() != null) ? e.getCause() : e;
			logger.error(e.getMessage(), attachedException);
			throw new TechnicalException("FIF0031","Unknown exception raised: " + attachedException.getMessage());
		}
		return new ServiceResponseSoap<UpdateEmailStatusResponse>(output);
	}

}
