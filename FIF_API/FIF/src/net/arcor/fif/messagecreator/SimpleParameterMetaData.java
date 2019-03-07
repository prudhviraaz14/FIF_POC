/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/SimpleParameterMetaData.java-arc   1.1   Nov 21 2013 08:52:16   schwarje  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/SimpleParameterMetaData.java-arc  $
 * 
 *    Rev 1.1   Nov 21 2013 08:52:16   schwarje
 * IT-k-32850: generic validation of input parameters configured in metadata (first use case: CCB date format)
 * 
 *    Rev 1.0   Apr 09 2003 09:34:42   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import net.arcor.fif.common.FIFException;

/**
 * @author goethalo
 */
public class SimpleParameterMetaData extends ParameterMetaData {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * Indicates whether the parameter is mandatory.
     */
    private boolean mandatory = true;

    /**
     * The <code>String</code> default value of the parameter
     */
    private String defaultValue = null;

    /**
     * The validation method to apply for the parameter
     */
    private String validationMethod = null;
    


    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

	/**
     * Constructor.
     * @param name  the name of the parameter the metadata relates to.
     */
    public SimpleParameterMetaData(String name)
        throws FIFException {
        super(name);
    }

    /**
     * Constructor.
     * @param name          the name of the parameter the metadata relates to
     * @param mandatory     indicates whether the parameter is mandatory
     * @param defaultValue  the default value of the parameter
     */
    public SimpleParameterMetaData(String name,
                                    boolean mandatory,
                                    String defaultValue,
                                    String validationMethod)
                                        throws FIFException {
        super(name);
        this.mandatory = mandatory;
        this.defaultValue = defaultValue;
        this.validationMethod = validationMethod;
    }


    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * @return String
     */
    public String getDefaultValue() {
        return defaultValue;
    }

    /**
     * @return boolean
     */
    public boolean isMandatory() {
        return mandatory;
    }

    /**
     * Sets the defaultValue.
     * @param defaultValue the default value to set
     */
    public void setDefaultValue(String defaultValue) {
        this.defaultValue = defaultValue;
    }

    /**
     * Sets the mandatory.
     * @param mandatory indicates whether the parameter is mandatory
     */
    public void setMandatory(boolean mandatory) {
        this.mandatory = mandatory;
    }

    public String getValidationMethod() {
		return validationMethod;
	}

	public void setValidationMethod(String validationMethod) {
		this.validationMethod = validationMethod;
	}


    /*---------*
     * METHODS *
     *---------*/

    /**
     * @see net.arcor.fif.messagecreator.ParameterMetaData#equals(java.lang.Object)
     */
    public boolean equals(Object obj) {
        return ((obj != null)
                 && (obj instanceof SimpleParameterMetaData)
                 && (((Parameter) obj).getName() == getName()));
    }

    /**
     * Writes the contents of this object as a <code>String</code>
     * @see java.lang.Object#toString()
     */
    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append("\nSimpleParameterMetaData (");
        sb.append("name: ");
        sb.append(getName());
        sb.append(", mandatory: ");
        sb.append(mandatory);
        sb.append(", defaultValue: ");
        sb.append(defaultValue);
        sb.append(")");
        return sb.toString();
    }
}
