/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/transport/ServiceBusInterface.java-arc   1.3   Aug 05 2011 14:57:22   schwarje  $
 *    $Revision:   1.3  $
 *    $Workfile:   ServiceBusInterface.java  $
 *      $Author:   schwarje  $
 *        $Date:   Aug 05 2011 14:57:22  $
 *
 *  Function: Main class of the service bus interface
 *  
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/transport/ServiceBusInterface.java-arc  $
 * 
 *    Rev 1.3   Aug 05 2011 14:57:22   schwarje
 * BKS request for TFW
 * 
 *    Rev 1.22   06 Jun 2011 16:48:56   wlazlow
 * SPN-FIF-000112730
 * 
 *    Rev 1.21   28 Jan 2011 13:23:30   wlazlow
 * IT-k-29845
 * 
 *    Rev 1.19   13 Oct 2010 11:17:24   makuier
 * Get context variable from a getter.
 * 
 *    Rev 1.18   07 Oct 2010 15:40:28   makuier
 * Moved the bean instantiation to init.
 * 
 *    Rev 1.17   16 Sep 2010 18:40:42   wlazlow
 * SPN-CCB-000102970
 * 
 *    Rev 1.14   25 Jun 2010 12:36:36   wlazlow
 * IT-27143
 * 
 *    Rev 1.13   16 Jan 2009 17:49:48   schwarje
 * IT-k-24916
 * allow priority to be populated on SBUS messages
 * 
 *    Rev 1.12   15 Dec 2008 17:12:32   schwarje
 * SPN-FIF-000080627
 * changed creation of correlation id
 * 
 *    Rev 1.11   04 Aug 2008 17:22:10   schwarje
 * IT-23029
 * added logging of start and end times
 * 
 *    Rev 1.10   27 May 2008 13:37:06   schwarje
 * IT-21762
 * added new parameter types, improved logging
 *
 *    Rev 1.9   05 May 2008 11:16:06   schwarje
 * IT-22324
 * added logging for committing and rolling back async requests
 * 
 *    Rev 1.8   30 Apr 2008 17:55:14   schwarje
 * SPN-CCB-000068794
 * updated commit and rollback methods
 * 
 *    Rev 1.7   23 Apr 2008 18:09:04   schwarje
 * IT-22324
 * added external system id to logging table
 * split queue handlers for sync and async requests
 * 
 *    Rev 1.6   03 Apr 2008 15:33:46   makuier
 * Added support for handling bus reply.
 * IT-20178
 * 
 *    Rev 1.5   26 Feb 2008 19:08:30   schwarje
 * IT-20793
 * updated to use FIF classes
 * 
 *    Rev 1.4   13 Feb 2008 18:03:50   schwarje
 * fixed typo in property name
 * 
 *    Rev 1.3   13 Feb 2008 17:04:30   schwarje
 * SPN-CCB-000067439
 * 1) handle FatalServiceResponse correctly
 * 2) handle responses for sync service bus requests correctly
 * 3) update status for service bus request logging
 * 4) service dependent sync timeouts
 * 
 *    Rev 1.2   08 Aug 2007 16:00:28   schwarje
 * SPN-CCB-000059206
 * added exception handling and logging
 * 
 *    Rev 1.1   26 Jul 2007 10:28:02   wlazlow
 * IT-19536
 * 
 *    Rev 1.0   25 Jul 2007 17:08:58   wlazlow
 * Initial revision.
 *
 ***************************************************************************  
 */

package net.arcor.fif.transport;

import java.lang.reflect.Method;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.TextMessage;
import javax.xml.bind.JAXBElement;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;

import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.client.ServiceBusInterfaceException;
import net.arcor.fif.client.ServiceBusRequest;
import net.arcor.fif.client.ServiceBusRequestLogger;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.Log4jConfig;
import net.arcor.fif.db.DatabaseConfig;
import net.arcor.mcf2.model.ServiceResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.FileSystemXmlApplicationContext;


import com.vodafone.mcf2.ws.model.impl.ServiceRequestSoap;

import de.vodafone.esb.schema.common.basetypes_esb_001.AppMonDetailsType;






public  class ServiceBusInterface {
    
    public static final String technicalFailureMessage = "Technical failure. See ServiceBusInterface log file for details of the exception.";

    public static final int defaultJmsPriority = 4;

    private static Log logger = LogFactory.getLog(ServiceBusInterface.class);
    
    private static long sequenceNumber = 0;
    
    private static boolean initialized = false;
    
    private static boolean initSuccessful = false;	    
    
    private static FileSystemXmlApplicationContext ctx = null;
   // private static MessageSender amessageSender = null;
    
    private static ServiceBusRequestLogger requestLogger = null;
    
    private static LinkedList<ServiceBusRequest> openAsnycRequests = null;
    private static LinkedList<String> openAsnycRequestsPriority = null;
    
    
    public static void init(String propertyFilename) {
        if (initialized)
            return;
        initialized = true;

        try {
            logger.info("Initializing ServiceBusInterface, property file: " + propertyFilename);

            ctx = new FileSystemXmlApplicationContext(
					ClientConfig.getSetting("CcmServiceBusInterface.BeanConfigurationFile"));            
            
            // set variables valid for all requests
            ServiceBusRequest.setEnvironmentName(
                ClientConfig.getSetting("CcmServiceBusInterface.EnvironmentName"));
            ServiceBusRequest.setClientName("CCM");

            // request logging in the database
            requestLogger = new ServiceBusRequestLogger();

            // Invoker properties
            try {
            	ServiceBusRequestInvoker.setDefaultSynchTimeout(
                        ClientConfig.getInt("CcmServiceBusInterface.SynchTimeout.Default"));
            } catch (FIFException e) {}

            try {
                ServiceBusRequestInvoker.setDateFormat(new SimpleDateFormat(
                        ClientConfig.getSetting("CcmServiceBusInterface.CCBDateFormat")));
            } catch (FIFException e) {}

            openAsnycRequests = new LinkedList<ServiceBusRequest>();
            openAsnycRequestsPriority = new LinkedList<String>();
            
            initSuccessful = true;
        } catch (Throwable t) {
            logger.error("An error occured while initializing CcmServiceBusInterface:", t);
        }
    }  
    
   

    public static FileSystemXmlApplicationContext getCtx() {
        return ctx;
    }

    public static void setCtx(FileSystemXmlApplicationContext ctx) {
        ServiceBusInterface.ctx = ctx;
    }
    
    public static void processRequest(String callSynch, String packageName,
            String serviceName, String externalSystemId, String priority, String[] parameterNames,
            String[] parameterValues, String[] outputList) {
        ServiceBusRequest request = null;
		  	 
        try {
        	
            if (outputList == null)
                outputList = new String[3];

            int jmsPriority = Integer.parseInt(priority);
            try{
            	String priorityFromConfiguration = ClientConfig.getSetting("CcmServiceBusInterface.JmsPriority."+serviceName );
                if(priorityFromConfiguration!=null && !priorityFromConfiguration.equals("")){   
                	priority=priorityFromConfiguration;
                	jmsPriority = Integer.parseInt(priority);            	
                }
            }catch(Exception e) {           	
            }
            
            
            
            String clientName = "CCM";
      
            request = new ServiceBusRequest(generateCorrelationId(clientName));
            request.setEventDueDate(getEventDueDate(serviceName));
            request.setStartDate(new Date(System.currentTimeMillis()));
            request.setRequestType(ServiceBusRequest.requestTypeService);       
            
            request.setCallSynch((callSynch.equals("Y")) ? true : false);
            if (request.isCallSynch())
            	request.setStatus(ServiceBusRequest.requestStatusPending);
            else
            	request.setStatus(ServiceBusRequest.requestStatusNotSent);
            request.setServiceName(serviceName);
            request.setPackageName(packageName);
            request.setExternalSystemId(externalSystemId);
            for (int i = 0; i < parameterNames.length; i++)
            	request.getParameters().put(parameterNames[i], parameterValues[i]);
                
            logger.info("Start processing of request (Id: " + request.getRequestId() + 
                    ") for service " + packageName + "." + serviceName);
            
            requestLogger.insertRequest (request);

            if (!initialized || !initSuccessful) 
                throw new ServiceBusInterfaceException("SBUS0007", 
                        "Initialization of ServiceBusInterface failed. See log file for details.", null);
            
            ServiceBusRequestInvoker ccmServiceBusRequestInvoker = (ServiceBusRequestInvoker) ctx.getBean("ccmServiceBusRequestInvoker");
            ccmServiceBusRequestInvoker.setRequest(request);

            if (request.isCallSynch()) { 
                ccmServiceBusRequestInvoker.execute(jmsPriority,false);
            }else{
                ccmServiceBusRequestInvoker.execute(jmsPriority,true);
            }

            String serverResponse = ccmServiceBusRequestInvoker.getServerResponse();
            outputList[2] = serverResponse;
            Throwable e = request.getThrowable();

            // log the request to the database
            if (e == null) {
                if (request.isCallSynch()) {
                    request.setStatus(ServiceBusRequest.requestStatusCompleted);
                    request.setEndDate(new Date(System.currentTimeMillis()));
                    requestLogger.updateRequest(request);
                }
            } else {
                request.setStatus(ServiceBusRequest.requestStatusFailed);
                request.setEndDate(new Date(System.currentTimeMillis()));
                requestLogger.updateRequest(request);
                throw e;
            }

            if (!request.isCallSynch()) {
                openAsnycRequests.add(request);
                openAsnycRequestsPriority.add(priority);
            }
        } catch (ServiceBusInterfaceException sbie) {
            outputList[0] = sbie.getErrorCode();
            outputList[1] = sbie.getMessage();
            String errorString = "SBUS-Request (Id: " + ((request != null ) ? request.getRequestId() : "unknown")
                    + "): An error occured:" + "\nError code: "
                    + sbie.getErrorCode() + "\nError message: " 
                    + sbie.getMessage();
            if (sbie.getRoot() == null)
                logger.error(errorString, sbie);
            else {
                logger.error(errorString + "\nRoot exception: ", sbie.getRoot());
                outputList[1] += " Exception was: " + sbie.getRoot().getClass().getName() + 
                        ". Message: " + sbie.getRoot().getMessage();
            }
        } catch (Throwable t) {
            logger.error("SBUS-Request (Id: " + ((request != null ) ? request.getRequestId() : "unknown") + 
                    "): Unknown exception was thrown, see details: ", t);
            outputList[0] = "SBUS0000";
            outputList[1] = technicalFailureMessage + " Exception was: " + t.getClass().getName() + 
                    ". Message: " + t.getMessage();
        }
       
        logger.info("Finished processing of request (Id: " + request.getRequestId() + 
                    ") for service " + packageName + "." + serviceName);
       
    }
    
 
//    public static void commitAsynchronousRequests(String errorMessage) {
    public static void commitAsynchronousRequests(String[] outputList) { 
        if (openAsnycRequests.size() > 0) {
            logger.info("Committing " + openAsnycRequests.size()+ " open messages for asynchronous requests.");
             if (outputList == null)
                    outputList = new String[3];

             int i = 0;
             for (ServiceBusRequest request : openAsnycRequests) {
                //String[] outputList = new String[3];
                try {
                    String priority = openAsnycRequestsPriority.get(i);
                    i++;
                    int jmsPriority = Integer.parseInt(priority);

                    ServiceBusRequestInvoker ccmServiceBusRequestInvoker = (ServiceBusRequestInvoker) ctx.getBean("ccmServiceBusRequestInvoker");
                    ccmServiceBusRequestInvoker.setRequest(request);
                
                    ccmServiceBusRequestInvoker.execute(jmsPriority,false);
                    
                    String serverResponse = ccmServiceBusRequestInvoker.getServerResponse();
                    outputList[2] = serverResponse;
                    Throwable e = request.getThrowable();
                    // log the request to the database
                    if (e == null) {
                        request.setStatus(ServiceBusRequest.requestStatusPending);
                        try {
                            requestLogger.updateRequest(request);
                        } catch (SQLException ex) {
                            logger.error("Error while logging rolled back service bus request (Id: "
                                        + request.getRequestId()
                                        + ") to the database.");
                        }
                    } else {
                        request.setStatus(ServiceBusRequest.requestStatusFailed);
                        request.setEndDate(new Date(System.currentTimeMillis()));
                        requestLogger.updateRequest(request);
                        throw e;
                    }
                } catch (SQLException ex) {
                    logger.error("Error while logging rolled back service bus request (Id: "
                                + request.getRequestId()
                                + ") to the database.");
                    rollbackAsynchronousRequests("");
                    break;
                }catch (Throwable t) {
                    logger.error("SBUS-Request (Id: " + ((request != null ) ? request.getRequestId() : "unknown") + 
                            "): Unknown exception was thrown, see details: ", t);
                    outputList[0] = "SBUS0000";
                    outputList[1] = technicalFailureMessage + " Exception was: " + t.getClass().getName() + 
                            ". Message: " + t.getMessage();
                        //errorMessage = outputList[1];     
                    t.printStackTrace();
                    rollbackAsynchronousRequests("");
                    break;
                }
            }
            openAsnycRequests = new LinkedList<ServiceBusRequest>();
        }
    }

    
    public static void rollbackAsynchronousRequests(String errorMessage) {
        if (openAsnycRequests.size() > 0) {
            logger.info("Rolling back " + openAsnycRequests.size() + " open messages for asynchronous requests.");
            
            for (ServiceBusRequest request : openAsnycRequests) {
                request.setStatus(ServiceBusRequest.requestStatusRolledBack);
                try {
                    // TODO better delete the entry
                    requestLogger.updateRequest(request);
                } catch (SQLException e) {
                    logger.error("Error while logging rolled back service bus request (Id: " + 
                            request.getRequestId() + ") to the database.");
                }
            }
            openAsnycRequests = new LinkedList<ServiceBusRequest>();
        }
    }
    
    private static String generateCorrelationId (String prefix) {
        String correlationId = 
            prefix + "-" + 
            new Long(System.nanoTime()).toString() + "-" +  
            new Long(++sequenceNumber).toString();        
        return correlationId;
    }
    
    private static Date getEventDueDate(String serviceName) {
        Date returnDate = null;
        try {
            int maxEventWaitTime = ClientConfig.getInt("CcmServiceBusInterface.MaxEventWaitTime." + serviceName);
            returnDate = new Date(System.currentTimeMillis() + 1000 * maxEventWaitTime);
        } catch (FIFException e) {}
        return returnDate;
    }
  
    

    public static void processSoapRequest(String callSynch, String packageName,
            String serviceName, String xsdFile, String operationName,String externalSystemId, String priority, String[] parameterNames,
            String[] parameterValues, String[] outputList) {
    
        if (outputList == null)
            outputList = new String[3];
        ServiceRequestSoap serviceRequest=null;
        ServiceResponse serviceResponse=null;
        try {
            int jmsPriority = Integer.parseInt(priority);
            String clientName = "CCM";

            Object serviceObject = null;
            serviceObject = instantiateObjectByName(packageName + "." + serviceName+"Request");
            serviceRequest = new ServiceRequestSoap(serviceObject, xsdFile, packageName);
            
            Object serviceResponseObject = null;
            try{
               serviceResponseObject = instantiateObjectByName(packageName + "." + serviceName+"Response");
            }catch(Exception e){}

 //           String serviceOriginator = ClientConfig.getSetting("CcmServiceBusInterface.ServiceOriginator"); 
            
            serviceRequest.setOperationName(operationName);
            serviceRequest.setSbusCorrelationID(generateCorrelationId(clientName));
            serviceRequest.setPriority(jmsPriority);
                       
            AppMonDetailsType appMonDetailsType = new AppMonDetailsType();    
            //appMonDetailsType.setBpId(serviceRequest.getCorrelationID());
            //appMonDetailsType.setBpName("CCM_SBUS_INTERFACE");
            appMonDetailsType.setCallingApp("CCM");
            //appMonDetailsType.setInitiator("CCM_SBUS_INTERFACE_INITIATOR");
            serviceRequest.setAppMonDetails(appMonDetailsType);
    
            //serviceRequest.setServiceOriginator(serviceOriginator);
            logger.info("Start processing of request (Id: " + serviceRequest.getCorrelationID() + 
                    ") for service " + packageName + "." + serviceName);
      
            Map<String,String> parameters = new HashMap<String,String>();
            
            for (int i = 0; i < parameterNames.length; i++)
                parameters.put(parameterNames[i], parameterValues[i]);
            
            if (!initialized || !initSuccessful) 
                throw new ServiceBusInterfaceException("SBUS0007", 
                        "Initialization of ServiceBusInterface failed. See log file for details.", null);
            
            ServiceBusRequestInvoker ccmServiceBusRequestInvoker = (ServiceBusRequestInvoker) ctx.getBean("ccmServiceBusRequestInvoker");

       /*
             Method[] methods = serviceRequest.getPayload().getClass().getMethods();     
            Method theMethod = null;           
            for (int i=0;i<methods.length;i++) {
               System.out.println(methods[i].getName());
            }
       */
            
            serviceResponse = ccmServiceBusRequestInvoker.executeSoap(serviceName,callSynch,serviceRequest,parameters);
            if(serviceResponse!=null){
                //outputList[2] = serviceRequest.getPayload().toString();
                TextMessage message = (TextMessage)serviceResponse.getIncomingMessage();
                String text = message.getText();
               
                outputList[2] = text;
            }
         } catch (ServiceBusInterfaceException e) {
              e.printStackTrace();
              logger.error(e.getMessage());
              
              outputList[0] = e.getErrorCode();
              outputList[1] = e.getMessage();
        }catch (BeansException e) {
            
            e.printStackTrace();
            logger.error(e.getMessage());
            outputList[0] = "SBUS0000";
            outputList[1] = e.getMessage();
        } catch (JMSException e) {
            e.printStackTrace();
            logger.error(e.getMessage());
            outputList[0] = "SBUS0000";
            outputList[1] = e.getMessage();
        } 
        logger.info("Finished processing of request (Id: " + serviceRequest.getSbusCorrelationID() + 
                ") for service " + packageName + "." + serviceName);  
    }
       
   
    private static Object instantiateObjectByName(String objectName)
            throws ServiceBusInterfaceException {
        Class aClass = null;
        Object anObject = null;
        try {
            aClass = Class.forName(objectName);
            anObject = aClass.newInstance();
        } catch (ClassNotFoundException e) {
            throw new ServiceBusInterfaceException("SBUS0005", "Class "
                  + objectName + " was not found. Maybe ...", e);
        } catch (InstantiationException e) {
            throw new ServiceBusInterfaceException("SBUS0000",
                  ServiceBusInterface.technicalFailureMessage, e);
        } catch (IllegalAccessException e) {
            throw new ServiceBusInterfaceException("SBUS0000",
                  ServiceBusInterface.technicalFailureMessage, e);
        }
        return anObject;
    }
    
    
  
    
}
