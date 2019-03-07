<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for activating an inporting order

  @author schwarje
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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
    <xsl:element name="package_name">
      <xsl:value-of select="request-param[@name='packageName']"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    
    <xsl:element name="Command_List">
      
      <xsl:variable name="tomorrow" select="dateutils:createFIFDateOffset(dateutils:getCurrentDate(), 'DATE', '1')"/>
      
      <xsl:variable name="desiredDate">
        <xsl:choose>
          <xsl:when test="dateutils:compareString(request-param[@name='GueltigkeitsDatum'], $tomorrow) = '-1'">
            <xsl:value-of select="$tomorrow"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='GueltigkeitsDatum']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="oneDayBefore"
        select="dateutils:createFIFDateOffset($desiredDate, 'DATE', '-1')"/>      
      
      <!-- get the access number in CCB format from the input fields in SBUS format -->
      <xsl:variable name="accessNumber">
        <xsl:text>49;</xsl:text>
        <xsl:value-of select="substring(request-param[@name='Rufnummer;Mobilvorwahl'], 2)"/>
        <xsl:text>;</xsl:text>
        <xsl:value-of select="request-param[@name='Rufnummer;Mobilfunkrufnummer']"/>
      </xsl:variable>
      
      <!-- Find Service Subscription by access number,or service_subscription id  if no bundle was found -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_mobile_service</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="access_number">
            <xsl:value-of select="$accessNumber"/>
          </xsl:element>
          <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- find stp -->
      <xsl:element name="CcmFifFindServiceTicketPositionCmd">
        <xsl:element name="command_id">find_reconfigure_stp</xsl:element>
        <xsl:element name="CcmFifFindServiceTicketPositionInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_mobile_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">find_mobile_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="find_stp_parameters">
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="usage_mode_value_rd">2</xsl:element>
              <xsl:element name="customer_order_state">DEFINED</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- get STP data -->
      <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
        <xsl:element name="command_id">get_reconfigure_stp_data</xsl:element>
        <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_reconfigure_stp</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:if test="request-param[@name='originalRequestResult'] = 'true'">      
      
        <!-- get data from customer order -->
        <xsl:element name="CcmFifGetCustomerOrderDataCmd">
          <xsl:element name="command_id">get_reconfigure_co_data</xsl:element>
          <xsl:element name="CcmFifGetCustomerOrderDataInCont">
            <xsl:element name="customer_order_id_ref">
              <xsl:element name="command_id">get_reconfigure_stp_data</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Get PC data to retrieve the current tariff -->
        <xsl:element name="CcmFifGetProductCommitmentDataCmd">
          <xsl:element name="command_id">get_old_tariff</xsl:element>
          <xsl:element name="CcmFifGetProductCommitmentDataInCont">
            <xsl:element name="product_commitment_number_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">product_commitment_number</xsl:element>
            </xsl:element>
            <xsl:element name="retrieve_signed_version">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Get PC data to retrieve the current tariff -->
        <xsl:element name="CcmFifGetProductCommitmentDataCmd">
          <xsl:element name="command_id">get_new_tariff</xsl:element>
          <xsl:element name="CcmFifGetProductCommitmentDataInCont">
            <xsl:element name="product_commitment_number_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">product_commitment_number</xsl:element>
            </xsl:element>
            <xsl:element name="retrieve_signed_version">N</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- check for other mobile services with the same tariff -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_additional_mobile_service</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>							
            </xsl:element>
            <xsl:element name="product_code">V8000</xsl:element>         
            <xsl:element name="pricing_structure_code_ref">
              <xsl:element name="command_id">get_old_tariff</xsl:element>
              <xsl:element name="field_name">pricing_structure_code</xsl:element>							
            </xsl:element>
            <xsl:element name="service_code">V8000</xsl:element>
            <xsl:element name="no_service_error">N</xsl:element>
            <xsl:element name="excluded_services">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_mobile_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="retrieve_signed_version">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- check for real tariff change, i.e. pricing structure has changed -->
        <xsl:element name="CcmFifConcatStringsCmd">
          <xsl:element name="command_id">concat_is_pricing_structure_change</xsl:element>
          <xsl:element name="CcmFifConcatStringsInCont">
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">get_old_tariff</xsl:element>
                <xsl:element name="field_name">pricing_structure_code</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">;</xsl:element>
              </xsl:element>							
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">get_new_tariff</xsl:element>
                <xsl:element name="field_name">pricing_structure_code</xsl:element>							
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        <xsl:element name="CcmFifMapStringCmd">
          <xsl:element name="command_id">is_pricing_structure_change</xsl:element>
          <xsl:element name="CcmFifMapStringInCont">
            <xsl:element name="input_string_type">xxx</xsl:element>
            <xsl:element name="input_string_ref">
              <xsl:element name="command_id">concat_is_pricing_structure_change</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="output_string_type">xxx</xsl:element>
            <xsl:element name="string_mapping_list">
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">V8000;V8000</xsl:element>
                <xsl:element name="output_string">N</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">V8002;V8002</xsl:element>
                <xsl:element name="output_string">N</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">V8003;V8003</xsl:element>
                <xsl:element name="output_string">N</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">V8004;V8004</xsl:element>
                <xsl:element name="output_string">N</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="no_mapping_error">N</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- concat results for determining if the rebate has to be deactivated -->
        <xsl:element name="CcmFifConcatStringsCmd">
          <xsl:element name="command_id">concat_deact_rebate</xsl:element>
          <xsl:element name="CcmFifConcatStringsInCont">
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">get_old_tariff</xsl:element>
                <xsl:element name="field_name">pricing_structure_code</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">;</xsl:element>
              </xsl:element>							
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">is_pricing_structure_change</xsl:element>
                <xsl:element name="field_name">output_string</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">;</xsl:element>
              </xsl:element>							
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_additional_mobile_service</xsl:element>
                <xsl:element name="field_name">service_found</xsl:element>							
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- look for a rebate with tariff V8906 and terminate it, if found -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_rebate_service_V8906</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>							
            </xsl:element>
            <xsl:element name="product_code">V8900</xsl:element>
            <xsl:element name="pricing_structure_code">V8906</xsl:element>
            <xsl:element name="service_code">V9001</xsl:element>
            <xsl:element name="no_service_error">N</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">concat_deact_rebate</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>							
            </xsl:element>
            <xsl:element name="required_process_ind">V8000;;N</xsl:element>
          </xsl:element>
        </xsl:element>
        <xsl:element name="CcmFifTerminateProductSubsCmd">
          <xsl:element name="command_id">terminate_rebate_V8906</xsl:element>
          <xsl:element name="CcmFifTerminateProductSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_rebate_service_V8906</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="$oneDayBefore"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
            <xsl:element name="reason_rd">MOBILETARIFCHG</xsl:element>
            <xsl:element name="auto_customer_order">N</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_rebate_service_V8906</xsl:element>
              <xsl:element name="field_name">service_found</xsl:element>							
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- look for a rebate with tariff V8907 and terminate it, if found -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_rebate_service_V8907</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>							
            </xsl:element>
            <xsl:element name="product_code">V8900</xsl:element>
            <xsl:element name="pricing_structure_code">V8907</xsl:element>
            <xsl:element name="service_code">V9001</xsl:element>
            <xsl:element name="no_service_error">N</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">concat_deact_rebate</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>							
            </xsl:element>
            <xsl:element name="required_process_ind">V8004;;N</xsl:element>
          </xsl:element>
        </xsl:element>
        <xsl:element name="CcmFifTerminateProductSubsCmd">
          <xsl:element name="command_id">terminate_rebate_V8907</xsl:element>
          <xsl:element name="CcmFifTerminateProductSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_rebate_service_V8907</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="$oneDayBefore"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
            <xsl:element name="reason_rd">MOBILETARIFCHG</xsl:element>
            <xsl:element name="auto_customer_order">N</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_rebate_service_V8907</xsl:element>
              <xsl:element name="field_name">service_found</xsl:element>							
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element>
                
        <!-- Get the sales org number from the mobile contract -->
        <xsl:element name="CcmFifGetCommissioningInformationDataCmd">
          <xsl:element name="command_id">get_sales_org_number</xsl:element>
          <xsl:element name="CcmFifGetCommissioningInformationDataInCont">
            <xsl:element name="supported_object_id_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
            <xsl:element name="supported_object_type_rd">O</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Check, if the value is a valid one -->
        <xsl:element name="CcmFifValidateGeneralCodeItemCmd">
          <xsl:element name="command_id">validate_sales_org_number</xsl:element>
          <xsl:element name="CcmFifValidateGeneralCodeItemInCont">
            <xsl:element name="group_code">SALEORGNUM</xsl:element>
            <xsl:element name="value_ref">
              <xsl:element name="command_id">get_sales_org_number</xsl:element>
              <xsl:element name="field_name">sales_org_number</xsl:element>							
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- check if there is another V8004 service (except) -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_for_tariff_V8004</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>							
            </xsl:element>
            <xsl:element name="product_code">V8000</xsl:element>
            <xsl:element name="pricing_structure_code">V8004</xsl:element>
            <xsl:element name="service_code">V8000</xsl:element>
            <xsl:element name="no_service_error">N</xsl:element>          
            <xsl:element name="excluded_services">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_mobile_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="retrieve_signed_version">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- check for a monthly fee service below the mobile service -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_monthly_fee_service</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="product_subscription_id_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>							
            </xsl:element>
            <xsl:element name="service_code">V8033</xsl:element>
            <xsl:element name="no_service_error">N</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">get_old_tariff</xsl:element>
              <xsl:element name="field_name">pricing_structure_code</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">V8004</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- terminate the monthly fee service, if the old tariff is V8004 -->
        <xsl:element name="CcmFifTermSuspReactServiceSubsCmd">
          <xsl:element name="command_id">terminate_fee_service</xsl:element>
          <xsl:element name="CcmFifTermSuspReactServiceSubsInCont">
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_monthly_fee_service</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>							
            </xsl:element>
            <xsl:element name="usage_mode">4</xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="$oneDayBefore"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
            <xsl:element name="reason_rd">MOBILETARIFCHG</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_monthly_fee_service</xsl:element>
              <xsl:element name="field_name">service_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element>
                
        <!-- Create Customer Order for terminations  -->
        <xsl:element name="CcmFifCreateCustOrderCmd">
          <xsl:element name="command_id">create_termination_co</xsl:element>
          <xsl:element name="CcmFifCreateCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="customer_tracking_id_ref">
              <xsl:element name="command_id">get_reconfigure_co_data</xsl:element>
              <xsl:element name="field_name">customer_tracking_id</xsl:element>
            </xsl:element>
            <xsl:element name="provider_tracking_no"></xsl:element>
            <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
            <xsl:element name="service_ticket_pos_list">
              <!-- fee service, if applicable -->
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">terminate_fee_service</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
              </xsl:element>
              <!-- rebate service, if applicable -->
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">terminate_rebate_V8906</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">terminate_rebate_V8907</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
              </xsl:element>              
            </xsl:element>  
          </xsl:element>
        </xsl:element>
        
        <!-- release customer order -->
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="command_id">release_termination_co</xsl:element>
          <xsl:element name="CcmFifReleaseCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">create_termination_co</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- check, if a fee service for another sim card has to be created.
          This happens i the following case:
          1) The tariff is changed from V8004 to another tariff
          2) The changed sim card has a fee service
          3) There is another sim card using V8004
        -->
        <xsl:element name="CcmFifConcatStringsCmd">
          <xsl:element name="command_id">concat_add_additional_fee_service</xsl:element>
          <xsl:element name="CcmFifConcatStringsInCont">
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">get_old_tariff</xsl:element>
                <xsl:element name="field_name">pricing_structure_code</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">;</xsl:element>
              </xsl:element>							
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_monthly_fee_service</xsl:element>
                <xsl:element name="field_name">service_found</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">;</xsl:element>
              </xsl:element>							
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_service_for_tariff_V8004</xsl:element>
                <xsl:element name="field_name">service_found</xsl:element>							
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- add the fee service for another mobile service -->
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_additional_fee_service</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_for_tariff_V8004</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V8033</xsl:element>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_service_for_tariff_V8004</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="$desiredDate"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">MOBILETARIFCHG</xsl:element>        
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_service_for_tariff_V8004</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">concat_add_additional_fee_service</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">V8004;Y;Y</xsl:element>
            <xsl:element name="service_characteristic_list"/>
          </xsl:element>
        </xsl:element>              
        
        <!-- add stp to the existing customer order -->
        <xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
          <xsl:element name="command_id">add_additional_fee_stp</xsl:element>
          <xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
            <xsl:element name="customer_order_id_ref">
              <xsl:element name="command_id">get_reconfigure_stp_data</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_ticket_pos_list">
              <!-- fee service, if applicable -->
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_additional_fee_service</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:element>         
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">concat_add_additional_fee_service</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">V8004;Y;Y</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Sign Order Form And Apply New Pricing Structure
          dependent apply is used, if an open customer order is found -->
        <xsl:element name="CcmFifSignAndApplyNewPricingStructCmd">
          <xsl:element name="command_id">sign_apply</xsl:element>
          <xsl:element name="CcmFifSignAndApplyNewPricingStructInCont">
            <xsl:element name="supported_object_id_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
            <xsl:element name="supported_object_type_rd">O</xsl:element>
            <xsl:element name="apply_swap_date">
              <xsl:value-of select="$desiredDate"/>
            </xsl:element>
            <xsl:element name="board_sign_name">ARCOR</xsl:element>
            <xsl:element name="board_sign_date_ref">
              <xsl:element name="command_id">get_reconfigure_stp_data</xsl:element>
              <xsl:element name="field_name">creation_date</xsl:element>
            </xsl:element>
            <xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
            <xsl:element name="primary_cust_sign_date_ref">
              <xsl:element name="command_id">get_reconfigure_stp_data</xsl:element>
              <xsl:element name="field_name">creation_date</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>      
        
        <xsl:element name="CcmFifConcatStringsCmd">
          <xsl:element name="command_id">concat_add_fee_service</xsl:element>
          <xsl:element name="CcmFifConcatStringsInCont">
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">get_new_tariff</xsl:element>
                <xsl:element name="field_name">pricing_structure_code</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">;</xsl:element>
              </xsl:element>							
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_service_for_tariff_V8004</xsl:element>
                <xsl:element name="field_name">service_found</xsl:element>							
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- add a fee service, if the mobile service is the only one with tariff V8004 -->
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_fee_service</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V8033</xsl:element>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="$desiredDate"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">MOBILETARIFCHG</xsl:element>        
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">concat_add_fee_service</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">V8004;N</xsl:element>
            <xsl:element name="service_characteristic_list"/>
          </xsl:element>
        </xsl:element>        
        
        <!-- add stp to the existing customer order -->
        <xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
          <xsl:element name="command_id">add_fee_stp</xsl:element>
          <xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
            <xsl:element name="customer_order_id_ref">
              <xsl:element name="command_id">get_reconfigure_stp_data</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_ticket_pos_list">
              <!-- fee service, if applicable -->
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_fee_service</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:element>         
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">concat_add_fee_service</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">V8004;N</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- release customer order -->
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="command_id">release_reconfigure_co</xsl:element>
          <xsl:element name="CcmFifReleaseCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">get_reconfigure_co_data</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- variable for contact text -->
        <xsl:variable name="contactText">
          <xsl:text>Der Arcor-Mobil-Tarifwechsel für Rufnummer </xsl:text>
          <xsl:value-of select="request-param[@name='Rufnummer;Mobilvorwahl']"/>
          <xsl:text>/</xsl:text>
          <xsl:value-of select="request-param[@name='Rufnummer;Mobilfunkrufnummer']"/>
          <xsl:text> wurde aktiviert.&#xA;Client: </xsl:text>
          <xsl:value-of select="request-param[@name='clientName']"/>
          <xsl:text>&#xA;TransactionID: </xsl:text>
          <xsl:value-of select="request-param[@name='transactionID']"/>
        </xsl:variable>
        
        <!-- create contact -->
        <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="command_id">create_contact</xsl:element>
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="contact_type_rd">MOBILETARIFCHG</xsl:element>
            <xsl:element name="short_description">Mobiltarifwechsel aktiviert</xsl:element>
            <xsl:element name="long_description_text">
              <xsl:value-of select="$contactText"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Create external notification -->
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_kba_notification</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="effective_date">
              <xsl:value-of select="dateutils:getCurrentDate()"/>
            </xsl:element>
            <xsl:element name="notification_action_name">createKBANotification</xsl:element>
            <xsl:element name="target_system">KBA</xsl:element>                           				
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>						
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_mobile_service</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TYPE</xsl:element>
                <xsl:element name="parameter_value">CONTACT</xsl:element>
              </xsl:element>           
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CATEGORY</xsl:element>
                <xsl:element name="parameter_value">Tariff</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">USER_NAME</xsl:element>
                <xsl:element name="parameter_value">FIF</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element>
                <xsl:element name="parameter_value">CCB</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">WORK_DATE</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="dateutils:getCurrentDate()"/>
                </xsl:element>
              </xsl:element>					
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TEXT</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="$contactText"/>
                </xsl:element>
              </xsl:element>					
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
      </xsl:if>
      
      <xsl:if test="request-param[@name='originalRequestResult'] != 'true'">
        
        <!-- cancel the customer order -->
        <xsl:element name="CcmFifCancelCustomerOrderCmd">
          <xsl:element name="command_id">cancel_reconfigure_co</xsl:element>
          <xsl:element name="CcmFifCancelCustomerOrderInCont">
            <xsl:element name="customer_order_id_ref">
              <xsl:element name="command_id">get_reconfigure_stp_data</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="cancel_reason_rd">CCM</xsl:element>          
          </xsl:element>
        </xsl:element>
        
        <!-- cancel the last contract version of the mobile phone contract -->
        <xsl:element name="CcmFifTransitionLegalAgreementCmd">
          <xsl:element name="command_id">cancel_tariff_change</xsl:element>
          <xsl:element name="CcmFifTransitionLegalAgreementInCont">
            <xsl:element name="contract_number_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
            <xsl:element name="state_rd">CANCELED</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <xsl:variable name="contactText">
          <xsl:text>Der Arcor-Mobil-Tarifwechsel für Rufnummer </xsl:text>
          <xsl:value-of select="request-param[@name='Rufnummer;Mobilvorwahl']"/>
          <xsl:text>/</xsl:text>
          <xsl:value-of select="request-param[@name='Rufnummer;Mobilfunkrufnummer']"/>
          <xsl:text> wurde storniert.&#xA;Client: </xsl:text>
          <xsl:value-of select="request-param[@name='clientName']"/>
          <xsl:text>&#xA;TransactionID: </xsl:text>
          <xsl:value-of select="request-param[@name='transactionID']"/>
          <xsl:text>&#xA;Fehlercode: </xsl:text>
          <xsl:value-of select="request-param[@name='originalRequestErrorCode']"/>
          <xsl:text>&#xA;Fehlermeldung: </xsl:text>
          <xsl:value-of select="request-param[@name='originalRequestErrorText']"/>
        </xsl:variable>
        
        <!-- create contact -->
        <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="command_id">create_contact</xsl:element>
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_mobile_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="contact_type_rd">MOBILETARIFCHG</xsl:element>
            <xsl:element name="short_description">Mobiltarifwechsel storniert</xsl:element>
            <xsl:element name="long_description_text">
              <xsl:value-of select="$contactText"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Create external notification -->
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_kba_notification</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="effective_date">
              <xsl:value-of select="dateutils:getCurrentDate()"/>
            </xsl:element>
            <xsl:element name="notification_action_name">createKBANotification</xsl:element>
            <xsl:element name="target_system">KBA</xsl:element>                           				
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>						
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_mobile_service</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TYPE</xsl:element>
                <xsl:element name="parameter_value">CONTACT</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CATEGORY</xsl:element>
                <xsl:element name="parameter_value">Tariff</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">USER_NAME</xsl:element>
                <xsl:element name="parameter_value">FIF</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element>
                <xsl:element name="parameter_value">CCB</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">WORK_DATE</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="dateutils:getCurrentDate()"/>
                </xsl:element>
              </xsl:element>					
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TEXT</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="$contactText"/>
                </xsl:element>
              </xsl:element>					
            </xsl:element>
          </xsl:element>
        </xsl:element>                  
        
      </xsl:if>
            
    </xsl:element>   
  </xsl:template>
</xsl:stylesheet>
