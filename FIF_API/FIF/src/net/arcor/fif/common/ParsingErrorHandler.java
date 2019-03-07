/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/ParsingErrorHandler.java-arc   1.0   Apr 09 2003 09:34:32   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/ParsingErrorHandler.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:32   goethalo
 * Initial revision.
*/
package net.arcor.fif.common;

import java.util.ArrayList;

import org.xml.sax.ErrorHandler;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

/**
 * Handles DTD validations errors reported by the Xerces parser.
 * @author goethalo
 */
public class ParsingErrorHandler implements ErrorHandler {

	/**
	 * Stores the warnings.
	 */
	private ArrayList warnings = null;

	/**
	 * Stores the errors.
	 */
	private ArrayList errors = null;

	/**
	 * Constructor
	 */
	public ParsingErrorHandler() {
		super();
	}

	/**
	 * Responds to a warning.
	 * @see org.xml.sax.ErrorHandler#warning(org.xml.sax.SAXParseException)
	 */
	public void warning(SAXParseException exception) throws SAXException {
		addWarning(exception);
	}

	/**
	 * Responds to an error.
	 * @see org.xml.sax.ErrorHandler#error(org.xml.sax.SAXParseException)
	 */
	public void error(SAXParseException exception) throws SAXException {
		addError(exception);
	}

	/**
	 * Responds to a fatal error.
	 * @see org.xml.sax.ErrorHandler#fatalError(org.xml.sax.SAXParseException)
	 */
	public void fatalError(SAXParseException exception) throws SAXException {
		addError(exception);
	}

	/**
	 * Determines if the object contains errors.
	 * @return boolean
	 */
	public boolean isError() {
		return ((errors != null) && (errors.size() > 0));
	}

	/**
	 * Determines if the object contains warnings.
	 * @return boolean
	 */
	public boolean isWarning() {
		return ((warnings != null) && (warnings.size() > 0));
	}

	/**
	 * Returns a string containing the reported error messages.
	 * @return String
	 */
	public String getErrors() {
		if (errors == null) {
			return "";
		}

		StringBuffer sb = new StringBuffer();
		for (int i = 0; i < errors.size(); i++) {
			sb.append(((SAXParseException) errors.get(i)).getMessage());
			sb.append(" (line: ");
			sb.append(((SAXParseException) errors.get(i)).getLineNumber());
			sb.append(", column: ");
			sb.append(((SAXParseException) errors.get(i)).getColumnNumber());
			sb.append(")\n");
		}

		return (sb.toString());
	}

	/**
	 * Returns a string containing the reported warning messages.
	 * @return String
	 */
	public String getWarnings() {
		if (warnings == null) {
			return "";
		}

		StringBuffer sb = new StringBuffer();
		for (int i = 0; i < warnings.size(); i++) {
			sb.append(((SAXParseException) warnings.get(i)).getMessage());
			sb.append(" (line: ");
			sb.append(((SAXParseException) warnings.get(i)).getLineNumber());
			sb.append(", column: ");
			sb.append(((SAXParseException) warnings.get(i)).getColumnNumber());
			sb.append(")\n");
		}

		return (sb.toString());
	}

	/**
	 * Clears the errors and warnings from the object.
	 */
	public void clear() {
		if (errors != null) {
			errors.clear();
		}
		if (warnings != null) {
			warnings.clear();
		}
	}

	/**
	 * Adds a warning the the warning list.
	 * @param e  the exception to be added.
	 */
	private void addWarning(Exception e) {
		if (warnings == null) {
			warnings = new ArrayList();
		}
		warnings.add(e);
	}

	/**
	 * Adds an error to the error list.
	 * @param e  the exception to be added.
	 */
	private void addError(Exception e) {
		if (errors == null) {
			errors = new ArrayList();
		}
		errors.add(e);
	}

}
