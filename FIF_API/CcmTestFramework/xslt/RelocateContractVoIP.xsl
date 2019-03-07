<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an relocate contract FIF request

  @author banania
-->

<!DOCTYPE XSL [
<!ENTITY TerminateService_VoIP SYSTEM "TerminateService_VoIP.xsl">
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
    <xsl:element name="client_name">KBA</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">
      <!-- Convert the termination date to OPM format -->
      <xsl:variable name="relocationDateOPM"
        select="dateutils:createOPMDate(request-param[@name='activationDate'])"/>
      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
      
      <xsl:variable name="terminationDateOPM"
        select="dateutils:createOPMDate(request-param[@name='activationDate'])"/>
  
      <xsl:variable name="NoticePeriodStartDate">
        <xsl:value-of select="request-param[@name='activationDate']"/>
      </xsl:variable>
        
      <xsl:variable name="TerminationDate">
        <xsl:value-of select="request-param[@name='activationDate']"/>
      </xsl:variable>
      
      <xsl:variable name="scenarioType">RELOCATION</xsl:variable>
      
      <xsl:variable name="ReasonRd">RELOCATION</xsl:variable>   

      <xsl:variable name="OrderVariant">                
        <xsl:value-of select="request-param[@name='relocationType']"/>       
      </xsl:variable> 

      <xsl:variable name="VoIPTermOrderVariant">                
        <xsl:value-of select="request-param[@name='relocationType']"/>       
      </xsl:variable> 
      
      <xsl:variable name="TerminationReason">UMZ</xsl:variable>    

      
      <xsl:if test="request-param[@name='relocationType'] = 'Umzug mit Rufnummernübernahme'                           
        and request-param[@name='numberOfNewAccessNumbers'] != '0'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">relocate_contract_error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">numberOfNewAccessNumbers must be set to '0' if no new access numbers are ordered!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <xsl:if test="request-param[@name='relocationType'] != 'Umzug mit Rufnummernübernahme'                               
        and request-param[@name='numberOfNewAccessNumbers'] = '0'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">relocate_contract_error_2</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">numberOfNewAccessNumbers can not be set to '0' if the relocationType is not 'Umzug mit Rufnummernübernahme'!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
            
      <!-- Find service Subs for given  service subscription id-->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">

          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='activationDate']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
  
      <!-- Find Product Code from Product Commitment -->
      <xsl:element name="CcmFifGetProductCommitmentDataCmd">
        <xsl:element name="command_id">get_pc_data_1</xsl:element>
        <xsl:element name="CcmFifGetProductCommitmentDataInCont">
          <xsl:element name="product_commitment_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Validate Product Code -->
      <xsl:element name="CcmFifValidateValueCmd">
        <xsl:element name="command_id">validate_value_1</xsl:element>
        <xsl:element name="CcmFifValidateValueInCont">
          <xsl:element name="value_ref">
            <xsl:element name="command_id">get_pc_data_1</xsl:element>
            <xsl:element name="field_name">product_code</xsl:element>
          </xsl:element>
          <xsl:element name="object_type">PRODUCT_COMMITMENT_NUMBER</xsl:element>
          <xsl:element name="value_type">PRODUCT_CODE</xsl:element>
          <xsl:element name="allowed_values">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:value-of select="request-param[@name='productCode']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- find directory entry stp -->
      <xsl:element name="CcmFifFindServiceTicketPositionCmd">
        <xsl:element name="command_id">find_directory_entry</xsl:element>
        <xsl:element name="CcmFifFindServiceTicketPositionInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>            
          </xsl:element>
          <xsl:element name="no_stp_error">N</xsl:element>
          <xsl:element name="find_stp_parameters">
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">V0100</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">RELEASED</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- get data from STP -->
      <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
        <xsl:element name="command_id">get_directory_entry_stp_data</xsl:element>
        <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_directory_entry</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_directory_entry</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>							
      
      <!-- cancel the service in OPM -->
      <xsl:element name="CcmFifCancelCustomerOrderCmd">
        <xsl:element name="command_id">cancel_directory_entry</xsl:element>
        <xsl:element name="CcmFifCancelCustomerOrderInCont">
          <xsl:element name="customer_order_id_ref">
            <xsl:element name="command_id">get_directory_entry_stp_data</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>            
          </xsl:element>
          <xsl:element name="cancel_reason_rd">UMZ</xsl:element>
          <xsl:element name="cancel_opm_order_ind">Y</xsl:element>
          <xsl:element name="skip_already_processed">Y</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_directory_entry</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>							
          </xsl:element>          
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- do not raise an error if no relased STP found or if OPM order does not exists but OP internal order has been successfully rejected -->            
      <xsl:element name="CcmFifMapStringCmd">
        <xsl:element name="command_id">map_raise_error</xsl:element>
        <xsl:element name="CcmFifMapStringInCont">
          <xsl:element name="input_string_type">[Y,N]_[Y,N,]</xsl:element>
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_directory_entry</xsl:element>
                <xsl:element name="field_name">stp_found</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">_</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">cancel_directory_entry</xsl:element>
                <xsl:element name="field_name">op_order_rejected_ind</xsl:element>							
              </xsl:element>
            </xsl:element>
          <xsl:element name="output_string_type">[Y,N]</xsl:element>
          <xsl:element name="string_mapping_list">
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">Y_N</xsl:element>
              <xsl:element name="output_string">Y</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">Y_</xsl:element>
              <xsl:element name="output_string">Y</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="no_mapping_error">N</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- raise error to initiate functional recycling -->      
      <xsl:element name="CcmFifRaiseErrorCmd">
        <xsl:element name="command_id">raise_error_func_recycle</xsl:element>
        <xsl:element name="CcmFifRaiseErrorInCont">
          <xsl:element name="error_text">IT-22324: TBE-Stornierung in Arbeit, Request muss morgen wieder ausgeführt werden.</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_raise_error</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>          
          <xsl:element name="required_process_ind">Y</xsl:element>          
        </xsl:element>
      </xsl:element>     
      
      <!-- Ensure that the relocation has not been performed before -->
      <xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
        <xsl:element name="command_id">find_cancel_stp_1</xsl:element>
        <xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="reason_rd">RELOCATION</xsl:element>
        </xsl:element>
      </xsl:element>


      <!-- Get Entity Information -->
      <xsl:element name="CcmFifGetEntityCmd">
        <xsl:element name="command_id">get_entity_1</xsl:element>
        <xsl:element name="CcmFifGetEntityInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Location Address -->
      <xsl:element name="CcmFifCreateAddressCmd">
        <xsl:element name="command_id">create_addr_1</xsl:element>
        <xsl:element name="CcmFifCreateAddressInCont">
          <xsl:element name="entity_ref">
            <xsl:element name="command_id">get_entity_1</xsl:element>
            <xsl:element name="field_name">entity_id</xsl:element>
          </xsl:element>
          <xsl:element name="address_type">LOKA</xsl:element>
          <xsl:element name="street_name">
            <xsl:value-of select="request-param[@name='newStreet']"/>
          </xsl:element>
          <xsl:element name="street_number">
            <xsl:value-of select="request-param[@name='newNumber']"/>
          </xsl:element>
          <xsl:element name="street_number_suffix">
            <xsl:value-of select="request-param[@name='newNumberSuffix']"/>
          </xsl:element>
          <xsl:element name="postal_code">
            <xsl:value-of select="request-param[@name='newPostalCode']"/>
          </xsl:element>
          <xsl:element name="city_name">
            <xsl:value-of select="request-param[@name='newCity']"/>
          </xsl:element>
          <xsl:element name="city_suffix_name">
            <xsl:value-of select="request-param[@name='newCitySuffix']"/>
          </xsl:element>
          <xsl:element name="country_code">DE</xsl:element>
        </xsl:element>
      </xsl:element>

      
      <!-- Clone Order Form -->
      <xsl:element name="CcmFifCloneOrderFormCmd">
        <xsl:element name="command_id">clone_order_form_1</xsl:element>
        <xsl:element name="CcmFifCloneOrderFormInCont">
          <xsl:element name="scenario_type">
            <xsl:value-of select="$scenarioType"/>
          </xsl:element>
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="sales_org_num_value">
            <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
          </xsl:element> 
          <xsl:element name="sales_org_num_value_vf">
            <xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
          </xsl:element> 
          <xsl:element name="target_product_code">
            <xsl:value-of select="request-param[@name='productCode']"/>
          </xsl:element>                             
          <xsl:element name="target_pricing_structure_code">
            <xsl:value-of select="request-param[@name='tariff']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="$ReasonRd"/>
          </xsl:element>  
          <xsl:if test="request-param[@name='relocationType'] = 'Umzug mit Rufnummernübernahme'">
            <xsl:element name="copy_dep_chars">Y</xsl:element>  
          </xsl:if>             
          <xsl:element name="board_sign_name">
            <xsl:value-of select="request-param[@name='boardSignName']"/>
          </xsl:element>
          <xsl:element name="primary_cust_sign_name">
            <xsl:value-of select="request-param[@name='primaryCustSignName']"/>
          </xsl:element> 
          <xsl:element name="min_per_dur_value">
            <xsl:value-of select="request-param[@name='minPeriodDurationValue']"/>
          </xsl:element>
          <xsl:element name="min_per_dur_unit">
            <xsl:value-of select="request-param[@name='minPeriodDurationUnit']"/>
          </xsl:element> 
          <xsl:element name="address_ref">
            <xsl:element name="command_id">create_addr_1</xsl:element>
            <xsl:element name="field_name">address_id</xsl:element>
          </xsl:element>  
          <xsl:element name="auto_extent_period_value">
            <xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>
          </xsl:element>                         
          <xsl:element name="auto_extent_period_unit">
            <xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>
          </xsl:element>                         
          <xsl:element name="auto_extension_ind">
            <xsl:value-of select="request-param[@name='autoExtensionInd']"/>
          </xsl:element>   
          <xsl:element name="target_product_type">Premium</xsl:element>  
          <xsl:if test="count(request-param-list[@name='featureServiceList']/request-param-list-item) != 0">
            <xsl:element name="service_code_list">
              <!-- Pass in the list of service codes -->
              <xsl:for-each
                select="request-param-list[@name='featureServiceList']/request-param-list-item">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="service_code">
                    <xsl:value-of select="request-param"/>
                  </xsl:element>
                </xsl:element>
              </xsl:for-each>
            </xsl:element>
          </xsl:if>
          <xsl:element name="service_characteristic_list">
            <!-- New location -->
            <xsl:element name="CcmFifAddressCharacteristicCont">
              <xsl:element name="service_char_code">V0014</xsl:element>
              <xsl:element name="data_type">ADDRESS</xsl:element>
              <xsl:element name="address_ref">
                <xsl:element name="command_id">create_addr_1</xsl:element>
                <xsl:element name="field_name">address_id</xsl:element>
              </xsl:element>
            </xsl:element>              
            <!-- Aktivierungsdatum-->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$relocationDateOPM"/>
              </xsl:element>
            </xsl:element>             
            <!-- Order variant -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">VI008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$OrderVariant"/>
              </xsl:element>
            </xsl:element>  
            <!-- Anzahl der neue Rufnummern -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0936</xsl:element>
              <xsl:element name="data_type">INTEGER</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='numberOfNewAccessNumbers']"/>
              </xsl:element>
            </xsl:element>          
            <!-- Bearbeitungsart -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">VI002</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">OP</xsl:element>
            </xsl:element>
            <!-- Bundle Kennzeichen -->   
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">VI047</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">Standalone</xsl:element>
              </xsl:element>      
            <!-- Technologieflag -->   
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">VI048</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">NGN</xsl:element>
            </xsl:element>  
          </xsl:element>
          <xsl:element name="suppress_directory_entry">
            <xsl:value-of select="request-param[@name='suppressDirectoryEntry']"/>
          </xsl:element>   
        </xsl:element>
      </xsl:element>
      
      
      <!-- Find the service VI202 (Monatspreis)-->
      <xsl:element name="CcmFifFindExclusiveChildServSubsCmd">
        <xsl:element name="command_id">find_monthly_charge_service_1</xsl:element>
        <xsl:element name="CcmFifFindExclusiveChildServSubsInCont">
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">clone_order_form_1</xsl:element>
            <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">VI220</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    
      <!-- Add Voice over IP  Service VI220 if not found  -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_monthly_charge_service_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">clone_order_form_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">VI220</xsl:element>
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">clone_order_form_1</xsl:element>
            <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
          </xsl:element> 
          <xsl:element name="desired_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="$ReasonRd"/>
          </xsl:element>          
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>  
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_monthly_charge_service_1</xsl:element>
            <xsl:element name="field_name">service_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>      
          <xsl:element name="service_characteristic_list">           
            <!-- Monatspreis VoIP --> 
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">VI025</xsl:element>
              <xsl:element name="data_type">DECIMAL</xsl:element>
              <xsl:element name="configured_value"></xsl:element>
            </xsl:element>             
          </xsl:element>
        </xsl:element>
      </xsl:element>
 
      <!-- look for a VoIP bundle (item) -->
      <xsl:element name="CcmFifFindBundleCmd">
        <xsl:element name="command_id">find_bundle_1</xsl:element>
        <xsl:element name="CcmFifFindBundleInCont">
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- add the new  bundle item if a bundle is found -->
      <xsl:element name="CcmFifModifyBundleItemCmd">
        <xsl:element name="command_id">modify_bundle_item_1</xsl:element>
        <xsl:element name="CcmFifModifyBundleItemInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>
          <xsl:element name="bundle_item_type_rd">VOIP_SERVICE</xsl:element>
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">clone_order_form_1</xsl:element>
            <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
          <xsl:element name="action_name">ADD</xsl:element>
        </xsl:element>
      </xsl:element>
             
      <!-- Create Customer Orders for Cloning of Services -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="sales_rep_dept_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
          <xsl:element name="provider_tracking_no">003v</xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">clone_order_form_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>   
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_monthly_charge_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

        <!-- Create Customer Order for Directory Entry -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_2</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>         
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="sales_rep_dept_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
          <xsl:element name="provider_tracking_no">003vt</xsl:element>
          <xsl:element name="ignore_empty_list_ind">Y</xsl:element> 
          <xsl:element name="service_ticket_pos_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">clone_order_form_1</xsl:element>
                <xsl:element name="field_name">directory_entry_stp_list</xsl:element>
              </xsl:element>                          
          </xsl:element>
        </xsl:element>
      </xsl:element>
  
 
    <!-- Release Customer Order for  VoIP 2 Line -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>     

    <!-- Release Customer Order for  Directory Entry -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_2</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
          <xsl:element name="parent_customer_order_id_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>          	
          </xsl:element>          
        </xsl:element>
      </xsl:element>

 
      <!-- Terminate the VoIP Product -->   
      &TerminateService_VoIP;
      
      <!-- Write the main access service to the external Notification -->   
      <xsl:element name="CcmFifCreateExternalNotificationCmd">
        <xsl:element name="command_id">create_notification_1</xsl:element>
        <xsl:element name="CcmFifCreateExternalNotificationInCont">
          <xsl:element name="effective_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="transaction_id">
            <xsl:value-of select="request-param[@name='requestListId']"/>
          </xsl:element>
          <xsl:element name="processed_indicator">Y</xsl:element>
          <xsl:element name="notification_action_name">RelocateContractVoIP</xsl:element>
          <xsl:element name="target_system">FIF</xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
               <xsl:element name="parameter_name">VoIP_SERVICE_SUBSCRIPTION_ID</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">clone_order_form_1</xsl:element>
                <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
              </xsl:element>
            </xsl:element> 
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">VoIP_DETAILED_REASON_RD</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">clone_order_form_1</xsl:element>
                <xsl:element name="field_name">detailed_reason_rd</xsl:element>
              </xsl:element>
            </xsl:element>                      							  
          </xsl:element>        
        </xsl:element>
      </xsl:element>
      
      <!-- Create Contact for the Service relocation -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">AUTO_RELOCATION</xsl:element>
          <xsl:element name="short_description">Automatischer Umzug</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;ContractNumber: </xsl:text>
            <xsl:value-of select="request-param[@name='contractNumber']"/>
            <xsl:text>&#xA;User Name: </xsl:text>
            <xsl:value-of select="request-param[@name='userName']"/>
            <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
            <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>  
 
    </xsl:element>

  </xsl:template>
</xsl:stylesheet>
