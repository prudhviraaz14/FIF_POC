/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/SomTemplateDataAccess.java-arc   1.0   Dec 03 2013 06:33:54   schwarje  $
 *    $Revision:   1.0  $
 *    $Workfile:   SomTemplateDataAccess.java  $
 *      $Author:   schwarje  $
 *        $Date:   Dec 03 2013 06:33:54  $
 *
 *  
 *  Copyright (C) Vodafone
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/SomTemplateDataAccess.java-arc  $
 * 
 *    Rev 1.0   Dec 03 2013 06:33:54   schwarje
 * Initial revision.
 * 
 * 
 ***************************************************************************  
 */
package net.arcor.fif.db;

import java.sql.Clob;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import net.arcor.fif.common.FIFException;


public class SomTemplateDataAccess extends DataAccess {

    /**
     * The prepared statement for retrieving the requests
     */
    private PreparedStatement fetchSomTemplates = null;

   
	/**
	 * Constructor using default db alias
	 * @throws FIFException
	 */
	public SomTemplateDataAccess() throws FIFException {
		super("default");
		init();
	}
    
	/**
	 * Constructor using db alias from input
	 * @param dbAlias
	 * @throws FIFException
	 */
	public SomTemplateDataAccess(String dbAlias) throws FIFException {
		super(dbAlias);
		init();
	}
    
    /* (non-Javadoc)
     * @see net.arcor.fif.db.DataAccess#init()
     */
    public void init() throws FIFException {
    	if (initialized) return;
    	initialized = true;    	
    	
    	try {    		
    		logger.info("Preparing database statements...");
    		fetchSomTemplates = conn.prepareStatement("select som_template_id, description_text, IS_SUB_TEMPLATE, som_template from som_template");
    	} catch (SQLException e) {
    		throw new FIFException(
    				"Error while initializing Fif transaction data access.", e);
    	}
    }

    public synchronized ArrayList<SomTemplate> fetchSomTemplates() throws FIFException {
        if (fetchSomTemplates == null)
        	throw new FIFException("Logging of database access is not properly initialized");
        
    	try {
			if (logger.isDebugEnabled())
				logger.debug("Executing statement: select som_template_id, description_text, IS_SUB_TEMPLATE, som_template from som_template");
			ResultSet result = fetchSomTemplates.executeQuery();

			
	    	ArrayList<SomTemplate> somTemplates = new ArrayList<SomTemplate>();
			while (result.next()) {
				SomTemplate somTemplate = new SomTemplate();
				somTemplate.setSomTemplateID(result.getString("SOM_TEMPLATE_ID"));
				somTemplate.setDescriptionText(result.getString("DESCRIPTION_TEXT"));
				somTemplate.setSubTemplate(result.getString("IS_SUB_TEMPLATE") != null && result.getString("IS_SUB_TEMPLATE").equals("Y"));
				Clob somTemplateClob = result.getClob("SOM_TEMPLATE");
				if (somTemplateClob != null)
					somTemplate.setSomTemplate(somTemplateClob.getSubString(1, (int) somTemplateClob.length()));
				somTemplates.add(somTemplate);
			}

			result.close();
			
			return somTemplates;
		} catch (SQLException e) {
			throw new FIFException(e);
		}
    }
    
    /* (non-Javadoc)
     * @see net.arcor.fif.db.DataAccess#closeStatements()
     */
    public void closeStatements() {
    	try {
    		fetchSomTemplates.close();
			if (conn != null)
				conn.close();
		} catch (SQLException e) {
			logger.fatal("Cannot close the statements.", e);
		}
    }

}
