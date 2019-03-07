package net.arcor.fif.db;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.messagecreator.FIFError;
import net.arcor.fif.messagecreator.Parameter;
import net.arcor.fif.messagecreator.SimpleParameter;

public class FailedRequestNotificationDataAccess extends DataAccess {

	private PreparedStatement getTransactionIDStmt = null;
	private PreparedStatement insertFailedRequestStmt = null;
	private PreparedStatement insertFailedRequestParamStmt = null;
	private PreparedStatement insertFailedRequestParamListStmt = null;
    
	public FailedRequestNotificationDataAccess() throws FIFException {
		super("default");
		init();
	}
    
	public FailedRequestNotificationDataAccess(String dbAlias) throws FIFException {
		super(dbAlias);
		init();
	}
	
    public void init() throws FIFException {
    	if (initialized)
    		return;
    	initialized = true;
    	
		try {
			logger.info("Preparing database statements for failed request notification creation ...");
			// Prepare the database statements
			getTransactionIDStmt = conn.prepareStatement(
					ClientConfig.getSetting("SynchronousFifClient.FailedRequestNotification.GetTransactionID.Statement"));
				
			insertFailedRequestStmt = conn.prepareStatement(
					ClientConfig.getSetting("SynchronousFifClient.FailedRequestNotification.InsertRequest.Statement"));
				
			insertFailedRequestParamStmt = conn.prepareStatement(
					ClientConfig.getSetting("SynchronousFifClient.FailedRequestNotification.InsertRequestParam.Statement"));
			
			insertFailedRequestParamListStmt = conn.prepareStatement(
					ClientConfig.getSetting("SynchronousFifClient.FailedRequestNotification.InsertRequestParamList.Statement"));
		} catch (SQLException e) {
			throw new FIFException(e);
		}
    }

    public synchronized void insertFailedRequestNotification (FailedRequestNotification failedRequestNotification) throws FIFException {		
		try {
			insertFailedRequestStmt.clearParameters();
			insertFailedRequestParamStmt.clearParameters();
			insertFailedRequestParamListStmt.clearParameters();
			
			failedRequestNotification.setId(generateTransactionID());
			insertFailedRequestStmt.setString(1, failedRequestNotification.getId());
			insertFailedRequestStmt.setString(2, failedRequestNotification.getExternalSystemID());
			insertFailedRequestStmt.execute();
			
			insertFailedRequestParamStmt.setString(1, failedRequestNotification.getId());
			insertFailedRequestParamListStmt.setString(1, failedRequestNotification.getId());
					
			insertFailedRequestParamStmt.setString(2, "actionName");
			insertFailedRequestParamStmt.setString(3, failedRequestNotification.getActionName());
			insertFailedRequestParamStmt.execute();
			
			// add error messages
			int listItemNumberErrors = 0;
			insertFailedRequestParamListStmt.setString(2, "errorMessages");
			for (FIFError error : failedRequestNotification.getRequestErrors()) {
				insertFailedRequestParamListStmt.setInt(3, ++listItemNumberErrors);
				
				if (error.getNumber() != null && !(error.getNumber().equals(""))) {
					insertFailedRequestParamListStmt.setString(4, "errorCode");
					insertFailedRequestParamListStmt.setString(5, error.getNumber());
					insertFailedRequestParamListStmt.execute();
				}
				
				if (error.getMessage() != null && !(error.getMessage().equals(""))) {
					insertFailedRequestParamListStmt.setString(4, "errorText");
					insertFailedRequestParamListStmt.setString(5, error.getMessage());
					insertFailedRequestParamListStmt.execute();
				}
			}
			
			// add parameters of the fif request
			insertFailedRequestParamListStmt.setString(2, "parameterList");
			int listItemNumberParameters = 0;
			for (Object key : failedRequestNotification.getRequestParams().keySet()) {
				insertFailedRequestParamListStmt.setInt(3, ++listItemNumberParameters);
				Parameter parameter = (Parameter) failedRequestNotification.getRequestParams().get(key);
				if (parameter instanceof SimpleParameter) {
					String value = ((SimpleParameter) parameter).getValue();
					String name = ((SimpleParameter) parameter).getName();
					
					// don't insert if the parameter is empty
					if (value == null || value.equals("") || name == null || name.equals("") || value.length() > 4000)
						continue;
					
					insertFailedRequestParamListStmt.setString(4, "name");
					insertFailedRequestParamListStmt.setString(5, name);
					insertFailedRequestParamListStmt.execute();
					
					insertFailedRequestParamListStmt.setString(4, "value");
					insertFailedRequestParamListStmt.setString(5, value);
					insertFailedRequestParamListStmt.execute();
				}
			}

			commit();
		} catch (SQLException e) {
			try {
				rollback();
			} catch (FIFException sqle) {}			
			logger.error("Exception while creating notification for request, see details:", e);
			throw new FIFException(e);
		}
    }

	/**
	 * @throws SQLException
	 */
	private String generateTransactionID() throws SQLException {
		String id = null; 
		ResultSet result = getTransactionIDStmt.executeQuery();		
		if (result.next())
			id = result.getString(1);
		result.close();
		return id;
	}

    public void closeStatements() {
    	try {
    		getTransactionIDStmt.close();
			insertFailedRequestParamListStmt.close();
			insertFailedRequestParamStmt.close();
			insertFailedRequestStmt.close();
			if (conn != null)
				conn.close();
		} catch (SQLException e) {
			logger.fatal("Cannot close the statements.", e);
		}
    }

}
