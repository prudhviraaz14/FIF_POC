package net.arcor.fif.ccmtestframework;

import java.util.HashMap;
import java.util.Map;

public class TFSomPart {
	
	private String filename = null;
	private Map params = null;

	public TFSomPart() {
		super();
		params = new HashMap();
	}

	public String getFilename() {
		return filename;
	}

	public void setFilename(String filename) {
		this.filename = filename;
	}

	public Map getParams() {
		return params;
	}

	public void setParams(Map params) {
		this.params = params;
	}

}
