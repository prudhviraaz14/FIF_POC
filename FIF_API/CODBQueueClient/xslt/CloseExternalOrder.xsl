<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated termination cancellation FIF request

  @author goethalo
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
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
      <xsl:value-of select="request-param[@name='clientName']"/>
    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">

    <!-- CreateExternalOrder -->
      <xsl:element name="CcmFifCreateExternalOrderCmd">
        <xsl:element name="command_id">create_external_order_1</xsl:element>
        <xsl:element name="CcmFifCreateExternalOrderInCont">
          <xsl:element name="order_id">
            <xsl:value-of select="request-param[@name='orderId']"/>
          </xsl:element>
          <xsl:element name="order_position_number">
            <xsl:value-of select="request-param[@name='orderPositionNumber']"/>
          </xsl:element>
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_intention">
            <xsl:value-of select="request-param[@name='customerIntention']"/>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
          <xsl:if test="count(request-param-list[@name='serviceSubscriptionIdList']/request-param-list-item) != 0">        
            <xsl:element name="affected_service_subscription_id_list">
              <!-- Pass in the list of service subscription ids -->
              <xsl:for-each
                select="request-param-list[@name='serviceSubscriptionIdList']/request-param-list-item">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="service_subscription_id">
                    <xsl:value-of select="request-param"/>
                  </xsl:element>
                </xsl:element>
              </xsl:for-each>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='orderEnvelopeId'] != ''">        
            <xsl:element name="order_envelope_id">
              <xsl:value-of select="request-param[@name='orderEnvelopeId']"/>
            </xsl:element>
          </xsl:if>
          <xsl:element name="state_rd">
            <xsl:value-of select="request-param[@name='status']"/>
          </xsl:element>
          <xsl:element name="order_position_type">
            <xsl:value-of select="request-param[@name='orderPositionType']"/>
          </xsl:element>
          <xsl:element name="barcode">
            <xsl:choose>
              <xsl:when test="request-param[@name='barcode'] != ''">
                <xsl:value-of select="request-param[@name='barcode']"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="request-param[@name='orderId']"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>            
          <xsl:element name="workflow_type_rd">
            <xsl:value-of select="request-param[@name='workflowType']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    

    <!-- CloseExternalOrder -->
      <xsl:element name="CcmFifCloseExternalOrderCmd">
        <xsl:element name="command_id">close_external_order_1</xsl:element>
        <xsl:element name="CcmFifCloseExternalOrderInCont">
          <xsl:element name="order_id">
            <xsl:value-of select="request-param[@name='orderId']"/>
          </xsl:element>
          <xsl:element name="order_position_number">
            <xsl:value-of select="request-param[@name='orderPositionNumber']"/>
          </xsl:element>
          <xsl:element name="close_reason_rd">
            <xsl:value-of select="request-param[@name='closeReason']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>


  </xsl:template>
</xsl:stylesheet>
