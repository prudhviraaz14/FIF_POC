<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!--
  XSLT file for creating a FIF request for creating an order from and a product commitment.

  @author schwarje
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
      <!-- Create Order Form-->
      <xsl:element name="CcmFifCreateOrderFormCmd">
        <xsl:element name="command_id">create_order_form_1</xsl:element>
        <xsl:element name="CcmFifCreateOrderFormInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="sales_org_num_value">
            <xsl:value-of select="request-param[@name='SALES_ORG_NUM_VALUE']"/>
          </xsl:element>
          <xsl:element name="doc_template_name">Vertrag</xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Add Product Commitment -->
      <xsl:element name="CcmFifAddProductCommitCmd">
        <xsl:element name="command_id">add_product_commitment_1</xsl:element>
        <xsl:element name="CcmFifAddProductCommitInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">create_order_form_1</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <xsl:element name="product_code">I1201</xsl:element>
          <xsl:element name="pricing_structure_code">
            <xsl:value-of select="request-param[@name='PRICING_STRUCTURE_CODE']"/>
          </xsl:element>
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
          <xsl:element name="board_sign_name">Arcor</xsl:element>
          <xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
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
            <xsl:element name="command_id">add_product_commitment_1</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
          <xsl:element name="product_subs_group_id">
            <xsl:value-of select="request-param[@name='PRODUCT_SUBS_GROUP_ID']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Add I1040 -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_subscription_I1040</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">I1040</xsl:element>
          <xsl:if test="request-param[@name='DESIRED_DATE'] != ''">
            <xsl:element name="desired_date">
              <xsl:value-of select="request-param[@name='DESIRED_DATE']" />
            </xsl:element>
            <xsl:element name="desired_schedule_type">
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']" />
            </xsl:element>
          </xsl:if>          
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="service_characteristic_list">
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I0610</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Mailbox</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifAccessNumberCont">
              <xsl:element name="service_char_code">I9058</xsl:element>
              <xsl:element name="data_type">USER_ACCOUNT_NUM</xsl:element>
              <xsl:element name="network_account">
                <xsl:value-of select="request-param[@name='ONLINE_ACCOUNT']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I0590</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">00012135464:arcor-online</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Add I1043 -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_subscription_I1043</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">I1043</xsl:element>
          <xsl:if test="request-param[@name='DESIRED_DATE'] != ''">
            <xsl:element name="desired_date">
              <xsl:value-of select="request-param[@name='DESIRED_DATE']" />
            </xsl:element>
            <xsl:element name="desired_schedule_type">
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']" />
            </xsl:element>
          </xsl:if>
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="service_characteristic_list">
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1007</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">extauftrnr</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifAccessNumberCont">
              <xsl:element name="service_char_code">V0001</xsl:element>
              <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
              <xsl:element name="masking_digits_rd">1</xsl:element>
              <xsl:element name="country_code">
                <xsl:value-of select="request-param[@name='COUNTRY_CODE']" />
              </xsl:element>
              <xsl:element name="city_code">
                <xsl:value-of select="request-param[@name='CITY_CODE']" />
              </xsl:element>
              <xsl:element name="local_number">
                <xsl:value-of select="request-param[@name='LOCAL_NUMBER']" />
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifAddressCharacteristicCont">
              <xsl:element name="service_char_code">V0014</xsl:element>
              <xsl:element name="data_type">ADDRESS</xsl:element>
              <xsl:element name="address_id">
                <xsl:value-of select="request-param[@name='ADDRESS_ID']" />
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Add V0174 -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_subscription_V0174</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V0174</xsl:element>
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">add_service_subscription_I1043</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='DESIRED_DATE'] != ''">
            <xsl:element name="desired_date">
              <xsl:value-of select="request-param[@name='DESIRED_DATE']" />
            </xsl:element>
            <xsl:element name="desired_schedule_type">
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']" />
            </xsl:element>
          </xsl:if>
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']" />
          </xsl:element>
          <xsl:element name="service_characteristic_list" />
        </xsl:element>
      </xsl:element>      
      <!-- Add V0198 -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_subscription_V0198</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V0198</xsl:element>
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">add_service_subscription_V0174</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='DESIRED_DATE'] != ''">
            <xsl:element name="desired_date">
              <xsl:value-of select="request-param[@name='DESIRED_DATE']" />
            </xsl:element>
            <xsl:element name="desired_schedule_type">
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']" />
            </xsl:element>
          </xsl:if>
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']" />
          </xsl:element>
          <xsl:element name="service_characteristic_list" />
        </xsl:element>
      </xsl:element>      
      <!-- Add V0114 -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_subscription_V0114</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V0114</xsl:element>
          <xsl:if test="request-param[@name='DESIRED_DATE'] != ''">
            <xsl:element name="desired_date">
              <xsl:value-of select="request-param[@name='DESIRED_DATE']" />
            </xsl:element>
            <xsl:element name="desired_schedule_type">
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']" />
            </xsl:element>
          </xsl:if>
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']" />
          </xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Address -->
            <xsl:element name="CcmFifAddressCharacteristicCont">
              <xsl:element name="service_char_code">V0111</xsl:element>
              <xsl:element name="data_type">ADDRESS</xsl:element>
              <xsl:element name="address_id">
                <xsl:value-of select="request-param[@name='ADDRESS_ID']" />
              </xsl:element>
            </xsl:element>
            <!-- configured values -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0110</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">lie;fern;ame</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0112</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">undefined</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Customer Order for new services  -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="cust_order_description">Testframework</xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_subscription_I1040</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_subscription_I1043</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_subscription_V0114</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_subscription_V0174</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_subscription_V0198</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <xsl:if test="request-param[@name='ACTIVATE_SERVICES'] != 'N'">
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
        <!-- activate the services -->
        <xsl:element name="CcmFifSimulateActivationByOpCmd">
          <xsl:element name="command_id">simulate_activation_by_op_1</xsl:element>
          <xsl:element name="CcmFifSimulateActivationByOpInCont">
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">create_co_1</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
