<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for Arcor International Migration

  @author makuier
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" 
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
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="Command_List">
    
      <!-- Generate Base Command Id for add and terminate service -->
      <xsl:variable name="AddServCommandId">add_ss_</xsl:variable>
      <xsl:variable name="ProdSubsId" select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
      <xsl:variable name="ServSubsId" select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
      <xsl:variable name="AccountNum" select="request-param[@name='ACCOUNT_NUMBER']"/>
      <xsl:variable name="StartDate" select="request-param[@name='EFFECTIVE_DATE']"/>

      <!-- find all price plans for the product subscriptions -->
      <xsl:element name="CcmFifFindPricePlanSubsCmd">
        <xsl:element name="command_id">find_pps_1</xsl:element>
        <xsl:element name="CcmFifFindPricePlanSubsInCont">
          <xsl:element name="product_subscription_id"><xsl:value-of select="$ProdSubsId"/></xsl:element>
          <xsl:element name="selected_destination_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Validate future Selected destinations -->
      <xsl:element name="CcmFifValidateFutureSelectedDestCmd">
        <xsl:element name="command_id">validate_sd_1</xsl:element>
        <xsl:element name="CcmFifValidateFutureSelectedDestInCont">
          <xsl:element name="price_plan_subs_list_ref">
            <xsl:element name="command_id">find_pps_1</xsl:element>
            <xsl:element name="field_name">price_plan_subs_list</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date"><xsl:value-of select="$StartDate"/></xsl:element>
          <xsl:element name="only_country_selected_dest">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Deactivate Selected destinations -->
      <xsl:element name="CcmFifDeactSelectedDestForPpsCmd">
        <xsl:element name="command_id">deact_sd_1</xsl:element>
        <xsl:element name="CcmFifDeactSelectedDestForPpsInCont">
          <xsl:element name="price_plan_subs_list_ref">
            <xsl:element name="command_id">find_pps_1</xsl:element>
            <xsl:element name="field_name">price_plan_subs_list</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date"><xsl:value-of select="$StartDate"/></xsl:element>
          <xsl:element name="only_country_selected_dest">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:for-each select="request-param-list[@name='SERVICE_CODE_LIST']/request-param-list-item">
        <xsl:variable name="ServiceCode" select="request-param[@name='SERVICE_CODE']"/>
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">
            <xsl:value-of select="concat($AddServCommandId, $ServiceCode)"/>
          </xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_id"><xsl:value-of select="$ProdSubsId"/></xsl:element>
            <xsl:element name="service_code"><xsl:value-of select="$ServiceCode"/></xsl:element>
            <xsl:element name="parent_service_subs_id"><xsl:value-of select="$ServSubsId"/></xsl:element>
            <xsl:element name="desired_date"><xsl:value-of select="$StartDate"/></xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">MODIFY_DES_CNTRY</xsl:element>
            <xsl:element name="account_number"><xsl:value-of select="$AccountNum"/></xsl:element>
            <xsl:element name="ignore_if_service_exist">Y</xsl:element>
            <xsl:element name="service_characteristic_list">
            </xsl:element>
          </xsl:element>
        </xsl:element>

        <!-- Add contributing items -->
        <xsl:element name="CcmFifAddModifyContributingItemCmd">
          <xsl:element name="CcmFifAddModifyContributingItemInCont">
            <xsl:element name="product_subscription_id"><xsl:value-of select="$ProdSubsId"/></xsl:element>
            <xsl:element name="service_code"><xsl:value-of select="$ServiceCode"/></xsl:element>
            <xsl:element name="contributing_item_list">
              <xsl:element name="CcmFifContributingItem">
                <xsl:element name="supported_object_type_rd">SERVICE_SUBSC</xsl:element>
                <xsl:element name="start_date"><xsl:value-of select="$StartDate"/></xsl:element>
                <xsl:element name="service_subscription_id"><xsl:value-of select="$ServSubsId"/></xsl:element>                  	
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:for-each>

      <!-- Create Customer Order for add and terminate discount Services -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="cust_order_description">Wunschländer-Änderung</xsl:element>
          <xsl:element name="provider_tracking_no">001</xsl:element>
          <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:for-each select="request-param-list[@name='SERVICE_CODE_LIST']/request-param-list-item">
             <xsl:variable name="ServiceCode" select="request-param[@name='SERVICE_CODE']"/>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">
                  <xsl:value-of select="concat($AddServCommandId, $ServiceCode)"/>
                </xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Release Customer Order for add and terminate discount Services -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>


    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
