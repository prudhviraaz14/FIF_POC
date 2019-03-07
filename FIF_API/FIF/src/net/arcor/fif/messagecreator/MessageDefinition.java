/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/MessageDefinition.java-arc   1.0   Apr 09 2003 09:34:38   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/MessageDefinition.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:38   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import net.arcor.fif.common.FIFException;

/**
 * This class represents a message definition.
 * It links the name of a message type to its java class name.
 *
 * @author goethalo
 */
public class MessageDefinition {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The name of the message type.
     */
    private String typeName = null;

    /**
     * The class name of the message.
     */
    private String className = null;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     * @param typeName   the name of the message type.
     * @param className  the java class name of the message.
     * @throws FIFException
     */
    public MessageDefinition(String typeName, String className)
        throws FIFException {
        if ((typeName == null || typeName.length() == 0)
            || (className == null || className.length() == 0)) {
            throw new FIFException(
                "Cannot create the MessageDefinition object because an empty "
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
        sb.append("\nMessageDefinition (typeName: ");
        sb.append(typeName);
        sb.append(", className: ");
        sb.append(className);
        sb.append(")");
        return sb.toString();
    }

}
