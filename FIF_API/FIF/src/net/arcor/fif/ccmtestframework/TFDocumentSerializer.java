/*
 $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/ccmtestframework/TFDocumentSerializer.java-arc   1.2   Oct 21 2011 12:57:06   banania  $

 $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/ccmtestframework/TFDocumentSerializer.java-arc  $
 * 
 *    Rev 1.2   Oct 21 2011 12:57:06   banania
 * Method "serializeDocFromString" added.
 * 
 *    Rev 1.1   Sep 19 2005 15:29:28   banania
 * Added use of entity resolver for finding dtds.
 * 
 *    Rev 1.0   Sep 15 2005 15:03:48   banania
 * Initial revision.
 */
package net.arcor.fif.ccmtestframework;

import java.io.IOException;
import java.io.StringReader;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.ParsingErrorHandler;
import net.arcor.fif.messagecreator.EntityResolver;

import org.apache.log4j.Logger;
import org.apache.xerces.parsers.DOMParser;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * @author banania
 *
 * Class that serializes a DOM document from XML file.
 */

public class TFDocumentSerializer {

	/*------------------*
	 * MEMBER VARIABLES *
	 *------------------*/

	/**
	 * The log4j logger.
	 */
	private static Logger logger = Logger.getLogger(TFDocumentSerializer.class);

	/*---------*
	 * METHODS *
	 *---------*/

	/**
	 * Gets the text contained in an element.
	 *
	 * @param element  the element to take the text from
	 * @return a <code>String</code> containing the text of the element,
	 * null if the element contains no text.
	 */
	public static String getElementText(Element element) {
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
	 * Gets the text contained in an element given the tagname of the element
	 * and the parent element.
	 * @param parent   the parent element
	 * @param tagName  the tag name of the element to take the text for
	 * @return a <code>String</code> containing the element text, null if an
	 * element with the passed in tagname was not found.
	 */
	public static String getElementText(Element parent, String tagName) {
		Element element = (Element) (parent.getElementsByTagName(tagName)
				.item(0));
		if (element == null) {
			return null;
		}
		return (getElementText(element));
	}

	/**
	 * Creates a DOM document based on the contents of an XML file.
	 * @param fileName  the name of the XML file to construct the DOM document from
	 * @return the created <code>Document</code> object
	 */
	public static Document serializeDocFromFile(String fileName)
			throws FIFException {
		// Create a DOM parser
		DOMParser parser = new DOMParser();
		Document doc = null;

		// Parse the XML metadata file with DTD validation
		try {
			ParsingErrorHandler handler = new ParsingErrorHandler();
			parser.setFeature("http://xml.org/sax/features/validation", true);
			parser.setErrorHandler(handler);
			parser.setEntityResolver(new EntityResolver());
			parser.parse(fileName);
			if (handler.isError()) {
				throw new FIFException(
						"XML parser reported the following errors:\n"
								+ handler.getErrors());

			} else if (handler.isWarning()) {
				logger.warn("XML parser reported warnings:\n"
						+ handler.getWarnings());
			}
		} catch (SAXException e) {
			throw new FIFException("Cannot parse file " + fileName, e);

		} catch (IOException e) {
			throw new FIFException("Cannot parse file " + fileName, e);
		}
		// Get the document
		doc = parser.getDocument();

		// Serialize the document
		return doc;
	}
	/**
	 * Creates a DOM document based on the contents of an XML string.
	 * @param fileName  the name of the XML file to construct the DOM document from
	 * @return the created <code>Document</code> object
	 */
	public static Document serializeDocFromString(String requestListString)
			throws FIFException {
		// Create a DOM parser
		DOMParser parser = new DOMParser();
		Document doc = null;

		// Parse the XML metadata file with DTD validation
		try {
			ParsingErrorHandler handler = new ParsingErrorHandler();
			parser.setFeature("http://xml.org/sax/features/validation", true);
			parser.setErrorHandler(handler);
			parser.setEntityResolver(new EntityResolver());
			parser.parse(new InputSource(new StringReader(requestListString)));
			if (handler.isError()) {
				throw new FIFException(
						"XML parser reported the following errors:\n"
								+ handler.getErrors());

			} else if (handler.isWarning()) {
				logger.warn("XML parser reported warnings:\n"
						+ handler.getWarnings());
			}
		} catch (SAXException e) {
			throw new FIFException("Cannot parse xml string " + requestListString, e);

		} catch (IOException e) {
			throw new FIFException("Cannot parse xml string " + requestListString, e);
		}
		// Get the document
		doc = parser.getDocument();

		// Serialize the document
		return doc;
	}
}
