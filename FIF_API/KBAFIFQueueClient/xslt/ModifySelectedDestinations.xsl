<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for changing selected destinations

  @author iarizova
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  exclude-result-prefixes="dateutils">
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
    <xsl:element name="Command_List">

      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
      <!-- Find Service Subscription -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="access_number">
            <xsl:value-of select="request-param[@name='accessNumber']"/>
          </xsl:element>
          <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>          
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>          
          <xsl:element name="product_code">
            <xsl:value-of select="request-param[@name='productCode']"/>
          </xsl:element>          
          <xsl:if test="starts-with(request-param[@name='accessNumber'], '49')">
            <xsl:element name="technical_service_code">VOICE</xsl:element>
          </xsl:if>
          <xsl:if test="not(starts-with(request-param[@name='accessNumber'], '49'))">
            <xsl:element name="technical_service_code">INTERNET_DIAL_IN</xsl:element>
          </xsl:if>
        </xsl:element>
      </xsl:element>

      <xsl:element name="CcmFifFindPricePlanSubsCmd">
        <xsl:element name="command_id">find_pps_1</xsl:element>
        <xsl:element name="CcmFifFindPricePlanSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="selected_destination_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Deactivate Selected destinations -->
      <xsl:element name="CcmFifDeactSelectedDestForPpsCmd">
        <xsl:element name="command_id">deact_sd_1</xsl:element>
        <xsl:element name="CcmFifDeactSelectedDestForPpsInCont">
          <xsl:element name="price_plan_subs_list_ref">
            <xsl:element name="command_id">find_pps_1</xsl:element>
            <xsl:element name="field_name">price_plan_subs_list</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='startDate']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Configure Price Plan -->
      <xsl:element name="CcmFifConfigurePPSCmd">
        <xsl:element name="command_id">config_pps_1</xsl:element>
        <xsl:element name="CcmFifConfigurePPSInCont">
          <xsl:element name="price_plan_subs_list_ref">
            <xsl:element name="command_id">find_pps_1</xsl:element>
            <xsl:element name="field_name">price_plan_subs_list</xsl:element>
          </xsl:element>
          <xsl:variable name="StartDate" select="request-param[@name='startDate']"/>
          <xsl:if
            test="count(request-param-list[@name='selectedDestinationsList']/request-param-list-item) != 0">
            <xsl:element name="selected_destinations_list">
              <!-- Selected Destinations -->
              <xsl:for-each
                select="request-param-list[@name='selectedDestinationsList']/request-param-list-item">
                <xsl:element name="CcmFifSelectedDestCont">
                  <xsl:element name="begin_number">
                    <xsl:value-of select="request-param[@name='beginNumber']"/>
                  </xsl:element>
                  <xsl:element name="start_date">
                    <xsl:value-of select="$StartDate"/>
                  </xsl:element>
                </xsl:element>
              </xsl:for-each>
            </xsl:element>
          </xsl:if>
        </xsl:element>
      </xsl:element>

      <!-- Create Contact-->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="command_id">create_contact_1</xsl:element>
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">INFO</xsl:element>
          <xsl:element name="caller_name">SYSTEM</xsl:element>
          <xsl:element name="caller_phone_number">SYSTEM</xsl:element>
          <xsl:element name="author_name">
            <xsl:value-of select="request-param[@name='userName']"/>
          </xsl:element>
          <xsl:element name="short_description">Changing selected dest.</xsl:element>
          <xsl:element name="long_description_text">Changing selected destinations.</xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:if test="request-param[@name='clientName'] != 'KBA'">
        <!-- Create KBA notification  -->
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_kba_notification_1</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='startDate']"/>
            </xsl:element>
            <xsl:element name="notification_action_name">createKBANotification</xsl:element>
            <xsl:element name="target_system">KBA</xsl:element>
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='customerNumber']"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TYPE</xsl:element>
                <xsl:element name="parameter_value">CONTACT</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CATEGORY</xsl:element>
                <xsl:element name="parameter_value">Rabattierte Zielrufnummern</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">USER_NAME</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='userName']"/>
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
                  <xsl:text>Rabattierte Zielrufnummern wurden geändert</xsl:text>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
