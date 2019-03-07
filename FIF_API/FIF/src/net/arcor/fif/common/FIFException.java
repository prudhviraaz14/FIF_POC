/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/common/FIFException.java-arc   1.3   Jun 10 2015 13:20:52   schwarje  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/common/FIFException.java-arc  $
 * 
 *    Rev 1.3   Jun 10 2015 13:20:52   schwarje
 * PPM-95514: small improvements
 * 
 *    Rev 1.2   May 26 2015 07:26:14   schwarje
 * PPM-95514 CPM
 * 
 *    Rev 1.1   Jan 30 2004 10:11:04   goethalo
 * IN-000019704: Added code to get linked exception from JMSExceptions.
 * 
 *    Rev 1.0   Apr 09 2003 09:34:32   goethalo
 * Initial revision.
*/
package net.arcor.fif.common;

import javax.jms.JMSException;

/**
 * Generic exception for the FIF package.
 * This generic exception holds on to the original exception in its detail
 * attribute.
 *
 * @author goethalo
 */
public class FIFException extends Exception {

	private static final long serialVersionUID = 1L;

	protected String errorCode = null;
	
    public String getErrorCode() {
		return errorCode;
	}

	/**
     * Contains the original exception
     */
    private Exception detail = null;

    /**
     * Constructs a FIFException with no detailed message.
     */
    public FIFException() {
        super();
    }

    /**
     * Constructs a FIFException with the specified detailed message.
     *
     * @param message  the detailed message for this FIFException
     */
    public FIFException(String message) {
        super(message);
    }

    /**
     * Constructs a FIFException with the specified detailed message.
     *
     * @param message  the detailed message for this FIFException
     */
    public FIFException(String errorCode, String message) {
    	super(message);
    	this.errorCode = errorCode;
    }

    /**
     * Constructs a FIFException with the specified detailed message.
     *
     * @param message  the detailed message for this FIFException
     */
    public FIFException(FIFErrorLiterals errorCode, String message) {
    	super(message);
    	this.errorCode = errorCode.name();
    }

    /**
     * Constructs a FIFException with the specified original
     * exception and no detailed message.
     *
     * @param detail  the exception that caused this FIFException
     */
    public FIFException(Exception detail) {
        super();
        this.detail = detail;
    }

    /**
     * Constructs a FIFException with the specified detailed message
     * and original exception.
     *
     * @param message  the detailed message for this exception
     * @param detail   the exception that caused this FIFException
     */
    public FIFException(String message, Exception detail) {
        super(message);
        this.detail = detail;
    }
    
    public FIFException(String errorCode, String message, Exception detail) {
        super(message);
        this.detail = detail;
    	this.errorCode = errorCode;
    }
    
    public FIFException(FIFErrorLiterals errorCode, String message, Exception detail) {
        super(message);
        this.detail = detail;
    	this.errorCode = errorCode.name();
    }
    
    /**
     * Returns the original exception that caused this FIFException
     * to be thrown.
     *
     * @return  the original exception
     */
    public Exception getDetail() {
        return detail;
    }

    /**
     * Prints the stack trace of the exception and all its embedded
     * exceptions.
     * @see java.lang.Throwable#printStackTrace()
     */
    public void printStackTrace() {
        super.printStackTrace();
        Exception e = getDetail();
        while (e != null) {
            e.printStackTrace();
            if (e instanceof FIFException) {
                e = ((FIFException) e).getDetail();
            } else if (e instanceof JMSException) {
                e = ((JMSException) e).getLinkedException();
            } else {
                e = null;
            }
        }
    }

    /**
     * Prints the stack trace of the exception and all its embedded
     * exceptions.
     * @see java.lang.Throwable#printStackTrace(java.io.PrintStream)
     */
    public void printStackTrace(java.io.PrintStream s) {
        super.printStackTrace(s);
        Exception e = getDetail();
        while (e != null) {
            e.printStackTrace(s);
            if (e instanceof FIFException) {
                e = ((FIFException) e).getDetail();
            } else if (e instanceof JMSException) {
                e = ((JMSException) e).getLinkedException();
            } else {
                e = null;
            }
        }
    }

    /**
     * Prints the stack trace of the exception and all its embedded
     * exceptions.
     * @see java.lang.Throwable#printStackTrace(java.io.PrintWriter)
     */
    public void printStackTrace(java.io.PrintWriter s) {
        super.printStackTrace(s);
        Exception e = getDetail();
        while (e != null) {
            e.printStackTrace(s);
            if (e instanceof FIFException) {
                e = ((FIFException) e).getDetail();
            } else if (e instanceof JMSException) {
                e = ((JMSException) e).getLinkedException();
            } else {
                e = null;
            }
        }
    }

}
