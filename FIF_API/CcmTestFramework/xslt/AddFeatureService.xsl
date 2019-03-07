<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an Add Feature Service FIF request

  @author goethalo
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
    exclude-result-prefixes="dateutils">
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
  <xsl:template match="/">
    <xsl:element name="CcmFifCommandList">
      <xsl:apply-templates select="request/request-params"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="request-params">
    <!-- Copy over transaction ID and action name -->
    <xsl:element name="transaction_id">
      <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="client_name">
      <xsl:value-of select="request-param[@name='clientName']"/>
    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">
   
      <xsl:variable name="Type">
        <!-- the empty text in each variable is a hack to have the variable existing
          even if the original is not defined in one of the FIF clients -->
        <xsl:text/>
        <xsl:value-of select="request-param[@name='type']"/>
      </xsl:variable> 
      <xsl:variable name="accessNumber">
        <xsl:text/>
        <xsl:value-of select="request-param[@name='accessNumber']"/>
      </xsl:variable> 
      <xsl:variable name="productSubscriptionId">
        <xsl:text/>
        <xsl:value-of select="request-param[@name='productSubscriptionId']"/>
      </xsl:variable> 
      <xsl:variable name="serviceSubscriptionId">
        <xsl:text/>
        <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
      </xsl:variable> 
      <xsl:variable name="onlineAccountNumber">
        <xsl:text/>
        <xsl:value-of select="request-param[@name='onlineAccountNumber']"/>
      </xsl:variable> 

      <xsl:if test="$serviceSubscriptionId = ''
        and $accessNumber = ''
        and $productSubscriptionId = ''
        and $Type = ''">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">type_error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The paramter type has to be set if serviceSubscriptionId, productSubscriptionId  and accessNumber are empty!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
            
      <!--Get Detailed Reason Rd -->     
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_external_notification_3</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">
              <xsl:value-of select="concat($Type, '_DETAILED_REASON_RD')"/>
            </xsl:element>
            <xsl:element name="ignore_empty_result">Y</xsl:element>
          </xsl:element>
        </xsl:element>
  
      <xsl:if test="$accessNumber != '' or
        $onlineAccountNumber != '' or
        $productSubscriptionId != '' or
        $serviceSubscriptionId != ''">
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <!-- Find by access number, if provided -->            
            <xsl:if test="$accessNumber != '' and
              $onlineAccountNumber = '' and
              $serviceSubscriptionId = '' and
              $productSubscriptionId = ''">
              <xsl:element name="access_number">
                <xsl:value-of select="$accessNumber"/>
              </xsl:element>
              <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
            </xsl:if>

            <!-- Find by online account number, if provided -->
            <xsl:if test="$onlineAccountNumber != '' and
              $accessNumber = '' and
              $serviceSubscriptionId = '' and
              $productSubscriptionId = ''">
              <xsl:element name="access_number">
                <xsl:value-of select="$onlineAccountNumber"/>
              </xsl:element>
              <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
              <xsl:element name="access_number_type">USER_ACCOUNT_NUM</xsl:element>
            </xsl:if>
            <xsl:if test="$serviceSubscriptionId != ''">
              <xsl:element name="service_subscription_id">
                <xsl:value-of select="$serviceSubscriptionId"/>
              </xsl:element>
            </xsl:if>
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:element>
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="contract_number">
              <xsl:value-of select="request-param[@name='contractNumber']"/>
            </xsl:element>
            <xsl:if test="$productSubscriptionId != ''">
              <xsl:element name="product_subscription_id">
                <xsl:value-of select="$productSubscriptionId"/>
              </xsl:element>
              <xsl:element name="fetch_main_ss_from_ps_Ind">Y</xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Take value of serviceSubscriptionId from ccm external notification if accessNumber,serviceTicketPositionId,serviceSubscriptionId not provided -->
      <xsl:if test="($accessNumber = '') 
        and ($onlineAccountNumber = '') 
        and $serviceSubscriptionId = '' 
        and ($productSubscriptionId = '')">

        <xsl:if test="$Type != ''">                          
          <xsl:element name="CcmFifReadExternalNotificationCmd">
            <xsl:element name="command_id">read_external_notification_1</xsl:element>
            <xsl:element name="CcmFifReadExternalNotificationInCont">
              <xsl:element name="transaction_id">
                <xsl:value-of select="request-param[@name='requestListId']"/>
              </xsl:element>
              <xsl:element name="parameter_name">
                <xsl:value-of select="concat($Type, '_SERVICE_SUBSCRIPTION_ID')"/>
              </xsl:element>                        
            </xsl:element>
          </xsl:element>
        </xsl:if>       
          
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>            
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Add Feature Service -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='featureServiceCode']"/>
          </xsl:element>
          <xsl:element name="sales_organisation_number">
                <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
          </xsl:element>  
          <xsl:element name="sales_organisation_number_vf">
            <xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
          </xsl:element>   
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="reason_rd">MODIFY_FEATURES</xsl:element>
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='orderDate'] != ''">          
              <xsl:value-of select="request-param[@name='orderDate']"/>
            </xsl:if>
            <xsl:if test="count(request-param[@name='orderDate']) = 0 or
                                request-param[@name='orderDate'] = ''">
              <xsl:value-of select="dateutils:getCurrentDate(true)"/>
            </xsl:if>
          </xsl:element>

          <xsl:element name="service_characteristic_list">
          </xsl:element>
          <xsl:element name="detailed_reason_ref">
                  <xsl:element name="command_id">read_external_notification_3</xsl:element>
                  <xsl:element name="field_name">parameter_value</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:if test="$serviceSubscriptionId = ''
        and $productSubscriptionId = ''
        and $onlineAccountNumber = ''
        and $accessNumber = ''">       
        <!-- find an open reconfigure customer order for the main  service -->
        <xsl:element name="CcmFifFindCustomerOrderCmd">
          <xsl:element name="command_id">find_customer_order_1</xsl:element>
          <xsl:element name="CcmFifFindCustomerOrderInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="state_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">ASSIGNED</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">RELEASED</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="allow_children">Y</xsl:element>
            <xsl:element name="usage_mode">2</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- find an open subscribe customer order for the main service if not found above -->
        <xsl:element name="CcmFifFindCustomerOrderCmd">
          <xsl:element name="command_id">find_customer_order_2</xsl:element>
          <xsl:element name="CcmFifFindCustomerOrderInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="state_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">ASSIGNED</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">RELEASED</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="allow_children">Y</xsl:element>
            <xsl:element name="usage_mode">1</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_customer_order_1</xsl:element>
              <xsl:element name="field_name">customer_order_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element> 
          </xsl:element>
        </xsl:element>
        
        <!-- concat results of two recent commands for use in process indicator --> 
        <xsl:element name="CcmFifConcatStringsCmd">
          <xsl:element name="command_id">concat_parameters_1</xsl:element>
          <xsl:element name="CcmFifConcatStringsInCont">
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_customer_order_1</xsl:element>
                <xsl:element name="field_name">customer_order_found</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">_</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_customer_order_2</xsl:element>
                <xsl:element name="field_name">customer_order_found</xsl:element>							
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>							
        
        <!-- Add STPs to reconfigure customer order if exists -->   
        <xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
          <xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
            <xsl:element name="customer_order_id_ref">
              <xsl:element name="command_id">find_customer_order_1</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_ticket_pos_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="processing_status">
              <xsl:value-of select="request-param[@name='processingStatus']"/>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_customer_order_1</xsl:element>
              <xsl:element name="field_name">customer_order_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>   
          </xsl:element>
        </xsl:element>
        
        <!-- Add STPs to subscribe customer order if exists -->   
        <xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
          <xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
            <xsl:element name="customer_order_id_ref">
              <xsl:element name="command_id">find_customer_order_2</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_ticket_pos_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="processing_status">
              <xsl:value-of select="request-param[@name='processingStatus']"/>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_customer_order_2</xsl:element>
              <xsl:element name="field_name">customer_order_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>   
          </xsl:element>
        </xsl:element>

        <!-- Create Customer Order if neither reconfigure or subscribe customer orders not exist -->
        <xsl:element name="CcmFifCreateCustOrderCmd">
          <xsl:element name="command_id">create_co_1</xsl:element>
          <xsl:element name="CcmFifCreateCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="cust_order_description">Add Feature Service</xsl:element>
            <xsl:element name="customer_tracking_id">
              <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
            </xsl:element>
            <xsl:element name="service_ticket_pos_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">concat_parameters_1</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">N_N</xsl:element> 
            <xsl:element name="e_shop_id">
						<xsl:value-of select="request-param[@name='eShopID']"/>
			</xsl:element>
            <xsl:element name="processing_status">
              <xsl:value-of select="request-param[@name='processingStatus']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>

        <!-- Release Customer Order if neither reconfigure or subscribe customer orders not exist -->
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="CcmFifReleaseCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">create_co_1</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">concat_parameters_1</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">N_N</xsl:element>             
          </xsl:element>
        </xsl:element>       
      </xsl:if>

      <xsl:if test="$serviceSubscriptionId != ''
        or $productSubscriptionId != ''
        or $onlineAccountNumber != ''
        or $accessNumber != ''">
        <!-- Create Customer Order -->
        <xsl:element name="CcmFifCreateCustOrderCmd">
          <xsl:element name="command_id">create_co_1</xsl:element>
          <xsl:element name="CcmFifCreateCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="cust_order_description">Add Feature Service</xsl:element>
            <xsl:element name="customer_tracking_id">
              <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
            </xsl:element>
            <xsl:element name="service_ticket_pos_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="e_shop_id">
						<xsl:value-of select="request-param[@name='eShopID']"/>
			</xsl:element>
            <xsl:element name="processing_status">
              <xsl:value-of select="request-param[@name='processingStatus']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Release Customer Order -->
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="CcmFifReleaseCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">create_co_1</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
                       
      <!-- Create Contact for Feature Service Addition -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">ADD_FEATURE_SERV</xsl:element>
          <xsl:element name="short_description">
          	<xsl:text>Dienst hinzugefügt über </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
          </xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;Feature Service Code: </xsl:text>
            <xsl:value-of select="request-param[@name='featureServiceCode']"/>
            <xsl:text>&#xA;Wunschdatum: </xsl:text>
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
	  
      <xsl:if test="request-param[@name='clientName'] != 'KBA'">
      <!-- Create KBA notification  -->
      <xsl:element name="CcmFifCreateExternalNotificationCmd">
        <xsl:element name="command_id">create_kba_notification_1</xsl:element>
        <xsl:element name="CcmFifCreateExternalNotificationInCont">
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
          <xsl:element name="notification_action_name">createKBANotification</xsl:element>
          <xsl:element name="target_system">KBA</xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TYPE</xsl:element>
              <xsl:element name="parameter_value">CONTACT</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CATEGORY</xsl:element>
              <xsl:element name="parameter_value">ChangeFee</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">USER_NAME</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='clientName']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">WORK_DATE</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='desiredDate']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TEXT</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:text>Dienst </xsl:text>
				<xsl:value-of select="request-param[@name='featureServiceCode']"/>
				<xsl:text> hinzugefügt über </xsl:text>
                <xsl:value-of select="request-param[@name='clientName']"/>
                <xsl:text>.</xsl:text>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
