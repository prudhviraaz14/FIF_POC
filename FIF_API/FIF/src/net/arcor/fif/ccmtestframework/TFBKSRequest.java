package net.arcor.fif.ccmtestframework;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import net.arcor.fif.messagecreator.Request;

/**
* @author schwarje
*
*/
public class TFBKSRequest extends Request {

	private String transactionID = null;
	private String packageName = null;
	private String serviceName = null;
	private Map outputParams = null;
	private List<String> resultParamList = new LinkedList<String>();
	private Map<String, String> resultParams = new HashMap<String, String>();
	
	public Map getOutputParams() {
		return outputParams;
	}

	public void setOutputParams(Map outputParams) {
		this.outputParams = outputParams;
	}


	public Map<String, String> getResultParams() {
		return resultParams;
	}

	public void setResultParams(Map<String, String> resultParams) {
		this.resultParams = resultParams;
	}

	public String getTransactionID() {
		return transactionID;
	}

	public void setTransactionID(String transactionID) {
		this.transactionID = transactionID;
	}

	public String getServiceName() {
		return serviceName;
	}

	public void setServiceName(String serviceName) {
		this.serviceName = serviceName;
	}

	public String getPackageName() {
		return packageName;
	}

	public void setPackageName(String packageName) {
		this.packageName = packageName;
	}

	public List<String> getResultParamList() {
		return resultParamList;
	}

	public void setResultParamList(List<String> resultParamList) {
		this.resultParamList = resultParamList;
	}


}
