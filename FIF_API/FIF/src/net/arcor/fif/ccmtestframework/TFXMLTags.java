/*
 $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/ccmtestframework/TFXMLTags.java-arc   1.11   Aug 05 2011 14:42:04   schwarje  $

 $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/ccmtestframework/TFXMLTags.java-arc  $
 * 
 *    Rev 1.11   Aug 05 2011 14:42:04   schwarje
 * BKS request for TFW
 * 
 *    Rev 1.10   Jun 24 2010 17:53:28   schwarje
 * CPCOM Phase 2: new FIF client type accepting SOM orders
 * 
 *    Rev 1.9   Aug 06 2009 12:40:16   schwarje
 * added com-requests
 * 
 *    Rev 1.8   May 04 2009 17:06:40   lejam
 * Added parameters to request list.
 * 
 *    Rev 1.7   Feb 07 2007 17:05:38   schwarje
 * added setting of override system date for use in XSLT
 * 
 *    Rev 1.6   Dec 22 2006 11:34:26   schwarje
 * TF: added support for transaction lists
 * 
 *    Rev 1.5   Dec 08 2006 13:25:20   schwarje
 * added SQL requests
 * 
 *    Rev 1.4   Sep 27 2005 15:12:14   banania
 * Added 'requestParamRefOutputParamName'.
 * 
 *    Rev 1.3   Sep 19 2005 15:30:06   banania
 * requestParamRefTransactionID added.
 * 
 *    Rev 1.2   Sep 15 2005 15:04:54   banania
 * Added param-name.
 * 
 *    Rev 1.1   Sep 08 2005 15:15:08   banania
 * Cleaned up the code and added a PVCS-headed!
 */
package net.arcor.fif.ccmtestframework;

/**
 * @author banania Class containing the XML tags that are used by the
 *         testframework Client.
 */
public final class TFXMLTags {

	public static final String actionMapping = "action-mapping";

	public static final String actionName = "action-name";

	public static final String commandError = "error_element";

	public static final String commandErrorDescription = "error_description";

	public static final String commandErrorType = "error_type";

	public static final String commandID = "command_id";

	public static final String commandWarning = "warning_element";

	public static final String commandWarningDescription = "warning_description";

	public static final String commandWarningList = "warning_list";

	public static final String commandWarningType = "warning_type";

	public static final String creatorClass = "creator-class";

	public static final String creatorInputRequestType = "creator-input-request-type";

	public static final String creatorOutputMessageType = "creator-output-message-type";

	public static final String creatorParam = "creator-param";

	public static final String creatorType = "creator-type";

	public static final String executionState = "execution_state";

	public static final String executionStateFailed = "FAILED";

	public static final String executionStateNotExecuted = "NOT_EXECUTED";

	public static final String executionStateSuccess = "SUCCESS";

	public static final String groupCode = "group-code";

	public static final String itemIdentifier = "item-identifier";

	public static final String messageClass = "message-class";

	public static final String messageCreation = "message-creation";

	public static final String messageCreatorDefinition = "message-creator-definition";

	public static final String messageDefinition = "message-definition";

	public static final String messageParam = "message-param";

	public static final String messageParameters = "message-parameters";

	public static final String messageParamList = "message-param-list";

	public static final String messageType = "message-type";

	public static final String outputParam = "output-param";

	public static final String outputParamName = "output-param-name";

	public static final String paramDefaultRefDataValue = "param-default-refdata-value";

	public static final String paramDefaultValue = "param-default-value";

	public static final String paramListMandatory = "param-list-mandatory";

	public static final String paramListName = "param-list-name";

	public static final String paramMandatory = "param-mandatory";

	public static final String paramName = "param-name";

	public static final String paramValue = "param-value";

	public static final String replyActionName = "action_name";

	public static final String requestClass = "request-class";

	public static final String requestDefinition = "request-definition";

	public static final String requestDTDName = "request.dtd";

	public static final String requestListId = "request-list-id";

	public static final String requestListName = "request-list-name";

	public static final String requestListRoot = "request-list";

	public static final String requestParam = "request-param";

	public static final String requestParamRef = "request-param-ref";

	public static final String requestParamList = "request-param-list";

	public static final String requestParamListItem = "request-param-list-item";

	public static final String requestParamListName = "name";

	public static final String requestParamName = "name";

	public static final String requestParamRefTransactionID = "transactionID";

	public static final String requestParamRefParamName = "param-name";

	public static final String requestParamRefOutputParamName = "output-param-name";

	public static final String requestParams = "request-params";

	public static final String requestRoot = "request";

	public static final String requestType = "request-type";

	public static final String responseCommandID = "response-command-id";

	public static final String responseHandling = "response-handling";

	public static final String responseParamName = "response-param-name";

	public static final String returnWarnings = "return-warnings";

	public static final String transactionId = "transaction_id";

	public static final String transactionList = "transaction-list";

	public static final String transactionListDTD = "fif_transaction_list.dtd";

	public static final String transactionListID = "transaction-list-id";

	public static final String transactionListName = "transaction-list-name";

	public static final String transactionListParams = "transaction-list-params";

	public static final String transactionListParam = "transaction-list-param";

	public static final String transactionListParamName = "name";

	public static final String FIFTransactionListParams = "transaction_list_params";

	public static final String FIFParameterValueCont = "CcmFifParameterValueCont";

	public static final String FIFParameterName = "parameter_name";
	
	public static final String FIFParameterValue = "parameter_value";

	public static final String transactionListRoot = "CcmFifTransactionList";

	public static final String transactionListState = "transaction_list_state";

	public static final String transactionListStateFailed = "ROLLED_BACK";

	public static final String transactionListStateSucceeded = "COMMIT";

	public static final String transactionRoot = "CcmFifCommandList";

	public static final String transactionState = "transaction_state";

	public static final String sqlRequestRoot = "sql-request";

	public static final String statement = "statement";

	public static final String sqlRequestTransactionId = "transaction-id";
	
	public static final String requests = "requests";

	public static final String sqlRequestInputParams = "sql-request-input-params";

	public static final String sqlRequestOutputParams = "sql-request-output-params";

	public static final String sqlRequestResultParams = "sql-request-result-params";

	public static final String bksRequestInputParams = "bks-request-input-params";

	public static final String bksRequestOutputParams = "bks-request-output-params";

	public static final String bksRequestResultParams = "bks-request-result-params";

	public static final String transactionStateFailed = "ROLLED_BACK";

	public static final String transactionStateNotExecuted = "NOT_EXECUTED";

	public static final String transactionStateSucceeded = "COMMIT";

	public static final String paramNameOverrideSystemDate = "OVERRIDE_SYSTEM_DATE";
	
	public static final String bksRequestRoot = "bks-request";
	
	public static final String somParts = "som-parts";

	public static final String somPartTemplate = "som-part-template";

	public static final String somPartParams = "som-part-params";

	public static final String filename = "filename";
	
	public static final String trxBuilderRequestRoot = "trx-builder-request";
	

}
