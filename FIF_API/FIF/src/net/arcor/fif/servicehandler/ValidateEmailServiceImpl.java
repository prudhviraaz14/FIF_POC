/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/ValidateEmailServiceImpl.java-arc   1.0   Mar 28 2014 08:54:52   schwarje  $
 *    $Revision:   1.0  $
 *    $Workfile:   ValidateEmailServiceImpl.java  $
 *      $Author:   schwarje  $
 *        $Date:   Mar 28 2014 08:54:52  $
 *
 *  Function: service handler for ValidateEmail
 *  
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/ValidateEmailServiceImpl.java-arc  $
 * 
 *    Rev 1.0   Mar 28 2014 08:54:52   schwarje
 * Initial revision.
 * 
 ***************************************************************************  
 */
package net.arcor.fif.servicehandler;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

import net.arcor.fif.client.ServiceBusRequest;
import net.arcor.fif.client.SynchronousServiceBusClientRequestHandler;
import net.arcor.fif.common.FIFException;
import net.arcor.mcf2.model.ServiceObjectEndpoint;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.vodafone.mcf2.ws.service.OnewaySoapOperation;
import com.vodafone.mcf2.ws.service.SoapEndpoint;

import de.vodafone.esb.service.eai.customer.emailutility_001.ValidateEmailResponse;

/**
 * response handler implementation example.
 * 
 * @author schwarje
 */
@SoapEndpoint(soapAction = "response~/EmailUtility-001/ValidateEmail", context = "de.vodafone.esb.service.eai.customer.emailutility_001", schema = "classpath:EmailUtility-001.xsd")
public class ValidateEmailServiceImpl extends SoapServiceImpl
	implements OnewaySoapOperation<ValidateEmailResponse> {

    /** Logger */
    private final static Log logger = LogFactory.getLog(ValidateEmailServiceImpl.class);
    
    @PostConstruct
    public void init() {
        logger.info("ValidateEmailServiceImpl::init");
    }

    @PreDestroy
    public void destroy() {
        logger.info("ValidateEmailServiceImpl::destroy");
    }

    public void invoke(ServiceObjectEndpoint<ValidateEmailResponse> serviceObject) {
    	
    	logger.info("Processing response for asynchronous call of " + 
    			serviceObject.getServiceName() + 
    			", correlationID: " + 
    			serviceObject.getSbusCorrelationID());	
    	// get a fresh RequestHandler
    	SynchronousServiceBusClientRequestHandler requestHandler = getRequestHandler();
    	
    	ValidateEmailResponse response = serviceObject.getPayload();
    	
		ServiceBusRequest busRequest = createServiceBusRequest(
				response, 
				serviceObject.getSbusCorrelationID(), 
				serviceObject.getJavaPackage(),
				serviceObject.getServiceName().substring(serviceObject.getServiceName().lastIndexOf("/") + 1));
		busRequest.setRequestType(ServiceBusRequest.requestTypeResponse);
		//busRequest.setStartDate(new Date(System.currentTimeMillis()));		
		busRequest.getParameters().put("originalRequestResult", response.getStatus().equals("0") ? "true" : "false");
		if (response.getErrorCode() != null && !(response.getErrorCode().equals("")))
			busRequest.getParameters().put("originalRequestErrorCode", response.getErrorCode());
		if (response.getErrorMessage() != null && !(response.getErrorMessage().equals("")))
			busRequest.getParameters().put("originalRequestErrorText", response.getErrorMessage());

		try {
			// call the FIF client to process the message
			busRequest = requestHandler.processServiceBusReply(busRequest);
		} catch (FIFException e) {
			Throwable attachedException = (e.getCause() != null) ? e.getCause() : e;
			logger.error(e.getMessage(), attachedException);
		}
    	
    }

}
