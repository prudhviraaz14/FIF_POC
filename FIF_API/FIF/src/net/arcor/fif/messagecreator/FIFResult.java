/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/FIFResult.java-arc   1.0   Sep 09 2003 16:36:38   goethalo  $
    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/FIFResult.java-arc  $
 * 
 *    Rev 1.0   Sep 09 2003 16:36:38   goethalo
 * Initial revision.
*/    
package net.arcor.fif.messagecreator;

/**
 * Abstract base class for all FIF result types (like Errors and Warnings).
 * @author goethalo
 */
public abstract class FIFResult {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The result number.
     */
    private String number = null;

    /**
     * The result message.
     */
    private String message = null;

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Constructor.
     * @param number   the result number to set.
     * @param message  the result message to set.
     */
    public FIFResult(String number, String message) {
        this.number = number;
        this.message = message;
    }

    /**
     * Gets the result message.
     * @return the result message.
     */
    public String getMessage() {
        return message;
    }

    /**
     * Gets the result number.
     * @return the result number.
     */
    public String getNumber() {
        return number;
    }

    /**
     * Returns a string representation of the error object.
     * @return a String containing the result number and message. 
     */
    public abstract String toString();
}
