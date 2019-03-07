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

import de.vodafone.esb.service.sbus.ccm.ccm_001.GenerateOrderEnvelopeNumberRequest;
import de.vodafone.esb.service.sbus.ccm.ccm_001.GenerateOrderEnvelopeNumberResponse;

@SoapEndpoint(soapAction = "/CCM-001/GenerateOrderEnvelopeNumber", context = "de.vodafone.esb.service.sbus.ccm.ccm_001", schema = "classpath:CCM-001.xsd")
public class GenerateOrderEnvelopeNumberImpl extends SoapServiceImpl 
            implements SoapOperation<GenerateOrderEnvelopeNumberRequest, GenerateOrderEnvelopeNumberResponse> {

    public ServiceResponse<GenerateOrderEnvelopeNumberResponse> invoke(ServiceObjectEndpoint<GenerateOrderEnvelopeNumberRequest> serviceObject)
			throws FunctionalException, TechnicalException,FunctionalRuntimeException, TechnicalRuntimeException {

		SynchronousServiceBusClientRequestHandler requestHandler = getRequestHandler();
    	
    	String trxId = serviceObject.getCorrelationID();
    	String packageName = serviceObject.getJavaPackage();
    	GenerateOrderEnvelopeNumberRequest request = serviceObject.getPayload();

    	GenerateOrderEnvelopeNumberResponse output = new GenerateOrderEnvelopeNumberResponse();
		ServiceBusRequest busRequest = createServiceBusRequest(request,trxId,packageName,"GenerateOrderEnvelopeNumber");
		busRequest.setRequestType(ServiceBusRequest.requestTypeService);
		busRequest.setStartDate(new Date(System.currentTimeMillis()));

		try {
			// call the FIF client to process the message
			busRequest = requestHandler.processServiceBusRequest(busRequest);
			if (busRequest.getStatus().equals(ServiceBusRequest.requestStatusCompleted)) {
				String orderEnvelopeNumber = busRequest.getReturnParameters().get("orderEnvelopeNumber");
				output.setOrderEnvelopeNumber(orderEnvelopeNumber);
			}
			if (busRequest.getStatus().equals(ServiceBusRequest.requestStatusFailed))
				output.setOrderEnvelopeNumber("");
		} catch (FIFException e) {
			Throwable attachedException = (e.getCause() != null) ? e.getCause() : e;
			logger.error(e.getMessage(), attachedException);
			throw new TechnicalException("FIF-0108","Unknown exception raised");
		}
		return new ServiceResponseSoap<GenerateOrderEnvelopeNumberResponse>(output);
	}

}
