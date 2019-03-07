<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a KBA notification FIF request

  @author goethalo
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
      
      <xsl:if test="request-param[@name='CATEGORY'] != 'WholesaleFax'
        and request-param[@name='TEXT'] = ''">
          <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">type_error_1</xsl:element>
            <xsl:element name="CcmFifRaiseErrorInCont">
              <xsl:element name="error_text">The parameter TEXT has to be set!</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>
      <!-- Get today's date -->
      <xsl:variable name="today"
          select="dateutils:getCurrentDate()"/>        
      <!-- Create KBA notification  -->
      <xsl:element name="CcmFifCreateExternalNotificationCmd">
        <xsl:element name="command_id">create_kba_notification_1</xsl:element>
        <xsl:element name="CcmFifCreateExternalNotificationInCont">
          <xsl:element name="effective_date">
              <xsl:if test="request-param[@name='EFFECTIVE_DATE'] != ''">
                <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
              </xsl:if>            
              <xsl:if test="request-param[@name='EFFECTIVE_DATE'] = ''">
                <xsl:value-of select="$today"/>
              </xsl:if>                          
          </xsl:element>
          <xsl:element name="notification_action_name">createKBANotification</xsl:element>
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
            <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">DESIRED_DATE</xsl:element>
                <xsl:element name="parameter_value">
                    <xsl:if test="request-param[@name='EFFECTIVE_DATE'] != ''">
                      <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
                    </xsl:if>            
                    <xsl:if test="request-param[@name='EFFECTIVE_DATE'] = ''">
                      <xsl:value-of select="$today"/>
                    </xsl:if>                          
                </xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='CONTRACT_NUMBER'] != ''">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CONTRACT_NUMBER</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/></xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='LINE_KEY_NUMBER'] != ''">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">LINE_KEY_NUMBER</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='LINE_KEY_NUMBER']"/></xsl:element>
              </xsl:element>
            </xsl:if>   
            <xsl:if test="request-param[@name='OLD_ACTIVATION_DATE'] != ''">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">OLD_ACTIVATION_DATE</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='OLD_ACTIVATION_DATE']"/></xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='NEW_ACTIVATION_DATE'] != ''">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">NEW_ACTIVATION_DATE</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='NEW_ACTIVATION_DATE']"/></xsl:element>
              </xsl:element>
            </xsl:if>               
            <xsl:if test="request-param[@name='TEXT'] != ''">         
              <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">TEXT</xsl:element>
                  <xsl:element name="parameter_value">
                      <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text><xsl:value-of select="request-param[@name='TEXT']" disable-output-escaping="yes"/><xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
                  </xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='BAR_CODE'] != ''">   
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">BAR_CODE</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='BAR_CODE']"/></xsl:element>
              </xsl:element> 
            </xsl:if>
            <xsl:if test="request-param[@name='ORDER_POSITION'] != ''">  
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ORDER_POSITION</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='ORDER_POSITION']"/></xsl:element>
              </xsl:element> 
            </xsl:if>
          </xsl:element>     
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
