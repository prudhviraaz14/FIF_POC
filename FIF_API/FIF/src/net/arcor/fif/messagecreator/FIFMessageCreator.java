/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/FIFMessageCreator.java-arc   1.0   Apr 09 2003 09:34:36   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/FIFMessageCreator.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:36   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import net.arcor.fif.common.FIFException;



/**
 * Abstract base class for all FIF related message creator types.
 * @author goethalo
 */
public abstract class FIFMessageCreator extends MessageCreator {

    /**
     * Constructor.
     * @see java.lang.Object#Object()
     */
    public FIFMessageCreator(String action) throws FIFException {
        super(action);
    }


}
