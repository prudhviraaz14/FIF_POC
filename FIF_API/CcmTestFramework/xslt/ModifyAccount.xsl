<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for modifying an account
  
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
      
     <xsl:variable name="Today" select="dateutils:getCurrentDate()"/>
        
        <xsl:variable name="DesiredDate">
        <xsl:choose>
            <xsl:when test="request-param[@name='EFFECTIVE_DATE'] = ''">
                <xsl:value-of select="$Today"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
        
      <!-- the following command is only executed if bank account info is provided -->
      <xsl:if test="(request-param[@name='BANK_ACCOUNT_NUMBER'] != '')
      	         or (request-param[@name='BANK_CLEARING_CODE'] != '')
      	         or (request-param[@name='OWNER_FULL_NAME'] != '')
      	         or (request-param[@name='BANK_IDENTIFIER_CODE'] != '')
      	         or (request-param[@name='INTERNAT_BANK_ACCOUNT_NUMBER'] != '')">
      <!-- create bank account -->
      <xsl:element name="CcmFifCreateBankAccountCmd">
        <xsl:element name="command_id">create_bank_account_1</xsl:element>
        <xsl:element name="CcmFifCreateBankAccountInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element>
          <xsl:element name="bank_account_number">
            <xsl:value-of select="request-param[@name='BANK_ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="owner_full_name">
            <xsl:value-of select="request-param[@name='OWNER_FULL_NAME']"/>
          </xsl:element>
          <xsl:element name="bank_clearing_code">
            <xsl:value-of select="request-param[@name='BANK_CLEARING_CODE']"/>
          </xsl:element>
          <xsl:element name="bank_identifier_code">
            <xsl:value-of select="request-param[@name='BANK_IDENTIFIER_CODE']"/>
          </xsl:element> 
          <xsl:element name="internat_bank_account_number">
            <xsl:value-of select="request-param[@name='INTERNAT_BANK_ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="bank_name">
            <xsl:value-of select="request-param[@name='BANK_NAME']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      
      <!-- Get Account Data -->
      <xsl:element name="CcmFifGetAccountDataCmd">
        <xsl:element name="command_id">get_account_data</xsl:element>
        <xsl:element name="CcmFifGetAccountDataInCont">
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="effective_date">
              <xsl:value-of select="$DesiredDate"/>
          </xsl:element>
        </xsl:element>    
      </xsl:element>  
      
      <!-- Modify Account -->
      <xsl:element name="CcmFifModifyAccountCmd">
        <xsl:element name="CcmFifModifyAccountInCont">
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='BANK_ACCOUNT_NUMBER'] != '')
      	             or (request-param[@name='BANK_CLEARING_CODE'] != '')
      	             or (request-param[@name='OWNER_FULL_NAME'] != '')
      	             or (request-param[@name='BANK_IDENTIFIER_CODE'] != '')
      	             or (request-param[@name='INTERNAT_BANK_ACCOUNT_NUMBER'] != '')">
            <xsl:element name="bank_account_id_ref">
              <xsl:element name="command_id">create_bank_account_1</xsl:element>
              <xsl:element name="field_name">bank_account_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='BANK_ACCOUNT_ID'] != '')">
            <xsl:element name="bank_account_id">
              <xsl:value-of select="request-param[@name='BANK_ACCOUNT_ID']"/>
            </xsl:element>
          </xsl:if>
          <xsl:element name="mailing_id">
            <xsl:value-of select="request-param[@name='MAILING_ID']"/>
          </xsl:element>
          <xsl:element name="effective_date">
              <xsl:value-of select="$DesiredDate"/>
          </xsl:element>
          <xsl:element name="doc_template_name">
            <xsl:value-of select="request-param[@name='DOC_TEMPLATE_NAME']"/>
          </xsl:element>
          <xsl:element name="method_of_payment">
            <xsl:value-of select="request-param[@name='METHOD_OF_PAYMENT']"/>
          </xsl:element>
          <xsl:element name="manual_suspend_ind">
            <xsl:value-of select="request-param[@name='MANUAL_SUSPEND_IND']"/>
          </xsl:element>
          <xsl:element name="language_rd">
            <xsl:value-of select="request-param[@name='LANGUAGE_RD']"/>
          </xsl:element>
          <xsl:element name="currency_rd">
            <xsl:value-of select="request-param[@name='CURRENCY_RD']"/>
          </xsl:element>
          <xsl:element name="cycle_name">
            <xsl:value-of select="request-param[@name='CYCLE_NAME']"/>
          </xsl:element>
          <xsl:element name="payment_term_rd">
            <xsl:value-of select="request-param[@name='PAYMENT_TERM_RD']"/>
          </xsl:element>
          <xsl:element name="zero_charge_ind">
            <xsl:value-of select="request-param[@name='ZERO_CHARGE_IND']"/>
          </xsl:element>
          <xsl:element name="usage_limit">
            <xsl:value-of select="request-param[@name='USAGE_LIMIT']"/>
          </xsl:element>
          <xsl:element name="customer_account_id">
            <xsl:value-of select="request-param[@name='CUSTOMER_ACCOUNT_ID']"/>
          </xsl:element>
          <xsl:element name="output_device_rd">
            <xsl:value-of select="request-param[@name='OUTPUT_DEVICE_RD']"/>
          </xsl:element>
          <xsl:element name="direct_debit_authoriz_date">
            <xsl:value-of select="request-param[@name='DIRECT_DEBIT_AUTHORIZ_DATE']"/>
          </xsl:element>
          <xsl:element name="tax_exempt_indicator">
            <xsl:value-of select="request-param[@name='TAX_EXEMPT_INDICATOR']"/>
          </xsl:element>
          <xsl:element name="sales_tax_id">
            <xsl:value-of select="request-param[@name='SALES_TAX_ID']"/>
          </xsl:element>
          <xsl:element name="tax_identification_number">
            <xsl:value-of select="request-param[@name='TAX_IDENTIFICATION_NUMBER']"/>
          </xsl:element>
          <xsl:element name="auto_select_payment_method">
            <xsl:value-of select="request-param[@name='AUTO_SELECT_PAYMENT_METHOD']"/>
          </xsl:element>
          <xsl:element name="state_rd">
            <xsl:value-of select="request-param[@name='STATE_RD']"/>
          </xsl:element>
          <xsl:element name="no_arc_indicator">
            <xsl:value-of select="request-param[@name='NO_ARC_INDICATOR']"/>
          </xsl:element>
          <xsl:element name="no_change_error_ind">Y</xsl:element>
          <xsl:element name="mandate_reference_id">
            <xsl:value-of select="request-param[@name='MANDATE_REFERENCE_ID']"/>
          </xsl:element>
          <xsl:element name="mandate_signature_date">
            <xsl:value-of select="request-param[@name='MANDATE_SIGNATURE_DATE']"/>
          </xsl:element>
          <xsl:element name="mandate_status_rd">
            <xsl:value-of select="request-param[@name='MANDATE_STATUS']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
            
      <xsl:if test="request-param[@name='CREATE_CONTACT'] != 'N'">
          <!-- Create Contact -->
          <xsl:element name="CcmFifCreateContactCmd">
            <xsl:element name="CcmFifCreateContactInCont">
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">get_account_data</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
              <xsl:element name="contact_type_rd">
                <xsl:value-of select="request-param[@name='CONTACT_TYPE_RD']"/>
              </xsl:element>
              <xsl:element name="short_description">
                <xsl:value-of select="request-param[@name='SHORT_DESCRIPTION']"/>
              </xsl:element>
              <xsl:element name="long_description_text">
                <xsl:value-of select="request-param[@name='LONG_DESCRIPTION_TEXT']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
      </xsl:if>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
