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
    <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
      
    <xsl:element name="Command_List">
      
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">functionID</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:value-of select="request-param[@name='functionID']"/>
              </xsl:element>							
            </xsl:element>                
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">functionStatus</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:choose>
                  <xsl:when test="request-param[@name='processingStatus'] = 'completedOPM'">SUCCESS</xsl:when>
                  <xsl:otherwise>ACKNOWLEDGED</xsl:otherwise>                  
                </xsl:choose>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>      
      
        <xsl:choose>
        <xsl:when test="request-param[@name='processingStatus'] = 'completedOPM'">
          
          <xsl:choose>
            <xsl:when test="request-param[@name='serviceDeliveryContractNumber'] != ''">
              <!-- add SDCPC -->
              <xsl:element name="CcmFifAddSDCProdCommitCmd">
                <xsl:element name="command_id">add_product_commitment</xsl:element>
                <xsl:element name="CcmFifAddSDCProdCommitInCont">
                  <xsl:element name="contract_number">
                    <xsl:value-of select="request-param[@name='serviceDeliveryContractNumber']"/>
                  </xsl:element>
                  <xsl:element name="product_code">I1410</xsl:element>
                  <xsl:element name="pricing_structure_code">
                    <xsl:value-of select="request-param[@name='tariff']"/>
                  </xsl:element>
                  <xsl:element name="notice_per_dur_value">
                    <xsl:value-of select="request-param[@name='noticePeriodDurationValue']"/>
                  </xsl:element>
                  <xsl:element name="notice_per_dur_unit">
                    <xsl:value-of select="request-param[@name='noticePeriodDurationUnit']"/>
                  </xsl:element>
                  <xsl:element name="term_start_date">
                    <xsl:value-of select="request-param[@name='termStartDate']"/>
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
                  <xsl:element name="special_termination_right">
                    <xsl:value-of select="request-param[@name='specialTerminationRight']"/>
                  </xsl:element>						
                </xsl:element>
              </xsl:element>
              
              <!-- sign SDC, if it is not signed yet TODO server code -->
              <xsl:element name="CcmFifSignServiceDelivContCmd">
                <xsl:element name="command_id">sign_sdc</xsl:element>
                <xsl:element name="CcmFifSignServiceDelivContInCont">
                  <xsl:element name="contract_number">
                    <xsl:value-of select="request-param[@name='serviceDeliveryContractNumber']"/>
                  </xsl:element>
                  <xsl:element name="board_sign_name">
                    <xsl:value-of select="request-param[@name='boardSignName']"/>
                  </xsl:element>
                  <xsl:element name="board_sign_date">
                    <xsl:value-of select="request-param[@name='boardSignDate']"/>
                  </xsl:element>
                  <xsl:element name="primary_cust_sign_name">
                    <xsl:value-of select="request-param[@name='primaryCustSignName']"/>
                  </xsl:element>
                  <xsl:element name="primary_cust_sign_date">
                    <xsl:value-of select="request-param[@name='primaryCustSignDate']"/>
                  </xsl:element>
                  <xsl:element name="secondary_cust_sign_name">
                    <xsl:value-of select="request-param[@name='secondaryCustSignName']"/>
                  </xsl:element>
                  <xsl:element name="secondary_cust_sign_date">
                    <xsl:value-of select="request-param[@name='secondaryCustSignDate']"/>
                  </xsl:element>
                  <xsl:element name="ignore_if_signed">Y</xsl:element>	
                </xsl:element>					
              </xsl:element>					
              
              <!-- sign the newly created SDCPC -->
              <xsl:element name="CcmFifSignSDCProductCommitmentCmd">
                <xsl:element name="command_id">sign_sdc_1</xsl:element>
                <xsl:element name="CcmFifSignSDCProductCommitmentInCont">
                  <xsl:element name="product_commitment_number_ref">
                    <xsl:element name="command_id">add_product_commitment</xsl:element>
                    <xsl:element name="field_name">product_commitment_number</xsl:element>
                  </xsl:element>
                  <xsl:element name="board_sign_name">
                    <xsl:value-of select="request-param[@name='boardSignName']"/>
                  </xsl:element>
                  <xsl:element name="board_sign_date">
                    <xsl:value-of select="request-param[@name='boardSignDate']"/>
                  </xsl:element>
                  <xsl:element name="primary_cust_sign_name">
                    <xsl:value-of select="request-param[@name='primaryCustSignName']"/>
                  </xsl:element>
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
            </xsl:when>
            <xsl:otherwise>
              <!-- Create Order Form-->
              <xsl:if test="request-param[@name='productCommitmentNumber'] = ''">
                <xsl:element name="CcmFifCreateOrderFormCmd">
                  <xsl:element name="command_id">create_order_form_1</xsl:element>
                  <xsl:element name="CcmFifCreateOrderFormInCont">
                    <xsl:element name="customer_number">
                      <xsl:value-of select="request-param[@name='customerNumber']"/>
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
                  <xsl:element name="command_id">add_product_commitment</xsl:element>
                  <xsl:element name="CcmFifAddProductCommitInCont">
                    <xsl:element name="customer_number">
                      <xsl:value-of select="request-param[@name='customerNumber']"/>
                    </xsl:element>
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
                  <xsl:element name="command_id">sign_of</xsl:element>
                  <xsl:element name="CcmFifSignOrderFormInCont">
                    <xsl:element name="contract_number_ref">
                      <xsl:element name="command_id">create_order_form_1</xsl:element>
                      <xsl:element name="field_name">contract_number</xsl:element>
                    </xsl:element>
                    <xsl:element name="board_sign_name">
                      <xsl:value-of select="request-param[@name='boardSignName']"/>
                    </xsl:element>
                    <xsl:element name="board_sign_date">
                      <xsl:value-of select="request-param[@name='boardSignDate']"/>
                    </xsl:element>
                    <xsl:element name="primary_cust_sign_name">
                      <xsl:value-of select="request-param[@name='primaryCustSignName']"/>
                    </xsl:element>
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
            </xsl:otherwise>
          </xsl:choose>
                    
          <!-- Add Product Subscription -->
          <xsl:element name="CcmFifAddProductSubsCmd">
            <xsl:element name="command_id">add_product_subscription</xsl:element>
            <xsl:element name="CcmFifAddProductSubsInCont">
              <xsl:element name="customer_number">
                <xsl:value-of select="request-param[@name='customerNumber']"/>
              </xsl:element>
              <xsl:if test="request-param[@name='productCommitmentNumber'] != ''">
                <xsl:element name="product_commitment_number">
                  <xsl:value-of select="request-param[@name='productCommitmentNumber']"/>
                </xsl:element>
              </xsl:if>
              <xsl:if test="request-param[@name='productCommitmentNumber'] = ''">
                <xsl:element name="product_commitment_number_ref">
                  <xsl:element name="command_id">add_product_commitment</xsl:element>
                  <xsl:element name="field_name">product_commitment_number</xsl:element>
                </xsl:element>
              </xsl:if>
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
                <xsl:element name="command_id">add_product_subscription</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">I1410</xsl:element>
              <xsl:element name="service_subscription_id">
                <xsl:value-of select="request-param[@name='allocatedServiceSubscriptionId']"/>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$today"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">ASAP</xsl:element>
              <xsl:element name="reason_rd">CREATE_SECURITY</xsl:element>
              <xsl:element name="account_number">
                <xsl:value-of select="request-param[@name='accountNumber']"/>
              </xsl:element>
              <xsl:element name="service_characteristic_list">
                <!-- Aktivierungsdatum -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">I1403</xsl:element>
                  <xsl:element name="data_type">DATE</xsl:element>
                  <xsl:element name="configured_value">
                    <xsl:value-of select="$desiredDateOPM"/>
                  </xsl:element>
                </xsl:element>
                <!--  activation Key -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">I1402</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">
                    <xsl:value-of select="request-param[@name='activationKey']"/>
                  </xsl:element>
                </xsl:element>
                <!--  remarks -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">V0008</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">
                    <xsl:value-of select="request-param[@name='remarks']"/>
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
          
          <!-- Create Customer Order -->
          <xsl:element name="CcmFifCreateCustOrderCmd">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="CcmFifCreateCustOrderInCont">
              <xsl:element name="customer_number">
                <xsl:value-of select="request-param[@name='customerNumber']"/>
              </xsl:element>
              <xsl:element name="cust_order_description">Erstellung Sicherheitspaket</xsl:element>
              <xsl:element name="customer_tracking_id">
                <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
              </xsl:element>
              <xsl:element name="lan_path_file_string">
                <xsl:value-of select="request-param[@name='lanPathFileString']"/>
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
              <xsl:element name="processing_status">
                <xsl:value-of select="request-param[@name='processingStatus']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
                    
          <!-- Get bundle id -->     
          <xsl:element name="CcmFifReadExternalNotificationCmd">
            <xsl:element name="command_id">read_bundle_id</xsl:element>
            <xsl:element name="CcmFifReadExternalNotificationInCont">
              <xsl:element name="transaction_id">
                <xsl:value-of select="request-param[@name='requestListId']"/>
              </xsl:element>
              <xsl:element name="parameter_name">
                <xsl:text>BUNDLE_ID</xsl:text>
              </xsl:element>
            </xsl:element>
          </xsl:element>          
          
          <!-- add the new bundle item if a bundle is found -->
          <xsl:element name="CcmFifModifyBundleItemCmd">
            <xsl:element name="command_id">modify_bundle_item</xsl:element>
            <xsl:element name="CcmFifModifyBundleItemInCont">
              <xsl:element name="bundle_id_ref">
                <xsl:element name="command_id">read_bundle_id</xsl:element>
                <xsl:element name="field_name">parameter_value</xsl:element>
              </xsl:element>
              <xsl:element name="bundle_item_type_rd">SOFTWARE</xsl:element>
              <xsl:element name="supported_object_id_ref">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
              <xsl:element name="action_name">ADD</xsl:element>
              <xsl:if test="request-param[@name='futureIndicator'] != ''">
                <xsl:element name="future_indicator">
                  <xsl:value-of select="request-param[@name='futureIndicator']"/>
                </xsl:element>
              </xsl:if>
            </xsl:element>
          </xsl:element>
                    
          <!--  Create external notification for internal purposes -->
          <xsl:element name="CcmFifCreateExternalNotificationCmd">
            <xsl:element name="command_id">create_notification_1</xsl:element>
            <xsl:element name="CcmFifCreateExternalNotificationInCont">
              <xsl:element name="effective_date">
                <xsl:value-of select="dateutils:getCurrentDate()"/>
              </xsl:element>
              <xsl:element name="transaction_id">
                <xsl:value-of select="request-param[@name='requestListId']"/>
              </xsl:element>
              <xsl:element name="processed_indicator">Y</xsl:element>
              <xsl:element name="notification_action_name">
                <xsl:value-of select="//request/action-name"/>
              </xsl:element>
              <xsl:element name="target_system">FIF</xsl:element>
              <xsl:element name="parameter_value_list">
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">
                    <xsl:value-of select="request-param[@name='functionID']"/>
                    <xsl:text>_SERVICE_SUBSCRIPTION_ID</xsl:text>
                  </xsl:element>
                  <xsl:element name="parameter_value_ref">
                    <xsl:element name="command_id">add_service_1</xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
                </xsl:element>							
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">
                    <xsl:value-of select="request-param[@name='functionID']"/>
                    <xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
                  </xsl:element>
                  <xsl:element name="parameter_value_ref">
                    <xsl:element name="command_id">create_co_1</xsl:element>
                    <xsl:element name="field_name">customer_order_id</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          
        </xsl:when>
        <xsl:otherwise>
      
            <xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">   
                <xsl:element name="CcmFifFindServiceSubsCmd">
                    <xsl:element name="command_id">find_service_1</xsl:element>
                    <xsl:element name="CcmFifFindServiceSubsInCont">
                        <xsl:element name="service_subscription_id">
                            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:if>

            <xsl:if test="request-param[@name='productSubscriptionId'] != '' and request-param[@name='serviceSubscriptionId'] = ''">   
            <!-- Look for the ISDN/DSL-R or NGN service -->
            <xsl:element name="CcmFifFindServiceSubsForProductCmd">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="CcmFifFindServiceSubsForProductInCont">
                <xsl:element name="product_subscription_id">
                  <xsl:value-of select="request-param[@name='productSubscriptionId']"/>
                </xsl:element>
                <xsl:element name="service_code_list">
                  <xsl:element name="CcmFifPassingValueCont">
                    <xsl:element name="service_code">V0010</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifPassingValueCont">
                    <xsl:element name="service_code">V0011</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifPassingValueCont">
                    <xsl:element name="service_code">V0003</xsl:element>
                  </xsl:element>            
                  <xsl:element name="CcmFifPassingValueCont">
                    <xsl:element name="service_code">I1043</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifPassingValueCont">
                    <xsl:element name="service_code">I104A</xsl:element>
                  </xsl:element>            
                  <xsl:element name="CcmFifPassingValueCont">
                    <xsl:element name="service_code">I1210</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifPassingValueCont">
                    <xsl:element name="service_code">I1213</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            
            <xsl:element name="CcmFifFindServiceSubsCmd">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="CcmFifFindServiceSubsInCont">
                <xsl:element name="service_subscription_id_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">service_subscription_id</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:if>
          <!-- Look for the ISDN service in the external notification if productSubscriptionId is not provided --> 
            <xsl:if test="request-param[@name='productSubscriptionId'] = '' and request-param[@name='serviceSubscriptionId'] = ''">  
            
            <xsl:variable name="Type">
              <xsl:value-of select="request-param[@name='type']"/>
            </xsl:variable> 
            
            <xsl:element name="CcmFifReadExternalNotificationCmd">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="CcmFifReadExternalNotificationInCont">
                <xsl:element name="transaction_id">
                  <xsl:value-of select="request-param[@name='requestListId']"/>
                </xsl:element>
                <xsl:element name="parameter_name">   
                  <xsl:value-of select="concat($Type, '_SERVICE_SUBSCRIPTION_ID')"/>  
                </xsl:element>                 
              </xsl:element>
            </xsl:element>
            
            <xsl:element name="CcmFifFindServiceSubsCmd">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="CcmFifFindServiceSubsInCont">
                <xsl:element name="service_subscription_id_ref">
                  <xsl:element name="command_id">read_external_notification_1</xsl:element>
                  <xsl:element name="field_name">parameter_value</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:if>
          
          <!-- Create Order Form-->
          <xsl:element name="CcmFifCreateOrderFormCmd">
            <xsl:element name="command_id">create_order_form_1</xsl:element>
            <xsl:element name="CcmFifCreateOrderFormInCont">
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
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
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
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
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
              <xsl:element name="product_commitment_number_ref">
                <xsl:element name="command_id">add_product_commitment_1</xsl:element>
                <xsl:element name="field_name">product_commitment_number</xsl:element>
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
              <xsl:element name="service_subscription_id">
                <xsl:value-of select="request-param[@name='allocatedServiceSubscriptionId']"/>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">END_BEFORE</xsl:element>
              <xsl:element name="reason_rd">CREATE_SECURITY</xsl:element>
              <xsl:element name="account_number">
                <xsl:value-of select="request-param[@name='accountNumber']"/>
              </xsl:element>
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
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
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
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
              <xsl:element name="customer_tracking_id">
                <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
              </xsl:element>
              <xsl:if test="request-param[@name='providerTrackingNumber'] = ''" > 
                <xsl:element name="provider_tracking_no">001f</xsl:element> 
              </xsl:if>          
              <xsl:if test="request-param[@name='providerTrackingNumber'] != ''">             
                <xsl:element name="provider_tracking_no">
                  <xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
                </xsl:element>
              </xsl:if>         
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
          
          <!-- Create Contact for the addition of security service -->
          <xsl:element name="CcmFifCreateContactCmd">
            <xsl:element name="CcmFifCreateContactInCont">
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
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
        </xsl:otherwise>          
      </xsl:choose>
      
      
      <xsl:if test="request-param[@name='clientName'] = 'CODB'">
          <xsl:element name="CcmFifConcatStringsCmd">
            <xsl:element name="command_id">getPTN</xsl:element>
            <xsl:element name="CcmFifConcatStringsInCont">
              <xsl:element name="input_string_list">              
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">create_co_1</xsl:element>
                  <xsl:element name="field_name">provider_tracking_no</xsl:element>							
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>

          <xsl:element name="CcmFifConcatStringsCmd">
            <xsl:element name="command_id">safetyService</xsl:element>
            <xsl:element name="CcmFifConcatStringsInCont">
              <xsl:element name="input_string_list">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">add_service_1</xsl:element>
                  <xsl:element name="field_name">service_subscription_id</xsl:element>							
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>      
          <xsl:element name="CcmFifConcatStringsCmd">
            <xsl:element name="command_id">safetyContractNumber</xsl:element>
            <xsl:element name="CcmFifConcatStringsInCont">
              <xsl:element name="input_string_list">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">create_order_form_1</xsl:element>
                  <xsl:element name="field_name">contract_number</xsl:element>							
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>      
                   
      </xsl:if>      

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
