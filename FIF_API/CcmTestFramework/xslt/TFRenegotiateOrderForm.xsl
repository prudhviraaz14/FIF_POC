<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--
  XSLT file for creating a FIF request for creating a Customer Message

  @author banania
-->
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1"
    doctype-system="fif_transaction.dtd"/>
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
      <!-- Renegotiate Order Form -->
      <xsl:element name="CcmFifRenegotiateOrderFormCmd">
        <xsl:element name="command_id">renegotiate_order_form_1</xsl:element>
        <xsl:element name="CcmFifRenegotiateOrderFormInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="loi_indicator">
            <xsl:value-of select="request-param[@name='LOI_INDICATOR']"/>
          </xsl:element>
          <xsl:element name="notice_per_dur_value">
            <xsl:value-of select="request-param[@name='NOTICE_PER_DUR_VALUE']"/>
          </xsl:element>
          <xsl:element name="notice_per_dur_unit">
            <xsl:value-of select="request-param[@name='NOTICE_PER_DUR_UNIT']"/>
          </xsl:element>     
          <xsl:element name="min_per_dur_value">
            <xsl:value-of select="request-param[@name='MIN_PER_DUR_VALUE']"/>
          </xsl:element>     
          <xsl:element name="min_per_dur_unit">
            <xsl:value-of select="request-param[@name='MIN_PER_DUR_UNIT']"/>
          </xsl:element>     
          <xsl:element name="term_start_date">
            <xsl:value-of select="request-param[@name='TERM_START_DATE']"/>
          </xsl:element>     
          <xsl:element name="monthly_order_entry_amount">
            <xsl:value-of select="request-param[@name='MONTHLY_ORDER_ENTRY_AMOUNT']"/>
          </xsl:element>     
          <xsl:element name="termination_restriction">
            <xsl:value-of select="request-param[@name='TERMINATION_RESTRICTION']"/>
          </xsl:element>     
          <xsl:element name="doc_template_name">
            <xsl:value-of select="request-param[@name='DOC_TEMPLATE_NAME']"/>
          </xsl:element>          
          <xsl:element name="assoc_skeleton_cont_num">
            <xsl:value-of select="request-param[@name='ASSOC_SKELETON_CONT_NUM']"/>
          </xsl:element>     
          <xsl:element name="override_restriction">
            <xsl:value-of select="request-param[@name='OVERRIDE_RESTRICTION']"/>
          </xsl:element>               
          <xsl:for-each select="request-param-list[@name='RenegotiateParam']/request-param-list-item/request-param-list[@name='ProductCommitList']/request-param-list-item">
            <xsl:if test="request-param[@name='OPERATION'] = 'TARIF_CHANGE'">
              <xsl:element name="product_commit_list">
                <xsl:element name="CcmFifProductCommitCont">
                  <xsl:element name="old_product_code">
                    <xsl:value-of select="request-param[@name='OLD_PRODUCT_CODE']"/>
                  </xsl:element>
                  <xsl:element name="old_pricing_structure_code">
                    <xsl:value-of select="request-param[@name='OLD_PRICING_STRUCTURE_CODE']"/>
                  </xsl:element>
                  <xsl:element name="new_product_code">
                    <xsl:value-of select="request-param[@name='NEW_PRODUCT_CODE']"/>
                  </xsl:element>
                  <xsl:element name="new_pricing_structure_code">
                    <xsl:value-of select="request-param[@name='NEW_PRICING_STRUCTURE_CODE']"/>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='OPERATION'] = 'PRODUCT_SWAP'">
              <xsl:element name="product_commit_list">
                <xsl:element name="CcmFifProductCommitCont">
                  <xsl:element name="new_product_code">
                    <xsl:value-of select="request-param[@name='NEW_PRODUCT_CODE']"/>
                  </xsl:element>
                  <xsl:element name="new_pricing_structure_code">
                    <xsl:value-of select="request-param[@name='NEW_PRICING_STRUCTURE_CODE']"/>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:if>
          </xsl:for-each>
          <xsl:element name="auto_extent_period_value">
            <xsl:value-of select="request-param[@name='AUTO_EXTENT_PERIOD_VALUE']"/>
          </xsl:element>                         
          <xsl:element name="auto_extent_period_unit">
            <xsl:value-of select="request-param[@name='AUTO_EXTENT_PERIOD_UNIT']"/>
          </xsl:element>                         
          <xsl:element name="auto_extension_ind">
            <xsl:value-of select="request-param[@name='AUTO_EXTENSION_IND']"/>
          </xsl:element>                         
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
