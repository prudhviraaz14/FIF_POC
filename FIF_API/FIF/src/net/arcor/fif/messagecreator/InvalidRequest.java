package net.arcor.fif.messagecreator;

/**
 * This class represents an invalid request.
 * A request is invalid if the action name is wrong, a parameter is missing, etc.
 * @author goethalo
 */
public class InvalidRequest extends FIFRequest {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The error message.
     */
    private FIFError error = null;

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Constructor.
     */
    public InvalidRequest() {
        super();
    }

    /**
     * Sets the error.
     * @param error  the error to set.
     */
    public void setError(FIFError error) {
        this.error = error;
    }

    /**
     * Gets the error.
     * @return the error.
     */
    public FIFError getError() {
        return error;
    }

}
