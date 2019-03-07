/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/ServiceBusRequest.java-arc   1.7   Mar 06 2017 21:37:52   lejam  $
 *    $Revision:   1.7  $
 *    $Workfile:   ServiceBusRequest.java  $
 *      $Author:   lejam  $
 *        $Date:   Mar 06 2017 21:37:52  $
 *
 *  Function: Main class of the service bus interface
 *  
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/ServiceBusRequest.java-arc  $
 * 
 *    Rev 1.7   Mar 06 2017 21:37:52   lejam
 * PPM219104 NAV2 Added serviceType and serviceVersion to ServiceBusRequest class
 * 
 *    Rev 1.6   Jan 20 2009 09:57:16   schwarje
 * SPN-CCB-000081938: handle fatalServiceResponse in SbusResponseClient
 * 
 *    Rev 1.5   Aug 21 2008 17:02:30   schwarje
 * IT-22684: added support for populating output parameters on service bus requests
 * 
 *    Rev 1.4   Jul 30 2008 16:29:42   schwarje
 * IT-k-23569: new FIF client for reading responses for service bus requests initiated from CCM
 * 
 *    Rev 1.3   Apr 24 2008 13:24:10   schwarje
 * IT-22324: added external system id
 * 
 *    Rev 1.2   Feb 28 2008 15:25:32   schwarje
 * IT-20793: added processing of events
 * 
 *    Rev 1.1   Feb 06 2008 20:04:06   schwarje
 * IT-20058: updated
 * 
 *    Rev 1.0   Jan 29 2008 17:44:18   schwarje
 * Initial revision.
 * 
 *    Rev 1.0   Aug 09 2007 17:24:40   schwarje
 * Initial revision.
 * 
 ***************************************************************************  
 */
package net.arcor.fif.client;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class ServiceBusRequest {
	
	/**
	 * request states
	 */
	public static final String requestStatusNotSent = "NOT_SENT";
	public static final String requestStatusCompleted = "COMPLETED";
	public static final String requestStatusFailed = "FAILED";
	public static final String requestStatusInProgress = "IN_PROGRESS";
	public static final String requestStatusPending = "PENDING";
	public static final String requestStatusRespondedPositive = "POSITIVE_RESPONSE";
	public static final String requestStatusRespondedNegative = "NEGATIVE_RESPONSE";
	public static final String requestStatusInRecycling = "IN_RECYCLING";	
	public static final String requestStatusRolledBack = "ROLLED_BACK";	
	
	public static final String requestTypeEvent = "E";
	public static final String requestTypeService = "S";
	public static final String requestTypeResponse = "R";
	
	private static String clientName = null;
	private static String environmentName = null;

	private String packageName = null;
	private Map<String, String> parameters = new HashMap<String, String>();
	private Map<String, String> returnParameters = new HashMap<String, String>();
	private Map<String, List<Map<String, String>>> parameterLists = new HashMap<String, List<Map<String, String>>>();
	private String requestId = null;
	private String serviceName = null;
	private String serviceType = null;
	private String serviceVersion = null;
	private String requestType = null;
	private String status = requestStatusInProgress;
	private boolean callSynch = false;
	private Throwable throwable = null;
	private int recycleStage = 0;
	private int recycleDelay = 0;
	private boolean recycleMessage = false;	
	private Date eventDueDate = null;
	private String externalSystemId = null;
	private Date startDate = null;
	private Date endDate = null;
	private boolean fatalServiceResponse = false;	
	
	public ServiceBusRequest (String requestId) {
		this.requestId = requestId;		
	}
	
	public String getErrorCode() {
		if (throwable == null)
			return null;
		else {
			if (throwable instanceof ServiceBusInterfaceException)
				return ((ServiceBusInterfaceException) throwable).getErrorCode();
			else
				return "SBUS0000";
		}
	}
	
	public String getErrorText() {
		if (throwable == null)
			return null;
		else
			return throwable.getMessage();
	}
	
	public String getPackageName() {
		return packageName;
	}
	public Map<String, String> getParameters() {
		return parameters;
	}
	public String getRequestId() {
		return requestId;
	}
	public String getServiceName() {
		return serviceName;
	}
	public String getServiceType() {
		return serviceType;
	}
	public String getServiceVersion() {
		return serviceVersion;
	}
	public String getStatus() {
		return status;
	}
	public boolean isCallSynch() {
		return callSynch;
	}
	public void setCallSynch(boolean aCallSynch) {
		this.callSynch = aCallSynch;
	}
	public void setPackageName(String aPackageName) {
		this.packageName = aPackageName;
	}
	public void setParameters(Map<String, String> parameters) {
		this.parameters = parameters;
	}
	public Map<String, List<Map<String, String>>> getParameterLists() {
		return parameterLists;
	}
	public void setParameterLists(Map<String, List<Map<String, String>>> parameterLists) {
		this.parameterLists = parameterLists;
	}
	public Map<String, String> getReturnParameters() {
		return returnParameters;
	}

	public void setReturnParameters(Map<String, String> returnParameters) {
		this.returnParameters = returnParameters;
	}

	public void setRequestId(String requestId) {
		this.requestId = requestId;
	}
	public void setServiceName(String aServiceName) {
		this.serviceName = aServiceName;
	}
	public void setServiceType(String aServiceType) {
		this.serviceType = aServiceType;
	}
	public void setServiceVersion(String aServiceVersion) {
		this.serviceVersion = aServiceVersion;
	}
	public void setStatus(String status) {
		this.status = status;
	}

	public Throwable getThrowable() {
		return throwable;
	}

	public void setThrowable(Throwable throwable) {
		this.throwable = throwable;
	}

	public static String getClientName() {
		return clientName;
	}

	public static void setClientName(String clientName) {
		ServiceBusRequest.clientName = clientName;
	}

	public String getRequestType() {
		return requestType;
	}

	public void setRequestType(String requestType) {
		this.requestType = requestType;
	}

	public static String getEnvironmentName() {
		return environmentName;
	}

	public static void setEnvironmentName(String environmentName) {
		ServiceBusRequest.environmentName = environmentName;
	}

	public int getRecycleStage() {
		return recycleStage;
	}

	public void setRecycleStage(int recycleStage) {
		this.recycleStage = recycleStage;
	}

	public int getRecycleDelay() {
		return recycleDelay;
	}

	public void setRecycleDelay(int recycleDelay) {
		this.recycleDelay = recycleDelay;
	}

	public boolean getRecycleMessage() {
		return recycleMessage;
	}

	public void setRecycleMessage(boolean recycleMessage) {
		this.recycleMessage = recycleMessage;
	}

	public Date getEventDueDate() {
		return eventDueDate;
	}

	public void setEventDueDate(Date eventDueDate) {
		this.eventDueDate = eventDueDate;
	}

	public String getExternalSystemId() {
		return externalSystemId;
	}

	public void setExternalSystemId(String externalSystemId) {
		this.externalSystemId = externalSystemId;
	}

	public Date getEndDate() {
		return endDate;
	}

	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public boolean isFatalServiceResponse() {
		return fatalServiceResponse;
	}

	public void setFatalServiceResponse(boolean fatalServiceResponse) {
		this.fatalServiceResponse = fatalServiceResponse;
	}

}
