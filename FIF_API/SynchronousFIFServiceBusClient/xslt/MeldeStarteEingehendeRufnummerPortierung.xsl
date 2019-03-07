<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for activating an inporting order

  @author banania
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

      <xsl:variable name="today"
        select="dateutils:getCurrentDate()"/>

      <!-- get the access number in CCB format from the input fields in SBUS format -->
      <xsl:variable name="accessNumber">        
        <xsl:text>49;</xsl:text>
        <xsl:value-of select="substring-after(request-param[@name='PortierteRufnummer;Mobilvorwahl'], '0')"/>
        <xsl:text>;</xsl:text>
        <xsl:value-of select="request-param[@name='PortierteRufnummer;Mobilfunkrufnummer']"/>
      </xsl:variable>  
      
      <!-- Find Service Subscription by access number,or service_subscription id  if no bundle was found -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_ported_mobile_service</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="access_number">
            <xsl:value-of select="$accessNumber"/>
          </xsl:element>
          <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- find STP -->
      <xsl:element name="CcmFifFindServiceTicketPositionCmd">
        <xsl:element name="command_id">find_stp</xsl:element>
        <xsl:element name="CcmFifFindServiceTicketPositionInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">find_ported_mobile_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="usage_mode_value_rd">1</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- get STP data -->
      <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
        <xsl:element name="command_id">get_stp_data</xsl:element>
        <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_stp</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- get data from customer order -->
      <xsl:element name="CcmFifGetCustomerOrderDataCmd">
        <xsl:element name="command_id">get_co_data</xsl:element>
        <xsl:element name="CcmFifGetCustomerOrderDataInCont">
          <xsl:element name="customer_order_id_ref">
            <xsl:element name="command_id">get_stp_data</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_stp</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
  
      <xsl:if test="request-param[@name='originalRequestResult'] = 'true'">  
        
        
        <!-- the activation date for the new mobile phone service and the termination date for
          the temporary sim card is depending on the porting date and the porting type in the 
          following way:
          portingDate = today and portingType = with temp sim card 
          ==> activation date := tomorrow
          ==> termination date := today 
          portingDate = today and portingType = without temp sim card
          ==> activation date := today
          portingDate != today and portingType = with temp sim card 
          ==> activation date := portingDate
          ==> termination date := portingDate - 1
          portingDate != today and portingType = without temp sim card 
          ==> activation date := portingDate
        -->
        <xsl:variable name="tomorrow"
          select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
        
        <xsl:variable name="activationDateWithTempSimCard">
          <xsl:if test="request-param[@name='PortierungsDatum'] = $today">
            <xsl:value-of select="$tomorrow"/>
          </xsl:if>
          <xsl:if test="request-param[@name='PortierungsDatum'] != $today">
            <xsl:value-of select="request-param[@name='PortierungsDatum']"/>
          </xsl:if>
        </xsl:variable>
        
        <xsl:variable name="desiredDateMinusOne"
          select="dateutils:createFIFDateOffset(request-param[@name='PortierungsDatum'], 'DATE', '-1')"/>
        
        <xsl:variable name="terminationDateWithTempSimCard">
          <xsl:if test="request-param[@name='PortierungsDatum'] = $today">
            <xsl:value-of select="$today"/>
          </xsl:if>
          <xsl:if test="request-param[@name='PortierungsDatum'] != $today">
            <xsl:value-of select="$desiredDateMinusOne"/>
          </xsl:if>
        </xsl:variable>
        <!-- find service for existing mobile phone contract within the same product subscription -->            
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_temporary_mobile_service</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_code">V8000</xsl:element>
            <xsl:element name="no_service_error">N</xsl:element>
            <xsl:element name="product_commitment_number_ref">
              <xsl:element name="command_id">find_ported_mobile_service</xsl:element>
              <xsl:element name="field_name">product_commitment_number</xsl:element>
            </xsl:element>
            <xsl:element name="target_state">SUBSCRIBED</xsl:element>          
          </xsl:element>
        </xsl:element>
        
        <!-- get the activation date for the new mobile service depending on the porting type -->
        <xsl:element name="CcmFifMapStringCmd">
          <xsl:element name="command_id">map_activation_date</xsl:element>
          <xsl:element name="CcmFifMapStringInCont">
            <xsl:element name="input_string_type">portingType</xsl:element>
            <xsl:element name="input_string_ref">
              <xsl:element name="command_id">find_temporary_mobile_service</xsl:element>
              <xsl:element name="field_name">service_found</xsl:element>                
            </xsl:element>
            <xsl:element name="output_string_type">activationDate</xsl:element>
            <xsl:element name="string_mapping_list">
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">Y</xsl:element>
                <xsl:element name="output_string">
                  <xsl:value-of select="$activationDateWithTempSimCard"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">N</xsl:element>
                <xsl:element name="output_string">
                  <xsl:value-of select="request-param[@name='PortierungsDatum']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="no_mapping_error">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Check for a tariff option -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_option_service</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="product_subscription_id_ref">
              <xsl:element name="command_id">find_ported_mobile_service</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V8032</xsl:element>
            <xsl:element name="no_service_error">N</xsl:element>
          </xsl:element>
        </xsl:element>										
        
        <!-- find STP for the tariff option -->
        <xsl:element name="CcmFifFindServiceTicketPositionCmd">
          <xsl:element name="command_id">find_option_stp</xsl:element>
          <xsl:element name="CcmFifFindServiceTicketPositionInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">find_option_service</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="usage_mode_value_rd">1</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_option_service</xsl:element>
              <xsl:element name="field_name">service_found</xsl:element>							
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>          
          </xsl:element>
        </xsl:element>
        
        
        <!-- Check for a fee service -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_fee_service</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="product_subscription_id_ref">
              <xsl:element name="command_id">find_ported_mobile_service</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V8033</xsl:element>
            <xsl:element name="no_service_error">N</xsl:element>
          </xsl:element>
        </xsl:element>										
        
        <!-- find STP for the fee service -->
        <xsl:element name="CcmFifFindServiceTicketPositionCmd">
          <xsl:element name="command_id">find_fee_stp</xsl:element>
          <xsl:element name="CcmFifFindServiceTicketPositionInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">find_fee_service</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="usage_mode_value_rd">1</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_fee_service</xsl:element>
              <xsl:element name="field_name">service_found</xsl:element>							
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>          
          </xsl:element>
        </xsl:element>
        
        <!-- Reconfigure the main access service -->
        <xsl:element name="CcmFifReconfigServiceCmd">
          <xsl:element name="command_id">modify_mobile_stp</xsl:element>
          <xsl:element name="CcmFifReconfigServiceInCont">          
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_ported_mobile_service</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_stp</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date_ref">
              <xsl:element name="command_id">map_activation_date</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>            
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="service_characteristic_list">
              <!-- SimId -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0108</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='SimSerienNr']"/>
                </xsl:element>
              </xsl:element>
              <!-- PUK -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0179</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='SimPuk']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Reconfigure the option service -->
        <xsl:element name="CcmFifReconfigServiceCmd">
          <xsl:element name="command_id">modify_option_stp</xsl:element>
          <xsl:element name="CcmFifReconfigServiceInCont">          
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_option_service</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_option_stp</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date_ref">
              <xsl:element name="command_id">map_activation_date</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>            
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="service_characteristic_list"/>     
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_option_service</xsl:element>
              <xsl:element name="field_name">service_found</xsl:element>							
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>                    
          </xsl:element>
        </xsl:element>
        
        <!-- Reconfigure the fee service -->
        <xsl:element name="CcmFifReconfigServiceCmd">
          <xsl:element name="command_id">modify_fee_stp</xsl:element>
          <xsl:element name="CcmFifReconfigServiceInCont">          
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_fee_service</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_fee_stp</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date_ref">
              <xsl:element name="command_id">map_activation_date</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>            
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="service_characteristic_list"/>     
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_fee_service</xsl:element>
              <xsl:element name="field_name">service_found</xsl:element>							
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>     
          </xsl:element>
        </xsl:element>
        
        <!-- release customer order -->
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="command_id">release_activation_co</xsl:element>
          <xsl:element name="CcmFifReleaseCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_ported_mobile_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">get_stp_data</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- terminate this product subscription, if this service exists -->
        <xsl:element name="CcmFifTerminateProductSubsCmd">
          <xsl:element name="command_id">terminate_temporary_ps</xsl:element>
          <xsl:element name="CcmFifTerminateProductSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_temporary_mobile_service</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="$terminationDateWithTempSimCard"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
            <xsl:element name="reason_rd">PORT_MOBILE</xsl:element>
            <xsl:element name="auto_customer_order">N</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_temporary_mobile_service</xsl:element>
              <xsl:element name="field_name">service_found</xsl:element>                            
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>          
          </xsl:element>
        </xsl:element>         
        
        <!-- create customer order for termination -->
        <xsl:element name="CcmFifCreateCustOrderCmd">
          <xsl:element name="command_id">create_termination_co</xsl:element>
          <xsl:element name="CcmFifCreateCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_ported_mobile_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="customer_tracking_id_ref">
              <xsl:element name="command_id">get_co_data</xsl:element>
              <xsl:element name="field_name">customer_tracking_id</xsl:element>
            </xsl:element>
            <xsl:element name="provider_tracking_no">002m</xsl:element>
            <xsl:element name="service_ticket_pos_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">terminate_temporary_ps</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_temporary_mobile_service</xsl:element>
              <xsl:element name="field_name">service_found</xsl:element>                            
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>          
          </xsl:element>
        </xsl:element>
        
        <!-- release customer order -->
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="command_id">release_termination_co</xsl:element>
          <xsl:element name="CcmFifReleaseCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_ported_mobile_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">create_termination_co</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_temporary_mobile_service</xsl:element>
              <xsl:element name="field_name">service_found</xsl:element>                            
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>          
          </xsl:element>
        </xsl:element>
        
        <!-- create contact -->
        <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="command_id">create_contact</xsl:element>
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_ported_mobile_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="contact_type_rd">PORT_MOBILE</xsl:element>
            <xsl:element name="short_description">Mobilportierung freigegeben</xsl:element>
            <xsl:element name="long_description_text">
              <xsl:text>Auftrag zur Mobilrufnummerportierung wurde über </xsl:text>
              <xsl:value-of select="request-param[@name='clientName']"/>
              <xsl:text> freigegeben.&#xA;TransactionID: </xsl:text>
              <xsl:value-of select="request-param[@name='transactionID']"/>
              <xsl:text>&#xA;Rufnummer: </xsl:text>
              <xsl:value-of select="$accessNumber"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      
          
      </xsl:if>
      <xsl:if test="request-param[@name='originalRequestResult'] = 'false'">
        
        <!-- cancel customer order -->
        <xsl:element name="CcmFifCancelCustomerOrderCmd">
          <xsl:element name="command_id">cancel_customer_order</xsl:element>
          <xsl:element name="CcmFifCancelCustomerOrderInCont">
            <xsl:element name="customer_order_id_ref">
              <xsl:element name="command_id">get_stp_data</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>            
            </xsl:element>
            <xsl:element name="cancel_reason_rd">CCM</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <xsl:variable name="contactText">
          <xsl:text>Mobilrufnummerportierung wurde storniert über </xsl:text>
          <xsl:value-of select="request-param[@name='clientName']"/>
          <xsl:text>&#xA;TransactionID: </xsl:text>
          <xsl:value-of select="request-param[@name='transactionID']"/>
          <xsl:text>&#xA;Rufnummer: </xsl:text>
          <xsl:value-of select="$accessNumber"/>
          <xsl:text>&#xA;Fehlercode: </xsl:text>
          <xsl:value-of select="request-param[@name='originalRequestErrorCode']"/>
          <xsl:text>&#xA;Fehlertext: </xsl:text>
          <xsl:value-of select="request-param[@name='originalRequestErrorText']"/>          
        </xsl:variable>
        
        <!-- create contact -->
        <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="command_id">create_contact</xsl:element>
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_ported_mobile_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="contact_type_rd">PORT_MOBILE</xsl:element>
            <xsl:element name="short_description">Mobilportierung storniert</xsl:element>
            <xsl:element name="long_description_text">
              <xsl:value-of select="$contactText"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>        
       
        <!-- Create KBA notification, if the request is not a KBA request -->
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_kba_notification</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="effective_date">
              <xsl:value-of select="$today"/>
            </xsl:element>
            <xsl:element name="notification_action_name">createKBANotification</xsl:element>
            <xsl:element name="target_system">KBA</xsl:element>
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_ported_mobile_service</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:if test="request-param[@name='originalRequestErrorCode'] = '0'">
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">TYPE</xsl:element>
                  <xsl:element name="parameter_value">CONTACT</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">CATEGORY</xsl:element>
                  <xsl:element name="parameter_value">CancelationMobilePortabilityToArcor</xsl:element>
                </xsl:element>
              </xsl:if>
              <xsl:if test="request-param[@name='originalRequestErrorCode'] != '0'">
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">TYPE</xsl:element>
                  <xsl:element name="parameter_value">PROCESS</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">CATEGORY</xsl:element>
                  <xsl:element name="parameter_value">OrderMobilePortabilityToArcorNegative</xsl:element>
                </xsl:element>
              </xsl:if>              
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">USER_NAME</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='clientName']"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">WORK_DATE</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="$today"/>
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
