<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for activating service without OP.
  @author schwarje
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1" indent="yes" method="xml"/>
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

    <xsl:variable name="today" select="dateutils:getCurrentDate()"/>

    <xsl:element name="Command_List">
      
  		<!-- find terminated service subscription -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_subs_term</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">	      
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='termServiceSubscriptionId']"/>
          </xsl:element>
          <xsl:element name="no_service_error">N</xsl:element>
        </xsl:element>
      </xsl:element>   
      
  		<!-- find stp -->
  		<xsl:element name="CcmFifFindServiceTicketPositionCmd">
  			<xsl:element name="command_id">find_stp_term</xsl:element>
  			<xsl:element name="CcmFifFindServiceTicketPositionInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='termServiceSubscriptionId']"/>
          </xsl:element>
  				<xsl:element name="usage_mode_value_rd">4</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service_subs_term</xsl:element>
            <xsl:element name="field_name">service_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>										
  			</xsl:element>
  		</xsl:element>
      
  		<!-- get data from STP -->
  		<xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
  			<xsl:element name="command_id">get_stp_data_term</xsl:element>
  			<xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
  				<xsl:element name="service_ticket_position_id_ref">
  					<xsl:element name="command_id">find_stp_term</xsl:element>
  					<xsl:element name="field_name">service_ticket_position_id</xsl:element>
  				</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_stp_term</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>										
  			</xsl:element>
  		</xsl:element>		
      
  		<!-- get data from CO -->
      <xsl:element name="CcmFifGetCustomerOrderDataCmd">
        <xsl:element name="command_id">get_co_data_term</xsl:element>
        <xsl:element name="CcmFifGetCustomerOrderDataInCont">
  				<xsl:element name="customer_order_id_ref">
  					<xsl:element name="command_id">get_stp_data_term</xsl:element>
  					<xsl:element name="field_name">customer_order_id</xsl:element>
  				</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_stp_term</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>										
        </xsl:element>
      </xsl:element>      
    
     <xsl:if test="request-param[@name='parentBarcode'] = '' or
        request-param[@name='customerIntention'] = ''">
        
       <!-- Contractpartner Change Scenario -->
        <!-- find new service subscription -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_subs_act</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">	      
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="request-param[@name='actServiceSubscriptionId']"/>
            </xsl:element>
            <xsl:element name="no_service_error">N</xsl:element>
          </xsl:element>
        </xsl:element>   
       
        <!-- find stp -->
        <xsl:element name="CcmFifFindServiceTicketPositionCmd">
          <xsl:element name="command_id">find_stp_act</xsl:element>
          <xsl:element name="CcmFifFindServiceTicketPositionInCont">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="request-param[@name='actServiceSubscriptionId']"/>
            </xsl:element>
            <xsl:element name="usage_mode_value_rd">1</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_service_subs_act</xsl:element>
              <xsl:element name="field_name">service_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>										
          </xsl:element>
        </xsl:element>
       
        <!-- get data from STP -->
        <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
          <xsl:element name="command_id">get_stp_data_act</xsl:element>
          <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_stp_act</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_stp_act</xsl:element>
              <xsl:element name="field_name">stp_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>										
          </xsl:element>
        </xsl:element>		
       
        <!-- get data from CO -->
        <xsl:element name="CcmFifGetCustomerOrderDataCmd">
          <xsl:element name="command_id">get_co_data_act</xsl:element>
          <xsl:element name="CcmFifGetCustomerOrderDataInCont">
            <xsl:element name="customer_order_id_ref">
              <xsl:element name="command_id">get_stp_data_act</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_stp_act</xsl:element>
              <xsl:element name="field_name">stp_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>										
          </xsl:element>
        </xsl:element>  
        
        <xsl:element name="CcmFifMapStringCmd">
          <xsl:element name="command_id">map_prov_change_log_create</xsl:element>
          <xsl:element name="CcmFifMapStringInCont">
            <xsl:element name="input_string_type">[Y,N];[Y,N]</xsl:element>
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_stp_term</xsl:element>
                <xsl:element name="field_name">stp_found</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">;</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_stp_act</xsl:element>
                <xsl:element name="field_name">stp_found</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="output_string_type"></xsl:element>
            <xsl:element name="string_mapping_list">
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">Y;Y</xsl:element>
                <xsl:element name="output_string">Y</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">N;Y</xsl:element>
                <xsl:element name="output_string">N</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">Y;N</xsl:element>
                <xsl:element name="output_string">N</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">N;N</xsl:element>
                <xsl:element name="output_string">N</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="no_mapping_error">Y</xsl:element>
          </xsl:element>
        </xsl:element>
       
      <!-- Write to Provider-Change-Log -->
      <xsl:element name="CcmFifCreateProviderChangeLogCmd">
        <xsl:element name="command_id">create_prov_change_log</xsl:element>
        <xsl:element name="CcmFifCreateProviderChangeLogInCont">
          <xsl:element name="act_customer_order_id_ref">
            <xsl:element name="command_id">get_co_data_act</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="term_customer_order_id_ref">
            <xsl:element name="command_id">get_co_data_term</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="source_system">
            <xsl:value-of select="request-param[@name='sourceSystem']"/>
          </xsl:element>
          <xsl:element name="creation_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="desired_date_ref">
            <xsl:element name="command_id">get_stp_data_act</xsl:element>
            <xsl:element name="field_name">desired_date</xsl:element>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="request-param[@name='reasonRd']"/>
          </xsl:element>
          <xsl:element name="detailed_reason_ref">
            <xsl:element name="command_id">get_stp_data_act</xsl:element>
            <xsl:element name="field_name">detailed_reason_rd</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_prov_change_log_create</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>										
        </xsl:element>
      </xsl:element>

      <!-- concat text parts for contact text -->
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">contact_text_activation</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text>Neuer Vertrag </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_subs_act</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text> ist Teil eines Vertragspartnerwechsels von &#xA;Kunde </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_subs_term</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text> (Barcode: </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">get_co_data_term</xsl:element>
              <xsl:element name="field_name">customer_tracking_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text>) zu &#xA;Kunde </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_subs_act</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text> (Barcode: </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">get_co_data_act</xsl:element>
              <xsl:element name="field_name">customer_tracking_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text>)&#xA;TransactionID: </xsl:text>
                <xsl:value-of select="request-param[@name='transactionID']"/>
                <xsl:text> (FIF-Client: </xsl:text>
                <xsl:value-of select="request-param[@name='clientName']"/>
                <xsl:text>)</xsl:text>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Contact for the contract partner change act. -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">get_co_data_act</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">VPW_ACT</xsl:element>
          <xsl:element name="short_description">VPW Aktivierung</xsl:element>
          <xsl:element name="description_text_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">contact_text_activation</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_prov_change_log_create</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>										
        </xsl:element>
      </xsl:element>

      <!-- concat text parts for contact text -->
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">contact_text_termination</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text>Kündigung des Vertrags </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_subs_term</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text> ist Teil eines Vertragspartnerwechsels von &#xA;Kunde </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_subs_term</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text> (Barcode: </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">get_co_data_term</xsl:element>
              <xsl:element name="field_name">customer_tracking_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text>) zu &#xA;Kunde </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_subs_act</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text> (Barcode: </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">get_co_data_act</xsl:element>
              <xsl:element name="field_name">customer_tracking_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text>)&#xA;TransactionID: </xsl:text>
                <xsl:value-of select="request-param[@name='transactionID']"/>
                <xsl:text> (FIF-Client: </xsl:text>
                <xsl:value-of select="request-param[@name='clientName']"/>
                <xsl:text>)</xsl:text>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

        <!-- Create Contact for the contract partner change term. -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">get_co_data_term</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">VPW_TERM</xsl:element>
          <xsl:element name="short_description">VPW Kündigung</xsl:element>
          <xsl:element name="description_text_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">contact_text_termination</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_prov_change_log_create</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>										
        </xsl:element>
      </xsl:element>
     
      </xsl:if>   

      <xsl:if test="request-param[@name='parentBarcode'] != '' and
        request-param[@name='customerIntention'] != ''">

        <xsl:variable name="isProviderChange">
          <xsl:choose>
            <xsl:when test="request-param[@name='customerIntention'] = 'RelocationDeact'">N</xsl:when>
            <xsl:when test="request-param[@name='customerIntention'] = 'LineChangeDeact'">N</xsl:when>
            <xsl:otherwise>Y</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="serviceCode">
          <xsl:choose>
            <xsl:when test="$isProviderChange = 'N'">V0012</xsl:when>
            <xsl:otherwise>Wh010</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <!-- Provider Change Scenario -->
        <!-- check if the voice service has already been created -->
        <xsl:element name="CcmFifFindServiceTicketPositionCmd">
          <xsl:element name="command_id">find_act_voice_stp</xsl:element>
          <xsl:element name="CcmFifFindServiceTicketPositionInCont">
            <xsl:element name="customer_tracking_id">
              <xsl:value-of select="request-param[@name='parentBarcode']"/>
            </xsl:element>
            <xsl:element name="no_stp_error">N</xsl:element>
            <xsl:element name="find_stp_parameters">
              <xsl:element name="CcmFifFindStpParameterCont">
                <xsl:element name="service_code">
                  <xsl:value-of select="$serviceCode"/>
                </xsl:element>
                <xsl:element name="usage_mode_value_rd">1</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
          <xsl:element name="command_id">get_act_voice_stp_data</xsl:element>
          <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_act_voice_stp</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_act_voice_stp</xsl:element>
              <xsl:element name="field_name">stp_found</xsl:element>							
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- get data from CO -->
        <xsl:element name="CcmFifGetCustomerOrderDataCmd">
          <xsl:element name="command_id">get_co_data_act</xsl:element>
          <xsl:element name="CcmFifGetCustomerOrderDataInCont">
            <xsl:element name="customer_order_id_ref">
              <xsl:element name="command_id">get_act_voice_stp_data</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_act_voice_stp</xsl:element>
              <xsl:element name="field_name">stp_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>										
          </xsl:element>
        </xsl:element>
        
        <xsl:if test="$isProviderChange = 'Y'">
          <!-- Create empty CO if no activation one is found -->
          <xsl:element name="CcmFifCreateCustOrderCmd">
            <xsl:element name="command_id">create_activation_co</xsl:element>
            <xsl:element name="CcmFifCreateCustOrderInCont">
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_service_subs_term</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
              <xsl:element name="customer_tracking_id">
                <xsl:value-of select="request-param[@name='parentBarcode']"/>
              </xsl:element>
              <xsl:element name="provider_tracking_no">001v</xsl:element>
              <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
              <xsl:element name="create_empty_customer_order">Y</xsl:element>
              <xsl:element name="service_ticket_pos_list"/> 
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_act_voice_stp</xsl:element>
                <xsl:element name="field_name">stp_found</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">N</xsl:element>         
            </xsl:element>
          </xsl:element>
          
          <!-- Write to Provider-Change-Log -->
          <!-- Use the new act CO if no act STP has been found -->
          <xsl:element name="CcmFifCreateProviderChangeLogCmd">
            <xsl:element name="command_id">create_prov_change_log</xsl:element>
            <xsl:element name="CcmFifCreateProviderChangeLogInCont">
              <xsl:element name="act_customer_order_id_ref">
                <xsl:element name="command_id">create_activation_co</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
              <xsl:element name="term_customer_order_id_ref">
                <xsl:element name="command_id">get_co_data_term</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
              <xsl:element name="source_system">
                <xsl:value-of select="request-param[@name='sourceSystem']"/>
              </xsl:element>
              <xsl:element name="creation_date">
                <xsl:value-of select="$today"/>
              </xsl:element>
              <xsl:element name="desired_date_ref">
                <xsl:element name="command_id">get_stp_data_term</xsl:element>
                <xsl:element name="field_name">desired_date</xsl:element>
              </xsl:element>
              <xsl:element name="reason_rd">
                <xsl:value-of select="request-param[@name='reasonRd']"/>
              </xsl:element>
              <xsl:element name="detailed_reason_rd"/>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_act_voice_stp</xsl:element>
                <xsl:element name="field_name">stp_found</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">N</xsl:element>   									
            </xsl:element>
          </xsl:element>
        </xsl:if>
          
        <!-- Use the found act CO -->
        <xsl:element name="CcmFifCreateProviderChangeLogCmd">
          <xsl:element name="command_id">create_prov_change_log</xsl:element>
          <xsl:element name="CcmFifCreateProviderChangeLogInCont">
            <xsl:element name="act_customer_order_id_ref">
              <xsl:element name="command_id">get_co_data_act</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="term_customer_order_id_ref">
              <xsl:element name="command_id">get_co_data_term</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="source_system">
              <xsl:value-of select="request-param[@name='sourceSystem']"/>
            </xsl:element>
            <xsl:element name="creation_date">
              <xsl:value-of select="$today"/>
            </xsl:element>
            <xsl:element name="desired_date_ref">
              <xsl:element name="command_id">get_stp_data_term</xsl:element>
              <xsl:element name="field_name">desired_date</xsl:element>
            </xsl:element>
            <xsl:element name="reason_rd">
              <xsl:value-of select="request-param[@name='reasonRd']"/>
            </xsl:element>
            <xsl:element name="detailed_reason_rd"/>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_act_voice_stp</xsl:element>
              <xsl:element name="field_name">stp_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>   									
          </xsl:element>
        </xsl:element>
        
        <xsl:if test="$isProviderChange = 'Y'">
          <xsl:element name="CcmFifCreateContactCmd">
            <xsl:element name="command_id">create_contact_prov_change</xsl:element>
            <xsl:element name="CcmFifCreateContactInCont">
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_service_subs_term</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
              <xsl:element name="contact_type_rd">PROV_CHG_TERM</xsl:element>
              <xsl:element name="short_description">Providerwechsel Kündigung</xsl:element>
              <xsl:element name="description_text_list">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="contact_text">
                    <xsl:text>Die Kündigung des Vertrags </xsl:text>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">find_service_subs_term</xsl:element>
                  <xsl:element name="field_name">contract_number</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="contact_text">
                    <xsl:text> ist Teil eines Providerwechsels von &#xA;Kunde </xsl:text>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">find_service_subs_term</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="contact_text">
                    <xsl:text> (Barcode: </xsl:text>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">get_co_data_term</xsl:element>
                  <xsl:element name="field_name">customer_tracking_id</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="contact_text">
                    <xsl:text>) zu &#xA;einem noch nicht erstellten Kunden (Barcode: </xsl:text>
                    <xsl:value-of select="request-param[@name='parentBarcode']"/>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="contact_text">
                    <xsl:text>)&#xA;TransactionID: </xsl:text>
                    <xsl:value-of select="request-param[@name='transactionID']"/>
                    <xsl:text> (FIF-Client: </xsl:text>
                    <xsl:value-of select="request-param[@name='clientName']"/>
                    <xsl:text>)</xsl:text>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_stp_act</xsl:element>
                <xsl:element name="field_name">stp_found</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">N</xsl:element>   	
            </xsl:element>
          </xsl:element>
          
          <xsl:element name="CcmFifCreateContactCmd">
            <xsl:element name="command_id">create_contact_prov_change</xsl:element>
            <xsl:element name="CcmFifCreateContactInCont">
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_service_subs_term</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
              <xsl:element name="contact_type_rd">PROV_CHG_TERM</xsl:element>
              <xsl:element name="short_description">Providerwechsel Kündigung</xsl:element>
              <xsl:element name="description_text_list">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="contact_text">
                    <xsl:text>Die Kündigung des Vertrags </xsl:text>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">find_service_subs_term</xsl:element>
                  <xsl:element name="field_name">contract_number</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="contact_text">
                    <xsl:text> ist Teil eines Providerwechsels von &#xA;Kunde </xsl:text>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">find_service_subs_term</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="contact_text">
                    <xsl:text> (Barcode: </xsl:text>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">get_co_data_term</xsl:element>
                  <xsl:element name="field_name">customer_tracking_id</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="contact_text">
                    <xsl:text>) zu &#xA;Kunde </xsl:text>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">find_service_subs_act</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="contact_text">
                    <xsl:text> (Barcode: </xsl:text>
                    <xsl:value-of select="request-param[@name='parentBarcode']"/>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="contact_text">
                    <xsl:text>)&#xA;TransactionID: </xsl:text>
                    <xsl:value-of select="request-param[@name='transactionID']"/>
                    <xsl:text> (FIF-Client: </xsl:text>
                    <xsl:value-of select="request-param[@name='clientName']"/>
                    <xsl:text>)</xsl:text>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_stp_term</xsl:element>
                <xsl:element name="field_name">stp_found</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">Y</xsl:element>
            </xsl:element>
          </xsl:element>        
        </xsl:if>
      </xsl:if>
           
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>

