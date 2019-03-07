<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an online contract. IT-22630 .

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
       
      <!-- Take value of serviceSubscriptionId from ccm external notification if accessNumber,serviceTicketPositionId,serviceSubscriptionId not provided -->
      <xsl:if test="(request-param[@name='serviceSubscriptionId'] = '' and
        request-param[@name='bundleType'] != '')">
 
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_external_notification_3</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">ISDN_SERVICE_SUBSCRIPTION_ID</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Look for the ISDN service -->
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
        
        <!--Get Detailed Reason Rd -->     
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_external_notification_4</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='externalNotificationId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">ISDN_DETAILED_REASON_RD</xsl:element>
            <xsl:element name="ignore_empty_result">Y</xsl:element>
          </xsl:element>
        </xsl:element>          
        
        
        <!--Get Notice Period Dur Value -->   
        <xsl:if test="request-param[@name='noticePeriodDurValue'] = ''">  
          <xsl:element name="CcmFifReadExternalNotificationCmd">
            <xsl:element name="command_id">read_external_notification_5</xsl:element>
            <xsl:element name="CcmFifReadExternalNotificationInCont">
              <xsl:element name="transaction_id">
                <xsl:value-of select="request-param[@name='externalNotificationId']"/>
              </xsl:element>
              <xsl:element name="parameter_name">NOTICE_PERIOD_DUR_VALUE</xsl:element>
              <xsl:element name="ignore_empty_result">Y</xsl:element>
            </xsl:element>
          </xsl:element> 
        </xsl:if>
      </xsl:if>
                    
      <xsl:if test="(request-param[@name='serviceSubscriptionId'] != '')">
        <!-- Look for the main service -->
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


      <!-- Create Order Form-->
      <xsl:if test="request-param[@name='productCommitmentNumber']=''">
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
            <xsl:if test="request-param[@name='noticePeriodDurValue'] != ''">
              <xsl:element name="notice_per_dur_value">
                <xsl:value-of select="request-param[@name='noticePeriodDurValue']"/>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='noticePeriodDurValue'] = ''">
              <xsl:element name="notice_per_dur_value_ref">
                <xsl:element name="command_id">read_external_notification_5</xsl:element>
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
            <xsl:element name="product_code">I1100</xsl:element>
            <xsl:element name="pricing_structure_code">
              <xsl:value-of select="request-param[@name='tariff']"/>
            </xsl:element>
            <xsl:if test="request-param[@name='noticePeriodDurValue'] != ''">
              <xsl:element name="use_psm_period_of_cancelation">N</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='noticePeriodDurValue'] = ''">
              <xsl:element name="use_psm_period_of_cancelation_ref">
                <xsl:element name="command_id">read_external_notification_5</xsl:element>
                <xsl:element name="field_name">value_found</xsl:element>
              </xsl:element>
            </xsl:if>          
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
      </xsl:if>
      
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
          <xsl:if test="request-param[@name='productCommitmentNumber'] != ''">	
            <xsl:element name="product_commitment_number">
              <xsl:value-of select="request-param[@name='productCommitmentNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='productCommitmentNumber'] = ''">	          
            <xsl:element name="product_commitment_number_ref">
              <xsl:element name="command_id">add_product_commitment_1</xsl:element>
              <xsl:element name="field_name">product_commitment_number</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="vis_tracking_position">
            <xsl:value-of select="request-param[@name='VISTrackingPosition']"/>
          </xsl:element>          
        </xsl:element>
      </xsl:element>
      <!-- Add service I1040 -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">I1040</xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="request-param[@name='reasonRd']"/>
          </xsl:element>
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
            <!-- Mailbox account Name -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I0610</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='mailboxAccountName']"/>
              </xsl:element>
            </xsl:element>
            <!-- Dial-In account Name -->
            <xsl:element name="CcmFifAccessNumberCont">
              <xsl:element name="service_char_code">I9058</xsl:element>
              <xsl:element name="data_type">USER_ACCOUNT_NUM</xsl:element>
              <xsl:element name="network_account">
                <xsl:value-of select="request-param[@name='dialInAccountName']"/>
              </xsl:element>
            </xsl:element>
            <!--  Mailbox access type -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I9065</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='mailboxAccessType']"/>
              </xsl:element>
            </xsl:element>
            <!--  Frontpage extension -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I9066</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='frontpageExtension']"/>
              </xsl:element>
            </xsl:element>
            <!--  Mailbox alias name -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I0590</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='mailboxAliasName']"/>
              </xsl:element>
            </xsl:element>
            <!--  User name -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I9056</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='OnlineUserName']"/>
              </xsl:element>
            </xsl:element>
            <!--  Admin. für die Onlineadministrationsbereich -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I9063</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='onlineAdmin']"/>
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
            <!--  Kondition/Rabatt -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0162</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='rabattIndicator']"/>
              </xsl:element>
            </xsl:element>             
          </xsl:element>
          <xsl:element name="detailed_reason_ref">
            <xsl:element name="command_id">read_external_notification_4</xsl:element>
            <xsl:element name="field_name">parameter_value</xsl:element>
          </xsl:element>  
         </xsl:element>
      </xsl:element>
   
      <!-- Add  Service V0099 if the bonusIndicator is set -->
      <xsl:if test="request-param[@name='bonusIndicator'] = 'Y'">
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_2</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">add_product_subscription_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V0099</xsl:element> 
            <xsl:element name="desired_date">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">
              <xsl:value-of select="request-param[@name='reasonRd']"/>
            </xsl:element>      
            <xsl:if test="request-param[@name='accountNumber'] = ''">          
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element> 
            </xsl:if> 
            <xsl:if test="request-param[@name='accountNumber'] != ''">          
              <xsl:element name="account_number">
                <xsl:value-of select="request-param[@name='accountNumber']"/>
              </xsl:element>  
            </xsl:if> 
            <!-- Bemerkung -->
            <xsl:element name="service_characteristic_list">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0008</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">NOT_RELEVANT</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <xsl:if test="request-param[@name='bundleType'] != ''">         
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
            <xsl:element name="bundle_item_type_rd">
              <xsl:value-of select="request-param[@name='bundleType']"/>
            </xsl:element>
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
            <xsl:element name="bundle_item_type_rd">
              <xsl:value-of select="request-param[@name='bundleType']"/>
            </xsl:element>
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
      </xsl:if>

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
            <xsl:element name="provider_tracking_no">003i</xsl:element> 
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
            <!-- I1040 -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <!-- V0099 -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_2</xsl:element>
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
            <xsl:element name="parent_customer_order_id">
              <xsl:value-of select="request-param[@name='customerOrderID']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>     
   

      <!-- Create Contact for the addition of online service -->
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
          <xsl:element name="contact_type_rd">CREATE_ONL</xsl:element>
          <xsl:element name="short_description">
            <xsl:text>Dienst hinzugefügt über </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
          </xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;Service Code: I1040</xsl:text>
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
              <xsl:element name="parameter_name">ONLINE_SERVICE_SUBSCRIPTION_ID</xsl:element> 
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">add_service_1</xsl:element> 
                <xsl:element name="field_name">service_subscription_id</xsl:element> 
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
