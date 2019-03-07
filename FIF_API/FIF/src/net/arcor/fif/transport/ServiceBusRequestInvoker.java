/**
 ***************************************************************************
 *    $Revision:   1.2  $
 *    $Workfile:   ServiceBusRequestInvoker.java  $
 *      $Author:   schwarje  $
 *        $Date:   Aug 05 2011 14:57:22  $
 *
 * TODO Function: Service Invoker, does bla bla 
 *  
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/transport/ServiceBusRequestInvoker.java-arc  $
 * 
 *    Rev 1.2   Aug 05 2011 14:57:22   schwarje
 * BKS request for TFW
 * 
 *    Rev 1.25   06 Jun 2011 16:49:16   wlazlow
 * SPN-FIF-000112730
 * 
 *    Rev 1.24   04 May 2011 13:11:16   wlazlow
 * SPN-CCB-000111961
 * 
 *    Rev 1.23   05 Apr 2011 21:26:26   wlazlow
 * IT-k-30310
 *
 *    Rev 1.21   21 Feb 2011 10:51:26   makuier
 * Poluate the correlation ID for all requests.
 * 
 *    Rev 1.20   28 Jan 2011 13:23:38   wlazlow
 * IT-k-29845
 * 
 *    Rev 1.18   14 Dec 2010 21:07:58   wlazlow
 * SPN-CCB-000107022
 * 
 *    Rev 1.17   13 Oct 2010 11:18:00   makuier
 * Get context variable from a getter.
 * 
 *    Rev 1.16   22 Sep 2010 10:14:46   lejam
 * Using TextMessage class to get responce XML in invokeService SPN-FIF-104102
 * 
 *    Rev 1.15   21 Sep 2010 17:23:32   makuier
 * pointer check.
 * 
 *    Rev 1.14   16 Sep 2010 18:41:16   wlazlow
 * SPN-CCB-000102970
 * 
 *    Rev 1.11   25 Jun 2010 12:36:42   wlazlow
 * IT-27143
 * 
 *    Rev 1.10   11 May 2010 20:17:18   wlazlow
 * IT-26056
 * 
 *    Rev 1.9   16 Jan 2009 17:50:28   schwarje
 * IT-k-24916
 * allow priority to be populated on SBUS messages
 * 
 *    Rev 1.8   04 Dec 2008 12:05:40   schwarje
 * SPN-FIF-000080437
 * always commit sync responses
 * 
 *    Rev 1.7   13 Nov 2008 14:32:20   makuier
 * Added support for Enum.
 * 
 *    Rev 1.6   04 Aug 2008 17:23:12   schwarje
 * IT-23029
 * improved logging of JAXBExceptions, allow object factories from different packages to create service object
 * 
 *    Rev 1.5   27 May 2008 13:37:32   schwarje
 * IT-21762
 * added new parameter types, improved logging
 * 
 *    Rev 1.4   23 Apr 2008 18:09:58   schwarje
 * IT-22324
 * added external system id to logging table
 * split queue handlers for sync and async requests
 * 
 *    Rev 1.3   03 Apr 2008 15:46:36   makuier
 * populate the result comming back from SBUS.
 * IT-20178
 * 
 *    Rev 1.2   26 Feb 2008 19:08:14   schwarje
 * IT-20793
 * updated to use FIF classes
 * 
 *    Rev 1.1   13 Feb 2008 17:06:08   schwarje
 * SPN-CCB-000067439
 * 1) handle FatalServiceResponse correctly
 * 2) handle responses for sync service bus requests correctly
 * 3) update status for service bus request logging
 * 4) service dependent sync timeouts
 * 
 *    Rev 1.0   08 Aug 2007 16:01:22   schwarje
 * Initial revision.
 * 
 *    Rev 1.1   26 Jul 2007 18:24:04   wlazlow
 * IT-19536
 * 
 *************************************************************************** 
 */

package net.arcor.fif.transport;


import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Map;

import javax.jms.TextMessage;
import javax.xml.bind.JAXBElement;
import javax.xml.datatype.XMLGregorianCalendar;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.client.ServiceBusInterfaceException;
import net.arcor.fif.client.ServiceBusRequest;
import net.arcor.fif.common.FIFException;
import net.arcor.mcf2.exception.base.MCFException;
import net.arcor.mcf2.exception.internal.FatalServiceResponseException;
import net.arcor.mcf2.exception.internal.TimeoutException;
import net.arcor.mcf2.model.ServiceConfig;
import net.arcor.mcf2.model.ServiceConfigXml;
import net.arcor.mcf2.model.ServiceRegistrySender;
import net.arcor.mcf2.model.ServiceResponse;
import net.arcor.mcf2.model.impl.ServiceRequestJaxb;
import net.arcor.mcf2.sender.MessageSender;
import net.arcor.mcf2.xml.XmlProcessor;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionStatus;
import org.w3c.dom.CharacterData;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.helpers.DefaultHandler;

import com.sun.org.apache.xerces.internal.jaxp.datatype.XMLGregorianCalendarImpl;
import com.vodafone.mcf2.ws.model.impl.ServiceRequestSoap;


/**
 * TODO change headers, commenting
 * CcmServiceInvoker als Beispiel zur Aufruf synchroner und asynchroner Requests.
 * @author makuier
 */




public class ServiceBusRequestInvoker{

    @Autowired
    private ServiceRegistrySender registry;
    
    @Autowired
    private MessageSender messageSender;
	
	private static int defaultSynchTimeout = 30000;

    protected final Log logger = LogFactory.getLog(getClass());

    private PlatformTransactionManager transactionManager = null;

    private TransactionStatus transactionStatus = null;

    private ServiceBusRequest request = null;    

    private String  serverResponse = null;

    private static SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");

    public ServiceBusRequestInvoker() {
        
    }
    public ServiceBusRequestInvoker(ServiceBusRequest request) {
        super();
        this.request = request;
    }
    
    private class MyValidator extends DefaultHandler {
		public boolean validationError = false;
		public SAXParseException saxParseException = null;

		public void error(SAXParseException exception) throws SAXException {
			validationError = true;
			saxParseException = exception;
		}

		public void fatalError(SAXParseException exception) throws SAXException {
			validationError = true;
			saxParseException = exception;
		}

		public void warning(SAXParseException exception) throws SAXException {
		}
	}

    
    private Object instantiateObjectByName(String objectName)
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
            throw new ServiceBusInterfaceException("SBUS0000", ServiceBusInterface.technicalFailureMessage, e);
        } catch (IllegalAccessException e) {
            throw new ServiceBusInterfaceException("SBUS0000", ServiceBusInterface.technicalFailureMessage, e);
        }
        return anObject;
    }

    /**
     * Invokes the method with the name provided in the input. If the name contains a semicolon,
     * the method is called recursively on the contained object 
     * @param anObject Object to call the method
     * @param prefix Prefix of the method name
     * @param methodName Name of the method (may be the artificial name containing semicolons)
     * @param methodValue method argument(s)
     * @param parameterType type of the method argument(s)
     * @return the return parameter of the method
     * @throws ServiceBusInterfaceException
     */
    private Object invokeMethod(Object anObject, String prefix,
            String methodName, Object methodValue, String parameterType) throws ServiceBusInterfaceException {
        logger.debug("Invoking method " + prefix + methodName + " with parameter type " + parameterType + 
                " on object of type " + anObject.getClass().getName());
        Object returnObject = null;
        try {
            if (prefix == null)
                prefix = "";
            int index = methodName.indexOf(";");
            // call this Java method recursively in case the method name is nested
            if (index >0){
                String parentTypeName = methodName.substring(0, index);
                String cascadedMethodName = methodName.substring(index+1);
                Object cascadedObject = findObjectByTypeName(anObject,parentTypeName);
                invokeMethod(cascadedObject,prefix,cascadedMethodName,methodValue,parameterType);
            }
            // otherwise call the desired method directly
            else {
                Method[] methods = anObject.getClass().getMethods();
                Method theMethod = null;
                // find the right method
                for (int i=0;i<methods.length;i++) {
                   if (methods[i].getName().equals(prefix + methodName) && 
                        (parameterType == null || 
                            (methods[i].getParameterTypes().length>0  && 
                            (methods[i].getParameterTypes())[0].getName().endsWith(parameterType)))) {
                        theMethod = methods[i];
                        break;
                    }
                }
        		// raise an exception if the method is not found
                if (theMethod == null)
                    throw new NoSuchMethodException("Method " + prefix + methodName + " could not be found.");
                Class[] types = theMethod.getParameterTypes();
                // if the method has parameters, handle dates and numbers accordingly, 
                // and treat all other inputs as strings
                if (types.length > 0) {
                    if (types[0].isEnum()) 
                        returnObject = theMethod.invoke(anObject, Enum.valueOf(types[0], (String)methodValue));
        		        else if (types[0].getName().equals("java.lang.Integer"))
                        returnObject = theMethod.invoke(anObject, Integer.parseInt((String)methodValue));
                    else if (types[0].getName().equals("java.lang.Long"))
                        returnObject = theMethod.invoke(anObject, Long.parseLong((String)methodValue));
                    else if (types[0].getName().equals("int"))
                        returnObject = theMethod.invoke(anObject, Integer.parseInt((String)methodValue));
                    else if (types[0].getName().equals("boolean"))
                        returnObject = theMethod.invoke(anObject, Boolean.parseBoolean((String)methodValue));				
                    else if (types[0].getName().equals("java.lang.Boolean"))
                        returnObject = theMethod.invoke(anObject, Boolean.parseBoolean((String)methodValue));																
                    else if (types[0].getName().equals("long"))
                        returnObject = theMethod.invoke(anObject, Long.parseLong((String)methodValue));
                    else if (types[0].getName().endsWith("XMLGregorianCalendar"))
                        returnObject = theMethod.invoke(anObject, formatDate((String)methodValue));                    
                    else if (types[0].getName().equals("org.w3c.dom.Element"))
                        returnObject = theMethod.invoke(anObject, parseElement((String)methodValue));	
                    else {
                    	
                        returnObject = theMethod.invoke(anObject, methodValue);
                        String servName = anObject.getClass().getName();
                        if(methodName.equals("SomString") && servName.equals("net.arcor.com.epsm_com_001.StartPreclearedFixedLineOrderInput")){
                        	ValidateSom((String)methodValue);
                        }
                    }
                }
                // otherwise call method with empty parameter list
                else {
                    returnObject = theMethod.invoke(anObject, (Object[]) null);
                }
            }
        } catch (SecurityException e) {
            throw new ServiceBusInterfaceException("SBUS0000", ServiceBusInterface.technicalFailureMessage, e);
        } catch (NoSuchMethodException e) {
            throw new ServiceBusInterfaceException("SBUS0004", "Method " + prefix + methodName + " with parameter type "
                    + parameterType + " wasn't found for class " + anObject.getClass().getName()
                    , e);
        } catch (IllegalArgumentException e) {
            throw new ServiceBusInterfaceException("SBUS0000", ServiceBusInterface.technicalFailureMessage, e);
        } catch (IllegalAccessException e) {
            throw new ServiceBusInterfaceException("SBUS0000", ServiceBusInterface.technicalFailureMessage, e);
        } catch (InvocationTargetException e) {
            throw new ServiceBusInterfaceException("SBUS0000", ServiceBusInterface.technicalFailureMessage, e);
        }
        return returnObject;
    }

    private Element parseElement(String somString) throws ServiceBusInterfaceException{
    	
  
    	Element somElement=null;   	
    	try {
   		
		    String somStringToParse = somString.replaceAll("&gt;", ">");
    		somStringToParse = somStringToParse.replaceAll("&lt;", "<");
            DocumentBuilderFactory dbf =
            DocumentBuilderFactory.newInstance();
            //dbf.setValidating(true);
            dbf.setNamespaceAware(true);
            
           
            
            DocumentBuilder db = dbf.newDocumentBuilder();
           
            
            InputSource is = new InputSource();  
            is.setCharacterStream(new StringReader(somStringToParse));
            Document doc = db.parse(is);
          
            
            //NodeList nodes = doc.getElementsByTagName("order");
            NodeList nodes = doc.getElementsByTagName("ns4:order");
            
            
            if (nodes.getLength() > 0)
            {
            	somElement = (Element) nodes.item(0);
            
            	//NodeList name = somElement.getElementsByTagName("sendingSystem");
      
                // Element nameElement = (Element) name.item(0);
                //System.out.println("sendingSystem: " + getCharacterDataFromElement(nameElement));          
            }
       }
        catch (Exception e) {
            e.printStackTrace();
            throw new ServiceBusInterfaceException("SBUS0023", "Parsing ANY element error.", e);
        }
    	
    	return somElement;
    }
    
    
      public String returnSomVersionFromXsd(String somXsdFile)throws ServiceBusInterfaceException{
    	String somVersion="";
    	try {
 			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
			DocumentBuilder db = dbf.newDocumentBuilder();
			InputSource is = new InputSource();  			
			Document doc = db.parse(somXsdFile);
			NodeList attibutes = doc.getElementsByTagName( "attribute" );
	
		    for( int i = 0; i < attibutes.getLength(); i++ ) {
		     
		      Element attribute = (Element) attibutes.item( i );
              if(attribute.getAttribute("name" ).equals("fixedSomMajorVersion"))		    
            	  somVersion=attribute.getAttribute("fixed" ) ;
		    }

    	}catch (Exception e) {
		            e.printStackTrace();
		            throw new ServiceBusInterfaceException("SBUS0023", "Parsing XSD error."+" "+e.getMessage(), e);
		}
    	return somVersion;
    }

   
      public String returnSomVersionFromXml(String somString)throws ServiceBusInterfaceException{
      	String somVersion="";
      	try {
   			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
  			DocumentBuilder db = dbf.newDocumentBuilder();
  			InputSource is = new InputSource();  
			is.setCharacterStream(new StringReader(somString));
			Document doc = db.parse(is);
  			
  			NodeList attibutes = doc.getElementsByTagName( "order" );
  			Element attribute = (Element) attibutes.item( 0 );
  			somVersion=attribute.getAttribute("somVersion" );
      	}catch (Exception e) {
  		            e.printStackTrace();
  		            throw new ServiceBusInterfaceException("SBUS0023", "Parsing XML error."+" "+e.getMessage(), e);
  		}
      	return somVersion;
      }
      
      
    public void ValidateSom(String somString)throws ServiceBusInterfaceException{
    	String xsdFile=null;
    	try{
    	    xsdFile = ClientConfig.getSetting("CcmServiceBusInterface.SomValidation.xsdFile");
    	}catch(FIFException e){
    		 throw new ServiceBusInterfaceException("SBUS0000", ServiceBusInterface.technicalFailureMessage, e);
    	}
    	
    	//String xsdFile="xsd/som-order.xsd";
    	String somVersionFromXsd = returnSomVersionFromXsd(xsdFile);
	  	String somVersionFromXml = returnSomVersionFromXml(somString);
	  	if(!somVersionFromXsd.equals(somVersionFromXml)){
	  		throw new ServiceBusInterfaceException("SBUS0025", "SOM has different version: "+somVersionFromXml+ " than xsd: "+somVersionFromXsd, null);
	  	}
    	try {
    	  	
    		//SchemaFactory schemaFactory = SchemaFactory.newInstance( XMLConstants.W3C_XML_SCHEMA_NS_URI );

    		// hook up org.xml.sax.ErrorHandler implementation.
    		//schemaFactory.setErrorHandler( myErrorHandler );

    		// get the custom xsd schema describing the required format for my XML files.
    		//Schema schemaXSD = schemaFactory.newSchema( new File ( "xsd/som-order.xsd" ) );

    		//Validator validator = schemaXSD.newValidator();
    		//System.out.println(validator.getProperty("fixedSomMajorVersion").toString());

    		

			String somStringToParse = somString.replaceAll("&gt;", ">");
			somStringToParse = somStringToParse.replaceAll("&lt;", "<");
			DocumentBuilderFactory dbf =
			DocumentBuilderFactory.newInstance();
			dbf.setValidating(true);
			dbf.setNamespaceAware(true);
			dbf.setAttribute(   
					"http://java.sun.com/xml/jaxp/properties/schemaLanguage",   
					"http://www.w3.org/2001/XMLSchema");   
			dbf.setAttribute(   
					"http://java.sun.com/xml/jaxp/properties/schemaSource",   
					xsdFile);               

			
			DocumentBuilder db = dbf.newDocumentBuilder();
			MyValidator handler=new MyValidator();
			db.setErrorHandler(handler); 
			
			InputSource is = new InputSource();  
			is.setCharacterStream(new StringReader(somStringToParse));
			Document doc = db.parse(is);
			
			if(handler.validationError==true)    {
			    System.out.println("XML Document has Error:"+handler.validationError+" "+handler.saxParseException.getMessage());
			    throw new ServiceBusInterfaceException("SBUS0023", "XML Document has Error:"+handler.validationError+" "+handler.saxParseException.getMessage(), null);
			}
    	}catch (Exception e) {
		            e.printStackTrace();
		            throw new ServiceBusInterfaceException("SBUS0023", "Parsing ANY element error."+" "+e.getMessage(), e);
		}

		
    	return;
    }
    
    public static String xmlToString(Node node) {
        try {
            Source source = new DOMSource(node);
            StringWriter stringWriter = new StringWriter();
            Result result = new StreamResult(stringWriter);
            TransformerFactory factory = TransformerFactory.newInstance();
            Transformer transformer = factory.newTransformer();
            transformer.transform(source, result);
            return stringWriter.getBuffer().toString();
        } catch (TransformerConfigurationException e) {
            e.printStackTrace();
        } catch (TransformerException e) {
            e.printStackTrace();
        }
        return null;
    }


 
    
    public static String getCharacterDataFromElement(Element e) {
        Node child = e.getFirstChild();
        if (child instanceof CharacterData) {
           CharacterData cd = (CharacterData) child;
           return cd.getData();
        }
        return "?";
      }

    
    private Object findObjectByTypeName(Object anObject, String parentTypeName)
            throws ServiceBusInterfaceException {
        try {
            Method m = anObject.getClass().getMethod("get" + parentTypeName);
            Object returnObj = m.invoke(anObject, (Object[]) null);
            if (returnObj == null) {
                Class theType = m.getReturnType();
                returnObj = theType.newInstance();
                Method m1 = anObject.getClass().getMethod(
                        "set" + parentTypeName, theType);
                m1.invoke(anObject, returnObj);
            }
            return returnObj;
        } catch (SecurityException e) {
            throw new ServiceBusInterfaceException("SBUS0000", ServiceBusInterface.technicalFailureMessage, e);
        } catch (NoSuchMethodException e) {
            throw new ServiceBusInterfaceException("SBUS0003", "Method get" + parentTypeName + " wasn't found for class " + 
                    anObject.getClass().getName(), e);
        } catch (IllegalAccessException e) {
            throw new ServiceBusInterfaceException("SBUS0000", ServiceBusInterface.technicalFailureMessage, e);
        } catch (IllegalArgumentException e) {
            throw new ServiceBusInterfaceException("SBUS0000", ServiceBusInterface.technicalFailureMessage, e);
        } catch (InvocationTargetException e) {
            throw new ServiceBusInterfaceException("SBUS0000", ServiceBusInterface.technicalFailureMessage, e);
        } catch (InstantiationException e) {
            throw new ServiceBusInterfaceException("SBUS0000", ServiceBusInterface.technicalFailureMessage, e);
        }
    }

    private XMLGregorianCalendar formatDate(String dateAsString) throws ServiceBusInterfaceException {
        Date date = null;
        try {
            date = dateFormat.parse(dateAsString);
        } catch (ParseException e) {
            throw new ServiceBusInterfaceException("SBUS0002", "Invalid date format. The date string '" + dateAsString +
                    "' doesn't match the expected format ('" + dateFormat + "')", e);
        }
        GregorianCalendar calendar = new GregorianCalendar();
        calendar.setTime(date);
        return new XMLGregorianCalendarImpl(calendar);
    }
    
    public void execute(int jmsPriority,boolean serializeOnly) {
        try {
            // dump service to log file
            String dumpServiceString = "Processing " + ((!request.isCallSynch()) ? "a" : "") + 
                "synchronous service request for service " + request.getPackageName() + "." + 
                request.getServiceName() + " with the following parameters:\nRequestId: " + request.getRequestId();
            for (String parameterName : request.getParameters().keySet())
                dumpServiceString += "\n" + parameterName + ": " + request.getParameters().get(parameterName); 
            
            logger.debug(dumpServiceString);
            
  			String blockServiceDetail = ClientConfig.getSetting("CcmServiceBusInterface.BlockService."+request.getServiceName() );
			String blockService = ClientConfig.getSetting("CcmServiceBusInterface.BlockService");
			if(!blockService.equals("Y") && !blockServiceDetail.equals("Y"))
                invokeService(messageSender, jmsPriority,serializeOnly);
			
        } catch (Throwable e) {
            request.setThrowable(e);
        }
    }

    /*
    public void execute(MessageSender queueHandler) {
    	execute (CcmServiceBusInterface.defaultJmsPriority);
    }
    */
    
    /**
     * @param queueHandler
     * @throws ServiceBusInterfaceException
     */
    private void invokeService(MessageSender queueHandler, int jmsPriority,boolean serializeOnly) throws ServiceBusInterfaceException {
        try {
            Object outXml = null;
            Object inputObject;
            Object serviceObject;
            Object objectFactoryObject;

            serverResponse = null;
            // create service and input objects
            inputObject = instantiateObjectByName(request.getPackageName() + "."
                    + request.getServiceName() + "Input");
            serviceObject = instantiateObjectByName(request.getPackageName() + "."
                    + request.getServiceName() + "Service");
            
            // get object factory from a different package in some cases
            String objectFactoryPackageName = request.getPackageName();
            try {
            	objectFactoryPackageName = ClientConfig.getSetting("CcmServiceBusInterface.ObjectFactoryPackage." + 
            			request.getServiceName());
            } catch (FIFException e) {}
            objectFactoryObject = instantiateObjectByName(objectFactoryPackageName + ".ObjectFactory");
            
            // populate parameters on the input
            for (String parameterName : request.getParameters().keySet())
                invokeMethod(inputObject, "set", parameterName,
                        request.getParameters().get(parameterName), (String) null);
                
            invokeMethod(serviceObject, "set", request.getServiceName() + "Input", inputObject, (String) null);
            
            // set the service version depending on the service name
            invokeMethod(serviceObject, "", "setVersion", getServiceVersion(request.getServiceName()), (String) null);
            outXml = invokeMethod(objectFactoryObject, "", "create"
                    + request.getServiceName() + "Service", serviceObject, request.getServiceName()
                    + "Service");
                 			
					
            ApplicationContext ctx = ServiceBusInterface.getCtx();
            registry = (ServiceRegistrySender) ctx.getBean("serviceRegistrySender");
               
			String serviceNameToFind = request.getServiceName().substring(0,1).toLowerCase() + request.getServiceName().substring(1);
            ServiceConfig serviceConfig = registry.getService(serviceNameToFind +"Service,"+getServiceVersion(request.getServiceName()));
  

            ServiceRequestJaxb serviceRequest = new ServiceRequestJaxb((JAXBElement)outXml, (ServiceConfigXml) serviceConfig);
       
            serviceRequest.setPriority(jmsPriority);             
            
            //Serialization for validation
            if(serializeOnly){
			  try {            	  
                String schemaName = serviceRequest.getSchema();               
			    String packageName = request.getPackageName();
				if (ctx == null)
					throw new MCFException("Application context has not been initialized.");
				XmlProcessor xmlProcessor = (XmlProcessor) ctx.getBean("mcf2XmlProcessor");				
				String returnXml = xmlProcessor.serialize((JAXBElement<?>) outXml,schemaName,packageName);
	            //System.out.println("XML:"+returnXml);
			  } catch (Throwable e) {
				e.printStackTrace();
				throw new Exception(e);
			  }
            }
        
            if(request != null)
                serviceRequest.setCorrelationID(request.getRequestId());
           
            // synchronous calls
            if (request.isCallSynch()) {
            	long timeoutInMillis = getSynchTimeout(request.getServiceName());
                logger.info("Sending synchronous request (Id: " + 
                        request.getRequestId() + "). Waiting for reply ("+ timeoutInMillis + " ms)...");
                // call MCF to request service and wait for the answer
                //ServiceResponse<JAXBElement<?>> answer = queueHandler.sendSyncRequest(serviceRequest);
             
                ServiceResponse<JAXBElement<?>> answer = queueHandler.sendSyncRequest(serviceRequest, timeoutInMillis);
                if(answer !=null)
//                   serverResponse = answer.getPayload().getValue().toString();
            	  {
                     TextMessage message = (TextMessage)answer.getIncomingMessage();
            	      serverResponse = message.getText();
                 }
                
                
                // if MCF returned an object, there is an answer to the request 
                if (serverResponse != null) {
                    //queueHandler.commit();
                    if (serverResponse.contains("FatalServiceResponse")) {
                        String fatalMsg = getStringBetweenTags(serverResponse,"textFatalService>","<");
                        if (fatalMsg != null)
                            throw new ServiceBusInterfaceException(
                                    "SBUS0006", "Fatal service response received for request (Id: " +
                                    request.getRequestId() + ") with following message: " + 
                                    fatalMsg, null);
                        else 
                            throw new ServiceBusInterfaceException(
                                    "SBUS0007", "Illegal format of fatal service response.", null);
                    }
                    else { 
		    	String subs = getStringBetweenTags(serverResponse,"result>","<");                      
                        if (subs!=null && subs.equals("false")) {
                            throw new ServiceBusInterfaceException(
                                    getStringBetweenTags(serverResponse,"errorCode>","<"), 
                                    getStringBetweenTags(serverResponse,"errorText>","<"), null);
                        }
                    }
                } 
                // otherwise we got an timeout, log an error then
                else {
                    throw new ServiceBusInterfaceException("SBUS0001", "Request timed out after " + 
                            getSynchTimeout(request.getServiceName()) + " milliseconds.", null);
                }
            } else if( !serializeOnly ) {
                String messageID;
             
                messageID = queueHandler.sendAsyncRequest(serviceRequest);
           
  
                logger.info("CcmServiceBusInterface sent message with message ID: " + messageID + " with priority " + serviceRequest.getPriority());
            }
//        } catch (JMSException e) {
//            throw new ServiceBusInterfaceException("SBUS0000", CcmServiceBusInterface.technicalFailureMessage, e);
//        } catch (JAXBException e) {
//        	Throwable linkedException = e.getLinkedException();
//        	if (linkedException != null)
//        		throw new ServiceBusInterfaceException("SBUS0016", "JAXB Error while processing request: " + linkedException.getMessage(), linkedException);
//        	else
//        		throw new ServiceBusInterfaceException("SBUS0016", "JAXB Error while processing request: " + e.getMessage(), e);
//        } catch (SAXException e) {
//        	Exception originalException = e.getException();
//            throw new ServiceBusInterfaceException("SBUS0015", 
//            		"Error while parsing request, see details: ", 
//            		(originalException == null) ? e : originalException);
        } catch (FatalServiceResponseException e) {
                // Erwartet
        	 ServiceResponse<JAXBElement<?>> answer = e.getFatalServiceResponse();
        	 e.printStackTrace();
        	 throw new ServiceBusInterfaceException("SBUS0022", "Fatal service response exception:"+e.getMessage(), e);               
        } catch (TimeoutException e) {
        	e.printStackTrace();
            throw new ServiceBusInterfaceException("SBUS0020", "Timeout exception:"+e.getMessage(), e);   
        } catch (MCFException e) {
        	e.printStackTrace();
            throw new ServiceBusInterfaceException("SBUS0021", "MCF exception:"+e.getMessage(), e);
        } catch (ServiceBusInterfaceException e) {
        	e.printStackTrace();
            throw e;
        } catch (Exception e) {
        	e.printStackTrace();
        	StringWriter sw = new StringWriter();
            PrintWriter pw = new PrintWriter(sw);
            e.printStackTrace(pw);
          

        	throw new ServiceBusInterfaceException("SBUS0000", ServiceBusInterface.technicalFailureMessage+e.getMessage()+"  "+sw.toString(), e);
        }
    }

    /**
     * @return
     */
    private String getServiceVersion(String serviceName) throws ServiceBusInterfaceException {
        // TODO might be better to have it on the caller's side
        String serviceVersion = "001";        
        try {
            serviceVersion = ClientConfig.getSetting("CcmServiceBusInterface.ServiceVersion." + serviceName);
        } catch (FIFException e) {}
        return serviceVersion;
    }

    // TODO whats this?
   /* 
    protected void commit(Session session) throws JMSException {
        if (transactionStatus != null) transactionManager.commit(transactionStatus);
        session.commit();
        transactionStatus = null;
    }

    protected void commitSessionOnly(Session session) throws JMSException {
        if (transactionStatus != null) transactionManager.rollback(transactionStatus);
        session.commit();
        transactionStatus = null;
    }

    protected void rollback (Session session) throws JMSException {
        if (transactionStatus != null) transactionManager.rollback(transactionStatus);
        session.rollback();
        transactionStatus = null;
    }    
*/
    public static int getSynchTimeout(String serviceName) throws ServiceBusInterfaceException {
        int synchTimeout = defaultSynchTimeout;        
        try {
            synchTimeout = ClientConfig.getInt("CcmServiceBusInterface.SynchTimeout." + serviceName);
        } catch (FIFException e) {}
        return synchTimeout;
    }

    public static void setDefaultSynchTimeout(int defaultSynchTimeout) {
        ServiceBusRequestInvoker.defaultSynchTimeout = defaultSynchTimeout;
    }

    public static SimpleDateFormat getDateFormat() {
        return dateFormat;
    }

    public static void setDateFormat(SimpleDateFormat dateFormat) {
        ServiceBusRequestInvoker.dateFormat = dateFormat;
    }

    public String getServerResponse() {
        return serverResponse;
    }

    public void setServerResponse(String serverResponse) {
        this.serverResponse = serverResponse;
    }

    private String getStringBetweenTags(String sourceString,String startTag,String endTag) {
        int startIndex = sourceString.indexOf(startTag)+startTag.length();
        int endIndex = sourceString.indexOf(endTag,startIndex);
        if (startIndex < 0 || endIndex < 0)
            return null;
        return sourceString.substring(startIndex,endIndex);
    }
	public ServiceBusRequest getRequest() {
		return request;
	}
	public void setRequest(ServiceBusRequest request) {
		this.request = request;
	}
	
	
	 public void checkSoapSendOneway_ok(ServiceRequestSoap serviceRequest) {
	        // use magic value to signal the service to return nothing	      

	        messageSender.sendOnewaySoapRequest(serviceRequest);
	    }
	
	 <TREQ, TRES> ServiceResponse<TRES> doSendSync(ServiceRequestSoap<TREQ> serviceRequest) throws TimeoutException{
	     
	        	
	            ServiceResponse<TRES> answer = messageSender.sendSyncSoapRequest(serviceRequest, 10000L * 1);


	            return answer;

	       
	    }

	 public <T> ServiceResponse<T> executeSoap(String serviceName,String callSynch,ServiceRequestSoap serviceRequest,Map<String,String> parameters)throws ServiceBusInterfaceException {
		    ServiceResponse<T> serviceResponse = null;  
		    try {
	            // dump service to log file
	        	
	            String dumpServiceString = "Processing " + ((!callSynch.equals("Y")) ? "a" : "") + 
	                "synchronous service request for service " + serviceRequest.getJavaPackage() + "." + 
	                serviceName + " with the following parameters:\nRequestId: " + serviceRequest.getCorrelationID();
	            
	            for (String parameterName : parameters.keySet())
	                dumpServiceString += "\n" + parameterName + ": " + parameters.get(parameterName); 
	           	            
	            logger.debug(dumpServiceString);
	           
	            for (String parameterName : parameters.keySet()){
	                //System.out.println(parameterName + " "+parameters.get(parameterName));
	            	invokeMethod(serviceRequest.getPayload(), "set", parameterName,
	                		parameters.get(parameterName), (String) null);
	            }
	            
	            try{
	                String priority = ClientConfig.getSetting("CcmServiceBusInterface.JmsPriority."+serviceName);
	                if(priority!=null && !priority.equals("") ){
	                	int intPriority = Integer.parseInt(priority);
	                	serviceRequest.setPriority(intPriority);
	                }
	            }catch  (Exception e){
                	
                }
	               
	                
	                
	                
					String blockServiceDetail = ClientConfig.getSetting("CcmServiceBusInterface.BlockService."+serviceName );
					String blockService = ClientConfig.getSetting("CcmServiceBusInterface.BlockService");					
					if(!blockService.equals("Y") && !blockServiceDetail.equals("Y"))
						if(callSynch.equals("Y")){
							serviceResponse = doSendSync(serviceRequest);							
						}else{
							checkSoapSendOneway_ok(serviceRequest);							
						}
						
	        } catch (ServiceBusInterfaceException e) {
	        	e.printStackTrace();
	            throw e;
	        } catch (FIFException e1) {
	        	e1.printStackTrace();
	        	throw new ServiceBusInterfaceException("SBUS0000", ServiceBusInterface.technicalFailureMessage, e1);
	        }  catch (TimeoutException ex) {
	        	//fail("Timeout: response expected");
	        	throw new ServiceBusInterfaceException("SBUS0001", "Request timed out after " + 
	                    "1000" + " milliseconds.", null);	         
	        } catch(Throwable e){
	        	e.printStackTrace();
	        	throw new ServiceBusInterfaceException("SBUS0024", "Problem in the message sender:"+e.getMessage(), e);
	        }
			return serviceResponse;	        
	    }
	   
	 
}




