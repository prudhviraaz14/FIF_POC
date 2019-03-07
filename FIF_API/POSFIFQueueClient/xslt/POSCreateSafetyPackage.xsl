<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a safety package. IT-15592 Arcor Sicherheitspaket.

  @author banania
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
    <xsl:element name="client_name">
      <xsl:value-of select="request-param[@name='clientName']"/>
    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:variable name="DesiredDate" select="request-param[@name='desiredDate']"/>
    
    <!-- Convert the desired date to OPM format -->
    <xsl:variable name="desiredDateOPM"
      select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
      
    <!-- Calculate today and one day before the desired date -->
    <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
    
    <xsl:element name="Command_List">
      
      <xsl:variable name="Type">
        <xsl:value-of select="request-param[@name='type']"/>
      </xsl:variable> 
    
      <!-- Validate the parameter type -->
      <xsl:if test="$Type != ''
        and request-param[@name='serviceSubscriptionId']!= ''">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">type_error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The parameter 'type' can be set only if the main access service can not be determined!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Validate the parameter type -->
      <xsl:if test="$Type != 'NGNDSL'
        and $Type != 'BitDSL'
        and $Type != 'ISDN'      
        and request-param[@name='serviceSubscriptionId'] = ''">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">type_error_2</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The parameter type has to  be set to NGNDSL, BitDSL or ISDN.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
        
      <!-- Ensure that either requestListId is populated or serviceSubscriptionId -->
      <xsl:if test="(request-param[@name='serviceSubscriptionId'] = '')
        and (request-param[@name='requestListId'] = '')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">standalone_transaction_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The parameter serviceSubscriptionId or requestListId musst be provided!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!--Get Customer Number if not provided-->
      <xsl:if test="(request-param[@name='customerNumber'] = '')">
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_external_notification_1</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!--Get Account Number if not provided-->
      <xsl:if test="(request-param[@name='accountNumber'] = '')">
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_external_notification_2</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <xsl:if test="(request-param[@name='serviceSubscriptionId'] != '')">
        <!-- Look for the ISDN/DSL-R or NGN service -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Take value of serviceSubscriptionId from ccm external notification if accessNumber,serviceTicketPositionId,serviceSubscriptionId not provided -->
      <xsl:if test="(request-param[@name='serviceSubscriptionId'] = '')">
 
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_external_notification_3</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">
              <xsl:value-of select="concat($Type, '_SERVICE_SUBSCRIPTION_ID')"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Look for the ISDN/DSL-R or NGN service -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">read_external_notification_3</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>        
      </xsl:if>

      
      <!-- Ensure, that the service  belongs to an ISDN service (V0010, V0011) ,DSL-R service (I1043) or NGN service -->
      <xsl:element name="CcmFifValidateValueCmd">
        <xsl:element name="command_id">validate_value_1</xsl:element>
        <xsl:element name="CcmFifValidateValueInCont">
          <xsl:element name="value_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>
          </xsl:element>
          <xsl:element name="object_type">SERVICE_SUBSCRIPTION</xsl:element>
          <xsl:element name="value_type">SERVICE_CODE</xsl:element>
          <xsl:element name="allowed_values">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">V0010</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">V0011</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">V0003</xsl:element>
            </xsl:element>            
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">I1043</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">I104A</xsl:element>
            </xsl:element>            
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">I1210</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">I1213</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">I121z</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Create Order Form-->
      <xsl:element name="CcmFifCreateOrderFormCmd">
        <xsl:element name="command_id">create_order_form_1</xsl:element>
        <xsl:element name="CcmFifCreateOrderFormInCont">
          <xsl:if test="request-param[@name='customerNumber'] != ''">	
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='customerNumber'] = ''">					
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="term_dur_value">
            <xsl:value-of select="request-param[@name='termDurValue']"/>
          </xsl:element>
          <xsl:element name="term_dur_unit">
            <xsl:value-of select="request-param[@name='termDurUnit']"/>
          </xsl:element>
          <xsl:element name="term_start_date">
            <xsl:value-of select="request-param[@name='termStartDate']"/>
          </xsl:element>
          <xsl:element name="termination_date">
            <xsl:value-of select="request-param[@name='terminationDate']"/>
          </xsl:element>
          <xsl:element name="min_per_dur_value">
            <xsl:value-of select="request-param[@name='minPeriodDurationValue']"/>
          </xsl:element>
          <xsl:element name="min_per_dur_unit">
            <xsl:value-of select="request-param[@name='minPeriodDurationUnit']"/>
          </xsl:element>
          <xsl:element name="sales_org_num_value">
            <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
          </xsl:element>
          <xsl:element name="sales_org_num_value_vf">
			<xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
		  </xsl:element>            
          <xsl:element name="sales_org_date">
            <xsl:value-of select="request-param[@name='salesOrgDate']"/>
          </xsl:element>
          <xsl:element name="termination_restriction">
            <xsl:value-of select="request-param[@name='terminationRestriction']"/>
          </xsl:element>
          <xsl:element name="doc_template_name">Vertrag</xsl:element>
          <xsl:element name="assoc_skeleton_cont_num">
            <xsl:value-of select="request-param[@name='assocSkeletonContNum']"/>
          </xsl:element>
          <xsl:element name="auto_extent_period_value">
            <xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>
          </xsl:element>                         
          <xsl:element name="auto_extent_period_unit">
            <xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>
          </xsl:element>                         
          <xsl:element name="auto_extension_ind">
            <xsl:value-of select="request-param[@name='autoExtensionInd']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Add Order Form Product Commitment -->
      <xsl:element name="CcmFifAddProductCommitCmd">
        <xsl:element name="command_id">add_product_commitment_1</xsl:element>
        <xsl:element name="CcmFifAddProductCommitInCont">
          <xsl:if test="request-param[@name='customerNumber'] != ''">	
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='customerNumber'] = ''">					
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">create_order_form_1</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <xsl:element name="product_code">I1410</xsl:element>
          <xsl:element name="pricing_structure_code">
            <xsl:value-of select="request-param[@name='tariff']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Sign Order Form -->
      <xsl:element name="CcmFifSignOrderFormCmd">
        <xsl:element name="command_id">sign_of_1</xsl:element>
        <xsl:element name="CcmFifSignOrderFormInCont">
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">create_order_form_1</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='boardSignName'] != ''">
            <xsl:element name="board_sign_name">
              <xsl:value-of select="request-param[@name='boardSignName']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='boardSignName'] = ''">
            <xsl:element name="board_sign_name">ARCOR</xsl:element>
          </xsl:if>
          <xsl:element name="board_sign_date">
            <xsl:value-of select="request-param[@name='boardSignDate']"/>
          </xsl:element>
          <xsl:if test="request-param[@name='primaryCustSignName'] != ''">
            <xsl:element name="primary_cust_sign_name">
              <xsl:value-of select="request-param[@name='primaryCustSignName']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='primaryCustSignName'] = ''">
            <xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
          </xsl:if>
          <xsl:element name="primary_cust_sign_date">
            <xsl:value-of select="request-param[@name='primaryCustSignDate']"/>
          </xsl:element>
          <xsl:element name="secondary_cust_sign_name">
            <xsl:value-of select="request-param[@name='secondaryCustSignName']"/>
          </xsl:element>
          <xsl:element name="secondary_cust_sign_date">
            <xsl:value-of select="request-param[@name='secondaryCustSignDate']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Add Product Subscription -->
      <xsl:element name="CcmFifAddProductSubsCmd">
        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
        <xsl:element name="CcmFifAddProductSubsInCont">
          <xsl:if test="request-param[@name='customerNumber'] != ''">	
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='customerNumber'] = ''">					
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="product_commitment_number_ref">
            <xsl:element name="command_id">add_product_commitment_1</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
          <xsl:element name="vis_tracking_position">
            <xsl:value-of select="request-param[@name='VISTrackingPosition']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Add service I1410 -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">I1410</xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">END_BEFORE</xsl:element>
          <xsl:element name="reason_rd">CREATE_SECURITY</xsl:element>
          <xsl:if test="request-param[@name='accountNumber'] != ''">	
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='accountNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='accountNumber'] = ''">					
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">read_external_notification_2</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="service_characteristic_list">
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1403</xsl:element>
              <xsl:element name="data_type">DATE</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$desiredDateOPM"/>
              </xsl:element>
            </xsl:element>
            <!--  Kondition/Rabatt -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0097</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='rabatt']"/>
              </xsl:element>
            </xsl:element>
            <!--  Kondition/Rabatt ID -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0162</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='rabattId']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- look for a voice bundle (item) -->
      <xsl:element name="CcmFifFindBundleCmd">
        <xsl:element name="command_id">find_bundle_1</xsl:element>
        <xsl:element name="CcmFifFindBundleInCont">
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Create a new bundle if no one has been found -->
      <xsl:element name="CcmFifModifyBundleCmd">
        <xsl:element name="command_id">modify_bundle_1</xsl:element>
        <xsl:element name="CcmFifModifyBundleInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='customerNumber'] != ''">	
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='customerNumber'] = ''">					
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="bundle_found_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Get bundle item type rd from reference data -->
      <xsl:element name="CcmFifGetCrossRefSecondaryValueCmd">
        <xsl:element name="command_id">get_ref_data_1</xsl:element>
        <xsl:element name="CcmFifGetCrossRefSecondaryValueInCont">
          <xsl:element name="group_code">SERV_BLD</xsl:element>
          <xsl:element name="primary_value_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- add the new bundle item if a bundle is found -->
      <xsl:element name="CcmFifModifyBundleItemCmd">
        <xsl:element name="command_id">modify_bundle_item_1</xsl:element>
        <xsl:element name="CcmFifModifyBundleItemInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>
          <xsl:element name="bundle_item_type_rd">SOFTWARE</xsl:element>
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">add_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
          <xsl:element name="action_name">ADD</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>   
        </xsl:element>
      </xsl:element>
      <!-- add a new bundle item for the given service subscription id -->
      <xsl:element name="CcmFifModifyBundleItemCmd">
        <xsl:element name="command_id">modify_bundle_item_2</xsl:element>
        <xsl:element name="CcmFifModifyBundleItemInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">modify_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>
          <xsl:element name="bundle_item_type_rd_ref">
            <xsl:element name="command_id">get_ref_data_1</xsl:element>
            <xsl:element name="field_name">secondary_value</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
          <xsl:element name="action_name">ADD</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>   
        </xsl:element>
      </xsl:element>
      <!-- add the new  bundle item to the new bundle if created only -->
      <xsl:element name="CcmFifModifyBundleItemCmd">
        <xsl:element name="command_id">modify_bundle_item_3</xsl:element>
        <xsl:element name="CcmFifModifyBundleItemInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">modify_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>
          <xsl:element name="bundle_item_type_rd">SOFTWARE</xsl:element>
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">add_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
          <xsl:element name="action_name">ADD</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>            
        </xsl:element>
      </xsl:element>
      <!-- Create Customer Order for new services  -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:if test="request-param[@name='customerNumber'] != ''">	
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='customerNumber'] = ''">					
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="lan_path_file_string">
            <xsl:value-of select="request-param[@name='lanPathFileString']"/>
          </xsl:element>
          <xsl:element name="sales_rep_dept">
            <xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
          </xsl:element>
          <xsl:if test="request-param[@name='providerTrackingNumber'] = ''" > 
            <xsl:element name="provider_tracking_no">001f</xsl:element> 
          </xsl:if>          
          <xsl:if test="request-param[@name='providerTrackingNumber'] != ''">             
            <xsl:element name="provider_tracking_no">
              <xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:element name="super_customer_tracking_id">
            <xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
          </xsl:element>
          <xsl:element name="scan_date">
            <xsl:value-of select="request-param[@name='scanDate']"/>
          </xsl:element>
          <xsl:element name="order_entry_date">
            <xsl:value-of select="request-param[@name='entryDate']"/>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="e_shop_id">
		    <xsl:value-of select="request-param[@name='eShopID']"/>
		  </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Release stand alone Customer Order  --> 
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="CcmFifReleaseCustOrderInCont">
            <xsl:if test="request-param[@name='customerNumber'] != ''">	
              <xsl:element name="customer_number">
                <xsl:value-of select="request-param[@name='customerNumber']"/>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='customerNumber'] = ''">					
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">read_external_notification_1</xsl:element>
                <xsl:element name="field_name">parameter_value</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">create_co_1</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>        
          </xsl:element>
        </xsl:element>     
   

      <!-- Create Contact for the addition of security service -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:if test="request-param[@name='customerNumber'] != ''">	
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='customerNumber'] = ''">					
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="contact_type_rd">SECURITY_PACKAGE</xsl:element>
          <xsl:element name="short_description">
            <xsl:text>Dienst hinzugefügt über </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
          </xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;Service Code: I1410</xsl:text>
            <xsl:text>&#xA;Desired Date: </xsl:text>
            <xsl:value-of select="$DesiredDate"/>
            <xsl:text>&#xA;User name: </xsl:text>
            <xsl:value-of select="request-param[@name='userName']"/>
            <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
            <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Writes the SS id to  External notification  if requestListId is set -->
      <xsl:if test="request-param[@name='requestListId'] != ''">
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_external_notification_2</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="processed_indicator">Y</xsl:element>
            <xsl:element name="notification_action_name">CreateSafetyPackage</xsl:element>
            <xsl:element name="target_system">FIF</xsl:element>
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">Safety_SERVICE_SUBSCRIPTION_ID</xsl:element> 
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">add_service_1</xsl:element> 
                  <xsl:element name="field_name">service_subscription_id</xsl:element> 
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>  
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
