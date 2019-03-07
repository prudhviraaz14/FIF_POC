<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for changing selected destinations

  @author schwarje
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1"
    indent="yes" method="xml"/>
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
    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">

      <!-- Create Contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">
            <xsl:value-of select="request-param[@name='CONTACT_TYPE_RD']"/>
          </xsl:element>
          <xsl:element name="caller_name">
            <xsl:value-of select="request-param[@name='CALLER_NAME']"/>
          </xsl:element>
          <xsl:element name="caller_phone_number">
            <xsl:value-of select="request-param[@name='CALLER_PHONE_NUMBER']"/>
          </xsl:element>
          <xsl:element name="author_name">
            <xsl:value-of select="request-param[@name='AUTHOR_NAME']"/>
          </xsl:element>
          <xsl:element name="short_description">
            <xsl:value-of select="request-param[@name='SHORT_DESCRIPTION']"/>
          </xsl:element>
          <xsl:element name="long_description_text">
            <xsl:value-of select="request-param[@name='LONG_DESCRIPTION_TEXT']"/>
          </xsl:element>
          <xsl:element name="trouble_ticket_id">
            <xsl:value-of select="request-param[@name='TROUBLE_TICKET_ID']"/>
          </xsl:element>
          <xsl:element name="trouble_ticket_type_rd">
            <xsl:value-of select="request-param[@name='TROUBLE_TICKET_TYPE_RD']"/>
          </xsl:element>
          <xsl:element name="trouble_ticket_status_rd">
            <xsl:value-of select="request-param[@name='TROUBLE_TICKET_STATUS_RD']"/>
          </xsl:element>
          <xsl:element name="trouble_ticket_requested_ind">
            <xsl:value-of select="request-param[@name='TROUBLE_TICKET_REQUESTED_IND']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
