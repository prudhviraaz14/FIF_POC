/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/PSMDataAccess.java-arc   1.0   Jan 15 2019 16:50:54   lejam  $
 *    $Revision:   1.0  $
 *    $Workfile:   PSMDataAccess.java  $
 *      $Author:   lejam  $
 *        $Date:   Jan 15 2019 16:50:54  $
 *
 *  
 *  Copyright (C) Vodafone
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/PSMDataAccess.java-arc  $
 * 
 *    Rev 1.0   Jan 15 2019 16:50:54   lejam
 * Initial revision.
 * 
 ***************************************************************************  
 */
package net.arcor.fif.db;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.common.FIFException;


public class PSMDataAccess extends DataAccess {

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement getDataTypeForServiceCharCode = null;

	/**
	 * Constructor using default db alias
	 * @throws FIFException
	 */
	public PSMDataAccess() throws FIFException {
		super("default");
		init();
	}
    
	/**
	 * Constructor using db alias from input
	 * @param dbAlias
	 * @throws FIFException
	 */
	public PSMDataAccess(String dbAlias) throws FIFException {
		super(dbAlias);
		init();
	}
    
	public PSMDataAccess(Connection conn) throws FIFException {
		super(conn);
		init();
	}

    /* (non-Javadoc)
     * @see net.arcor.fif.db.DataAccess#init()
     */
    public synchronized void init() throws FIFException {
    	if (initialized) return;
    	
    	try {    		
    		logger.info("Preparing database statements...");
    		
    		getDataTypeForServiceCharCode = conn.prepareStatement("select datatype_value || characteristic_type_value data_type from service_characteristic where service_char_code = ?");
    	} catch (SQLException e) {
    		throw new FIFException(
    				"Error while initializing PSM data access.", e);
    	}
    	initialized = true;    	
    }


    /* (non-Javadoc)
     * @see net.arcor.fif.db.DataAccess#closeStatements()
     */
    public synchronized void closeStatements() {
    	try {    		
    		if (getDataTypeForServiceCharCode != null)
    			getDataTypeForServiceCharCode.close();
			if (conn != null)
				conn.close();
		} catch (SQLException e) {
			logger.fatal("Cannot close the statements.", e);
		}
    }

    public synchronized String getDataTypeForServiceCharCode (String serviceCharCode) throws FIFException {
    	logger.info("Retrieving dataType for serviceCharCode " + serviceCharCode);
    	try {    	
    		getDataTypeForServiceCharCode.clearParameters();
    		getDataTypeForServiceCharCode.setString(1, serviceCharCode);
    		ResultSet result = getDataTypeForServiceCharCode.executeQuery();

    		String dataType = null;
    		if (result.next())
    			dataType = result.getString(1);
    		result.close();
    		return dataType;
    	} catch (SQLException e) {
			logger.fatal("PSMDataAccess::getDataTypeForServiceCharCode.", e);
    		throw new FIFException("Error while retrieving dataType for serviceCharCode "
    				+ serviceCharCode, e); 
    	}
    }

}
