/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/ConsolidateSubscriptionDataHandler.java-arc   1.4   Feb 25 2019 13:43:32   makuier  $
 *    $Revision:   1.4  $
 *    $Workfile:   ConsolidateSubscriptionDataHandler.java  $
 *      $Author:   makuier  $
 *        $Date:   Feb 25 2019 13:43:32  $
 *
 *  Function: service handler for synchronous processing in FIF
 *  
 *  Copyright (C) Arcor
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/servicehandler/ConsolidateSubscriptionDataHandler.java-arc  $
 * 
 *    Rev 1.4   Feb 25 2019 13:43:32   makuier
 * Do not retry in case of :
 * - Open order validation skipped
 * - Open order validation failure (BKS0051)
 * 
 *    Rev 1.3   Jun 07 2017 14:24:56   naveen.k
 * PPM 197512 RMS 161608,Project TKG 
 * 
 *    Rev 1.2   Mar 27 2013 12:31:10   schwarje
 * SPN-FIF-000124073: add contact in case of reported problems in automatic data reconciliation
 * 
 *    Rev 1.1   Jan 29 2013 11:12:16   schwarje
 * IT-32438: added ZAR request
 * 
 *    Rev 1.0   Jan 18 2013 07:47:58   schwarje
 * Initial revision.
 * 
 ***************************************************************************  
 */
package net.arcor.fif.servicehandler;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.bind.JAXBElement;

import net.arcor.ccm.epsm_ccm_consolidatesubscriptiondata_001.ActionItem;
import net.arcor.ccm.epsm_ccm_consolidatesubscriptiondata_001.ConsolidateSubscriptionDataOutput;
import net.arcor.ccm.epsm_ccm_consolidatesubscriptiondata_001.ConsolidateSubscriptionDataService;
import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.client.ServiceBusInterfaceException;
import net.arcor.fif.client.ServiceBusRequest;
import net.arcor.fif.client.ServiceBusRequestLogger;
import net.arcor.fif.common.DateUtils;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.db.CCMDataAccess;
import net.arcor.fif.db.DataReconReport;
import net.arcor.fif.db.DataReconReportDataAccess;
import net.arcor.fif.db.DatabaseFifRequest;
import net.arcor.fif.db.DatabaseFifRequestDataAccess;
import net.arcor.fif.db.ZARClearingRequest;
import net.arcor.fif.db.ZARClearingRequestDataAccess;
import net.arcor.mcf2.exception.base.MCFException;
import net.arcor.mcf2.model.ServiceObjectEndpoint;
import net.arcor.mcf2.model.ServiceResponse;



/**
 * The SynchronousFifServiceHandler handles service bus requests for
 * FIF synchronously, i.e. it waits for FifInterface to process the message 
 * and returns the result of the request to the service bus
 * @author schwarje
 *
 */
public class ConsolidateSubscriptionDataHandler extends SynchronousFifHandler {

	private static final String CCM_DATA_TYPE_TECH_SERVICE_ID = "TECH_SERVICE_ID";

	private static final String CCM_DATA_TYPE_USER_ACCOUNT_NUM = "USER_ACCOUNT_NUM";

	private static final String CCM_DATA_TYPE_MOBIL_ACCESS_NUM = "MOBIL_ACCESS_NUM";

	private static final String CCM_DATA_TYPE_ACC_NUM_RANGE = "ACC_NUM_RANGE";

	private static final String CCM_DATA_TYPE_MAIN_ACCESS_NUM = "MAIN_ACCESS_NUM";

	private static final String ZAR_SCENARIO_UPDATE_ACCESS_NUMBER_GROUP = "4";

	private static final String ZAR_SCENARIO_ADD_ACCESS_NUMBER = "3";

	private static final String ZAR_SCENARIO_REMOVE_ACCESS_NUMBER = "2";

	private static final String ZAR_SCENARIO_RESET_CUSTOMER_NUMBER = "1";

	private static final String ERROR_CODE_ZAR_ADD_ACCESS_NUMBER = "E0011";

	private static final String ERROR_CODE_ZAR_REMOVE_ACCESS_NUMBER = "E0012";

	private static final String ERROR_CODE_ZAR_WRONG_CUSTOMER_NUMBER = "E0013";

	private static final String ERROR_CODE_ZAR_WRONG_GROUP = "E0038";

	private static final String EXTERNAL_SYSTEM_CCM = "CCM";

	private static final String EXTERNAL_SYSTEM_ZAR = "ZAR";

	private static final String EXTERNAL_SYSTEM_AIDA = "AIDA";

	private static final String EXTERNAL_SYSTEM_CRAMER = "Cramer";
	
	private static final String EXTERNAL_SYSTEM_INFPORT = "InfPort";

	private static final String ACTION_TYPE_CHANGE = "Change";

	private static final String ACTION_TYPE_IGNORE = "Ignore";

	// private static final String ACTION_TYPE_REPORT = "Report";

	private static final String FIF_STATUS_NOT_STARTED = "NOT_STARTED";

	private static final int FIF_PRIORITY_LOW = 5;

	/**
	 * maximum number of retries of BKS call
	 */
	private static int maxRetries = 3;

	/**
	 * number of minutes after which BKS is called again
	 */
	private static int retryDelay = 1440;

	/**
	 * number of minutes after which BKS is called again
	 */
	private static boolean writeFifRequests = true;
	
	
	
	/**
	 * for logging service bus requests to the database
	 */
	private static ServiceBusRequestLogger requestLogger = null;

	private static DataReconReportDataAccess dataReconReportDataAccess = null; 

	private static DatabaseFifRequestDataAccess ccmFifRequestDataAccess = null; 

	private static CCMDataAccess ccmDataAccess = null; 

	private static ZARClearingRequestDataAccess zarClearingRequestDataAccess = null;
		
	public ConsolidateSubscriptionDataHandler() throws MCFException {
		super();		
		init();
	}
	
	/**
	 * 
	 */
	private synchronized void init() {		
		try {
			maxRetries = ClientConfig.getInt("DataReconciliationClient.MaxRetries");
		} catch (FIFException e) {}
		try {
			retryDelay = ClientConfig.getInt("DataReconciliationClient.RetryDelay");
		} catch (FIFException e) {}
		try {
			writeFifRequests = ClientConfig.getBoolean("DataReconciliationClient.WriteFifRequests");
		} catch (FIFException e) {}
		String dbAliasZAR = "ccmdb";
		try {
			dbAliasZAR = ClientConfig.getSetting("DataReconciliationClient.ZARClearingRequest.DBAlias");
		} catch (FIFException e) {}
		
		try {
			if (dataReconReportDataAccess == null)
				dataReconReportDataAccess = new DataReconReportDataAccess("ccmdb");
			if (ccmFifRequestDataAccess == null)
				ccmFifRequestDataAccess = new DatabaseFifRequestDataAccess("ccmdb");
			if (requestLogger == null)
				requestLogger = new ServiceBusRequestLogger(false);
			if (ccmDataAccess == null)
				ccmDataAccess = new CCMDataAccess(dataReconReportDataAccess.getConn());
			if (zarClearingRequestDataAccess == null)
				zarClearingRequestDataAccess = new ZARClearingRequestDataAccess(dbAliasZAR);			
		} catch (Exception e) {
			logger.fatal(e.getMessage(), e);
			throw new MCFException(e.getClass().getSimpleName() + " raised with message: " + e.getMessage());
		}		
	}
	
	public ServiceResponse<?> execute(final ServiceObjectEndpoint<?> serviceInput)
		throws MCFException {
		
		@SuppressWarnings("unchecked")
		ConsolidateSubscriptionDataService service = ((JAXBElement<ConsolidateSubscriptionDataService>)(serviceInput.getPayload())).getValue();		
		ConsolidateSubscriptionDataOutput output = service.getConsolidateSubscriptionDataOutput();					
		
		try {
			execute(serviceInput.getCorrelationID(), output);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			throw new MCFException();
		}
		
		
		return null;
	}
	
	private void execute(String requestID, ConsolidateSubscriptionDataOutput output) throws SQLException, FIFException{

		String initiatingFifTransactionId = null;
		DataReconReport dataReconReport = new DataReconReport();
		
		// populating internal dataReconReport
		dataReconReport.setReportID(dataReconReportDataAccess.generateReportID());
		dataReconReport.setReportTime(new Date());
		dataReconReport.setBksResult(output.isResult());
		dataReconReport.setBksErrorCode(output.getErrorCode());
		dataReconReport.setBksErrorText(output.getErrorText());
		dataReconReport.setValidatedCCM(true);
		if (output.isAidaValidated() != null)
			dataReconReport.setValidatedAIDA(output.isAidaValidated());
		if (output.isZarValidated() != null)
			dataReconReport.setValidatedZAR(output.isZarValidated());
		if (output.isCramerValidated() != null)
			dataReconReport.setValidatedCramer(output.isCramerValidated());
		if (output.isInfPortValidated() != null)
			dataReconReport.setValidatedInfPort(output.isInfPortValidated());
		if (output.getActionList() != null)
			dataReconReport.setActionItems(output.getActionList().getActionItem());
		dataReconReport.setProcessedCCM(!hasTasks(dataReconReport, EXTERNAL_SYSTEM_CCM));
		dataReconReport.setProcessedAIDA(!hasTasks(dataReconReport, EXTERNAL_SYSTEM_AIDA));
		dataReconReport.setProcessedZAR(!hasTasks(dataReconReport, EXTERNAL_SYSTEM_ZAR));
		dataReconReport.setProcessedCramer(!hasTasks(dataReconReport, EXTERNAL_SYSTEM_CRAMER));
		dataReconReport.setProcessedInfPort(!hasTasks(dataReconReport, EXTERNAL_SYSTEM_INFPORT));
		dataReconReport.setProcessedSLS(false); // TODO, if only ignore, set true
		dataReconReport.setSbusCorrelationID(requestID);		

		// try to find the original request on SERVICE_BUS_REQUEST
		ServiceBusRequest originalBusRequest = 
			requestLogger.retrieveRequest(
					requestID, 
					ServiceBusRequest.requestTypeService);

		// saving result of ServiceBusRequest, if one was found
		if (originalBusRequest != null) {
			if (output.isResult())
				originalBusRequest.setStatus(ServiceBusRequest.requestStatusRespondedPositive);
			else {
				originalBusRequest.setStatus(ServiceBusRequest.requestStatusRespondedNegative);
				originalBusRequest.setThrowable(
						new ServiceBusInterfaceException(
								output.getErrorCode(),
								output.getErrorText()));
			}
			originalBusRequest.setEndDate(new Date());
			requestLogger.updateRequest(originalBusRequest);
						
			requestLogger.retrieveRequestParams(originalBusRequest);
			// read data from original request on SERVICE_BUS_REQUEST
			String externalSystemId = originalBusRequest.getExternalSystemId();
			String orderID = originalBusRequest.getParameters().get("OrderId");
			int orderPositionNumber = Integer.parseInt(originalBusRequest.getParameters().get("OrderPositionNumber"));
			String bundleID = originalBusRequest.getParameters().get("BundleId");
			String customerNumber = externalSystemId.substring(0, externalSystemId.indexOf(";"));
			initiatingFifTransactionId = externalSystemId.substring(externalSystemId.indexOf(";") + 1);

			dataReconReport.setCustomerNumber(customerNumber);
			dataReconReport.setOrderID(orderID);
			dataReconReport.setOrderPositionNumber(orderPositionNumber);
			dataReconReport.setBundleID(bundleID);
		}
		else {
			logger.error("Original entry in SERVICE_BUS_REQUEST " + requestID + " couldn't be found.");
		}

		// check result
		if (output.isResult() == false)
		{
			logger.error("BKS request " + requestID + 
					" returned with following message: " + output.getErrorCode() + 
					" " + output.getErrorText());
			if (!output.isOpenOrderValidationSkipped()){
				String errorCode = output.getErrorCode();
				if (!errorCode.equals("BKS0051") && !errorCode.equals("")) {
					if (errorCode.equals("BKS0026")) 
						// BKS0026: Couldn't find serviceSubscription for input
						retryDataReconciliation(dataReconReport, requestID, initiatingFifTransactionId, maxRetries);
					else if (errorCode.equals("BKS0027")) 
						// BKS0027: BKS couldn't access an external system, which it's supposed to access
						retryDataReconciliation(dataReconReport, requestID, initiatingFifTransactionId, 100);
					else 
						retryDataReconciliation(dataReconReport, requestID, initiatingFifTransactionId, 100);	
				}
			}
		}
		else {
			
			// write to ZAR, if available and config says so
			try {
				createZARRequest(requestID, dataReconReport);
			} catch (FIFException e) {
				logger.error("A problem occured while trying to create the ZAR clearing request. See exception:", e);
				try {
					zarClearingRequestDataAccess.rollback();
				} catch (FIFException e1) {
					logger.error("Error while rolling back ZAR requests. See exception:", e);
				}
			}
			
			// log error, if ZAR is not available and something's to be written
						
			// ignore, if nothing's to be written to ZAR
			
			// generate FIF requests
			createFifRequest(requestID, dataReconReport);
			
			// create contact in CCM
			createCcmContact(requestID, dataReconReport);
		}
				
		dataReconReportDataAccess.insertDataReconReport(dataReconReport);

		if (dataReconReport.isProcessedZAR())			
			zarClearingRequestDataAccess.commit();
		dataReconReportDataAccess.commit();
		ccmFifRequestDataAccess.commit();
		requestLogger.commit();
	}
	private void createCcmContact(String requestID, DataReconReport dataReconReport) throws FIFException {
		if (!writeFifRequests || 
				dataReconReport.getCustomerNumber() == null ||
				dataReconReport.getCustomerNumber().equals(""))
			return;
		
		boolean createContact = false;
		// scan for CCM work
		for (ActionItem item : dataReconReport.getActionItems()) 
			if (!item.getActionType().equals(ACTION_TYPE_IGNORE)) { 
				createContact = true;
				break;
			}
		
		if (createContact) {
			DatabaseFifRequest createContactRequest = new DatabaseFifRequest(); 
			createContactRequest.setTransactionId(dataReconReport.getReportID() + System.currentTimeMillis());
			createContactRequest.setActionName("addContact");
			createContactRequest.setExternalSystemId(requestID);
			createContactRequest.setPriority(FIF_PRIORITY_LOW);
			createContactRequest.setDueDate(new Date());
			createContactRequest.setStatus(FIF_STATUS_NOT_STARTED);
			Map<String, String> parameters = new HashMap<String, String>();
			parameters.put("CUSTOMER_NUMBER", dataReconReport.getCustomerNumber());	
			parameters.put("SHORT_DESCRIPTION", "Automatischer Datenabgleich");	
			parameters.put("LONG_DESCRIPTION_TEXT", "Probleme bei automatischem Datenabgleich entdeckt, " +
					"siehe DATA_RECON_REPORT_ID = " + dataReconReport.getReportID());	
			parameters.put("CONTACT_TYPE_RD", "CUSTOMER");
			createContactRequest.setParameters(parameters);					
			ccmFifRequestDataAccess.insertFifRequest(createContactRequest);
		}
	}

	/**
	 * @param requestID
	 * @param orderID
	 * @param orderPositionNumber
	 * @param bundleID
	 * @param fifTransactionId
	 * @param actualRetries 
	 * @throws FIFException
	 */
	private void retryDataReconciliation(DataReconReport dataReconReport, String requestID, String fifTransactionId, int maxRetries) throws FIFException {
		if (fifTransactionId == null) {
			logger.warn("Cannot automatically retrigger data reconciliation (Correlation-ID: " +
					requestID + ") because original FifRequest couldn't be found in the database.");
			return;
		}
			
		// retry (how often?)
		DatabaseFifRequest originalFifRequest = ccmFifRequestDataAccess.fetchFifRequestById(fifTransactionId);
		
		if (originalFifRequest == null) {
			logger.warn("Original FifRequest " + fifTransactionId +
					" couldn't be found. No retry is triggered.");
		}
		else {
			int actualRetries = 0;
			if (originalFifRequest.getParameters().containsKey("retries"))
				actualRetries = Integer.parseInt(originalFifRequest.getParameters().get("retries"));
			if (actualRetries < maxRetries) {		
				Date retryDate = new Date(System.currentTimeMillis() + 60000 * retryDelay);
				DatabaseFifRequest retryFifRequest = new DatabaseFifRequest();
				retryFifRequest.setTransactionId(dataReconReport.getReportID());
				retryFifRequest.setActionName(originalFifRequest.getActionName());
				retryFifRequest.setExternalSystemId(originalFifRequest.getExternalSystemId());
				retryFifRequest.setPriority(FIF_PRIORITY_LOW);
				retryFifRequest.setDueDate(retryDate);
				retryFifRequest.setStatus(FIF_STATUS_NOT_STARTED);
				retryFifRequest.setParameters(originalFifRequest.getParameters());
				retryFifRequest.getParameters().put("retries", new Integer(++actualRetries).toString());
				ccmFifRequestDataAccess.insertFifRequest(retryFifRequest);
				logger.info("Triggering another BKS call (try #" + ++actualRetries + 
						") for data reconciliation for" +
						" bundleID " + dataReconReport.getBundleID() + 
						", orderID " + dataReconReport.getOrderID() + 
						", orderPositionNumber " + dataReconReport.getOrderPositionNumber() +
						" on " + retryDate.toString());
			}
		}
	}
	
	private void createZARRequest(String requestID, DataReconReport dataReconReport) throws FIFException {
		
		if (!hasTasks(dataReconReport, EXTERNAL_SYSTEM_ZAR)) {
			logger.debug("Nothing to be cleaned up on ZAR side for request " + requestID);
			dataReconReport.setProcessedZAR(true);
		}
		else {
		
			int clearingCounter = 0;
			
			Map<String, String> productCodesForServiceSubscription = new HashMap<String, String>(); 
			Map<String, String> customerNumbersForServiceSubscription = new HashMap<String, String>(); 			
			
			// Clearing cases for ZAR?
			// 1) Wrong customerNumber for x numbers?
			// 2) Wrong accessNumber? Not done!
			// 3) "Gruppen-ID?" RN in ZAR richtig gruppieren.			
			List<ZARClearingRequest> zarClearingList = new ArrayList<ZARClearingRequest>();
			
			for (ActionItem item : dataReconReport.getActionItems()) {
				if (item.getActionType().equals(ACTION_TYPE_CHANGE) && item.getValidatingSystem().equals(EXTERNAL_SYSTEM_ZAR)) {
					clearingCounter++;
					
					if (!productCodesForServiceSubscription.containsKey(item.getServiceSubscriptionId())) {
						String productCode = ccmDataAccess.getProductCodeForServiceSubscription(item.getServiceSubscriptionId());
						if (productCode != null)
							productCodesForServiceSubscription.put(
									item.getServiceSubscriptionId(), 
									productCode);
						else
							throw new FIFException("No productCode could be found for serviceSubscription " + item.getServiceSubscriptionId());
					}
					if (!customerNumbersForServiceSubscription.containsKey(item.getServiceSubscriptionId())) {
						String customerNumber = ccmDataAccess.getCustomerNumberForServiceSubscription(item.getServiceSubscriptionId());
						if (customerNumber != null)
							customerNumbersForServiceSubscription.put(
									item.getServiceSubscriptionId(), 
									customerNumber);
						else
							throw new FIFException("No customerNumber could be found for serviceSubscription " + item.getServiceSubscriptionId());
					}
					
					String affectedAccessNumber = null;
					if (item.getRelatedObjectType() != null && (
							item.getRelatedObjectType().equals(CCM_DATA_TYPE_MAIN_ACCESS_NUM) || 
							item.getRelatedObjectType().equals(CCM_DATA_TYPE_ACC_NUM_RANGE)))
						affectedAccessNumber = item.getRelatedObjectId();
					else { 
						if (item.getZarValue() != null)
							affectedAccessNumber = item.getZarValue();
						else 
							affectedAccessNumber = item.getCcmValue();
					}
					if (affectedAccessNumber == null)
						throw new FIFException("No accessNumber could be found in actionItem returned from BKS.");
					
					String [] accessNumberParts = affectedAccessNumber.split(";");
					if (accessNumberParts.length != 3 && accessNumberParts.length != 5) 
						throw new FIFException("Access number " + affectedAccessNumber + 
								" in illegal format.");

					// TODO was passiert bei falschen RN, zB 49;211;379;;
					String localAreaCode = "0" + accessNumberParts[1];
					String beginNumber = accessNumberParts[2];
					String endNumber = accessNumberParts[2];
					if (accessNumberParts.length == 5) {
						beginNumber = beginNumber + accessNumberParts[3];
						endNumber = beginNumber + accessNumberParts[4];
					}					
					
					ZARClearingRequest zarClearingRequest = new ZARClearingRequest();
					zarClearingRequest.setClearingID(dataReconReport.getReportID() + "-" + clearingCounter);
					zarClearingRequest.setServiceSubscriptionID(item.getServiceSubscriptionId());
					zarClearingRequest.setCustomerNumberCCM(customerNumbersForServiceSubscription.get(item.getServiceSubscriptionId()));
					if (item.getDataType().equals("CUSTOMER_NUMBER"))
						zarClearingRequest.setCustomerNumberZAR(item.getZarValue());
					else 
						zarClearingRequest.setCustomerNumberZAR(zarClearingRequest.getCustomerNumberCCM());
					zarClearingRequest.setLocalAreaCode(localAreaCode);				
					zarClearingRequest.setBeginNumber(beginNumber);
					zarClearingRequest.setEndNumber(endNumber);
					String ccmScenario = "0";
					// wrong customerNumber in ZAR
					if (item.getErrorCode().equals(ERROR_CODE_ZAR_WRONG_CUSTOMER_NUMBER))
						ccmScenario = ZAR_SCENARIO_RESET_CUSTOMER_NUMBER;
					// remove accessNumber
					else if (item.getErrorCode().equals(ERROR_CODE_ZAR_REMOVE_ACCESS_NUMBER))
						ccmScenario = ZAR_SCENARIO_REMOVE_ACCESS_NUMBER;
					// add accessNumber
					else if (item.getErrorCode().equals(ERROR_CODE_ZAR_ADD_ACCESS_NUMBER))
						ccmScenario = ZAR_SCENARIO_ADD_ACCESS_NUMBER;
					// wrong grouping
					else if (item.getErrorCode().equals(ERROR_CODE_ZAR_WRONG_GROUP))
						ccmScenario = ZAR_SCENARIO_UPDATE_ACCESS_NUMBER_GROUP;
					
					zarClearingRequest.setCcmScenario(ccmScenario);
					zarClearingRequest.setProductCode(productCodesForServiceSubscription.get(item.getServiceSubscriptionId()));
					zarClearingList.add(zarClearingRequest);
				}
			}

			zarClearingRequestDataAccess.insertRequests(zarClearingList);
			
			dataReconReport.setProcessedZAR(true);
		}
	}
	
	private void createFifRequest(String requestID, DataReconReport dataReconReport) throws FIFException {
		if (!writeFifRequests)
			return;
		
		// scan for CCM work
		HashMap<String, ArrayList<ActionItem>> ccmClearings = new HashMap<String, ArrayList<ActionItem>>();
		for (ActionItem item : dataReconReport.getActionItems()) {
			if (item.getActionType().equals(ACTION_TYPE_CHANGE) && item.getValidatingSystem().equals(EXTERNAL_SYSTEM_CCM)) {
				if (item.getServiceSubscriptionId() == null)
					throw new FIFException("No serviceSubscriptionID provided for CCM clearing.");
				
				// group entries by service subscription
				if (ccmClearings.containsKey(item.getServiceSubscriptionId()))
					ccmClearings.get(item.getServiceSubscriptionId()).add(item);
				else {
					ArrayList<ActionItem> clearingsForServiceSubscription = new ArrayList<ActionItem>();
					clearingsForServiceSubscription.add(item);
					ccmClearings.put(item.getServiceSubscriptionId(), clearingsForServiceSubscription);
				}					
			}
		}
		
		if (ccmClearings.size() > 0) {
			// check for ext sys id and already created requests
			if (ccmFifRequestDataAccess.fifRequestsForExternalSystemIdExists(requestID))
				logger.info("FifRequests to reconfigure the services were already created for " +
						"BKS response " + requestID);
			else {
				logger.info("Creating FifRequests to reconfigure the services for " +
						"BKS response " + requestID);
				for (String key : ccmClearings.keySet()) {
					ArrayList<ActionItem> itemList = ccmClearings.get(key);
					
					// create ccm-fif-request with:
					// - generated ID
					// - external_system_id := BKS-CorrelationID		
					// - action := reconfigureServiceCharacteristic		
					// - due_date := sysdate
					DatabaseFifRequest reconfigureFifRequest = new DatabaseFifRequest();
					reconfigureFifRequest.setTransactionId(dataReconReport.getReportID() + '-' + key.substring(4)); // field in DB too short ....
					reconfigureFifRequest.setActionName("reconfigureServiceCharacteristic");
					reconfigureFifRequest.setExternalSystemId(requestID);
					reconfigureFifRequest.setPriority(FIF_PRIORITY_LOW);
					reconfigureFifRequest.setDueDate(new Date());
					reconfigureFifRequest.setStatus(FIF_STATUS_NOT_STARTED);
					Map<String, String> parameters = new HashMap<String, String>();
					// simple parameters
					parameters.put("SERVICE_SUBSCRIPTION_ID", key);	
					parameters.put("DESIRED_DATE", DateUtils.getCurrentDate(true));	
					parameters.put("DESIRED_SCHEDULE_TYPE", "START_AFTER");	
					parameters.put("REASON_RD", "DATA_RECON");
					parameters.put("ACTIVATE_CUSTOMER_ORDER", "Y");
					reconfigureFifRequest.setParameters(parameters);					
					// parameter lists
					Map<String, List<Map<String, String>>> parameterLists = new HashMap<String, List<Map<String, String>>>();
					List<Map<String, String>> cscList = new ArrayList<Map<String, String>>();
					// items in the list
					for (ActionItem item : itemList) {
						Map<String, String> csc = new HashMap<String, String>();
						csc.put("DATA_TYPE", item.getDataType());
						csc.put("SERVICE_CHAR_CODE", item.getServiceCharCode());
						// CSCs in CONFIGURED_VALUE table
						if (item.getDataType().equals("STRING") ||
								item.getDataType().equals("BOOLEAN") ||
								item.getDataType().equals("INTEGER") ||
								item.getDataType().equals("DECIMAL")) {
							if (item.getTargetValue() != null && !(item.getTargetValue().equals("")))
								csc.put("CONFIGURED_VALUE", item.getTargetValue());
							else
								csc.put("CONFIGURED_VALUE", "**NULL**");
						}

						// ACCESS_NUMBER, actual phone numbers
						if (item.getTargetValue() != null && !(item.getTargetValue().equals("")) &&
								item.getDataType().equals(CCM_DATA_TYPE_ACC_NUM_RANGE) ||
								item.getDataType().equals(CCM_DATA_TYPE_MAIN_ACCESS_NUM) ||
								item.getDataType().equals(CCM_DATA_TYPE_MOBIL_ACCESS_NUM)) {
							String [] parts = item.getTargetValue().split(";");
							if (parts.length < 3) { 
								throw new FIFException(""); // TODO skip and restart that one, more time
							}
							csc.put("COUNTRY_CODE", parts[0]);
							csc.put("CITY_CODE", parts[1]);
							csc.put("LOCAL_NUMBER", parts[2]);
							if (parts.length > 3) { 
								csc.put("FROM_EXT_NUM", parts[3]);
								csc.put("TO_EXT_NUM", parts[4]);
							}							
						}
						// TECH_SERVICE_ID and USER_ACCOUNT_NUM
						if (item.getTargetValue() != null && !(item.getTargetValue().equals("")) &&
								item.getDataType().equals(CCM_DATA_TYPE_USER_ACCOUNT_NUM))
							csc.put("NETWORK_ACCOUNT", item.getTargetValue());
						if (item.getTargetValue() != null && !(item.getTargetValue().equals("")) &&
								item.getDataType().equals(CCM_DATA_TYPE_TECH_SERVICE_ID))
							csc.put("TECH_SERVICE_ID", item.getTargetValue());
						
						cscList.add(csc);
					}
									
					parameterLists.put("CONF_SERVICE_CHAR_LIST", cscList);
					reconfigureFifRequest.setParameterLists(parameterLists);
					
					ccmFifRequestDataAccess.insertFifRequest(reconfigureFifRequest);
				}
			}
		}		
		dataReconReport.setProcessedCCM(true);
		
	}

	public boolean hasTasks(DataReconReport dataReconReport, String externalSystem) {
		if (dataReconReport.getActionItems() == null)
			return false;
		
		for (ActionItem item : dataReconReport.getActionItems())
			if (!(item.getActionType().equals(ACTION_TYPE_IGNORE)) && 
					item.getValidatingSystem().equals(externalSystem))
				return true;
		
		return false;
	}

	
}
