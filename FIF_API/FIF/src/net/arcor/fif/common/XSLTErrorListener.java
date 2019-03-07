/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/XSLTErrorListener.java-arc   1.0   Apr 09 2003 09:34:34   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/XSLTErrorListener.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:34   goethalo
 * Initial revision.
*/
package net.arcor.fif.common;

import java.util.ArrayList;

import javax.xml.transform.ErrorListener;
import javax.xml.transform.TransformerException;

/**
 * Error listener for the XSLTMessageCreator.
 * This class stores the errors and warnings that are generated
 * by the XSLT process of the XSLTMessageCreator.
 * This data can then later be used for error reporting.
 * @author goethalo
 */
public class XSLTErrorListener implements ErrorListener {

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
	public XSLTErrorListener() {
		super();
	}

	/**
	 * Responds to a warning.
	 * @see javax.xml.transform.ErrorListener#warning(javax.xml.transform.TransformerException)
	 */
	public void warning(TransformerException exception)
		throws TransformerException {
		addWarning(exception);
	}

	/**
	 * Responds to an error
	 * @see javax.xml.transform.ErrorListener#error(javax.xml.transform.TransformerException)
	 */
	public void error(TransformerException exception)
		throws TransformerException {
		addError(exception);
	}

	/**
	 * Responds to a fatal error
	 * @see javax.xml.transform.ErrorListener#fatalError(javax.xml.transform.TransformerException)
	 */
	public void fatalError(TransformerException exception)
		throws TransformerException {
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
			sb.append(
				((TransformerException) errors.get(i)).getMessageAndLocation());
			sb.append("\n");
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
			sb.append(
				((TransformerException) warnings.get(i))
					.getMessageAndLocation());
			sb.append("\n");
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
