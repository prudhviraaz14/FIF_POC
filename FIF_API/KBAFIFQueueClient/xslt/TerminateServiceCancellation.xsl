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
      <!-- Cancel Order Form Termination -->
      <xsl:element name="CcmFifCancelOrderFormTerminationCmd">
        <xsl:element name="command_id">cancel_of_term_1</xsl:element>
        <xsl:element name="CcmFifCancelOrderFormTerminationInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="reason_rd">AUTO_TERM_CANCEL</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Contact for the Termination Cancellation -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">AUTO_TERM_CANCEL</xsl:element>
          <xsl:element name="short_description">Autom. Widerruf Kündigung</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;ContractNumber: </xsl:text>
            <xsl:value-of select="request-param[@name='contractNumber']"/>
            <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
            <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
