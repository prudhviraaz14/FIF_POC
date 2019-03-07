<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for setting the invoice delivery type

  @author schwarje
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>

  <xsl:template match="/">
    <xsl:element name="CcmFifCommandList">
      <xsl:apply-templates select="request/request-params"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="request-params">
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

      <!-- Convert the desired date to OPM format -->
      <xsl:variable name="desiredDateOPM"  select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>      
      
      <!-- look for the service subscription, that KBA provided -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>										
      
      <!-- find STP -->
      <xsl:element name="CcmFifFindServiceTicketPositionCmd">
        <xsl:element name="command_id">find_stp</xsl:element>
        <xsl:element name="CcmFifFindServiceTicketPositionInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="usage_mode_value_rd">1</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifMapStringCmd">
        <xsl:element name="command_id">map_porting_type</xsl:element>
        <xsl:element name="CcmFifMapStringInCont">
          <xsl:element name="input_string_type">ServiceCode</xsl:element>
          <xsl:element name="input_string_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>
          </xsl:element>
          <xsl:element name="output_string_type">PortingType</xsl:element>
          <xsl:element name="string_mapping_list">
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">V0003</xsl:element>
              <xsl:element name="output_string">Portierung mit Neuauftrag</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">V0010</xsl:element>
              <xsl:element name="output_string">Portierung mit Neuauftrag</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">V0011</xsl:element>
              <xsl:element name="output_string">Portierung mit Neuauftrag</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">V8000</xsl:element>
              <xsl:element name="output_string">Portierung ohne Neuauftrag</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">I1043</xsl:element>
              <xsl:element name="output_string">Portierung mit Neuauftrag</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">I1210</xsl:element>
              <xsl:element name="output_string">Portierung mit Neuauftrag</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">I1213</xsl:element>
              <xsl:element name="output_string">Portierung mit Neuauftrag</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="no_mapping_error">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:if test="request-param[@name='tariff'] = 'V8004'">
        <!-- check for a service for this tariff for determining the value for characteristic V8001 -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_for_tariff</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="product_code">V8000</xsl:element>
            <xsl:element name="pricing_structure_code">V8004</xsl:element>
            <xsl:element name="service_code">V8000</xsl:element>
            <xsl:element name="no_service_error">N</xsl:element>
            <xsl:element name="target_contract_state">SIGNED</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">map_porting_type</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>							
            </xsl:element>
            <xsl:element name="required_process_ind">Portierung mit Neuauftrag</xsl:element>            
          </xsl:element>
        </xsl:element>        
      </xsl:if>
      
      <!-- Create Order Form-->
      <xsl:element name="CcmFifCreateOrderFormCmd">
        <xsl:element name="command_id">create_mobile_contract</xsl:element>
        <xsl:element name="CcmFifCreateOrderFormInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="min_per_dur_value">24</xsl:element>
          <xsl:element name="min_per_dur_unit">MONTH</xsl:element>
          <xsl:element name="sales_org_num_value">
            <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
          </xsl:element>
          <xsl:element name="doc_template_name">Vertrag</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_porting_type</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Portierung mit Neuauftrag</xsl:element>
        </xsl:element>
      </xsl:element>
           
      <!-- Add Order Form Product Commitment -->
      <xsl:element name="CcmFifAddProductCommitCmd">
        <xsl:element name="command_id">add_mobile_pc</xsl:element>
        <xsl:element name="CcmFifAddProductCommitInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">create_mobile_contract</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <xsl:element name="product_code">V8000</xsl:element>
          <xsl:element name="pricing_structure_code">
            <xsl:value-of select="request-param[@name='tariff']"/>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_porting_type</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Portierung mit Neuauftrag</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Sign Order Form -->
      <xsl:element name="CcmFifSignOrderFormCmd">
        <xsl:element name="command_id">sign_mobile_contract</xsl:element>
        <xsl:element name="CcmFifSignOrderFormInCont">
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">create_mobile_contract</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <xsl:element name="board_sign_name">Arcor</xsl:element>
          <xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_porting_type</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Portierung mit Neuauftrag</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Add Product Subscription -->
      <xsl:element name="CcmFifAddProductSubsCmd">
        <xsl:element name="command_id">add_mobile_ps</xsl:element>
        <xsl:element name="CcmFifAddProductSubsInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="product_commitment_number_ref">
            <xsl:element name="command_id">add_mobile_pc</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_porting_type</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Portierung mit Neuauftrag</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Add Product Subscription -->
      <xsl:element name="CcmFifAddProductSubsCmd">
        <xsl:element name="command_id">add_mobile_ps</xsl:element>
        <xsl:element name="CcmFifAddProductSubsInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="product_commitment_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_porting_type</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Portierung ohne Neuauftrag</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- get access number data -->
      <xsl:element name="CcmFifFindServCharValueForServCharCmd">
        <xsl:element name="command_id">get_access_number_data</xsl:element>
        <xsl:element name="CcmFifFindServCharValueForServCharInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_stp</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_char_code">V0001</xsl:element>
          <xsl:element name="no_csc_error">N</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">V0010</xsl:element>
        </xsl:element>
      </xsl:element>							
      
      <!-- get access number data -->
      <xsl:element name="CcmFifFindServCharValueForServCharCmd">
        <xsl:element name="command_id">get_access_number_data</xsl:element>
        <xsl:element name="CcmFifFindServCharValueForServCharInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_stp</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_char_code">V0001</xsl:element>
          <xsl:element name="no_csc_error">N</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">V0003</xsl:element>
        </xsl:element>
      </xsl:element>							
      
      <!-- get access number data -->
      <xsl:element name="CcmFifFindServCharValueForServCharCmd">
        <xsl:element name="command_id">get_access_number_data</xsl:element>
        <xsl:element name="CcmFifFindServCharValueForServCharInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_stp</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_char_code">V0002</xsl:element>
          <xsl:element name="no_csc_error">N</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">V0011</xsl:element>
        </xsl:element>
      </xsl:element>							
      
      <!-- get access number data -->
      <xsl:element name="CcmFifFindServCharValueForServCharCmd">
        <xsl:element name="command_id">get_access_number_data</xsl:element>
        <xsl:element name="CcmFifFindServCharValueForServCharInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_stp</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_char_code">V0001</xsl:element>
          <xsl:element name="no_csc_error">N</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">I1043</xsl:element>
        </xsl:element>
      </xsl:element>							
      
      <!-- get access number data -->
      <xsl:element name="CcmFifFindServCharValueForServCharCmd">
        <xsl:element name="command_id">get_access_number_data</xsl:element>
        <xsl:element name="CcmFifFindServCharValueForServCharInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_stp</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_char_code">V0180</xsl:element>
          <xsl:element name="no_csc_error">N</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">V8000</xsl:element>
        </xsl:element>
      </xsl:element>							      
      
      <!-- get article number -->
      <xsl:element name="CcmFifFindServCharValueForServCharCmd">
        <xsl:element name="command_id">get_article_number</xsl:element>
        <xsl:element name="CcmFifFindServCharValueForServCharInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_stp</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_char_code">V0178</xsl:element>
          <xsl:element name="no_csc_error">N</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_porting_type</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Portierung ohne Neuauftrag</xsl:element>
        </xsl:element>
      </xsl:element>							
      
      <!-- Add Mobile Phone main Service V8000 -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_mobile_service</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_mobile_ps</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V8000</xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">CREATE_MOBILE</xsl:element>        
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_porting_type</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Portierung mit Neuauftrag</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Rufnummer -->
            <xsl:element name="CcmFifAccessNumberCont">
              <xsl:element name="service_char_code">V0180</xsl:element>
              <xsl:element name="data_type">MOBIL_ACCESS_NUM</xsl:element>
              <xsl:element name="masking_digits_rd_ref">
                <xsl:element name="command_id">get_access_number_data</xsl:element>
                <xsl:element name="field_name">masking_digits_rd</xsl:element>								
              </xsl:element>
              <xsl:element name="retention_period_rd_ref">
                <xsl:element name="command_id">get_access_number_data</xsl:element>
                <xsl:element name="field_name">retention_period_rd</xsl:element>								
              </xsl:element>
              <xsl:element name="storage_masking_digits_rd_ref">
                <xsl:element name="command_id">get_access_number_data</xsl:element>
                <xsl:element name="field_name">storage_masking_digits_rd</xsl:element>								
              </xsl:element>
              <xsl:element name="validate_duplicate_indicator">Y</xsl:element>
              <xsl:element name="country_code">
                <xsl:value-of select="substring-before(request-param[@name='portedAccessNumber'], ';')"/>
              </xsl:element>
              <xsl:element name="city_code">
                <xsl:value-of select="substring-before(substring-after(request-param[@name='portedAccessNumber'], ';'), ';')"/>
              </xsl:element>
              <xsl:element name="local_number">
                <xsl:value-of select="substring-after(substring-after(request-param[@name='portedAccessNumber'], ';'), ';')"/>
              </xsl:element>
            </xsl:element>										
            <!-- Artikelnummer -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0178</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='articleNumber']"/>
              </xsl:element>
            </xsl:element>
            <!-- SIM-Karte Portierung -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0181</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value_ref">
                <xsl:element name="command_id">map_porting_type</xsl:element>
                <xsl:element name="field_name">output_string</xsl:element>								
              </xsl:element>
            </xsl:element>
            <!-- Aktivierungsdatum-->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$desiredDateOPM"/>
              </xsl:element>
            </xsl:element>
            <!-- Aktivierung SIM-Karte -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V8002</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Ja</xsl:element>
            </xsl:element>            
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Add Mobile Phone main Service V8000 -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_mobile_service</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_mobile_ps</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V8000</xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">PORT_MOBILE</xsl:element>        
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_porting_type</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Portierung ohne Neuauftrag</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Rufnummer -->
            <xsl:element name="CcmFifAccessNumberCont">
              <xsl:element name="service_char_code">V0180</xsl:element>
              <xsl:element name="data_type">MOBIL_ACCESS_NUM</xsl:element>
              <xsl:element name="masking_digits_rd_ref">
                <xsl:element name="command_id">get_access_number_data</xsl:element>
                <xsl:element name="field_name">masking_digits_rd</xsl:element>								
              </xsl:element>
              <xsl:element name="retention_period_rd_ref">
                <xsl:element name="command_id">get_access_number_data</xsl:element>
                <xsl:element name="field_name">retention_period_rd</xsl:element>								
              </xsl:element>
              <xsl:element name="storage_masking_digits_rd_ref">
                <xsl:element name="command_id">get_access_number_data</xsl:element>
                <xsl:element name="field_name">storage_masking_digits_rd</xsl:element>								
              </xsl:element>
              <xsl:element name="validate_duplicate_indicator">Y</xsl:element>
              <xsl:element name="country_code">
                <xsl:value-of select="substring-before(request-param[@name='portedAccessNumber'], ';')"/>
              </xsl:element>
              <xsl:element name="city_code">
                <xsl:value-of select="substring-before(substring-after(request-param[@name='portedAccessNumber'], ';'), ';')"/>
              </xsl:element>
              <xsl:element name="local_number">
                <xsl:value-of select="substring-after(substring-after(request-param[@name='portedAccessNumber'], ';'), ';')"/>
              </xsl:element>
            </xsl:element>										
            <!-- Artikelnummer -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0178</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value_ref">
                <xsl:element name="command_id">get_article_number</xsl:element>
                <xsl:element name="field_name">characteristic_value</xsl:element>								                
              </xsl:element>
            </xsl:element>
            <!-- SIM-Karte Portierung -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0181</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value_ref">
                <xsl:element name="command_id">map_porting_type</xsl:element>
                <xsl:element name="field_name">output_string</xsl:element>								
              </xsl:element>
            </xsl:element>
            <!-- Aktivierungsdatum-->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$desiredDateOPM"/>
              </xsl:element>
            </xsl:element>
            <!-- Aktivierung SIM-Karte -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V8002</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Ja</xsl:element>
            </xsl:element>                        
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- check if tariff option exists -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_option</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="product_subscription_id_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V8032</xsl:element>
          <xsl:element name="no_service_error">N</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_porting_type</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Portierung ohne Neuauftrag</xsl:element>
        </xsl:element>
      </xsl:element>										

      <!-- add option, if it existed for the original product subscription -->      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_option</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_mobile_ps</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V8032</xsl:element>
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">add_mobile_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">PORT_MOBILE</xsl:element>        
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_option</xsl:element>
            <xsl:element name="field_name">service_found</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
          <xsl:element name="service_characteristic_list"/>
        </xsl:element>
      </xsl:element>
            
      <!-- Add contributing item for tariff option -->
      <xsl:element name="CcmFifAddModifyContributingItemCmd">
        <xsl:element name="CcmFifAddModifyContributingItemInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_mobile_ps</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V8032</xsl:element>
          <xsl:element name="contributing_item_list">
            <xsl:element name="CcmFifContributingItem">
              <xsl:element name="supported_object_type_rd">SERVICE_SUBSC</xsl:element>
              <xsl:element name="start_date">
                <xsl:value-of select="$today"/>
              </xsl:element>              
              <xsl:element name="service_subscription_ref">
                <xsl:element name="command_id">add_mobile_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_option</xsl:element>
            <xsl:element name="field_name">service_found</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- check if tariff option exists -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_option_2</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="product_subscription_id_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V8037</xsl:element>
          <xsl:element name="no_service_error">N</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_porting_type</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Portierung ohne Neuauftrag</xsl:element>
        </xsl:element>
      </xsl:element>										
      
      <!-- add option, if it existed for the original product subscription -->      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_option_2</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_mobile_ps</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V8037</xsl:element>
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">add_mobile_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">PORT_MOBILE</xsl:element>        
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_option_2</xsl:element>
            <xsl:element name="field_name">service_found</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
          <xsl:element name="service_characteristic_list"/>
        </xsl:element>
      </xsl:element>
      
      <!-- Add contributing item for tariff option -->
      <xsl:element name="CcmFifAddModifyContributingItemCmd">
        <xsl:element name="CcmFifAddModifyContributingItemInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_mobile_ps</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V8037</xsl:element>
          <xsl:element name="contributing_item_list">
            <xsl:element name="CcmFifContributingItem">
              <xsl:element name="supported_object_type_rd">SERVICE_SUBSC</xsl:element>
              <xsl:element name="start_date">
                <xsl:value-of select="$today"/>
              </xsl:element>              
              <xsl:element name="service_subscription_ref">
                <xsl:element name="command_id">add_mobile_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_option_2</xsl:element>
            <xsl:element name="field_name">service_found</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- check if service for monthly fee exists -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_fee_service</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="product_subscription_id_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V8033</xsl:element>
          <xsl:element name="no_service_error">N</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_porting_type</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Portierung ohne Neuauftrag</xsl:element>
        </xsl:element>
      </xsl:element>										
            
      <!-- add option, if it existed for the original product subscription -->      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_fee_service</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_mobile_ps</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V8033</xsl:element>
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">add_mobile_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">PORT_MOBILE</xsl:element>        
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_fee_service</xsl:element>
            <xsl:element name="field_name">service_found</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
          <xsl:element name="service_characteristic_list"/>
        </xsl:element>
      </xsl:element>
      
      <xsl:if test="request-param[@name='tariff'] = 'V8004'">
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_fee_service</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">add_mobile_ps</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V8033</xsl:element>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_mobile_service</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">CREATE_MOBILE</xsl:element>        
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_service</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_service_for_tariff</xsl:element>
              <xsl:element name="field_name">service_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>
            <xsl:element name="service_characteristic_list"/>
          </xsl:element>
        </xsl:element>
      </xsl:if>      
      
      <!-- find bundle for service, if exists -->
      <xsl:element name="CcmFifFindBundleCmd">
        <xsl:element name="command_id">find_bundle</xsl:element>
        <xsl:element name="CcmFifFindBundleInCont">
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- add the new bundle item of type --> 
      <xsl:element name="CcmFifModifyBundleItemCmd">
        <xsl:element name="command_id">add_mobile_service_bi</xsl:element>
        <xsl:element name="CcmFifModifyBundleItemInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">find_bundle</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>
          <xsl:element name="bundle_item_type_rd">MOBILE_SERVICE</xsl:element>
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">add_mobile_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
          <xsl:element name="action_name">ADD</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>			
      
      <!-- Create Customer Order for new services  -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="provider_tracking_no">001m</xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <!-- mobile service -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_mobile_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <!-- option service, if applicable -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_option</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_option_2</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <!-- fee service, if applicable -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_fee_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>         
        </xsl:element>
      </xsl:element>

      <!-- create contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="command_id">create_contact</xsl:element>
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">PORT_MOBILE</xsl:element>
          <xsl:element name="short_description">Mobilportierung angelegt</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>Auftrag zur Mobilrufnummerportierung wurde über </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
            <xsl:text> angelegt.&#xA;TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;Rufnummer: </xsl:text>
            <xsl:value-of select="request-param[@name='portedAccessNumber']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

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
          <xsl:element name="notification_action_name">Inporting</xsl:element>
          <xsl:element name="target_system">FIF</xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Mobile_SERVICE_SUBSCRIPTION_ID</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">add_mobile_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
            </xsl:element>          							  
          </xsl:element>        
        </xsl:element>
      </xsl:element>
      
      <!-- get entity for customer -->        
      <xsl:element name="CcmFifGetEntityCmd">
        <xsl:element name="command_id">get_entity</xsl:element>
        <xsl:element name="CcmFifGetEntityInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- create hardware address -->
      <xsl:if test="request-param[@name='hardwareDeliverySurname'] != ''
        and request-param[@name='hardwareDeliveryAddressId'] = ''">
        <!-- create the address -->
        <xsl:element name="CcmFifCreateAddressCmd">
          <xsl:element name="command_id">create_hardware_address</xsl:element>
          <xsl:element name="CcmFifCreateAddressInCont">
            <xsl:element name="entity_ref">
              <xsl:element name="command_id">get_entity</xsl:element>
              <xsl:element name="field_name">entity_id</xsl:element>
            </xsl:element>
            <xsl:element name="address_type">HARD</xsl:element>
            <xsl:element name="street_name">
              <xsl:value-of select="request-param[@name='hardwareDeliveryStreet']"/>
            </xsl:element>
            <xsl:element name="street_number">
              <xsl:value-of select="request-param[@name='hardwareDeliveryNumber']"/>
            </xsl:element>
            <xsl:element name="street_number_suffix">
              <xsl:value-of select="request-param[@name='hardwareDeliveryNumberSuffix']"/>
            </xsl:element>
            <xsl:element name="postal_code">
              <xsl:value-of select="request-param[@name='hardwareDeliveryPostalCode']"/>
            </xsl:element>
            <xsl:element name="city_name">
              <xsl:value-of select="request-param[@name='hardwareDeliveryCity']"/>
            </xsl:element>
            <xsl:element name="city_suffix_name">
              <xsl:value-of select="request-param[@name='hardwareDeliveryCitySuffix']"/>
            </xsl:element>
            <xsl:element name="country_code">DE</xsl:element>
          </xsl:element>
        </xsl:element>
                
        <!-- get address data from the new address -->
        <xsl:element name="CcmFifGetAddressDataCmd">
          <xsl:element name="command_id">get_address_data</xsl:element>
          <xsl:element name="CcmFifGetAddressDataInCont">
            <xsl:element name="address_id_ref">
              <xsl:element name="command_id">create_hardware_address</xsl:element>
              <xsl:element name="field_name">address_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>        
      </xsl:if>

      <!-- get the address data from the id, if one was provided -->
      <xsl:if test="request-param[@name='hardwareDeliverySurname'] = ''
        and request-param[@name='hardwareDeliveryAddressId'] != ''">
        <xsl:element name="CcmFifGetAddressDataCmd">
          <xsl:element name="command_id">get_address_data</xsl:element>
          <xsl:element name="CcmFifGetAddressDataInCont">
            <xsl:element name="address_id">
              <xsl:value-of select="request-param[@name='hardwareDeliveryAddressId']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>        

      <!-- get the primary address, if nothing else was provided -->
      <xsl:if test="request-param[@name='hardwareDeliverySurname'] = ''
        and request-param[@name='hardwareDeliveryAddressId'] = ''">
        <xsl:element name="CcmFifGetAddressDataCmd">
          <xsl:element name="command_id">get_address_data</xsl:element>
          <xsl:element name="CcmFifGetAddressDataInCont">
            <xsl:element name="address_id_ref">
              <xsl:element name="command_id">get_entity</xsl:element>
              <xsl:element name="field_name">primary_address_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- get article number from the newly created service -->
      <xsl:element name="CcmFifFindServCharValueForServCharCmd">
        <xsl:element name="command_id">get_new_article_number</xsl:element>
        <xsl:element name="CcmFifFindServCharValueForServCharInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">add_mobile_service</xsl:element>
            <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_char_code">V0178</xsl:element>
          <xsl:element name="no_csc_error">N</xsl:element>
        </xsl:element>
      </xsl:element>							
            
      <!-- Find service -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_contract</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">add_mobile_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>      
      
      <!-- Get PC data for sales org number -->
      <xsl:element name="CcmFifGetCommissioningInformationDataCmd">
        <xsl:element name="command_id">get_sales_org_number</xsl:element>
        <xsl:element name="CcmFifGetCommissioningInformationDataInCont">
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">find_contract</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">O</xsl:element>
          <xsl:element name="no_sales_org_number_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Get PC data for sales org number -->
      <xsl:element name="CcmFifGetProductCommitmentDataCmd">
        <xsl:element name="command_id">get_tariff</xsl:element>
        <xsl:element name="CcmFifGetProductCommitmentDataInCont">
          <xsl:element name="product_commitment_number_ref">
            <xsl:element name="command_id">find_contract</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- call the bus for individual customers -->
      <xsl:element name="CcmFifProcessServiceBusRequestCmd">
        <xsl:element name="command_id">call_aip</xsl:element>
        <xsl:element name="CcmFifProcessServiceBusRequestInCont">
          <xsl:element name="package_name">net.arcor.aip.epsm_aip_starteeingehenderufnummerportierung_001</xsl:element>
          <xsl:element name="service_name">StarteEingehendeRufnummerPortierung</xsl:element>
          <xsl:element name="synch_ind">N</xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">PortierteRufnummer;Mobilvorwahl</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:text>0</xsl:text>
                <xsl:value-of select="substring-before(substring-after(request-param[@name='portedAccessNumber'], ';'), ';')"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">PortierteRufnummer;Mobilfunkrufnummer</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="substring-after(substring-after(request-param[@name='portedAccessNumber'], ';'), ';')"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">VorigerServiceProvider</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='serviceProvider']"/>
              </xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='asapIndicator'] != 'Y'">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">WunschPortierungsdatum</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='desiredDate']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TarifOption</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_tariff</xsl:element>
                <xsl:element name="field_name">pricing_structure_code</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Vonumber</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_sales_org_number</xsl:element>
                <xsl:element name="field_name">sales_org_number</xsl:element>
              </xsl:element>
            </xsl:element>            
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TechnUser</xsl:element>
              <xsl:element name="parameter_value">FIF</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;NatPerson;Adresse;Strasse</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_address_data</xsl:element>
                <xsl:element name="field_name">street_name</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;NatPerson;Adresse;Hausnummer</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_address_data</xsl:element>
                <xsl:element name="field_name">street_number</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;NatPerson;Adresse;Hausnummerzusatz</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_address_data</xsl:element>
                <xsl:element name="field_name">street_number_suffix</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;NatPerson;Adresse;PLZ</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_address_data</xsl:element>
                <xsl:element name="field_name">postal_code</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;NatPerson;Adresse;Ort</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_address_data</xsl:element>
                <xsl:element name="field_name">city_name</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;NatPerson;Kundennummer</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;NatPerson;Rechnungskontonummer</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='differingOwnerFirstName'] != '' and
              request-param[@name='differingOwnerLastName'] != '' and 
              request-param[@name='differingOwnerBirthDate'] != ''">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">AbweichenderVertragsInhaber;NatPerson;PersonenDaten;Nachname</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='differingOwnerLastName']"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">AbweichenderVertragsInhaber;NatPerson;PersonenDaten;Vorname</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='differingOwnerFirstName']"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">AbweichenderVertragsInhaber;NatPerson;PersonenDaten;Geburtsdatum</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='differingOwnerBirthDate']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>            
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;NatPerson;PersonenDaten;Nachname</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_entity</xsl:element>
                <xsl:element name="field_name">surname</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;NatPerson;PersonenDaten;Vorname</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_entity</xsl:element>
                <xsl:element name="field_name">forename</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;NatPerson;PersonenDaten;Geburtsdatum</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_entity</xsl:element>
                <xsl:element name="field_name">birth_date</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Artikelnumber</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_new_article_number</xsl:element>
                <xsl:element name="field_name">characteristic_value</xsl:element>								                
              </xsl:element>
            </xsl:element>
          </xsl:element>          
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">get_entity</xsl:element>
            <xsl:element name="field_name">entity_type</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">I</xsl:element>
        </xsl:element>
       </xsl:element>

      <!-- call the bus for organizations -->
      <xsl:element name="CcmFifProcessServiceBusRequestCmd">
        <xsl:element name="command_id">call_aip</xsl:element>
        <xsl:element name="CcmFifProcessServiceBusRequestInCont">
          <xsl:element name="package_name">net.arcor.aip.epsm_aip_starteeingehenderufnummerportierung_001</xsl:element>
          <xsl:element name="service_name">StarteEingehendeRufnummerPortierung</xsl:element>
          <xsl:element name="synch_ind">N</xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">PortierteRufnummer;Mobilvorwahl</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:text>0</xsl:text>
                <xsl:value-of select="substring-before(substring-after(request-param[@name='portedAccessNumber'], ';'), ';')"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">PortierteRufnummer;Mobilfunkrufnummer</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="substring-after(substring-after(request-param[@name='portedAccessNumber'], ';'), ';')"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">VorigerServiceProvider</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='serviceProvider']"/>
              </xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='asapIndicator'] != 'Y'">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">WunschPortierungsdatum</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='desiredDate']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TarifOption</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_tariff</xsl:element>
                <xsl:element name="field_name">pricing_structure_code</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Vonumber</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_sales_org_number</xsl:element>
                <xsl:element name="field_name">sales_org_number</xsl:element>
              </xsl:element>
            </xsl:element>            
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TechnUser</xsl:element>
              <xsl:element name="parameter_value">FIF</xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='differingOwnerFirstName'] != '' and
              request-param[@name='differingOwnerLastName'] != '' and 
              request-param[@name='differingOwnerBirthDate'] != ''">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">AbweichenderVertragsInhaber;NatPerson;PersonenDaten;Nachname</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='differingOwnerLastName']"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">AbweichenderVertragsInhaber;NatPerson;PersonenDaten;Vorname</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='differingOwnerFirstName']"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">AbweichenderVertragsInhaber;NatPerson;PersonenDaten;Geburtsdatum</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='differingOwnerBirthDate']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>                        
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;JurPerson;Adresse;Strasse</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_address_data</xsl:element>
                <xsl:element name="field_name">street_name</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;JurPerson;Adresse;Hausnummer</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_address_data</xsl:element>
                <xsl:element name="field_name">street_number</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;JurPerson;Adresse;Hausnummerzusatz</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_address_data</xsl:element>
                <xsl:element name="field_name">street_number_suffix</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;JurPerson;Adresse;PLZ</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_address_data</xsl:element>
                <xsl:element name="field_name">postal_code</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;JurPerson;Adresse;Ort</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_address_data</xsl:element>
                <xsl:element name="field_name">city_name</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;JurPerson;Kundennummer</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;JurPerson;Rechnungskontonummer</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_service</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Kundeninformation;JurPerson;Firmenname</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_entity</xsl:element>
                <xsl:element name="field_name">surname</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">Artikelnumber</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_new_article_number</xsl:element>
                <xsl:element name="field_name">characteristic_value</xsl:element>								                
              </xsl:element>
            </xsl:element>
          </xsl:element>          
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">get_entity</xsl:element>
            <xsl:element name="field_name">entity_type</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">O</xsl:element>
        </xsl:element>
      </xsl:element>
      

    </xsl:element>    
  </xsl:template>
</xsl:stylesheet>
