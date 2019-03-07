/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/RequestDefinition.java-arc   1.0   Apr 09 2003 09:34:42   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/RequestDefinition.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:42   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import net.arcor.fif.common.FIFException;

/**
 * This class represents a request definition.
 * It links the name of a request type to its java class name.
 *
 * @author goethalo
 */
public class RequestDefinition {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The name of the request type.
     */
    private String typeName = null;

    /**
     * The class name of the request.
     */
    private String className = null;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     * @param typeName   the name of the request type.
     * @param className  the java class name of the request.
     * @throws FIFException
     */
    public RequestDefinition(String typeName, String className)
        throws FIFException {
        if (((typeName == null) || (typeName.trim().length() == 0))
            || ((className == null) || (className.trim().length() == 0))) {
            throw new FIFException(
                "Cannot create the RequestDefinition object because an empty "
                    + "typeName or className was passed in");
        }
        this.typeName = typeName;
        this.className = className;
    }

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * Gets the class name.
     * @return String
     */
    public String getClassName() {
        return className;
    }

    /**
     * Gets the type name.
     * @return String
     */
    public String getTypeName() {
        return typeName;
    }

    /**
     * Writes the contents of this object as a <code>String</code>
     * @see java.lang.Object#toString()
     */
    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append("\nRequestDefinition (typeName: ");
        sb.append(typeName);
        sb.append(", className: ");
        sb.append(className);
        sb.append(")");
        return sb.toString();
    }
}
