/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/SimpleParameter.java-arc   1.1   Jul 16 2003 15:01:14   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/SimpleParameter.java-arc  $
 * 
 *    Rev 1.1   Jul 16 2003 15:01:14   goethalo
 * Changes for IT-9750
 * 
 *    Rev 1.0   Apr 09 2003 09:34:42   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import net.arcor.fif.common.FIFException;

/**
 * This class represents a simple parameter.
 * A simple parameter does not contain further parameters.
 * @author goethalo
 */
public class SimpleParameter extends Parameter {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The <code>String</code> value of the parameter
     */
    private String value = null;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     * @param name  the name of the parameter.
     */
    public SimpleParameter(String name) throws FIFException {
        super(name);
    }

    /**
     * Constructor.
     * @param name   the name of the parameter
     * @param value  the value of the parameter
     */
    public SimpleParameter(String name, String value) throws FIFException {
        super(name);
        this.value = value;
    }

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * Returns the value.
     * @return String
     */
    public String getValue() {
        return value;
    }

    /**
     * Sets the value.
     * @param value The value to set
     */
    public void setValue(String value) {
        this.value = value;
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * @see net.arcor.fif.messagecreator.Parameter#equals(java.lang.Object)
     */
    public boolean equals(Object obj) {
        return (
            (obj != null)
                && (obj instanceof SimpleParameter)
                && (((Parameter) obj).getName() == getName()));
    }

    /**
     * Writes the contents of this object as a <code>String</code>
     * @see java.lang.Object#toString()
     */
    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append("\nSimpleParameter (");
        sb.append("name: ");
        sb.append(getName());
        sb.append(", value: ");
        sb.append(value);
        sb.append(")");
        return sb.toString();
    }

}
