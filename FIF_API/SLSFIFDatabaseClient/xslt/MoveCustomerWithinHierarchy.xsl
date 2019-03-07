<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a FIF request that moves a customer that already exists 
  in the hierarchy to a new parent.

  @author 
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
      <xsl:element name="CcmFifMoveCustomerWithinHierarchyCmd">
        <xsl:element name="command_id">move_customer_within_hierarchy</xsl:element>
        <xsl:element name="CcmFifMoveCustomerWithinHierarchyInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="parent_customer_number">
            <xsl:value-of select="request-param[@name='PARENT_CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:if test="request-param[@name='EFFECTIVE_DATE'] != ''">
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
            </xsl:element>
          </xsl:if>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
