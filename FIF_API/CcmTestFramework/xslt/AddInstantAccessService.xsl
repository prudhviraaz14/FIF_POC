<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for ordering instant access

  @author schwarje
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
      
      <xsl:variable name="today"
        select="dateutils:getCurrentDate()"/>
      
      <xsl:variable name="tomorrow"
        select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
      
      <xsl:if test="request-param[@name='type'] != ''">
        <!-- Get Detailed Reason Rd -->     
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_detailed_reason</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">
              <xsl:value-of select="request-param[@name='type']"/>
              <xsl:text>_DETAILED_REASON_RD</xsl:text>
            </xsl:element>
            <xsl:element name="ignore_empty_result">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- get service subscription -->     
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_service_subscription</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">
              <xsl:value-of select="request-param[@name='type']"/>
              <xsl:text>_SERVICE_SUBSCRIPTION_ID</xsl:text>
            </xsl:element>
            <xsl:element name="ignore_empty_result">N</xsl:element>
          </xsl:element>
        </xsl:element>        
      </xsl:if>
      
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_main_service</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:choose>
            <xsl:when test="request-param[@name='type'] != ''">
              <xsl:element name="service_subscription_id_ref">
                <xsl:element name="command_id">read_service_subscription</xsl:element>
                <xsl:element name="field_name">parameter_value</xsl:element>
              </xsl:element>            
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="service_subscription_id">
                <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
              </xsl:element>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:element>
      
      <!-- Add Feature Service -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_main_service</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V8042</xsl:element>
          <xsl:element name="sales_organisation_number">
                <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
          </xsl:element>  
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">find_main_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_main_service</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="service_characteristic_list">
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0108</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='SIMID']"/>
              </xsl:element>
            </xsl:element> 
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V8004</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='instantAccessOption']"/>
              </xsl:element>
            </xsl:element>            
          </xsl:element>
          <xsl:element name="detailed_reason_ref">
            <xsl:element name="command_id">read_detailed_reason</xsl:element>
            <xsl:element name="field_name">parameter_value</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Find terminated STP -->
      <xsl:element name="CcmFifFindServiceTicketPositionCmd">
        <xsl:element name="command_id">find_stp</xsl:element>
        <xsl:element name="CcmFifFindServiceTicketPositionInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">find_main_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="no_stp_error">N</xsl:element>
          <xsl:element name="find_stp_parameters">
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="usage_mode_value_rd">2</xsl:element>
              <xsl:element name="customer_order_state">DEFINED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="usage_mode_value_rd">2</xsl:element>
              <xsl:element name="customer_order_state">RELEASED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">DEFINED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">RELEASED</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- check for a previous action - add action here if no OMTS notification needed-->
      <xsl:element name="CcmFifValidatePreviousActionCmd">
        <xsl:element name="command_id">validate_previous_action_1</xsl:element>
        <xsl:element name="CcmFifValidatePreviousActionInCont">
          <xsl:element name="list_of_action_name">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">changeAccessNumbers</xsl:element>          	  
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">changeDSLBandwidth</xsl:element>          	  
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">changeDSLBandwidthAndTariff</xsl:element>          	  
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">changeMultimediaProduct</xsl:element>          	  
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">createMultimediaContract</xsl:element>          	  
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">createTVCenterContract</xsl:element>          	  
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">downgradeFromDSL</xsl:element>          	  
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">modifyAccessNumberBlocking</xsl:element>          	  
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">modifyAdviceOfCharge</xsl:element>          	  
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">modifyDSL</xsl:element>          	  
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">upgradeToACS</xsl:element>          	  
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">upgradeToDSL</xsl:element>          	  
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">concat_validate_service</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_stp</xsl:element>
              <xsl:element name="field_name">stp_found</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">;</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">validate_previous_action_1</xsl:element>
              <xsl:element name="field_name">action_performed_ind</xsl:element>							
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element> 
      
      <!-- Reconfigure the main access service -->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconfigure</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">          
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_main_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$tomorrow"/>            
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="reason_rd">CUST_REQUEST</xsl:element>          
          <xsl:element name="service_characteristic_list">
            <!-- Instant Access -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V8003</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='instantAccessIndicator']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">concat_validate_service</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y;Y</xsl:element>   
        </xsl:element>
      </xsl:element>
      
      <!-- Reconfigure the main access service -->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconfigure</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">          
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_main_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Instant Access -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V8003</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='instantAccessIndicator']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">concat_validate_service</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N;Y</xsl:element>   
        </xsl:element>
      </xsl:element>
      
      <!-- Reconfigure the main access service -->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconfigure</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">          
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_main_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$tomorrow"/>            
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="reason_rd">CUST_REQUEST</xsl:element>          
          <xsl:element name="service_characteristic_list">
            <!-- Instant Access -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V8003</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='instantAccessIndicator']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0971</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">NoOP</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">concat_validate_service</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y;N</xsl:element>   
        </xsl:element>
      </xsl:element>
      
      <!-- Reconfigure the main access service -->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconfigure</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">          
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_main_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Instant Access -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V8003</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='instantAccessIndicator']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0971</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">NoOP</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">concat_validate_service</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N;N</xsl:element>   
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
        <xsl:element name="command_id">get_stp_data</xsl:element>
        <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_stp</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_stp</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>   
        </xsl:element>
      </xsl:element>
        
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_main_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="cust_order_description">InstantAccess-Bestellung</xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconfigure</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_main_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_stp</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>   
          <xsl:element name="parent_customer_order_id_ref">
            <xsl:element name="command_id">get_stp_data</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>       
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_main_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_stp</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>   
        </xsl:element>
      </xsl:element>       
      
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_main_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">ADD_FEATURE_SERV</xsl:element>
          <xsl:element name="short_description">InstantAccess-Bestellung</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>InstantAccess-Bestellung über </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
            <xsl:text>&#xA;TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;Wunschdatum: </xsl:text>
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
	  
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
