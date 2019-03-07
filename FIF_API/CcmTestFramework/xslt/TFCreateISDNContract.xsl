<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
   exclude-result-prefixes="dateutils">
   <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd" />
   <xsl:template match="/">
      <xsl:element name="CcmFifCommandList">
         <xsl:apply-templates select="request/request-params" />
      </xsl:element>
   </xsl:template>
   <xsl:template match="request-params">
      <!-- Copy over transaction ID,action name & override_system_date -->
      <xsl:element name="transaction_id">
         <xsl:value-of select="request-param[@name='transactionID']" />
      </xsl:element>
      <xsl:element name="client_name">TF</xsl:element>
      <xsl:element name="action_name">
         <xsl:value-of select="//request/action-name" />
      </xsl:element>
      <xsl:element name="override_system_date">
         <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']" />
      </xsl:element>
      <xsl:element name="Command_List">
         <!-- Create Order Form-->
         <xsl:element name="CcmFifCreateOrderFormCmd">
            <xsl:element name="command_id">create_order_form_1</xsl:element>
            <xsl:element name="CcmFifCreateOrderFormInCont">
               <xsl:element name="customer_number">
                  <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']" />
               </xsl:element>
               <xsl:element name="sales_org_num_value">
                  <xsl:value-of select="request-param[@name='SALES_ORG_NUM_VALUE']" />
               </xsl:element>
               <xsl:element name="doc_template_name">Vertrag</xsl:element>
            </xsl:element>
         </xsl:element>
         <!-- Add Product Commitment -->
         <xsl:element name="CcmFifAddProductCommitCmd">
            <xsl:element name="command_id">add_product_commitment_1</xsl:element>
            <xsl:element name="CcmFifAddProductCommitInCont">
               <xsl:element name="customer_number">
                  <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']" />
               </xsl:element>
               <xsl:element name="contract_number_ref">
                  <xsl:element name="command_id">create_order_form_1</xsl:element>
                  <xsl:element name="field_name">contract_number</xsl:element>
               </xsl:element>
               <xsl:element name="product_code">V0002</xsl:element>
               <xsl:element name="pricing_structure_code">
                  <xsl:value-of select="request-param[@name='PRICING_STRUCTURE_CODE']" />
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
                  <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']" />
               </xsl:element>
               <xsl:element name="product_commitment_number_ref">
                  <xsl:element name="command_id">add_product_commitment_1</xsl:element>
                  <xsl:element name="field_name">product_commitment_number</xsl:element>
               </xsl:element>
               <xsl:element name="product_subs_group_id">
                  <xsl:value-of select="request-param[@name='PRODUCT_SUBS_GROUP_ID']" />
               </xsl:element>
            </xsl:element>
         </xsl:element>
         
         <!-- Add V0010 -->
         <xsl:element name="CcmFifAddServiceSubsCmd">
            <xsl:element name="command_id">add_service_subscription_V0010</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
               <xsl:element name="product_subscription_ref">
                  <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                  <xsl:element name="field_name">product_subscription_id</xsl:element>
               </xsl:element>
               <xsl:element name="service_code">
                  <xsl:choose>
                     <xsl:when test="request-param[@name='LINE_TYPE'] = 'Premium'">V0010</xsl:when>
                     <xsl:when test="request-param[@name='LINE_TYPE'] = 'Basis'">V0003</xsl:when>
                     <xsl:otherwise>V0010</xsl:otherwise>
                  </xsl:choose>
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
               <xsl:element name="service_characteristic_list">
                  <!-- Access Number -->
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
                  <!-- configured values -->
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0060</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">1</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0124</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">0201</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0061</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">Arcor</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0081</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">Arcor</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0094</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">analog</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0127</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">Inhabername</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0131</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">N</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0132</xsl:element>
                     <xsl:element name="data_type">INTEGER</xsl:element>
                     <xsl:element name="configured_value">1</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0133</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">Neuanschluss</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0935</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">sekunde</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0090</xsl:element>
                     <xsl:element name="data_type">BOOLEAN</xsl:element>
                     <xsl:element name="configured_value">Y</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0093</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">DSL 1000</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifConfiguredValueCont">
                     <xsl:element name="service_char_code">V0008</xsl:element>
                     <xsl:element name="data_type">STRING</xsl:element>
                     <xsl:element name="configured_value">intial text</xsl:element>
                  </xsl:element>
                  <!-- Address -->
                  <xsl:element name="CcmFifAddressCharacteristicCont">
                     <xsl:element name="service_char_code">V0014</xsl:element>
                     <xsl:element name="data_type">ADDRESS</xsl:element>
                     <xsl:element name="address_id">
                        <xsl:value-of select="request-param[@name='ADDRESS_ID']" />
                     </xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifAddressCharacteristicCont">
                     <xsl:element name="service_char_code">V0126</xsl:element>
                     <xsl:element name="data_type">ADDRESS</xsl:element>
                     <xsl:element name="address_id">
                        <xsl:value-of select="request-param[@name='ADDRESS_ID']" />
                     </xsl:element>
                  </xsl:element>
               </xsl:element>
               <xsl:element name="detailed_reason_rd">
                  <xsl:value-of select="request-param[@name='DETAILED_REASON_RD']"/>
               </xsl:element>
            </xsl:element>
         </xsl:element>
         
         <xsl:if test="request-param[@name='CREATE_DSL_SERVICES'] != 'N'">
            <!-- Add V0113 -->
            <xsl:element name="CcmFifAddServiceSubsCmd">
               <xsl:element name="command_id">add_service_subscription_V0113</xsl:element>
               <xsl:element name="CcmFifAddServiceSubsInCont">
                  <xsl:element name="product_subscription_ref">
                     <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                     <xsl:element name="field_name">product_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="service_code">V0113</xsl:element>
                  <xsl:element name="parent_service_subs_ref">
                     <xsl:element name="command_id">add_service_subscription_V0010</xsl:element>
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
                  <xsl:element name="service_characteristic_list">
                     <!-- configured values -->
                     <xsl:element name="CcmFifConfiguredValueCont">
                        <xsl:element name="service_char_code">V0826</xsl:element>
                        <xsl:element name="data_type">STRING</xsl:element>
                        <xsl:element name="configured_value">DSL 1000</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifConfiguredValueCont">
                        <xsl:element name="service_char_code">V0092</xsl:element>
                        <xsl:element name="data_type">STRING</xsl:element>
                        <xsl:element name="configured_value">Standard</xsl:element>
                     </xsl:element>
                  </xsl:element>
                  <xsl:element name="detailed_reason_rd">
                     <xsl:value-of select="request-param[@name='DETAILED_REASON_RD']"/>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
            
            <xsl:variable name="bandwidthServiceCode">
               <xsl:choose>
                  <xsl:when test="request-param[@name='DSL_BANDWIDTH'] = 'DSL 2000'">V0174</xsl:when>
                  <xsl:when test="request-param[@name='DSL_BANDWIDTH'] = 'DSL 6000'">V0178</xsl:when>
                  <xsl:when test="request-param[@name='DSL_BANDWIDTH'] = 'DSL 16000'">V018C</xsl:when>
                  <xsl:otherwise>V0174</xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <!-- Add bandwidth -->
            <xsl:element name="CcmFifAddServiceSubsCmd">
               <xsl:element name="command_id">add_bandwidth_service_subscription</xsl:element>
               <xsl:element name="CcmFifAddServiceSubsInCont">
                  <xsl:element name="product_subscription_ref">
                     <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                     <xsl:element name="field_name">product_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="service_code">
                     <xsl:value-of select="$bandwidthServiceCode"/>
                  </xsl:element>
                  <xsl:element name="parent_service_subs_ref">
                     <xsl:element name="command_id">add_service_subscription_V0010</xsl:element>
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
                  <xsl:element name="detailed_reason_rd">
                     <xsl:value-of select="request-param[@name='DETAILED_REASON_RD']"/>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
            <!-- Add V0109 -->
            <xsl:element name="CcmFifAddServiceSubsCmd">
               <xsl:element name="command_id">add_service_subscription_V0109</xsl:element>
               <xsl:element name="CcmFifAddServiceSubsInCont">
                  <xsl:element name="product_subscription_ref">
                     <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                     <xsl:element name="field_name">product_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="service_code">V0109</xsl:element>
                  <xsl:element name="parent_service_subs_ref">
                     <xsl:element name="command_id">add_service_subscription_V0010</xsl:element>
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
                        <xsl:element name="configured_value">asd;asd;asd</xsl:element>
                     </xsl:element>
                     <xsl:element name="CcmFifConfiguredValueCont">
                        <xsl:element name="service_char_code">V0112</xsl:element>
                        <xsl:element name="data_type">STRING</xsl:element>
                        <xsl:element name="configured_value">undefined</xsl:element>
                     </xsl:element>
                  </xsl:element>
                  <xsl:element name="detailed_reason_rd">
                     <xsl:value-of select="request-param[@name='DETAILED_REASON_RD']"/>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:if>
         
         <!-- Calculate today and one day before the desired date -->
         <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
         <xsl:variable name="contributingItemDate" select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
         
         <xsl:for-each select="request-param-list[@name='TARIFF_OPTION_LIST']/request-param-list-item">
            <xsl:variable name="serviceCode">
               <xsl:value-of select="request-param[@name='SERVICE_CODE']"/>
            </xsl:variable>
            
            <!-- Add Feature Service -->
            <xsl:element name="CcmFifAddServiceSubsCmd">
               <xsl:element name="command_id">
                  <xsl:text>add_service_</xsl:text>
                  <xsl:value-of select="position()"/>
               </xsl:element>
               <xsl:element name="CcmFifAddServiceSubsInCont">
                  <xsl:element name="product_subscription_ref">
                     <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                     <xsl:element name="field_name">product_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="service_code">
                     <xsl:value-of select="$serviceCode"/>
                  </xsl:element>
                  <xsl:element name="parent_service_subs_ref">
                     <xsl:element name="command_id">add_service_subscription_V0010</xsl:element>
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
                  <xsl:element name="service_characteristic_list"/>
               </xsl:element>
            </xsl:element>
            
            
            <!-- Add contributing item, if the feature is a tariff option or country service -->
            <xsl:element name="CcmFifAddModifyContributingItemCmd">
               <xsl:element name="command_id">
                  <xsl:text>add_contributing_item_</xsl:text>
                  <xsl:value-of select="position()"/>
               </xsl:element>
               <xsl:element name="CcmFifAddModifyContributingItemInCont">
                  <xsl:element name="product_subscription_ref">
                     <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                     <xsl:element name="field_name">product_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="service_code">
                     <xsl:value-of select="$serviceCode"/>
                  </xsl:element>
                  <xsl:element name="effective_date">
                     <xsl:value-of select="$contributingItemDate"/>
                  </xsl:element>
                  <xsl:element name="contributing_item_list">
                     <xsl:element name="CcmFifContributingItem">
                        <xsl:element name="supported_object_type_rd">SERVICE_SUBSC</xsl:element>
                        <xsl:element name="start_date">
                           <xsl:value-of select="$contributingItemDate"/>
                        </xsl:element>
                        <xsl:element name="service_subscription_ref">
                           <xsl:element name="command_id">add_service_subscription_V0010</xsl:element>
                           <xsl:element name="field_name">service_subscription_id</xsl:element>
                        </xsl:element>
                     </xsl:element>
                  </xsl:element>
                  <xsl:element name="no_price_plan_error">N</xsl:element> 
               </xsl:element>
            </xsl:element>     
         </xsl:for-each>
         
         
         <!-- Create Customer Order for new services  -->
         <xsl:element name="CcmFifCreateCustOrderCmd">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="CcmFifCreateCustOrderInCont">
               <xsl:element name="customer_number">
                  <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']" />
               </xsl:element>
               <xsl:element name="cust_order_description">Testframework</xsl:element>
               <xsl:element name="customer_tracking_id">
                  <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']" />
               </xsl:element>
               <xsl:element name="service_ticket_pos_list">
                  <xsl:element name="CcmFifCommandRefCont">
                     <xsl:element name="command_id">add_service_subscription_V0010</xsl:element>
                     <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifCommandRefCont">
                     <xsl:element name="command_id">add_service_subscription_V0109</xsl:element>
                     <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifCommandRefCont">
                     <xsl:element name="command_id">add_service_subscription_V0017</xsl:element>
                     <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifCommandRefCont">
                     <xsl:element name="command_id">add_service_subscription_V0113</xsl:element>
                     <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifCommandRefCont">
                     <xsl:element name="command_id">add_bandwidth_service_subscription</xsl:element>
                     <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifCommandRefCont">
                     <xsl:element name="command_id">add_service_subscription_V0046</xsl:element>
                     <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                  </xsl:element>
                  <xsl:for-each select="request-param-list[@name='TARIFF_OPTION_LIST']/request-param-list-item">
                     <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">
                           <xsl:text>add_service_</xsl:text>
                           <xsl:value-of select="position()"/>
                        </xsl:element>
                        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                     </xsl:element>
                  </xsl:for-each>
               </xsl:element>
            </xsl:element>
         </xsl:element>
         <xsl:if test="request-param[@name='ACTIVATE_SERVICES'] = 'Y'">
            <!-- Release Customer Order -->
         <xsl:element name="CcmFifReleaseCustOrderCmd">
            <xsl:element name="CcmFifReleaseCustOrderInCont">
               <xsl:element name="customer_number">
                  <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']" />
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
