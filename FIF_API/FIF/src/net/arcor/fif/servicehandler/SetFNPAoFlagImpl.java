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

import de.vodafone.esb.schema.common.commontypes_esb_001.ErrorType;
import de.vodafone.esb.service.sbus.ccm.ccm_001.SetFNPAoFlagRequest;
import de.vodafone.esb.service.sbus.ccm.ccm_001.SetFNPAoFlagResponse;

@SoapEndpoint(soapAction = "/CCM-001/SetFNPAoFlag", context = "de.vodafone.esb.service.sbus.ccm.ccm_001", schema = "classpath:CCM-001.xsd")
public class SetFNPAoFlagImpl extends SoapServiceImpl 
            implements SoapOperation<SetFNPAoFlagRequest, SetFNPAoFlagResponse> {

    public ServiceResponse<SetFNPAoFlagResponse> invoke(ServiceObjectEndpoint<SetFNPAoFlagRequest> serviceObject)
			throws FunctionalException, TechnicalException,FunctionalRuntimeException, TechnicalRuntimeException {

		SynchronousServiceBusClientRequestHandler requestHandler = getRequestHandler();
    	
    	String trxId = serviceObject.getCorrelationID();
    	String packageName = serviceObject.getJavaPackage();
    	SetFNPAoFlagRequest request = serviceObject.getPayload();
    	String orderId = request.getOrderId();
    	if (orderId != null) {
			orderId = ((orderId.length() > 13) ? orderId.substring(0, 13) : orderId);
			request.setOrderId(orderId);
		}
		SetFNPAoFlagResponse output = new SetFNPAoFlagResponse();
		ServiceBusRequest busRequest = createServiceBusRequest(request,trxId,packageName,"SetFNPAoFlag");
		busRequest.setRequestType(ServiceBusRequest.requestTypeService);
		busRequest.setStartDate(new Date(System.currentTimeMillis()));
		
		try {
			// call the FIF client to process the message
			busRequest = requestHandler.processServiceBusRequest(busRequest);
			if (busRequest.getStatus().equals(ServiceBusRequest.requestStatusCompleted))
				output.setStatus("SUCCESS");
			if (busRequest.getStatus().equals(ServiceBusRequest.requestStatusFailed)) {
				output.setStatus("FAILED");
				ErrorType errType = new ErrorType();
				errType.setErrorCode(busRequest.getErrorCode());
				errType.setErrorDescription(busRequest.getErrorText());
				output.setErrorDetails(errType);
				throw new FunctionalException("CCMCOM-ERROR-000010","AO Flag could not be set: " + busRequest.getErrorText());
			}			
		} catch (FIFException e) {
			Throwable attachedException = (e.getCause() != null) ? e.getCause() : e;
			logger.error(e.getMessage(), attachedException);
			throw new TechnicalException("FIF-0108","Unknown exception raised");
		}
		return new ServiceResponseSoap<SetFNPAoFlagResponse>(output);
	}

}
