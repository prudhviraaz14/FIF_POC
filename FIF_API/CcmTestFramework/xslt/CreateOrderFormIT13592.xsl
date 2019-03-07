<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating new contracts according to the IT-13592
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
    <xsl:element name="client_name">SLS</xsl:element>
    <!-- Action name -->
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">
	  <!-- Lock the Customer -->
      <xsl:element name="CcmFifLockObjectCmd">
        <xsl:element name="command_id">lock_customer_1</xsl:element>
        <xsl:element name="CcmFifLockObjectInCont">
          <xsl:element name="object_id">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="object_type">CUSTOMER</xsl:element>
        </xsl:element>
      </xsl:element>

	  <!-- validate that customer does not have an order form for the product V9008 -->
      <xsl:element name="CcmFifValidateOrderFormProductCodeCmd">
        <xsl:element name="command_id">validate_OF</xsl:element>
        <xsl:element name="CcmFifValidateOrderFormProductCodeInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="product_code">V9008</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Order Form  -->
      <xsl:element name="CcmFifCreateOrderFormCmd">
        <xsl:element name="command_id">create_order_form_1</xsl:element>
        <xsl:element name="CcmFifCreateOrderFormInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="sales_org_num_value">
            <xsl:value-of select="request-param[@name='CIO_DATA']"/>
          </xsl:element>
          <xsl:element name="doc_template_name">Vertrag</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Add Product Commitment -->
      <xsl:element name="CcmFifAddProductCommitCmd">
        <xsl:element name="command_id">add_product_commit_1</xsl:element>
        <xsl:element name="CcmFifAddProductCommitInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">create_order_form_1</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <!-- TODO: Change this to the real values -->
          <xsl:element name="product_code">V9008</xsl:element>
          <xsl:element name="pricing_structure_code">V9002</xsl:element>
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
          <xsl:element name="board_sign_name">
            <xsl:value-of select="request-param[@name='BOARD_SIGN_NAME']"/>
          </xsl:element>
          <xsl:element name="primary_cust_sign_name">
            <xsl:value-of select="request-param[@name='PRIMARY_CUST_SIGN_NAME']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Add Product Subscription -->
      <xsl:element name="CcmFifAddProductSubsCmd">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="CcmFifAddProductSubsInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="product_commitment_number_ref">
            <xsl:element name="command_id">add_product_commit_1</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Add Service Subscription -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_subscription_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V9001</xsl:element>
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="service_characteristic_list"/>
        </xsl:element>
      </xsl:element>

      <!-- Add contributing items -->
      <xsl:element name="CcmFifAddModifyContributingItemCmd">
        <xsl:element name="command_id">add_contrib_item_1</xsl:element>
        <xsl:element name="CcmFifAddModifyContributingItemInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="price_plan_code">V9428</xsl:element>
          
          <xsl:variable name="StartDate" select="dateutils:getCurrentDate()" />
          
          <xsl:element name="contributing_item_list">
            <xsl:element name="CcmFifContributingItem">
              <xsl:element name="supported_object_type_rd">ACCOUNT</xsl:element>
              <xsl:element name="start_date">
                <xsl:value-of select="$StartDate"/>
              </xsl:element>
              <xsl:element name="account_number">
                <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
              </xsl:element>                  	
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Customer Order -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_subscription_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Release Customer Order -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
