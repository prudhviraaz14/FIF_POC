/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/ActivateCustomerOrderImpl.java-arc   1.2   Nov 24 2017 18:01:40   naveen.k  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/ActivateCustomerOrderImpl.java-arc  $
 * 
 *    Rev 1.2   Nov 24 2017 18:01:40   naveen.k
 * Fixed:SPN-FIF-000134442,ActivateCustomerOrder supports Service Subscription Lists alone
 * 
 *    Rev 1.1   Nov 08 2017 23:57:18   lejam
 * PPM249301 SPN-CCB-134368 eTop
 * 
 *    Rev 1.0   Oct 19 2017 16:39:28   lejam
 * PPM249301 eTOP AutoBill
 *
*/
package net.arcor.fif.servicehandler;

import java.util.Date;

import javax.xml.bind.JAXBElement;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import net.arcor.mcf2.exception.base.MCFException;

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
     
import de.vodafone.esb.service.sbus.fif.fif_activatecustomerorder_001.ActivateCustomerOrderRequest;
import de.vodafone.esb.service.sbus.fif.fif_activatecustomerorder_001.ActivateCustomerOrderResponse;

@SoapEndpoint(soapAction = "/FIF-001/ActivateCustomerOrder", context = "de.vodafone.esb.service.sbus.fif.fif_001", schema = "classpath:FIF-001.xsd")
public class ActivateCustomerOrderImpl extends SoapServiceImpl 
            implements SoapOperation<ActivateCustomerOrderRequest, ActivateCustomerOrderResponse> {

	private String ServiceSubscriptionId =null;
    List<Map<String, String>> completeitemList = null;
    private boolean isDone=false;
    public ServiceResponse<ActivateCustomerOrderResponse> invoke(ServiceObjectEndpoint<ActivateCustomerOrderRequest> serviceObject)
			throws FunctionalException, TechnicalException,FunctionalRuntimeException, TechnicalRuntimeException {

		SynchronousServiceBusClientRequestHandler requestHandler = getRequestHandler();
    	
    	String correlationID = serviceObject.getSbusCorrelationID();
    	if (correlationID == null || correlationID.equals(""))
    		correlationID = serviceObject.getCorrelationID();
    	String packageName = serviceObject.getJavaPackage();
    	
    	ActivateCustomerOrderRequest request = new ActivateCustomerOrderRequest();
    	Object payload = serviceObject.getPayload();
		if (payload instanceof JAXBElement)
			request = (ActivateCustomerOrderRequest)((JAXBElement) payload).getValue();
		else
			request = serviceObject.getPayload();		

	    completeitemList = new ArrayList<Map<String, String>>();
		
    	ActivateCustomerOrderResponse output = new ActivateCustomerOrderResponse();
		ServiceBusRequest busRequest = createServiceBusRequest(request,correlationID,packageName,"CompleteCustomerOrder");
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
		
		completeitemList.clear();
		
		return new ServiceResponseSoap<ActivateCustomerOrderResponse>(output);
	}

  	protected void populateRequestParameter(Object request,
			String prefix, ServiceBusRequest busRequest) {
		Method[] allMethods = request.getClass().getDeclaredMethods();
		try {
			for (Method m : allMethods) 
			{
				if ((m.getName().startsWith("get") || m.getName().startsWith("is"))
						&& m.getName().length() > "get".length())
				{
					Object returnParameter;
					returnParameter = m.invoke(request, (Object[]) null);
					String simpleName = null;
					if (m.getName().startsWith("get"))
						simpleName = m.getName().substring("get".length());
					else if (m.getName().startsWith("is"))
						simpleName = m.getName().substring("is".length());
					String concatName = prefix + simpleName;

					if (returnParameter instanceof JAXBElement)
						returnParameter = ((JAXBElement) returnParameter).getValue();

					if (returnParameter instanceof Enum)
						returnParameter = ((Enum) returnParameter).name();

					if (isSimpleType(returnParameter)) {
						busRequest.getParameters().put(concatName, parseSimpleParameter(returnParameter));
						logger.debug("Added parameter '" + simpleName + 
								"' with value '" + returnParameter.toString() + "' to request.");
					}
					else if (returnParameter instanceof Collection) {						
						List<Map<String, String>> itemList = new ArrayList<Map<String, String>>();
						for (Object item : (Collection) returnParameter) {
							Map<String, String> listParameters = new HashMap<String, String>();
							if (isSimpleType(item))
								listParameters.put(simpleName, parseSimpleParameter(item));
							else
								populateRequestParameterList(item, "", listParameters,busRequest);
							listParameters.put("ServiceSubscriptionId",ServiceSubscriptionId);
							if(!listParameters.isEmpty() && concatName.equals("ServiceCharacteristicList;ServiceCharacteristic")){
							completeitemList.add(listParameters);
							
							}
						
							if(!concatName.equals("ServiceCharacteristicList;ServiceCharacteristic")&& simpleName.equals("ServiceSubscription") && !isDone){
								listParameters.put("ServiceSubscriptionId",ServiceSubscriptionId);
								completeitemList.add(listParameters);
								busRequest.getParameterLists().put("ServiceCharacteristicList;ServiceCharacteristic", completeitemList);
							}
							
							//itemList.add(listParameters);
						}
						
						if(busRequest.getParameters().containsKey("ServiceSubscriptionId")){
							busRequest.getParameters().remove("ServiceSubscriptionId");
						}
						if(concatName.equals("ServiceCharacteristicList;ServiceCharacteristic"))
						busRequest.getParameterLists().put(concatName, completeitemList);
						
					}
					else if (returnParameter != null)
						populateRequestParameter(
								returnParameter, concatName + ";", busRequest);
				}
			}
		} catch (IllegalArgumentException e) {
			String errorMessage = "Class structure doesn't match the expected structure.";
			logger.fatal(errorMessage, e);
			throw new MCFException(errorMessage);
		} catch (IllegalAccessException e) {
			String errorMessage = "Class structure doesn't match the expected structure.";
			logger.fatal(errorMessage, e);
			throw new MCFException(errorMessage);
		} catch (InvocationTargetException e) {
			String errorMessage = "Class structure doesn't match the expected structure.";
			logger.fatal(errorMessage, e);
			throw new MCFException(errorMessage);
		}
	}

  	protected void populateRequestParameterList(Object input, String prefix, Map<String, String> listParameters,ServiceBusRequest busRequest) 
	throws MCFException {
	Method[] allMethods = input.getClass().getDeclaredMethods();
	
	try {
		for (Method m : allMethods) {
			if (m.getName().startsWith("get") && m.getName().length() > "get".length()) {
				Object returnParameter;
				returnParameter = m.invoke(input, (Object[]) null);
				String name = prefix + m.getName().substring("get".length());
				
				if(name.equals("ServiceSubscriptionId")){
					ServiceSubscriptionId=parseSimpleParameter(returnParameter);
					isDone=false;
				}
				if (isSimpleType(returnParameter))
					listParameters.put(name, parseSimpleParameter(returnParameter));					
				else if (returnParameter instanceof Collection){
					
				}
				//	throw new MCFException("nested parameter lists are not supported yet.");
				else if (returnParameter != null && name.equals("ServiceCharacteristicList") ){
					/*if(!listParameters.isEmpty()){
						List<Map<String, String>> itemList = new ArrayList<Map<String, String>>();
						itemList.add(listParameters);
						busRequest.getParameterLists().put(name+";ServiceCharacteristic", itemList);
					}*/
					isDone=true;
					
				populateRequestParameter(input, "", busRequest);
				}
				else if (returnParameter != null)
					populateRequestParameterList (
						returnParameter, name + ";", listParameters,busRequest);
			}
		}
	} catch (IllegalArgumentException e) {
		String errorMessage = "Class structure doesn't match the expected structure.";
		logger.fatal(errorMessage, e);
		throw new MCFException(errorMessage);
	} catch (IllegalAccessException e) {
		String errorMessage = "Class structure doesn't match the expected structure.";
		logger.fatal(errorMessage, e);
		throw new MCFException(errorMessage);
	} catch (InvocationTargetException e) {
		String errorMessage = "Class structure doesn't match the expected structure.";
		logger.fatal(errorMessage, e);
		throw new MCFException(errorMessage);
	}
}


}
