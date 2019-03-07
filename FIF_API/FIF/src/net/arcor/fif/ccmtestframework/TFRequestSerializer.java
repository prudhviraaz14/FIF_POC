/*
 $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/ccmtestframework/TFRequestSerializer.java-arc   1.4   Sep 20 2016 13:25:40   schwarje  $

 $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/ccmtestframework/TFRequestSerializer.java-arc  $
 * 
 *    Rev 1.4   Sep 20 2016 13:25:40   schwarje
 * parameters set depending on values of other parameters
 * 
 *    Rev 1.3   Apr 21 2016 05:52:44   schwarje
 * absolute dates for TrxBuikder override date
 * 
 *    Rev 1.2   Aug 05 2011 14:42:04   schwarje
 * BKS request for TFW
 * 
 *    Rev 1.1   Jun 24 2010 17:53:28   schwarje
 * CPCOM Phase 2: new FIF client type accepting SOM orders
 * 
 *    Rev 1.0   Jun 01 2010 17:57:48   schwarje
 * Initial revision.
 * 
*/
package net.arcor.fif.ccmtestframework;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import net.arcor.fif.common.DateUtils;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.XMLHelpers;
import net.arcor.fif.messagecreator.FIFError;
import net.arcor.fif.messagecreator.FIFRequest;
import net.arcor.fif.messagecreator.FIFRequestList;
import net.arcor.fif.messagecreator.InvalidRequest;
import net.arcor.fif.messagecreator.Parameter;
import net.arcor.fif.messagecreator.ParameterList;
import net.arcor.fif.messagecreator.ParameterListItem;
import net.arcor.fif.messagecreator.Request;
import net.arcor.fif.messagecreator.RequestFactory;
import net.arcor.fif.messagecreator.SimpleParameter;
import net.arcor.fif.messagecreator.XMLTags;

import org.apache.log4j.Logger;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class TFRequestSerializer {
	
	private static Logger logger = Logger.getLogger(TFRequestSerializer.class);

	private static SimpleDateFormat sdfComDate = new SimpleDateFormat("yyyy-MM-dd");
	private static SimpleDateFormat sdfComDateTime = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
	private static SimpleDateFormat sdfFIF = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");
	/**
	 * A map containing output params.
	 */
	public static Map<String, String> outputParameters = new HashMap<String, String>();

	public static TFTrxBuilderRequest serializeTrxBuilderRequest(Element root) throws FIFException {
		TFTrxBuilderRequest trxBuilderRequest = new TFTrxBuilderRequest();
		trxBuilderRequest.setSomParts(serializeSomParts(root));
		trxBuilderRequest.setTransactionID(XMLHelpers.getTextElement(root, "transaction-id"));
		trxBuilderRequest.setTransactionType(XMLHelpers.getTextElement(root, "transaction-type"));
		String overrideSystemDateString = XMLHelpers.getTextElement(root, "override-system-date");
		if (overrideSystemDateString != null)
			trxBuilderRequest.setOverrideSystemDate(calculateRelativeDate(overrideSystemDateString));
		return trxBuilderRequest;
	}
	
	public static TFBKSRequest serializeBKSRequest(Element root) throws FIFException {
		TFBKSRequest bksRequest = new TFBKSRequest();
		bksRequest.setTransactionID(XMLHelpers.getTextElement(root, "transaction-id"));
		bksRequest.setServiceName(XMLHelpers.getTextElement(root, "service-name"));
		bksRequest.setPackageName(XMLHelpers.getTextElement(root, "package-name"));
		serializeRequestParams(root, TFXMLTags.bksRequestInputParams,
				bksRequest.getParams(), false);
		serializeRequestParams(root, TFXMLTags.bksRequestOutputParams,
				bksRequest.getOutputParams(), false);
		
		NodeList paramsRoot = root.getElementsByTagName(TFXMLTags.bksRequestResultParams);
		if (paramsRoot.getLength() > 0) {
			NodeList params = ((Element) paramsRoot.item(0)).getChildNodes();			
			for (int i = 0; i < params.getLength(); i++) {
				if (params.item(i).getNodeType() != Node.ELEMENT_NODE)
					continue;
				String xpathExpression = XMLHelpers.getTextElement((Element)params.item(i), "xpath-expression");
				String expectedResult = XMLHelpers.getTextElement((Element)params.item(i), "expected-result");
				bksRequest.getResultParams().put(xpathExpression, expectedResult);
				bksRequest.getResultParamList().add(xpathExpression);
			}
		}
		
		return bksRequest;
	}

	public static Request serializeFifRequest(Element root,
			boolean returnInvalid) throws FIFException {
		Request request = null;
		// Get the action name
		String action = TFDocumentSerializer.getElementText(root,
				TFXMLTags.actionName);
	
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
	
		serializeRequestParams(root, TFXMLTags.requestParams, request.getParams(), true);
		
		return request;
	}

	/**
	 * reads a param list into a map
	 * 
	 * @param root
	 *            request element which contains the desired parameter lists
	 * @param tagName
	 *            name of the parameter list to parse
	 * @param paramMap
	 *            output map
	 * @throws FIFException
	 */
	public static void serializeRequestParams(Element root, String tagName,
			Map paramMap, boolean isFifRequest) throws FIFException {
		// Loop through the request parameters
		NodeList paramsRoot = root.getElementsByTagName(tagName);
		if (paramsRoot.getLength() == 0)
			return;
		NodeList params = ((Element) paramsRoot.item(0)).getChildNodes();
		Date overrideDateTime = null;
	
		for (int i = 0; i < params.getLength(); i++) {
			Node node = params.item(i);
			if (node.getNodeType() == Node.ELEMENT_NODE) {
				Parameter param = parseParam((Element) node);
				paramMap.put(param.getName(), param);
				if (param instanceof SimpleParameter) {
					if (isFifRequest) {
						// TODO replace relative dates by FIF dates
						String convertedDate = replaceFifDate (((SimpleParameter) param).getValue());
						if (convertedDate != null)
							((SimpleParameter) param).setValue(convertedDate);
					}
					
					if (param.getName().equals(TFXMLTags.paramNameOverrideSystemDate)) {
						try {
							overrideDateTime = 
								sdfFIF.parse(((SimpleParameter) param).getValue());
						} catch (ParseException e) {
							throw new FIFException("Invalid format for override date.");
						}
					}
				}
			}
		}
		DateUtils.setOverrideDateTime(overrideDateTime);
	}

	public static List<TFSomPart> serializeSomParts (Element root) throws FIFException {
		List<TFSomPart> returnList = new LinkedList<TFSomPart>();
		NodeList somParts = root.getElementsByTagName(TFXMLTags.somParts);
		if (somParts.getLength() != 1)
			return returnList;
		else if (somParts.item(0).getNodeType() == Node.ELEMENT_NODE)
			root = (Element) somParts.item(0); 
		
		NodeList somPartTemplates = root.getChildNodes();
		if (somPartTemplates.getLength() == 0)
			return returnList;
	
		//NodeList parts = ((Element) somPartTemplates.item(0)).getChildNodes();
		for (int i = 0; i < somPartTemplates.getLength(); i++) {
			Node node = somPartTemplates.item(i);
			if (node.getNodeType() == Node.ELEMENT_NODE) {
				Element element = (Element) node;
				TFSomPart somPart = new TFSomPart();				
				somPart.setFilename(element.getAttribute(TFXMLTags.filename));
				serializeRequestParams(element, TFXMLTags.somPartParams, somPart.getParams(), false);
				returnList.add(somPart);				
			}
		}
		return returnList;
	}

	/**
	 * reads an SQL request from the XML and parses all parameters
	 * 
	 * @param root
	 *            the position in the document containing the root of the
	 *            request
	 * @return the request object
	 * @throws FIFException
	 */
	public static TFSQLRequest serializeSQLRequest(Element root) throws FIFException {
		TFSQLRequest sqlRequest = new TFSQLRequest();
		sqlRequest.setStatement(TFDocumentSerializer.getElementText(root,
				TFXMLTags.statement));
		sqlRequest.setTransactionId(TFDocumentSerializer.getElementText(root,
				TFXMLTags.sqlRequestTransactionId));
		serializeRequestParams(root, TFXMLTags.sqlRequestInputParams,
				sqlRequest.getParams(), false);
		serializeRequestParams(root, TFXMLTags.sqlRequestResultParams,
				sqlRequest.getResultParams(), false);
		serializeRequestParams(root, TFXMLTags.sqlRequestOutputParams,
				sqlRequest.getOutputParams(), false);
		return sqlRequest;
	}

	/**
	 * Parses a node to a Parameter object.
	 * 
	 * @param param
	 *            the parameter to parse.
	 * @return the <code>Parameter</code> object created based on the passed
	 *         in element.
	 */
	public static Parameter parseParam(Element param) throws FIFException {
		if (param.getTagName().equals(TFXMLTags.requestParam)) {
			String name = param.getAttribute(TFXMLTags.requestParamName);
			String value = TFDocumentSerializer.getElementText(param);
			return new SimpleParameter(name, value);
		} else if (param.getTagName().equals(TFXMLTags.requestParamRef)) {
			String transactionID = param
					.getAttribute(TFXMLTags.requestParamRefTransactionID);
			String paramName = param
					.getAttribute(TFXMLTags.requestParamRefParamName);
			String outputParamName = param
					.getAttribute(TFXMLTags.requestParamRefOutputParamName);
	
			// Get the value from the Map
			String paramValue = (String) outputParameters.get(transactionID + paramName);
			if (outputParamName.trim().length() != 0) {
				return new SimpleParameter(outputParamName, paramValue);
			} else {
	
				return new SimpleParameter(paramName, paramValue);
			}
	
		} else if (param.getTagName().equals(TFXMLTags.requestParamList)) {
			String name = param.getAttribute(TFXMLTags.requestParamListName);
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
		}else if (param.getTagName().equals(TFXMLTags.transactionListParam)) {
				String name = param.getAttribute(TFXMLTags.transactionListParamName);
				String value = TFDocumentSerializer.getElementText(param);
				return new SimpleParameter(name, value);
		} else {
			throw new FIFException("Cannot parse parameter: Unknown parameter "
					+ "type passed in: " + param.getTagName());
		}
	}

	/**
	 * Serializes an XML document representing a request to a
	 * <code>Request</code> object.
	 * 
	 * @param root
	 *            the root of the XML document to serialize.
	 * @param returnInvalid
	 *            indicates whether an invalid request should be returned in an
	 *            <code>InvalidRequest</code> object. If this is set to false
	 *            an exception is thrown when the request is invalid.
	 * @return the <code>Request</code> object represented by the XML document
	 * @throws FIFException
	 *             if the request could not be serialized.
	 */
	public static Request serializeRequest(Element root, boolean returnInvalid)
			throws FIFException {
		Request request = null;
	
		if (root.getTagName() == TFXMLTags.sqlRequestRoot) {
			request = serializeSQLRequest(root);
		} else if (root.getTagName() == TFXMLTags.bksRequestRoot) {
			request = serializeBKSRequest(root);
		} else if (root.getTagName() == TFXMLTags.requestRoot) {
			request = serializeFifRequest(root, returnInvalid);
		} else if (root.getTagName() == TFXMLTags.trxBuilderRequestRoot) {
			request = serializeTrxBuilderRequest(root);
		} else if (root.getTagName() == TFXMLTags.transactionList) {
			request = serializeTransactionList(root, returnInvalid);
		}
	
		return request;
	}

	/**
	 * reads a request list from the XML and parses all parameters
	 * 
	 * @param root
	 *            the position in the document containing the root of the
	 *            request
	 * @param returnInvalid
	 * @return the request object
	 * @throws FIFException
	 */
	public static FIFRequestList serializeTransactionList(Element root,
			boolean returnInvalid) throws FIFException {
		FIFRequestList requestList = FIFRequestList.createFIFRequestList();
		requestList.setID(TFDocumentSerializer.getElementText(root,
				TFXMLTags.transactionListID));
		requestList.setName(TFDocumentSerializer.getElementText(root,
				TFXMLTags.transactionListName));
	
		// set params
		serializeRequestParams(root, TFXMLTags.transactionListParams,
					requestList.getParams(), false);
	
		// Loop through the embedded requests
		NodeList requests = root.getElementsByTagName(XMLTags.requestRoot);
		for (int i = 0; i < requests.getLength(); i++) {
			Element requestRoot = (Element) requests.item(i);
			Request request = serializeRequest(requestRoot, returnInvalid);
			SimpleParameter sp = new SimpleParameter("requestListId",
					requestList.getID());
			request.addParam(sp);
			// if (request instanceof InvalidRequest) valid = false;
			requestList.addRequest((FIFRequest) request);
		}
		requestList.sort();
		return requestList;
	}

	public static String replaceComDate(String value) throws FIFException {
		GregorianCalendar calendar = calculateRelativeDate(value);
			
		if (calendar == null) 
			return null;
		
		return (value.startsWith("datetime")) ? 
				sdfComDateTime.format(calendar.getTime()) : 
				sdfComDate.format(calendar.getTime());
	}

	public static String replaceFifDate(String value) throws FIFException {
		GregorianCalendar calendar = calculateRelativeDate(value);
		
		return (calendar != null) ? 
				sdfFIF.format(calendar.getTime()) : 
				null;
	}

	/**
	 * replacing parameter with their values
	 * 
	 * @param request
	 *            the request
	 * @return
	 */
	public static boolean replaceParameters(TFSQLRequest request) {
		Iterator iter = request.getParams().keySet().iterator();
		Pattern pattern;
		Matcher matcher;
		while (iter.hasNext()) {
			Parameter param = request.getParam((String) iter.next());
			if (param instanceof SimpleParameter) {
				pattern = Pattern.compile(((SimpleParameter) param).getName());
				matcher = pattern.matcher(request.getStatement());
				if (((SimpleParameter) param).getValue() != null) {
					logger.debug("Replacing "
							+ ((SimpleParameter) param).getName() + " with "
							+ ((SimpleParameter) param).getValue());
					try {
						request.setStatement(matcher
								.replaceAll(((SimpleParameter) param)
										.getValue()));
					} catch (NullPointerException e) {
						logger.debug("Couldn't replace "
								+ ((SimpleParameter) param).getName()
								+ " with "
								+ ((SimpleParameter) param).getValue());
					}
				} else {
					logger.warn("Parameter "
							+ ((SimpleParameter) param).getName()
							+ " has no value.");
				}
			} else {
				logger.error("Wrong parameter type in SQL request.");
				return false;
			}
		}
		return true;
	}

	/**
	 * @param value
	 * @return
	 * @throws FIFException 
	 */
	public static GregorianCalendar calculateRelativeDate(String value) throws FIFException {
		if (value == null)
			return null;					
		else if (value.matches("^[0-9]{4}\\.[0-9]{2}\\.[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}")) {
			Date absoluteDate = null;
			try {
				absoluteDate = sdfFIF.parse(value);
			} catch (ParseException e) {
				throw new FIFException("Invalid format for override date '" + value + "'.");
			}
			
		    GregorianCalendar calendar = new GregorianCalendar();
		    calendar.setTime(absoluteDate);
		    return calendar; 
		}
		else if (value.startsWith("datetime:") || value.startsWith("date:")) {
			String pattern = "(datetime|date):[\\-|\\+]{0,1}[0-9]+:(hour|minute|date)";
			if (!value.matches(pattern))
				logger.warn("Wrong format for date replacement: " + value + ", "+ pattern);
			
			String[] parts = value.split(":");
			if (parts.length != 3)
				return null;
			int offset = Integer.parseInt(parts[1].trim());
			String offsetUnit = parts[2].trim();
			Date date = new Date();
		    GregorianCalendar calendar = new GregorianCalendar();
		    calendar.setTime(date);
		    calendar.set(Calendar.MILLISECOND, 0);
			if (offsetUnit.equals("hour"))
				calendar.add(Calendar.HOUR, offset);
			else if (offsetUnit.equals("date"))
				calendar.add(Calendar.DATE, offset);
			else if (offsetUnit.equals("minute"))
				calendar.add(Calendar.MINUTE, offset);
			return calendar;
		}
		else return null;
	}

	public static Iterable<MatchResult> findMatches( String pattern, CharSequence s ) 
	{ 
		List<MatchResult> results = new ArrayList<MatchResult>();
		Pattern p = null;
		try {
			p = Pattern.compile(pattern);
		} catch (RuntimeException e) {
			e.printStackTrace();
		}
		if (p == null) 
			return results;
		Matcher m = p.matcher(s);
		while (m.find()) {
			results.add(m.toMatchResult());
		}
		return results; 
	}

	public static String replaceParameters(String somPartString, Map params) throws FIFException {
		
		String pattern = "\\{[^\\}]+\\}";
		String returnString = new String(somPartString);
		 
		Iterable<MatchResult> matches = findMatches(pattern, somPartString);
		if (matches != null)
			for (MatchResult r : matches) {
				String matchResult = somPartString.substring(r.start(), r.end());

				// conditional:(key=value)parameterName => replace, if condition is true
				if (matchResult.startsWith("{conditional:(")) {
					String key = matchResult.substring(14, matchResult.indexOf("="));
					String value = matchResult.substring(matchResult.indexOf("=") + 1, matchResult.indexOf(")"));
					String stringToReplace = matchResult.substring(matchResult.indexOf(")") + 1, matchResult.length() - 1);
					boolean replaceString = false;
					Object o = params.get(key);
					if (params != null &&
							params.get(key) instanceof SimpleParameter &&
							((SimpleParameter)params.get(key)).getValue().equals(value))
						replaceString = true;
					returnString = returnString.replace(
							matchResult, 
							(replaceString) ? stringToReplace : "");
				}

				else {
					String paramName = somPartString.substring(r.start()+1, r.end()-1);
					
					SimpleParameter param = (SimpleParameter)params.get(paramName);
					if (param != null) {
						String value = param.getValue();
						if (value != null) {
							String replaceString = TFRequestSerializer.replaceComDate(value);
							returnString = returnString.replace(
									matchResult, 
									(replaceString == null) ? value : replaceString);
						}
						else
							returnString = returnString.replace(matchResult, "");
					}
					else
						returnString = returnString.replace(matchResult, "");
				}
			}		
		return returnString;
	}

}
