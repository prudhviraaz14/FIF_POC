/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/SynchronousFifServiceHandler.java-arc   1.9   Nov 22 2010 10:36:54   makuier  $
 *    $Revision:   1.9  $
 *    $Workfile:   SynchronousFifServiceHandler.java  $
 *      $Author:   makuier  $
 *        $Date:   Nov 22 2010 10:36:54  $
 *
 *  Function: service handler for synchronous processing in FIF
 *  
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/SynchronousFifServiceHandler.java-arc  $
 * 
 *    Rev 1.9   Nov 22 2010 10:36:54   makuier
 * Adapted to mcf2
 * 
 *    Rev 1.8   Sep 15 2008 09:32:58   schwarje
 * SPN-FIF-000076119: improved request logging for service bus client
 * 
 *    Rev 1.7   Aug 21 2008 17:02:44   schwarje
 * IT-22684: added support for populating output parameters on service bus requests
 * 
 *    Rev 1.6   Jul 30 2008 16:27:34   schwarje
 * IT-k-23569: new FIF client for reading responses for service bus requests initiated from CCM
 * 
 *    Rev 1.5   May 05 2008 16:18:02   schwarje
 * SPN-FIF-000070336: improved logging for SynchonousServiceBusClient
 * 
 *    Rev 1.4   Feb 28 2008 14:59:24   schwarje
 * IT-20793: added processing of events
 * 
 *    Rev 1.3   Feb 06 2008 12:42:26   makuier
 * Put an instance of handler per thread in an static map.
 * 
 *    Rev 1.2   Jan 30 2008 16:47:28   schwarje
 * IT-20058: Redesign of FIF service bus client
 * 
 *    Rev 1.1   Jan 30 2008 13:13:54   schwarje
 * IT-20058: Redesign of FIF service bus client
 * 
 *    Rev 1.0   Jan 29 2008 17:45:34   schwarje
 * Initial revision.
 * 
 ***************************************************************************  
 */
package net.arcor.fif.servicehandler;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Map;

import javax.xml.bind.JAXBElement;
import javax.xml.datatype.XMLGregorianCalendar;

import net.arcor.epsm_basetypes_001.InputData;
import net.arcor.epsm_basetypes_001.OutputData;
import net.arcor.epsm_basetypes_001.ProviderService;
import net.arcor.fif.client.ServiceBusRequest;
import net.arcor.fif.client.SynchronousServiceBusClientRequestHandler;
import net.arcor.fif.common.FIFException;
import net.arcor.mcf2.exception.base.MCFException;
import net.arcor.mcf2.model.ServiceObjectEndpoint;
import net.arcor.mcf2.model.ServiceResponse;

import com.sun.org.apache.xerces.internal.jaxp.datatype.XMLGregorianCalendarImpl;

/**
 * The SynchronousFifServiceHandler handles service bus requests for
 * FIF synchronously, i.e. it waits for FifInterface to process the message 
 * and returns the result of the request to the service bus
 * @author schwarje
 *
 */
public class SynchronousFifServiceHandler extends SynchronousFifHandler {
	
	public SynchronousFifServiceHandler() throws MCFException {
		super();
	}
	
	private static SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");
	
	public ServiceResponse<?> execute(final ServiceObjectEndpoint<?> serviceInput)
		throws MCFException {
		
		SynchronousServiceBusClientRequestHandler requestHandler = getRequestHandler();
	
		@SuppressWarnings("unchecked")
		ProviderService service = ((JAXBElement<ProviderService>)(serviceInput.getPayload())).getValue();
		
		InputData input = getServiceInputObject(service);		
		OutputData output = createOutputObject(service);
		JAXBElement<?> returnObject = createReturnObject(service, output);		
		HashMap<String, String> header = new HashMap<String, String>();
		header.put("JMSCorrelationID", serviceInput.getCorrelationID());
		header.put("PTF_RequestName", serviceInput.getServiceName());
		ServiceBusRequest busRequest = createServiceBusRequest(input, header);
		busRequest.setRequestType(ServiceBusRequest.requestTypeService);
		busRequest.setStartDate(new Date(System.currentTimeMillis()));
		
		try {
			// call the FIF client to process the message
			busRequest = requestHandler.processServiceBusRequest(busRequest);
		} catch (FIFException e) {
			Throwable attachedException = (e.getCause() != null) ? e.getCause() : e;
			logger.error(e.getMessage(), attachedException);
			setResult(output, false, "FIF0013", attachedException.getMessage());
			return null;
		}
		
		// variables for the response
		boolean result = true;
		String errorCode = null;
		String errorText = null;
		
		// check if message will be recycled
		if (busRequest.getStatus().equals(ServiceBusRequest.requestStatusInRecycling)) {
			result = false;
			errorCode = busRequest.getErrorCode();
			errorText = "Request failed with FIF error message " + busRequest.getErrorText() + 
					". The message will be automatically resent after " + busRequest.getRecycleDelay() + 
					" seconds.";
		}
		else if (busRequest.getStatus().equals(ServiceBusRequest.requestStatusFailed)) { 
			result = false;
			errorCode = busRequest.getErrorCode();
			errorText = busRequest.getErrorText();
		}
		else if (!(busRequest.getStatus().equals(ServiceBusRequest.requestStatusCompleted)))
			throw new MCFException("Illegal status of service bus request.");
		
		setResult(output, result, errorCode, errorText);
		setReturnParameters(output, busRequest.getReturnParameters());
		
		String logMessage = "Finished processing of service bus request. Status: " + busRequest.getStatus();
		if (!result) 
			logMessage += ", error code: " + errorCode + ", error text: " + errorText;
		logger.info(logMessage);
	
		if (busRequest.getStatus().equals(ServiceBusRequest.requestStatusInRecycling))
			// TODO currently (1.26) recycling is done by raising a technical exception
			// will be changed some time in the future (hopefully)
			throw new MCFException("Message has to be processed again.");
	
		if (returnObject == null)
			return null;
		return serviceInput.createResponse(returnObject);
	}

	/**
	 * @param output
	 */
	protected void setReturnParameters(OutputData output, Map<String, String> returnParameters) 
						throws MCFException{
		try {
			Method[] allMethods = output.getClass().getDeclaredMethods();
			for (String parameterName : returnParameters.keySet()){
				String parameterValue = returnParameters.get(parameterName);
				for (Method m : allMethods) {
					if (m.getName().equals("set" + parameterName)) {
			            Class[] types = m.getParameterTypes();
			            if (types.length > 0) {
			                if (types[0].getName().equals("java.lang.Integer"))
			                    m.invoke(output, Integer.parseInt(parameterValue));
			                else if (types[0].getName().equals("java.lang.Long"))
			                    m.invoke(output, Long.parseLong(parameterValue));
			                else if (types[0].getName().equals("int"))
			                    m.invoke(output, Integer.parseInt(parameterValue));
			                else if (types[0].getName().equals("long"))
			                    m.invoke(output, Long.parseLong(parameterValue));
			                else if (types[0].getName().endsWith("XMLGregorianCalendar"))
			                    m.invoke(output, formatDate(parameterValue));
			                else 
			                    m.invoke(output, parameterValue);
			            }
					}
				}			
			}
		} catch (NumberFormatException e) {
        	String errorText = "Illegal number format returned from FIF.";
        	logger.error(errorText, e);
        	throw new MCFException(errorText);
		} catch (SecurityException e) {
        	String errorText = "Class structure doesn't match the expected structure.";
        	logger.error(errorText, e);
        	throw new MCFException(errorText);
		} catch (IllegalArgumentException e) {
        	String errorText = "Argument type for output not supported.";
        	logger.error(errorText);
        	throw new MCFException(errorText);
		} catch (IllegalAccessException e) {
        	String errorText = "Class structure doesn't match the expected structure.";
        	logger.error(errorText, e);
        	throw new MCFException(errorText);
		} catch (InvocationTargetException e) {
        	String errorText = "Class structure doesn't match the expected structure.";
        	logger.error(errorText, e);
        	throw new MCFException(errorText);
		}
	}

    private XMLGregorianCalendar formatDate(String dateAsString) throws MCFException {
        Date date = null;
        try {
            date = dateFormat.parse(dateAsString);
        } catch (ParseException e) {
        	String errorText = "Invalid date format returned from FIF. The date string '" + dateAsString +
            				   "' doesn't match the expected format ('" + dateFormat + "')";
        	logger.error(errorText, e);
            throw new MCFException(errorText);
        }
        GregorianCalendar calendar = new GregorianCalendar();
        calendar.setTime(date);
        return new XMLGregorianCalendarImpl(calendar);
    }
}
