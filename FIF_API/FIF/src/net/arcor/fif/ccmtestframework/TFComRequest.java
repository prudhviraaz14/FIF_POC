package net.arcor.fif.ccmtestframework;

import java.util.ArrayList;
import java.util.List;

import net.arcor.fif.messagecreator.Request;

/**
* @author schwarje
*
*/
public class TFComRequest extends Request {


	private List<TFSomPart> somParts = null;
	private String orderId = null;
	
	public TFComRequest() {
		super();
		somParts = new ArrayList<TFSomPart>();
	}

	public List<TFSomPart> getSomParts() {
		return somParts;
	}

	public void setSomParts(List<TFSomPart> somParts) {
		this.somParts = somParts;
	}

	public String getOrderId() {
		return orderId;
	}

	public void setOrderId(String orderId) {
		this.orderId = orderId;
	}


}
