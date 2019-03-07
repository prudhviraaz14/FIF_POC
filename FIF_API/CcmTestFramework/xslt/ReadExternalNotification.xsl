<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for allocating a cid

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
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    
    <xsl:element name="Command_List">
      
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">functionID</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:value-of select="request-param[@name='functionID']"/>
              </xsl:element>							
            </xsl:element>                
          </xsl:element>
        </xsl:element>
      </xsl:element>      
      
      <xsl:if test="request-param[@name='type'] != ''">
        <xsl:element name="CcmFifConcatStringsCmd">
          <xsl:element name="command_id">type</xsl:element>
          <xsl:element name="CcmFifConcatStringsInCont">
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">
                  <xsl:value-of select="request-param[@name='type']"/>
                </xsl:element>							
              </xsl:element>                
            </xsl:element>
          </xsl:element>
        </xsl:element>      
      </xsl:if>
      
      <xsl:element name="CcmFifReadExternalNotificationCmd">
        <xsl:element name="command_id">read_parameter</xsl:element>
        <xsl:element name="CcmFifReadExternalNotificationInCont">
          <xsl:element name="transaction_id">
            <xsl:value-of select="request-param[@name='requestListId']"/>
          </xsl:element>
          <xsl:element name="parameter_name">
            <xsl:value-of select="request-param[@name='type']"/>
            <xsl:value-of select="request-param[@name='functionID']"/>
            <xsl:value-of select="request-param[@name='parameterName']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>      
                  
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
