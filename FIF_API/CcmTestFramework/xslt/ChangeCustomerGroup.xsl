<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for changing the customer group

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
      <!-- Change Customer Group -->
      <xsl:element name="CcmFifChangeCustomerGroupCmd">
        <xsl:element name="command_id">change_customer_group</xsl:element>
        <xsl:element name="CcmFifChangeCustomerGroupInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="customer_group_rd">
            <xsl:value-of select="request-param[@name='NEW_CUSTOMER_GROUP_NUMBER']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
