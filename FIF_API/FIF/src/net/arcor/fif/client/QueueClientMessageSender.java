/*
 * $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/QueueClientMessageSender.java-arc   1.10   Nov 07 2008 11:24:08   makuier  $
 *
 * $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/QueueClientMessageSender.java-arc  $
 * 
 *    Rev 1.10   Nov 07 2008 11:24:08   makuier
 * Manual rollback flag added.
 * 
 *    Rev 1.9   Aug 08 2008 15:49:02   wlazlow
 * IT-21113
 * 
 *    Rev 1.8   Aug 16 2007 19:23:06   lejam
 * Added support for OMTSOrderId on the request list level IT-19036
 * 
 *    Rev 1.7   Jun 19 2007 16:54:42   makuier
 * remove control characters from the original message when craeting a reply to avoid application crash.
 * SPN-FIF-000056412
 * 
 *    Rev 1.6   Apr 19 2007 17:14:44   schwarje
 * IT-19232: support for transaction lists in database clients
 * 
 *    Rev 1.5   Sep 15 2004 17:06:50   goethalo
 * SPN-FIF-000025474: Remove CDATA sections from original request in reply message if original request is invalid.
 * 
 *    Rev 1.4   Aug 02 2004 15:26:16   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.3   Jul 15 2004 12:14:54   goethalo
 * SPN-CCB-000023940: Added code to take care of encoding problems for incoming XML.
 * 
 *    Rev 1.2   Jun 14 2004 15:43:02   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 */
package net.arcor.fif.client;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.messagecreator.FIFError;
import net.arcor.fif.messagecreator.FIFRequest;
import net.arcor.fif.messagecreator.InvalidRequest;
import net.arcor.fif.messagecreator.InvalidRequestList;
import net.arcor.fif.messagecreator.Message;
import net.arcor.fif.messagecreator.MessageCreator;
import net.arcor.fif.messagecreator.MessageCreatorFactory;
import net.arcor.fif.messagecreator.MessageCreatorMetaData;
import net.arcor.fif.messagecreator.MessageSender;
import net.arcor.fif.messagecreator.Request;
import net.arcor.fif.messagecreator.FIFRequestList;
import net.arcor.fif.messagecreator.RequestSerializer;
import net.arcor.fif.transport.MQJMSClient;
import net.arcor.fif.transport.TransportManager;
import net.arcor.fif.transport.TransportUtils;

import org.apache.log4j.Logger;

/**
 * This class is responsible for sending FIF messages based on requests
 * coming from a queue.
 * It reads the requests from the queue, creates a FIF message for this
 * request, and sends the message to FIF.
 * @author goethalo
 */
public class QueueClientMessageSender implements Runnable {

	/*------------------*
	 * MEMBER VARIABLES *
	 *------------------*/

	/**
	 * The log4j logger.
	 */
	private static Logger logger = Logger
			.getLogger(QueueClientMessageSender.class);

	/**
	 * The client request receiver.
	 */
	private net.arcor.fif.transport.MessageReceiver clientRequestReceiver = null;

	/**
	 * The client response sender.
	 */
	private net.arcor.fif.transport.MessageSender clientResponseSender = null;

	/**
	 * The FIF message sender.
	 */
	private net.arcor.fif.messagecreator.MessageSender FIFMessageSender = null;

	/*---------*
	 * METHODS *
	 *---------*/

	/**
	 * Initializes the message sender.
	 */
	protected synchronized void init() throws FIFException {
		logger.info("Initializing QueueClientMessageSender...");

		// Client Request Receiver setup
		logger.debug("Initializing client request receiver...");
		clientRequestReceiver = TransportManager
				.createReceiver("ClientRequestQueue");
		clientRequestReceiver.start();
		logger.debug("Successfully initialized client request receiver.");

		// Client Response Sender setup
		logger.debug("Initializing client response sender...");
		clientResponseSender = TransportManager
				.createSender("ClientResponseQueue");
		clientResponseSender.start();
		logger.debug("Successfully initialized client response sender.");

		// FIF Message Sender setup
		logger.debug("Initializing FIF message sender...");
		FIFMessageSender = new MessageSender("FIFRequestQueue");
		FIFMessageSender.start();
		logger.debug("Successfully initialized FIF message sender.");

		logger.info("Successfully initialized QueueClientMessageSender.");
	}

	/**
	 * Starts to process the requests from the queue.
	 * @see java.lang.Runnable#run()
	 */
	public void run() {
		try {
			boolean timedOut = false;
			while (!(Thread.interrupted()) && (!QueueClient.inErrorStatus())) {
				// Wait for a client request...
				if (!timedOut) {
					logger.info("Waiting for client request...");
				}
				javax.jms.Message msg = clientRequestReceiver.receiveMessage(1);

				// Start at the beginning of the loop again if the message is null
				if (msg == null) {
					timedOut = true;
					continue;
				}

				// We did not time out. Remember that
				timedOut = false;

				// Process the request
				logger.debug("Processing request...");
				processRequest(msg);

				// Request was successfully processed: acknowledge the message
				msg.acknowledge();
				logger.debug("Successfully processed request.");
			}
		} catch (Exception e) {
			if (QueueClient.isShutDownHookInvoked() == false) {
				// Set the error status on the QueueClient object
				logger.fatal("Fatal error while processing requests", e);
			}
			QueueClient.setErrorStatus();
		}
	}

	/**
	 * Processes a queue request.
	 * @param msg     the message containing the request.
	 * @throws FIFException if the request could not be processed.
	 */
	public void processRequest(javax.jms.Message msg) throws FIFException {
		// Get the message text
		String msgText = TransportUtils.getMessageText(msg,
				((MQJMSClient) clientRequestReceiver.getJmsClient())
						.getEncoding());
		logger.debug("Received request message: " + msgText);

		// Parse the request
		Request request = null;
		try {
			StringBuffer beautifiedRequest = new StringBuffer();
			request = RequestSerializer.serializeFromString(msgText,
					beautifiedRequest, true);
			// Replace the original message by the beautified version
			if (beautifiedRequest.length() != 0) {
				msgText = beautifiedRequest.toString();
			}
			logger.debug("Parsed request: " + request.toString());
		} catch (FIFException fe) {
			throw new FIFException("Problems while serializing request.  "
					+ "This exception should never been thrown. Request: "
					+ msgText, fe);
		}

		// Process the request
		if (request instanceof FIFRequest) {
			processSimpleRequest((FIFRequest) request, msgText);
		} else if (request instanceof FIFRequestList) {
			processRequestList((FIFRequestList) request, msgText);
		} else {
			throw new FIFException("Request is of unknown type. Type: "
					+ request.getClass().getName());
		}
	}

	/**
	 * Processes a simple FIF request.
	 * @param request  the serialized FIF request object.
	 * @param msgText  the original text of the request message.
	 * @throws FIFException if the request could not be processed.
	 */
	private void processSimpleRequest(FIFRequest request, String msgText)
			throws FIFException {
		try {
			logger
					.info("Processing request for action: "
							+ request.getAction() + ", transaction ID: "
							+ request.getTransactionID() + "...");

			// Write the request to a file, if needed
			writeRequestMessage(msgText, request.getTransactionID(), request
					.getAction());

			// Create the message
			Message FIFMsg = createMessage(request, msgText);

			if ((FIFMsg != null)
					&& (FIFMsg instanceof QueueClientResponseMessage)) {
				// The message creation failed, handle errors.
				QueueClientResponseMessage failureResponse = (QueueClientResponseMessage) FIFMsg;
				logger
						.debug("Sending message: "
								+ failureResponse.getMessage());
				clientResponseSender.sendMessage(failureResponse.getMessage());

				// Write the response
				writeResponseMessage(failureResponse);

				// Log the errors - except the received request
				ArrayList errors = failureResponse.getErrors();
				for (int i = 0; i < errors.size(); i++) {
					logger.error(((FIFError) (errors.get(i))).getMessage());
				}
				logger.error("Errors while processing request for action: "
						+ request.getAction() + ", transaction ID: "
						+ request.getTransactionID() + ".");
				return;
			}

			if (FIFMsg != null) {
				// We have a success, log it.
				FIFMessageSender.sendMessage(FIFMsg);

				// Write the sent message
				writeSentMessage(FIFMsg, request.getTransactionID(), request
						.getAction());

				// Log the success
				logger.info("Successfully processed request for action: "
						+ request.getAction() + ", transaction ID: "
						+ request.getTransactionID() + ".");
			}
		} catch (FIFException fe) {
			logger.error("Exception while processing request for action: "
					+ request.getAction() + ", transaction ID: "
					+ request.getTransactionID() + ".", fe);
			throw fe;
		}
	}

	/**
	 * Processes a FIF request list.
	 * @param msgText  the original text of the request message.
	 * @param request  the serialized FIF request list object.
	 * @throws FIFException if the request could not be processed.
	 */
	private void processRequestList(FIFRequestList requestList, String msgText)
			throws FIFException {
		try {
			logger.info("Processing request list with name: "
					+ requestList.getName() + ", ID: " + requestList.getID()
					+ "...");

			// Write the request to a file, if needed
			writeRequestListMessage(msgText, requestList.getID(), requestList
					.getName());

			// Create the message
			Message FIFMsg = createMessage(requestList, msgText);

			if ((FIFMsg != null)
					&& (FIFMsg instanceof QueueClientResponseListMessage)) {
				// The message creation failed, handle errors.
				QueueClientResponseListMessage failureResponse = (QueueClientResponseListMessage) FIFMsg;
				clientResponseSender.sendMessage(failureResponse.getMessage());

				// Write the response to the file system
				writeResponseListMessage(failureResponse);

				// Log the errors - except the received request
				List errors = failureResponse.getErrors();
				Iterator errorIter = errors.iterator();
				while (errorIter.hasNext()) {
					logger.error(((FIFError) (errorIter.next())).getMessage());
				}
				logger.error("Errors while processing request list with name: "
						+ requestList.getName() + ", ID: "
						+ requestList.getID() + ".");
				return;
			}

			if (FIFMsg != null) {
				// We have a success, log it.
				FIFMessageSender.sendMessage(FIFMsg);

				// Write the sent message to the file system
				writeSentListMessage(FIFMsg, requestList.getID(), requestList
						.getName());

				// Log the success
				logger.info("Successfully processed request list for name: "
						+ requestList.getName() + ", ID: "
						+ requestList.getID() + ".");
			}
		} catch (FIFException fe) {
			logger.error("Exception while processing request list name: "
					+ requestList.getName() + ", ID: " + requestList.getID()
					+ ".", fe);
			throw fe;
		}
	}

	/**
	 * Creates a message for a given request.
	 * @param request  the request to create the message for.
	 * @param msgText  the original message text.
	 * @return the message related to the request, or a 
	 * <code>QueueClientResponseMessage</code> if the message creation failed.
	 */
	private Message createMessage(FIFRequest request, String msgText) {
		// Check if we got a valid request
		ArrayList errors = new ArrayList();
		if (!validateSimpleRequest(request, msgText, errors)) {
			// Handle Errors
			QueueClientResponseMessage response = new QueueClientResponseMessage(
					QueueClientResponseMessage.FAILURE, request.getAction(),
					request.getTransactionID(), errors);
			return response;
		}

		// Get the message creator
		String action = request.getAction();
		MessageCreator mc = null;

		if (MessageCreatorMetaData.hasActionMapping(action)) {
			try {
				mc = MessageCreatorFactory.getMessageCreator(action);
			} catch (FIFException fe) {
				errors.add(new FIFError("FIF-API",
						"Cannot get message creator for request. Reason: "
								+ fe.getMessage()));
			}
		} else {
			errors.add(new FIFError("FIF-API",
					"No action mapping found for action name: " + action));
		}

		if (errors.size() != 0) {
			// Handle errors
			QueueClientResponseMessage response = new QueueClientResponseMessage(
					QueueClientResponseMessage.FAILURE, request.getAction(),
					request.getTransactionID(), errors);
			return response;
		}

		// Create the message
		Message FIFMsg = null;
		try {
			FIFMsg = mc.createMessage(request);
			return FIFMsg;
		} catch (FIFException fe) {
			// The creation of the message failed.
			// Populate the error string with an error message.
			errors.add(new FIFError("FIF-API",
					"Cannot create FIF message for request.  Reason : "
							+ fe.getMessage()));
			QueueClientResponseMessage response = new QueueClientResponseMessage(
					QueueClientResponseMessage.FAILURE, request.getAction(),
					request.getTransactionID(), errors);
			return response;
		}
	}

	/**
	 * Creates a message for a given request list.
	 * @param requestList  the request list to create the message for.
	 * @param msgText      the original message text.
	 * @return the message related to the request, or a 
	 * <code>QueueClientResponseListMessage</code> if the message creation 
	 * failed.
	 */
	private Message createMessage(FIFRequestList requestList, String msgText)
			throws FIFException {
		// Check if we got a valid request list
		ArrayList errors = new ArrayList();
		if (!validateRequestList(requestList, msgText, errors)) {
			// Handle Errors
			QueueClientResponseListMessage responseList = new QueueClientResponseListMessage(
					QueueClientResponseListMessage.FAILURE, requestList
							.getName(), requestList.getID(), errors);
			return responseList;
		}

		// Create the request messages
		List requestMsgList = new LinkedList();
		List responseMsgList = new LinkedList();
		boolean errorsInRequests = false;
		Iterator requestIter = requestList.getRequests().iterator();
		while (requestIter.hasNext()) {
			FIFRequest request = (FIFRequest) requestIter.next();
			Message requestMsg = createMessage(request, null);
			if (requestMsg instanceof QueueClientResponseMessage) {
				logger.debug("Adding response message to lists: " + requestMsg);
				errorsInRequests = true;
				responseMsgList.add(requestMsg);
			} else {
				logger.debug("Adding request message to lists: " + requestMsg);
				requestMsgList.add(requestMsg);
				responseMsgList
						.add(new QueueClientResponseMessage(
								QueueClientResponseMessage.VALIDATED, request
										.getAction(), request
										.getTransactionID(), null));
			}
		}

		if (!errorsInRequests) {
			//  Create a fif transaction list document
			return (RequestSerializer.createFIFTransactionList(requestList.getID(), requestList
					.getName(), requestList.getOMTSOrderID(),requestList.getManualRollback(), requestList.getHeaderList(),requestMsgList));
		} else {
			// We had a failed request.  Create a response message document.
			return (createFailedResponseListMessage(requestList.getID(),
					requestList.getName(), msgText, responseMsgList));
		}
	}

	/**
	 * Creates a response message for a failed request list creation.
	 * @param requestListID    the ID of the request list related to the 
	 *                         failure.
	 * @param requestListName  the name of the request list related to the 
	 *                         failure.
	 * @param msgText          the original request message
	 * @param responseMsgList  the list containing the response messages for 
	 *                         the individual requests.
	 * @return the failed response message.
	 */
	private Message createFailedResponseListMessage(String requestListID,
			String requestListName, String msgText, List responseMsgList)
			throws FIFException {
		ArrayList errors = new ArrayList();
		errors.add(new FIFError("FIF-API",
				"Cannot create FIF Message for request list. "
						+ "Errors in embedded requests."));
		errors
				.add(new FIFError("FIF-API", "Original request list:\n"
						+ removeCDATAFromRequest(msgText)));

		QueueClientResponseListMessage responseList = new QueueClientResponseListMessage(
				QueueClientResponseListMessage.FAILURE, requestListName,
				requestListID, errors);
		Iterator msgIter = responseMsgList.iterator();
		while (msgIter.hasNext()) {
			QueueClientResponseMessage response = (QueueClientResponseMessage) msgIter
					.next();
			responseList.addResponse(response);
		}

		return responseList;
	}

	/**
	 * Validates a simple request.
	 * @param request  the request to validate.
	 * @param msgText  the original contents of the message that contained 
	 *                 the request.
	 * @param errors   the <code>ArrayList</code> to add error messages to.
	 * @return true if the validation passed, 
	 * false if not (errors are in the <code>error</code> object.
	 */
	private boolean validateSimpleRequest(FIFRequest request, String msgText,
			ArrayList errors) {
		// Add the error if it is an invalid request
		if (request instanceof InvalidRequest) {
			errors.add(((InvalidRequest) request).getError());
		}

		// Add the action error, if needed
		if (request.getAction() == null) {
			errors.add(new FIFError("FIF-API", "No action name provided."));
		}

		// Add the transaction error, if needed
		if (request.getTransactionID() == null) {
			errors.add(new FIFError("FIF-API",
					"No transactionID parameter provided."));
		}

		// Add the original received request, if errors occured
		if ((errors.size() != 0) && (msgText != null)) {
			errors
					.add(new FIFError("FIF-API", "Original request:\n"
							+ removeCDATAFromRequest(msgText)));
		}

		if (errors.size() == 0) {
			return true;
		} else {
			return false;
		}
	}
	
	/**
	 * Removes all CDATA sections from a request message.
	 * This is needed to return a readable and parsable original request
	 * message to the client when the request is invalid.
	 * @param request  the request to remove CDATA sections from.
	 * @return the request without CDATA sections.
	 */
	private String removeCDATAFromRequest(String request) {
		Pattern p = Pattern.compile("[\\x00-\\x08\\x0E-\\x1F\\x7F]");
        Matcher m = p.matcher("");
        m.reset(request);
        request = m.replaceAll("");		
        return (request.replaceAll("<!\\[CDATA\\[", "").replaceAll("\\]\\]>", ""));
	}

	/**
	 * Validates a request list.
	 * @param requestList  the request list to validate.
	 * @param msgText      the original contents of the message that contained 
	 *                     the request list.
	 * @param errors       the <code>ArrayList</code> to add error messages to.
	 * @return true if the validation passed, 
	 * false if not (errors are in the <code>error</code> object.
	 */
	private boolean validateRequestList(FIFRequestList requestList,
			String msgText, ArrayList errors) {
		// Add the errors if it is an invalid request
		if (requestList instanceof InvalidRequestList) {
			errors.add(((InvalidRequestList) requestList).getError());
			Iterator errorIter = requestList.getRequests().iterator();
			while (errorIter.hasNext()) {
				Request request = (Request) errorIter.next();
				if (request instanceof InvalidRequest) {
					InvalidRequest invalid = (InvalidRequest) request;
					errors.add(new FIFError("FIF-API", invalid.getAction()
							+ ": " + invalid.getError()));
				}
			}
		}

		// Add the name error, if needed
		if (requestList.getName() == null) {
			errors.add(new FIFError("FIF-API",
					"No name provided for the request list."));
		}

		// Add the ID error, if needed
		if (requestList.getID() == null) {
			errors.add(new FIFError("FIF-API",
					"No ID parameter provided for the request list."));
		}

		// Add the ID error, if needed
		if (requestList.getOMTSOrderID() == null) {
			logger.debug("No OMTSOrderID parameter provided for the request list.");
		}

		// Add the ID error, if needed
		if (requestList.getHeaderList() == null) {
			logger.debug("No HeaderList provided for the request list.");
		}
		
		// Add the original received request, if errors occured
		if (errors.size() != 0) {
			errors.add(new FIFError("FIF-API", "Original request list:\n"
					+ removeCDATAFromRequest(msgText)));
		}

		if (errors.size() == 0) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Writes a sent message to the sent message directory.
	 * The messages is only written to the directory if the
	 * <code>queueclient.WriteSentMessages</code> setting
	 * is set to <code>true</code>
	 * @param msg     the message to be sent
	 * @param id      the transaction id of the message
	 * @param action  the action the message is related to
	 * @throws FIFException if the message could not be written.
	 */
	private void writeSentMessage(Message msg, String id, String action)
			throws FIFException {
		// Bail out if the message should not be written to a output file
		if (!QueueClientConfig.getBoolean("queueclient.WriteSentMessages")) {
			return;
		}

		String fileName = FileUtils.writeToOutputFile(msg.getMessage(),
				QueueClientConfig.getPath("queueclient.SentOutputDir"), "sent-"
						+ action + "-" + id, ".xml", false);

		logger.debug("Wrote sent message to: " + fileName);
	}

	/**
	 * Writes a sent list message to the sent message directory.
	 * The messages is only written to the directory if the
	 * <code>queueclient.WriteSentMessages</code> setting
	 * is set to <code>true</code>
	 * @param msg     the message to be sent
	 * @param id      the id of the message
	 * @param name    the list name the message is related to
	 * @throws FIFException if the message could not be written.
	 */
	private void writeSentListMessage(Message msg, String id, String name)
			throws FIFException {
		// Bail out if the message should not be written to a output file
		if (!QueueClientConfig.getBoolean("queueclient.WriteSentMessages")) {
			return;
		}

		String fileName = FileUtils.writeToOutputFile(msg.getMessage(),
				QueueClientConfig.getPath("queueclient.SentOutputDir"),
				"sent-list-" + name + "-" + id, ".xml", false);

		logger.debug("Wrote sent list message to: " + fileName);
	}

	/**
	 * Writes the request message to the request message directory.
	 * The message is only written to the directory if the
	 * <code>queueclient.WriteRequestMessages</code> setting
	 * is set to <code>true</code>
	 * @param msg     the message to be sent
	 * @param id      the transaction id of the message
	 * @param action  the action the message is related to
	 * @throws FIFException if the request could not be written.
	 */
	private void writeRequestMessage(String msg, String id, String action)
			throws FIFException {
		// Bail out if the message should not be written to a output file
		if (!QueueClientConfig.getBoolean("queueclient.WriteRequestMessages")) {
			return;
		}

		String fileName = FileUtils.writeToOutputFile(msg, QueueClientConfig
				.getPath("queueclient.RequestOutputDir"), "request-" + action
				+ "-" + id, ".xml", false);

		logger.debug("Wrote request message to: " + fileName);
	}

	/**
	 * Writes the request list message to the request message directory.
	 * The message is only written to the directory if the
	 * <code>queueclient.WriteRequestMessages</code> setting
	 * is set to <code>true</code>
	 * @param msg     the message to be sent
	 * @param id      the id of the message list
	 * @param name    the name the message list is related to
	 * @throws FIFException if the request could not be written.
	 */
	private void writeRequestListMessage(String msg, String id, String name)
			throws FIFException {
		// Bail out if the message should not be written to a output file
		if (!QueueClientConfig.getBoolean("queueclient.WriteRequestMessages")) {
			return;
		}

		String fileName = FileUtils.writeToOutputFile(msg, QueueClientConfig
				.getPath("queueclient.RequestOutputDir"), "request-list-"
				+ name + "-" + id, ".xml", false);

		logger.debug("Wrote request-list message to: " + fileName);
	}

	/**
	 * Writes a sent KBA response message to an output file.
	 * The message is only written to the directory if the
	 * <code>queueclient.WriteResponseMessages</code> setting
	 * is set to <code>true</code> in the configuration file. 
	 * @param response  the message to be written.
	 * @throws FIFException if the response message could not be written.
	 */
	private void writeResponseMessage(QueueClientResponseMessage response)
			throws FIFException {
		// Bail out if the message should not be written to a output file
		if (!QueueClientConfig.getBoolean("queueclient.WriteResponseMessages")) {
			return;
		}

		String fileName = FileUtils.writeToOutputFile(response.getMessage(),
				QueueClientConfig.getPath("queueclient.ResponseOutputDir"),
				"response-" + response.getActionName() + "-"
						+ response.getTransactionID(), ".xml", false);

		logger.debug("Wrote response message to: " + fileName);
	}

	/**
	 * Writes a sent KBA response list message to an output file.
	 * The message is only written to the directory if the
	 * <code>queueclient.WriteResponseMessages</code> setting
	 * is set to <code>true</code> in the configuration file. 
	 * @param response  the message to be written.
	 * @throws FIFException if the response message could not be written.
	 */
	private void writeResponseListMessage(
			QueueClientResponseListMessage responseList) throws FIFException {
		// Bail out if the message should not be written to a output file
		if (!QueueClientConfig.getBoolean("queueclient.WriteResponseMessages")) {
			return;
		}

		String fileName = FileUtils.writeToOutputFile(
				responseList.getMessage(), QueueClientConfig
						.getPath("queueclient.ResponseOutputDir"),
				"response-list-" + responseList.getName() + "-"
						+ responseList.getID(), ".xml", false);

		logger.debug("Wrote response list message to: " + fileName);
	}

	/**
	 * Shuts down the object.
	 */
	protected synchronized void shutdown() {
		logger.info("Shutting down queue message sender...");
		boolean success = true;

		try {
			if (clientRequestReceiver != null) {
				clientRequestReceiver.shutdown();
				clientRequestReceiver = null;
			}
		} catch (FIFException e1) {
			logger.error("Cannot shutdown client request receiver.");
			success = false;
		}

		try {
			if (clientResponseSender != null) {
				clientResponseSender.shutdown();
				clientResponseSender = null;
			}
		} catch (FIFException e1) {
			logger.error("Cannot shutdown client reply sender.");
			success = false;
		}

		try {
			if (FIFMessageSender != null) {
				FIFMessageSender.shutdown();
				FIFMessageSender = null;
			}
		} catch (FIFException e1) {
			logger.error("Cannot shutdown FIF message sender.");
			success = false;
		}

		if (success) {
			logger.info("Successfully shut down queue message sender.");
		} else {
			logger.error("Errors while shutting down queue message sender.");
		}
	}
}