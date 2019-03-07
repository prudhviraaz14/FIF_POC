/*
 $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/RequestSerializer.java-arc   1.20   Jun 18 2010 17:42:32   schwarje  $

 $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/RequestSerializer.java-arc  $
 * 
 *    Rev 1.20   Jun 18 2010 17:42:32   schwarje
 * changes for CPCOM Phase 2: new FIF client type accepting SOM orders
 * 
 *    Rev 1.19   Jun 01 2010 18:05:32   schwarje
 * IT-26029: updates
 * 
 *    Rev 1.18   Mar 11 2010 13:16:14   schwarje
 * IT-26029: Decomissioning MQReader
 * 
 *    Rev 1.16   Jun 22 2009 18:42:24   schwarje
 * SPN-FIF-000087753: ignore empty request-list-params when populating FIF XML
 * 
 *    Rev 1.15   Jun 04 2009 12:36:56   schwarje
 * SPN-FIF-000087150: propagate request list parameters to each single request
 * 
 *    Rev 1.14   Dec 04 2008 14:52:18   makuier
 * get the manual rollback from fif-param-list.
 * 
 *    Rev 1.13   Nov 07 2008 11:40:42   makuier
 * Handling manual rollback added.
 * 
 *    Rev 1.12   Aug 08 2008 15:49:58   wlazlow
 * IT-21113
 * 
 *    Rev 1.11   Jan 10 2008 17:59:02   lejam
 * Corrected population of OMTSOrderID in serializeRequestList PN-65854
 * 
 *    Rev 1.10   Aug 20 2007 14:49:46   lejam
 * Corrected population of OMTSOrderID from XML message IT-19036
 * 
 *    Rev 1.9   Aug 16 2007 19:23:08   lejam
 * Added support for OMTSOrderId on the request list level IT-19036
 * 
 *    Rev 1.8   Apr 19 2007 17:15:20   schwarje
 * IT-19232: support for transaction lists in database clients
 * 
 *    Rev 1.7   Dec 05 2006 17:16:10   makuier
 * Populate the request list id automatically on all list items
 * IT-16444 
 * 
 *    Rev 1.6   Sep 19 2005 15:24:00   banania
 * Added use of entity resolver for finding dtds.
 * 
 *    Rev 1.5   Aug 02 2004 15:26:22   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.4   Jul 15 2004 12:15:16   goethalo
 * SPN-CCB-000023940: Added code to take care of encoding problems for incoming XML.
 * 
 *    Rev 1.3   Jun 14 2004 15:43:10   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.2   Jul 25 2003 09:15:28   goethalo
 * IT-9750
 * 
 *    Rev 1.1   Jul 16 2003 15:01:20   goethalo
 * Changes for IT-9750
 * 
 *    Rev 1.0   Apr 09 2003 09:34:42   goethalo
 * Initial revision.
 */
package net.arcor.fif.messagecreator;

import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import net.arcor.fif.common.DOMSerializer;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.ParsingErrorHandler;

import org.apache.log4j.Logger;
import org.apache.xerces.dom.DOMImplementationImpl;
import org.apache.xerces.parsers.DOMParser;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.Text;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * Class that serializes Request objects to and from XML format.
 * @author goethalo
 */
public class RequestSerializer {

	/*------------------*
	 * MEMBER VARIABLES *
	 *------------------*/

	/**
	 * The log4j logger.
	 */
	private static Logger logger = Logger.getLogger(RequestSerializer.class);

	/*---------*
	 * METHODS *
	 *---------*/

	/**
	 * Serializes a Request object to an XML DOM Tree.
	 * @param request  the request to be serialized.
	 * @return the generated <code>Document</code> object
	 */
	public static Document serialize(Request request) throws FIFException {
		if (request instanceof FIFRequestList)
			return serializeFIFRequestList((FIFRequestList)request);
		else { 
			// Get the metadata
			ArrayList metadata = MessageCreatorMetaData.getActionMapping(
					request.getAction()).getMessageParams();

			// Create the DOM tree (and include the DTD name)
			DOMImplementation domImpl = new DOMImplementationImpl();
			Document doc = domImpl.createDocument(null, XMLTags.requestRoot,
					domImpl.createDocumentType(XMLTags.requestRoot, null,
							XMLTags.requestDTDName));
			Element root = doc.getDocumentElement();

			// Add the action name to the document
			addElement(doc, root, XMLTags.actionName, request.getAction());

			// Add the request params tag to the document and make
			// the new Element to root node
			root = addElement(doc, root, XMLTags.requestParams, null);

			// Loop through the metadata
			for (int i = 0; i < metadata.size(); i++) {
				ParameterMetaData pmd = (ParameterMetaData) metadata.get(i);
				// Get the corresponding parameter
				Parameter param = request.getParam(pmd.getName());

				// Add the parameter to the root node
				addParameter(doc, root, pmd, param);
			}

			// Return the document
			return doc;
		}
	}

	private static Document serializeFIFRequestList(FIFRequestList list) throws FIFException {
		// Create the DOM tree (and include the DTD name)
		DOMImplementation domImpl = new DOMImplementationImpl();
		
		Document doc = domImpl.createDocument(null, XMLTags.requestListRoot,
				domImpl.createDocumentType(XMLTags.requestListRoot, null,
						"request-list.dtd"));
		Element root = doc.getDocumentElement();
		// Add the action name to the document
		addElement(doc, root, "request-list-name", list.getName());
		addElement(doc, root, "request-list-id", list.getID());
		if (list.getOMTSOrderID() != null)
			addElement(doc, root, "OMTSOrderID", list.getOMTSOrderID());
		if (list.getHeaderList() != null) {
			Element listParameterRoot = addElement(doc, root, "request-list-params", null);
			for (SimpleParameter sp : list.getHeaderList()) {
				Element element = doc.createElement("request-list-param");
				element.setAttribute(XMLTags.requestParamName, sp.getName());
				if (sp.getValue() != null) {
					Text text = doc.createCDATASection(sp.getValue());
					element.appendChild(text);
				}
				listParameterRoot.appendChild(element);
			}
		}
		Element requestsRoot = addElement(doc, root, "requests", null);
		for (Object fifRequestObject : list.getRequests()) {
			FIFRequest fifRequest = (FIFRequest) fifRequestObject;
			ArrayList metadata = MessageCreatorMetaData.getActionMapping(fifRequest.getAction()).getMessageParams();
			Element requestRoot = addElement(doc, requestsRoot, XMLTags.requestRoot, null);
			addElement(doc, requestRoot, XMLTags.actionName, fifRequest.getAction());
			Element paramsRoot = addElement(doc, requestRoot, XMLTags.requestParams, null);
			for (int i = 0; i < metadata.size(); i++) {
				ParameterMetaData pmd = (ParameterMetaData) metadata.get(i);
				Parameter param = fifRequest.getParam(pmd.getName());
				addParameter(doc, paramsRoot, pmd, param);
			}
		}
		return doc;
	}

	/**
	 * Creates a request object based on the contents of an XML DOM Tree.
	 * @param doc            the XML document to construct the request from
	 * @param returnInvalid  indicates whether an invalid request should be returned in an
	 *                       <code>InvalidRequest</code> object.  If this is set to false an
	 *                       exception is thrown when the request is invalid.
	 * @return the created <code>Request</code> object
	 * @throws FIFException if the request is invalid and <code>returnInvalid</code> 
	 *         is set to <code>false</code>.
	 */
	public static Request serialize(Document doc, boolean returnInvalid)
			throws FIFException {
		// Get the root element of the document
		Element root = doc.getDocumentElement();

		// Determine the request type
		logger.debug("Root tagname is: " + root.getTagName());
		if (root.getTagName().equals(XMLTags.requestRoot)) {
			return (serializeRequest(root, returnInvalid));
		} else if (root.getTagName().equals(XMLTags.requestListRoot)) {
			return (serializeRequestList(root, returnInvalid));
		} else {
			String error = "Cannot convert XML document to Request "
					+ "object: the document does not represent "
					+ "a Request object.  The document root should be "
					+ "<request> or <request-list>.";
			if (returnInvalid) {
				Request request = new InvalidRequest();
				((InvalidRequest) request).setError(new FIFError("FIF-API",
						error));
				logger.error(error);
				return request;
			} else {
				throw new FIFException(error);
			}
		}
	}

	/**
	 * Creates a request object based on the contents of an XML file.
	 * @param fileName  the name of the XML file to construct the request from
	 * @param returnInvalid  indicates whether an invalid request should be returned in an
	 *                       <code>InvalidRequest</code> object.  If this is set to false an
	 *                       exception is thrown when the request is invalid.
	 * @return the created <code>Request</code> object
	 */
	public static Request serializeFromFile(String fileName,
			boolean returnInvalid) throws FIFException {
		// Create a DOM parser
		DOMParser parser = new DOMParser();

		// Parse the XML metadata file with DTD validation
		try {
			ParsingErrorHandler handler = new ParsingErrorHandler();
			parser.setFeature("http://xml.org/sax/features/validation", true);
			parser.setErrorHandler(handler);
			parser.setEntityResolver(new EntityResolver());
			parser.parse(fileName);

			if (handler.isError()) {
				if (returnInvalid) {
					InvalidRequest request = new InvalidRequest();
					request.setError(new FIFError("FIF-API", handler
							.getErrors()));
					logger
							.error("Errors while parsing: "
									+ handler.getErrors());
					return request;
				} else {
					throw new FIFException(
							"XML parser reported the following errors:\n"
									+ handler.getErrors());
				}
			} else if (handler.isWarning()) {
				logger.warn("XML parser reported warnings:\n"
						+ handler.getWarnings());
			}
		} catch (SAXException e) {
			if (returnInvalid) {
				InvalidRequest request = new InvalidRequest();
				request.setError(new FIFError("FIF-API", "Cannot parse file "
						+ fileName + ". " + e.getMessage()));
				logger.error("Exception while parsing.", e);
				return request;
			} else {
				throw new FIFException("Cannot parse file " + fileName, e);
			}
		} catch (IOException e) {
			if (returnInvalid) {
				InvalidRequest request = new InvalidRequest();
				request.setError(new FIFError("FIF-API", "Cannot parse file "
						+ fileName + ". " + e.getMessage()));
				logger.error("Exception while parsing.", e);
				return request;
			} else {
				throw new FIFException("Cannot parse file " + fileName, e);
			}
		}

		// Get the document
		Document doc = parser.getDocument();

		// Serialize the document
		return (serialize(doc, returnInvalid));
	}

	/**
	 * Creates a request object based on the contents of a String.
	 * The string should contain an XML request.
	 * @param request  		     the string containing the XML request.
	 * @param beautifiedRequest	 StringBuffer to contain the original request in unified 
	 * 							 encoding and format.   Pass in null if the request should
	 * 							 not be beautified.
	 * @param returnInvalid  	 indicates whether an invalid request should be returned in an
	 *                       	 <code>InvalidRequest</code> object.  If this is set to false an
	 *                       	 exception is thrown when the request is invalid. 
	 * @return the created <code>Request</code> object
	 */
	public static Request serializeFromString(String request,
			StringBuffer beautifiedRequest, boolean returnInvalid)
			throws FIFException {
		// Create a DOM parser
		DOMParser parser = new DOMParser();

		// Parse the XML metadata file with DTD validation
		try {
			ParsingErrorHandler handler = new ParsingErrorHandler();
			parser.setFeature("http://xml.org/sax/features/validation", true);
			parser.setErrorHandler(handler);
            parser.setEntityResolver(new EntityResolver());			
			parser.parse(new InputSource(new StringReader(request)));

			if (handler.isError()) {
				if (returnInvalid) {
					if (request.indexOf("<" + XMLTags.requestListRoot + ">") != -1) {
						InvalidRequestList list = new InvalidRequestList();
						list.setError(new FIFError("FIF-API",
								"Errors while parsing request: "
										+ handler.getErrors()));
						extractListIDs(request, list);
						logger.error("Errors while parsing request: "
								+ handler.getErrors());
						return list;
					} else {
						InvalidRequest req = new InvalidRequest();
						req.setError(new FIFError("FIF-API",
								"Errors while parsing request: "
										+ handler.getErrors()));
						extractRequestIDs(request, req);
						logger.error("Errors while parsing request: "
								+ handler.getErrors());
						return req;
					}

				} else {
					throw new FIFException(
							"XML parser reported the following errors:\n"
									+ handler.getErrors());
				}
			} else if (handler.isWarning()) {
				logger.warn("XML parser reported warnings:\n"
						+ handler.getWarnings());
			}
		} catch (SAXException e) {
			if (returnInvalid) {
				InvalidRequest req = new InvalidRequest();
				req.setError(new FIFError("FIF-API", "Cannot parse request: "
						+ e.getMessage()));
				extractRequestIDs(request, req);
				logger.error("Exception while parsing.", e);
				return req;
			} else {
				throw new FIFException(
						"Cannot parse request string " + request, e);
			}
		} catch (IOException e) {
			if (returnInvalid) {
				InvalidRequest req = new InvalidRequest();
				req.setError(new FIFError("FIF-API", "Cannot parse request: "
						+ e.getMessage()));
				extractRequestIDs(request, req);
				logger.error("Exception while parsing.", e);
				return req;
			} else {
				throw new FIFException(
						"Cannot parse request string " + request, e);
			}
		}

		// Get the document
		Document doc = parser.getDocument();

		// Beautify the original request
		if (beautifiedRequest != null) {
			DOMSerializer serializer = new DOMSerializer();
			StringWriter writer = new StringWriter();
			try {
				serializer.serialize(doc, writer, true);
				beautifiedRequest.append(writer.toString());
			} catch (Exception e) {
				logger.warn("Cannot beautify original request.", e);
			}
		}

		// Serialize the document
		return (serialize(doc, returnInvalid));
	}

	/**
	 * Extracts the IDs for a request.  This method attempts to extract the IDs
	 * of a request if parsing the ID failed.
	 * @param request  the request message text
	 * @param req      the invalid request to set the IDs on.
	 */
	private static void extractRequestIDs(String request, InvalidRequest req) {
		try {
			req.setAction(extractTagContents(XMLTags.actionName, request));
			if (request.indexOf("\"transactionID\">") != -1) {
				String transactionID = request.substring(request
						.indexOf("\"transactionID\">")
						+ ("\"transactionID\">").length());
				req.addParam(new SimpleParameter("transactionID",
						extractTagContents(transactionID)));
			}
		} catch (Exception e) {
			logger.warn("Could not extract IDs of request.", e);
		}
	}

	/**
	 * Extracts the IDs for a request list.  This method attempts to extract the IDs
	 * of a request list if parsing the ID failed.
	 * @param request  the request list message text
	 * @param req      the invalid request to set the IDs on.
	 */
	private static void extractListIDs(String request, InvalidRequestList list) {
		try {
			list.setName(extractTagContents(XMLTags.requestListName, request));
			list.setID(extractTagContents(XMLTags.requestListId, request));
		} catch (FIFException fe) {
			logger.warn("Could not extract IDs of list request.", fe);
		}
	}

	/**
	 * Extracts the tag contents for a given string.
	 * This will extract the contents of the first matching tag that is found.
	 * This method is used to try to extract tags when the parsing of the 
	 * XML file failed.
	 * @param tagName  the tag name to get the contents for.
	 * @param xml      the XML string to extract the tag from.
	 * @return the contents.
	 */
	private static String extractTagContents(String tagName, String xml) {
		if (tagName == null) {
			return ("unknown");
		}
		try {
			// Try to find the tag
			tagName = "<" + tagName + ">";
			int index = xml.indexOf(tagName);
			if (index == -1) {
				return ("unknown");
			}
			tagName = xml.substring(index + tagName.length());

			return extractTagContents(tagName);
		} catch (Exception e) {
			logger.warn("Could not extract tag contents for " + tagName, e);
			return ("unknown");
		}
	}

	/**
	 * Extract the embedded contents in a given tag string.
	 * This method will extract the first tag contents found in the 
	 * passed in string.
	 * @param tagStart  the string containing the tag start and its contents.
	 * @return the tag contents.
	 */
	private static String extractTagContents(String tagStart) {
		try {
			// Strip off CDATA section if needed
			if (tagStart.startsWith("<![CDATA[")) {
				tagStart = tagStart.substring(("<![CDATA[").length());
				tagStart = tagStart.substring(0, tagStart.indexOf("]]>"));
			}
			// Get text till end-tag
			if (tagStart.indexOf('<') != -1) {
				tagStart = tagStart.substring(0, tagStart.indexOf('<'));
			}
			return tagStart;
		} catch (Exception e) {
			logger.warn("Could not extract tag in " + tagStart, e);
			return ("unknown");
		}
	}

	/**
	 * Serializes an XML document representing a request to a 
	 * <code>Request</code> object.
	 * @param root           the root of the XML document to serialize.
	 * @param returnInvalid  indicates whether an invalid request should be returned in an
	 *                       <code>InvalidRequest</code> object.  If this is set to false an
	 *                       exception is thrown when the request is invalid.
	 * @return the <code>Request</code> object represented by the XML document
	 * @throws FIFException if the request could not be serialized.
	 */
	private static Request serializeRequest(Element root, boolean returnInvalid)
			throws FIFException {
		Request request = null;

		// Get the action name
		String action = getElementText(root, XMLTags.actionName);

		// Create the request object for the action name
		try {
			request = RequestFactory.createRequest(action);
		} catch (FIFException fe) {
			if (returnInvalid) {
				request = new InvalidRequest();
				request.setAction(action);
				((InvalidRequest) request).setError(new FIFError("FIF-API", fe
						.getMessage()));
			} else {
				throw (fe);
			}
		}

		// Loop through the request parameters
		Element paramList = (Element) root.getElementsByTagName(
				XMLTags.requestParams).item(0);
		NodeList params = paramList.getChildNodes();

		for (int i = 0; i < params.getLength(); i++) {
			Node param = params.item(i);
			if (param.getNodeType() == Node.ELEMENT_NODE) {
				Parameter p = parseParam((Element) param);
				request.addParam(p);
			}
		}

		return request;
	}

	/**
	 * Serializes an XML document representing a request list to a 
	 * <code>Request</code> object.
	 * @param root           the root of the XML document to serialize.
	 * @param returnInvalid  indicates whether an invalid request should be returned in an
	 *                       <code>InvalidRequest</code> object.  If this is set to false an
	 *                       exception is thrown when the request is invalid.
	 * @return the <code>Request</code> object represented by the XML document
	 * @throws FIFException if the request could not be serialized.
	 */
	private static Request serializeRequestList(Element root,
			boolean returnInvalid) throws FIFException {
		// Populate the request list attributes
		boolean valid = true;
		FIFRequestList requestList = new FIFRequestList();
		requestList.setID(getElementText(root, XMLTags.requestListId));
		requestList.setName(getElementText(root, XMLTags.requestListName));

		String OMTSOrderID = getElementText(root, XMLTags.requestListOMTSOrderId);
		if(OMTSOrderID!=null && OMTSOrderID.length()>0)
			requestList.setOMTSOrderID(getElementText(root, XMLTags.requestListOMTSOrderId));

		List<SimpleParameter> hList =  new ArrayList<SimpleParameter>();
		// Loop through the header List parameters
		Element headerList = (Element) root.getElementsByTagName(
				XMLTags.requestListParams).item(0);
	
	    if(headerList != null){
		   NodeList listParams = headerList.getChildNodes();

		   for (int j = 0; j < listParams.getLength(); j++) {
			  Node param = listParams.item(j);				  
			  if(param.getNodeType() == Node.ELEMENT_NODE){				  
			     if (((Element)param).getTagName().equals(XMLTags.requestListParam)) {
				    String name = ((Element)param).getAttribute(XMLTags.requestParamName);
				    String value = getElementText((Element)param);
					if(name.equals(XMLTags.requestListManualRollback))
						requestList.setManualRollback(value);

			        hList.add(new SimpleParameter(name, value));
		         }
			  }
		   }
	    }
		if(hList != null && hList.size() != 0)
			requestList.setHeaderList(hList);
		
		// Loop through the embedded requests
		NodeList requests = root.getElementsByTagName(XMLTags.requestRoot);
		for (int i = 0; i < requests.getLength(); i++) {
			Element requestRoot = (Element) requests.item(i);
			Request request = serializeRequest(requestRoot, true);
			SimpleParameter sp = new SimpleParameter("requestListId",requestList.getID());
			request.addParam(sp);
			sp = new SimpleParameter("manualRollback",requestList.getManualRollback());
			request.addParam(sp);
			if (request instanceof InvalidRequest) {
				valid = false;
			}
			requestList.addRequest((FIFRequest) request);
		}
        requestList.sort();
		
		if (!valid) {
			InvalidRequestList invalidRequestList = new InvalidRequestList();
			invalidRequestList.setID(requestList.getID());
			invalidRequestList.setName(requestList.getName());
			OMTSOrderID = requestList.getOMTSOrderID();
			if(OMTSOrderID!=null && OMTSOrderID.length()>0)
				invalidRequestList.setOMTSOrderID(OMTSOrderID);
			hList = requestList.getHeaderList();
			if(hList!= null && hList.size()!=0)
			    invalidRequestList.setHeaderList(hList);
			invalidRequestList.setRequests(requestList.getRequests());
			invalidRequestList.setError(new FIFError("FIF-API",
					"Errors while processing requests in the list."));
			return invalidRequestList;
		}

		return requestList;
	}

	/**
	 * Adds a parameter(list) to the document.
	 * @param doc     the document to add the parameter to.
	 * @param parent  the parent node to add the parameter to.
	 * @param pmd     the metadata of the parameter.
	 * @param param   the parameter to add to the document.
	 * @throws FIFException
	 */
	private static void addParameter(Document doc, Element parent,
			ParameterMetaData pmd, Parameter param) throws FIFException {
		if (param == null)
			return;
		if (pmd instanceof SimpleParameterMetaData) {
			// Add the simple parameter to the parent
			SimpleParameter sp = (SimpleParameter) param;
			addParamElement(doc, parent, sp.getName(), sp.getValue());
		} else if (pmd instanceof ParameterListMetaData) {
			// Add the parameter list to the parent
			ParameterListMetaData plmd = (ParameterListMetaData) pmd;
			ParameterList pl = (ParameterList) param;
			if (pl == null) {
				return;
			}
			Element list = addParamListElement(doc, parent, pl.getName());

			// Add the list items to the list node
			ArrayList metadata = plmd.getParamsMetaData();
			for (int items = 0; items < pl.getItemCount(); items++) {
				// Create the list item
				Element item = addParamListItemElement(doc, list);

				// Add the parameters to the list item
				for (int i = 0; i < metadata.size(); i++) {
					// Recursively call ourselves
					ParameterMetaData pm = (ParameterMetaData) metadata.get(i);
					Parameter p = (Parameter) pl.getItem(items).getParam(
							pm.getName());
					addParameter(doc, item, pm, p);
				}
			}
		}
	}

	/**
	 * Adds an element to the document.
	 *
	 * @param doc     the document to add the element to.
	 * @param parent  the parent to add the element to.
	 * @param name    the name of the element to add.
	 * @param value   the text value of the element to add.
	 *                 use null if no text value should be added.
	 * @return the newly added Element
	 */
	private static Element addElement(Document doc, Element parent,
			String name, String value) {
		// Create a new element
		Element element = doc.createElement(name);

		if (value != null) {
			// Create the text
			Text text = doc.createCDATASection(value);

			// Add the text
			element.appendChild(text);
		}

		// Append the element to the parent
		parent.appendChild(element);

		// Return the created element
		return element;
	}

	/**
	 * Adds a request parameter element to the document.
	 *
	 * @param doc     the document to add the element to.
	 * @param parent  the parent to add the element to.
	 * @param name    the name of the element to add.
	 * @param value   the text value of the element to add.
	 *                 use null if no text value should be added.
	 * @return the newly added Element
	 */
	private static Element addParamElement(Document doc, Element parent,
			String name, String value) {
		// Create a new element
		Element element = doc.createElement(XMLTags.requestParam);
		element.setAttribute(XMLTags.requestParamName, name);
		if (value != null) {
			// Create the text
			Text text = doc.createCDATASection(value);

			// Add the text
			element.appendChild(text);
		}

		// Append the element to the parent
		parent.appendChild(element);

		// Return the created element
		return element;
	}

	/**
	 * Adds a request parameter element to the document.
	 *
	 * @param doc     the document to add the element to.
	 * @param parent  the parent to add the element to.
	 * @param name    the name of the element to add.
	 * @param value   the text value of the element to add.
	 *                 use null if no text value should be added.
	 * @return the newly added Element
	 */
	private static Element addListParamElement(Document doc, Element parent,
			String name, String value) {
		// Create a new element
		Element element = doc.createElement(XMLTags.ccmFifParameterValueCont);
		//element.setAttribute(XMLTags.requestParamName, name);
		if (value != null) {
			Element nameElement = doc.createElement(XMLTags.parameterName);
	//		Text nameText = doc.createCDATASection(name);
			Text nameText = doc.createTextNode(name);
	        nameElement.appendChild(nameText);
	        
	        Element valueElement = doc.createElement(XMLTags.parameterValue);
			//Text valueText = doc.createCDATASection(value);
			Text valueText = doc.createTextNode(value);
			valueElement.appendChild(valueText);
	        
	        element.appendChild(nameElement);
	        element.appendChild(valueElement);
		}

		// Append the element to the parent
		parent.appendChild(element);

		// Return the created element
		return element;
	}
	
	
	
	/**
	 * Adds a request parameter list element to the document.
	 *
	 * @param doc     the document to add the element to.
	 * @param parent  the parent to add the element to.
	 * @param name    the name of the element to add.
	 * @return the newly added Element
	 */
	private static Element addParamListElement(Document doc, Element parent,
			String name) {
		// Create a new element
		Element element = doc.createElement(XMLTags.requestParamList);
		element.setAttribute(XMLTags.requestParamListName, name);

		// Append the element to the parent
		parent.appendChild(element);

		// Return the created element
		return element;
	}

	/**
	 * Adds a parameter list item element to the document.
	 *
	 * @param doc     the document to add the element to.
	 * @param parent  the parent list element to add the item element to.
	 * @return the newly added Element
	 */
	private static Element addParamListItemElement(Document doc, Element parent) {
		// Create a new element
		Element element = doc.createElement(XMLTags.requestParamListItem);

		// Append the element to the parent
		parent.appendChild(element);

		// Return the created element
		return element;
	}

	/**
	 * Gets the text contained in an element given the tagname of the element
	 * and the parent element.
	 * @param parent   the parent element
	 * @param tagName  the tag name of the element to take the text for
	 * @return a <code>String</code> containing the element text, null if an
	 * element with the passed in tagname was not found.
	 */
	private static String getElementText(Element parent, String tagName) {
		Element element = (Element) (parent.getElementsByTagName(tagName)
				.item(0));
		if (element == null) {
			return null;
		}
		return (getElementText(element));
	}

	/**
	 * Gets the text contained in an element.
	 *
	 * @param element  the element to take the text from
	 * @return a <code>String</code> containing the text of the element,
	 * null if the element contains no text.
	 */
	private static String getElementText(Element element) {
		if (element == null) {
			return null;
		}
		Node child = element.getFirstChild();
		if (child != null) {
			return (child.getNodeValue());
		} else {
			return null;
		}
	}

	/**
	 * Parses a node to a Parameter object.
	 * @param param   the parameter to parse.
	 * @return the <code>Parameter</code> object created based
	 * on the passed in element.
	 */
	private static Parameter parseParam(Element param) throws FIFException {
		if (param.getTagName().equals(XMLTags.requestParam)) {
			String name = param.getAttribute(XMLTags.requestParamName);
			String value = getElementText(param);
			return new SimpleParameter(name, value);
		} else if (param.getTagName().equals(XMLTags.requestParamList)) {
			String name = param.getAttribute(XMLTags.requestParamListName);
			ParameterList list = new ParameterList(name);

			NodeList listItems = param.getChildNodes();
			for (int items = 0; items < listItems.getLength(); items++) {
				Node item = listItems.item(items);
				if (item.getNodeType() == Node.ELEMENT_NODE) {
					ParameterListItem listItem = new ParameterListItem();
					NodeList params = item.getChildNodes();
					for (int i = 0; i < params.getLength(); i++) {
						Node childParam = params.item(i);
						if (childParam.getNodeType() == Node.ELEMENT_NODE) {
							Parameter p = parseParam((Element) childParam);
							listItem.addParam(p);
						}
					}
					list.addItem(listItem);
				}
			}

			return list;
		} else {
			throw new FIFException("Cannot parse parameter: Unknown parameter "
					+ "type passed in: " + param.getTagName());
		}
	}

	/**
	 * Creates a FIF Transaction List message.
	 * @param transactionListID    the ID of the list to create.
	 * @param transactionListName  the name of the list to create.
	 * @param requestMsgList       the list of the FIF transaction messages 
	 *                             that have to be put in the list.
	 * @return the <code>Message</code> containing the FIF Transaction List
	 * @throws FIFException if the transaction list could not be created.
	 */
	public static Message createFIFTransactionList(String transactionListID, 
			                                       String transactionListName, 
			                                       String transactionListOMTSOrderID, 
			                                       String transactionListManualRollback, 
			                                       List transactionListParams, 
			                                       List requestMsgList)
			throws FIFException {
		DOMImplementation domImpl = new DOMImplementationImpl();
		Document FIFMsgDoc = domImpl.createDocument(null,
				XMLTags.transactionListRoot, domImpl.createDocumentType(
						XMLTags.transactionListRoot, null,
						XMLTags.transactionListDTD));
		Element transactionListRoot = FIFMsgDoc.getDocumentElement();
		addElement(FIFMsgDoc, transactionListRoot, XMLTags.transactionListID,
				transactionListID);
		addElement(FIFMsgDoc, transactionListRoot, XMLTags.transactionListName,
				transactionListName);
		addElement(FIFMsgDoc, transactionListRoot, XMLTags.transactionListCustomerTrackingId,
				transactionListOMTSOrderID);
		if (transactionListManualRollback != null)
			addElement(FIFMsgDoc, transactionListRoot, XMLTags.transactionListManualRollback,
				transactionListManualRollback);
	
		if(transactionListParams!=null && transactionListParams.size()!=0){
			Element listParamsRoot=null;
			listParamsRoot=addElement(FIFMsgDoc, transactionListRoot, XMLTags.transactionListParams,null);
			Iterator transactionListParamsIter = transactionListParams.iterator();
			while (transactionListParamsIter.hasNext()) {				
				SimpleParameter sp = (SimpleParameter) transactionListParamsIter.next();
				if (sp.getValue() != null)
					addListParamElement(FIFMsgDoc, listParamsRoot, sp.getName(), sp.getValue());				
			}
		}

		transactionListRoot = FIFMsgDoc.getDocumentElement();
		
		// Add the individual transactions
		Element transactionsRoot = FIFMsgDoc
				.createElement(XMLTags.transactionList);
		transactionListRoot.appendChild(transactionsRoot);
		Iterator requestMsgIter = requestMsgList.iterator();
		while (requestMsgIter.hasNext()) {
			Message requestMsg = (Message) requestMsgIter.next();
			Document requestMsgDoc = requestMsg.getDocument();
			Node requestMsgRoot = requestMsgDoc.getDocumentElement();
	
			// Import the response root in the response list document 
			Node importedRequest = FIFMsgDoc.importNode(requestMsgRoot, true);
			transactionsRoot.appendChild(importedRequest);
		}
	
		// Serialize the message document
		try {
			DOMSerializer serializer = new DOMSerializer();
			StringWriter sw = new StringWriter();
			serializer.serialize(FIFMsgDoc, sw, false);
			return (new FIFMessage(sw.toString()));
		} catch (IOException ioe) {
			throw new FIFException(
					"Cannot serialize generated transaction list.", ioe);
		}
	}

	public static Document serializeSOMRequest(String request, StringBuffer beautifiedRequest) throws FIFException {
		// Create a DOM parser
		DOMParser parser = new DOMParser();

		// Parse the XML metadata file with DTD validation
		try {
			ParsingErrorHandler handler = new ParsingErrorHandler();
			// TODO
			parser.setFeature("http://xml.org/sax/features/validation", false);
			parser.setErrorHandler(handler);
            parser.setEntityResolver(new EntityResolver());			
			parser.parse(new InputSource(new StringReader(request)));

			if (handler.isError())
				throw new FIFException("XML parser reported the following errors:\n" + handler.getErrors());
			else if (handler.isWarning()) {
				logger.warn("XML parser reported warnings:\n" + handler.getWarnings());
			}
		} catch (Exception e) {
			throw new FIFException("Exception raised while parsing SOM request.", e);
		} 

		// Beautify the original request
		if (beautifiedRequest != null) {
			DOMSerializer serializer = new DOMSerializer();
			StringWriter writer = new StringWriter();
			try {
				serializer.serialize(parser.getDocument(), writer, true);
				beautifiedRequest.append(writer.toString());
			} catch (Exception e) {
				logger.warn("Cannot beautify original request.", e);
			}
		}
		
		// Get the document
		return parser.getDocument();
	}
}