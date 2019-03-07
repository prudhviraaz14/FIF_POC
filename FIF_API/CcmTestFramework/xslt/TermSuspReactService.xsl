<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an TermSuspReactService FIF request

  @author schwarje
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

      <!-- TermSuspReactService service -->
      <xsl:element name="CcmFifTermSuspReactServiceSubsCmd">
        <xsl:element name="command_id">tsr_service_1</xsl:element>
        <xsl:element name="CcmFifTermSuspReactServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="usage_mode">
            <xsl:value-of select="request-param[@name='USAGE_MODE']"/>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">
            <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="request-param[@name='REASON_RD']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Customer Order -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">tsr_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Release Customer Order -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
