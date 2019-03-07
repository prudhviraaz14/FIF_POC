<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a FIF request that changes the state of a customer

  @author wlazlow
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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
    <xsl:element name="client_name">CODB</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">
      

      <!-- look for the  account -->
      <xsl:element name="CcmFifFindAccountCmd">
        <xsl:element name="command_id">find_account</xsl:element>
        <xsl:element name="CcmFifFindAccountInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="no_account_error">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Finalize  account -->
      <xsl:element name="CcmFifFinalizeAccountCmd">
        <xsl:element name="command_id">finalize_account</xsl:element>
        <xsl:element name="CcmFifFinalizeAccountInCont">
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_account</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="bypass_command">N</xsl:element>
          <xsl:element name="error_out">Y</xsl:element>
        </xsl:element>
      </xsl:element>

    </xsl:element>


  </xsl:template>
</xsl:stylesheet>
