/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/SoapServiceImpl.java-arc   1.6   Nov 08 2017 23:57:18   lejam  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/SoapServiceImpl.java-arc  $
 * 
 *    Rev 1.6   Nov 08 2017 23:57:18   lejam
 * PPM249301 SPN-CCB-134368 eTop
 * 
 *    Rev 1.5   Oct 21 2017 06:51:38   naveen.k
 * Changed the visibility of methods to support overriding
 * 
 *    Rev 1.4   Oct 19 2017 16:39:28   lejam
 * PPM249301 eTOP AutoBill
 * 
 *    Rev 1.3   Jul 06 2017 08:41:58   lalit.kumar-nayak
 * RMS163506- Automated_Onboarding_WebTicketService _CCB
 * 
 *    Rev 1.2   May 26 2015 07:19:30   schwarje
 * PPM-95514 CPM
*/
package net.arcor.fif.servicehandler;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigInteger;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.datatype.XMLGregorianCalendar;
import javax.xml.validation.Schema;

import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.client.ServiceBusRequest;
import net.arcor.fif.client.SynchronousServiceBusClientRequestHandler;
import net.arcor.mcf2.exception.base.MCFException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

abstract public class SoapServiceImpl {

	protected static final SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");
	
    final static Log logger = LogFactory.getLog(SoapServiceImpl.class);
	protected static JAXBContext jbContext=null;
	protected static Schema schema = null; 
	protected static String context = null;
	protected static String schemaName = null;
	protected static String soapAction = null;
//
//	public String getSoapAction() {
//		return soapAction;
//	}
	
	protected ServiceBusRequest createServiceBusRequest(
			Object request, String trxId, String packageName,String serviceName) {			
		// extract some useful names from the input object
		ServiceBusRequest busRequest = new ServiceBusRequest(trxId);
		busRequest.setCallSynch(false);
		busRequest.setPackageName(packageName);
		busRequest.setServiceName(serviceName);

		// populate the values on a service bus request object
		busRequest.getParameters().put("transactionID",trxId);
		busRequest.getParameters().put("packageName",packageName);
		busRequest.setStartDate(new Date());

		// call all input getter methods and populate their values as parameters of the request
		populateRequestParameter(request, "", busRequest);

		// get class name of service to find the right mapping
		logger.info("Start processing service bus request of type '" + serviceName + "'...");

		return busRequest;
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
	protected boolean isSimpleType(Object returnParameter) {
		return returnParameter instanceof XMLGregorianCalendar ||
			returnParameter instanceof String ||
			returnParameter instanceof Integer ||
			returnParameter instanceof BigInteger ||
			returnParameter instanceof BigDecimal ||
			returnParameter instanceof Long ||
			returnParameter instanceof Boolean;
	}

	/**
	 * @param returnParameter
	 * @param returnType
	 * @return
	 */
	protected String parseSimpleParameter(Object returnParameter) {
		// transform dates to fif/ccb format
		if (returnParameter instanceof XMLGregorianCalendar)							
			return dateFormatter.format(((XMLGregorianCalendar)returnParameter).
					toGregorianCalendar().getTime());
		else 
			return returnParameter.toString();
		// add parameter to service bus request
	}
	
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

	protected SynchronousServiceBusClientRequestHandler getRequestHandler() throws MCFException {
		SynchronousServiceBusClientRequestHandler requestHandler = null;
		try {
			// get the next available number
			requestHandler = 
				(SynchronousServiceBusClientRequestHandler)SynchronousFifHandler.getHandlerMap().get(Thread.currentThread().getName());
			if (requestHandler == null){
				if (!SynchronousFifHandler.getThreadNumberMap().containsKey(Thread.currentThread().getName())){
					SynchronousFifHandler.getThreadNumberMap().put(Thread.currentThread().getName(), SynchronousFifHandler.getNoOfActiveHndThreads());
					SynchronousFifHandler.setNoOfActiveHndThreads(SynchronousFifHandler.getNoOfActiveHndThreads()+1);
				}
        	    String ccmInstanceBase = ClientConfig.getSetting("ServerHandler.ServerInstanceBase");
				String currentExt = SynchronousFifHandler.getThreadNumberMap().get(Thread.currentThread().getName()).toString();
				requestHandler = new SynchronousServiceBusClientRequestHandler(ccmInstanceBase+currentExt);
				SynchronousFifHandler.getHandlerMap().put(Thread.currentThread().getName(), requestHandler);
			}
		} catch (Exception e) {
			logger.fatal("Exception caught while initializing SynchronousFifHandler. " +
					"See exception for details: ", e);
			throw new MCFException("Exception caught while initializing SynchronousFifHandler. " +
					"See exception for details: ");
		}
		return requestHandler;
	}

}
