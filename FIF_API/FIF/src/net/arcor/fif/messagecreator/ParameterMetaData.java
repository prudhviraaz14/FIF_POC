/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/ParameterMetaData.java-arc   1.0   Apr 09 2003 09:34:42   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/ParameterMetaData.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:42   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import net.arcor.fif.common.FIFException;

/**
 * @author goethalo
 */
public abstract class ParameterMetaData {

	/*------------------*
	 * MEMBER VARIABLES *
	 *------------------*/

	/**
	 * The name of the parameter the metadata is related to.
	 */
	private String name = null;


	/*--------------*
	 * CONSTRUCTORS *
	 *--------------*/

	/**
	 * Constructor
	 * @param name  the name of the parameter the metadata is related to
	 */
	public ParameterMetaData(String name) throws FIFException {
		if ((name == null) || (name.trim().length() == 0)) {
			throw new FIFException(
				"Cannot create ParameterMetaData because the passed "
				+ "in name is null or empty");
		}
		this.name = name;
	}


	/*---------------------*
	 * GETTERS AND SETTERS *
	 *---------------------*/

	/**
	 * @return String
	 */
	public String getName() {
		return name;
	}


	/*---------*
	 * METHODS *
	 *---------*/

	/**
	 * Determines if the object is equal to another object
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	public abstract boolean equals(Object obj);


	/**
	 * Generates the hashcode for this object.
	 * The hashcode is generator based on the name of the object. It consists
	 * of a call to <code>name.hashCode()</code> to use the standard
	 * <code>String</code> class method.
	 * @see java.lang.Object#hashCode()
	 */
	public int hashCode() {
		return name.hashCode();
	}

    /**
     * Writes the contents of this object as a <code>String</code>
     * @see java.lang.Object#toString()
     */
    public abstract String toString();
}
