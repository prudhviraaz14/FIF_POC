package net.arcor.fif.common;

import javax.xml.soap.SOAPMessage;


public interface FifHttpServiceHandler {
	/**
	 * method for processing service requests, the one that does the actual work
	 * @param request
	 * @return
	 * @throws FIFException
	 */
	public String execute(SOAPMessage message) throws FIFException;
	public String getSoapAction();
}
