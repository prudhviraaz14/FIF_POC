<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for reseting the registration key. IT-15592 Arcor Sicherheitspaket.

  @author banania
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
    <xsl:variable name="DesiredDate" select="request-param[@name='desiredDate']"/>
    <!-- Convert the desired date to OPM format -->
    <xsl:variable name="desiredDateOPM"
      select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
    <!-- Calculate today and one day before the desired date 
      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>-->
    
    <xsl:element name="Command_List">
      
      <!-- Look for the Safety Package service -->
      <xsl:element name="CcmFifFindServiceSubsForProductCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsForProductInCont">
          <xsl:element name="product_subscription_id">
            <xsl:value-of select="request-param[@name='productSubscriptionId']"/>
          </xsl:element>
          <xsl:element name="service_code_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">I1410</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Validate the service subscription state -->
      <xsl:element name="CcmFifValidateServiceSubsStateCmd">
        <xsl:element name="command_id">validate_ss_state_1</xsl:element>
        <xsl:element name="CcmFifValidateServiceSubsStateInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_state">SUBSCRIBED</xsl:element>           
        </xsl:element>
      </xsl:element>
      
      <!-- Reconfigure Service Subscription -->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconf_serv_1</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$DesiredDate"/>	
          </xsl:element>
          <xsl:element name="desired_schedule_type">END_BEFORE</xsl:element>
          <xsl:element name="reason_rd">CHG_REGKEY</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Aktivierungsschlüssel -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1402</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='registrationKey']"/>
              </xsl:element>
            </xsl:element>	
            <!-- Reset Reason -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='resetReason']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Customer Order  -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="provider_tracking_no">001</xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconf_serv_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>           
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Release stand alone Customer Order  -->
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

      <!-- Create Contact  -->
        <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="contact_type_rd">SECURITY_PACKAGE</xsl:element>
            <xsl:element name="short_description">
              <xsl:text>Reg. Key geändert über </xsl:text>
              <xsl:value-of select="request-param[@name='clientName']"/>
            </xsl:element>
            <xsl:element name="long_description_text">
              <xsl:text>TransactionID: </xsl:text>
              <xsl:value-of select="request-param[@name='transactionID']"/>
              <xsl:text>&#xA;User name: </xsl:text>
              <xsl:value-of select="request-param[@name='userName']"/>
              <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
              <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
  
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
