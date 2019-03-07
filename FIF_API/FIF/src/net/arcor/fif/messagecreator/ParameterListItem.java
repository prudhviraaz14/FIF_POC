/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/ParameterListItem.java-arc   1.0   Jul 16 2003 14:59:00   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/ParameterListItem.java-arc  $
 * 
 *    Rev 1.0   Jul 16 2003 14:59:00   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.util.HashMap;
import java.util.Map;

import net.arcor.fif.common.FIFException;

/**
 * This class represents an item in a parameter list.
 * It can contain simple parameters and parameter lists.
 * @author goethalo
 */
public class ParameterListItem {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The map of parameters
     */
    private Map params = null;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     * @throws FIFException
     */
    public ParameterListItem() throws FIFException {
        params = new HashMap();
    }

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * Returns the params.
     * @return Map
     */
    public Map getParams() {
        return params;
    }

    /**
     * Sets the params.
     * @param params The params to set
     */
    public void setParams(Map params) throws FIFException {
        if (params == null) {
            throw new FIFException("Cannot set a null params object in setParams()");
        }
        this.params = params;
    }

    /**
     * Adds a parameter to the list item.
     * @param param  the parameter to be added
     * @throws FIFException if the passed in parameter is null
     */
    public void addParam(Parameter param) throws FIFException {
        if (param == null) {
            throw new FIFException(
                "Cannot add parameter because a null pointer was passed "
                    + "to addParams(param).");
        }
        params.put(param.getName(), param);
    }

    /**
     * Gets a parameter from the list item.
     * @param name  the name of the parameter to get the value from.
     * @return a Parameter object, null if the parameter does not exist.
     */
    public Parameter getParam(String name) {
        return ((Parameter) params.get(name));
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
        sb.append("\nParameterListItem (");
        sb.append("params: ");
        Object[] list = params.values().toArray();
        for (int i = 0; i < list.length; i++) {
            sb.append(((Parameter) list[i]).toString());
        }
        sb.append(")");
        return sb.toString();
    }

}
