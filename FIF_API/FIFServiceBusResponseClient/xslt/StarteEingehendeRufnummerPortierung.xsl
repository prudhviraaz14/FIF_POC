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
  
      <xsl:if test="request-param[@name='originalRequestResult'] = 'true'">                  
        <!-- create contact -->
        <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="command_id">create_contact</xsl:element>
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_ported_mobile_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="contact_type_rd">PORT_MOBILE</xsl:element>
            <xsl:element name="short_description">Mobilportierung angenommen</xsl:element>
            <xsl:element name="long_description_text">
              <xsl:text>Mobilrufnummerportierung wurde von AIP angenommen und wird zum gewünschten Termin verarbeitet.</xsl:text>
              <xsl:text>&#xA;TransactionID: </xsl:text>
              <xsl:value-of select="request-param[@name='transactionID']"/>
              <xsl:text>&#xA;Rufnummer: </xsl:text>
              <xsl:value-of select="$accessNumber"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>                                  
      </xsl:if>
      
      <xsl:if test="request-param[@name='originalRequestResult'] = 'false'">        
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
          <xsl:text>Mobilrufnummerportierung wurde von AIP abgewiesen und in CCM storniert.</xsl:text>
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
