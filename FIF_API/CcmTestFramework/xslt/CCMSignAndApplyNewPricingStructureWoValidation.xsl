<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for sign and apply new pricing structure

  @author schwarje
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

      <!-- make sure the contract has not changed -->
      <xsl:element name="CcmFifValidateLegalAgreementUnchangedCmd">
        <xsl:element name="command_id">validate_la_unchanged_1</xsl:element>
        <xsl:element name="CcmFifValidateLegalAgreementUnchangedInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="version_number">
            <xsl:value-of select="request-param[@name='VERSION_NUMBER']"/>
          </xsl:element>
          <xsl:element name="update_number">
            <xsl:value-of select="request-param[@name='UPDATE_NUMBER']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
        
      
      <!-- Sign Order Form -->
      <xsl:element name="CcmFifSignOrderFormCmd">
        <xsl:element name="command_id">sign_order_form_1</xsl:element>
        <xsl:element name="CcmFifSignOrderFormInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="board_sign_name">
            <xsl:value-of select="request-param[@name='BOARD_SIGN_NAME']"/>
          </xsl:element>     
          <xsl:element name="board_sign_date">
            <xsl:value-of select="request-param[@name='BOARD_SIGN_DATE']"/>
          </xsl:element>     
          <xsl:element name="primary_cust_sign_name">
            <xsl:value-of select="request-param[@name='PRIMARY_CUSTOMER_SIGN_NAME']"/>
          </xsl:element>     
          <xsl:element name="primary_cust_sign_date">
            <xsl:value-of select="request-param[@name='PRIMARY_CUSTOMER_SIGN_DATE']"/>
          </xsl:element>               
        </xsl:element>
      </xsl:element>

      <!-- Apply New Pricing Structure -->
      <xsl:element name="CcmFifApplyNewPricingStructCmd">
        <xsl:element name="command_id">apply_new_ps_1</xsl:element>
        <xsl:element name="CcmFifApplyNewPricingStructInCont">
          <xsl:element name="supported_object_id">
            <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">O</xsl:element>
          <xsl:element name="apply_swap_date">
            <xsl:value-of select="request-param[@name='APPLY_SWAP_DATE']"/>
          </xsl:element>          
        </xsl:element>
      </xsl:element>
      
      
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
