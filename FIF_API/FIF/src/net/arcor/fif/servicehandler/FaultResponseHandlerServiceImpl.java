/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/FaultResponseHandlerServiceImpl.java-arc   1.0   Mar 28 2014 08:55:08   schwarje  $
 *    $Revision:   1.0  $
 *    $Workfile:   FaultResponseHandlerServiceImpl.java  $
 *      $Author:   schwarje  $
 *        $Date:   Mar 28 2014 08:55:08  $
 *
 *  Function: General Fault Response Handler
 *  
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/FaultResponseHandlerServiceImpl.java-arc  $
 * 
 *    Rev 1.0   Mar 28 2014 08:55:08   schwarje
 * Initial revision.
 * 
 ***************************************************************************  
 */
package net.arcor.fif.servicehandler;

import javax.jms.TextMessage;
import javax.xml.transform.Source;

import net.arcor.fif.client.ServiceBusRequest;
import net.arcor.fif.client.SynchronousServiceBusClientRequestHandler;
import net.arcor.fif.common.FIFException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.vodafone.mcf2.ws.addon.FaultResponseHandler;

import de.vodafone.esb.schema.common.basetypes_esb_001.ESBException;

/**
 * Fault response handler implementation.
 * 
 * @author schwarje
 */
public class FaultResponseHandlerServiceImpl extends SoapServiceImpl implements FaultResponseHandler {

    /** Logger. */
    private final static Log logger = LogFactory.getLog(FaultResponseHandlerServiceImpl.class);

    /** SBUS correlation id */
    private String correlationId;

    /** ESB Exception */
    private ESBException esbException;

    /** textMessage */
    private TextMessage textMessage;

    /**
     * fault construct
     * 
     * @param correlationId
     * @param esbException
     */
    public FaultResponseHandlerServiceImpl(String correlationId, TextMessage textMessage, ESBException esbException) {
        this.correlationId = correlationId;
        this.esbException = esbException;
        this.textMessage = textMessage;
    }

    /**
     */
    public FaultResponseHandlerServiceImpl() {
        super();        
    }
    
    /* (non-Javadoc)
     * @see com.vodafone.mcf2.ws.addon.FaultResponseHandler#invoke(javax.xml.transform.Source)
     */
    public Source invoke(Source request) throws Exception {

		SynchronousServiceBusClientRequestHandler requestHandler = getRequestHandler();
    	
    	String fullServiceName = textMessage.getStringProperty("SBUS_Servicename");    	
    	
		ServiceBusRequest busRequest = createServiceBusRequest(
				esbException, 
				correlationId, 
				"soap-fault",
				fullServiceName.substring(fullServiceName.lastIndexOf("/") + 1));
		busRequest.setRequestType(ServiceBusRequest.requestTypeResponse);
		busRequest.getParameters().put("originalRequestResult", "false");
		if (esbException != null) {
			if (esbException.getErrorDetails().getErrorCode() != null && !(esbException.getErrorDetails().getErrorCode().equals("")))
				busRequest.getParameters().put("originalRequestErrorCode", esbException.getErrorDetails().getErrorCode());

			String errorMessage = "";			
			if (esbException.getErrorDetails().getErrorMessage() != null)
				errorMessage += esbException.getErrorDetails().getErrorMessage().trim();
			if (esbException.getErrorDetails().getErrorDescription() != null)
				errorMessage += " - " + esbException.getErrorDetails().getErrorDescription().trim();
			if (esbException.getErrorDetails().getErrorInformation() != null)
				errorMessage += " - " + esbException.getErrorDetails().getErrorInformation().trim();
				
			if (!errorMessage.equals(""))
				busRequest.getParameters().put("originalRequestErrorText", errorMessage);
		}

		try {
			// call the FIF client to process the message
			busRequest = requestHandler.processServiceBusReply(busRequest);
		} catch (FIFException e) {
			Throwable attachedException = (e.getCause() != null) ? e.getCause() : e;
			logger.error(e.getMessage(), attachedException);
		}
		
        return null;
    }

    public void setCorrelationId(String correlationId) {
        this.correlationId = correlationId;
    }

    public void setEsbException(ESBException esbException) {
        this.esbException = esbException;
    }

    public void setTextMessage(TextMessage textMessage) {
        this.textMessage = textMessage;
    }
}
