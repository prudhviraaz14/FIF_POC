/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousServiceBusClientRequestHandler.java-arc   1.20   Jun 10 2015 13:25:16   schwarje  $
 *    $Revision:   1.20  $
 *    $Workfile:   SynchronousServiceBusClientRequestHandler.java  $
 *      $Author:   schwarje  $
 *        $Date:   Jun 10 2015 13:25:16  $
 *
 *  Function: request handler for the synchronous fif service bus client
 *  
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/SynchronousServiceBusClientRequestHandler.java-arc  $
 * 
 *    Rev 1.20   Jun 10 2015 13:25:16   schwarje
 * PPM-95514: use error literals
 * 
 *    Rev 1.19   May 26 2015 07:33:20   schwarje
 * PPM-95514 CPM
 * 
 *    Rev 1.18   Jan 18 2013 07:46:54   schwarje
 * IT-32438: Allow switching off the MessageCreator
 * 
 *    Rev 1.17   Sep 14 2010 16:34:44   schwarje
 * SPN-FIF-000103773: fixed service bus clients
 * 
 *    Rev 1.16   Mar 11 2010 13:13:10   schwarje
 * IT-26029: Decomissioning MQReader
 * 
 *    Rev 1.15   Apr 03 2009 15:50:32   schwarje
 * SPN-FIF-000084890: made retrieveRequest synchronous
 * 
 *    Rev 1.14   Mar 26 2009 16:44:40   schwarje
 * SPN-FIF-000084593: made SyncFIFClient thread-safe when running multithreaded
 * 
 *    Rev 1.13   Mar 10 2009 10:29:06   makuier
 * Added copy constructor.
 * 
 *    Rev 1.12   Feb 25 2009 15:48:22   schwarje
 * IT-k-24193: process responses for requests with events (mobile number porting)
 * SPN-FIF-000082822: also create a handleFailedFifRequest request after technical errors returned from the backend
 * 
 *    Rev 1.11   Jan 21 2009 13:51:02   schwarje
 * IT-k-24721: allow events without service requests
 * 
 *    Rev 1.10   Jan 20 2009 09:57:16   schwarje
 * SPN-CCB-000081938: handle fatalServiceResponse in SbusResponseClient
 * 
 *    Rev 1.9   Dec 17 2008 16:35:34   schwarje
 * SyncFIF: handle all kinds of server replies
 * 
 *    Rev 1.8   Dec 05 2008 16:24:58   schwarje
 * IT-k-24294: added external system id for retrieveRequest
 * 
 *    Rev 1.7   Sep 15 2008 09:35:14   schwarje
 * SPN-FIF-000076119: improved request logging for service bus client
 * 
 *    Rev 1.6   Aug 21 2008 17:02:30   schwarje
 * IT-22684: added support for populating output parameters on service bus requests
 * 
 *    Rev 1.5   Jul 31 2008 09:17:42   schwarje
 * IT-k-23569: new FIF client for reading responses for service bus requests initiated from CCM
 * 
 *    Rev 1.4   Feb 28 2008 19:31:56   schwarje
 * IT-20793: updated
 * 
 *    Rev 1.3   Feb 28 2008 15:25:32   schwarje
 * IT-20793: added processing of events
 * 
 *    Rev 1.2   Feb 06 2008 20:04:06   schwarje
 * IT-20058: updated
 * 
 *    Rev 1.1   Jan 30 2008 13:06:50   schwarje
 * IT-20058: updated
 * 
 *    Rev 1.0   Jan 29 2008 17:44:16   schwarje
 * Initial revision.
 * 
 ***************************************************************************  
 */
package net.arcor.fif.client;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Map;

import net.arcor.fif.common.FIFErrorLiterals;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FIFTechnicalException;
import net.arcor.fif.messagecreator.FIFError;
import net.arcor.fif.messagecreator.FIFReplyMessage;
import net.arcor.fif.messagecreator.FIFReplyMessageFactory;
import net.arcor.fif.messagecreator.FIFTransactionResult;
import net.arcor.fif.messagecreator.Message;
import net.arcor.fif.messagecreator.MessageCreatorMetaData;
import net.arcor.fif.messagecreator.OutputParameter;
import net.arcor.fif.messagecreator.ParameterList;
import net.arcor.fif.messagecreator.ParameterListItem;
import net.arcor.fif.messagecreator.Request;
import net.arcor.fif.messagecreator.RequestFactory;
import net.arcor.fif.messagecreator.SimpleParameter;

import org.apache.log4j.Logger;

/**
 * request handler for the synchronous fif service bus client, provides functionality 
 * specific for the synchronous service bus client 
 * @author schwarje
 *
 */
public class SynchronousServiceBusClientRequestHandler extends RequestHandler {

	/**
	 * The log4j logger.
	 */
	private static Logger logger = Logger.getLogger(SynchronousServiceBusClientRequestHandler.class);
	
	/**
	 * for logging service bus requests to the database
	 */
	private static ServiceBusRequestLogger requestLogger = null;
	
	/**
	 * constructor, calls super constructor and sets up the request logging
	 * @throws FIFException
	 * @throws SQLException
	 */
	public SynchronousServiceBusClientRequestHandler () throws FIFException, SQLException {
		super();
		setupRequestLogging();
	}

	public SynchronousServiceBusClientRequestHandler(String instanceName) throws FIFException, SQLException{
		super(instanceName, true);	
		setupRequestLogging();
	}
	/**
	 * sets up the request logging,
	 * - creates a database connection
	 * - prepares database statements
	 * @throws FIFException
	 * @throws SQLException
	 */
	public synchronized static void setupRequestLogging () throws FIFException, SQLException {
        try {
        	ServiceBusRequest.setClientName(ClientConfig.getSetting("servicebusclient.ClientName"));
		} catch (FIFException e) {
			ServiceBusRequest.setClientName("FIF");
		}
        try {
        	ServiceBusRequest.setEnvironmentName(ClientConfig.getSetting("servicebusclient.EnvironmentName"));
		} catch (FIFException e) {
			ServiceBusRequest.setEnvironmentName("FIFServiceBusClient");
		}

		if (requestLogger == null)
			requestLogger = new ServiceBusRequestLogger();
	}
	
	/**
	 * Processes a service bus request.
	 * @param busRequest the request to be processed
	 * @throws SQLException
	 */
	public ServiceBusRequest processServiceBusRequest(ServiceBusRequest busRequest) throws FIFException {
		// create a fif request from a service bus request
		Request request = null;
		Message reply = null;

		try {					
			// check for an existing request
			ServiceBusRequest previousBusRequest = 
				requestLogger.retrieveRequest(busRequest.getRequestId(), busRequest.getRequestType());

			// insert the request into the database, if there is none yet 
			if (previousBusRequest == null)
				requestLogger.insertRequest(busRequest);				
			
			// populate the recycling parameters on the request, if the request is in recycling.
			else if (previousBusRequest.getStatus().equals(ServiceBusRequest.requestStatusInRecycling))
				busRequest.setRecycleStage(previousBusRequest.getRecycleStage());

			// if status is in progress we cannot proceed. Something must have gone badly wrong.
			else if (previousBusRequest.getStatus().equals(ServiceBusRequest.requestStatusInProgress))
				throw new FIFTechnicalException(FIFErrorLiterals.FIF0036, "Request (" + busRequest.getRequestId() + ") is already in progress. Cannot process again.");

			// if status is in progress we cannot proceed as the request was already 
			// successfully processed or the id was reused.
			else if (previousBusRequest.getStatus().equals(ServiceBusRequest.requestStatusCompleted))
				throw new FIFTechnicalException(FIFErrorLiterals.FIF0037, "Request (" + busRequest.getRequestId() + ") is already completed. Cannot process again.");

			// TODO dont know yet what to do with existing failed requests
			else if (previousBusRequest.getStatus().equals(ServiceBusRequest.requestStatusFailed))
				throw new FIFTechnicalException(FIFErrorLiterals.FIF0038, "Request (" + busRequest.getRequestId() + ") is already finally failed. Cannot process again.");
			
			// unexpected state in database
			else
				throw new FIFTechnicalException(FIFErrorLiterals.FIF0039, "Request (" + busRequest.getRequestId() + ") which is not in recycling already exists in database.");
			
			// create the actual fif request
			// TODO recycle missing action 
			try {
				request = createRequest(busRequest);
			} catch (FIFException e) {
				reply = FIFReplyMessageFactory.createFailureMessage(
						null, 
						FIFErrorLiterals.FIF0012.name(), 
						"Request could not be created, see following exception: " + e.getMessage());
				
				if (shouldWeRecycle(busRequest.getRecycleStage(), reply)) {
					((FIFReplyMessage)reply).setRecycleMessage(true);
					((FIFReplyMessage)reply).setRecycleDelay(recycleDelays.get(busRequest.getRecycleStage()+1));
				}
			}
			
			if (request != null) {
				// set recycle status on request
				request.setRecycleStage(busRequest.getRecycleStage());
				
				if (busRequest.getRequestType().equals(ServiceBusRequest.requestTypeEvent)) {
					// find request and parameters
					ServiceBusRequest serviceRequestForEvent = 
						requestLogger.retrieveRequest(busRequest.getRequestId(), ServiceBusRequest.requestTypeService);
					
					// raise an error, if the event was not found
					if (serviceRequestForEvent != null) { 
						requestLogger.retrieveRequestParams(serviceRequestForEvent);
					
						// update service request for event
						if (serviceRequestForEvent.getStatus().equals(ServiceBusRequest.requestStatusPending) ||
							serviceRequestForEvent.getStatus().equals(ServiceBusRequest.requestStatusRespondedNegative) ||
							serviceRequestForEvent.getStatus().equals(ServiceBusRequest.requestStatusRespondedPositive)) {
							// set result, error message and end date
							if (busRequest.getParameters().get("originalRequestResult").equals("true"))
								serviceRequestForEvent.setStatus(ServiceBusRequest.requestStatusCompleted);
							else {
								serviceRequestForEvent.setStatus(ServiceBusRequest.requestStatusFailed);
								serviceRequestForEvent.setThrowable(
										new ServiceBusInterfaceException(
												busRequest.getParameters().get("originalRequestErrorCode"),
												busRequest.getParameters().get("originalRequestErrorText")));
							}
							serviceRequestForEvent.setEndDate(new Date(System.currentTimeMillis()));
							requestLogger.updateRequest(serviceRequestForEvent);
						}
						
						// add parameters of previous request
						for (String key : serviceRequestForEvent.getParameters().keySet()) {
							if (!(request.getParams().containsKey(key)))
								request.addParam(new SimpleParameter(key, serviceRequestForEvent.getParameters().get(key)));
						}
					}			
				}

				reply = processRequest(request);
			}
		} catch (SQLException e) {
			logger.error("Exception: ", e);
			throw new FIFException("Exception while logging service bus request (" + busRequest.getRequestId() + 
					") to the database. Request has not been processed.", e);
		}
		
		// raise error as long as only simple requests are implemented for fif service bus clients 
		if (!(reply instanceof FIFReplyMessage))
			throw new FIFException("Transaction lists are not implemented yet for ServiceBus clients.");			
		
		FIFReplyMessage fifReplyMessage = (FIFReplyMessage) reply;
		
		// set the recycling parameters on the service bus request object
		busRequest.setRecycleMessage(fifReplyMessage.getRecycleMessage());
		busRequest.setRecycleDelay(fifReplyMessage.getRecycleDelay());
		if (fifReplyMessage.getRecycleMessage())
			busRequest.setRecycleStage(busRequest.getRecycleStage() + 1);

		FIFTransactionResult result = fifReplyMessage.getResult();
		
		// put the result and the error message on the service bus request object
		int transactionStatus = result.getResult();
		
		// set the status for successful fif requests
		if (transactionStatus == FIFTransactionResult.SUCCESS) {
			busRequest.setStatus(ServiceBusRequest.requestStatusCompleted);
			for (Object outputParameter : fifReplyMessage.getOutputParameters()) {
				OutputParameter param = (OutputParameter) outputParameter;
				busRequest.getReturnParameters().put(param.getName(), param.getValue());
			}
		}
		
		// set the status for failed fif requests
		else if (transactionStatus == FIFTransactionResult.FAILURE) {
			// set the error message, if one was found
			ArrayList<FIFError> errors = extractErrors(fifReplyMessage);
			if (errors.size() > 0)
				busRequest.setThrowable(new ServiceBusInterfaceException(
						errors.get(0).getNumber(), errors.get(0).getMessage()));
			
			// set the status
			if (fifReplyMessage.getRecycleMessage())
				busRequest.setStatus(ServiceBusRequest.requestStatusInRecycling);
			else {
				busRequest.setStatus(ServiceBusRequest.requestStatusFailed);
			}
		}
		else {
			try {
				handleIllegalFifReply(transactionStatus);
			} catch (ServiceBusInterfaceException e) {				
				busRequest.setStatus(ServiceBusRequest.requestStatusFailed);
				busRequest.setThrowable(e);
			}
		}
		
		try {
			// update the request in the database
			busRequest.setEndDate(new Date(System.currentTimeMillis()));
			requestLogger.updateRequest(busRequest);
			requestLogger.insertRequestResults(busRequest);
		} catch (SQLException e) {
			logger.error("Exception while logging service bus request (" + busRequest.getRequestId() + ") to the database. Request has been processed.", e);
		}						
		
		return busRequest;
	}

	/**
	 * Processes an async reply to a service bus request.
	 * @param busRequest the reply to be processed
	 * @throws SQLException
	 */
	public ServiceBusRequest processServiceBusReply(ServiceBusRequest busRequest) throws FIFException {
		// create a fif request from a service bus request
		Request request = null;
		Message reply = null;

		try {					
			// check for an existing request
			ServiceBusRequest originalBusRequest = 
				requestLogger.retrieveRequest(busRequest.getRequestId(), ServiceBusRequest.requestTypeService);

			// check if there was an event for the request, which would have changed the state of the original request
			ServiceBusRequest eventForOriginalBusRequest = 
				requestLogger.retrieveRequest(busRequest.getRequestId(), ServiceBusRequest.requestTypeEvent);
			
			// raise an error, if the service was not found
			if (originalBusRequest == null)
				throw new FIFException("Couldn't find service request (Id: " + busRequest.getRequestId() + ") for response.");
				
			else {
				// copy over the external system id, only for documentation
				busRequest.setExternalSystemId(originalBusRequest.getExternalSystemId());				
				
				// we only handle pending request, any other state will be rejected
				if (!originalBusRequest.getStatus().equals(ServiceBusRequest.requestStatusPending)) {					
					// if there has not been an event, something's terribly wrong
					if (eventForOriginalBusRequest == null)
						throw new FIFException("The original service bus request (Id: " + busRequest.getRequestId() + 
						") is not in status PENDING. This client designed to only process responses of that type.");
				}
				
				// we only async requests, anything else should be impossible by configuration
				if (originalBusRequest.isCallSynch())
					throw new FIFException("This client is not designed to process responses " +
							"for synchronous service bus requests.");

				// we only async requests, anything else should be impossible by configuration
				if (!(originalBusRequest.getServiceName().equals(busRequest.getServiceName())))
					throw new FIFException("Response service (" + busRequest.getServiceName() + 
							") is of different type than original service (" + originalBusRequest.getServiceName() + ")");

				if (eventForOriginalBusRequest == null) {
					// set result, error message and end date
					if (busRequest.getParameters().get("originalRequestResult").equals("true"))
						originalBusRequest.setStatus(ServiceBusRequest.requestStatusRespondedPositive);
					else {
						originalBusRequest.setStatus(ServiceBusRequest.requestStatusRespondedNegative);
						originalBusRequest.setThrowable(
								new ServiceBusInterfaceException(
										busRequest.getParameters().get("originalRequestErrorCode"),
										busRequest.getParameters().get("originalRequestErrorText")));
					}
					originalBusRequest.setEndDate(new Date(System.currentTimeMillis()));
					requestLogger.updateRequest(originalBusRequest);
				}
				
				// create the actual fif request, if an action mapping exists, otherwise, don't do much
				if (MessageCreatorMetaData.hasActionMapping(busRequest.getServiceName())) {
					try {
						request = createRequest(busRequest);
					} catch (FIFException e) {
						reply = FIFReplyMessageFactory.createFailureMessage(null, FIFErrorLiterals.FIF0012.name(), e.getMessage());
					}
				}
				
				if (request != null) {
					requestLogger.retrieveRequestParams(originalBusRequest);
					
					// add parameters of previous request
					for (String key : originalBusRequest.getParameters().keySet()) {
						if (!(request.getParams().containsKey(key)))
							request.addParam(new SimpleParameter(key, originalBusRequest.getParameters().get(key)));
					}
					// also add the external system id, so FIF can use it
					request.addParam(new SimpleParameter("originalRequestExternalSystemId", busRequest.getExternalSystemId()));
					
					reply = processRequest(request);
					
					// raise error as long as only simple requests are implemented for fif service bus clients 
					if (!(reply instanceof FIFReplyMessage))
						throw new FIFException("Transaction lists are not implemented yet for ServiceBus clients.");			
					
					FIFReplyMessage fifReplyMessage = (FIFReplyMessage) reply;					
					FIFTransactionResult result = fifReplyMessage.getResult();
					
					// put the result and the error message on the service bus request object
					int transactionStatus = result.getResult();
					
					// set the status for successful fif requests
					if (transactionStatus == FIFTransactionResult.SUCCESS)
						busRequest.setStatus(ServiceBusRequest.requestStatusCompleted);
					
					// set the status for failed fif requests
					else if (transactionStatus == FIFTransactionResult.FAILURE) {
						// set the error message, if one was found
						ArrayList<FIFError> errors = extractErrors(fifReplyMessage);
						if (errors.size() > 0)
							busRequest.setThrowable(new ServiceBusInterfaceException(
									errors.get(0).getNumber(), errors.get(0).getMessage()));
						
						// set the status
						busRequest.setStatus(ServiceBusRequest.requestStatusFailed);
					}

					else {
						try {
							handleIllegalFifReply(transactionStatus);
						} catch (ServiceBusInterfaceException e) {
							busRequest.setStatus(ServiceBusRequest.requestStatusFailed);
							busRequest.setThrowable(e);
						}
					}
				}
				else
					busRequest.setStatus(ServiceBusRequest.requestStatusCompleted);					
			}
			busRequest.setEndDate(new Date(System.currentTimeMillis()));
		} catch (SQLException e) {
			throw new FIFException("Exception while retrieving original service bus request (" + 
					busRequest.getRequestId() + ") from the database.", e);
		}						
			
		try {
			if (!busRequest.isFatalServiceResponse())
				requestLogger.insertRequest(busRequest);			
		} catch (SQLException e) {
			logger.error("Exception while logging service bus request (" + 
					busRequest.getRequestId() + ") to the database.", e);
		}						
		
		return busRequest;
	}

	/**
	 * @param busRequest
	 * @param transactionStatus
	 * @throws FIFException
	 */
	private void handleIllegalFifReply(int transactionStatus) throws ServiceBusInterfaceException {
		if (transactionStatus == FIFTransactionResult.NOT_EXECUTED)
		{
			throw new ServiceBusInterfaceException(
					FIFErrorLiterals.FIF0014.name(), "Request could for unknown reasons not be executed in the FIF backend.");
		}

		else if (transactionStatus == FIFTransactionResult.INVALID_REPLY)
		{
			throw new ServiceBusInterfaceException(
					FIFErrorLiterals.FIF0015.name(), "Received invalid reply from the FIF backend. Cannot determine, " +
							"if the request was executed.");
		}
			
		else if (transactionStatus == FIFTransactionResult.CANCELED ||
				 transactionStatus == FIFTransactionResult.POSTPONED)
		{
			throw new ServiceBusInterfaceException(
					FIFErrorLiterals.FIF0016.name(), "Canceled and postponed requests are not supported in this client. " +
							"If this error is raised, the software was not properly tested.");
		}
		
		else {
			throw new ServiceBusInterfaceException(FIFErrorLiterals.FIF0017.name(), "FIF returned with unknown status (" + 
					transactionStatus + "), don't know what to do now.");				
		}
	}

	/**
	 * @param busRequest
	 * @param request
	 * @throws FIFException
	 */

	public Request createRequest(ServiceBusRequest busRequest) throws FIFException
	{
		Request request;
		request = RequestFactory.createRequest(busRequest.getServiceName());

		// adding a transaction id to this request, needed for all FIF transactions
		try {
			request.addParam(new SimpleParameter("transactionID",busRequest.getRequestId()));
			request.addParam(new SimpleParameter("packageName",busRequest.getPackageName()));
			for (String key : busRequest.getParameters().keySet()) {
				request.addParam(new SimpleParameter(key, busRequest.getParameters().get(key)));
			}

			for (String listName : busRequest.getParameterLists().keySet()) {
				ParameterList parameterList = new ParameterList(listName);
				for (Map<String, String> listItem : busRequest.getParameterLists().get(listName)) {
					ParameterListItem parameterListItem = new ParameterListItem();
					for (String listItemName : listItem.keySet()) {
						parameterListItem.addParam(
								new SimpleParameter(listItemName, listItem.get(listItemName)));			
					}
					parameterList.addItem(parameterListItem);
				}
				request.addParam(parameterList);
			}			
		} catch (FIFException e) {
			// ignored, because exception is only raised, if parameter name is empty		
		}

		return request;
	}
		
	/**
	 * Shuts down the object.
	 */
	protected void shutdown() {
	    logger.info("Shutting down message sender...");
	    boolean success = true;
	
	    if (success) {
	        logger.info("Successfully shut down message sender.");
	    } else {
	        logger.error("Errors while shutting down message sender.");
	    }
	}
	
}
