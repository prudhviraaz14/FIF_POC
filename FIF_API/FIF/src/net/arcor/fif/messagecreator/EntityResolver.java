/*
 $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/EntityResolver.java-arc   1.0   Sep 19 2005 15:20:24   banania  $

 $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/EntityResolver.java-arc  $
 * 
 *    Rev 1.0   Sep 19 2005 15:20:24   banania
 * Initial revision.
 */
package net.arcor.fif.messagecreator;

import java.io.IOException;

import net.arcor.fif.common.FIFException;

import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * @author banania
 * 
 * This class implements org.xml.sax.EntityResolver. It is used for resolving
 * the DTDs if there're stored in a different directory than the application.
 */
public class EntityResolver implements org.xml.sax.EntityResolver {

	/**
	 * @see org.xml.sax.EntityResolver#resolveEntity(java.lang.String,
	 *      java.lang.String)
	 */
	public InputSource resolveEntity(String publicId, String systemId)
			throws SAXException, IOException {

		if (systemId != null) {

			String strDTDDir;

			try {
				strDTDDir = MessageCreatorConfig
						.getPath("messagecreator.DTDDir");
			} catch (FIFException e) {
				// Just ignore the exception if "messagecreator.DTDDir" is not
				// set the configaration file.
				// Use in this case the default behaviour.
				return null;
			}

			String strDTDName;
			int index = systemId.lastIndexOf("/");
			if (index > 0) {
				strDTDName = systemId.substring(index + 1);
				if (strDTDName.endsWith(".dtd")) {
					return new InputSource(strDTDDir + strDTDName);
				}
			}
		}
		return null;
	}
}