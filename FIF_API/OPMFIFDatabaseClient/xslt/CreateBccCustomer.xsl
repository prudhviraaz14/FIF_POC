<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for converting an OPM createBccCustomer request
  to a FIF transaction

  @author goethalo
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
    exclude-result-prefixes="dateutils">
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
  <xsl:template match="/">
    <xsl:element name="CcmFifCommandList">
      <xsl:apply-templates select="request/request-params"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="request-params">
    <!-- Transaction ID -->
    <xsl:element name="transaction_id">
      <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="client_name">OPM</xsl:element>
    <!-- Action name -->
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">
      <!-- Create Entity -->
      <xsl:element name="CcmFifCreateEntityCmd">
        <xsl:element name="command_id">create_entity_1</xsl:element>
        <xsl:element name="CcmFifCreateEntityInCont">
          <xsl:element name="entity_type">I</xsl:element>
          <xsl:element name="salutation_description">
            <xsl:value-of select="request-param[@name='ENTITY.SALUTATION']"/>
          </xsl:element>
          <xsl:element name="title_description">
            <xsl:value-of select="request-param[@name='ENTITY.TITLE']"/>
          </xsl:element>
          <xsl:element name="nobility_prefix_description">
            <xsl:value-of select="request-param[@name='ENTITY.NOBILITY_PREFIX']"/>
          </xsl:element>
          <xsl:element name="forename">
            <xsl:value-of select="request-param[@name='ENTITY.FORENAME']"/>
          </xsl:element>
          <xsl:element name="surname_prefix_description">
            <xsl:value-of select="request-param[@name='ENTITY.SURNAME_PREFIX']"/>
          </xsl:element>
          <xsl:element name="name">
            <xsl:value-of select="request-param[@name='ENTITY.SURNAME']"/>
          </xsl:element>
          <xsl:element name="birth_date">
            <xsl:value-of select="dateutils:convertOPMDate(request-param[@name='ENTITY.BIRTHDATE'])"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Address -->
      <xsl:element name="CcmFifCreateAddressCmd">
        <xsl:element name="command_id">create_address_1</xsl:element>
        <xsl:element name="CcmFifCreateAddressInCont">
          <xsl:element name="entity_ref">
            <xsl:element name="command_id">create_entity_1</xsl:element>
            <xsl:element name="field_name">entity_id</xsl:element>
          </xsl:element>
          <xsl:element name="address_type">STD</xsl:element>
          <xsl:element name="street_name">
            <xsl:value-of select="request-param[@name='ADDRESS.STREET_NAME']"/>
          </xsl:element>
          <xsl:element name="street_number">
            <xsl:value-of select="request-param[@name='ADDRESS.NUMBER']"/>
          </xsl:element>
          <xsl:element name="street_number_suffix">
            <xsl:value-of select="request-param[@name='ADDRESS.NUMBER_SUFFIX']"/>
          </xsl:element>
          <xsl:element name="postal_code">
            <xsl:value-of select="request-param[@name='ADDRESS.POSTAL_CODE']"/>
          </xsl:element>
          <xsl:element name="city_name">
            <xsl:value-of select="request-param[@name='ADDRESS.CITY']"/>
          </xsl:element>
          <xsl:element name="city_suffix_name">
            <xsl:value-of select="request-param[@name='ADDRESS.CITY_SUFFIX']"/>
          </xsl:element>
          <xsl:element name="country_code">DE</xsl:element>
          <xsl:element name="address_additional_text">
            <xsl:value-of select="request-param[@name='ADDRESS.ADDITIONAL_TEXT']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Customer -->
      <xsl:element name="CcmFifCreateCustomerCmd">
        <xsl:element name="command_id">create_customer_1</xsl:element>
        <xsl:element name="CcmFifCreateCustomerInCont">
          <xsl:element name="entity_ref">
            <xsl:element name="command_id">create_entity_1</xsl:element>
            <xsl:element name="field_name">entity_id</xsl:element>
          </xsl:element>
          <xsl:element name="address_ref">
            <xsl:element name="command_id">create_address_1</xsl:element>
            <xsl:element name="field_name">address_id</xsl:element>
          </xsl:element>
          <xsl:element name="user_password">
            <xsl:value-of select="request-param[@name='CUSTOMER.USER_PASSWORD']"/>
          </xsl:element>
          <xsl:element name="match_code_id">
            <xsl:value-of select="translate(substring(request-param[@name='ENTITY.SURNAME'],1,20),'abcdefghijklmnopqrstuvwxyzöäüß','ABCDEFGHIJKLMNOPQRSTUVWXYZÖÄÜß')"/>
          </xsl:element>
          <xsl:element name="customer_group_rd">
            <xsl:value-of select="request-param[@name='CUSTOMER.CUSTOMER_GROUP']"/>
          </xsl:element>
          <xsl:element name="category_rd">RESIDENTIAL</xsl:element>
          <xsl:element name="classification_rd">E</xsl:element>
          <xsl:element name="tax_exempt_indicator">N</xsl:element>
          <xsl:element name="masking_digits_rd">0</xsl:element>
          <xsl:element name="storage_masking_digits_rd">0</xsl:element>
          <xsl:element name="payment_method_rd">DIRECT_DEBIT</xsl:element>
          <xsl:element name="payment_term_rd">0</xsl:element>
          <xsl:element name="cycle_name">
            <xsl:value-of select="request-param[@name='CUSTOMER.BILL_CYCLE']"/>
          </xsl:element>
          <xsl:element name="prospect_indicator">N</xsl:element>
          <xsl:element name="credit_check_result_indicator">Y</xsl:element>
          <xsl:if test="request-param[@name='CUSTOMER.RISK_CATEGORY'] = 'OK'">
            <xsl:element name="risk_category_rd">OK_IC</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='CUSTOMER.RISK_CATEGORY'] = 'KI'">
            <xsl:element name="risk_category_rd">KI</xsl:element>
          </xsl:if>
        </xsl:element>
      </xsl:element>

      <!-- Create Access Information -->
      <xsl:element name="CcmFifUpdateAccessInformCmd">
        <xsl:element name="command_id">create_access_1</xsl:element>
        <xsl:element name="CcmFifUpdateAccessInformInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">create_customer_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="entity_ref">
            <xsl:element name="command_id">create_entity_1</xsl:element>
            <xsl:element name="field_name">entity_id</xsl:element>
          </xsl:element>
          <xsl:element name="access_information_type_rd">STD</xsl:element>
          <xsl:element name="phone_number">
            <xsl:value-of select="request-param[@name='ACCESS.PHONE_NUMBER']"/>
          </xsl:element>
          <xsl:element name="mobile_number">
            <xsl:value-of select="request-param[@name='ACCESS.MOBILE_NUMBER']"/>
          </xsl:element>
          <xsl:element name="fax_number">
            <xsl:value-of select="request-param[@name='ACCESS.FAX_NUMBER']"/>
          </xsl:element>
          <xsl:element name="email_address">
            <xsl:value-of select="request-param[@name='ACCESS.EMAIL_ADDRESS']"/>
          </xsl:element>
          <xsl:element name="electronic_contact_indicator">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Mailing -->
      <xsl:element name="CcmFifCreateMailingCmd">
        <xsl:element name="command_id">create_mailing_1</xsl:element>
        <xsl:element name="CcmFifCreateMailingInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">create_customer_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="address_ref">
            <xsl:element name="command_id">create_address_1</xsl:element>
            <xsl:element name="field_name">address_id</xsl:element>
          </xsl:element>
          <xsl:element name="access_information_ref">
            <xsl:element name="command_id">create_access_1</xsl:element>
            <xsl:element name="field_name">access_information_id</xsl:element>
          </xsl:element>
          <xsl:element name="mailing_name">Rechnung</xsl:element>
          <xsl:element name="document_type_rd">BILL</xsl:element>
          <xsl:element name="marketing_information_ind">Y</xsl:element>
          <xsl:element name="table_of_contents_ind">N</xsl:element>
          <xsl:element name="printer_destination_rd">webBill</xsl:element>
          <xsl:element name="verification_counter_value">0</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Bank Account -->
      <xsl:element name="CcmFifCreateBankAccountCmd">
        <xsl:element name="command_id">create_bank_account_1</xsl:element>
        <xsl:element name="CcmFifCreateBankAccountInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">create_customer_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="bank_account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT.NUMBER']"/>
          </xsl:element>
          <xsl:element name="owner_full_name">
            <xsl:value-of select="request-param[@name='ACCOUNT.OWNER_NAME']"/>
          </xsl:element>
          <xsl:element name="bank_clearing_code">
            <xsl:value-of select="request-param[@name='ACCOUNT.BANK_CLEARING_CODE']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Account -->
      <xsl:element name="CcmFifCreateAccountCmd">
        <xsl:element name="command_id">create_account_1</xsl:element>
        <xsl:element name="CcmFifCreateAccountInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">create_customer_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="bank_account_id_ref">
            <xsl:element name="command_id">create_bank_account_1</xsl:element>
            <xsl:element name="field_name">bank_account_id</xsl:element>
          </xsl:element>
          <xsl:element name="mailing_id_ref">
            <xsl:element name="command_id">create_mailing_1</xsl:element>
            <xsl:element name="field_name">mailing_id</xsl:element>
          </xsl:element>
          <xsl:element name="doc_template_name">Rechnung</xsl:element>
          <xsl:element name="method_of_payment">DIRECT_DEBIT</xsl:element>
          <xsl:element name="manual_suspend_ind">Y</xsl:element>
          <xsl:element name="language_rd">ger</xsl:element>
          <xsl:element name="currency_rd">EUR</xsl:element>
          <xsl:element name="cycle_name">
            <xsl:value-of select="request-param[@name='CUSTOMER.BILL_CYCLE']"/>
          </xsl:element>
          <xsl:element name="payment_term_rd">0</xsl:element>
          <xsl:element name="usage_limit">99999999.99</xsl:element>
          <xsl:element name="customer_account_id"></xsl:element>
          <xsl:element name="output_device_rd">PRINTER</xsl:element>
          <xsl:element name="direct_debit_authoriz_date">
            <xsl:value-of select="dateutils:convertOPMDate(request-param[@name='ACCOUNT.DIRECT_DEBIT_AUTHORIZATION_DATE'])"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Document Pattern -->
      <xsl:element name="CcmFifCreateDocumentPatternCmd">
        <xsl:element name="command_id">create_document pattern_1</xsl:element>
        <xsl:element name="CcmFifCreateDocumentPatternInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">create_customer_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">create_account_1</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="mailing_id_ref">
            <xsl:element name="command_id">create_mailing_1</xsl:element>
            <xsl:element name="field_name">mailing_id</xsl:element>
          </xsl:element>
          <xsl:element name="output_device_rd">WEBBILL</xsl:element>
          <xsl:element name="doc_template_name">webBill mit EGN</xsl:element>
          <xsl:element name="cycle_name">
            <xsl:value-of select="request-param[@name='CUSTOMER.BILL_CYCLE']"/>
          </xsl:element>
          <xsl:element name="currency_rd">EUR</xsl:element>
          <xsl:element name="hierarchy_indicator">N</xsl:element>
          <xsl:element name="zero_suppress_indicator">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Order Form -->
      <xsl:element name="CcmFifCreateOrderFormCmd">
        <xsl:element name="command_id">create_order_form_1</xsl:element>
        <xsl:element name="CcmFifCreateOrderFormInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">create_customer_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="sales_org_num_value">
            <xsl:value-of select="request-param[@name='TRANSACTION.SALES_ORG_NUMBER']"/>
          </xsl:element>
          <xsl:element name="doc_template_name">Vertrag</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Add Product Commitment -->
      <xsl:element name="CcmFifAddProductCommitCmd">
        <xsl:element name="command_id">add_product_commit_1</xsl:element>
        <xsl:element name="CcmFifAddProductCommitInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">create_customer_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">create_order_form_1</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <!-- TODO: Change this to the real values -->
          <xsl:element name="product_code">V0001</xsl:element>
          <xsl:element name="pricing_structure_code">V0325</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Sign Order Form -->
      <xsl:element name="CcmFifSignOrderFormCmd">
        <xsl:element name="command_id">sign_order_form_1</xsl:element>
        <xsl:element name="CcmFifSignOrderFormInCont">
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">create_order_form_1</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <xsl:element name="board_sign_name">ARCOR</xsl:element>
          <xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Add Product Subscription -->
      <xsl:element name="CcmFifAddProductSubsCmd">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="CcmFifAddProductSubsInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">create_customer_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="product_commitment_number_ref">
            <xsl:element name="command_id">add_product_commit_1</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Add Service Subscription for Voice -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_subscription_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <!-- TODO: Replace by real service -->
          <xsl:element name="service_code">V0004</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Ruffnummer -->
            <xsl:element name="CcmFifAccessNumberCont">
              <xsl:element name="service_char_code">V0001</xsl:element>
              <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
              <xsl:element name="country_code">49</xsl:element>
              <xsl:element name="city_code">211</xsl:element>
              <xsl:element name="local_number">53550</xsl:element>
            </xsl:element>
			<!-- Service provider -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0010</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">TEST_PROVIDER</xsl:element>
            </xsl:element>
            <!-- Name/Firma 1. Anschlussinhaber -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0127</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
              	<xsl:value-of select="request-param[@name='ENTITY.SURNAME']"/>
              </xsl:element>
            </xsl:element>
            <!-- Vorname 1. Anschlussinhaber -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0128</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
              	<xsl:value-of select="request-param[@name='ENTITY.FORENAME']"/>
              </xsl:element>
            </xsl:element>
            <!-- TODO: Replace by real list -->
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Add Service Subscription for Preselection -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_subscription_2</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <!-- TODO: Replace by real service -->
          <xsl:element name="service_code">V0009</xsl:element>
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">add_service_subscription_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">create_account_1</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- TODO: Replace by real list -->
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Customer Order for Voice -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_customer_order_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">create_customer_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='TRANSACTION.BARCODE_ID']"/>
          </xsl:element>
          <xsl:element name="provider_tracking_no">001</xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_subscription_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Customer Order for Preselection -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_customer_order_2</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">create_customer_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='TRANSACTION.BARCODE_ID']"/>
          </xsl:element>
          <xsl:element name="provider_tracking_no">002</xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_subscription_2</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Release Customer Order -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">create_customer_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Release Customer Order -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">create_customer_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_customer_order_2</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
