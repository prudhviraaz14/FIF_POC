<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for release to permanent notification

  @author Marcin Leja
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
    <xsl:element name="client_name">CCM</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">
      <xsl:variable name="today" select="dateutils:getCurrentDate()"/> 
      
      <!-- Find order form -->
      <xsl:element name="CcmFifGetOrderFormDataCmd">
        <xsl:element name="command_id">find_order_form_1</xsl:element>
        <xsl:element name="CcmFifGetOrderFormDataInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Check if order was initiated by COM -->
      <xsl:element name="CcmFifIsComOrderCmd">
        <xsl:element name="command_id">is_com_order</xsl:element>
        <xsl:element name="CcmFifIsComOrderInCont">
          <xsl:element name="barcode_ref">
            <xsl:element name="command_id">find_order_form_1</xsl:element>
            <xsl:element name="field_name">customer_tracking_id</xsl:element>
          </xsl:element>          	  
        </xsl:element>
      </xsl:element>
      
      <!-- Release existing appropriate notifications to Provi -->
      <xsl:element name="CcmFifSendContractChgCompletedCmd">
        <xsl:element name="command_id">send_contract_chg_completed_1</xsl:element>
        <xsl:element name="CcmFifSendContractChgCompletedInCont">
          <xsl:element name="contract_type">
            <xsl:value-of select="request-param[@name='CONTRACT_TYPE']"/>
          </xsl:element>
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="product_commitment_number">
            <xsl:value-of select="request-param[@name='PRODUCT_COMMITMENT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="version_number">
            <xsl:value-of select="request-param[@name='VERSION_NUMBER']"/>
          </xsl:element>
          <xsl:element name="is_com_order_ref">
            <xsl:element name="command_id">is_com_order</xsl:element>
            <xsl:element name="field_name">is_com_order</xsl:element>
          </xsl:element>          
        </xsl:element>
      </xsl:element>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
