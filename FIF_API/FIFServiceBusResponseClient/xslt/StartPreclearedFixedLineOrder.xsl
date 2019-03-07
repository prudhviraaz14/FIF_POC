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

      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>

      <xsl:variable name="customerNumber"
        select="dateutils:findCustomerNumberInSom(request-param[@name='SomString'])"/>
 
 
      <xsl:if test="request-param[@name='originalRequestResult'] != 'false'">  
        <xsl:element name="CcmFifConcatStringsCmd">
          <xsl:element name="command_id">dummyaction</xsl:element>
          <xsl:element name="CcmFifConcatStringsInCont">
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">dummyaction</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if> 
 
      <xsl:if test="request-param[@name='originalRequestResult'] = 'false'">     

      <xsl:variable name="contactText">
        <xsl:value-of select="//request/action-name"/>
        <xsl:text> ist ausgefehlert mit folgender Meldung.</xsl:text>
        <xsl:text>&#xA;Fehlercode: </xsl:text>
        <xsl:value-of select="request-param[@name='originalRequestErrorCode']"/>
        <xsl:text>&#xA;Fehlertext: </xsl:text>
        <xsl:value-of select="request-param[@name='originalRequestErrorText']"/>
        <xsl:text>&#xA;TransactionID: </xsl:text>
        <xsl:value-of select="request-param[@name='transactionID']"/>
        <xsl:text>&#xA;Barcode: </xsl:text>
        <xsl:value-of select="request-param[@name='Barcode']"/>
      </xsl:variable>


      <!-- create contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="command_id">create_contact</xsl:element>
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="$customerNumber"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">COM_ORDER_FAILED</xsl:element>
          <xsl:element name="short_description">COM-Auftrag ausgefehlert</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:value-of select="$contactText"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- KBA notification -->
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
                <xsl:value-of select="$customerNumber"/>
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
                <xsl:element name="parameter_value">SomOrderFailed</xsl:element>
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
