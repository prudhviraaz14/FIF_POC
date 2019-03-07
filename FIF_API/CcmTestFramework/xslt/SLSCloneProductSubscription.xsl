<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for cloning a product subscription
  
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

      <!-- Validate Future Dated Apply Exists -->
      <xsl:element name="CcmFifValidateFutureDatedApplyExistsCmd">
        <xsl:element name="command_id">validate_future_apply_1</xsl:element>
        <xsl:element name="CcmFifValidateFutureDatedApplyExistsInCont">
          <xsl:element name="product_subscription_id">
            <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
            
      <!-- Get Order Form Data -->
      <xsl:element name="CcmFifGetOrderFormDataCmd">
        <xsl:element name="command_id">get_order_form_data_1</xsl:element>
        <xsl:element name="CcmFifGetOrderFormDataInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
            
      <!-- Get Price Plan Data -->
      <xsl:element name="CcmFifGetPricePlanDataForProductSubsCmd">
        <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
        <xsl:element name="CcmFifGetPricePlanDataForProductSubsInCont">
          <xsl:element name="product_subscription_id">
            <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="new_data_only_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
            
      <!-- Rollback Apply New Pricing Structure -->
      <xsl:element name="CcmFifRollbackApplyNewPriceStructCmd">
        <xsl:element name="command_id">rollback_1</xsl:element>
        <xsl:element name="CcmFifRollbackApplyNewPriceStructInCont">
          <xsl:element name="supported_object_id">
            <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">ORDERFORM</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Clone Product Subscription -->
      <xsl:element name="CcmFifCloneProductSubsCmd">
        <xsl:element name="command_id">clone_ps_1</xsl:element>
        <xsl:element name="CcmFifCloneProductSubsInCont">
          <xsl:element name="product_subscription_id">
            <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='CLONE_DATE']"/>
          </xsl:element>
          <xsl:element name="service_code_list">
            <xsl:for-each select="request-param-list[@name='SERVICE_CODE_LIST']/request-param-list-item">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">
                  <xsl:value-of select="request-param[@name='SERVICE_CODE']"/>
                </xsl:element>
              </xsl:element>
            </xsl:for-each>
          </xsl:element>
          <xsl:element name="directory_entry_service_code">V0100</xsl:element>
          <xsl:element name="service_characteristic_list"></xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Renegotiate Order Form -->
      <xsl:element name="CcmFifRenegotiateOrderFormCmd">
        <xsl:element name="command_id">renegotiate_of_1</xsl:element>
        <xsl:element name="CcmFifRenegotiateOrderFormInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="currency_rd_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">currency_rd</xsl:element>
          </xsl:element>
          <xsl:element name="language_rd_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">language_rd</xsl:element>
          </xsl:element>
          <xsl:element name="loi_indicator_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">loi_indicator</xsl:element>
          </xsl:element>
          <xsl:element name="notice_per_dur_value_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">notice_per_dur_value</xsl:element>
          </xsl:element>
          <xsl:element name="notice_per_dur_unit_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">notice_per_dur_unit</xsl:element>
          </xsl:element>
          <xsl:element name="min_per_dur_value_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">min_per_dur_value</xsl:element>
          </xsl:element>
          <xsl:element name="min_per_dur_unit_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">min_per_dur_unit</xsl:element>
          </xsl:element>
          <xsl:element name="term_start_date_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">term_start_date</xsl:element>
          </xsl:element>
          <xsl:element name="monthly_order_entry_amount_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">monthly_order_entry_amount</xsl:element>
          </xsl:element>
          <xsl:element name="termination_restriction_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">termination_restriction</xsl:element>
          </xsl:element>
          <xsl:element name="doc_template_name_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">doc_template_name</xsl:element>
          </xsl:element>
          <xsl:element name="product_commit_list_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">product_commit_list</xsl:element>
          </xsl:element>          
          <xsl:element name="min_period_start_date_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">min_period_start_date</xsl:element>
          </xsl:element>
          <xsl:element name="auto_extent_period_value_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">auto_extent_period_value</xsl:element>
          </xsl:element>
          <xsl:element name="auto_extent_period_unit_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">auto_extent_period_unit</xsl:element>
          </xsl:element>
          <xsl:element name="auto_extension_ind_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">auto_extension_ind</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
                        
      <!-- Sign Order Form -->
      <xsl:element name="CcmFifSignOrderFormCmd">
        <xsl:element name="command_id">sign_of_1</xsl:element>
        <xsl:element name="CcmFifSignOrderFormInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="board_sign_name_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">board_sign_name</xsl:element>
          </xsl:element>
          <xsl:element name="board_sign_date_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">board_sign_date</xsl:element>
          </xsl:element>
          <xsl:element name="primary_cust_sign_name_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">primary_cust_sign_name</xsl:element>
          </xsl:element>
          <xsl:element name="primary_cust_sign_date_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">primary_cust_sign_date</xsl:element>
          </xsl:element>
          <xsl:element name="secondary_cust_sign_name_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">secondary_cust_sign_name</xsl:element>
          </xsl:element>
          <xsl:element name="secondary_cust_sign_date_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="field_name">secondary_cust_sign_date</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
                        
      <!-- Apply New Pricing Structure -->
      <xsl:element name="CcmFifApplyNewPricingStructCmd">
        <xsl:element name="command_id">apply_new_ps_1</xsl:element>
        <xsl:element name="CcmFifApplyNewPricingStructInCont">
          <xsl:element name="supported_object_id">
            <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">O</xsl:element>
          <xsl:element name="apply_swap_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
                        
      <!-- Configure price plans of original product subscription -->                        
      <!-- Find Price Plan Subscriptions with summary account for original PS -->
      <xsl:element name="CcmFifFindPricePlanSubsCmd">
        <xsl:element name="command_id">find_original_pps_1</xsl:element>
        <xsl:element name="CcmFifFindPricePlanSubsInCont">
          <xsl:element name="product_subscription_id">
            <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="summary_account_ind">Y</xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
            
      <!-- Configure summary accounts of PPS of the original PS -->
      <xsl:element name="CcmFifConfigurePPSCmd">
        <xsl:element name="command_id">configure_original_pps_1</xsl:element>
        <xsl:element name="CcmFifConfigurePPSInCont">
          <xsl:element name="price_plan_subs_list_ref">
            <xsl:element name="command_id">find_original_pps_1</xsl:element>
            <xsl:element name="field_name">price_plan_subs_list</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Configure selected destinations of PPS of the original PS -->
      <xsl:element name="CcmFifConfigurePPSCmd">
        <xsl:element name="command_id">configure_original_pps_2</xsl:element>
        <xsl:element name="CcmFifConfigurePPSInCont">
          <xsl:element name="product_subscription_id">
            <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="price_plan_code_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">selected_dest_price_plan_code</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="selected_destinations_list_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">selected_destinations_list</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
            
      <!-- Configure contributing items of PPS of the original PS -->
      <xsl:element name="CcmFifAddModifyContributingItemCmd">
        <xsl:element name="command_id">configure_original_pps_3</xsl:element>
        <xsl:element name="CcmFifAddModifyContributingItemInCont">
          <xsl:element name="product_subscription_id">
            <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="price_plan_code_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">cont_item_price_plan_code</xsl:element>
          </xsl:element>
          <xsl:element name="contributing_item_list_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">contributing_item_list</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
            
      <!-- Configure option values of PPS of the original PS -->
      <xsl:element name="CcmFifConfigurePPSCmd">
        <xsl:element name="command_id">configure_original_pps_4</xsl:element>
        <xsl:element name="CcmFifConfigurePPSInCont">
          <xsl:element name="product_subscription_id">
            <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="price_plan_code_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">option_value_price_plan_code</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="pps_option_value_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">option_value_name</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>            
            
      <!-- Configure price plans of original product subscription -->                        
      <!-- Find Price Plan Subscriptions with summary account for cloned PS -->
      <xsl:element name="CcmFifFindPricePlanSubsCmd">
        <xsl:element name="command_id">find_cloned_pps_1</xsl:element>
        <xsl:element name="CcmFifFindPricePlanSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">clone_ps_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="summary_account_ind">Y</xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
            
      <!-- Configure summary accounts of PPS of the original PS -->
      <xsl:element name="CcmFifConfigurePPSCmd">
        <xsl:element name="command_id">configure_cloned_pps_1</xsl:element>
        <xsl:element name="CcmFifConfigurePPSInCont">
          <xsl:element name="price_plan_subs_list_ref">
            <xsl:element name="command_id">find_cloned_pps_1</xsl:element>
            <xsl:element name="field_name">price_plan_subs_list</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Configure selected destinations of PPS of the cloned PS -->
      <xsl:element name="CcmFifConfigurePPSCmd">
        <xsl:element name="command_id">configure_cloned_pps_2</xsl:element>
        <xsl:element name="CcmFifConfigurePPSInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">clone_ps_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="price_plan_code_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">selected_dest_price_plan_code</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="selected_destinations_list_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">selected_destinations_list</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
            
      <!-- Configure contributing items of PPS of the cloned PS -->
      <xsl:element name="CcmFifAddModifyContributingItemCmd">
        <xsl:element name="command_id">configure_cloned_pps_3</xsl:element>
        <xsl:element name="CcmFifAddModifyContributingItemInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">clone_ps_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="price_plan_code_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">cont_item_price_plan_code</xsl:element>
          </xsl:element>
          <xsl:element name="contributing_item_list_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">contributing_item_list</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
            
      <!-- Configure option values of PPS of the cloned PS -->
      <xsl:element name="CcmFifConfigurePPSCmd">
        <xsl:element name="command_id">configure_cloned_pps_4</xsl:element>
        <xsl:element name="CcmFifConfigurePPSInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">clone_ps_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="price_plan_code_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">option_value_price_plan_code</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">apply_date</xsl:element>
          </xsl:element>
          <xsl:element name="pps_option_value_ref">
            <xsl:element name="command_id">get_price_plan_data_1</xsl:element>
            <xsl:element name="field_name">option_value_name</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_future_apply_1</xsl:element>
            <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
          </xsl:element>
          <xsl:element name="no_price_plan_error">N</xsl:element>
        </xsl:element>
      </xsl:element>            

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
