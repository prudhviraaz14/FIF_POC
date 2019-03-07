<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
   XSLT file for updating customer information
   exclude-result-prefixes="dateutils" 
   @author banania
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
   <xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1" indent="yes" method="xml"/>
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

         <!-- Find Service Subscription by Service Subscription Id -->
         <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
               <xsl:element name="service_subscription_id">
                  <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
               </xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- Get Order Form Data -->
         <xsl:element name="CcmFifGetOrderFormDataCmd">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="CcmFifGetOrderFormDataInCont">
               <xsl:element name="contract_number_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">contract_number</xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- Validate Get Old Price Plan Code -->
         <xsl:element name="CcmFifGetProdCommitContCmd">
            <xsl:element name="command_id">get_product_commitment</xsl:element>
            <xsl:element name="CcmFifGetProdCommitContInCont">
               <xsl:element name="prod_commit_ref">
                  <xsl:element name="command_id">get_order_form_data_1</xsl:element>
                  <xsl:element name="field_name">product_commit_list</xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- Validate Pricing Structure -->
         <xsl:element name="CcmFifValidateValueCmd">
            <xsl:element name="command_id">validate_price_plan_code_1</xsl:element>
            <xsl:element name="CcmFifValidateValueInCont">
               <xsl:element name="value_ref">
                  <xsl:element name="command_id">get_product_commitment</xsl:element>
                  <xsl:element name="field_name">pricing_structure_code</xsl:element>
               </xsl:element>
               <xsl:element name="object_type">PRODUCT_COMMITMENT</xsl:element>
               <xsl:element name="value_type">PRICING_STRUCTURE_CODE</xsl:element>
               <xsl:element name="allowed_values">
                  <xsl:element name="CcmFifPassingValueCont">
                     <xsl:element name="value">
                        <xsl:value-of select="request-param[@name='OLD_PRICING_STRUCTURE_CODE']"/>
                     </xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- Get Account Data -->
         <xsl:element name="CcmFifGetAccountDataCmd">
            <xsl:element name="command_id">get_account_data_1</xsl:element>
            <xsl:element name="CcmFifGetAccountDataInCont">
               <xsl:element name="account_number_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">account_number</xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- Get Cycle Data -->
         <xsl:element name="CcmFifGetCycleCmd">
            <xsl:element name="command_id">get_cycle_1</xsl:element>
            <xsl:element name="CcmFifGetCycleInCont">
               <xsl:element name="cycle_name_ref">
                  <xsl:element name="command_id">get_account_data_1</xsl:element>
                  <xsl:element name="field_name">cycle_name</xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- Renegotiate Order Form  -->
         <xsl:element name="CcmFifRenegotiateOrderFormCmd">
            <xsl:element name="command_id">renegotiate_order_form_1</xsl:element>
            <xsl:element name="CcmFifRenegotiateOrderFormInCont">
               <xsl:element name="contract_number_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">contract_number</xsl:element>
               </xsl:element>
               <xsl:element name="product_commit_list">
                  <xsl:element name="CcmFifProductCommitCont">
                     <xsl:element name="new_pricing_structure_code">
                        <xsl:value-of select="request-param[@name='NEW_PRICING_STRUCTURE_CODE']"/>
                     </xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- Sign and Apply a new pricing structure  -->
         <xsl:element name="CcmFifSignAndApplyNewPricingStructCmd">
            <xsl:element name="command_id">sign_apply_1</xsl:element>
            <xsl:element name="CcmFifSignAndApplyNewPricingStructInCont">
               <xsl:element name="supported_object_id_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">contract_number</xsl:element>
               </xsl:element>
               <xsl:element name="supported_object_type_rd">O</xsl:element>
               <xsl:element name="apply_swap_date_ref">
                  <xsl:element name="command_id">get_cycle_1</xsl:element>
                  <xsl:element name="field_name">due_date</xsl:element>
               </xsl:element>
               <xsl:element name="board_sign_name">ARCOR</xsl:element>
               <xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
               <xsl:element name="customer_order_id_ref">
                  <xsl:element name="command_id">create_co_1</xsl:element>
                  <xsl:element name="field_name">customer_order_id</xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:element>

         <xsl:variable name="addServiceCommandId">add_service_</xsl:variable>
         <xsl:for-each
            select="request-param-list[@name='TARIFF_OPTION_SERVICE_LIST']/request-param-list-item">
            <xsl:variable name="serviceCode" select="request-param[@name='SERVICE_CODE']"/>
            <!-- Add new tariff option service -->
            <xsl:element name="CcmFifAddServiceSubsCmd">
               <xsl:element name="command_id">
                  <xsl:value-of select="concat($addServiceCommandId, $serviceCode)"/>
               </xsl:element>
               <xsl:element name="CcmFifAddServiceSubsInCont">
                  <xsl:element name="product_subscription_ref">
                     <xsl:element name="command_id">find_service_1</xsl:element>
                     <xsl:element name="field_name">product_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="service_code">
                     <xsl:value-of select="request-param[@name='SERVICE_CODE']"/>
                  </xsl:element>
                  <xsl:element name="parent_service_subs_ref">
                     <xsl:element name="command_id">find_service_1</xsl:element>
                     <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="desired_date_ref">
                     <xsl:element name="command_id">get_cycle_1</xsl:element>
                     <xsl:element name="field_name">due_date</xsl:element>
                  </xsl:element>
                  <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
                  <xsl:element name="reason_rd">NOT_RELEVANT</xsl:element>
                  <xsl:element name="account_number_ref">
                     <xsl:element name="command_id">find_service_1</xsl:element>
                     <xsl:element name="field_name">account_number</xsl:element>
                  </xsl:element>
                  <xsl:element name="ignore_if_service_exist">Y</xsl:element>
                  <xsl:element name="service_characteristic_list"/>
               </xsl:element>
            </xsl:element>

            <!-- Add contributing items -->
            <xsl:element name="CcmFifAddModifyContributingItemCmd">
               <xsl:element name="CcmFifAddModifyContributingItemInCont">
                  <xsl:element name="product_subscription_ref">
                     <xsl:element name="command_id">find_service_1</xsl:element>
                     <xsl:element name="field_name">product_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="service_code">
                     <xsl:value-of select="request-param[@name='SERVICE_CODE']"/>
                  </xsl:element>
                  <!-- search date -->
                  <xsl:element name="effective_date_ref">
                     <xsl:element name="command_id">get_cycle_1</xsl:element>
                     <xsl:element name="field_name">due_date</xsl:element>
                  </xsl:element>
                  <xsl:element name="contributing_item_list">
                     <xsl:element name="CcmFifContributingItem">
                        <xsl:element name="supported_object_type_rd">SERVICE_SUBSC</xsl:element>
                        <!-- ToDO start date by reference-->
                        <xsl:element name="start_date_ref">
                           <xsl:element name="command_id">get_cycle_1</xsl:element>
                           <xsl:element name="field_name">due_date</xsl:element>
                        </xsl:element>
                        <xsl:element name="service_subscription_ref">
                           <xsl:element name="command_id">find_service_1</xsl:element>
                           <xsl:element name="field_name">service_subscription_id</xsl:element>
                        </xsl:element>
                     </xsl:element>
                  </xsl:element>
                  <xsl:element name="no_price_plan_error">N</xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:for-each>

         <xsl:if
            test="count(request-param-list[@name='TARIFF_OPTION_SERVICE_LIST']/request-param-list-item) != 0">
            <!-- Create Customer Order for tariff option Services -->
            <xsl:element name="CcmFifCreateCustOrderCmd">
               <xsl:element name="command_id">create_co_1</xsl:element>
               <xsl:element name="CcmFifCreateCustOrderInCont">
                  <xsl:element name="customer_number_ref">
                     <xsl:element name="command_id">find_service_1</xsl:element>
                     <xsl:element name="field_name">customer_number</xsl:element>
                  </xsl:element>
                  <xsl:element name="cust_order_description">Tarifoption-Änderung</xsl:element>
                  <xsl:element name="service_ticket_pos_list">
                     <xsl:for-each
                        select="request-param-list[@name='TARIFF_OPTION_SERVICE_LIST']/request-param-list-item">
                        <xsl:variable name="serviceCode"
                           select="request-param[@name='SERVICE_CODE']"/>
                        <xsl:element name="CcmFifCommandRefCont">
                           <xsl:element name="command_id">
                              <xsl:value-of select="concat($addServiceCommandId, $serviceCode)"/>
                           </xsl:element>
                           <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                        </xsl:element>
                     </xsl:for-each>
                     <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">add_service_1</xsl:element>
                        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                     </xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>

            <!-- Release stand alone Customer Order for add and terminate discount Services -->
            <xsl:element name="CcmFifReleaseCustOrderCmd">
               <xsl:element name="CcmFifReleaseCustOrderInCont">
                  <xsl:element name="customer_number_ref">
                     <xsl:element name="command_id">find_service_1</xsl:element>
                     <xsl:element name="field_name">customer_number</xsl:element>
                  </xsl:element>
                  <xsl:element name="customer_order_ref">
                     <xsl:element name="command_id">create_co_1</xsl:element>
                     <xsl:element name="field_name">customer_order_id</xsl:element>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:if>

         <!-- create contact -->
         <xsl:element name="CcmFifCreateContactCmd">
            <xsl:element name="command_id">create_cont_1</xsl:element>
            <xsl:element name="CcmFifCreateContactInCont">
               <xsl:element name="customer_number_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
               </xsl:element>
               <xsl:element name="contact_type_rd">INFO</xsl:element>
               <xsl:element name="short_description">IT-17259-Migration</xsl:element>
               <xsl:element name="long_description_text">IT-17259: Änderung Tarifoptionen</xsl:element>
            </xsl:element>
         </xsl:element>

      </xsl:element>
   </xsl:template>
</xsl:stylesheet>
