/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/common/FIFErrorLiterals.java-arc   1.1   Jun 19 2015 14:54:04   schwarje  $
 *    $Revision:   1.1  $
 *    $Workfile:   FIFErrorLiterals.java  $
 *      $Author:   schwarje  $
 *        $Date:   Jun 19 2015 14:54:04  $
 *
 *  Function: FIF error literals
 *  
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/common/FIFErrorLiterals.java-arc  $
 * 
 *    Rev 1.1   Jun 19 2015 14:54:04   schwarje
 * added more ErrorLiterals
 * 
 *    Rev 1.0   Jun 10 2015 13:17:14   schwarje
 * Initial revision.
 * 
 ***************************************************************************  
 */
package net.arcor.fif.common;

public enum FIFErrorLiterals {

	FIF0000,
	FIF0001,
	FIF0002,
	FIF0003,
	FIF0004,
	FIF0005,
	FIF0006,
	FIF0007,
	FIF0008,
	FIF0009,
	FIF0010, // "The server has crashed while processing the message."
	FIF0011, // Transaction id of the reply doesn't match the transaction id of the request. Something is badly wrong here!
	FIF0012, // "Request could not be created, see following exception: " + e.getMessage()
	FIF0013,
	FIF0014, // "Request could for unknown reasons not be executed in the FIF backend."
	FIF0015, // "Received invalid reply from the FIF backend. Cannot determine, if the request was executed."
	FIF0016, // "Canceled and postponed requests are not supported in this client. If this error is raised, the software was not properly tested."
	FIF0017, // "FIF returned with unknown status (" + transactionStatus + "), don't know what to do now."
	FIF0018, // "The reply returned from the FIF backend could not be parsed. FIF-API cannot determine, if the request was processed successfully."
	FIF0020, // e.getMessage()
	FIF0029, // (Oracle) error during processSQL
	FIF0030, // "The FifTransaction executeSQL may only be processed as single request, not as a request list of more than one request."
	FIF0031, // "Unknown exception raised: " + attachedException.getMessage()
	FIF0032, // "SOAP-Action " + soapAction + " is not supported by this FIF-Client."
	FIF0033, // "Exception occured during deserialization. See details: " + e.getMessage() 
	FIF0034, // "Exception occured during serialization. See details: " + e.getMessage()
	FIF0035, // "Exception occured while serializing SOAP Header" 
	FIF0036, // "Request (" + busRequest.getRequestId() + ") is already in progress. Cannot process again."
	FIF0037, // "Request (" + busRequest.getRequestId() + ") is already completed. Cannot process again."
	FIF0038, // "Request (" + busRequest.getRequestId() + ") is already finally failed. Cannot process again."
	FIF0039; // "Request (" + busRequest.getRequestId() + ") which is not in recycling already exists in database."
	
}
