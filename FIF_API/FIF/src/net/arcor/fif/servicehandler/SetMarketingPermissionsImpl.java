/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/SetMarketingPermissionsImpl.java-arc   1.3   Jul 16 2015 16:31:34   schwarje  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/SetMarketingPermissionsImpl.java-arc  $
 * 
 *    Rev 1.3   Jul 16 2015 16:31:34   schwarje
 * PPM-95514: corrected soap action based on WSDL
 * 
 *    Rev 1.2   Jun 10 2015 13:29:50   schwarje
 * PPM-95514: small changes
 * 
 *    Rev 1.1   May 26 2015 07:19:24   schwarje
 * PPM-95514 CPM
 * 
 *    Rev 1.0   May 19 2015 08:03:24   makuier
 * Initial revision.
 */
package net.arcor.fif.servicehandler;

import java.util.Date;

import javax.xml.bind.JAXBException;

import net.arcor.fif.client.ServiceBusRequest;
import net.arcor.fif.client.SynchronousServiceBusClientRequestHandler;
import net.arcor.fif.common.FIFErrorLiterals;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FIFFunctionalException;

import org.xml.sax.SAXException;

import de.vodafone.esb.service.eai.customer.customerinteraction_002.SetMarketingPermissionsRequest;
import de.vodafone.esb.service.eai.customer.customerinteraction_002.SetMarketingPermissionsResponse;

public class SetMarketingPermissionsImpl extends HttpSoapServiceImpl {

    public SetMarketingPermissionsImpl() throws JAXBException, SAXException {
		super();
	}

    static {
        context = "de.vodafone.esb.service.eai.customer.customerinteraction_002";
        schemaName = "schema/CustomerInteraction-002.xsd";
        soapAction = "/CustomerInteraction002/SetMarketingPermission";
    }
    
    /**
	 * The operation "SetMarketingPermissions" of the service "SetMarketingPermissions".
	 */
    protected Object executeService(Object request) throws FIFException{
    	SetMarketingPermissionsRequest smpr = (SetMarketingPermissionsRequest) request;
		SynchronousServiceBusClientRequestHandler requestHandler = getRequestHandler();
    	
		// GUID is used as transactionID for FIF
    	String correlationID = smpr.getGUID();
    	
		ServiceBusRequest busRequest = createServiceBusRequest(smpr, correlationID, context, soapAction);
		busRequest.setRequestType(ServiceBusRequest.requestTypeService);
		busRequest.setStartDate(new Date(System.currentTimeMillis()));
		busRequest.setExternalSystemId(smpr.getCustomerNumber());

		// call the FIF client to process the message in the backend	
		busRequest = requestHandler.processServiceBusRequest(busRequest);				
		if (busRequest.getStatus().equals(ServiceBusRequest.requestStatusFailed)) {
			// FIF0037 (request already successfully processed) is not considered an error.
			if (!busRequest.getErrorCode().equals(FIFErrorLiterals.FIF0037.name()))
				throw new FIFFunctionalException(busRequest.getErrorCode(), busRequest.getErrorText());
		}

		// there are no output parameters in the response, so just return an empty object
    	return new SetMarketingPermissionsResponse();
    }
}
