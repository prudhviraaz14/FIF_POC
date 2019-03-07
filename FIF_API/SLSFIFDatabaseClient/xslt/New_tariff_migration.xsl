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
    <xsl:element name="client_name">SLS</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">

            <!-- Get Order Form Data -->
      <xsl:element name="CcmFifGetOrderFormDataCmd">
        <xsl:element name="command_id">get_order_form_data_1</xsl:element>
        <xsl:element name="CcmFifGetOrderFormDataInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
          </xsl:element>
         </xsl:element>
      </xsl:element>
      <!-- Validate Get Old Price Plan Code -->
      <xsl:element name="CcmFifGetProdCommitContCmd">
        <xsl:element name="command_id">get_price_plan_code_1</xsl:element>
        <xsl:element name="CcmFifGetProdCommitContInCont">
          <xsl:element name="prod_commit_ref">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element> 
            <xsl:element name="field_name">product_commit_list</xsl:element> 
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Validate Price Plan Code -->
      <xsl:element name="CcmFifValidateValueCmd">
        <xsl:element name="command_id">validate_price_plan_code_1</xsl:element>
        <xsl:element name="CcmFifValidateValueInCont">
          <xsl:element name="value_ref">
            <xsl:element name="command_id">get_price_plan_code_1</xsl:element> 
              <xsl:element name="field_name">pricing_structure_code</xsl:element> 
            </xsl:element>
          <xsl:element name="object_type">PRICE_PLAN_SUBSCRIPTION</xsl:element>
          <xsl:element name="value_type">PRICE_PLAN_CODE</xsl:element>
          <xsl:element name="allowed_values">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:value-of select="request-param[@name='PRICING_STRUCTURE_CODE']"/>
              </xsl:element>          	  
            </xsl:element>   
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Get Cycle Data -->
      <xsl:element name="CcmFifGetCycleCmd">
        <xsl:element name="command_id">get_cycle_1</xsl:element>
         <xsl:element name="CcmFifGetCycleInCont">
          <xsl:element name="cycle_name">
            <xsl:value-of select="request-param[@name='CYCLE_NAME']"/>
          </xsl:element>
          </xsl:element>
      </xsl:element> 
      
      <!-- TermSuspReactService service -->
      <xsl:element name="CcmFifTermSuspReactServiceSubsCmd">
        <xsl:element name="command_id">tsr_service_1</xsl:element>
        <xsl:element name="CcmFifTermSuspReactServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="usage_mode">4</xsl:element>
          <xsl:element name="desired_date_ref">
            <xsl:element name="command_id">get_cycle_1</xsl:element>
            <xsl:element name="field_name">due_date</xsl:element>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
         <!-- <xsl:element name="reason_rd"> 
            <xsl:value-of select="request-param[@name='REASON_RD']"/>
          </xsl:element> -->
          <xsl:element name="reason_rd">NOT_RELEVANT</xsl:element>
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
              <xsl:element name="command_id">tsr_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Release Customer Order -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="command_id">create_co_2</xsl:element>
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
      <!-- Renegotiate Order Form  -->
      <xsl:element name="CcmFifRenegotiateOrderFormCmd">
        <xsl:element name="command_id">renegotiate_order_form_1</xsl:element>
        <xsl:element name="CcmFifRenegotiateOrderFormInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
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
      <!-- create contact -->
      <xsl:element name="CcmFifCreateContactCmd">
       <xsl:element name="command_id">create_cont_1</xsl:element> 
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">CUSTOMER_ORDER</xsl:element>
          <xsl:element name="caller_name">SYSTEM</xsl:element>
          <xsl:element name="caller_phone_number">SYSTEM</xsl:element>
          <xsl:element name="author_name">New_tarif_migr</xsl:element>
          <xsl:element name="short_description">New_tarif_migration</xsl:element>
          <xsl:element name="long_description_text">The migration (termination of the service and apply) was done for Contract : <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/></xsl:element>
          <xsl:element name="trouble_ticket_requested_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Sign and Apply Dependent -->
      <xsl:element name="CcmFifSignAndApplyNewPricingStructCmd">
        <xsl:element name="command_id">sign_apply_1</xsl:element>
        <xsl:element name="CcmFifSignAndApplyNewPricingStructInCont">
          <xsl:element name="supported_object_id">
              <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
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
    </xsl:element>            
   </xsl:template>
</xsl:stylesheet>
