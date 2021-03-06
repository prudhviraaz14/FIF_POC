<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a terminate product subscription FIF request

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
      <!-- Terminate Order Form -->
      <xsl:element name="CcmFifTerminateProductSubsCmd">
        <xsl:element name="command_id">terminate_ps_1</xsl:element>
        <xsl:element name="CcmFifTerminateProductSubsInCont">
          <xsl:element name="product_subscription_id">
            <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">END_BEFORE</xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
