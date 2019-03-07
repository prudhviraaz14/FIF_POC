/*
 * $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/InvalidRequestList.java-arc   1.0   Jun 14 2004 15:42:04   goethalo  $
 *
 * $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/InvalidRequestList.java-arc  $
 * 
 *    Rev 1.0   Jun 14 2004 15:42:04   goethalo
 * Initial revision.
 */
package net.arcor.fif.messagecreator;

/**
 * This class represents an invalid request.
 * A request list is invalid if one of its bundled requests is invalid. 
 * @author goethalo
 */
public class InvalidRequestList extends FIFRequestList {

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
    public InvalidRequestList() {
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
