/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/MessageCreatorDefinition.java-arc   1.0   Apr 09 2003 09:34:38   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/MessageCreatorDefinition.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:38   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.util.ArrayList;

import net.arcor.fif.common.FIFException;

/**
 * This class represents a message creator definition.
 * It contains information about a message creator type and
 * links its name to a java class name.
 *
 * @author goethalo
 */
public class MessageCreatorDefinition {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The name of the message creator type.
     */
    private String typeName = null;

    /**
     * The class name of the message creator.
     */
    private String className = null;

    /**
     * The names of the creator parameters
     */
    private ArrayList paramNames = null;

    /**
     * The supported input request type.
     */
    private String inputRequestType = null;

    /**
     * The supported output message type.
     */
    private String outputMessageType = null;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor
     * @param typeName  the type name of the message creator.
     * @throws FIFException
     */
    public MessageCreatorDefinition(String typeName) throws FIFException {
        if ((typeName == null || typeName.trim().length() == 0)) {
            throw new FIFException(
                "Cannot create the MessageCreatorDefinition object because "
                    + "an empty typeName was passed in");
        }
        this.typeName = typeName;
        paramNames = new ArrayList();
    }

    /**
     * Constructor.
     * @param typeName           the type name of the message creator.
     * @param className          the java class name of the message creator
     * @param paramNames         the list of creator parameter names
     * @param inputRequestType   the input request type name
     * @param outputMessageType  the output message type name
     * @throws FIFException
     */
    public MessageCreatorDefinition(
        String typeName,
        String className,
        ArrayList paramNames,
        String inputRequestType,
        String outputMessageType)
        throws FIFException {
        this(typeName);
        setClassName(className);
        setInputRequestType(inputRequestType);
        setOutputMessageType(outputMessageType);
        if (paramNames == null) {
            throw new FIFException(
                "Cannot create the MessageCreatorDefinition object because "
                    + "a null paramNames object was passed in");
        }
        this.paramNames = paramNames;
    }

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * @return String
     */
    public String getClassName() {
        return className;
    }

    /**
     * @return String
     */
    public String getInputRequestType() {
        return inputRequestType;
    }

    /**
     * @return String
     */
    public String getOutputMessageType() {
        return outputMessageType;
    }

    /**
     * @return ArrayList
     */
    public ArrayList getParamNames() {
        return paramNames;
    }

    /**
     * @return String
     */
    public String getTypeName() {
        return typeName;
    }

    /**
     * Sets the className.
     * @param className The className to set
     */
    public void setClassName(String className) throws FIFException {
        if ((className == null || className.trim().length() == 0)) {
            throw new FIFException("Cannot set the className because it is null or empty");
        }
        this.className = className;
    }

    /**
     * Sets the inputRequestType.
     * @param inputRequestType The inputRequestType to set
     */
    public void setInputRequestType(String inputRequestType)
        throws FIFException {
        if ((inputRequestType == null)
            || (inputRequestType.trim().length() == 0)) {
            throw new FIFException("Cannot set the inputRequestType because it is null or empty");
        }
        this.inputRequestType = inputRequestType;
    }

    /**
     * Sets the outputMessageType.
     * @param outputMessageType The outputMessageType to set
     */
    public void setOutputMessageType(String outputMessageType)
        throws FIFException {
        if ((outputMessageType == null)
            || (outputMessageType.trim().length() == 0)) {
            throw new FIFException("Cannot set the outputMessageType because it is null or empty");
        }
        this.outputMessageType = outputMessageType;
    }

    /**
     * Sets the paramNames.
     * @param paramNames The paramNames to set
     */
    public void setParamNames(ArrayList paramNames) throws FIFException {
        if (paramNames == null) {
            throw new FIFException(
                "Cannot set the paramNames because "
                    + "a null paramNames object was passed in");
        }
        this.paramNames = paramNames;
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Adds a parameter name to the message creator parameters.
     * @param paramName  the parameter name to add to the list
     * @throws FIFException if the passed in <code>String</code>
     * object is <code>null</code> or empty.
     */
    public void addParamName(String paramName) throws FIFException {
        if ((paramName == null) || (paramName.trim().length() == 0)) {
            throw new FIFException(
                "Cannot set a null paramName object in " + "addParamName()");
        }
        paramNames.add(paramName);
    }

    /**
     * Writes the contents of this object as a <code>String</code>
     * @see java.lang.Object#toString()
     */
    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append("\nMessageCreatorDefinition (typeName: ");
        sb.append(typeName);
        sb.append(", className: ");
        sb.append(className);
        sb.append(", paramNames: (");
        for (int i = 0; i < paramNames.size(); i++) {
            sb.append((String) paramNames.get(i));
            if (i != paramNames.size() - 1)
                sb.append(",");
        }
        sb.append("), inputRequestType: ");
        sb.append(inputRequestType);
        sb.append(", outputMessageType: ");
        sb.append(outputMessageType);
        sb.append(")");
        return sb.toString();
    }

}
