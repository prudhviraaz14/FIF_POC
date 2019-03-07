/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/ActionMapping.java-arc   1.1   Oct 07 2003 14:51:26   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/ActionMapping.java-arc  $
 * 
 *    Rev 1.1   Oct 07 2003 14:51:26   goethalo
 * Changes for IT-9811 - Internet By Call with Registration
 * 
 *    Rev 1.0   Apr 09 2003 09:34:36   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import net.arcor.fif.common.FIFException;

/**
 * This class represents an action mapping.
 * It contains information about which message creator to use
 * for a specific action and which parameters to expect.
 *
 * @author goethalo
 */
public class ActionMapping {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The name of the action the object is related to.
     */
    private String actionName = null;

    /**
     * The type name of the creator to use for the action.
     */
    private String creatorType = null;

    /**
     * The parameters for the creator of this action.
     */
    private Map creatorParams = null;

    /**
     * The message parameter metadata for this action
     */
    private ArrayList messageParams = null;

    /**
     * Indicates whether the warnings in the response message should be
     * part of the output.
     */
    private boolean returnWarnings = false;

    /**
     * The list of response parameters to include in the output.
     */
    private ArrayList outputParams = null;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     * @param actionName   the name of the action this mapping is for.
     * @param creatorType  the type of the creator to use for this action.
     * @throws FIFException
     */
    public ActionMapping(String actionName, String creatorType)
        throws FIFException {
        if ((actionName == null) || (actionName.trim().length() == 0)) {
            throw new FIFException(
                "Cannot create the ActionMapping object because "
                    + "a null or empty actionName was passed in");
        }
        this.actionName = actionName;
        if ((creatorType == null) || (creatorType.trim().length() == 0)) {
            throw new FIFException(
                "Cannot create the ActionMapping object because "
                    + "a null or empty creatorType was passed in");
        }
        this.creatorType = creatorType;
        creatorParams = new HashMap();
        messageParams = new ArrayList();
        returnWarnings = false;
        outputParams = new ArrayList();
    }

    /**
     * Constructor.
     * @param actionName     the name of the action this mapping is for.
     * @param creatorType    the name of the creator type to use to generate the message.
     * @param creatorParams  the creator parameters for the message creator.
     * @param messageParams  the message parameters.
     * @throws FIFException
     */
    public ActionMapping(
        String actionName,
        String creatorType,
        Map creatorParams,
        ArrayList messageParams,
        boolean returnWarnings,
        ArrayList outputParams)
        throws FIFException {
        this(actionName, creatorType);
        setCreatorParams(creatorParams);
        setMessageParams(messageParams);
        setReturnWarnings(returnWarnings);
        setOutputParams(outputParams);
    }

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * Gets the action name for the action.
     * @return the action name.
     */
    public String getActionName() {
        return actionName;
    }

    /**
     * Gets the creator parameters for the action.
     * @return the creator parameters.
     */
    public Map getCreatorParams() {
        return creatorParams;
    }

    /**
     * Gets the creator type for the action.
     * @return the creator type.
     */
    public String getCreatorType() {
        return creatorType;
    }

    /**
     * Gets the message parameters for the action.
     * @return the message parameters.
     */
    public ArrayList getMessageParams() {
        return messageParams;
    }

    /**
     * Gets the output parameters for the action.
     * @return the output parameters.
     */
    public ArrayList getOutputParams() {
        return outputParams;
    }

    /**
     * Determines wether warnings should be returned to the client.
     * @return true if warnings should be returned, false if not.
     */
    public boolean returnWarnings() {
        return returnWarnings;
    }

    /**
     * Sets the creatorParams.
     * @param creatorParams The creatorParams to set
     */
    public void setCreatorParams(Map creatorParams) throws FIFException {
        if ((creatorParams == null)) {
            throw new FIFException(
                "Cannot set the creatorParams because a null object "
                    + "was passed in");
        }
        this.creatorParams = creatorParams;
    }

    /**
     * Sets the messageParams.
     * @param messageParams The messageParams to set
     */
    public void setMessageParams(ArrayList messageParams) throws FIFException {
        if ((messageParams == null)) {
            throw new FIFException(
                "Cannot set the messageParams because a null object "
                    + "was passed in");
        }
        this.messageParams = messageParams;
    }

    /**
     * Sets the output parameters.
     * @param outputParams  The output parameters to set.
     */
    public void setOutputParams(ArrayList outputParams) throws FIFException {
        if ((outputParams == null)) {
            throw new FIFException(
                "Cannot set the outputParams because a null object "
                    + "was passed in");
        }
        this.outputParams = outputParams;
    }

    /**
     * Sets whether to return warnings in the output.
     * @param returnWarnings  
     */
    public void setReturnWarnings(boolean returnWarnings) {
        this.returnWarnings = returnWarnings;
    }

    /**
     * Writes the contents of this object as a <code>String</code>
     * @see java.lang.Object#toString()
     */
    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append("\nActionMapping (actionName: ");
        sb.append(actionName);
        sb.append(", creatorType: ");
        sb.append(creatorType);
        sb.append(", creatorParams:\n");
        Object[] list = creatorParams.values().toArray();
        for (int i = 0; i < list.length; i++) {
            sb.append(((SimpleParameter) list[i]).toString());
        }
        sb.append(", messageParams: ");
        for (int i = 0; i < messageParams.size(); i++) {
            sb.append("\nMessageParam #" + (i + 1) + ":\n");
            sb.append(((ParameterMetaData) messageParams.get(i)).toString());
        }
        sb.append(", returnWarnings: " + returnWarnings);
        sb.append(", outputParams: ");
        for (int i = 0; i < outputParams.size(); i++) {
            sb.append("\nOutputParam #" + (i + 1) + ":\n");
            sb.append(((OutputParameterMetaData) outputParams.get(i)).toString());
        }        
        sb.append(")");
        return sb.toString();
    }
}
