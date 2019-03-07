/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/XMLTags.java-arc   1.13   Nov 21 2013 08:51:32   schwarje  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/XMLTags.java-arc  $
 * 
 *    Rev 1.13   Nov 21 2013 08:51:32   schwarje
 * IT-k-32850: generic validation of input parameters configured in metadata (first use case: CCB date format)
 * 
 *    Rev 1.12   Nov 07 2008 11:34:04   makuier
 * manual rollback added.
 * 
 *    Rev 1.11   Aug 08 2008 15:49:58   wlazlow
 * IT-21113
 * 
 *    Rev 1.10   Aug 16 2007 19:23:08   lejam
 * Added support for OMTSOrderId on the request list level IT-19036
 * 
 *    Rev 1.9   Jul 25 2007 21:02:32   makuier
 * tag for package name added.
 * 
 *    Rev 1.8   Jan 17 2007 18:11:36   makuier
 * Literals for cancelation and postponement.
 * SPN-FIF-000046682
 * 
 *    Rev 1.7   Jun 15 2004 16:19:40   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.6   Jun 14 2004 15:43:10   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.5   Dec 17 2003 14:56:16   goethalo
 * Changes for IT-9245: ISDN changes.
 * 
 *    Rev 1.4   Oct 07 2003 14:51:28   goethalo
 * Changes for IT-9811 - Internet By Call with Registration
 * 
 *    Rev 1.3   Sep 10 2003 12:38:38   goethalo
 * Additional Changes for IT-10800
 * 
 *    Rev 1.2   Sep 09 2003 16:37:02   goethalo
 * IT-10800: added warning support.
 * 
 *    Rev 1.1   Jul 16 2003 15:00:50   goethalo
 * Changes for IT-9750
 * 
 *    Rev 1.0   Apr 09 2003 09:34:44   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

/**
 * Class containing the XML tags that are used by the FIF Message Creator.
 *
 * @author goethalo
 */
public final class XMLTags {

    public static final String actionMapping = "action-mapping";

    public static final String actionName = "action-name";
    
    public static final String commandError = "error_element";

    public static final String commandErrorDescription = "error_description";

    public static final String commandErrorType = "error_type";

    public static final String commandID = "command_id";

    public static final String commandWarning = "warning_element";

    public static final String commandWarningDescription =
        "warning_description";

    public static final String commandWarningList = "warning_list";        

    public static final String commandWarningType = "warning_type";

    public static final String creatorClass = "creator-class";

    public static final String creatorInputRequestType =
        "creator-input-request-type";

    public static final String creatorOutputMessageType =
        "creator-output-message-type";

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

    public static final String messageCreatorDefinition =
        "message-creator-definition";

    public static final String messageDefinition = "message-definition";

    public static final String messageParam = "message-param";

    public static final String messageParameters = "message-parameters";

    public static final String messageParamList = "message-param-list";

    public static final String messageType = "message-type";
    
    public static final String outputParam = "output-param";
    
    public static final String outputParamName = "output-param-name";
    
    public static final String paramDefaultRefDataValue = "param-default-refdata-value";

    public static final String paramDefaultValue = "param-default-value";

    public static final String paramValidationMethod = "param-validation-method";

    public static final String paramListMandatory = "param-list-mandatory";

    public static final String paramListName = "param-list-name";

    public static final String paramMandatory = "param-mandatory";

    public static final String paramName = "param-name";

    public static final String paramValue = "param-value";

    public static final String replyActionName = "action_name";

    public static final String replyPackageName = "package_name";

    public static final String requestClass = "request-class";

    public static final String requestDefinition = "request-definition";

    public static final String requestDTDName = "request.dtd";
    
    public static final String requestListId = "request-list-id";
    
    public static final String requestListOMTSOrderId = "OMTSOrderID";
    
    public static final String requestListManualRollback = "manualRollback";
    
    public static final String requestListParams = "request-list-params";
    
    public static final String transactionListParam = "transaction_list_param";

    public static final String transactionListParams = "transaction_list_params";
    
    public static final String ccmFifParameterValueCont = "CcmFifParameterValueCont";
    
    public static final String parameterName = "parameter_name";
    
    public static final String parameterValue = "parameter_value";
    
    public static final String requestListParam = "request-list-param";
       
    public static final String requestListName = "request-list-name";
    
    public static final String requestListRoot = "request-list";

    public static final String requestParam = "request-param";

    public static final String requestParamList = "request-param-list";

    public static final String requestParamListItem = "request-param-list-item";

    public static final String requestParamListName = "name";

    public static final String requestParamName = "name";

    public static final String requestParams = "request-params";

    public static final String requestRoot = "request";

    public static final String requestType = "request-type";
    
    public static final String responseCommandID = "response-command-id";
    
    public static final String responseHandling = "response-handling";
    
    public static final String responseParamName = "response-param-name";
    
    public static final String returnWarnings = "return-warnings";

    public static final String transactionId = "transaction_id";
    
    public static final String transactionList = "transaction_list";
    
    public static final String transactionListDTD = "fif_transaction_list.dtd";
    
    public static final String transactionListID = "transaction_list_id";
    
    public static final String transactionListName = "transaction_list_name";

    public static final String transactionListCustomerTrackingId = "transaction_list_customer_tracking_id";

    public static final String transactionListManualRollback = "manual_rollback";

    public static final String transactionListRoot = "CcmFifTransactionList";
    
    public static final String transactionListState = "transaction_list_state";
    
    public static final String transactionListStateFailed = "ROLLED_BACK";

    public static final String transactionListStateSucceeded = "COMMIT";
    
    public static final String transactionRoot = "CcmFifCommandList";
    
    public static final String transactionState = "transaction_state";
    
    public static final String transactionStateFailed = "ROLLED_BACK";
    
    public static final String transactionStateNotExecuted = "NOT_EXECUTED";

    public static final String transactionStateSucceeded = "COMMIT";
    
    public static final String transactionStateCanceled = "CANCELED";
    
    public static final String transactionStatePostpones = "POSTPONED";
    
}
