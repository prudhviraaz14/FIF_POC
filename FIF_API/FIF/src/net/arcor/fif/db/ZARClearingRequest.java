/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/ZARClearingRequest.java-arc   1.0   Jan 22 2013 07:50:30   schwarje  $
 *    $Revision:   1.0  $
 *    $Workfile:   ZARClearingRequest.java  $
 *      $Author:   schwarje  $
 *        $Date:   Jan 22 2013 07:50:30  $
 *
 *  Copyright (C) Vodafone
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/ZARClearingRequest.java-arc  $
 * 
 *    Rev 1.0   Jan 22 2013 07:50:30   schwarje
 * Initial revision.
 * 
 *    Rev 1.0   May 25 2010 16:27:16   schwarje
 * Initial revision.
 * 
 * 
 ***************************************************************************  
 */
package net.arcor.fif.db;

public class ZARClearingRequest {
	
	// - COL_CLEARING_ID (varchar50) - counter "FIF-000000000001", besser BKS-Request-ID
	// - COL_CCM_SS_ID (varchar50) - serviceSubscriptionID
	// - COL_RUF_KUNDENUMMER_CCM - customerNumber CCM
	// - COL_RUF_KUNDENUMMER_ZAR - customerNumber ZAR
	// - COL_ONB_VORWAHL - Vorwahl mit 0
	// - COL_RUF_START - Startnummer
	// - COL_RUF_END - Endnummer (bzw. wieder Startnummer)
	// - COL_CCM_SCENARIO - scenarioType as number 
	// - COL_PRODUCT_CODE - PSM productCode für Rufnummer
	// - COL_INSERT_DATE (DATE) := sysdate
	// - COL_LAST_UPDATE (DATE) := sysdate
	// - COL_LAST_SYSTEM (varchar3) := FIF

	private String clearingID = null;
	private String serviceSubscriptionID = null;
	private String customerNumberCCM = null;
	private String customerNumberZAR = null;
	private String localAreaCode = null;
	private String beginNumber = null;
	private String endNumber = null;
	private String ccmScenario = null;
	private String productCode = null;
	
	public String getBeginNumber() {
		return beginNumber;
	}
	public void setBeginNumber(String beginNumber) {
		this.beginNumber = beginNumber;
	}
	public String getCcmScenario() {
		return ccmScenario;
	}
	public void setCcmScenario(String ccmScenario) {
		this.ccmScenario = ccmScenario;
	}
	public String getClearingID() {
		return clearingID;
	}
	public void setClearingID(String clearingID) {
		this.clearingID = clearingID;
	}
	public String getCustomerNumberCCM() {
		return customerNumberCCM;
	}
	public void setCustomerNumberCCM(String customerNumberCCM) {
		this.customerNumberCCM = customerNumberCCM;
	}
	public String getCustomerNumberZAR() {
		return customerNumberZAR;
	}
	public void setCustomerNumberZAR(String customerNumberZAR) {
		this.customerNumberZAR = customerNumberZAR;
	}
	public String getEndNumber() {
		return endNumber;
	}
	public void setEndNumber(String endNumber) {
		this.endNumber = endNumber;
	}
	public String getLocalAreaCode() {
		return localAreaCode;
	}
	public void setLocalAreaCode(String localAreaCode) {
		this.localAreaCode = localAreaCode;
	}
	public String getProductCode() {
		return productCode;
	}
	public void setProductCode(String productCode) {
		this.productCode = productCode;
	}
	public String getServiceSubscriptionID() {
		return serviceSubscriptionID;
	}
	public void setServiceSubscriptionID(String serviceSubscriptionID) {
		this.serviceSubscriptionID = serviceSubscriptionID;
	}
	
}
