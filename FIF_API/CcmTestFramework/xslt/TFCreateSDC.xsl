<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!--
  XSLT file for creating a FIF request for creating service delivery contract and adding
  a product commitment.

  @author banania
-->
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
  <xsl:template match="/">
    <xsl:element name="CcmFifCommandList">
      <xsl:apply-templates select="request/request-params"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="request-params">
    <!-- Copy over transaction ID,action name & override_system_date -->
    <xsl:element name="transaction_id">
      <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">
      <!-- Create SDC-->
      <xsl:element name="CcmFifCreateServiceDelivContCmd">
        <xsl:element name="command_id">create_sdc_1</xsl:element>
        <xsl:element name="CcmFifCreateServiceDelivContInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="language_rd">
            <xsl:value-of select="request-param[@name='LANGUAGE_RD']"/>
          </xsl:element>
          <xsl:element name="loi_indicator">
            <xsl:value-of select="request-param[@name='LOI_INDICATOR']"/>
          </xsl:element>
          <xsl:element name="doc_template_name">
            <xsl:value-of select="request-param[@name='SDC_DOC_TEMPLATE_NAME']"/>
          </xsl:element>
          <xsl:element name="assoc_skeleton_cont_num">
            <xsl:value-of select="request-param[@name='ASSOC_SKELETON_CONT_NUM']"/>
          </xsl:element>
          <xsl:element name="override_restriction">
            <xsl:value-of select="request-param[@name='OVERRIDE_RESTRICTION']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Add Product Commitment -->
      <xsl:element name="CcmFifAddSDCProdCommitCmd">
        <xsl:element name="command_id">add_sdcpc_1</xsl:element>
        <xsl:element name="CcmFifAddSDCProdCommitInCont">
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">create_sdc_1</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <xsl:element name="product_code">
            <xsl:value-of select="request-param[@name='PRODUCT_CODE']"/>
          </xsl:element>
          <xsl:element name="pricing_structure_code">
            <xsl:value-of select="request-param[@name='PRICING_STRUCTURE_CODE']"/>
          </xsl:element>
          <xsl:element name="loi_indicator">
            <xsl:value-of select="request-param[@name='LOI_INDICATOR']"/>
          </xsl:element>
          <xsl:element name="quantity_value">
            <xsl:value-of select="request-param[@name='QUANTITY_VALUE']"/>
          </xsl:element>
          <xsl:element name="grace_per_dur_value">
            <xsl:value-of select="request-param[@name='GRACE_PER_DUR_VALUE']"/>
          </xsl:element>
          <xsl:element name="grace_per_dur_unit">
            <xsl:value-of select="request-param[@name='GRACE_PER_DUR_UNIT']"/>
          </xsl:element>
          <xsl:element name="notice_per_dur_value">
            <xsl:value-of select="request-param[@name='NOTICE_PER_DUR_VALUE']"/>
          </xsl:element>
          <xsl:element name="notice_per_dur_unit">
            <xsl:value-of select="request-param[@name='NOTICE_PER_DUR_UNIT']"/>
          </xsl:element>
          <xsl:element name="notice_per_exempt_ind">
            <xsl:value-of select="request-param[@name='NOTICE_PER_EXEMPT_IND']"/>
          </xsl:element>
          <xsl:element name="term_dur_value">
            <xsl:value-of select="request-param[@name='TERM_DUR_VALUE']"/>
          </xsl:element>
          <xsl:element name="term_dur_unit">
            <xsl:value-of select="request-param[@name='TERM_DUR_UNIT']"/>
          </xsl:element>
          <xsl:element name="term_start_date">
            <xsl:value-of select="request-param[@name='TERM_START_DATE']"/>
          </xsl:element>
          <xsl:element name="min_per_dur_value">
            <xsl:value-of select="request-param[@name='MIN_PER_DUR_VALUE']"/>
          </xsl:element>
          <xsl:element name="min_per_dur_unit">
            <xsl:value-of select="request-param[@name='MIN_PER_DUR_UNIT']"/>
          </xsl:element>
          <xsl:element name="sales_org_num_value">
            <xsl:value-of select="request-param[@name='SALES_ORG_NUM_VALUE']"/>
          </xsl:element>
          <xsl:element name="sales_org_date">
            <xsl:value-of select="request-param[@name='SALES_ORG_DATE']"/>
          </xsl:element>
          <xsl:element name="monthly_order_entry_amount">
            <xsl:value-of select="request-param[@name='MONTHLY_ORDER_ENTRY_AMOUNT']"/>
          </xsl:element>
          <xsl:element name="termination_restriction">
            <xsl:value-of select="request-param[@name='TERMINATION_RESTRICTION']"/>
          </xsl:element>
          <xsl:element name="doc_template_name">
            <xsl:value-of select="request-param[@name='SDCPC_DOC_TEMPLATE_NAME']"/>
          </xsl:element>
          <xsl:element name="override_restriction">
            <xsl:value-of select="request-param[@name='OVERRIDE_RESTRICTION']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
