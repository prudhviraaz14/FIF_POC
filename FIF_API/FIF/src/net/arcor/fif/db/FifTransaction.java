package net.arcor.fif.db;

import java.sql.Timestamp;

public class FifTransaction {
	private String transactionId = null;
	private String clientType = null;
	private String clientId = null;
	private String clientRequest = null;
	private String clientResponse = null;
	private Timestamp dueDate = null;
	private Timestamp entryDate = null;
	private Timestamp endDate = null;
	private String status = null;
	private String customerNumber = null;
	private Integer recycleStage = 0;
	private Integer responseRetryCount = 0;
	private String jmsCorrelationId = null;
	private String jmsReplyTo = null;
	
	
	public String getClientType() {
		return clientType;
	}
	public void setClientType(String clientType) {
		this.clientType = clientType;
	}
	public String getClientId() {
		return clientId;
	}
	public void setClientId(String clientId) {
		this.clientId = clientId;
	}
	public String getClientRequest() {
		return clientRequest;
	}
	public void setClientRequest(String clientRequest) {
		this.clientRequest = clientRequest;
	}
	public String getClientResponse() {
		return clientResponse;
	}
	public void setClientResponse(String clientResponse) {
		this.clientResponse = clientResponse;
	}
	public String getCustomerNumber() {
		return customerNumber;
	}
	public void setCustomerNumber(String customerNumber) {
		this.customerNumber = customerNumber;
	}
	public Timestamp getDueDate() {
		return dueDate;
	}
	public void setDueDate(Timestamp dueDate) {
		this.dueDate = dueDate;
	}
	public Timestamp getEndDate() {
		return endDate;
	}
	public void setEndDate(Timestamp endDate) {
		this.endDate = endDate;
	}
	public Timestamp getEntryDate() {
		return entryDate;
	}
	public void setEntryDate(Timestamp entryDate) {
		this.entryDate = entryDate;
	}
	public Integer getRecycleStage() {
		return recycleStage;
	}
	public void setRecycleStage(Integer recycleStage) {
		this.recycleStage = recycleStage;
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
	public Integer getResponseRetryCount() {
		return responseRetryCount;
	}
	public void setResponseRetryCount(Integer responseRetryCount) {
		this.responseRetryCount = responseRetryCount;
	}
	public String getJmsCorrelationId() {
		return jmsCorrelationId;
	}
	public void setJmsCorrelationId(String jmsCorrelationId) {
		this.jmsCorrelationId = jmsCorrelationId;
	}
	public String getJmsReplyTo() {
		return jmsReplyTo;
	}
	public void setJmsReplyTo(String jmsReplyTo) {
		this.jmsReplyTo = jmsReplyTo;
	}
}
