/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/ServiceBusInterfaceException.java-arc   1.0   Jan 29 2008 17:44:20   schwarje  $
 *    $Revision:   1.0  $
 *    $Workfile:   ServiceBusInterfaceException.java  $
 *      $Author:   schwarje  $
 *        $Date:   Jan 29 2008 17:44:20  $
 *
 *  Function: Main class of the service bus interface
 *  
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/ServiceBusInterfaceException.java-arc  $
 * 
 *    Rev 1.0   Jan 29 2008 17:44:20   schwarje
 * Initial revision.
 * 
 *    Rev 1.0   Aug 09 2007 17:24:38   schwarje
 * Initial revision.
 * 
 ***************************************************************************  
 */
package net.arcor.fif.client;

public class ServiceBusInterfaceException extends Exception {
	static final long serialVersionUID = 125631265316236123L;
	
	private String errorCode;
	
	private Throwable root;

	public ServiceBusInterfaceException (String errorCode, String message, Throwable root) {
		super(message);
		this.errorCode = errorCode;
		this.root = root;
	}

	public ServiceBusInterfaceException (String errorCode, String message) {
		this(errorCode, message, null);
	}
	
	public String getErrorCode() {
		return errorCode;
	}

	public void setErrorCode(String errorCode) {
		this.errorCode = errorCode;
	}

	public Throwable getRoot() {
		return root;
	}

	public void setRoot(Throwable root) {
		this.root = root;
	}
	
	
}
