package net.arcor.fif.db;

import java.util.ArrayList;
import java.util.Map;

import net.arcor.fif.messagecreator.FIFError;

public class FailedRequestNotification {
	private String id;
	private String externalSystemID;
	private String actionName;
	private ArrayList<FIFError> requestErrors;
	private Map requestParams;
	
	public String getActionName() {
		return actionName;
	}
	public void setActionName(String actionName) {
		this.actionName = actionName;
	}
	public String getExternalSystemID() {
		return externalSystemID;
	}
	public void setExternalSystemID(String externalSystemID) {
		this.externalSystemID = externalSystemID;
	}
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public ArrayList<FIFError> getRequestErrors() {
		return requestErrors;
	}
	public void setRequestErrors(ArrayList<FIFError> requestErrors) {
		this.requestErrors = requestErrors;
	}
	public Map getRequestParams() {
		return requestParams;
	}
	public void setRequestParams(Map requestParams) {
		this.requestParams = requestParams;
	}
	
}
