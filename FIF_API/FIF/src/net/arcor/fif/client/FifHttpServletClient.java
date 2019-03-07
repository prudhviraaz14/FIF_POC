/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/FifHttpServletClient.java-arc   1.2   Jul 17 2015 10:06:20   schwarje  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/FifHttpServletClient.java-arc  $
 * 
 *    Rev 1.2   Jul 17 2015 10:06:20   schwarje
 * PPM-95514: remove quotes from SOAP action
 * 
 *    Rev 1.1   Jul 16 2015 11:33:48   schwarje
 * PPM-95514: changed way of parsing request to work around a TIBCO bug
 * 
 *    Rev 1.0   Jun 10 2015 13:23:46   schwarje
 * Initial revision.
*/
package net.arcor.fif.client;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.Locale;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.XMLConstants;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.bind.PropertyException;
import javax.xml.bind.Unmarshaller;
import javax.xml.soap.Detail;
import javax.xml.soap.MessageFactory;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPConstants;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPFault;
import javax.xml.soap.SOAPMessage;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import net.arcor.fif.common.FIFErrorLiterals;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FIFFunctionalException;
import net.arcor.fif.common.FIFTechnicalException;
import net.arcor.fif.common.FifHttpServiceHandler;
import net.arcor.fif.common.FifHttpServiceRegistry;

import org.apache.log4j.Logger;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.vodafone.mcf2.ws.tools.NamespacePrefixMapperImpl;

import de.vodafone.esb.schema.common.basetypes_esb_001.AppMonDetailsType;
import de.vodafone.esb.schema.common.basetypes_esb_001.ErrorDetailsType;
import de.vodafone.esb.schema.common.basetypes_esb_001.FunctionalESBException;
import de.vodafone.esb.schema.common.basetypes_esb_001.TechnicalESBException;

public final class FifHttpServletClient extends FifServletClient {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private static MessageFactory factory = null; 
	private static Marshaller marshaller = null;
	private static Unmarshaller unmarshaller = null;
	private static de.vodafone.esb.schema.common.basetypes_esb_001.ObjectFactory of = null;
	/**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(FifHttpServletClient.class);


    /*---------*
     * METHODS *
     *---------*/
    /**
     * Starts the <code>EaiClient</code>. Initializes marshallers and unmarshallers
     * @param args  the command-line arguments.
     */
    public void init() {
    	super.init();
    	
    	try {
			if (factory == null)
				factory = MessageFactory.newInstance(SOAPConstants.SOAP_1_2_PROTOCOL);
			
			if (marshaller == null || unmarshaller == null) {
				SchemaFactory schemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
				Schema baseTypesSchema = schemaFactory.newSchema(this.getClass().getClassLoader().getResource("schema/BaseTypes-ESB-001.xsd"));
				JAXBContext baseTypesContext = JAXBContext.newInstance("de.vodafone.esb.schema.common.basetypes_esb_001");
			    marshaller = baseTypesContext.createMarshaller();
				marshaller.setSchema(baseTypesSchema); 
			    marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE); 
	    		marshaller.setProperty(Marshaller.JAXB_ENCODING, "UTF-8");    		
			    try {
			        marshaller.setProperty("com.sun.xml.bind.namespacePrefixMapper", new NamespacePrefixMapperImpl());
			    }
			    catch (PropertyException e) {}
			    
				unmarshaller = baseTypesContext.createUnmarshaller();
				unmarshaller.setSchema(baseTypesSchema);
			}	    	

			if (of == null)
				of = new de.vodafone.esb.schema.common.basetypes_esb_001.ObjectFactory();
		} catch (Exception e) {
			logger.fatal("Exception during initialization", e);
		}
    
    }
    
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		long startTime = System.currentTimeMillis();
		String input = readInput(req);

		String bpId = "unknown";
		String soapAction = req.getHeader("soapAction");
		logger.debug("SOAP-Action in request: " + soapAction);
		soapAction = soapAction.trim().replaceAll("\"", "");
		
		String contentType = req.getContentType();
		String output = null;

		// get handler from internal registry (filled by configuration file)
		FifHttpServiceHandler aHandler = FifHttpServiceRegistry.getInternalregistry().get(soapAction);
		FIFException exception = null;
		if (aHandler == null)
			exception = new FIFTechnicalException(FIFErrorLiterals.FIF0032, "SOAP-Action " + soapAction + " is not supported by this FIF-Client.");
        else {
        	try {
        		SOAPMessage message = MessageFactory.newInstance(SOAPConstants.SOAP_1_2_PROTOCOL).createMessage(null, new ByteArrayInputStream(input.getBytes()));
        		// extract AppMonDetails, if available, use bpId for logging, ignore the rest
        		AppMonDetailsType appMonDetails = getAppMonDetails(message);
        		if (appMonDetails != null)
        			bpId = appMonDetails.getBpId();
        		logger.info("Processing request for service " + soapAction + ", bpId " + bpId + " started.");

        		// backend processing of the service
        		output = aHandler.execute(message);
     		} catch (FIFException fe) {
     			exception = fe;
	 		} catch (SOAPException se) {
				exception = new FIFTechnicalException(FIFErrorLiterals.FIF0033, "Exception occured during deserialization. See details: " + se.getMessage(), se);
			}
        }
        
        if (exception != null) {
        	if (exception.getDetail() != null)
        		logger.error("Exception raised while processing request " + bpId
        				+ ": ErrorCode: " + exception.getErrorCode()
        				+ ", ErrorMessage: " + exception.getMessage(), exception);
			try {
				// if any error occured, return an error response
				output = generateSoapFault(exception, bpId, soapAction);
			} catch (Exception e1) {
				throw new ServletException(exception);
			}
        }
    	
		resp.setContentType(contentType);
		resp.setCharacterEncoding("UTF-8");
		resp.setContentLength(output.length());
		PrintWriter out = resp.getWriter();
		out.println(output);
		out.close();
		out.flush();
    	
        long endTime = System.currentTimeMillis();
    	logger.info("Processing request for service " + soapAction + ", bpId " + bpId + " completed, duration: " + new Long(endTime - startTime) + " ms");
    }

	private static String readInput(HttpServletRequest req) throws IOException,
			UnsupportedEncodingException {
		String input = "";
		
        String contentType = req.getContentType();
        String[] fields = contentType.split(";");
        String encoding="UTF-8";
        for (int i = 0; i < fields.length; i++) {
        	String field=fields[i].trim();
        	if (field.startsWith("charset")) {
        		String[] charset = field.split("=");
        		if (charset.length>=2) {
        			encoding=charset[1];
        			encoding=encoding.replaceAll("\"", "");
        		}
        	}
		}
		BufferedReader br = new BufferedReader(new InputStreamReader(req.getInputStream(), encoding));		
		
		String line = null;
		while ((line = br.readLine()) != null) {
			input += URLDecoder.decode(line, "UTF-8");
		}
		br.close();
		return input;
	}

    /**
     * generates error response depending on type of error
     * @param fault
     * @return
     * @throws JAXBException
     * @throws SOAPException
     * @throws IOException
     */
    private String generateSoapFault(Exception fault, String bpId, String soapAction) throws JAXBException, SOAPException, IOException{
    	SOAPMessage message = factory.createMessage();

    	SOAPBody body = message.getSOAPBody();
    	SOAPFault soapFault = body.addFault();
        soapFault.setFaultCode(SOAPConstants.SOAP_RECEIVER_FAULT);
        String errorCode=null;
        String errorText=null;
        if (fault instanceof FIFException) {
        	errorCode = ((FIFException)fault).getErrorCode();
            errorText = fault.getMessage();
        } 
        else {
            errorCode = FIFErrorLiterals.FIF0000.name();
            errorText=fault.getMessage();
        }

        logger.warn("Request for service " + soapAction + 
        		", bpId " + bpId + 
        		" failed, errorCode: " + errorCode + 
        		", errorText: " + errorText);
        soapFault.addFaultReasonText(errorCode, Locale.ENGLISH);
        Detail detail = soapFault.addDetail();

        ErrorDetailsType details = new ErrorDetailsType();        
        details.setErrorCode(errorCode);
        details.setErrorMessage(errorText);

        if (fault instanceof FIFFunctionalException){
        	FunctionalESBException functionalESBException = new FunctionalESBException();
        	functionalESBException.setErrorDetails(details);
        	marshaller.marshal(of.createFunctionalESBException(functionalESBException), detail);
        } else {
        	TechnicalESBException technicalESBException = new TechnicalESBException();
        	technicalESBException.setErrorDetails(details);
        	marshaller.marshal(of.createTechnicalESBException(technicalESBException), detail);
        }
        
        message.saveChanges();
        message.setProperty(SOAPMessage.WRITE_XML_DECLARATION, "true");

		ByteArrayOutputStream out = new ByteArrayOutputStream();
        message.writeTo(out);
		return new String(out.toByteArray());
    }

	/**
	 * parses the SOAP header for AppMonDetails
	 * @param requestXml
	 * @return
	 * @throws IOException
	 * @throws SOAPException
	 * @throws JAXBException
	 */
	private static AppMonDetailsType getAppMonDetails(SOAPMessage message) throws FIFException {
		
		try {
		    NodeList nodeList = message.getSOAPHeader().getElementsByTagName("*");
		    for (int i = 0; i < nodeList.getLength(); i++) {
		        Node node = nodeList.item(i);
		        if (node.getNodeType() == Node.ELEMENT_NODE && node.getLocalName().equals("appMonDetails")) {
		        	AppMonDetailsType appMonDetails = ((JAXBElement<AppMonDetailsType>) unmarshaller.unmarshal(node)).getValue();
		        	return appMonDetails;
		        }
		    }
		} catch (Exception e) {
			throw new FIFTechnicalException(FIFErrorLiterals.FIF0035, "Exception occured while serializing SOAP Header", e);
		}
		
		return null;
	}
}
