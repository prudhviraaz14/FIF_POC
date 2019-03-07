<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a FIF request that changes the state of a customer

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
    <xsl:element name="client_name">
      <xsl:value-of select="request-param[@name='CLIENT_NAME']"/>   
      <xsl:value-of select="request-param[@name='clientName']"/>   
    </xsl:element>       
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">
      <!-- Change state of customer -->
      <xsl:element name="CcmFifDeactivateCustomerCmd">
        <xsl:element name="command_id">deactivate_Customer_1</xsl:element>
        <xsl:element name="CcmFifDeactivateCustomerInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="max_attempts">
            <xsl:value-of select="request-param[@name='MAX_ATTEMPTS']"/>
            <xsl:value-of select="request-param[@name='maxAttempts']"/>
          </xsl:element>
          <xsl:element name="termageina_delay">
            <xsl:value-of select="request-param[@name='TERMAGEINA_DELAY']"/>
            <xsl:value-of select="request-param[@name='termageinaDelay']"/>
          </xsl:element>
          <xsl:element name="input_channel">
            <xsl:value-of select="request-param[@name='INPUT_CHANNEL']"/>
            <xsl:value-of select="request-param[@name='inputChannel']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
