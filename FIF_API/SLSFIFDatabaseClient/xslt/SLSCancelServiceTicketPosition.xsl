<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for cancelling STPs
  
  @author schwarje
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
  <xsl:template match="/">
    <xsl:element name="CcmFifCommandList">
      <xsl:apply-templates select="request/request-params"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="request-params">
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

      <!-- cancel one service ticket position -->
      <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">
      <xsl:element name="CcmFifCancelServiceTicketPositionCmd">
        <xsl:element name="command_id">cancel_stp_1</xsl:element>
        <xsl:element name="CcmFifCancelServiceTicketPositionInCont">
          <xsl:element name="service_ticket_position_id">
            <xsl:value-of select="request-param[@name='SERVICE_TICKET_POSITION_ID']"/>
          </xsl:element>
          <xsl:element name="cancel_reason_rd">
            <xsl:value-of select="request-param[@name='CANCEL_REASON_RD']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>

      <!-- cancel all non complete service ticket positions for a product subscription -->
      <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">
      <xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
        <xsl:element name="command_id">cancel_stp_for_product_1</xsl:element>
        <xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
          <xsl:element name="product_subscription_id">
            <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="request-param[@name='CANCEL_REASON_RD']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
