/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/HttpSoapServiceImpl.java-arc   1.1   Jun 10 2015 13:29:58   schwarje  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/HttpSoapServiceImpl.java-arc  $
 * 
 *    Rev 1.1   Jun 10 2015 13:29:58   schwarje
 * PPM-95514: small changes
 * 
 *    Rev 1.0   May 26 2015 07:20:36   schwarje
 * Initial revision.
*/
package net.arcor.fif.servicehandler;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;

import javax.xml.XMLConstants;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.bind.Unmarshaller;
import javax.xml.soap.MessageFactory;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPConstants;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPMessage;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import net.arcor.fif.common.FIFErrorLiterals;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FIFTechnicalException;
import net.arcor.fif.common.FifHttpServiceHandler;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.xml.sax.SAXException;

abstract public class HttpSoapServiceImpl extends SoapServiceImpl implements FifHttpServiceHandler {

	protected static final SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");
	
    final static Log logger = LogFactory.getLog(HttpSoapServiceImpl.class);
	protected static JAXBContext jbContext=null;
	protected static Schema schema = null; 
	protected static String context = null;
	protected static String schemaName = null;
	protected static String soapAction = null;
	private static SchemaFactory schemaFactory = null;
	private static Marshaller marshaller = null;
	private static Unmarshaller unmarshaller = null;
	private static Unmarshaller baseTypesUnmarshaller = null;

    public HttpSoapServiceImpl() throws JAXBException, SAXException {
    	super();
		ClassLoader classLoader = this.getClass().getClassLoader();
    	if (jbContext == null)
    		jbContext=JAXBContext.newInstance(context);
    	if (schemaFactory == null)
    		schemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
    	if (schema == null)
     		schema = schemaFactory.newSchema(classLoader.getResource(schemaName));
    	if (marshaller == null) {
    		marshaller = jbContext.createMarshaller();
    		marshaller.setSchema(schema); 
    		marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
    		marshaller.setProperty(Marshaller.JAXB_ENCODING, "UTF-8");    		
    	}
    	if (unmarshaller == null) {
			unmarshaller = jbContext.createUnmarshaller();
			unmarshaller.setSchema(schema);
    	}
    	if (baseTypesUnmarshaller == null) {
			Schema baseTypesSchema = schemaFactory.newSchema(classLoader.getResource("schema/BaseTypes-ESB-001.xsd"));
			JAXBContext baseTypesUnmarshallerContext = JAXBContext.newInstance("de.vodafone.esb.schema.common.basetypes_esb_001");
			baseTypesUnmarshaller = baseTypesUnmarshallerContext.createUnmarshaller();
			baseTypesUnmarshaller.setSchema(baseTypesSchema);
    	}
    }
	
	public String getSoapAction() {
		return soapAction;
	}
	
	/**
	 * serializes the output object to XML
	 * @param output
	 * @return
	 * @throws SOAPException
	 * @throws JAXBException
	 * @throws IOException
	 */
	private String serialize(Object output) throws SOAPException, JAXBException, IOException {
		SOAPMessage mes = MessageFactory.newInstance(SOAPConstants.SOAP_1_2_PROTOCOL).createMessage();
		SOAPBody body = mes.getSOAPBody();
		marshaller.marshal(output, body);
        mes.saveChanges();
        mes.setProperty(SOAPMessage.WRITE_XML_DECLARATION, "true");
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		mes.writeTo(out);
		return new String(out.toByteArray(),"UTF-8");
	}
		
    /* (non-Javadoc)
     * @see net.arcor.fif.common.FifHttpServiceHandler#execute(java.lang.String)
     */
    public String execute(SOAPMessage message) throws FIFException {
     	String outputXml=null;
    	Object request;
		Object output = null;

		// get Java objects from the XML input
		try {
			logger.debug("Deserializing input.");
			request = unmarshaller.unmarshal(message.getSOAPBody().extractContentAsDocument());
		} catch (Exception e) {
			throw new FIFTechnicalException(FIFErrorLiterals.FIF0033, "Exception occured during deserialization. See details: " + e.getMessage(), e);
		}
    	
		// execute in backend
		try {
			logger.debug("Executing service in backend.");
			output = executeService(request);
		} catch (FIFException e) {
			if (e.getErrorCode() != null)
				throw e;
			else {
				Throwable attachedException = (e.getCause() != null) ? e.getCause() : e;
				throw new FIFTechnicalException(FIFErrorLiterals.FIF0031, "Unknown exception raised: " + attachedException.getMessage());
			}
		}

		// generate output message
		try {
			logger.debug("Serializing output.");
			outputXml = serialize(output);
		} catch (Exception e) {
			throw new FIFTechnicalException(FIFErrorLiterals.FIF0034, "Exception occured during serialization. See details: " + e.getMessage(), e);
		}
    	
    	return outputXml;
    }

    abstract protected Object executeService(Object request) throws FIFException;
	
}
