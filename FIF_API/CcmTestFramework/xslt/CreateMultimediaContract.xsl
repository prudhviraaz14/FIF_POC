<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a multi media contract. IT-17690 - IPTV.

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
    
    <!-- Convert the desired date to OPM format -->
    <xsl:variable name="desiredDateOPM"
      select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
      
    <!-- Calculate today and one day before the desired date -->
    <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
        
    <xsl:element name="Command_List">
 
      <xsl:variable name="AddServCommandId">add_ss_</xsl:variable>
      <xsl:variable name="AccountNumber" select="request-param[@name='accountNumber']"/> 
      <xsl:variable name="IPTVResonRd">CREATE_IPTV</xsl:variable> 
      <xsl:variable name="VODResonRd">CREATE_VOD</xsl:variable> 
      <xsl:variable name="ReasonRd">
        <xsl:if test="request-param[@name='multimediaProduct'] = 'IPTV_BASIC'">
          <xsl:value-of select="$IPTVResonRd"/>
        </xsl:if>
        <xsl:if test="request-param[@name='multimediaProduct'] = 'VOD_BASIC'">
          <xsl:value-of select="$VODResonRd"/>
        </xsl:if>
      </xsl:variable>
      
      <!-- Ensure that the paramter multimedia Product is set correctly -->
      <xsl:if test="(request-param[@name='multimediaProduct'] != 'IPTV_BASIC')
        and (request-param[@name='multimediaProduct'] != 'VOD_BASIC')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The paramter multimediaProduct can be set to 'IPTV_BASIC' or 'VOD_BASIC' only! </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>      
      <!-- Look for the ISDN/DSL-R service if productSubscriptionId is provided --> 
      <xsl:if test="(request-param[@name='serviceSubscriptionId'] != '')">   
        <!-- Look for the NGN-DSL service -->    
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
              <xsl:value-of select="request-param[@name='multimediaProduct']"/>
            </xsl:element>
            <xsl:element name="characteristic_type">CONFIGURED_VALUE</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">validate_previous_action_1</xsl:element>
              <xsl:element name="field_name">action_performed_ind</xsl:element>          	
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>           
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
            <xsl:if test="request-param[@name='multimediaProduct'] = 'IPTV_BASIC'">
              <xsl:element name="reason_rd">CREATE_IPTV</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='multimediaProduct'] = 'VOD_BASIC'">
              <xsl:element name="reason_rd">CREATE_VOD</xsl:element>
            </xsl:if> 
            <xsl:element name="service_characteristic_list">
              <!-- Multimedia-VC -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">I1323</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">
                    <xsl:value-of select="request-param[@name='multimediaProduct']"/>
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
                  <xsl:value-of select="$desiredDateOPM"/>
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
            <xsl:element name="e_shop_id">
			  <xsl:value-of select="request-param[@name='eShopID']"/>
			</xsl:element>            
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
      
      <!-- Look for the NGNDSL service in the external notification if serviceSubscriptionId is not provided --> 
      <xsl:if test="(request-param[@name='serviceSubscriptionId'] = '')">         
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
                <xsl:value-of select="request-param[@name='desiredDate']"/>
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
              <xsl:value-of select="request-param[@name='multimediaProduct']"/>
            </xsl:element>
           <xsl:element name="characteristic_type">CONFIGURED_VALUE</xsl:element>
          </xsl:element>
        </xsl:element> 
        
        </xsl:if>
      
      <!-- Get Entity Information -->
      <xsl:element name="CcmFifGetEntityCmd">
        <xsl:element name="command_id">get_entity_1</xsl:element>
        <xsl:element name="CcmFifGetEntityInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Location Address  if the address id is not provided. SPN-FIF-000039525-O-->
      <xsl:if test="request-param[@name='addressId'] = ''">
      <xsl:element name="CcmFifCreateAddressCmd">
        <xsl:element name="command_id">create_addr_1</xsl:element>
        <xsl:element name="CcmFifCreateAddressInCont">
          <xsl:element name="entity_ref">
            <xsl:element name="command_id">get_entity_1</xsl:element>
            <xsl:element name="field_name">entity_id</xsl:element>
          </xsl:element>       
          <xsl:element name="address_type">LOKA</xsl:element>
          <xsl:element name="street_name">
            <xsl:value-of select="request-param[@name='streetName']"/>
          </xsl:element>
          <xsl:element name="street_number">
            <xsl:value-of select="request-param[@name='streetNumber']"/>
          </xsl:element>
          <xsl:element name="street_number_suffix">
            <xsl:value-of select="request-param[@name='numberSuffix']"/>
          </xsl:element>
          <xsl:element name="postal_code">
            <xsl:value-of select="request-param[@name='postalCode']"/>
          </xsl:element>
          <xsl:element name="city_name">
            <xsl:value-of select="request-param[@name='city']"/>
          </xsl:element>
          <xsl:element name="city_suffix_name">
            <xsl:value-of select="request-param[@name='citySuffix']"/>
          </xsl:element>
          <xsl:element name="country_code">DE</xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>

      <!-- Normalize Address  if the address id is provided. -->
      <xsl:if test="request-param[@name='addressId'] != ''">
		<xsl:element name="CcmFifNormalizeAddressCmd">
			<xsl:element name="command_id">normalize_address_1</xsl:element>
			<xsl:element name="CcmFifNormalizeAddressInCont">
				<xsl:element name="customer_number">
					<xsl:value-of select="request-param[@name='customerNumber']"/>
				</xsl:element>
				<xsl:element name="address_id">
					<xsl:value-of select="request-param[@name='addressId']"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
      </xsl:if>

      <!-- Create Order Form-->
      <xsl:element name="CcmFifCreateOrderFormCmd">
        <xsl:element name="command_id">create_order_form_1</xsl:element>
        <xsl:element name="CcmFifCreateOrderFormInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>         
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
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">create_order_form_1</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='multimediaProduct'] = 'IPTV_BASIC'">
            <xsl:element name="product_code">I1302</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='multimediaProduct'] = 'VOD_BASIC'">
            <xsl:element name="product_code">I1304</xsl:element>
          </xsl:if>          
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
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="product_commitment_number_ref">
            <xsl:element name="command_id">add_product_commitment_1</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Add Multimedia main access Service -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='multimediaProduct'] = 'IPTV_BASIC'">
            <xsl:element name="service_code">I1302</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='multimediaProduct'] = 'VOD_BASIC'">
            <xsl:element name="service_code">I1303</xsl:element>
          </xsl:if> 
          <xsl:element name="desired_date">
            <xsl:value-of select="$today"/>	
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:if test="request-param[@name='multimediaProduct'] = 'IPTV_BASIC'">
            <xsl:element name="reason_rd">CREATE_IPTV</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='multimediaProduct'] = 'VOD_BASIC'">
            <xsl:element name="reason_rd">CREATE_VOD</xsl:element>
          </xsl:if>           
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='accountNumber']"/>
          </xsl:element>                   
          <xsl:element name="service_characteristic_list">
            <!-- Address -->
            <xsl:element name="CcmFifAddressCharacteristicCont">
              <xsl:element name="service_char_code">V0014</xsl:element>
              <xsl:element name="data_type">ADDRESS</xsl:element>
              <xsl:if test="request-param[@name='addressId'] = ''">
                <xsl:element name="address_ref">
                  <xsl:element name="command_id">create_addr_1</xsl:element>
                  <xsl:element name="field_name">address_id</xsl:element>
                </xsl:element>
              </xsl:if>
              <xsl:if test="request-param[@name='addressId'] != ''">
                <xsl:element name="address_id">
                  <xsl:value-of select="request-param[@name='addressId']"/>
                </xsl:element>
              </xsl:if>
            </xsl:element>
            <!-- Order variant -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1311</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='orderVariant']"/>
              </xsl:element>
            </xsl:element>  
            <!-- Allow partial cancellation -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1313</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='allowPartialCancel']"/>
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
            <!-- Allow Downgrade -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1315</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='allowDowngrade']"/>
              </xsl:element>
            </xsl:element>             
            <!-- Bearbeitungsart -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">VI002</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">OP</xsl:element>
            </xsl:element>            
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$desiredDateOPM"/>
              </xsl:element>
            </xsl:element>
            <!-- Reason for reconfiguration -->          
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1312</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">unbekannt</xsl:element>
            </xsl:element>  
            <!-- Comment -->          
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Anlage Multimedia-Vertrag</xsl:element>
            </xsl:element>                              
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Add Feature Service V0017 Monthly Charge  -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_0</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V0017</xsl:element>
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">add_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$today"/>	
          </xsl:element> 
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="$ReasonRd"/>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='accountNumber']"/>
          </xsl:element> 
          <xsl:element name="service_characteristic_list"/>
        </xsl:element>
      </xsl:element>


     <!-- Add Feature Service V0083 Setup Charge  -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_01</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">add_product_subscription_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V0083</xsl:element>
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">add_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$today"/>	
          </xsl:element> 
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="$ReasonRd"/>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='accountNumber']"/>
          </xsl:element> 
          <xsl:element name="service_characteristic_list"/>
        </xsl:element>
      </xsl:element>
            
            
      <xsl:if
        test="count(request-param-list[@name='featureServiceList']/request-param-list-item) != 0">
        <!-- Create feature Services -->
        <xsl:for-each select="request-param-list[@name='featureServiceList']/request-param-list-item">          
          <xsl:variable name="ServiceCode" select="request-param[@name='serviceCode']"/>          
          
          <!-- Add feature services -->
          <xsl:element name="CcmFifAddServiceSubsCmd">
            <xsl:element name="command_id">
              <xsl:value-of select="concat($AddServCommandId, $ServiceCode)"/>
            </xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">
                <xsl:value-of select="$ServiceCode"/>
              </xsl:element>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$today"/>	
              </xsl:element>     
              <xsl:element name="reason_rd">
                <xsl:value-of select="$ReasonRd"/>
              </xsl:element>
              <xsl:element name="account_number">
                <xsl:value-of select="request-param[@name='accountNumber']"/>
              </xsl:element> 
              <xsl:element name="service_characteristic_list"></xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
      </xsl:if>
      
      <!-- look for a voice bundle (item) -->
      <xsl:element name="CcmFifFindBundleCmd">
        <xsl:element name="command_id">find_bundle_1</xsl:element>
        <xsl:element name="CcmFifFindBundleInCont">
           <xsl:element name="bundle_item_type_rd">ACCESS</xsl:element>
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
          <xsl:if test="request-param[@name='multimediaProduct'] = 'IPTV_BASIC'">
            <xsl:element name="bundle_item_type_rd">IPTV_BASIC</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='multimediaProduct'] = 'VOD_BASIC'">
            <xsl:element name="bundle_item_type_rd">VOD_BASIC</xsl:element>
          </xsl:if>  
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">add_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
          <xsl:element name="action_name">ADD</xsl:element>
        </xsl:element>
      </xsl:element>
        
      <!-- Create Customer Order for new services  -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_2</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>                                      
          <xsl:element name="provider_tracking_no">003h</xsl:element>                    
          <xsl:element name="service_ticket_pos_list">
            <!-- Multimedia -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element> 
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_0</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element> 
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_01</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>             
            <xsl:for-each select="request-param-list[@name='featureServiceList']/request-param-list-item">
              <xsl:variable name="ServiceCode" select="request-param[@name='serviceCode']"/>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">
                  <xsl:value-of select="concat($AddServCommandId, $ServiceCode)"/>
                </xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:for-each>                                 
          </xsl:element>
          <xsl:element name="e_shop_id">
			<xsl:value-of select="request-param[@name='eShopID']"/>
		  </xsl:element>
        </xsl:element>
      </xsl:element>
                
     <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_2</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>          
        </xsl:element>
      </xsl:element>           
      
      <!-- Create Contact for Service Addition -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>        
          <xsl:if test="request-param[@name='multimediaProduct'] = 'IPTV_BASIC'">
            <xsl:element name="contact_type_rd">CREATE_IPTV</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='multimediaProduct'] = 'VOD_BASIC'">
            <xsl:element name="contact_type_rd">CREATE_VOD</xsl:element>
          </xsl:if>        
          <xsl:element name="short_description">Create Multimedia</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;Desired Date: </xsl:text>
            <xsl:value-of select="request-param[@name='desiredDate']"/>
            <xsl:text>&#xA;User Name: </xsl:text>
            <xsl:value-of select="request-param[@name='userName']"/>
            <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
            <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
  
      <!-- Create External notification  if requestListId is set -->
      <xsl:if test="request-param[@name='requestListId'] != ''">
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_external_notification_1</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="notification_action_name">CreateVoIPContract</xsl:element>
            <xsl:element name="target_system">FIF</xsl:element>
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:if test="request-param[@name='multimediaProduct'] = 'IPTV_BASIC'">
                  <xsl:element name="parameter_name">IPTV_SERVICE_SUBSCRIPTION_ID</xsl:element> 
                </xsl:if>
                <xsl:if test="request-param[@name='multimediaProduct'] = 'VOD_BASIC'">
                  <xsl:element name="parameter_name">VOD_SERVICE_SUBSCRIPTION_ID</xsl:element> 
                </xsl:if> 
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">add_service_1</xsl:element> 
                  <xsl:element name="field_name">service_subscription_id</xsl:element> 
                </xsl:element>
              </xsl:element> 
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Create external notification -->
      <xsl:if test="request-param[@name='clientName'] != 'KBA'">
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_kba_notification_1</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:element>
            <xsl:element name="notification_action_name">createKBANotification</xsl:element>
            <xsl:element name="target_system">KBA</xsl:element>                           				
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>						
                  <xsl:element name="parameter_value">
                    <xsl:value-of select="request-param[@name='customerNumber']"/>
                  </xsl:element>												
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TYPE</xsl:element>
                <xsl:element name="parameter_value">CONTACT</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CATEGORY</xsl:element>
                <xsl:element name="parameter_value">CreateMultimediaContract</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:if test="request-param[@name='userName'] != ''">              
                  <xsl:element name="parameter_name">USER_NAME</xsl:element>
                  <xsl:element name="parameter_value">
                    <xsl:value-of select="request-param[@name='userName']"/>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='userName'] = ''">              
                  <xsl:element name="parameter_name">USER_NAME</xsl:element>
                  <xsl:element name="parameter_value">
                    <xsl:value-of select="request-param[@name='clientName']"/>
                  </xsl:element>
                </xsl:if>            
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='clientName']"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">WORK_DATE</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='desiredDate']"/>
                </xsl:element>
              </xsl:element>					
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TEXT</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:text>Multimedia contract has been created on </xsl:text>
                  <xsl:value-of select="$today"/>	
                  <xsl:text> by </xsl:text>  
                  <xsl:value-of select="request-param[@name='clientName']"/>
                  <xsl:text> with product </xsl:text>  
                  <xsl:value-of select="request-param[@name='multimediaProduct']"/> 
                  <xsl:text>.</xsl:text>              
                </xsl:element>
              </xsl:element>					
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
                  
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
