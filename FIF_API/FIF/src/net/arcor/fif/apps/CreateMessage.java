/*
 $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/apps/CreateMessage.java-arc   1.7   Feb 16 2005 12:00:36   goethalo  $

 $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/apps/CreateMessage.java-arc  $
 * 
 *    Rev 1.7   Feb 16 2005 12:00:36   goethalo
 * Added support for request lists.
 * 
 *    Rev 1.6   Mar 02 2004 11:18:34   goethalo
 * SPN-CCB-000020494: Changed way property files are read.  Now the fully qualified property file name must be provided.
 * 
 *    Rev 1.5   Feb 13 2004 10:40:30   goethalo
 * Fixed some stuff.
 * 
 *    Rev 1.4   Feb 12 2004 17:00:10   goethalo
 * Removed loop and added error code at exit.
 * 
 *    Rev 1.3   Oct 07 2003 14:50:24   goethalo
 * Changes for IT-9811 - Internet By Call with Registration
 * 
 *    Rev 1.2   Jul 25 2003 09:07:34   goethalo
 * IT-9750
 * 
 *    Rev 1.1   Jul 16 2003 14:53:18   goethalo
 * Changes for IT-9750.
 * 
 *    Rev 1.0   Apr 09 2003 09:34:26   goethalo
 * Initial revision.
 */
package net.arcor.fif.apps;

import java.io.IOException;
import java.io.StringWriter;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import org.apache.log4j.Logger;
import org.apache.xerces.dom.DOMImplementationImpl;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.Text;

import net.arcor.fif.common.DOMSerializer;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.common.Log4jConfig;
import net.arcor.fif.messagecreator.FIFMessage;
import net.arcor.fif.messagecreator.FIFRequest;
import net.arcor.fif.messagecreator.FIFRequestList;
import net.arcor.fif.messagecreator.Message;
import net.arcor.fif.messagecreator.MessageCreator;
import net.arcor.fif.messagecreator.MessageCreatorConfig;
import net.arcor.fif.messagecreator.MessageCreatorFactory;
import net.arcor.fif.messagecreator.MessageSender;
import net.arcor.fif.messagecreator.Request;
import net.arcor.fif.messagecreator.RequestSerializer;
import net.arcor.fif.messagecreator.SimpleParameter;
import net.arcor.fif.messagecreator.XMLTags;
import net.arcor.fif.transport.TransportManager;

/**
 * This application creates a Request based on an XML request. It is
 * particularly useful to test the MessageCreator framework and for being called
 * by scripts or external applications.
 * <p>
 * This application also allows to send the create message to the queue.
 * <p>
 * <b>Usage: </b> <br>
 * <code>java net.arcor.fif.apps.CreateMessage <i>filename.xml</i> <i>[-send]</i></code>
 * <p>
 * <b>Options: </b> <br>
 * <code>-send</code> &nbsp;&nbsp;&nbsp;&nbsp;also sends the message to the
 * queue.
 * <p>
 * <b>Format of XML file: </b> <br>
 * The XML request file should be in following format: <br>
 * <code>
 * <pre>
 * 
 *  
 *   &lt;?xml version=&quot;1.0&quot;?&gt;
 *   &lt;request&gt;
 *       &lt;action-name&gt;actionName&lt;/action-name&gt;
 *       &lt;request-params&gt;
 *           &lt;request-param name=&quot;parameter1&quot;&gt;paramValue1&lt;/request-param&gt;
 *           &lt;request-param name=&quot;parameter2&quot;&gt;paramValue2&lt;/request-param&gt;
 *           &lt;request-param name=&quot;parameter3&quot;&gt;paramValue3&lt;/request-param&gt;
 *           ...
 *       &lt;/request-params&gt;
 *   &lt;/request&gt;
 *   
 *  
 * </pre>
 * </code>
 * <p>
 * <b>Property file </b> <br>
 * The property file is defaulted to CreateMessage. <br>
 * The <code>fif.propertyfile</code> system property can be set to another
 * property file if needed. <br>
 * To do this the following syntax can be used for starting the application:
 * <br>
 * <code>java -Dfif.propertyfile=AnotherFile net.arcor.fif.apps.CreateMessage
 * <i>filename.xml</i> <i>[-send]</i></code>
 * 
 * @author goethalo
 */
public final class CreateMessage {

	/*------------------*
	 * MEMBER VARIABLES *
	 *------------------*/

	/**
	 * The log4j logger.
	 */
	private static Logger logger = Logger.getLogger(CreateMessage.class);

	/**
	 * Indicates whether the created message should also be sent to the queue.
	 */
	private static boolean send = false;

	/*---------*
	 * METHODS *
	 *---------*/

	/**
	 * Initializes the application.
	 * 
	 * @throws FIFException
	 */
	private static void init(String configFile) throws FIFException {
		// Initialize the logger
		Log4jConfig.init(configFile);

		logger.info("Initializing application with property file " + configFile
				+ "...");

		// Initialize the message creator
		MessageCreatorConfig.init(configFile);

		if (send) {
			// Initialize the transport manager if the message should be sent
			TransportManager.init(configFile);
		}

		logger.info("Successfully initialized application.");
	}

	/**
	 * Shuts down the application.
	 * 
	 * @throws FIFException
	 */
	private static void shutdown() {
		boolean success = true;
		logger.info("Shutting down application...");
		try {
			// Shut down message creator
			MessageCreatorConfig.shutdown();
		} catch (Exception e) {
			success = false;
			logger.error("Cannot shutdown message creator", e);
		}
		try {
			if (send) {
				// Shut down the transport manager if needed
				TransportManager.shutdown();
			}
		} catch (Exception e) {
			success = false;
			logger.error("Cannot shutdown transport manager", e);
		}

		if (success) {
			logger.info("Successfully shut down application.");
		} else {
			logger.error("Errors while shutting down application.");
		}
	}

	/**
	 * Creates a message based on an XML request.
	 */
	public static void main(String[] args) {
		if (args.length < 1) {
			System.err
					.println("CreateMessage: creates a FIF Message based on a XML request.");
			System.err.println("\nUsage: CreateMessage filename.xml [-send]");
			System.err.println("\nOptions:");
			System.err
					.println("    -send   also sends the message to the queue.");
			System.exit(1);
		}

		String fileName = args[0];
		if (args.length >= 2) {
			if (args[1].trim().equalsIgnoreCase("-send")) {
				send = true;
			}
		}

		// Set the config file name
		String configFile = "CreateMessage.properties";
		if (System.getProperty("fif.propertyfile") != null) {
			configFile = System.getProperty("fif.propertyfile");
		}

		boolean error = false;

		try {
			// Initialize the application
			init(configFile);

			// Create the request
			Request request = RequestSerializer.serializeFromFile(fileName,
					false);

			// Get the message text

			// Process the request
			Message msg = null;
			if (request instanceof FIFRequest) {
				msg = createSimpleRequest((FIFRequest) request);
				// Write the message to the output directory
				FileUtils.writeToOutputFile(msg.getMessage(), "output/",
						request.getAction()
								+ "-"
								+ ((SimpleParameter) request
										.getParam("transactionID")).getValue(),
						".xml", false);
				logger.info(((SimpleParameter) request
						.getParam("transactionID")));
			} else if (request instanceof FIFRequestList) {
				msg = createRequestList((FIFRequestList) request);
				// Write the message to the output directory
				FileUtils.writeToOutputFile(msg.getMessage(), "output/",
						"request-list-" + ((FIFRequestList) request).getName()
								+ "-" + ((FIFRequestList) request).getID(),
						".xml", false);

			} else {
				throw new FIFException("Request is of unknown type. Type: "
						+ request.getClass().getName());
			}

			// Send the message, if needed
			if (send) {
				MessageSender sender = new MessageSender("outqueue");
				sender.start();
				sender.sendMessage(msg);
				sender.shutdown();
				logger.info("Sent message to queue.");
			}
		} catch (FIFException e) {
			logger.fatal("Cannot send message.", e);
			e.printStackTrace();
			error = true;
		} finally {
			shutdown();
		}
		if (error == true) {
			System.exit(1);
		} else {
			System.exit(0);
		}
	}

	/**
	 * Creates a FIF request based on a simple request.
	 * 
	 * @param request
	 *            the serialized FIF request object.
	 * @return the message representing the FIF request.
	 * @throws FIFException
	 *             if the request could not be processed.
	 */
	private static Message createSimpleRequest(FIFRequest request)
			throws FIFException {
		// Get a message creator for the request
		MessageCreator mc = MessageCreatorFactory.getMessageCreator(request
				.getAction());

		// Create the message
		Message msg = mc.createMessage(request);

		return msg;
	}

	/**
	 * Creates a FIF request based on a request list.
	 * 
	 * @param requestList
	 *            the serialized FIF request list object.
	 * @return the message representing the FIF request.
	 * @throws FIFException
	 *             if the request could not be processed.
	 */
	private static Message createRequestList(FIFRequestList requestList)
			throws FIFException {
		logger.info("Creating XML message for request list...");
		List requestMsgList = new LinkedList();
		boolean errorsInRequests = false;
		Iterator requestIter = requestList.getRequests().iterator();
		while (requestIter.hasNext()) {
			FIFRequest request = (FIFRequest) requestIter.next();
			Message requestMsg = createSimpleRequest(request);
			requestMsgList.add(requestMsg);
		}

		DOMImplementation domImpl = new DOMImplementationImpl();
		Document FIFMsgDoc = domImpl.createDocument(null,
				XMLTags.transactionListRoot, domImpl.createDocumentType(
						XMLTags.transactionListRoot, null,
						XMLTags.transactionListDTD));
		Element transactionListRoot = FIFMsgDoc.getDocumentElement();
		addElement(FIFMsgDoc, transactionListRoot, XMLTags.transactionListID,
				requestList.getID());
		addElement(FIFMsgDoc, transactionListRoot, XMLTags.transactionListName,
				requestList.getName());

		// Add the individual transactions
		Element transactionsRoot = FIFMsgDoc
				.createElement(XMLTags.transactionList);
		transactionListRoot.appendChild(transactionsRoot);
		Iterator requestMsgIter = requestMsgList.iterator();
		while (requestMsgIter.hasNext()) {
			Message requestMsg = (Message) requestMsgIter.next();
			Document requestMsgDoc = requestMsg.getDocument();
			Node requestMsgRoot = requestMsgDoc.getDocumentElement();

			// Import the response root in the response list document
			Node importedRequest = FIFMsgDoc.importNode(requestMsgRoot, true);
			transactionsRoot.appendChild(importedRequest);
		}

		// Serialize the message document
		Message msg = null;
		try {
			DOMSerializer serializer = new DOMSerializer();
			StringWriter sw = new StringWriter();
			serializer.serialize(FIFMsgDoc, sw, false);
			msg = new FIFMessage(sw.toString());
		} catch (IOException ioe) {
			throw new FIFException(
					"Cannot serialize generated transaction list.", ioe);
		}

		logger.info("Created XML message for request list.");

		return msg;
	}

	/**
	 * Adds an element to the document.
	 * 
	 * @param doc
	 *            the document to add the element to.
	 * @param parent
	 *            the parent to add the element to.
	 * @param name
	 *            the name of the element to add.
	 * @param value
	 *            the text value of the element to add. use null if no text
	 *            value should be added.
	 * @return the newly added Element
	 */
	private static Element addElement(Document doc, Element parent,
			String name, String value) {
		// Create a new element
		Element element = doc.createElement(name);

		if (value != null) {
			// Create the text
			Text text = doc.createCDATASection(value);

			// Add the text
			element.appendChild(text);
		}

		// Append the element to the parent
		parent.appendChild(element);

		// Return the created element
		return element;
	}

}