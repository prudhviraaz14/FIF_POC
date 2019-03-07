/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/Parameter.java-arc   1.1   Jul 16 2003 14:59:56   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/Parameter.java-arc  $
 * 
 *    Rev 1.1   Jul 16 2003 14:59:56   goethalo
 * Changes for IT-9750
 * 
 *    Rev 1.0   Apr 09 2003 09:34:40   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import net.arcor.fif.common.FIFException;

/**
 * This is the abstract base class for all parameter types.
 * @author goethalo
 */
public abstract class Parameter {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     *  The name of the parameter object
     */
    private String name = null;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor
     * @param name  the name of the parameter
     */
    public Parameter(String name) throws FIFException {
        if ((name == null) || (name.trim().length() == 0)) {
            throw new FIFException(
                "Cannot create Parameter because the passed "
                    + "in name is null or empty");
        }
        this.name = name;
    }

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * Returns the name.
     * @return String
     */
    public String getName() {
        return name;
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Determines if the object is equal to another object
     * @see java.lang.Object#equals(java.lang.Object)
     */
    public abstract boolean equals(Object obj);

    /**
     * Generates the hashcode for this object.
     * The hashcode is generator based on the name of the object. It consists
     * of a call to <code>name.hashCode()</code> to use the standard
     * <code>String</code> class method.
     * @see java.lang.Object#hashCode()
     */
    public int hashCode() {
        return name.hashCode();
    }

    /**
     * Writes the contents of this object as a <code>String</code>
     * @see java.lang.Object#toString()
     */
    public abstract String toString();
}
