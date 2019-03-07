<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for adding a wholesale product subscription

  @author banania
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
     
      <xsl:variable name="today"
        select="dateutils:getCurrentDate()"/>
      
      <xsl:variable name="DesiredDate">  
        <xsl:choose>
          <xsl:when test ="request-param[@name='DESIRED_DATE'] = $today">
            <xsl:value-of select="$today"/>
          </xsl:when>
          <xsl:when test ="request-param[@name='DESIRED_DATE'] = ''">
            <xsl:value-of select="$today"/>
          </xsl:when>					
          <xsl:when test ="request-param[@name='DESIRED_DATE'] &lt; $today">
            <xsl:value-of select="$today"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>

      <xsl:if test="request-param[@name='CUSTOMER_NUMBER'] = '' ">
        <!-- Get customer number from reference data -->
        <xsl:element name="CcmFifGetCrossRefSecondaryValueCmd">
          <xsl:element name="command_id">get_ref_data_cust_1</xsl:element>
          <xsl:element name="CcmFifGetCrossRefSecondaryValueInCont">
            <xsl:element name="group_code">WHOLE_CUST</xsl:element>
            <xsl:element name="primary_value">
              <xsl:value-of select="request-param[@name='WHOLESALE_PARTNER']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <xsl:if test="request-param[@name='ACCOUNT_NUMBER'] = '' ">        
        <!-- Get account number from reference data -->
        <xsl:element name="CcmFifGetCrossRefSecondaryValueCmd">
          <xsl:element name="command_id">get_ref_data_acc_1</xsl:element>
          <xsl:element name="CcmFifGetCrossRefSecondaryValueInCont">
            <xsl:element name="group_code">WHOLE_ACC</xsl:element>
            <xsl:element name="primary_value">
              <xsl:value-of select="request-param[@name='WHOLESALE_PARTNER']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <xsl:if test="request-param[@name='PRODUCT_COMMITMENT_NUMBER'] = '' ">
        <!-- Get product commitment number from reference data -->
        <xsl:element name="CcmFifGetCrossRefSecondaryValueCmd">
          <xsl:element name="command_id">get_ref_data_prod_commit_1</xsl:element>
          <xsl:element name="CcmFifGetCrossRefSecondaryValueInCont">
            <xsl:element name="group_code">WHOLE_PC</xsl:element>
            <xsl:element name="primary_value">
              <xsl:value-of select="request-param[@name='WHOLESALE_PARTNER']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Lock product commitment  -->
      <xsl:element name="CcmFifLockObjectCmd">
        <xsl:element name="CcmFifLockObjectInCont">
          <xsl:if test="request-param[@name='PRODUCT_COMMITMENT_NUMBER'] = '' ">        
            <xsl:element name="object_id_ref">
              <xsl:element name="command_id">get_ref_data_prod_commit_1</xsl:element>
              <xsl:element name="field_name">secondary_value</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_COMMITMENT_NUMBER'] != '' ">        
            <xsl:element name="object_id">
              <xsl:value-of select="request-param[@name='PRODUCT_COMMITMENT_NUMBER']"/>
            </xsl:element>
          </xsl:if>  
          <xsl:element name="object_type">SDC_PROD_COMM</xsl:element>
        </xsl:element>
      </xsl:element> 
      
      <!-- Add Product Subscription -->
      <xsl:element name="CcmFifAddProductSubsCmd">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="CcmFifAddProductSubsInCont">
          <xsl:if test="request-param[@name='CUSTOMER_NUMBER'] != '' ">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='CUSTOMER_NUMBER'] = '' ">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">get_ref_data_cust_1</xsl:element>
              <xsl:element name="field_name">secondary_value</xsl:element>
            </xsl:element>
          </xsl:if>  
          <xsl:if test="request-param[@name='PRODUCT_COMMITMENT_NUMBER'] = '' ">        
            <xsl:element name="product_commitment_number_ref">
              <xsl:element name="command_id">get_ref_data_prod_commit_1</xsl:element>
              <xsl:element name="field_name">secondary_value</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_COMMITMENT_NUMBER'] != '' ">        
            <xsl:element name="product_commitment_number">
              <xsl:value-of select="request-param[@name='PRODUCT_COMMITMENT_NUMBER']"/>
            </xsl:element>
          </xsl:if>          
        </xsl:element>
      </xsl:element>

      <!-- Add Service Subscription for Technical service  -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_subscription_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">Wh001</xsl:element>
          <xsl:if test="$DesiredDate = $today">											
            <xsl:element name="desired_date">
              <xsl:value-of select="$DesiredDate"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          </xsl:if>	
          <xsl:if test="$DesiredDate != $today">											
            <xsl:element name="desired_date">
              <xsl:value-of select="$DesiredDate"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='ACCOUNT_NUMBER'] != ''">          
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:element>  
          </xsl:if>  
          <xsl:if test="request-param[@name='ACCOUNT_NUMBER'] = ''">          
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">get_ref_data_acc_1</xsl:element>
              <xsl:element name="field_name">secondary_value</xsl:element>
            </xsl:element>  
          </xsl:if>  
          <xsl:element name="service_characteristic_list">
              <xsl:if test="request-param[@name='ADDRESS_ID'] != ''">
                <!-- Address -->
                <xsl:element name="CcmFifAddressCharacteristicCont">                
              <xsl:element name="service_char_code">V0014</xsl:element>
              <xsl:element name="data_type">ADDRESS</xsl:element>     
                <xsl:element name="address_id">
                  <xsl:value-of select="request-param[@name='ADDRESS_ID']"/>
                </xsl:element>
            </xsl:element>      
            </xsl:if>      
            <!-- Technical service identifier (TASI) -->
            <xsl:element name="CcmFifAccessNumberCont">
              <xsl:element name="service_char_code">V0188</xsl:element>
              <xsl:element name="data_type">TECH_SERVICE_ID</xsl:element>
              <xsl:element name="network_account">
                <xsl:value-of select="request-param[@name='TECH_SERVICE_ID']"/>
              </xsl:element>
            </xsl:element>
            <!-- Wholesale Partner -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0189</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='WHOLESALE_PARTNER']"/>
              </xsl:element>
            </xsl:element>  
            <!-- Wholesale Partner -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0152</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='TECH_SERVICE_ID']"/>
              </xsl:element>
            </xsl:element>
            <!-- Bemerkung -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Add Wholesale Product Subscription</xsl:element>
            </xsl:element>            
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Add Service Subscription for Port Einrichtungspreis-->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_subscription_2</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <!-- TODO: Replace by real service -->
          <xsl:element name="service_code">Wh002</xsl:element>
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">add_service_subscription_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:if test="$DesiredDate = $today">											
            <xsl:element name="desired_date">
              <xsl:value-of select="$DesiredDate"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          </xsl:if>	
          <xsl:if test="$DesiredDate != $today">											
            <xsl:element name="desired_date">
              <xsl:value-of select="$DesiredDate"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          </xsl:if>          
          <xsl:if test="request-param[@name='ACCOUNT_NUMBER'] != ''">          
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:element>  
          </xsl:if>  
          <xsl:if test="request-param[@name='ACCOUNT_NUMBER'] = ''">          
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">get_ref_data_acc_1</xsl:element>
              <xsl:element name="field_name">secondary_value</xsl:element>
            </xsl:element>  
          </xsl:if>  
          <xsl:element name="service_characteristic_list">
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Customer Order for Voice -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:if test="request-param[@name='CUSTOMER_NUMBER'] != '' ">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='CUSTOMER_NUMBER'] = '' ">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">get_ref_data_cust_1</xsl:element>
              <xsl:element name="field_name">secondary_value</xsl:element>
            </xsl:element>
          </xsl:if>  
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
          </xsl:element>
          <xsl:element name="provider_tracking_no">001</xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_subscription_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_subscription_2</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>            
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:if test="request-param[@name='CUSTOMER_NUMBER'] != '' ">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='CUSTOMER_NUMBER'] = '' ">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">get_ref_data_cust_1</xsl:element>
              <xsl:element name="field_name">secondary_value</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>          
        </xsl:element>
      </xsl:element>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
