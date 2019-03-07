<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a DLC notification for KBA

  @author banania
-->
<xsl:stylesheet 
    exclude-result-prefixes="dateutils" 
    version="1.0"
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
    <xsl:element name="client_name">OPM</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">
      <!-- Get today's date -->
      <xsl:variable name="today"
          select="dateutils:getCurrentDate()"/>        
      <!-- Create KBA notification  -->
      <xsl:element name="CcmFifCreateExternalNotificationCmd">
        <xsl:element name="command_id">create_dlc_notification_1</xsl:element>
        <xsl:element name="CcmFifCreateExternalNotificationInCont">
          <xsl:element name="effective_date">
              <xsl:if test="request-param[@name='EFFECTIVE_DATE'] != ''">
                <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
              </xsl:if>            
              <xsl:if test="request-param[@name='EFFECTIVE_DATE'] = ''">
                <xsl:value-of select="$today"/>
              </xsl:if>                          
          </xsl:element>
          <xsl:element name="notification_action_name">createDLCNotification</xsl:element>
          <xsl:element name="target_system">KBA</xsl:element>
          <xsl:element name="parameter_value_list">                                                                                                  
            <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/></xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TYPE</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='TYPE']"/></xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CATEGORY</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='CATEGORY']"/></xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">USER_NAME</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='USER_NAME']"/></xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='CLEARING_ACTIVITY_ID'] != ''">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CLEARING_ACTIVITY_ID</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='CLEARING_ACTIVITY_ID']"/></xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CCB_EXTERNAL_ID</xsl:element>
              <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='CCB_EXTERNAL_ID']"/></xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SALES_SEGMENT</xsl:element>
              <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='SALES_SEGMENT']"/></xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">ONKZ</xsl:element>
              <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='ONKZ']"/></xsl:element>
            </xsl:element>      
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">ASB</xsl:element>
              <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='ASB']"/></xsl:element>
            </xsl:element>  
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">ORDER_POSITION</xsl:element>
              <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='ORDER_POSITION']"/></xsl:element>
            </xsl:element> 
            <xsl:if test="request-param[@name='TAL_CARRIER_INFO_FIELD'] != ''">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TAL_CARRIER_INFO_FIELD</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='TAL_CARRIER_INFO_FIELD']"/></xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='TAL_CARRIER_REASON_CODE'] != ''">     
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TAL_CARRIER_REASON_CODE</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='TAL_CARRIER_REASON_CODE']"/></xsl:element>
              </xsl:element> 
            </xsl:if>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CLEARING_REASON_CODE</xsl:element>
              <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='CLEARING_REASON_CODE']"/></xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">BAR_CODE</xsl:element>
              <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='BAR_CODE']"/></xsl:element>
            </xsl:element>            
            <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">WORK_DATE</xsl:element>
                <xsl:element name="parameter_value">
                    <xsl:if test="request-param[@name='EFFECTIVE_DATE'] != ''">
                      <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
                    </xsl:if>            
                    <xsl:if test="request-param[@name='EFFECTIVE_DATE'] = ''">
                      <xsl:value-of select="$today"/>
                    </xsl:if>                          
                </xsl:element>
            </xsl:element>

          </xsl:element>     
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
