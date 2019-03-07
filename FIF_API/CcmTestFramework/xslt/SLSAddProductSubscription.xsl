<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an Add Service Subscription FIF request

  @author schwarje
-->
<!DOCTYPE XSL [
<!ENTITY GenericServiceCharacteristicList SYSTEM "GenericServiceCharacteristicList.xsl">
<!ENTITY GenericCreateAddress SYSTEM "GenericCreateAddress.xsl">
]>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
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
    
      <!-- add product subscription -->
      <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 

        <xsl:if test="request-param[@name='CREATE_PROD_SUBS_GROUP_ID'] = 'Y'">	
           <!-- Create product subscription Group --> 
          <xsl:element name="CcmFifCreateProdSubsGroupCmd">
            <xsl:element name="command_id">create_prod_subs_group_1</xsl:element>
            <xsl:element name="CcmFifCreateProdSubsGroupInCont">
              <xsl:element name="customer_number">
                <xsl:choose>
                  <xsl:when test="request-param[@name='PARENT_CUSTOMER_NUMBER'] != ''">
                    <xsl:value-of select="request-param[@name='PARENT_CUSTOMER_NUMBER']"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>					
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:element>
              <xsl:element name="product_sub_group_name">
                <xsl:value-of select="request-param[@name='PRODUCT_SUB_GROUP_NAME']"/>
              </xsl:element>
              <xsl:element name="product_sub_group_description">
                <xsl:value-of select="request-param[@name='PRODUCT_SUB_GROUP_DESCRIPTION']"/>
              </xsl:element>
              <xsl:element name="effective_date">
                <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element> 
        </xsl:if>
                
        <xsl:element name="CcmFifAddProductSubsCmd">
          <xsl:element name="command_id">add_product_subs</xsl:element>
          <xsl:element name="CcmFifAddProductSubsInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
            </xsl:element>
            <xsl:element name="product_commitment_number">
              <xsl:value-of select="request-param[@name='PRODUCT_COMMITMENT_NUMBER']"/>
            </xsl:element>
            <xsl:if test="request-param[@name='CREATE_PROD_SUBS_GROUP_ID'] != 'Y' and
              request-param[@name='PRODUCT_SUBS_GROUP_ID'] != ''">	
              <xsl:element name="product_subs_group_id">
                <xsl:value-of select="request-param[@name='PRODUCT_SUBS_GROUP_ID']"/>
              </xsl:element>  
            </xsl:if>  
            <xsl:if test="request-param[@name='CREATE_PROD_SUBS_GROUP_ID'] = 'Y'">	
              <xsl:element name="product_subs_group_ref">
                <xsl:element name="command_id">create_prod_subs_group_1</xsl:element>
                <xsl:element name="field_name">product_subs_group_id</xsl:element>
              </xsl:element> 
            </xsl:if>
          </xsl:element>
        </xsl:element>
        

      </xsl:if>

      <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
        <!-- lock product to avoid concurrency problems -->
        <xsl:element name="CcmFifLockObjectCmd">
          <xsl:element name="CcmFifLockObjectInCont">
            <xsl:element name="object_id">
              <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
            </xsl:element>
            <xsl:element name="object_type">PROD_SUBS</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

		<xsl:element name="CcmFifGetEntityCmd">
			<xsl:element name="command_id">get_entity</xsl:element>
			<xsl:element name="CcmFifGetEntityInCont">
				<xsl:element name="customer_number">
					<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>          

      <!-- add service subscription 01 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_01'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_01']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_01</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_01']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_01'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_01'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_01']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_01'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_01'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_01']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_01'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_01']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_01'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_01'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_01']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_01'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_01'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_01']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_01'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_01'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_01']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_01'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_01'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_01']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_01'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>

          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_01']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 01 END -->

      <!-- add service subscription 02 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_02'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_02']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_02</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_02']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_02'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_02'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_02']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_02'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_02'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_02']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_02'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_02']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_02'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_02'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_02']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_02'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_02'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_02']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_02'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_02'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_02']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_02'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_02'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_02']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_02'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>
          
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_02']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 02 END -->

      <!-- add service subscription 03 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_03'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_03']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_03</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_03']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_03'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_03'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_03']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_03'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_03'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_03']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_03'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_03']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_03'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_03'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_03']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_03'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_03'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_03']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_03'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_03'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_03']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_03'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_03'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_03']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_03'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>
          
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_03']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 03 END -->

      <!-- add service subscription 04 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_04'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_04']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_04</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_04']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_04'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_04'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_04']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_04'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_04'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_04']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_04'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_04']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_04'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_04'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_04']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_04'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_04'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_04']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_04'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_04'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_04']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_04'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_04'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_04']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_04'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_04']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 04 END -->

      <!-- add service subscription 05 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_05'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_05']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_05</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_05']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_05'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_05'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_05']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_05'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_05'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_05']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_05'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_05']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_05'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_05'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_05']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_05'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_05'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_05']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_05'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_05'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_05']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_05'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_05'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_05']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_05'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>
          
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_05']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 05 END -->

      <!-- add service subscription 06 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_06'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_06']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_06</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_06']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_06'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_06'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_06']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_06'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_06'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_06']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_06'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_06']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_06'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_06'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_06']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_06'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_06'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_06']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_06'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_06'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_06']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_06'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_06'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_06']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_06'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>
          
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_06']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 06 END -->

      <!-- add service subscription 07 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_07'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_07']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_07</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_07']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_07'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_07'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_07']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_07'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_07'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_07']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_07'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_07']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_07'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_07'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_07']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_07'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_07'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_07']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_07'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_07'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_07']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_07'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_07'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_07']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_07'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>

          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_07']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 07 END -->

      <!-- add service subscription 08 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_08'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_08']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_08</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_08']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_08'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_08'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_08']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_08'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_08'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_08']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_08'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_08']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_08'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_08'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_08']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_08'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_08'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_08']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_08'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_08'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_08']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_08'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_08'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_08']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_08'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>
          
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_08']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 08 END -->

      <!-- add service subscription 09 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_09'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_09']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_09</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_09']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_09'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_09'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_09']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_09'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_09'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_09']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_09'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_09']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_09'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_09'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_09']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_09'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_09'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_09']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_09'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_09'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_09']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_09'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_09'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_09']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_09'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>

          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_09']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 09 END -->

      <!-- add service subscription 10 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_10'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_10']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_10</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_10']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_10'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_10'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_10']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_10'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_10'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_10']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_10'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_10']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_10'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_10'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_10']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_10'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_10'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_10']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_10'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_10'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_10']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_10'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_10'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_10']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_10'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>
          
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_10']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 10 END -->

      <!-- add service subscription 11 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_11'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_11']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_11</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_11']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_11'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_11'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_11']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_11'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_11'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_11']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_11'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_11']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_11'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_11'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_11']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_11'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_11'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_11']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_11'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_11'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_11']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_11'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_11'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_11']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_11'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>
          
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_11']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 11 END -->

      <!-- add service subscription 12 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_12'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_12']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_12</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_12']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_12'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_12'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_12']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_12'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_12'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_12']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_12'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_12']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_12'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_12'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_12']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_12'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_12'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_12']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_12'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_12'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_12']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_12'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_12'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_12']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_12'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>
          
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_12']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 12 END -->

      <!-- add service subscription 13 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_13'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_13']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_13</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_13']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_13'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_13'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_13']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_13'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_13'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_13']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_13'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_13']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_13'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_13'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_13']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_13'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_13'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_13']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_13'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_13'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_13']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_13'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_13'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_13']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_13'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>
          
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_13']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 13 END -->

      <!-- add service subscription 14 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_14'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_14']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_14</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_14']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_14'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_14'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_14']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_14'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_14'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_14']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_14'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_14']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_14'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_14'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_14']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_14'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_14'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_14']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_14'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_14'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_14']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_14'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_14'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_14']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_14'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>
          
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_14']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 14 END -->

      <!-- add service subscription 15 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_15'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_15']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_15</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_15']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_15'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_15'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_15']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_15'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_15'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_15']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_15'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_15']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_15'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_15'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_15']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_15'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_15'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_15']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_15'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_15'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_15']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_15'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_15'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_15']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_15'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>
          
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_15']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 15 END -->

      <!-- add service subscription 16 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_16'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_16']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_16</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_16']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_16'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_16'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_16']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_16'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_16'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_16']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_16'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_16']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_16'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_16'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_16']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_16'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_16'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_16']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_16'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_16'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_16']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_16'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_16'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_16']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_16'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>
          
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_16']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 16 END -->

      <!-- add service subscription 17 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_17'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_17']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_17</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_17']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_17'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_17'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_17']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_17'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_17'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_17']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_17'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_17']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_17'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_17'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_17']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_17'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_17'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_17']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_17'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_17'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_17']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_17'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_17'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_17']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_17'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>
          
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_17']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 17 END -->

      <!-- add service subscription 18 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_18'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_18']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_18</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_18']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_18'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_18'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_18']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_18'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_18'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_18']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_18'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_18']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_18'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_18'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_18']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_18'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_18'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_18']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_18'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_18'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_18']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_18'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_18'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_18']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_18'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>
          
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_18']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 18 END -->

      <!-- add service subscription 19 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_19'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_19']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_19</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_19']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_19'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_19'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_19']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_19'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_19'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_19']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_19'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_19']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_19'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_19'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_19']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_19'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_19'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_19']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_19'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_19'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_19']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_19'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_19'] != ''">
              <xsl:value-of select="request-param[@name='ORDER_DATE_19']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_19'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>
          
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_19']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 19 END -->

      <!-- add service subscription 20 BEGIN -->
      <xsl:if test="request-param[@name='SERVICE_CODE_20'] != ''">
      <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_20']/request-param-list-item">
        &GenericCreateAddress;
      </xsl:for-each>
      
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_20</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subs</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
          <xsl:element name="product_subscription_id">
             <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
          </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">
            <xsl:value-of select="request-param[@name='SERVICE_CODE_20']"/>
          </xsl:element>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_20'] != '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_20'] = '')">
            <xsl:element name="parent_service_subs_id">
              <xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_ID_20']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="(request-param[@name='PARENT_SERVICE_SUBS_ID_20'] = '' and
          	             request-param[@name='PARENT_SERVICE_SUBS_REF_20'] != '')">
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_<xsl:value-of select="request-param[@name='PARENT_SERVICE_SUBS_REF_20']"/></xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="desired_date">
            <xsl:if test="request-param[@name='DESIRED_DATE_20'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE_20']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_DATE'] != '' and
                           request-param[@name='DESIRED_DATE_20'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
            </xsl:if>
          </xsl:element>            
          <xsl:element name="desired_schedule_type">
            <xsl:if test="request-param[@name='DESIRED_SCHEDULE_TYPE_20'] != ''">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE_20']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='DESIRED_SCHEDULE_TYPE'] != '' and
                           request-param[@name='DESIRED_SCHEDULE_TYPE_20'] = '')">          
              <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:if test="request-param[@name='REASON_RD_20'] != ''">          
              <xsl:value-of select="request-param[@name='REASON_RD_20']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='REASON_RD'] != '' and
                           request-param[@name='REASON_RD_20'] = '')">          
              <xsl:value-of select="request-param[@name='REASON_RD']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:if test="request-param[@name='ACCOUNT_NUMBER_20'] != ''">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER_20']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ACCOUNT_NUMBER'] != '' and
                           request-param[@name='ACCOUNT_NUMBER_20'] = '')">          
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="order_date">
            <xsl:if test="request-param[@name='ORDER_DATE_20'] != ''">          
              <xsl:value-of select="request-param[@name='ORDER_DATE_20']"/>
            </xsl:if>
            <xsl:if test="(request-param[@name='ORDER_DATE'] != '' and
                           request-param[@name='ORDER_DATE_20'] = '')">          
              <xsl:value-of select="request-param[@name='ORDER_DATE']"/>
            </xsl:if>
          </xsl:element>
          
          <xsl:element name="service_characteristic_list">
            <xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST_20']/request-param-list-item">
              &GenericServiceCharacteristicList;
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      <!-- add service subscription 20 END -->

      
      <xsl:if test="request-param[@name='CREATE_CUSTOMER_ORDER'] = 'Y'">
      <!-- Create Customer Order -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
          </xsl:element>
          <xsl:element name="provider_tracking_no">
            <xsl:value-of select="request-param[@name='PROVIDER_TRACKING_NUMBER']"/>
          </xsl:element>          
		  <xsl:element name="super_customer_tracking_id">
		    <xsl:value-of select="request-param[@name='SUPER_CUSTOMER_TRACKING_ID']"/>
		  </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:if test="request-param[@name='SERVICE_CODE_01'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_01</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_02'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_02</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_03'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_03</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_04'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_04</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_05'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_05</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_06'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_06</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_07'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_07</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_08'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_08</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_09'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_09</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_10'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_10</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_11'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_11</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_12'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_12</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_13'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_13</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_14'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_14</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_15'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_15</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_16'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_16</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_17'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_17</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_18'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_18</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_19'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_19</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE_20'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_20</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:if>
      
     <xsl:if test="request-param[@name='RELEASE_CUSTOMER_ORDER'] = 'Y'">          
        <!-- Release Customer Order -->
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="CcmFifReleaseCustOrderInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
            </xsl:element>
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">create_co</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>


<!-- contributing items und selected dest fehlen noch
	
	-->
      <xsl:if test="count(request-param-list[@name='SELECTED_DESTINATIONS_LIST']/request-param-list-item) != 0">
      <!-- find all price plans for the product subscriptions -->
      <xsl:element name="CcmFifFindPricePlanSubsCmd">
        <xsl:element name="command_id">find_pps_1</xsl:element>
        <xsl:element name="CcmFifFindPricePlanSubsInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
            <xsl:element name="product_subscription_id">
              <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">add_product_subs</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="selected_destination_ind">Y</xsl:element>
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
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Configure Price Plan -->
      <xsl:element name="CcmFifConfigurePPSCmd">
        <xsl:element name="command_id">config_pps_1</xsl:element>
        <xsl:element name="CcmFifConfigurePPSInCont">
          <xsl:element name="price_plan_subs_list_ref">
            <xsl:element name="command_id">find_pps_1</xsl:element>
            <xsl:element name="field_name">price_plan_subs_list</xsl:element>
          </xsl:element>
          <xsl:variable name="StartDate" select="request-param[@name='DESIRED_DATE']" />
          <xsl:element name="selected_destinations_list">
            <!-- Selected Destinations -->
            <xsl:for-each select="request-param-list[@name='SELECTED_DESTINATIONS_LIST']/request-param-list-item">
              <xsl:element name="CcmFifSelectedDestCont">
                <xsl:element name="begin_number">
                  <xsl:value-of select="request-param[@name='BEGIN_NUMBER']"/>
                </xsl:element>
                <xsl:element name="end_number">
                  <xsl:value-of select="request-param[@name='END_NUMBER']"/>
                </xsl:element>
                <xsl:element name="start_date">
                  <xsl:value-of select="$StartDate"/>
                </xsl:element>
              </xsl:element>
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>

      <xsl:if test="count(request-param-list[@name='CONTRIBUTING_ITEM_LIST']/request-param-list-item) != 0">
      <!-- Add contributing items -->
      <xsl:element name="CcmFifAddModifyContributingItemCmd">
        <xsl:element name="command_id">add_contrib_item_1</xsl:element>
        <xsl:element name="CcmFifAddModifyContributingItemInCont">
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] != ''">	 
            <xsl:element name="product_subscription_id">
              <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='PRODUCT_SUBSCRIPTION_ID'] = ''">	 
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">add_product_subs</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="price_plan_code">
            <xsl:value-of select="request-param[@name='PRICE_PLAN_CODE']"/>
          </xsl:element>
          <xsl:variable name="StartDate" select="request-param[@name='DESIRED_DATE']" />
          <xsl:element name="contributing_item_list">
            <xsl:for-each select="request-param-list[@name='CONTRIBUTING_ITEM_LIST']/request-param-list-item">
              <xsl:element name="CcmFifContributingItem">
                <xsl:element name="supported_object_type_rd">
                  <xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_TYPE_RD']"/>
                </xsl:element>
                <xsl:element name="start_date">
                  <xsl:value-of select="$StartDate"/>
                </xsl:element>
                <xsl:element name="hierarchy_inclusion_indicator">
                  <xsl:value-of select="request-param[@name='HIERARCHY_INCLUSION_INDICATOR']"/>
                </xsl:element>                
                <xsl:if test="request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] = 'CUSTOMER'">
                  <xsl:element name="customer_number">
                    <xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
                  </xsl:element>                  	
                </xsl:if>
                <xsl:if test="request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] = 'ACCOUNT'">
                  <xsl:element name="account_number">
                    <xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
                  </xsl:element>                  	
                </xsl:if>
                <xsl:if test="request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] = 'PRODUCT_SUBSC'">
                  <xsl:element name="product_subscription_id">
                    <xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
                  </xsl:element>                  	
                </xsl:if>
                <xsl:if test="request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] = 'SERVICE_SUBSC'">
                  <xsl:element name="service_subscription_id">
                    <xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
                  </xsl:element>                  	
                </xsl:if>
                <xsl:if test="request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] = 'PROD_GROUP'">
                  <xsl:element name="product_group_rd">
                    <xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
                  </xsl:element>                  	
                </xsl:if>                
              </xsl:element>
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>

		<xsl:element name="CcmFifFindServiceSubsCmd">
			<xsl:element name="command_id">find_service</xsl:element>
			<xsl:element name="CcmFifFindServiceSubsInCont">
				<xsl:element name="service_subscription_id_ref">
					<xsl:element name="command_id">add_service_01</xsl:element>
					<xsl:element name="field_name">service_subscription_id</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>		
	
		<!-- Create Contact -->
		<xsl:if test="request-param[@name='CREATE_CONTACT'] != 'N'">
		    <xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="contact_type_rd">
						<xsl:choose>
							<xsl:when test="request-param[@name='CONTACT_TYPE_RD'] != ''">
								<xsl:value-of select="request-param[@name='CONTACT_TYPE_RD']"/>
							</xsl:when>
							<xsl:otherwise>PROD_SUBS</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:element name="short_description">
						<xsl:choose>
							<xsl:when test="request-param[@name='SHORT_DESCRIPTION'] != ''">
								<xsl:value-of select="request-param[@name='SHORT_DESCRIPTION']"/>
							</xsl:when>
							<xsl:otherwise>Produktnutzung hinzugefügt</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					
					<xsl:element name="description_text_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:if test="request-param[@name='LONG_DESCRIPTION_TEXT'] != ''">
					    			<xsl:value-of select="request-param[@name='LONG_DESCRIPTION_TEXT']"/>
									<xsl:text>&#xA;</xsl:text>
								</xsl:if>
							    <xsl:text>Produktnutzung </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_service</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>          
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text> mit Hauptdienst </xsl:text>
							</xsl:element>
						</xsl:element>						
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_service</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>          
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text> (ServiceCode </xsl:text>
								<xsl:value-of select="request-param[@name='SERVICE_CODE_01']"/>
								<xsl:text>) erstellt.&#xA;TransactionID: </xsl:text>
								<xsl:value-of select="request-param[@name='transactionID']"/>
								<xsl:text> (SLS)</xsl:text>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
