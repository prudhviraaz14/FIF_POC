/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/common/FIFFunctionalException.java-arc   1.1   Jun 10 2015 13:20:40   schwarje  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/common/FIFFunctionalException.java-arc  $
 * 
 *    Rev 1.1   Jun 10 2015 13:20:40   schwarje
 * PPM-95514: small improvements
 * 
 *    Rev 1.0   May 26 2015 07:28:02   schwarje
 * Initial revision.
*/
package net.arcor.fif.common;

public class FIFFunctionalException extends FIFException {

	private static final long serialVersionUID = 1L;

	public FIFFunctionalException() {
	}

	public FIFFunctionalException(String message) {
		super(message);
	}

	public FIFFunctionalException(String errorCode, String message) {
		super(errorCode, message);
	}

	public FIFFunctionalException(FIFErrorLiterals errorCode, String message) {
		super(errorCode, message);
	}

	public FIFFunctionalException(Exception detail) {
		super(detail);
	}

	public FIFFunctionalException(String message, Exception detail) {
		super(message, detail);
	}

	public FIFFunctionalException(String errorCode, String message, Exception detail) {
		super(errorCode, message, detail);
	}

	public FIFFunctionalException(FIFErrorLiterals errorCode, String message, Exception detail) {
		super(errorCode, message, detail);
	}

}
