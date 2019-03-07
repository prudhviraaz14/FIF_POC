/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/FIFMessage.java-arc   1.1   Jun 14 2004 15:43:06   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/FIFMessage.java-arc  $
 * 
 *    Rev 1.1   Jun 14 2004 15:43:06   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.0   Apr 09 2003 09:34:36   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

/**
 * Class representing a FIF Message.
 * The message string contains the XML representation of a FIF Transaction.
 * This message can be sent to FIF through the FIFMessageSender API.
 *
 * @author goethalo
 */
public class FIFMessage extends Message {

    /*-------------*
     * CONSTRUCTOR *
     *-------------*/

    /**
     * Constructor.
     */
    public FIFMessage() {
        super();
    }

    /**
     * Constructor.
     * @param text  the message text to set.
     */
    public FIFMessage(String text) {
        super(text);
    }
}
