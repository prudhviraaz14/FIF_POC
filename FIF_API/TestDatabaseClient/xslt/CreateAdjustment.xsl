<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a Create Adjustment FIF request

  @author goethalo
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
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>

    <xsl:element name="Command_List">
      <!-- Create Adjustment -->
      <xsl:element name="CcmFifCreateAdjustmentCmd">
        <xsl:element name="command_id">create_adjustment_1</xsl:element>
        <xsl:element name="CcmFifCreateAdjustmentInCont">
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="start_date">
            <xsl:value-of select="request-param[@name='START_DATE']"/>
          </xsl:element>
          <xsl:element name="adjustment_type">
            <xsl:value-of select="request-param[@name='ADJUSTMENT_TYPE']"/>
          </xsl:element>
          <xsl:element name="base_currency_amount">
            <xsl:value-of select="request-param[@name='AMOUNT']"/>
          </xsl:element>
          <xsl:element name="create_user_id">
            <xsl:value-of select="request-param[@name='CREATE_USER_ID']"/>
          </xsl:element>
          <xsl:element name="description_text">
            <xsl:value-of select="request-param[@name='DESCRIPTION']"/>
          </xsl:element>
          <xsl:element name="reason_code">
            <xsl:value-of select="request-param[@name='REASON_CODE']"/>
          </xsl:element>
          <xsl:element name="product_code">
            <xsl:value-of select="request-param[@name='PRODUCT_CODE']"/>
          </xsl:element>
          <xsl:element name="tax_code">
            <xsl:value-of select="request-param[@name='TAX_CODE']"/>
          </xsl:element>
          <xsl:element name="internal_reason_text">
            <xsl:value-of select="request-param[@name='INTERNAL_REASON_TEXT']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
