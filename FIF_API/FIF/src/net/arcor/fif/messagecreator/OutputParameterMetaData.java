/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/OutputParameterMetaData.java-arc   1.1   Dec 17 2003 14:56:12   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/OutputParameterMetaData.java-arc  $
 * 
 *    Rev 1.1   Dec 17 2003 14:56:12   goethalo
 * Changes for IT-9245: ISDN changes.
 * 
 *    Rev 1.0   Oct 07 2003 14:51:52   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import net.arcor.fif.common.FIFException;

/**
 * Class representing the metadata about an output parameter.
 * @author goethalo
 */
public class OutputParameterMetaData {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The ID of the command the parameter is coming from.
     */
    private String responseCommandID = null;

    /**
     * The name of the parameter in the incoming response message.
     */
    private String responseName = null;

    /**
     * The name to use for the parameter in the output.
     */
    private String outputName = null;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor
     * @param responseName  the name of the parameter in the incoming 
     *                      response message.
     * @param outputName    the name to use for the parameter in the output.
     */
    public OutputParameterMetaData(String responseName, String outputName)
        throws FIFException {
        if ((responseName == null) || (responseName.trim().length() == 0)) {
            throw new FIFException(
                "Cannot create OutputParameterMetaData because the passed "
                    + "in responseName is null or empty");
        }
        if ((outputName == null) || (outputName.trim().length() == 0)) {
            throw new FIFException(
                "Cannot create OutputParameterMetaData because the passed "
                    + "in outputName is null or empty");
        }
        this.responseCommandID = "";
        this.responseName = responseName;
        this.outputName = outputName;
    }

    /**
     * Constructor
     * @param responseCommandID  the ID of the command to get the parameter from.
     * @param responseName       the name of the parameter in the incoming 
     *                           response message.
     * @param outputName         the name to use for the parameter in the output.
     */
    public OutputParameterMetaData(
        String responseCommandID,
        String responseName,
        String outputName)
        throws FIFException {
        if ((responseCommandID == null)
            || (responseCommandID.trim().length() == 0)) {
            throw new FIFException(
                "Cannot create OutputParameterMetaData because the passed "
                    + "in responseCommandID is null or empty");
        }
        if ((responseName == null) || (responseName.trim().length() == 0)) {
            throw new FIFException(
                "Cannot create OutputParameterMetaData because the passed "
                    + "in responseName is null or empty");
        }
        if ((outputName == null) || (outputName.trim().length() == 0)) {
            throw new FIFException(
                "Cannot create OutputParameterMetaData because the passed "
                    + "in outputName is null or empty");
        }
        this.responseCommandID = responseCommandID;
        this.responseName = responseName;
        this.outputName = outputName;
    }

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * Gets the command ID to take the parameter from.
     * @return  rge command ID to take the parameter from.
     */
    public String getResponseCommandID() {
        return responseCommandID;
    }

    /**
     * Gets the output parameter name.
     * @return  the name of the output parameter.
     */
    public String getOutputName() {
        return outputName;
    }

    /**
     * Gets the response parameter name.
     * @return   the name of the parameter in the response message.
     */
    public String getResponseName() {
        return responseName;
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
        sb.append("\nOutputParameterMetaData (");
        sb.append("responseCommandID: ");
        sb.append(getResponseCommandID());
        sb.append("responseName: ");
        sb.append(getResponseName());
        sb.append(", outputName: ");
        sb.append(getOutputName());
        sb.append(")");
        return sb.toString();
    }

}
