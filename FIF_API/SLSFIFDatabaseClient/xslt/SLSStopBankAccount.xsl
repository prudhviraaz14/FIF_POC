<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a FIF request that stops unused bank accounts

  @author banania
-->
<xsl:stylesheet version="1.0"
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
    <xsl:element name="client_name"><xsl:value-of select="request-param[@name='CLIENT_NAME']"/></xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">
      <!-- Stop Bank Account -->
      <xsl:element name="CcmFifStopBankAccountCmd">
        <xsl:element name="command_id">stop_bank_account_1</xsl:element>
        <xsl:element name="CcmFifStopBankAccountInCont">
          <xsl:element name="bank_account_id">
            <xsl:value-of select="request-param[@name='BANK_ACCOUNT_ID']"/>
          </xsl:element>
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="stop_date">
            <xsl:value-of select="request-param[@name='STOP_DATE']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
