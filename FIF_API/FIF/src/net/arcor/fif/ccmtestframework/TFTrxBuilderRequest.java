package net.arcor.fif.ccmtestframework;

import java.util.GregorianCalendar;


public class TFTrxBuilderRequest extends TFComRequest {

	private String transactionID = null;
	private String transactionType = null;
	private GregorianCalendar overrideSystemDate = null;
	
	public GregorianCalendar getOverrideSystemDate() {
		return overrideSystemDate;
	}
	public void setOverrideSystemDate(GregorianCalendar overrideSystemDate) {
		this.overrideSystemDate = overrideSystemDate;
	}
	public String getTransactionID() {
		return transactionID;
	}
	public void setTransactionID(String transactionID) {
		this.transactionID = transactionID;
	}
	public String getTransactionType() {
		return transactionType;
	}
	public void setTransactionType(String transactionType) {
		this.transactionType = transactionType;
	}
}
