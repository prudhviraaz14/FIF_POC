        
    <!-- Clone Order Form -->
    <xsl:element name="CcmFifCloneOrderFormCmd">
      <xsl:element name="command_id">clone_order_form_1</xsl:element>
      <xsl:element name="CcmFifCloneOrderFormInCont">
        <xsl:element name="scenario_type">
          <xsl:value-of select="$scenarioType"/>
        </xsl:element>
        <xsl:choose>
          <xsl:when test="$targetCustomerNumber != ''">
            <xsl:element name="customer_number">
              <xsl:value-of select="$targetCustomerNumber"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_target_customer</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>          
            </xsl:element>            
          </xsl:otherwise>
        </xsl:choose>
        <xsl:element name="account_number_ref">
          <xsl:element name="command_id">find_target_account</xsl:element>
          <xsl:element name="field_name">parameter_value</xsl:element>          
        </xsl:element>
        <xsl:element name="contract_number_ref">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="field_name">contract_number</xsl:element>          
        </xsl:element>
        <xsl:element name="sales_org_num_value">
          <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
        </xsl:element>      
        <xsl:element name="sales_org_num_value_vf">
			<xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
		</xsl:element>                 
        <xsl:element name="target_product_code">
          <xsl:value-of select="request-param[@name='productCode']"/>
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
        <xsl:element name="copy_dep_chars">
          <xsl:value-of select="$keepAccessNumbers"/>
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
        <xsl:if test="$scenarioType = 'RELOCATION' or 
          $scenarioType = 'PROVIDER_CHANGE' or 
          $scenarioType = 'TAKEOVER'">
          <xsl:element name="address_ref">
            <xsl:element name="command_id">find_location_address</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
        </xsl:if>
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
        <xsl:element name="service_characteristic_list">
          <xsl:if test="$scenarioType = 'RELOCATION' or 
            $scenarioType = 'PROVIDER_CHANGE' or
            $scenarioType = 'TAKEOVER'">
            <!-- New location -->
            <xsl:element name="CcmFifAddressCharacteristicCont">
              <xsl:element name="service_char_code">V0014</xsl:element>
              <xsl:element name="data_type">ADDRESS</xsl:element>
              <xsl:element name="address_ref">
                <xsl:element name="command_id">find_location_address</xsl:element>
                <xsl:element name="field_name">output_string</xsl:element>
              </xsl:element>
            </xsl:element>  
          </xsl:if>             
          <!-- Aktivierungsdatum-->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0909</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">
              <xsl:value-of select="$desiredDateOPM"/>
            </xsl:element>
          </xsl:element>
          <!-- Auftragsvariante -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">VI008</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">
              <xsl:value-of select="$OrderVariant"/>
            </xsl:element>
          </xsl:element>  
          <!-- Anzahl der neue Rufnummern -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0936</xsl:element>
            <xsl:element name="data_type">INTEGER</xsl:element>
            <xsl:element name="configured_value">
              <xsl:value-of select="request-param[@name='numberOfNewAccessNumbers']"/>
            </xsl:element>
          </xsl:element>          
          <!-- Bearbeitungsart -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">VI002</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">OP</xsl:element>
          </xsl:element>
          <!-- Bundle Kennzeichen -->   
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">VI047</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">Standalone</xsl:element>
          </xsl:element>      
          <!-- Technologieflag -->   
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">VI048</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">NGN</xsl:element>
          </xsl:element>  
        </xsl:element>
        <xsl:element name="suppress_directory_entry">
          <xsl:value-of select="request-param[@name='suppressDirectoryEntry']"/>
        </xsl:element>  
        <xsl:element name="keep_contract_conditions">
          <xsl:value-of select="$keepContractConditions"/>
        </xsl:element>
        <xsl:element name="source_packet_ref">
          <xsl:element name="command_id">read_source_packet</xsl:element>
          <xsl:element name="field_name">parameter_value</xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    
    <!-- find service and connected objects by SS ID -->
    <xsl:element name="CcmFifFindServiceSubsCmd">
      <xsl:element name="command_id">find_cloned_service</xsl:element>
      <xsl:element name="CcmFifFindServiceSubsInCont">	      
        <xsl:element name="service_subscription_id_ref">
          <xsl:element name="command_id">clone_order_form_1</xsl:element>
          <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>    
    
    <!-- Add Voice over IP  Service VI220 if not found  -->
    <xsl:element name="CcmFifAddServiceSubsCmd">
      <xsl:element name="command_id">add_monthly_charge_service</xsl:element>
      <xsl:element name="CcmFifAddServiceSubsInCont">
        <xsl:element name="product_subscription_ref">
          <xsl:element name="command_id">clone_order_form_1</xsl:element>
          <xsl:element name="field_name">product_subscription_id</xsl:element>
        </xsl:element>
        <xsl:element name="service_code">VI220</xsl:element>
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
        <xsl:element name="service_characteristic_list"/>           
      </xsl:element>
    </xsl:element>
    
    <xsl:choose>
      <xsl:when test="$scenarioType = 'PROVIDER_CHANGE' or $scenarioType = 'TAKEOVER'">
        <xsl:element name="CcmFifModifyBundleCmd">
          <xsl:element name="command_id">modify_bundle_1</xsl:element>
          <xsl:element name="CcmFifModifyBundleInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_cloned_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>          
            </xsl:element>
          </xsl:element>
        </xsl:element>          
      </xsl:when>
      <xsl:otherwise>
        <!-- Create a new bundle if no one has been found -->
        <xsl:element name="CcmFifModifyBundleCmd">
          <xsl:element name="command_id">modify_bundle_1</xsl:element>
          <xsl:element name="CcmFifModifyBundleInCont">
            <xsl:element name="bundle_id_ref">
              <xsl:element name="command_id">find_bundle_1</xsl:element>
              <xsl:element name="field_name">bundle_id</xsl:element>
            </xsl:element>           
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_cloned_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>          
            </xsl:element>
            <xsl:element name="bundle_found_ref">
              <xsl:element name="command_id">find_bundle_1</xsl:element>
              <xsl:element name="field_name">bundle_found</xsl:element>
            </xsl:element>         
          </xsl:element>
        </xsl:element>          
      </xsl:otherwise>
    </xsl:choose>
    
    <!-- add the new voice over IP  bundle item if a bundle is found -->
    <xsl:element name="CcmFifModifyBundleItemCmd">
      <xsl:element name="command_id">modify_bundle_item_1</xsl:element>
      <xsl:element name="CcmFifModifyBundleItemInCont">
        <xsl:element name="bundle_id_ref">
          <xsl:element name="command_id">modify_bundle_1</xsl:element>
          <xsl:element name="field_name">bundle_id</xsl:element>
        </xsl:element>
        <xsl:element name="bundle_item_type_rd">VOIP_SERVICE</xsl:element>
        <xsl:element name="supported_object_id_ref">
          <xsl:element name="command_id">clone_order_form_1</xsl:element>
          <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
        </xsl:element>
        <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
        <xsl:element name="action_name">ADD</xsl:element>
      </xsl:element>
    </xsl:element>
          
     <!-- Create Customer Orders for Cloning -->
     <xsl:element name="CcmFifCreateCustOrderCmd">
       <xsl:element name="command_id">create_activation_co</xsl:element>
       <xsl:element name="CcmFifCreateCustOrderInCont">
         <xsl:element name="customer_number_ref">
           <xsl:element name="command_id">find_cloned_service</xsl:element>
           <xsl:element name="field_name">customer_number</xsl:element>          
         </xsl:element>
         <xsl:element name="customer_tracking_id">
           <xsl:value-of select="$activationBarcode"/>
         </xsl:element>
         <xsl:element name="sales_rep_dept_ref">
           <xsl:element name="command_id">find_service_1</xsl:element>
           <xsl:element name="field_name">product_commitment_number</xsl:element>
         </xsl:element>
         <xsl:element name="provider_tracking_no">
           <xsl:choose>
             <xsl:when test="request-param[@name='providerTrackingNumberVoiceTarget'] != ''">
               <xsl:value-of select="request-param[@name='providerTrackingNumberVoiceTarget']" />
             </xsl:when>
             <xsl:otherwise>003v</xsl:otherwise>
           </xsl:choose>
         </xsl:element>
         <xsl:element name="service_ticket_pos_list">
           <xsl:element name="CcmFifCommandRefCont">
             <xsl:element name="command_id">clone_order_form_1</xsl:element>
             <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
           </xsl:element>
           <xsl:element name="CcmFifCommandRefCont">
             <xsl:element name="command_id">add_monthly_charge_service</xsl:element>
             <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
           </xsl:element>
         </xsl:element>  
         <xsl:element name="e_shop_id">
           <xsl:value-of select="request-param[@name='eShopID']"/>
         </xsl:element>       
       </xsl:element>
     </xsl:element>
     
    <!-- Release Customer Orders for Cloning  DSL services -->
    <xsl:element name="CcmFifReleaseCustOrderCmd">
      <xsl:element name="CcmFifReleaseCustOrderInCont">
        <xsl:element name="customer_number_ref">
          <xsl:element name="command_id">find_cloned_service</xsl:element>
          <xsl:element name="field_name">customer_number</xsl:element>          
        </xsl:element>
        <xsl:element name="customer_order_ref">
          <xsl:element name="command_id">create_activation_co</xsl:element>
          <xsl:element name="field_name">customer_order_id</xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>

    <!-- Create Customer Order for Directory Entry -->
    <xsl:element name="CcmFifCreateCustOrderCmd">
      <xsl:element name="command_id">create_dir_entry_co</xsl:element>
      <xsl:element name="CcmFifCreateCustOrderInCont">
        <xsl:element name="customer_number_ref">
          <xsl:element name="command_id">find_cloned_service</xsl:element>
          <xsl:element name="field_name">customer_number</xsl:element>          
        </xsl:element>
        <xsl:element name="customer_tracking_id">
          <xsl:value-of select="$activationBarcode"/>
        </xsl:element>
        <xsl:element name="sales_rep_dept_ref">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="field_name">product_commitment_number</xsl:element>
        </xsl:element>
        <xsl:element name="provider_tracking_no">
          <xsl:choose>
            <xsl:when test="request-param[@name='providerTrackingNumberDirectoryEntryTarget'] != ''">
              <xsl:value-of select="request-param[@name='providerTrackingNumberDirectoryEntryTarget']" />
            </xsl:when>
            <xsl:otherwise>003vt</xsl:otherwise>
          </xsl:choose>
        </xsl:element>        
        <xsl:element name="ignore_empty_list_ind">Y</xsl:element> 
        <xsl:element name="service_ticket_pos_list">
          <xsl:element name="CcmFifCommandRefCont">
            <xsl:element name="command_id">clone_order_form_1</xsl:element>
            <xsl:element name="field_name">directory_entry_stp_list</xsl:element>
          </xsl:element>                          
        </xsl:element>
        <xsl:element name="e_shop_id">
          <xsl:value-of select="request-param[@name='eShopID']"/>
        </xsl:element> 
      </xsl:element>
    </xsl:element>
    
    <!-- Release Customer Order for  Directory Entry -->
    <xsl:element name="CcmFifReleaseCustOrderCmd">
      <xsl:element name="CcmFifReleaseCustOrderInCont">
        <xsl:element name="customer_number_ref">
          <xsl:element name="command_id">find_cloned_service</xsl:element>
          <xsl:element name="field_name">customer_number</xsl:element>          
        </xsl:element>
        <xsl:element name="customer_order_ref">
          <xsl:element name="command_id">create_dir_entry_co</xsl:element>
          <xsl:element name="field_name">customer_order_id</xsl:element>
        </xsl:element>
        <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
        <xsl:element name="parent_customer_order_id_ref">
          <xsl:element name="command_id">create_activation_co</xsl:element>
          <xsl:element name="field_name">customer_order_id</xsl:element>          	
        </xsl:element>
      </xsl:element>
    </xsl:element>    
    
    <!-- Terminate the VoIP Product -->   
    &TerminateService_VoIP;    
    
    <!-- add the new voice over IP  bundle item if a bundle is found -->
    <xsl:element name="CcmFifModifyBundleItemCmd">
        <xsl:element name="command_id">modify_bundle_item_1</xsl:element>
        <xsl:element name="CcmFifModifyBundleItemInCont">
            <xsl:element name="bundle_id_ref">
                <xsl:element name="command_id">modify_bundle_1</xsl:element>
                <xsl:element name="field_name">bundle_id</xsl:element>
            </xsl:element>
            <xsl:element name="bundle_item_type_rd">VOIP_SERVICE</xsl:element>
            <xsl:element name="supported_object_id_ref">
                <xsl:element name="command_id">clone_order_form_1</xsl:element>
                <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
            </xsl:element>
            <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
            <xsl:element name="action_name">MODIFY</xsl:element>
            <xsl:element name="future_indicator">Y</xsl:element>
        </xsl:element>
    </xsl:element>
    
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
        <xsl:element name="notification_action_name">
          <xsl:value-of select="//request/action-name"/>
        </xsl:element>
        <xsl:element name="target_system">FIF</xsl:element>
        <xsl:element name="parameter_value_list">
          <xsl:if test="request-param[@name='functionID'] != ''">  
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">
                <xsl:value-of select="request-param[@name='functionID']"/>
                <xsl:text>_SERVICE_SUBSCRIPTION_ID</xsl:text>
              </xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">clone_order_form_1</xsl:element>
                <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
              </xsl:element>
            </xsl:element>  
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">
                <xsl:value-of select="request-param[@name='functionID']"/>
                <xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
              </xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">create_activation_co</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
            </xsl:element>  
          </xsl:if>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    
    <xsl:element name="CcmFifConcatStringsCmd">
      <xsl:element name="command_id">activationPTN</xsl:element>
      <xsl:element name="CcmFifConcatStringsInCont">
        <xsl:element name="input_string_list">
          <xsl:element name="CcmFifCommandRefCont">
            <xsl:element name="command_id">create_activation_co</xsl:element>
            <xsl:element name="field_name">provider_tracking_no</xsl:element>							
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>             
    <xsl:element name="CcmFifConcatStringsCmd">
      <xsl:element name="command_id">reconfigurationPTN</xsl:element>
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
      <xsl:element name="command_id">terminationPTN</xsl:element>
      <xsl:element name="CcmFifConcatStringsInCont">
        <xsl:element name="input_string_list">
          <xsl:element name="CcmFifCommandRefCont">
            <xsl:element name="command_id">create_co_2</xsl:element>
            <xsl:element name="field_name">provider_tracking_no</xsl:element>							
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>             
    
    
