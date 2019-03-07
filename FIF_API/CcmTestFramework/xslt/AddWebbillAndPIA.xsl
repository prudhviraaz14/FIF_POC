<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for converting an OPM addWebbillAndPIA request
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
      <!-- Get Entity Information -->
      <xsl:element name="CcmFifGetEntityCmd">
        <xsl:element name="command_id">get_entity_1</xsl:element>
        <xsl:element name="CcmFifGetEntityInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER.CUSTOMER_NUMBER']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Modify Access Information -->
      <xsl:element name="CcmFifUpdateAccessInformCmd">
        <xsl:element name="command_id">modify_access_1</xsl:element>
        <xsl:element name="CcmFifUpdateAccessInformInCont">
          <xsl:element name="access_information_ref">
            <xsl:element name="command_id">get_entity_1</xsl:element>
            <xsl:element name="field_name">primary_access_info_id</xsl:element>
          </xsl:element>
          <xsl:element name="email_address">
            <xsl:value-of select="request-param[@name='ACCESS.EMAIL_ADDRESS']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Mailing -->
      <xsl:element name="CcmFifCreateMailingCmd">
        <xsl:element name="command_id">create_mailing_1</xsl:element>
        <xsl:element name="CcmFifCreateMailingInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER.CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="address_ref">
            <xsl:element name="command_id">get_entity_1</xsl:element>
            <xsl:element name="field_name">primary_address_id</xsl:element>
          </xsl:element>
          <xsl:element name="access_information_ref">
            <xsl:element name="command_id">get_entity_1</xsl:element>
            <xsl:element name="field_name">primary_access_info_id</xsl:element>
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
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER.CUSTOMER_NUMBER']"/>
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

	  <!-- Modify the account -->
      <xsl:element name="CcmFifModifyAccountCmd">
        <xsl:element name="command_id">modify_account_1</xsl:element>
        <xsl:element name="CcmFifModifyAccountInCont">
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT.ACCOUNT_NUMBER']"/>
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
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER.CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT.ACCOUNT_NUMBER']"/>
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

      <!-- Create Order Form for PIA -->
      <xsl:element name="CcmFifCreateOrderFormCmd">
        <xsl:element name="command_id">create_order_form_1</xsl:element>
        <xsl:element name="CcmFifCreateOrderFormInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER.CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="sales_org_num_value">
            <xsl:value-of select="request-param[@name='TRANSACTION.SALES_ORG_NUMBER']"/>
          </xsl:element>
          <xsl:element name="doc_template_name">Vertrag</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Add Product Commitment for PIA -->
      <xsl:element name="CcmFifAddProductCommitCmd">
        <xsl:element name="command_id">add_product_commit_1</xsl:element>
        <xsl:element name="CcmFifAddProductCommitInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER.CUSTOMER_NUMBER']"/>
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
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER.CUSTOMER_NUMBER']"/>
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
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER.CUSTOMER_NUMBER']"/>
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
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER.CUSTOMER_NUMBER']"/>
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

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
