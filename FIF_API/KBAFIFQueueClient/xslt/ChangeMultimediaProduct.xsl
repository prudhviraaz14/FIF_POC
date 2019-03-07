<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a Multimedia product change FIF request

  @author banania
-->

<!DOCTYPE XSL [
<!ENTITY TerminateService_Multimedia SYSTEM "TerminateService_Multimedia.xsl">
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  exclude-result-prefixes="dateutils">

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
    <xsl:element name="client_name">KBA</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">
      <!-- Convert the termination date to OPM format -->
      <xsl:variable name="relocationDateOPM"
        select="dateutils:createOPMDate(request-param[@name='activationDate'])"/>
      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
      
      <xsl:variable name="terminationDateOPM"
        select="dateutils:createOPMDate(request-param[@name='activationDate'])"/>
  
      <xsl:variable name="NoticePeriodStartDate">
        <xsl:value-of select="request-param[@name='activationDate']"/>
      </xsl:variable>
        
      <xsl:variable name="TerminationDate">
        <xsl:value-of select="request-param[@name='activationDate']"/>
      </xsl:variable>
          
      <xsl:variable name="OrderVariant">MM-Produktwechsel</xsl:variable>              
     
      <xsl:variable name="TerminationReason">KKG</xsl:variable>    
    
      
      <xsl:variable name="IPTVResonRd">VOD_TO_IPTV</xsl:variable> 
      <xsl:variable name="VODResonRd">IPTV_TO_VOD</xsl:variable> 

      <xsl:variable name="IPTVBasic">IPTV_BASIC</xsl:variable> 
      <xsl:variable name="VODBasic">VOD_BASIC</xsl:variable> 
            
      <xsl:variable name="ReasonRd">
        <xsl:if test="request-param[@name='targetProductCode'] = 'I1302'">
          <xsl:value-of select="$IPTVResonRd"/>
        </xsl:if>
        <xsl:if test="request-param[@name='targetProductCode'] = 'I1304'">
          <xsl:value-of select="$VODResonRd"/>
        </xsl:if>
      </xsl:variable>
 
 
      <xsl:variable name="MultimediaProduct">
        <xsl:if test="request-param[@name='targetProductCode'] = 'I1302'">
          <xsl:value-of select="$IPTVBasic"/>
        </xsl:if>
        <xsl:if test="request-param[@name='targetProductCode'] = 'I1304'">
          <xsl:value-of select="$VODBasic"/>
        </xsl:if>
      </xsl:variable>
 
      <!-- Ensure that the paramter productCode is set correctly -->
      <xsl:if test="(request-param[@name='productCode'] != 'I1302')
        and (request-param[@name='productCode'] != 'I1304')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The paramter productCode can be set to 'I1302' or 'I1304' only! </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if> 
                
      <!-- Ensure that the paramter targetProductCode is set correctly -->
      <xsl:if test="(request-param[@name='targetProductCode'] != 'I1302')
        and (request-param[@name='targetProductCode'] != 'I1304')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">error_2</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The paramter productCode can be set to 'I1302' or 'I1304' only! </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if> 
     
      <!-- Look for the DSL service if DSLServiceSubscriptionId is provided --> 
      <xsl:if test="(request-param[@name='DSLServiceSubscriptionId'] != '')">   
        
        <!-- Look for the NGN-DSL service -->    
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="request-param[@name='DSLServiceSubscriptionId']"/>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='activationDate']"/>
            </xsl:element>           
          </xsl:element>
        </xsl:element>
        
        <!-- Ensure, that the service  belongs to an NGN_DSL  service (I1210) -->
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
                <xsl:element name="value">I1210</xsl:element>
              </xsl:element>             
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- check for a bandwidth change  -->
        <xsl:element name="CcmFifValidatePreviousActionCmd">
          <xsl:element name="command_id">validate_previous_action_1</xsl:element>
          <xsl:element name="CcmFifValidatePreviousActionInCont">
            <xsl:element name="action_name">changeDSLBandwidth</xsl:element>
          </xsl:element>
        </xsl:element>   
                     
        <!-- Reconfigure Service Subscription : For NGN Product -->
        <xsl:element name="CcmFifReconfigServiceCmd">
          <xsl:element name="command_id">reconf_serv_1</xsl:element>
          <xsl:element name="CcmFifReconfigServiceInCont">
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">
              <xsl:value-of select="$ReasonRd"/>
            </xsl:element>
            <xsl:element name="service_characteristic_list">
              <!-- Multimedia-VC -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">I1323</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="$MultimediaProduct"/>
                </xsl:element>
              </xsl:element>
              <!-- Reason for reconfiguration -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0943</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">MM-Änderung</xsl:element>
              </xsl:element>
              <!-- Aktivierungsdatum -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0909</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="$terminationDateOPM"/>
                </xsl:element>
              </xsl:element>						
            </xsl:element>     
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">validate_previous_action_1</xsl:element>
              <xsl:element name="field_name">action_performed_ind</xsl:element>          	
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>                 
          </xsl:element>
        </xsl:element>        
        
        <!-- Create Customer Order reconfigure NGN-DSL  -->        
        <xsl:element name="CcmFifCreateCustOrderCmd">
          <xsl:element name="command_id">create_co_1</xsl:element>
          <xsl:element name="CcmFifCreateCustOrderInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="customer_tracking_id">
              <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
            </xsl:element>                             
            <xsl:element name="provider_tracking_no">001</xsl:element>             
            <xsl:element name="service_ticket_pos_list">
              <!-- I1210 -->
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">reconf_serv_1</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>                                 
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">validate_previous_action_1</xsl:element>
              <xsl:element name="field_name">action_performed_ind</xsl:element>          	
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>               
          </xsl:element>
        </xsl:element>
        
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="CcmFifReleaseCustOrderInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">create_co_1</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>  
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">validate_previous_action_1</xsl:element>
              <xsl:element name="field_name">action_performed_ind</xsl:element>          	
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>   
          </xsl:element>
        </xsl:element> 
                
      </xsl:if> 
         
      <!-- Look for the NGNDSL service in the external notification if DSLServiceSubscriptionId is not provided --> 
      <xsl:if test="(request-param[@name='DSLServiceSubscriptionId'] = '')">   
              
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_external_notification_1</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">NGNDSL_SERVICE_SUBSCRIPTION_ID</xsl:element>                        
          </xsl:element>
        </xsl:element>
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='activationDate']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Find service characteristic code -->
        <xsl:element name="CcmFifFindServiceCharByValueCmd">
          <xsl:element name="command_id">find_serv_char_value_1</xsl:element>
          <xsl:element name="CcmFifFindServiceCharByValueInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_char_code_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">I1323</xsl:element>
              </xsl:element>             
            </xsl:element>
            <xsl:element name="characteristic_value">
              <xsl:value-of select="$MultimediaProduct"/>
            </xsl:element>
            <xsl:element name="characteristic_type">CONFIGURED_VALUE</xsl:element>
          </xsl:element>
        </xsl:element> 
        
      </xsl:if>    
                                                 

      <!-- Look for the Multimedia service -->    
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_2</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='activationDate']"/>
          </xsl:element>           
        </xsl:element>
      </xsl:element>
      
      <!-- Clone Order Form -->
      <xsl:element name="CcmFifCloneOrderFormCmd">
        <xsl:element name="command_id">clone_order_form_1</xsl:element>
        <xsl:element name="CcmFifCloneOrderFormInCont">
          <xsl:element name="scenario_type">PRODUCT_CHANGE</xsl:element>
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="sales_org_num_value">
            <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
          </xsl:element>     
          <xsl:element name="sales_org_num_value_vf">
            <xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
          </xsl:element> 
          <xsl:element name="target_product_code">
            <xsl:value-of select="request-param[@name='targetProductCode']"/>
          </xsl:element>     
          <xsl:element name="target_pricing_structure_code">
            <xsl:value-of select="request-param[@name='tariff']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="$ReasonRd"/>
          </xsl:element>  
          <xsl:element name="board_sign_name">
            <xsl:value-of select="request-param[@name='boardSignName']"/>
          </xsl:element>
          <xsl:element name="primary_cust_sign_name">
            <xsl:value-of select="request-param[@name='primaryCustSignName']"/>
          </xsl:element> 
          <xsl:element name="min_per_dur_value">
            <xsl:value-of select="request-param[@name='minPeriodDurationValue']"/>
          </xsl:element>
          <xsl:element name="min_per_dur_unit">
            <xsl:value-of select="request-param[@name='minPeriodDurationUnit']"/>
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
          <xsl:element name="target_product_type">Premium</xsl:element>  
          <xsl:if test="count(request-param-list[@name='featureServiceList']/request-param-list-item) != 0">
            <xsl:element name="service_code_list">
              <!-- Pass in the list of service codes -->
              <xsl:for-each
                select="request-param-list[@name='featureServiceList']/request-param-list-item">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="service_code">
                    <xsl:value-of select="request-param"/>
                  </xsl:element>
                </xsl:element>
              </xsl:for-each>
            </xsl:element>
          </xsl:if>
          <xsl:element name="service_characteristic_list">            
            <!-- Aktivierungsdatum-->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$relocationDateOPM"/>
              </xsl:element>
            </xsl:element>             
            <!-- Order variant -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1311</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$OrderVariant"/>
              </xsl:element>
            </xsl:element>  
            <!-- Allow Donwgrade -->        
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1313</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='allowDowngrade']"/>
              </xsl:element>
            </xsl:element>
            <!-- FSKLevel -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1314</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='FSKLevel']"/>
              </xsl:element>
            </xsl:element>
            <!-- Allow partial cancellation -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1315</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='allowPartialCancel']"/>
              </xsl:element>
            </xsl:element>            
            <!-- Bearbeitungsart -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">VI002</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">OP</xsl:element>
            </xsl:element>            
            <!-- Comment -->          
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Produktwechsel Multimedia</xsl:element>
            </xsl:element>                   
          </xsl:element>
          <xsl:element name="termination_restriction_rd">
            <xsl:value-of select="request-param[@name='terminationRestrictionRd']"/>
          </xsl:element>   
        </xsl:element>
      </xsl:element>
      
      <!-- Find the service V0017 (Monatspreis)-->
      <xsl:element name="CcmFifFindExclusiveChildServSubsCmd">
        <xsl:element name="command_id">find_monthly_charge_service_1</xsl:element>
        <xsl:element name="CcmFifFindExclusiveChildServSubsInCont">
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">clone_order_form_1</xsl:element>
            <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0017</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Add  Service V0017 if not found -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_monthly_charge_service_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">clone_order_form_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V0017</xsl:element>
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">clone_order_form_1</xsl:element>
            <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
          </xsl:element> 
          <xsl:element name="desired_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="$ReasonRd"/>
          </xsl:element>          
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>  
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_monthly_charge_service_1</xsl:element>
            <xsl:element name="field_name">service_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>      
          <xsl:element name="service_characteristic_list"/>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Customer Orders for Cloning of Services -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_mm_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="sales_rep_dept_ref">
            <xsl:element name="command_id">find_service_2</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
          <xsl:element name="provider_tracking_no">003h</xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">clone_order_form_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element> 
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_monthly_charge_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Release Customer Orders for Cloning  -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_mm_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element> 
      
      <!-- look for a Multimedia bundle (item) -->
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
      
      <!-- add the new  bundle item if a bundle is found -->
      <xsl:element name="CcmFifModifyBundleItemCmd">
        <xsl:element name="command_id">modify_bundle_item_1</xsl:element>
        <xsl:element name="CcmFifModifyBundleItemInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='targetProductCode'] = 'I1302'">
            <xsl:element name="bundle_item_type_rd">IPTV_BASIC</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='targetProductCode'] = 'I1304'">
            <xsl:element name="bundle_item_type_rd">VOD_BASIC</xsl:element>
          </xsl:if>
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">clone_order_form_1</xsl:element>
            <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
          <xsl:element name="action_name">ADD</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Terminate the Multimedia Contract -->   
      &TerminateService_Multimedia;
      
      <!-- Write the main access service to the external Notification -->   
      <xsl:element name="CcmFifCreateExternalNotificationCmd">
        <xsl:element name="command_id">create_notification_1</xsl:element>
        <xsl:element name="CcmFifCreateExternalNotificationInCont">
          <xsl:element name="effective_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="transaction_id">
            <xsl:value-of select="request-param[@name='requestListId']"/>
          </xsl:element>
          <xsl:element name="processed_indicator">Y</xsl:element>
          <xsl:element name="notification_action_name">RelocateService</xsl:element>
          <xsl:element name="target_system">FIF</xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:if test="request-param[@name='targetProductCode'] = 'I1302'">
                <xsl:element name="parameter_name">IPTV_SERVICE_SUBSCRIPTION_ID</xsl:element>
              </xsl:if>
              <xsl:if test="request-param[@name='targetProductCode'] = 'I1304'">
                <xsl:element name="parameter_name">VOD_SERVICE_SUBSCRIPTION_ID</xsl:element>
              </xsl:if>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">clone_order_form_1</xsl:element>
                <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
              </xsl:element>
            </xsl:element>   
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:if test="request-param[@name='targetProductCode'] = 'I1302'">
                <xsl:element name="parameter_name">IPTV_DETAILED_REASON_RD</xsl:element>
              </xsl:if>
              <xsl:if test="request-param[@name='targetProductCode'] = 'I1304'">
                <xsl:element name="parameter_name">VOD_DETAILED_REASON_RD</xsl:element>
              </xsl:if>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">clone_order_form_1</xsl:element>
                <xsl:element name="field_name">detailed_reason_rd</xsl:element>
              </xsl:element>
            </xsl:element>                   							  
          </xsl:element>        
        </xsl:element>
      </xsl:element>
      
      <!-- Create Contact for the Service relocation -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">SWAP_MM</xsl:element>
          <xsl:element name="short_description">MM-Produktwechsel</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;ContractNumber: </xsl:text>
            <xsl:value-of select="request-param[@name='contractNumber']"/>
            <xsl:text>&#xA;User Name: </xsl:text>
            <xsl:value-of select="request-param[@name='userName']"/>
            <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
            <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>  
       
    </xsl:element>

  </xsl:template>
</xsl:stylesheet>
