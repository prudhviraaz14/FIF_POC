/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/QueueClientXMLTags.java-arc   1.5   Dec 18 2018 09:27:14   Lalitpise  $
    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/client/QueueClientXMLTags.java-arc  $
 * 
 *    Rev 1.5   Dec 18 2018 09:27:14   Lalitpise
 * IT-K34257 added variables jmsReplyTo and jmsCorrelationId
 * 
 *    Rev 1.4   Jun 14 2004 15:43:04   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.3   Oct 07 2003 14:50:44   goethalo
 * Changes for IT-9811 - Internet By Call with Registration
 * 
 *    Rev 1.2   Sep 09 2003 16:34:58   goethalo
 * IT-10800: support for warnings and parameter lists in DB clients.
*/    
package net.arcor.fif.client;

/**
 * Class containing the XML tags that are used by the QueueClient.
 * @author goethalo
 */
public class QueueClientXMLTags {
    
    public static final String actionName = "action-name";

    public static final String error = "error";

    public static final String errorList = "error-list";

    public static final String errorMessage = "message";

    public static final String errorNumber = "number";
    
    public static final String outputParam = "output-param";
    
    public static final String outputParamName = "name";

    public static final String outputParams = "output-params";

    public static final String requestListErrors = "request-list-errors";
    
    public static final String requestListID = "request-list-id";
    
    public static final String requestListName = "request-list-name";
    
    public static final String requestListResult = "request-list-result";

    public static final String responseDTDName = "response.dtd";
    
    public static final String responseListDTDName = "response-list.dtd";
    
    public static final String responseListRoot = "response-list";

    public static final String responseRoot = "response";
    
    public static final String responses = "responses";

    public static final String transactionId = "transaction-id";

    public static final String transactionResult = "transaction-result";

    public static final String transactionStatusFailure = "FAILURE";
    
    public static final String transactionStatusNotExecuted = "NOT_EXECUTED";

    public static final String transactionStatusSuccess = "SUCCESS";

    public static final String transactionStatusValidated = "VALIDATED";
    
    public static final String unknownValue = "unknown";

    public static final String warning = "warning";

    public static final String warningList = "warning-list";

    public static final String warningMessage = "message";

    public static final String warningNumber = "number";
    
    public static final String jmsCorrelationId = "jmsCorrelationId";
    
    public static final String jmsReplyTo = "jmsReplyTo";
}
