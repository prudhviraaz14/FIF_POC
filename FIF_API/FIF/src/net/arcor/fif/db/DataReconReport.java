/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/DataReconReport.java-arc   1.3   Jun 07 2017 14:28:12   naveen.k  $
 *    $Revision:   1.3  $
 *    $Workfile:   DataReconReport.java  $
 *      $Author:   naveen.k  $
 *        $Date:   Jun 07 2017 14:28:12  $
 *
 *  Copyright (C) Vodafone
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/DataReconReport.java-arc  $
 * 
 *    Rev 1.3   Jun 07 2017 14:28:12   naveen.k
 * PPM 197512 RMS 161608,Project TKG
 * 
 *    Rev 1.2   Jan 29 2013 11:09:48   schwarje
 * IT-32438: updates
 * 
 *    Rev 1.1   Jan 18 2013 07:48:54   schwarje
 * IT-32438: added relatedObject
 * 
 *    Rev 1.0   Jan 17 2013 15:29:40   schwarje
 * Initial revision.
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

import net.arcor.ccm.epsm_ccm_consolidatesubscriptiondata_001.ActionItem;

public class DataReconReport {
	
	private String reportID = null;
	private String customerNumber = null;
	private String bundleID = null;
	private String orderID = null;
	private int orderPositionNumber = 1;
	private Date reportTime = null;
	private boolean bksResult = true;
	private String bksErrorCode = null;
	private String bksErrorText = null;
	private boolean validatedCCM = false;
	private boolean validatedAIDA = false;
	private boolean validatedZAR = false;
	private boolean validatedCramer = false;
	private boolean validatedInfPort= false;
	private boolean processedCCM = false;
	private boolean processedAIDA = false;
	private boolean processedZAR = false;
	private boolean processedCramer = false;
	private boolean processedSLS = false;
	private boolean processedInfPort = false;
	private String sbusCorrelationID = null;
	private List<ActionItem> actionItems = null;
	
	public List<ActionItem> getActionItems() {
		return actionItems;
	}
	public void setActionItems(List<ActionItem> actionItems) {
		this.actionItems = actionItems;
	}
	public String getBksErrorCode() {
		return bksErrorCode;
	}
	public void setBksErrorCode(String bksErrorCode) {
		this.bksErrorCode = bksErrorCode;
	}
	public String getBksErrorText() {
		return bksErrorText;
	}
	public void setBksErrorText(String bksErrorText) {
		this.bksErrorText = bksErrorText;
	}
	public boolean isBksResult() {
		return bksResult;
	}
	public void setBksResult(boolean bksResult) {
		this.bksResult = bksResult;
	}
	public String getBundleID() {
		return bundleID;
	}
	public void setBundleID(String bundleID) {
		this.bundleID = bundleID;
	}
	public String getCustomerNumber() {
		return customerNumber;
	}
	public void setCustomerNumber(String customerNumber) {
		this.customerNumber = customerNumber;
	}
	public String getOrderID() {
		return orderID;
	}
	public void setOrderID(String orderID) {
		this.orderID = orderID;
	}
	public int getOrderPositionNumber() {
		return orderPositionNumber;
	}
	public void setOrderPositionNumber(int orderPositionNumber) {
		this.orderPositionNumber = orderPositionNumber;
	}
	public boolean isProcessedAIDA() {
		return processedAIDA;
	}
	public void setProcessedAIDA(boolean processedAIDA) {
		this.processedAIDA = processedAIDA;
	}
	public boolean isProcessedCCM() {
		return processedCCM;
	}
	public void setProcessedCCM(boolean processedCCM) {
		this.processedCCM = processedCCM;
	}
	public boolean isProcessedCramer() {
		return processedCramer;
	}
	public void setProcessedCramer(boolean processedCramer) {
		this.processedCramer = processedCramer;
	}
	public boolean isProcessedSLS() {
		return processedSLS;
	}
	public void setProcessedSLS(boolean processedSLS) {
		this.processedSLS = processedSLS;
	}
	public boolean isProcessedZAR() {
		return processedZAR;
	}
	public void setProcessedZAR(boolean processedZAR) {
		this.processedZAR = processedZAR;
	}
	public boolean isProcessedInfPort() {
		return processedInfPort;
	}
	public void setProcessedInfPort(boolean processedInfPort) {
		this.processedInfPort = processedInfPort;
	}
	public String getReportID() {
		return reportID;
	}
	public void setReportID(String reportID) {
		this.reportID = reportID;
	}
	public Date getReportTime() {
		return reportTime;
	}
	public void setReportTime(Date reportTime) {
		this.reportTime = reportTime;
	}
	public boolean isValidatedAIDA() {
		return validatedAIDA;
	}
	public void setValidatedAIDA(boolean validatedAIDA) {
		this.validatedAIDA = validatedAIDA;
	}
	public boolean isValidatedCCM() {
		return validatedCCM;
	}
	public void setValidatedCCM(boolean validatedCCM) {
		this.validatedCCM = validatedCCM;
	}
	public boolean isValidatedCramer() {
		return validatedCramer;
	}
	public void setValidatedCramer(boolean validatedCramer) {
		this.validatedCramer = validatedCramer;
	}
	public boolean isValidatedZAR() {
		return validatedZAR;
	}
	public void setValidatedZAR(boolean validatedZAR) {
		this.validatedZAR = validatedZAR;
	}
	public boolean isValidatedInfPort() {
		return validatedInfPort;
	}
	public void setValidatedInfPort(boolean validatedInfPort) {
		this.validatedInfPort = validatedInfPort;
	}
	public String getSbusCorrelationID() {
		return sbusCorrelationID;
	}
	public void setSbusCorrelationID(String sbusCorrelationID) {
		this.sbusCorrelationID = sbusCorrelationID;
	}
	
}
