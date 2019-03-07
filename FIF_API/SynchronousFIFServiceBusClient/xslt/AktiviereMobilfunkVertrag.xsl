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
        <xsl:element name="command_id">find_subscribe_stp</xsl:element>
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
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">COMPLETE</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">FINAL</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- get STP data -->
      <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
        <xsl:element name="command_id">get_subscribe_stp_data</xsl:element>
        <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_subscribe_stp</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- get data from customer order -->
      <xsl:element name="CcmFifGetCustomerOrderDataCmd">
        <xsl:element name="command_id">get_subscribe_co_data</xsl:element>
        <xsl:element name="CcmFifGetCustomerOrderDataInCont">
          <xsl:element name="customer_order_id_ref">
            <xsl:element name="command_id">get_subscribe_stp_data</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
            
      <!-- check which desired date has to be used -->
      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
      <xsl:variable name="tomorrow" select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>      
      <xsl:element name="CcmFifValidateDateCmd">
        <xsl:element name="command_id">check_desired_date_today</xsl:element>
        <xsl:element name="CcmFifValidateDateInCont">
          <xsl:element name="value_ref">
            <xsl:element name="command_id">get_subscribe_stp_data</xsl:element>
            <xsl:element name="field_name">desired_date</xsl:element>
          </xsl:element>
          <xsl:element name="allowed_values">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:value-of select="$today"/>
              </xsl:element>							
            </xsl:element>
          </xsl:element>
          <xsl:element name="operator">LESS</xsl:element>
          <xsl:element name="raise_error_if_invalid">N</xsl:element>							
        </xsl:element>
      </xsl:element>							
                  
      <!-- Reconfigure the main access service -->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconfigure_mobile_service</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">          
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_mobile_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Aktivierung SIM-Karte -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V8002</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Ja</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">check_desired_date_today</xsl:element>
            <xsl:element name="field_name">is_valid</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>          
        </xsl:element>
      </xsl:element>
      
      <!-- Reconfigure the main access service -->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconfigure_mobile_service</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">          
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_mobile_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$tomorrow"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Aktivierung SIM-Karte -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V8002</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Ja</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">check_desired_date_today</xsl:element>
            <xsl:element name="field_name">is_valid</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- create customer order -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_customer_order</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_mobile_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconfigure_mobile_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- release customer order -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="command_id">release_customer_order</xsl:element>
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_mobile_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_customer_order</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- variable for contact text -->
      <xsl:variable name="contactText">
        <xsl:text>Der SIM-Karte für Rufnummer </xsl:text>
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
          <xsl:element name="contact_type_rd">CREATE_MOBILE</xsl:element>
          <xsl:element name="short_description">SIM-Karte aktiviert</xsl:element>
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
              <xsl:element name="parameter_value">MobilePhoneActivationLaterOrderPositive</xsl:element>
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
      
    </xsl:element>   
  </xsl:template>
</xsl:stylesheet>
