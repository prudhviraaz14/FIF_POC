package net.arcor.fif.messagecreator;

import net.arcor.fif.common.FIFException;

public class FIFInvalidRequestException extends FIFException {
    public FIFInvalidRequestException(String message) {
        super(message);
    }

    /**
     * Constructs a FIFException with the specified original
     * exception and no detailed message.
     *
     * @param detail  the exception that caused this FIFException
     */
    public FIFInvalidRequestException(Exception detail) {
        super(detail);
    }

    /**
     * Constructs a FIFException with the specified detailed message
     * and original exception.
     *
     * @param message  the detailed message for this exception
     * @param detail   the exception that caused this FIFException
     */
    public FIFInvalidRequestException(String message, Exception detail) {
        super(message, detail);
    }

}
