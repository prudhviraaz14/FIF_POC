/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/XSQLMessageCreatorConnectionManagerFactory.java-arc   1.0   Apr 09 2003 09:34:46   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/XSQLMessageCreatorConnectionManagerFactory.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:46   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import org.apache.log4j.Logger;

import oracle.xml.xsql.XSQLConnectionManager;
import oracle.xml.xsql.XSQLConnectionManagerFactory;

/**
 * Database connection manager factory for the
 * XSQL Message Creator.
 * This is needed to support encrypted database passwords
 * in the Oracle XSQL engine.
 * @author goethalo
 */
public class XSQLMessageCreatorConnectionManagerFactory
    implements XSQLConnectionManagerFactory {

    /**
     * The log4j logger
     */
    private static Logger logger =
        Logger.getLogger(XSQLMessageCreatorConnectionManagerFactory.class);

    /**
     * Constructor.
     */
    public XSQLMessageCreatorConnectionManagerFactory() {
    }

    /**
     * Creates an XSQLConnectionManager
     * @see oracle.xml.xsql.XSQLConnectionManagerFactory#create()
     */
    public XSQLConnectionManager create() {
        return new XSQLMessageCreatorConnectionManager();
    }

}
