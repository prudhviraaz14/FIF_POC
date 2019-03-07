package net.arcor.fif.common;

public class FIFTechnicalException extends FIFException {

	private static final long serialVersionUID = 1L;

	public FIFTechnicalException() {
	}

	public FIFTechnicalException(String message) {
		super(message);
	}

	public FIFTechnicalException(String errorCode, String message) {
		super(errorCode, message);
	}

	public FIFTechnicalException(FIFErrorLiterals errorCode, String message) {
		super(errorCode, message);
	}

	public FIFTechnicalException(Exception detail) {
		super(detail);
	}

	public FIFTechnicalException(String message, Exception detail) {
		super(message, detail);
	}

	public FIFTechnicalException(String errorCode, String message, Exception detail) {
		super(errorCode, message, detail);
	}

	public FIFTechnicalException(FIFErrorLiterals errorCode, String message, Exception detail) {
		super(errorCode, message, detail);
	}

}
