/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/ParameterListMetaData.java-arc   1.0   Apr 09 2003 09:34:40   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/ParameterListMetaData.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:40   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.util.ArrayList;

import net.arcor.fif.common.FIFException;

/**
 * @author goethalo
 */
public class ParameterListMetaData extends ParameterMetaData {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * Indicates whether the parameter is mandatory.
     */
    private boolean mandatory = true;

    /**
     * The metadata of the list parameters.
     */
    private ArrayList paramsMetaData = null;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     * @param name  the name of the parameter the metadata relates to.
     */
    public ParameterListMetaData(String name) throws FIFException {
        super(name);
        paramsMetaData = new ArrayList();
    }

    /**
     * Constructor.
     * @param name          the name of the parameter the metadata relates to
     * @param mandatory     indicates whether the parameter is mandatory
     */
    public ParameterListMetaData(String name, boolean mandatory)
        throws FIFException {
        super(name);
        this.mandatory = mandatory;
        paramsMetaData = new ArrayList();
    }

    /**
     * Constructor.
     * @param name          the name of the parameter the metadata relates to
     * @param mandatory     indicates whether the parameter is mandatory
     */
    public ParameterListMetaData(
        String name,
        boolean mandatory,
        ArrayList paramsMetaData)
        throws FIFException {
        super(name);
        this.paramsMetaData = paramsMetaData;
        if (paramsMetaData == null) {
            throw new FIFException(
                "Cannot create ParameterListMetaData because the passed "
                    + "in paramsMetaData object is null");
        }
    }

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * @return boolean
     */
    public boolean isMandatory() {
        return mandatory;
    }

    /**
     * Sets the mandatory.
     * @param mandatory indicates whether the parameter is mandatory
     */
    public void setMandatory(boolean mandatory) {
        this.mandatory = mandatory;
    }

    /**
     * @return ArrayList
     */
    public ArrayList getParamsMetaData() {
        return paramsMetaData;
    }

    /**
     * Sets the paramsMetaData.
     * @param paramsMetaData the metadata of the list parameters to set
     */
    public void setParamsMetaData(ArrayList paramsMetaData)
        throws FIFException {
        if (paramsMetaData == null) {
            throw new FIFException(
                "Cannot set a null paramsMetaData object in "
                    + "setParamsMetaDat()");
        }
        this.paramsMetaData = paramsMetaData;
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * @see net.arcor.fif.messagecreator.ParameterMetaData#equals(java.lang.Object)
     */
    public boolean equals(Object obj) {
        return (
            (obj != null)
                && (obj instanceof ParameterListMetaData)
                && (((Parameter) obj).getName() == getName()));
    }

    /**
     * Adds the metadata of a parameter to the parameter list metadata.
     * @param paramMetaData  the metadata of the parameter to add to the list.
     * @throws FIFException if the passed in <code>ParameterMetaData</code> object is <code>null</code>.
     */
    public void addParamMetaData(ParameterMetaData paramMetaData)
        throws FIFException {
        if (paramMetaData == null) {
            throw new FIFException(
                "Cannot set a null paramMetaData object in "
                    + "addParamMetaData()");
        }
        paramsMetaData.add(paramMetaData);
    }

    /**
     * Writes the contents of this object as a <code>String</code>
     * @see java.lang.Object#toString()
     */
    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append("\nParameterListMetaData (");
        sb.append("name: ");
        sb.append(getName());
        sb.append(", mandatory: ");
        sb.append(mandatory);
        sb.append(", paramsMetaData: ");
        for (int i = 0; i < paramsMetaData.size(); i++) {
            sb.append(((ParameterMetaData) paramsMetaData.get(i)).toString());
        }
        sb.append(")");
        return sb.toString();
    }

}
