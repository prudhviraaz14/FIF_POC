<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated termination cancellation FIF request

  @author goethalo
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
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
      <!-- Cancel Custoer Order -->
      <xsl:element name="CcmFifCancelCustOrderWithBarCodeCmd">
        <xsl:element name="command_id">cancel_of_term_1</xsl:element>
        <xsl:element name="CcmFifCancelCustOrderWithBarCodeInCont">
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='customerTrackingId']"/>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="request-param[@name='reasonRd']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

 
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
