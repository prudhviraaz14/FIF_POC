/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/FIFError.java-arc   1.1   Sep 09 2003 16:37:00   goethalo  $
    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/FIFError.java-arc  $
 * 
 *    Rev 1.1   Sep 09 2003 16:37:00   goethalo
 * IT-10800: added warning support.
*/    
package net.arcor.fif.messagecreator;

/**
 * This class represents an error returned by FIF.
 * @author goethalo
 */
public class FIFError extends FIFResult {

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Constructor.
     * @param number   the error number to set.
     * @param message  the error message to set.
     */
    public FIFError(String number, String message) {
        super(number, message);
    }

    /**
     * Returns a string representation of the error object.
     * @return a String containing the error number and message. 
     */
    public String toString() {
        StringBuffer msg = new StringBuffer();
        msg.append("[ERROR] ");
        msg.append(getNumber());
        msg.append(" | ");
        msg.append(getMessage());
        return (msg.toString());
    }

}
