/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/RequestMetaData.java-arc   1.0   Apr 09 2003 09:34:42   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/RequestMetaData.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:42   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.util.Map;

/**
 * @author goethalo
 *
 * To change this generated comment edit the template variable "typecomment":
 * Window>Preferences>Java>Templates.
 * To enable and disable the creation of type comments go to
 * Window>Preferences>Java>Code Generation.
 */
public class RequestMetaData {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

	private Map fieldmetadata = null;

	private String action = null;


    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

	/**
	 * Returns the fieldmetadata.
	 * @return Map
	 */
	public Map getFieldmetadata() {
		return fieldmetadata;
	}

	/**
	 * Sets the fieldmetadata.
	 * @param fieldmetadata The fieldmetadata to set
	 */
	public void setFieldmetadata(Map fieldmetadata) {
		this.fieldmetadata = fieldmetadata;
	}

}
