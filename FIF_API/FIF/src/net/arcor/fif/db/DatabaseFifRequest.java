/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/DatabaseFifRequest.java-arc   1.1   Jan 17 2013 15:27:36   schwarje  $
 *    $Revision:   1.1  $
 *    $Workfile:   DatabaseFifRequest.java  $
 *      $Author:   schwarje  $
 *        $Date:   Jan 17 2013 15:27:36  $
 *
 *  Copyright (C) Vodafone
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/DatabaseFifRequest.java-arc  $
 * 
 *    Rev 1.1   Jan 17 2013 15:27:36   schwarje
 * IT-32438: added inserting of FifRequests, new parameters
 * 
 *    Rev 1.0   May 25 2010 16:27:16   schwarje
 * Initial revision.
 * 
 * 
 ***************************************************************************  
 */
package net.arcor.fif.db;

import java.util.Date;
import java.util.List;
import java.util.Map;

public class DatabaseFifRequest {
	private String transactionId = null;
	private String dependentTransactionId = null;
	private String transactionListId = null;
	private String status = null;
	private String transactionListStatus = null;
	private String errorText = null;
	private Date dueDate = null;
	private Date startDate = null;
	private Date endDate = null;
	private String actionName = null;
	private String externalSystemId = null;
	private int priority = 5;
	private Map<String, String> parameters = null;
	private Map<String, String> results = null;
	private Map<String, List<Map<String, String>>> parameterLists = null;
	
	public String getActionName() {
		return actionName;
	}
	public void setActionName(String actionName) {
		this.actionName = actionName;
	}
	public Date getDueDate() {
		return dueDate;
	}
	public void setDueDate(Date dueDate) {
		this.dueDate = dueDate;
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
	public Map<String, List<Map<String, String>>> getParameterLists() {
		return parameterLists;
	}
	public void setParameterLists(
			Map<String, List<Map<String, String>>> parameterLists) {
		this.parameterLists = parameterLists;
	}
	public Map<String, String> getParameters() {
		return parameters;
	}
	public void setParameters(Map<String, String> parameters) {
		this.parameters = parameters;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public String getTransactionId() {
		return transactionId;
	}
	public void setTransactionId(String transactionId) {
		this.transactionId = transactionId;
	}
	public String getTransactionListId() {
		return transactionListId;
	}
	public void setTransactionListId(String transactionListId) {
		this.transactionListId = transactionListId;
	}
	public String getTransactionListStatus() {
		return transactionListStatus;
	}
	public void setTransactionListStatus(String transactionListStatus) {
		this.transactionListStatus = transactionListStatus;
	}
	public String getDependentTransactionId() {
		return dependentTransactionId;
	}
	public void setDependentTransactionId(String dependentTransactionId) {
		this.dependentTransactionId = dependentTransactionId;
	}
	public String getErrorText() {
		return errorText;
	}
	public void setErrorText(String errorText) {
		this.errorText = errorText;
	}
	public Map<String, String> getResults() {
		return results;
	}
	public void setResults(Map<String, String> results) {
		this.results = results;
	}
	public String getExternalSystemId() {
		return externalSystemId;
	}
	public void setExternalSystemId(String externalSystemId) {
		this.externalSystemId = externalSystemId;
	}
	public int getPriority() {
		return priority;
	}
	public void setPriority(int priority) {
		this.priority = priority;
	}
	
}
