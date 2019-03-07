/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/ServiceBusRequestLogger.java-arc   1.18   Nov 02 2017 10:48:10   lejam  $
 *    $Revision:   1.18  $
 *    $Workfile:   ServiceBusRequestLogger.java  $
 *      $Author:   lejam  $
 *        $Date:   Nov 02 2017 10:48:10  $
 *
 *  Function: Main class of the service bus interface
 *  
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/ServiceBusRequestLogger.java-arc  $
 * 
 *    Rev 1.18   Nov 02 2017 10:48:10   lejam
 * RMS163028_PPM158506_250118 MCF2 java7 upgrade corrected CLOB handling in insertRequest
 * 
 *    Rev 1.17   Jul 09 2013 14:48:26   lejam
 * Added pointer check for paramValue in ServiceBusRequestLogger SPN-FIF-125008
 * 
 *    Rev 1.16   Jan 17 2013 15:34:04   schwarje
 * IT-32438: added parameter for automatic commit
 * 
 *    Rev 1.15   Jan 24 2011 14:30:10   wlazlow
 * SPN-FIF-000108281
 * 
 *    Rev 1.14   Dec 07 2010 19:53:02   wlazlow
 * IT-k-29305
 * 
 *    Rev 1.13   Sep 21 2010 21:15:54   wlazlow
 * SPN-CCB-000103309
 * 
 *    Rev 1.12   Mar 11 2010 13:13:10   schwarje
 * IT-26029: Decomissioning MQReader
 * 
 *    Rev 1.11   Dec 15 2009 16:49:58   makuier
 * If the parameter value is larger that 4000 save it in CLOB
 * 
 *    Rev 1.10   Apr 03 2009 15:50:32   schwarje
 * SPN-FIF-000084890: made retrieveRequest synchronous
 * 
 *    Rev 1.9   Mar 26 2009 16:44:40   schwarje
 * SPN-FIF-000084593: made SyncFIFClient thread-safe when running multithreaded
 * 
 *    Rev 1.8   Dec 05 2008 16:24:58   schwarje
 * IT-k-24294: added external system id for retrieveRequest
 * 
 *    Rev 1.7   Sep 15 2008 09:35:16   schwarje
 * SPN-FIF-000076119: improved request logging for service bus client
 * 
 *    Rev 1.6   Aug 21 2008 17:02:30   schwarje
 * IT-22684: added support for populating output parameters on service bus requests
 * 
 *    Rev 1.5   Jul 30 2008 16:29:42   schwarje
 * IT-k-23569: new FIF client for reading responses for service bus requests initiated from CCM
 * 
 *    Rev 1.4   Apr 24 2008 13:24:08   schwarje
 * IT-22324: added external system id
 * 
 *    Rev 1.3   Feb 28 2008 15:25:32   schwarje
 * IT-20793: added processing of events
 * 
 *    Rev 1.2   Feb 06 2008 20:04:06   schwarje
 * IT-20058: updated
 * 
 *    Rev 1.1   Jan 30 2008 13:06:52   schwarje
 * IT-20058: updated
 * 
 *    Rev 1.0   Jan 29 2008 17:44:18   schwarje
 * Initial revision.
 * 
 ***************************************************************************  
 */
package net.arcor.fif.client;

import java.sql.CallableStatement;
import java.sql.Clob;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.Map;

import net.arcor.fif.common.FIFException;
import oracle.jdbc.OracleTypes;
import oracle.sql.CLOB;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class ServiceBusRequestLogger {

	/**
	 * The connection to use for the database.
	 */
	protected final Log logger = LogFactory.getLog(getClass());
	private Connection connection = null;
	private int maxErrorMessageSize = 4000;
	boolean autoCommit = true;

	private PreparedStatement insertRequestStmt = null;
	private int insertRequestErrorCodeIndex;
	private int insertRequestErrorTextIndex;
	private int insertRequestPackageNameIndex;
	private int insertRequestServiceNameIndex;
	private int insertRequestRequestTypeIndex;
	private int insertRequestServiceBusClientNameIndex;
	private int insertRequestEnvironmentNameIndex;
	private int insertRequestStatusIndex;
	private int insertRequestSynchronousIndicatorIndex;
	private int insertRequestTransactionIDIndex;
	private int insertRequestRecycleStageIndex;
	private int insertRequestRecycleDelayIndex;
	private int insertRequestEventDueDateIndex;
	private int insertRequestExternalSystemIdIndex;
	private int insertRequestStartDateIndex;
	private int insertRequestEndDateIndex;
	
	private PreparedStatement updateRequestStmt = null;
	private int updateRequestErrorCodeIndex;
	private int updateRequestErrorTextIndex;
	private int updateRequestStatusIndex;
	private int updateRequestTransactionIDIndex;
	private int updateRequestRequestTypeIndex;
	private int updateRequestRecycleStageIndex;
	private int updateRequestRecycleDelayIndex;
	private int updateRequestStartDateIndex;
	private int updateRequestEndDateIndex;
	
	private PreparedStatement retrieveRequestStmt = null;
	private int retrieveRequestTransactionIDIndex;
	private int retrieveRequestPackageNameIndex;
	private int retrieveRequestServiceNameIndex;
	private int retrieveRequestRequestTypeIndex;
	private int retrieveRequestStatusIndex;
	private int retrieveRequestSynchronousIndicatorIndex;
	private int retrieveRequestRecycleStageIndex;
	private int retrieveRequestRecycleDelayIndex;
	private int retrieveRequestStartDateIndex;
	private int retrieveRequestEndDateIndex;
	private int retrieveRequestExternalSystemIdIndex;
	
	private PreparedStatement retrieveRequestParamsStmt = null;
	private int retrieveRequestParamsTransactionIDIndex;
	private int retrieveRequestParamsRequestTypeIndex;
	private int retrieveRequestParamsParamIndex;
	private int retrieveRequestParamsValueIndex;
	private int retrieveRequestParamsLongValueIndex;
	
	private PreparedStatement requestParamStmt = null;
	private int insertRequestParamParamIndex;
	private int insertRequestParamRequestTypeIndex;
	private int insertRequestParamTransactionIDIndex;
	private int insertRequestParamValueIndex;
	private int insertRequestParamCLOBIndex;
	
	private PreparedStatement requestParamListStmt = null;
	private int insertRequestParamListParamIndex;
	private int insertRequestParamListParamListIndex;
	private int insertRequestParamListTransactionIDIndex;
	private int insertRequestParamListRequestTypeIndex;
	private int insertRequestParamListValueIndex;
	private int insertRequestParamListListItemNumberIndex;
	
	private PreparedStatement requestResultStmt = null;
	private int insertRequestResultParamIndex;
	private int insertRequestResultRequestTypeIndex;
	private int insertRequestResultTransactionIDIndex;
	private int insertRequestResultValueIndex;
	
	public ServiceBusRequestLogger () throws FIFException, SQLException {
		init();
	}

	/**
	 * @throws FIFException
	 * @throws SQLException
	 */
	private void init() throws FIFException, SQLException {
		String dbAlias = ClientConfig.getSetting("servicebusclient.RequestLogging.DBAlias");

		connection = DriverManager.getConnection("jdbc:apache:commons:dbcp:" + dbAlias);
		connection.setAutoCommit(false);
		
		try {
			maxErrorMessageSize = ClientConfig.getInt("servicebusclient.RequestLogging.MaxErrorMessageSize");
		} catch (FIFException e) {
			maxErrorMessageSize = 4000;
		}

		logger.info("Preparing database statements for service bus request logging...");
		// Prepare the database statements
		String insertRequestStatement = ClientConfig.getSetting("servicebusclient.RequestLogging.InsertRequest.Statement");
		insertRequestStmt = connection.prepareStatement(insertRequestStatement);

		// parameters for insert request statement
		insertRequestTransactionIDIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequest.IndexTransactionID");
		insertRequestPackageNameIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequest.IndexPackageName");
		insertRequestServiceNameIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequest.IndexServiceName");
		insertRequestRequestTypeIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequest.IndexRequestType");
		insertRequestServiceBusClientNameIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequest.IndexServiceBusClientName");
		insertRequestEnvironmentNameIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequest.IndexEnvironmentName");
		insertRequestSynchronousIndicatorIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequest.IndexSynchronousIndicator");
		insertRequestStatusIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequest.IndexStatus");
		insertRequestErrorCodeIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequest.IndexErrorCode");
		insertRequestErrorTextIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequest.IndexErrorText");
		insertRequestRecycleStageIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequest.IndexRecycleStage");
		insertRequestRecycleDelayIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequest.IndexRecycleDelay");
		insertRequestEventDueDateIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequest.IndexEventDueDate");
		insertRequestExternalSystemIdIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequest.IndexExternalSystemId");
		insertRequestStartDateIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequest.IndexStartDate");
		insertRequestEndDateIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequest.IndexEndDate");
		
		String insertRequestParamStatement = ClientConfig.getSetting("servicebusclient.RequestLogging.InsertRequestParam.Statement");
		requestParamStmt = connection.prepareStatement(insertRequestParamStatement);
		
		// parameters for request param statement
		insertRequestParamTransactionIDIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequestParam.IndexTransactionID");
		insertRequestParamRequestTypeIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequestParam.IndexRequestType");
		insertRequestParamParamIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequestParam.IndexParam");
		insertRequestParamValueIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequestParam.IndexValue");
		insertRequestParamCLOBIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequestParam.IndexClob");

		String insertRequestParamListStatement = ClientConfig.getSetting("servicebusclient.RequestLogging.InsertRequestParamList.Statement");
		requestParamListStmt = connection.prepareStatement(insertRequestParamListStatement);
		
		// parameters for request param statement
		insertRequestParamListTransactionIDIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequestParamList.IndexTransactionID");
		insertRequestParamListRequestTypeIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequestParamList.IndexRequestType");
		insertRequestParamListParamListIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequestParamList.IndexParamList");
		insertRequestParamListParamIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequestParamList.IndexParam");
		insertRequestParamListValueIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequestParamList.IndexValue");
		insertRequestParamListListItemNumberIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequestParamList.IndexListItemNumber");
		
		String insertRequestResultStatement = ClientConfig.getSetting("servicebusclient.RequestLogging.InsertRequestResult.Statement");
		requestResultStmt = connection.prepareStatement(insertRequestResultStatement);
		
		// parameters for request param statement
		insertRequestResultTransactionIDIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequestResult.IndexTransactionID");
		insertRequestResultRequestTypeIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequestResult.IndexRequestType");
		insertRequestResultParamIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequestResult.IndexParam");
		insertRequestResultValueIndex = ClientConfig.getInt("servicebusclient.RequestLogging.InsertRequestResult.IndexValue");

		// Prepare the retrieve statement
		String retrieveRequestStatement = ClientConfig.getSetting("servicebusclient.RequestLogging.RetrieveRequest.Statement");
		retrieveRequestStmt = connection.prepareStatement(retrieveRequestStatement);

		// parameters for retrieve request statement
		retrieveRequestTransactionIDIndex = ClientConfig.getInt("servicebusclient.RequestLogging.RetrieveRequest.IndexTransactionID");
		retrieveRequestPackageNameIndex = ClientConfig.getInt("servicebusclient.RequestLogging.RetrieveRequest.IndexPackageName");
		retrieveRequestServiceNameIndex = ClientConfig.getInt("servicebusclient.RequestLogging.RetrieveRequest.IndexServiceName");
		retrieveRequestRequestTypeIndex = ClientConfig.getInt("servicebusclient.RequestLogging.RetrieveRequest.IndexRequestType");
		retrieveRequestSynchronousIndicatorIndex = ClientConfig.getInt("servicebusclient.RequestLogging.RetrieveRequest.IndexSynchronousIndicator");
		retrieveRequestStatusIndex = ClientConfig.getInt("servicebusclient.RequestLogging.RetrieveRequest.IndexStatus");
		retrieveRequestRecycleStageIndex = ClientConfig.getInt("servicebusclient.RequestLogging.RetrieveRequest.IndexRecycleStage");
		retrieveRequestRecycleDelayIndex = ClientConfig.getInt("servicebusclient.RequestLogging.RetrieveRequest.IndexRecycleDelay");
		retrieveRequestStartDateIndex = ClientConfig.getInt("servicebusclient.RequestLogging.RetrieveRequest.IndexStartDate");
		retrieveRequestEndDateIndex = ClientConfig.getInt("servicebusclient.RequestLogging.RetrieveRequest.IndexEndDate");
		retrieveRequestExternalSystemIdIndex = ClientConfig.getInt("servicebusclient.RequestLogging.RetrieveRequest.IndexExternalSystemId");

		// Prepare the retrieve statement
		String retrieveRequestParamsStatement = ClientConfig.getSetting("servicebusclient.RequestLogging.RetrieveRequestParams.Statement");
		retrieveRequestParamsStmt = connection.prepareStatement(retrieveRequestParamsStatement);

		// parameters for retrieve request statement
		retrieveRequestParamsTransactionIDIndex = ClientConfig.getInt("servicebusclient.RequestLogging.RetrieveRequestParams.IndexTransactionID");
		retrieveRequestParamsRequestTypeIndex = ClientConfig.getInt("servicebusclient.RequestLogging.RetrieveRequestParams.IndexRequestType");
		retrieveRequestParamsParamIndex = ClientConfig.getInt("servicebusclient.RequestLogging.RetrieveRequestParams.IndexParam");
		retrieveRequestParamsValueIndex = ClientConfig.getInt("servicebusclient.RequestLogging.RetrieveRequestParams.IndexValue");
		retrieveRequestParamsLongValueIndex = ClientConfig.getInt("servicebusclient.RequestLogging.RetrieveRequestParams.IndexLongValue");

		// Prepare the retrieve statement
		String updateRequestStatement = ClientConfig.getSetting("servicebusclient.RequestLogging.UpdateRequest.Statement");
		updateRequestStmt = connection.prepareStatement(updateRequestStatement);

		// parameters for update request statement
		updateRequestTransactionIDIndex = ClientConfig.getInt("servicebusclient.RequestLogging.UpdateRequest.IndexTransactionID");
		updateRequestRequestTypeIndex = ClientConfig.getInt("servicebusclient.RequestLogging.UpdateRequest.IndexRequestType");
		updateRequestStatusIndex = ClientConfig.getInt("servicebusclient.RequestLogging.UpdateRequest.IndexStatus");
		updateRequestErrorCodeIndex = ClientConfig.getInt("servicebusclient.RequestLogging.UpdateRequest.IndexErrorCode");
		updateRequestErrorTextIndex = ClientConfig.getInt("servicebusclient.RequestLogging.UpdateRequest.IndexErrorText");
		updateRequestRecycleStageIndex = ClientConfig.getInt("servicebusclient.RequestLogging.UpdateRequest.IndexRecycleStage");
		updateRequestRecycleDelayIndex = ClientConfig.getInt("servicebusclient.RequestLogging.UpdateRequest.IndexRecycleDelay");
		updateRequestStartDateIndex = ClientConfig.getInt("servicebusclient.RequestLogging.UpdateRequest.IndexStartDate");
		updateRequestEndDateIndex = ClientConfig.getInt("servicebusclient.RequestLogging.UpdateRequest.IndexEndDate");
	}

	public ServiceBusRequestLogger (boolean autoCommit) throws FIFException, SQLException {
		this.autoCommit = autoCommit;
		init();
	}

	public synchronized void insertRequest (ServiceBusRequest request) throws SQLException {
		try {
			insertRequestStmt.clearParameters();
			insertRequestStmt.setString(insertRequestTransactionIDIndex,
					request.getRequestId());
			insertRequestStmt.setString(insertRequestPackageNameIndex, request
					.getPackageName());
			insertRequestStmt.setString(insertRequestServiceNameIndex, request
					.getServiceName());
			insertRequestStmt.setString(insertRequestRequestTypeIndex, request
					.getRequestType());
			insertRequestStmt.setString(insertRequestServiceBusClientNameIndex,
					ServiceBusRequest.getClientName());
			insertRequestStmt.setString(insertRequestEnvironmentNameIndex,
					ServiceBusRequest.getEnvironmentName());
			insertRequestStmt.setString(insertRequestSynchronousIndicatorIndex,
					request.isCallSynch() ? "Y" : "N");
			insertRequestStmt.setInt(insertRequestRecycleStageIndex, request
					.getRecycleStage());
			insertRequestStmt.setInt(insertRequestRecycleDelayIndex, request
					.getRecycleDelay());
			Date eventDueDate = request.getEventDueDate();
			if (eventDueDate != null)
				insertRequestStmt.setTimestamp(insertRequestEventDueDateIndex,
						new java.sql.Timestamp(eventDueDate.getTime()));
			else
				insertRequestStmt.setTimestamp(insertRequestEventDueDateIndex,
						null);
			Date startDate = request.getStartDate();
			if (startDate != null)
				insertRequestStmt.setTimestamp(insertRequestStartDateIndex,
						new java.sql.Timestamp(startDate.getTime()));
			else
				insertRequestStmt.setTimestamp(insertRequestStartDateIndex,
						null);
			Date endDate = request.getEndDate();
			if (endDate != null)
				insertRequestStmt.setTimestamp(insertRequestEndDateIndex,
						new java.sql.Timestamp(endDate.getTime()));
			else
				insertRequestStmt.setTimestamp(insertRequestEndDateIndex, null);
			insertRequestStmt.setString(insertRequestExternalSystemIdIndex,
					(request.getExternalSystemId() != null) ? request
							.getExternalSystemId() : "");
			String errorCode = (request.getErrorCode() == null) ? "" : request
					.getErrorCode();
			String errorText = (request.getErrorText() == null) ? "" : request
					.getErrorText();
			if (errorText.length() > maxErrorMessageSize) {
				errorText = errorText.substring(0, maxErrorMessageSize);
			}
			insertRequestStmt.setString(insertRequestErrorCodeIndex, errorCode);
			insertRequestStmt.setString(insertRequestErrorTextIndex, errorText);
			insertRequestStmt.setString(insertRequestStatusIndex, request
					.getStatus());
			logger.info("Logging service bus request (Id: "
					+ request.getRequestId() + ") to the database.");
			logger.debug("Following parameters are set: " + "\ntransactionId: "
					+ request.getRequestId() + "\npackageName: "
					+ request.getPackageName() + "\nserviceName: "
					+ request.getServiceName() + "\nsynchronous: "
					+ request.isCallSynch() + "\nstatus: "
					+ request.getStatus() + "\nerrorCode: " + errorCode
					+ "\nerrorText: " + errorText + "\nrecycleStage: "
					+ request.getRecycleStage() + "\nrecycleDelay: "
					+ request.getRecycleDelay());
			insertRequestStmt.execute();
			for (String parameter : request.getParameters().keySet()) {
				requestParamStmt.clearParameters();
				requestParamStmt.setString(
						insertRequestParamTransactionIDIndex, request
								.getRequestId());
				requestParamStmt.setString(insertRequestParamRequestTypeIndex,
						request.getRequestType());
				requestParamStmt.setString(insertRequestParamParamIndex,
						parameter);

				CLOB newClob = null; 

				if (request.getParameters().get(parameter).length() > 4000)
				{
					String value = request.getParameters().get(parameter);
					requestParamStmt.setString(insertRequestParamValueIndex,
							"See the CLOB value.");
					//CLOB newClob = CLOB.createTemporary(((PoolableConnection)connection).getDelegate(), false, oracle.sql.CLOB.DURATION_CALL);
					
					CallableStatement stmt=null;					
					try{
					   stmt = connection.prepareCall("{ call DBMS_LOB.CREATETEMPORARY(?, TRUE)}");
					   stmt.registerOutParameter(1, OracleTypes.CLOB);
					   stmt.execute();
					   newClob = (CLOB)stmt.getObject(1);
					} finally {
					  if ( stmt != null ) {
					     try {
					    	 stmt.close();
					      } catch (Throwable e) {}
					  }
					}
					
					newClob.setString(1,value);
					requestParamStmt.setClob(insertRequestParamCLOBIndex, newClob);
					
				} else {
					requestParamStmt.setString(insertRequestParamValueIndex,
						request.getParameters().get(parameter));
					requestParamStmt.setClob(insertRequestParamCLOBIndex, (CLOB) null);
				}
				logger.debug("Inserting parameter with following values: "
						+ "\ntransactionId: " + request.getRequestId()
						+ "\nresult parameter: " + parameter + "\nvalue: "
						+ request.getParameters().get(parameter));
				requestParamStmt.execute();

				if(newClob != null)
					newClob.freeTemporary();
			}
			for (String listName : request.getParameterLists().keySet()) {
				int listItemCounter = 0;
				for (Map<String, String> listItem : request.getParameterLists()
						.get(listName)) {
					listItemCounter++;
					for (String listItemName : listItem.keySet()) {
						requestParamListStmt.clearParameters();
						requestParamListStmt.setString(
								insertRequestParamListTransactionIDIndex,
								request.getRequestId());
						requestParamListStmt.setString(
								insertRequestParamListRequestTypeIndex, request
										.getRequestType());
						requestParamListStmt.setString(
								insertRequestParamListParamListIndex, listName);
						requestParamListStmt.setString(
								insertRequestParamListParamIndex, listItemName);
						requestParamListStmt.setString(
								insertRequestParamListValueIndex, listItem
										.get(listItemName));
						requestParamListStmt.setString(
								insertRequestParamListListItemNumberIndex,
								new Integer(listItemCounter).toString());
						requestParamListStmt.execute();
					}
				}
			}
			if (autoCommit)
				connection.commit();
		} catch (SQLException e) {
			connection.rollback();
			throw e;
		}		
	}
	
	public synchronized void insertRequestResults (ServiceBusRequest request) throws SQLException {		
		try {
			for (String resultParameter : request.getReturnParameters()
					.keySet()) {
				requestResultStmt.clearParameters();
				requestResultStmt.setString(
						insertRequestResultTransactionIDIndex, request
								.getRequestId());
				requestResultStmt.setString(
						insertRequestResultRequestTypeIndex, request
								.getRequestType());
				requestResultStmt.setString(insertRequestResultParamIndex,
						resultParameter);
				requestResultStmt.setString(insertRequestResultValueIndex,
						request.getReturnParameters().get(resultParameter));
				logger
						.debug("Inserting result parameter with following values: "
								+ "\ntransactionId: "
								+ request.getRequestId()
								+ "\nresult parameter: "
								+ resultParameter
								+ "\nvalue: "
								+ request.getReturnParameters().get(
										resultParameter));
				requestResultStmt.execute();
			}
			if (autoCommit)
				connection.commit();
		} catch (SQLException e) {
			connection.rollback();
			throw e;
		}		
	}
	
	public synchronized void updateRequest (ServiceBusRequest request) throws SQLException {
		try {
			updateRequestStmt.clearParameters();
			updateRequestStmt.setString(updateRequestTransactionIDIndex,
					request.getRequestId());
			updateRequestStmt.setString(updateRequestRequestTypeIndex, request
					.getRequestType());
			updateRequestStmt.setInt(updateRequestRecycleStageIndex, request
					.getRecycleStage());
			updateRequestStmt.setInt(updateRequestRecycleDelayIndex, request
					.getRecycleDelay());
			Date startDate = request.getStartDate();
			if (startDate != null)
				updateRequestStmt.setTimestamp(updateRequestStartDateIndex,
						new java.sql.Timestamp(startDate.getTime()));
			else
				updateRequestStmt.setTimestamp(updateRequestStartDateIndex,
						null);
			Date endDate = request.getEndDate();
			if (endDate != null)
				updateRequestStmt.setTimestamp(updateRequestEndDateIndex,
						new java.sql.Timestamp(endDate.getTime()));
			else
				updateRequestStmt.setTimestamp(updateRequestEndDateIndex, null);
			String errorCode = (request.getErrorCode() == null) ? "" : request
					.getErrorCode();
			String errorText = (request.getErrorText() == null) ? "" : request
					.getErrorText();
			if (errorText.length() > maxErrorMessageSize) {
				errorText = errorText.substring(0, maxErrorMessageSize);
			}
			updateRequestStmt.setString(updateRequestErrorCodeIndex, errorCode);
			updateRequestStmt.setString(updateRequestErrorTextIndex, errorText);
			updateRequestStmt.setString(updateRequestStatusIndex, request
					.getStatus());
			logger.info("Logging service bus request (Id: "
					+ request.getRequestId() + ") to the database.");
			logger.debug("Following parameters are set: " + "\ntransactionId: "
					+ request.getRequestId() + "\npackageName: "
					+ request.getPackageName() + "\nserviceName: "
					+ request.getServiceName() + "\nsynchronous: "
					+ request.isCallSynch() + "\nstatus: "
					+ request.getStatus() + "\nerrorCode: " + errorCode
					+ "\nerrorText: " + errorText + "\nrecycleStage: "
					+ request.getRecycleStage() + "\nrecycleDelay: "
					+ request.getRecycleDelay());
			updateRequestStmt.execute();
			if (autoCommit)
				connection.commit();
		} catch (SQLException e) {
			connection.rollback();
			throw e;
		}		
	}
	
	public synchronized ServiceBusRequest retrieveRequest (String requestId, String requestType) throws SQLException {
		ServiceBusRequest busRequest = null;

		retrieveRequestStmt.clearParameters();
		retrieveRequestStmt.setString(retrieveRequestTransactionIDIndex, requestId);
		retrieveRequestStmt.setString(retrieveRequestRequestTypeIndex, requestType);
		
		ResultSet result = retrieveRequestStmt.executeQuery();						
		if (result.next()) {
			busRequest = new ServiceBusRequest(requestId);
			busRequest.setPackageName(result.getString(retrieveRequestPackageNameIndex));
			busRequest.setServiceName(result.getString(retrieveRequestServiceNameIndex));
			busRequest.setRequestType(requestType);
			busRequest.setCallSynch(
					(result.getString(retrieveRequestSynchronousIndicatorIndex).equals("Y")) ? true : false);
			busRequest.setRecycleStage(result.getInt(retrieveRequestRecycleStageIndex));
			busRequest.setRecycleDelay(result.getInt(retrieveRequestRecycleDelayIndex));
			Timestamp startDate = result.getTimestamp(retrieveRequestStartDateIndex);
			if (startDate != null)
				busRequest.setStartDate(new Date(startDate.getTime()));
			Timestamp endDate = result.getTimestamp(retrieveRequestEndDateIndex);
			if (endDate != null)
				busRequest.setEndDate(new Date(endDate.getTime()));
			busRequest.setStatus(result.getString(retrieveRequestStatusIndex));
			busRequest.setExternalSystemId(result.getString(retrieveRequestExternalSystemIdIndex));
			
			logger.info("Retrieving service bus request (Id: " + requestId + ") from the database.");
			logger.debug("Following parameters are set: " + 
					"\ntransactionId: " + busRequest.getRequestId() + 
					"\npackageName: " + busRequest.getPackageName() + 
					"\nserviceName: " + busRequest.getServiceName() + 
					"\nsynchronous: " + busRequest.isCallSynch() +					
					"\nstatus: " + busRequest.getStatus() + 
					"\nrecycleStage: " + busRequest.getRecycleStage() + 
					"\nrecycleDelay: " + busRequest.getRecycleDelay());			
		}
		return busRequest;
	}
	
	public synchronized void retrieveRequestParams (ServiceBusRequest busRequest) throws SQLException {
		retrieveRequestParamsStmt.clearParameters();
		retrieveRequestParamsStmt.setString(retrieveRequestParamsTransactionIDIndex, busRequest.getRequestId());
		retrieveRequestParamsStmt.setString(retrieveRequestParamsRequestTypeIndex, busRequest.getRequestType());
		
		ResultSet result = retrieveRequestParamsStmt.executeQuery();
		logger.info("Retrieving service bus request params (Id: " + busRequest.getRequestId() + ") from the database.");

		while (result.next()) {
			String paramName = result.getString(retrieveRequestParamsParamIndex);
			String paramValue = result.getString(retrieveRequestParamsValueIndex);
			if(paramValue!=null && (paramValue.equals("See the CLOB value.")||  paramValue.equals(""))){
				Clob clientRequest = result.getClob("LONG_VALUE");
				
				if (clientRequest != null)	{			
					String longValue=clientRequest.getSubString(1, (int) result.getClob("LONG_VALUE").length());				
					paramValue=longValue;
				}
				//String longValue = result.getString(retrieveRequestParamsLongValueIndex);
			
			}
			
      if(paramValue != null){
  			String str=paramValue;
  			if(paramValue.length()>100)
  				str=paramValue.substring(0,100);
  			logger.info("---------> PARAM: "+paramName+" VALUE: "+str+"... TRUNCATED");
  			busRequest.getParameters().put(paramName, paramValue);
      }
		}
	}
	
	public synchronized void commit () throws SQLException {
		try {
			connection.commit();
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			connection.rollback();
			throw e;
		}
	}
}
