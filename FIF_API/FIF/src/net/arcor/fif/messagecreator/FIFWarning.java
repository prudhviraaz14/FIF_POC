/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/FIFWarning.java-arc   1.0   Sep 09 2003 16:36:38   goethalo  $
    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/FIFWarning.java-arc  $
 * 
 *    Rev 1.0   Sep 09 2003 16:36:38   goethalo
 * Initial revision.
*/    
package net.arcor.fif.messagecreator;

/**
 * This class represents a warning returned by FIF.
 * @author goethalo
 */
public class FIFWarning extends FIFResult {

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Constructor.
     * @param number   the error number to set.
     * @param message  the error message to set.
     */
    public FIFWarning(String number, String message) {
        super(number, message);
    }

    /**
     * Returns a string representation of the error object.
     * @return a String containing the error number and message. 
     */
    public String toString() {
        StringBuffer msg = new StringBuffer();
        msg.append("[WARNING] ");
        msg.append(getNumber());
        msg.append(" | ");
        msg.append(getMessage());
        return (msg.toString());
    }

}
