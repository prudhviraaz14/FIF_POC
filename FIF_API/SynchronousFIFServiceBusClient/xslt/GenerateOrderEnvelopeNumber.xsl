<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for generating order envelope

  @author lejam
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

      <!-- generate order envelope number-->      
      <xsl:element name="CcmFifGenerateOrderEnvelopeIdCmd">
        <xsl:element name="command_id">generate_order_envelope_id_1</xsl:element>
        <xsl:element name="CcmFifGenerateOrderEnvelopeIdInCont">          
          <xsl:element name="system_id">
            <xsl:value-of select="request-param[@name='SystemID']"/>
          </xsl:element>
          <xsl:element name="system_type">
            <xsl:value-of select="request-param[@name='SystemType']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>    

      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
