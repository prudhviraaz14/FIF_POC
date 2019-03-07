<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for modifying customer data

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
      
      <xsl:variable name="CustomerNumber">
        <xsl:value-of select="request-param[@name='Kundennummer']"/>
      </xsl:variable>
      
      <xsl:variable name="MarketingPhoneIndicator">
        <xsl:choose>
          <xsl:when test="request-param[@name='MarketingEinwilligungTelefon'] = 'true'">
              <xsl:text>Y</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='MarketingEinwilligungTelefon'] = 'false'">
            <xsl:text>N</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text></xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="MarketingMailIndicator">
        <xsl:choose>
          <xsl:when test="request-param[@name='MarketingEinwilligungEmail'] = 'true'
            or request-param[@name='MarketingEinwilligungPost']= 'true'">
            <xsl:text>Y</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='MarketingEinwilligungEmail'] = 'false' or
            request-param[@name='MarketingEinwilligungPost'] = 'false'">
            <xsl:text>N</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text></xsl:text>
          </xsl:otherwise>
        </xsl:choose>			
      </xsl:variable>
    
      <xsl:variable name="MarketingFaxIndicator">
        <xsl:choose>
          <xsl:when test="request-param[@name='MarketingEinwilligungFax'] = 'true'">
            <xsl:text>Y</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='MarketingEinwilligungFax'] = 'false'">
            <xsl:text>N</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text></xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>


      <xsl:variable name="MarketingAuthorizationDate">
          <xsl:choose>
            <xsl:when test=" dateutils:compareString(request-param[@name='GueltigkeitsDatum'], $today)= '1' ">
              <xsl:value-of select="request-param[@name='GueltigkeitsDatum']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$today"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <!-- Change Customer Information -->      
      <xsl:element name="CcmFifModifyCustomerInfoCmd">
        <xsl:element name="command_id">modify_customer_info_1</xsl:element>
        <xsl:element name="CcmFifModifyCustomerInfoInCont">          
          <xsl:element name="customer_number">
            <xsl:value-of select="$CustomerNumber"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:if test="$MarketingPhoneIndicator != ''">
            <xsl:element name="marketing_phone_indicator">
              <xsl:value-of select="$MarketingPhoneIndicator"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="$MarketingMailIndicator != ''">            
          <xsl:element name="marketing_mail_indicator">
            <xsl:value-of select="$MarketingMailIndicator"/>
          </xsl:element>
          </xsl:if>
          <xsl:if test="$MarketingFaxIndicator !=''">   
          <xsl:element name="marketing_fax_indicator">
            <xsl:value-of select="$MarketingFaxIndicator"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="marketing_authorization_date">
            <xsl:value-of select="$MarketingAuthorizationDate"/>
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
                <xsl:element name="parameter_value">
                  <xsl:value-of select="$CustomerNumber"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TYPE</xsl:element>
                <xsl:element name="parameter_value">CONTACT</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CATEGORY</xsl:element>
                <xsl:element name="parameter_value">MarketingAgreementCancellationMailLetter</xsl:element>
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
                  <xsl:value-of select="$today"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TEXT</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:text>Änderung der Marketingeinwilligungsdaten über:</xsl:text>
                  <xsl:text>&#xA;Client Name: </xsl:text>
                  <xsl:value-of select="request-param[@name='clientName']"/>
                  <xsl:text>&#xA;Kundennummer: </xsl:text>
                  <xsl:value-of select="$CustomerNumber"/>
                  <xsl:text>&#xA;TransactionID: </xsl:text>
                  <xsl:value-of select="request-param[@name='transactionID']"/>
                  <xsl:text>&#xA;KampagnenID: </xsl:text>
                  <xsl:value-of select="request-param[@name='KampagnenID']"/>
                  <xsl:text>&#xA;E-Mail Adresse: </xsl:text>
                  <xsl:value-of select="request-param[@name='EmailAddress']"/>
                  <xsl:text>&#xA;Gültigkeitsdatum: </xsl:text>
                  <xsl:value-of select="$MarketingAuthorizationDate"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      
    
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
