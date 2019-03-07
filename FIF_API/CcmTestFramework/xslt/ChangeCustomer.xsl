<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for updating customer information
exclude-result-prefixes="dateutils" 
  @author iarizova
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
      
      <xsl:variable name="marketingAuthorizationDate">
        <xsl:if test="request-param[@name='MARKETING_AUTHORIZATION_DATE'] != ''">
          <xsl:value-of select="request-param[@name='MARKETING_AUTHORIZATION_DATE']"/>
        </xsl:if>
        <xsl:if test="request-param[@name='MARKETING_AUTHORIZATION_DATE'] = '' and 
          (request-param[@name='MARKETING_PHONE_INDICATOR'] != '' 
          or request-param[@name='MARKETING_MAIL_INDICATOR'] != ''
          or request-param[@name='MARKETING_FAX_INDICATOR'] != ''
          or request-param[@name='MARKETING_COOP_INDICATOR'] != ''
          or request-param[@name='MARKETING_USE_DATA_INDICATOR'] != '')">
          <xsl:value-of select="dateutils:getCurrentDate()"/>
        </xsl:if>
      </xsl:variable>            

      <!-- Change Customer Information -->
      
      <xsl:element name="CcmFifChangeCustomerCmd">
        <xsl:element name="command_id">change_customer_info_1</xsl:element>
        <xsl:element name="CcmFifChangeCustomerInCont">

          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:if test="request-param[@name='EFFECTIVE_DATE'] != ''">
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PAYMENT_TERM_RD'] != ''">
            <xsl:element name="payment_term_rd">
              <xsl:value-of select="request-param[@name='PAYMENT_TERM_RD']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='USER_PASSWORD'] != ''">
            <xsl:element name="user_password">
              <xsl:value-of select="request-param[@name='USER_PASSWORD']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='USAGE_LIMIT_AMOUNT'] != ''">
            <xsl:element name="usage_limit_amount">
              <xsl:value-of select="request-param[@name='USAGE_LIMIT_AMOUNT']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='RISK_CATEGORY_RD'] != ''">
            <xsl:element name="risk_category_rd">
              <xsl:value-of select="request-param[@name='RISK_CATEGORY_RD']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='CATEGORY_RD'] != ''">
            <xsl:element name="category_rd">
              <xsl:value-of select="request-param[@name='CATEGORY_RD']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='DOCUMENT_LANGUAGE_RD'] != ''">
            <xsl:element name="document_language_rd">
              <xsl:value-of select="request-param[@name='DOCUMENT_LANGUAGE_RD']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='CLASSIFICATION_RD'] != ''">
            <xsl:element name="classification_rd">
              <xsl:value-of select="request-param[@name='CLASSIFICATION_RD']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='CUSTOMER_GROUP_RD'] != ''">
            <xsl:element name="customer_group_rd">
              <xsl:value-of select="request-param[@name='CUSTOMER_GROUP_RD']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='CUSTOMER_INTERNAL_REF_NUMBER'] != ''">
            <xsl:element name="customer_internal_ref_number">
              <xsl:value-of select="request-param[@name='CUSTOMER_INTERNAL_REF_NUMBER']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PAYMENT_METHOD_RD'] != ''">
            <xsl:element name="payment_method_rd">
              <xsl:value-of select="request-param[@name='PAYMENT_METHOD_RD']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='MATCH_CODE_ID'] != ''">
            <xsl:element name="match_code_id">
              <xsl:value-of select="request-param[@name='MATCH_CODE_ID']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='CREDIT_CHECK_RESULT_STATE_RD'] != ''">
            <xsl:element name="credit_check_result_state_rd">
              <xsl:value-of select="request-param[@name='CREDIT_CHECK_RESULT_STATE_RD']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='CREDIT_CHECK_RESULT_INDICATOR'] != ''">
            <xsl:element name="credit_check_result_indicator">
              <xsl:value-of select="request-param[@name='CREDIT_CHECK_RESULT_INDICATOR']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PROSPECT_INDICATOR'] != ''">
            <xsl:element name="prospect_indicator">
              <xsl:value-of select="request-param[@name='PROSPECT_INDICATOR']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='REFERENCE_INDICATOR'] != ''">
            <xsl:element name="reference_indicator">
              <xsl:value-of select="request-param[@name='REFERENCE_INDICATOR']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='SERVICE_CUSTOMER_INDICATOR'] != ''">
            <xsl:element name="service_customer_indicator">
              <xsl:value-of select="request-param[@name='SERVICE_CUSTOMER_INDICATOR']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='USAGE_DATA_INDICATOR'] != ''">
            <xsl:element name="usage_data_indicator">
              <xsl:value-of select="request-param[@name='USAGE_DATA_INDICATOR']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='RETENTION_PERIOD_RD'] != ''">
            <xsl:element name="retention_period_rd">
              <xsl:value-of select="request-param[@name='RETENTION_PERIOD_RD']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='RETENTION_PERIOD_RD'] != '') or (request-param[@name='MASKING_DIGITS_RD'] != '')">
            <xsl:element name="cascade_mask_retention_ind">Y</xsl:element> 
          </xsl:if>
          <xsl:if test="request-param[@name='MASKING_DIGITS_RD'] != ''">
            <xsl:element name="masking_digits_rd">
              <xsl:value-of select="request-param[@name='MASKING_DIGITS_RD']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='STORAGE_MASKING_DIGITS_RD'] != ''">
            <xsl:element name="storage_masking_digits_rd">
              <xsl:value-of select="request-param[@name='STORAGE_MASKING_DIGITS_RD']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='SERVICE_LEVEL_RD'] != ''">
            <xsl:element name="service_level_rd">
              <xsl:value-of select="request-param[@name='SERVICE_LEVEL_RD']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='SUPPRESS_ARCHIVING_INDICATOR'] != ''">
            <xsl:element name="suppress_archiving_indicator">
              <xsl:value-of select="request-param[@name='SUPPRESS_ARCHIVING_INDICATOR']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='SECURITY_CUSTOMER_GROUP_STRING'] != ''">
            <xsl:element name="security_customer_group_string">
              <xsl:value-of select="request-param[@name='SECURITY_CUSTOMER_GROUP_STRING']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='REGION_RD'] != ''">
            <xsl:element name="region_rd">
              <xsl:value-of select="request-param[@name='REGION_RD']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='INVOICE_CURRENCY_RD'] != ''">
            <xsl:element name="invoice_currency_rd">
              <xsl:value-of select="request-param[@name='INVOICE_CURRENCY_RD']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='CYCLE_NAME'] != ''">
            <xsl:element name="cycle_name">
              <xsl:value-of select="request-param[@name='CYCLE_NAME']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='ENCRYPTION_KEY'] != ''">
            <xsl:element name="encryption_key">
              <xsl:value-of select="request-param[@name='ENCRYPTION_KEY']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='READ_ONLY'] != ''">
            <xsl:element name="read_only">
              <xsl:value-of select="request-param[@name='READ_ONLY']"/>
            </xsl:element>
          </xsl:if>  
          <xsl:if test="request-param[@name='PROSPECT_NUMBER'] != ''">
            <xsl:element name="prospect_number">
              <xsl:value-of select="request-param[@name='PROSPECT_NUMBER']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='INQUIRY_FILE_TYPE_RD'] != ''">
            <xsl:element name="inquiry_file_type_rd">
              <xsl:value-of select="request-param[@name='INQUIRY_FILE_TYPE_RD']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='INQUIRY_CUSTOMER_NUMBER'] != ''">
            <xsl:element name="inquiry_customer_number">
              <xsl:value-of select="request-param[@name='INQUIRY_CUSTOMER_NUMBER']"/>
            </xsl:element>            
          </xsl:if>
          <xsl:element name="post_ident_indicator">
            <xsl:value-of select="request-param[@name='POST_IDENT_INDICATOR']"/>
          </xsl:element>	  
          <xsl:element name="marketing_use_data_indicator">
            <xsl:value-of select="request-param[@name='MARKETING_USE_DATA_INDICATOR']"/>
          </xsl:element>
          <xsl:element name="marketing_phone_indicator">
            <xsl:value-of select="request-param[@name='MARKETING_PHONE_INDICATOR']"/>
          </xsl:element>
          <xsl:element name="marketing_mail_indicator">
            <xsl:value-of select="request-param[@name='MARKETING_MAIL_INDICATOR']"/>
          </xsl:element>
          <xsl:element name="marketing_fax_indicator">
            <xsl:value-of select="request-param[@name='MARKETING_FAX_INDICATOR']"/>
          </xsl:element>
          <xsl:element name="marketing_coop_indicator">
            <xsl:value-of select="request-param[@name='MARKETING_COOP_INDICATOR']"/>
          </xsl:element>
          <xsl:element name="marketing_authorization_date">
            <xsl:value-of select="$marketingAuthorizationDate"/>
          </xsl:element>					                              
       </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
