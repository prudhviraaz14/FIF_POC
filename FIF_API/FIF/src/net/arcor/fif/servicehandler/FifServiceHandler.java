/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/FifServiceHandler.java-arc   1.7   Jan 31 2014 13:10:58   schwarje  $
 *    $Revision:   1.7  $
 *    $Workfile:   FifServiceHandler.java  $
 *      $Author:   schwarje  $
 *        $Date:   Jan 31 2014 13:10:58  $
 *
 *  Function: service handler for synchronous processing in FIF
 *  
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/FifServiceHandler.java-arc  $
 * 
 *    Rev 1.7   Jan 31 2014 13:10:58   schwarje
 * SPN-FIF-000126786: handle Enum types in SBUS-FIF-Requests
 * 
 *    Rev 1.6   Nov 22 2010 10:36:54   makuier
 * Adapted to mcf2
 * 
 *    Rev 1.5   Jan 20 2009 09:56:24   schwarje
 * SPN-CCB-000081938: handle fatalServiceResponse in SbusResponseClient
 * 
 *    Rev 1.4   Jul 30 2008 16:27:34   schwarje
 * IT-k-23569: new FIF client for reading responses for service bus requests initiated from CCM
 * 
 ***************************************************************************  
 */
package net.arcor.fif.servicehandler;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.bind.JAXBElement;
import javax.xml.datatype.XMLGregorianCalendar;

import net.arcor.epsm_basetypes_001.InputData;
import net.arcor.epsm_basetypes_001.OutputData;
import net.arcor.epsm_basetypes_001.ProviderService;
import net.arcor.fif.client.ServiceBusRequest;
import net.arcor.fif.epsm_fif_001.ObjectFactory;
import net.arcor.mcf2.exception.base.MCFException;
import net.arcor.mcf2.service.Service;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public abstract class FifServiceHandler implements Service {

	protected final Log logger = LogFactory.getLog(getClass());
	
	/**
	 * handles the processing of fif requests  
	 */
	
	/**
	 * date format for transforming a service bus date to a fif date
	 */
	protected static final SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");
	
	/**
	 * maximum error message length defined in SBUS xsds
	 */
	protected static final int maxErrorMessageLength = 255;

	public FifServiceHandler() {
		super();
	}

	/**
	 * retrieves the request parameters from the service bus request param list by
	 * looping through all methods of the input
	 * @param input
	 * @param prefix
	 * @param listParameters
	 * @throws MCFException
	 */
	protected void populateRequestParameterList(Object input, String prefix, Map<String, String> listParameters) 
		throws MCFException {
		Method[] allMethods = input.getClass().getDeclaredMethods();
		try {
			for (Method m : allMethods) {
				if (m.getName().startsWith("get") && m.getName().length() > "get".length()) {
					Object returnParameter;
					returnParameter = m.invoke(input, (Object[]) null);
					String name = prefix + m.getName().substring("get".length());
					if (isSimpleType(returnParameter))
						listParameters.put(name, parseSimpleParameter(returnParameter));					
					else if (returnParameter instanceof Collection)
						throw new MCFException("nested parameter lists are not supported yet.");
					else if (returnParameter != null)
						populateRequestParameterList (
							returnParameter, name + ";", listParameters);
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

	/**
	 * retrieves the request parameters from the service bus request by
	 * looping through all methods of the input
	 * @param input
	 * @param prefix
	 * @param parameters
	 * @throws MCFException
	 */
	protected void populateRequestParameter(Object input, String prefix, ServiceBusRequest busRequest) 
		throws MCFException {
		Method[] allMethods = input.getClass().getDeclaredMethods();
		try {
			for (Method m : allMethods) 
			{
				if ((m.getName().startsWith("get") || m.getName().startsWith("is"))
						&& m.getName().length() > "get".length())
				{
					Object returnParameter;
					returnParameter = m.invoke(input, (Object[]) null);
					String simpleName = null;
					if (m.getName().startsWith("get"))
						simpleName = m.getName().substring("get".length());
					else if (m.getName().startsWith("is"))
						simpleName = m.getName().substring("is".length());
					String concatName = prefix + simpleName;

					if (returnParameter instanceof JAXBElement)
						returnParameter = ((JAXBElement) returnParameter).getValue();

					if (returnParameter != null && returnParameter.getClass().isEnum())
						returnParameter = ((Enum<?>)returnParameter).name();

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
								populateRequestParameterList(item, "", listParameters);
							itemList.add(listParameters);
						}
						
						busRequest.getParameterLists().put(concatName, itemList);
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

	/**
	 * @param returnParameter
	 * @return
	 */
	private boolean isSimpleType(Object returnParameter) {
		return returnParameter instanceof XMLGregorianCalendar ||
			returnParameter instanceof String ||
			returnParameter instanceof Integer ||
			returnParameter instanceof Long ||
			returnParameter instanceof Boolean;
	}

	/**
	 * @param returnParameter
	 * @param returnType
	 * @return
	 */
	private String parseSimpleParameter(Object returnParameter) {
		// transform dates to fif/ccb format
		if (returnParameter instanceof XMLGregorianCalendar)							
			return dateFormatter.format(((XMLGregorianCalendar)returnParameter).
					toGregorianCalendar().getTime());
		else 
			return returnParameter.toString();
		// add parameter to service bus request
	}
	
	protected ServiceBusRequest createServiceBusRequest(Object dataObject, Map header) throws MCFException {
		
		// extract some useful names from the input object
		String inputClassName = dataObject.getClass().getSimpleName();
		String inputFullClassName = dataObject.getClass().getName();
		String serviceName = null;
		if (inputClassName.endsWith("Output"))
			serviceName = inputClassName.substring(0, inputClassName.length() - "Output".length());
		else if (inputClassName.endsWith("Input"))
			serviceName = inputClassName.substring(0, inputClassName.length() - "Input".length());
		else
			throw new MCFException("Unexpected class structure, expected ...Input or ...Output, found " + inputClassName);
		String packageName = dataObject.getClass().getName().substring(0, 
				inputFullClassName.length() - inputClassName.length() - 1);		
				
		// the correlation id is used as transaction id for FIF
	    String transactionId = (String) header.get("JMSCorrelationID");
		
		ServiceBusRequest busRequest = new ServiceBusRequest(transactionId);
		busRequest.setCallSynch(false);
		busRequest.setPackageName(packageName);
		
		if (serviceName.equals("FatalServiceResponse")) {
			busRequest.setFatalServiceResponse(true);
			String actualServiceName = (String) header.get("PTF_RequestName");
			busRequest.setServiceName(actualServiceName.substring(0, 1).toUpperCase() + 
					actualServiceName.substring(1, actualServiceName.length() - "Service".length()));
		}			
		else 
			busRequest.setServiceName(serviceName);
		
		// populate the values on a service bus request object
		busRequest.getParameters().put("transactionID",transactionId);
		busRequest.getParameters().put("packageName",packageName);
		busRequest.setStartDate(new Date());

		// call all input getter methods and populate their values as parameters of the request
		populateRequestParameter(dataObject, "", busRequest);

		// get class name of service to find the right mapping
		logger.info("Start processing service bus request of type '" + serviceName + "'...");
		
		return busRequest;
	}

	protected JAXBElement<?> createReturnObject(ProviderService service, OutputData output) throws MCFException {
		// extract some useful names from the service
		String serviceClassName = service.getClass().getSimpleName();
		String serviceFullClassName = service.getClass().getName();
		String serviceName = serviceClassName.substring(0, serviceClassName.length() - "Service".length());
		String packageName = service.getClass().getName().substring(0, 
				serviceFullClassName.length() - serviceClassName.length() - 1);
		
		logger.info("Request for service '" + serviceName + "' received.");
		
		JAXBElement<?> returnObject = null;
		
		// do all the Java reflection before sending message to FifInterface, so we can make
		// sure we don't run into problems after processing the request
		try {
			// create a service object for the output
			ObjectFactory of = new ObjectFactory();
			Object outService = Class.forName(serviceFullClassName).newInstance();
			
			// populate the output on the service object
			Method outputSetter = outService.getClass().getMethod(
					"set" + serviceName + "Output", 
					new Class[]{ Class.forName(packageName + "." + serviceName + "Output")});
			outputSetter.invoke(outService, new Object[] {output});

			// create the jaxb object, which will be returned from the output service object
			Method serviceCreator = of.getClass().getMethod(
					"create" + serviceClassName, new Class[]{outService.getClass()});
			returnObject = (JAXBElement<?>)serviceCreator.invoke(of, new Object[] {outService});
		} catch (Exception e) {
			String errorMessage = "Class structure doesn't match the expected structure.";
			logger.fatal(errorMessage, e);
			throw new MCFException(errorMessage);
		}

		return returnObject;
	}

	/**
	 * @param service
	 */
	protected OutputData getEventOutputObject(ProviderService service) throws MCFException {
		String serviceClassName = service.getClass().getSimpleName();	
		String serviceName = serviceClassName.substring(0, serviceClassName.length() - "Event".length());

		OutputData output;
		try {
			// get the input object from the service object
			Method inputGetter = service.getClass().getMethod("get" + serviceName + "Output");
			output = (OutputData) inputGetter.invoke(service, (Object[]) null);
		} catch (Exception e) {
			throw new MCFException("Class structure doesn't match the expected structure.");
		}
		return output;
	}

	/**
	 * @param service
	 */
	protected InputData getServiceInputObject(ProviderService service) throws MCFException {
		String serviceClassName = service.getClass().getSimpleName();	
		String serviceName = serviceClassName.substring(0, serviceClassName.length() - "Service".length());

		InputData input;
		try {
			// get the input object from the service object
			Method inputGetter = service.getClass().getMethod("get" + serviceName + "Input");
			input = (InputData) inputGetter.invoke(service, (Object[]) null);
		} catch (Exception e) {
			throw new MCFException("Class structure doesn't match the expected structure.");
		}
		return input;
	}

	/**
	 * @param service
	 */
	protected OutputData getServiceOutputObject(ProviderService service) throws MCFException {
		String serviceClassName = service.getClass().getSimpleName();
		String serviceName;
		if (serviceClassName.equals("FatalServiceResponse"))
			serviceName = "FatalServiceResponse";
		else
			serviceName = serviceClassName.substring(0, serviceClassName.length() - "Service".length());

		OutputData output;
		try {
			// get the output object from the service object
			Method outputGetter = service.getClass().getMethod("get" + serviceName + "Output");
			output = (OutputData) outputGetter.invoke(service, (Object[]) null);
		} catch (Exception e) {
			throw new MCFException("Class structure doesn't match the expected structure.");
		}
		return output;
	}
	
	/**
	 * @param service
	 */
	protected OutputData createOutputObject(Object service) throws MCFException {
		String serviceClassName = service.getClass().getSimpleName();
		String serviceFullClassName = service.getClass().getName();
		String serviceName = serviceClassName.substring(0, serviceClassName.length() - "Service".length());
		String packageName = service.getClass().getName().substring(0, 
				serviceFullClassName.length() - serviceClassName.length() - 1);
		
		OutputData output = null;
		try {
			output = (OutputData) Class.forName(packageName + "." + serviceName + "Output").newInstance();
		} catch (Exception e) {
			throw new MCFException("Class structure doesn't match the expected structure.");
		}
		return output;
	}
	
	/**
	 * @param output
	 * @param result
	 * @param errorCode
	 * @param errorText
	 */
	protected void setResult(OutputData output, boolean result, String errorCode, String errorText) {
		// set the ouput and log the result
		output.setResult(result);
		if (errorText != null)
			output.setErrorText(
					(errorText.length() > maxErrorMessageLength) ? 
					errorText.substring(0, maxErrorMessageLength) : errorText);		
		output.setErrorCode(errorCode);
	}

}
