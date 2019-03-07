/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/OutputParameter.java-arc   1.0   Oct 07 2003 14:51:52   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/OutputParameter.java-arc  $
 * 
 *    Rev 1.0   Oct 07 2003 14:51:52   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import net.arcor.fif.common.FIFException;

/**
 * This class represents an output parameter returned to the caller. 
 * @author goethalo
 */
public class OutputParameter {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     *  The name of the parameter object.
     */
    private String name = null;

    /**
     * The value of the parameter object.
     */
    private String value = null;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor
     * @param name  the name of the parameter
     */
    public OutputParameter(String name, String value) throws FIFException {
        if ((name == null) || (name.trim().length() == 0)) {
            throw new FIFException(
                "Cannot create OutputParameter because the passed "
                    + "in name is null or empty");
        }
        this.name = name;
        this.value = value;
    }

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * Returns the name.
     * @return the name.
     */
    public String getName() {
        return name;
    }

    /**
     * Returns the value.
     * @return the value.
     */
    public String getValue() {
        return value;
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Writes the contents of this object as a <code>String</code>
     * @see java.lang.Object#toString()
     */
    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append("\nOutputParameter (");
        sb.append("name: ");
        sb.append(getName());
        sb.append(", value: ");
        sb.append(getValue());
        sb.append(")");
        return sb.toString();
    }
}
