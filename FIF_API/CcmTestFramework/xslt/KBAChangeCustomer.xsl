<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for updating customer information
exclude-result-prefixes="dateutils" 
  @author iarizova
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
    <xsl:element name="client_name">KBA</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">

      <!-- Change Customer Information -->
      
      <xsl:element name="CcmFifChangeCustomerCmd">
        <xsl:element name="command_id">change_customer_info_1</xsl:element>
        <xsl:element name="CcmFifChangeCustomerInCont">

          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:if test="request-param[@name='effectiveDate'] != ''">
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='effectiveDate']"/>
            </xsl:element>
          </xsl:if>          
          <xsl:if test="request-param[@name='paymentTermRd'] != ''">
            <xsl:element name="payment_term_rd">
              <xsl:value-of select="request-param[@name='paymentTermRd']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='userPassword'] != ''">
            <xsl:element name="user_password">
              <xsl:value-of select="request-param[@name='userPassword']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='usageLimitAmount'] != ''">
            <xsl:element name="usage_limit_amount">
              <xsl:value-of select="request-param[@name='usageLimitAmount']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='riskCategoryRd'] != ''">
            <xsl:element name="risk_category_rd">
              <xsl:value-of select="request-param[@name='riskCategoryRd']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='documentLanguageRd'] != ''">
            <xsl:element name="document_language_rd">
              <xsl:value-of select="request-param[@name='documentLanguageRd']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='classificationRd'] != ''">
            <xsl:element name="classification_rd">
              <xsl:value-of select="request-param[@name='classificationRd']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='customerGroupRd'] != ''">
            <xsl:element name="customer_group_rd">
              <xsl:value-of select="request-param[@name='customerGroupRd']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='customerInternalRefNumber'] != ''">
            <xsl:element name="customer_internal_ref_number">
              <xsl:value-of select="request-param[@name='customerInternalRefNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='paymentMethodRd'] != ''">
            <xsl:element name="payment_method_rd">
              <xsl:value-of select="request-param[@name='paymentMethodRd']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='matchCodeId'] != ''">
            <xsl:element name="match_code_id">
              <xsl:value-of select="request-param[@name='matchCodeId']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='creditCheckResultStateRd'] != ''">
            <xsl:element name="credit_check_result_state_rd">
              <xsl:value-of select="request-param[@name='creditCheckResultStateRd']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='creditCheckResultIndicator'] != ''">
            <xsl:element name="credit_check_result_indicator">
              <xsl:value-of select="request-param[@name='creditCheckResultIndicator']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='prospectIndicator'] != ''">
            <xsl:element name="prospect_indicator">
              <xsl:value-of select="request-param[@name='prospectIndicator']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='customerDataIndicator'] != ''">
          <xsl:element name="customer_data_indicator">
            <xsl:value-of select="request-param[@name='customerDataIndicator']"/>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='referenceIndicator'] != ''">
            <xsl:element name="reference_indicator">
              <xsl:value-of select="request-param[@name='referenceIndicator']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='serviceCustomerIndicator'] != ''">
            <xsl:element name="service_customer_indicator">
              <xsl:value-of select="request-param[@name='serviceCustomerIndicator']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='personalDataIndicator'] != ''">
            <xsl:element name="personal_data_indicator">
              <xsl:value-of select="request-param[@name='personalDataIndicator']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='usageDataIndicator'] != ''">
            <xsl:element name="usage_data_indicator">
              <xsl:value-of select="request-param[@name='usageDataIndicator']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='retentionPeriodRd'] != ''">
            <xsl:element name="retention_period_rd">
              <xsl:value-of select="request-param[@name='retentionPeriodRd']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='maskingDigitsRd'] != ''">
            <xsl:element name="masking_digits_rd">
              <xsl:value-of select="request-param[@name='maskingDigitsRd']"/>
            </xsl:element>
          </xsl:if>          
          <xsl:if test="request-param[@name='serviceLevelRd'] != ''">
            <xsl:element name="service_level_rd">
              <xsl:value-of select="request-param[@name='serviceLevelRd']"/>
            </xsl:element>
          </xsl:if>
       </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
