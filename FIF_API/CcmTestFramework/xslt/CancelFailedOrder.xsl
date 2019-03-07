<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a FIF request that changes the state of customer_order from FAIL to CANCEL

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
    <xsl:element name="client_name">SLS</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">
      <!-- Change state of customer_order -->
      <xsl:element name="CcmFifCancelFailedOrderCmd">
        <xsl:element name="command_id">cancel_failed_order_1</xsl:element>
        <xsl:element name="CcmFifCancelFailedOrderInCont">
          <xsl:element name="customer_order_id">
            <xsl:value-of select="request-param[@name='CUSTOMER_ORDER_ID']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
