<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a KBA notification FIF request

  @author wlazlow
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
    <xsl:element name="client_name">SLS</xsl:element>
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
                <xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='INPUT_CHANNEL']"/></xsl:element>
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
			<xsl:if test="request-param[@name='RECEIVER_HINT'] != ''">
				<xsl:element name="CcmFifParameterValueCont">
					<xsl:element name="parameter_name">RECEIVER_HINT</xsl:element>
					<xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='RECEIVER_HINT']"/></xsl:element>
				</xsl:element>
			</xsl:if>			  
            <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TEXT</xsl:element>
                <xsl:element name="parameter_value">
                    <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text><xsl:value-of select="request-param[@name='TEXT']" disable-output-escaping="yes"/><xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
                </xsl:element>
            </xsl:element>
          </xsl:element>     
        </xsl:element>
      </xsl:element>
      <!-- Create Contact for create KBA notification -->
      <xsl:if test="request-param[@name='SHORT_DESCRIPTION'] != ''">
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:if test="request-param[@name='CUSTOMER_NUMBER'] != ''">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
            </xsl:element>
          </xsl:if>
          
          <xsl:element name="contact_type_rd">
            <xsl:value-of select="request-param[@name='CONTACT_TYPE_RD']"/>
          </xsl:element>
          <xsl:element name="author_name">
            <xsl:value-of select="request-param[@name='AUTHOR_NAME']"/>
          </xsl:element>
          <xsl:element name="short_description">
            <xsl:value-of select="request-param[@name='SHORT_DESCRIPTION']"/>
          </xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID:</xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text><xsl:value-of select="request-param[@name='TEXT']" disable-output-escaping="yes"/><xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>     
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
