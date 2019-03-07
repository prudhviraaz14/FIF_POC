        
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
          <xsl:value-of select="$DSLProductCode"/>
        </xsl:element>
        <xsl:element name="target_pricing_structure_code">
          <xsl:value-of select="request-param[@name='tariffDSL']"/>
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
        <xsl:element name="target_product_type">
          <xsl:text>NGN_</xsl:text>
          <xsl:value-of select="$targetProductType"/>
        </xsl:element>         
        <xsl:element name="service_characteristic_list">
          <xsl:if test="$scenarioType = 'RELOCATION' or 
            $scenarioType = 'PROVIDER_CHANGE' or
            $scenarioType = 'TAKEOVER'">
            <!-- Standort-Adresse -->
            <xsl:element name="CcmFifAddressCharacteristicCont">
              <xsl:element name="service_char_code">V0014</xsl:element>
              <xsl:element name="data_type">ADDRESS</xsl:element>
              <xsl:element name="address_ref">
                <xsl:element name="command_id">find_location_address</xsl:element>
                <xsl:element name="field_name">output_string</xsl:element>
              </xsl:element>
            </xsl:element>
            <!-- Anschlussinhaberadresse -->
            <xsl:element name="CcmFifAddressCharacteristicCont">
              <xsl:element name="service_char_code">V0126</xsl:element>
              <xsl:element name="data_type">ADDRESS</xsl:element>
              <xsl:element name="address_ref">
                <xsl:element name="command_id">find_location_address</xsl:element>
                <xsl:element name="field_name">output_string</xsl:element>
              </xsl:element>
            </xsl:element>  
          </xsl:if>
          <xsl:if test="$scenarioType = 'RELOCATION'">
            <!-- Umzugsvariante -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V2024</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='relocationVariant']"/>
              </xsl:element>
            </xsl:element>
            <!-- Anschlussbereich_kennz. -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0934</xsl:element>
              <xsl:element name="data_type">INTEGER</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='asb']"/>
              </xsl:element>
            </xsl:element>
            <!-- Lage TAE -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0123</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='locationTAE']"/>
              </xsl:element>
            </xsl:element>        
            <!-- ONKZ -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0124</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='localAreaCode']"/>
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
          <!-- Auftragsvariante  -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0810</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>                                                                      
            <xsl:element name="configured_value">
              <xsl:value-of select="$OrderVariant"/>
            </xsl:element>    
          </xsl:element>
          <!-- Bearbeitungsart -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0971</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">TAL</xsl:element>
          </xsl:element>
          <!-- DSLBandbreite -->
          <xsl:if test="request-param[@name='DSLBandwidth'] != ''">
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0826</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='DSLBandwidth']"/>
              </xsl:element>
            </xsl:element>
          </xsl:if>
          <!-- DSL Upstream Bandbreite -->
          <xsl:if test="request-param[@name='upstreamBandwidth'] != ''">
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0092</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='upstreamBandwidth']"/>
              </xsl:element>
            </xsl:element>
          </xsl:if>
          <!-- Allow Downgrade -->
          <xsl:if test="request-param[@name='allowDowngrade'] != ''">
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0875</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='allowDowngrade']"/>
              </xsl:element>
            </xsl:element>
          </xsl:if>
          <!-- Desired Bandwidth -->
          <xsl:if test="request-param[@name='desiredBandwidth'] != ''">
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0876</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='desiredBandwidth']"/>
              </xsl:element>
            </xsl:element>
          </xsl:if>
          <!-- Anschlusstechnologie -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V009C</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">
              <xsl:value-of select="request-param[@name='portType']"/>
            </xsl:element>
          </xsl:element>          
          <!-- Leitungstyp -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0138</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">
              <xsl:value-of select="request-param[@name='lineType']"/>
            </xsl:element>
          </xsl:element>
          <!-- Carrier -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0081</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">
              <xsl:value-of select="request-param[@name='carrier']"/>
            </xsl:element>
          </xsl:element>
          <!-- DTAG-Freitext -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0141</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">
              <xsl:value-of select="request-param[@name='DTAGFreetext']"/>
            </xsl:element>
          </xsl:element>
          <!-- Rückrufnummer -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0125</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">
              <xsl:value-of select="request-param[@name='customerCallBackNumber']"/>
            </xsl:element>
          </xsl:element>
          <!-- Technology Change Reason -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0943</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">
              <xsl:value-of select="request-param[@name='technologyChangeReason']"/>
            </xsl:element>
          </xsl:element> 
          <!-- Multimedia-VC -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">I1323</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">
              <xsl:value-of select="request-param[@name='multimediaProduct']"/>
            </xsl:element>
          </xsl:element>  
          <xsl:if test="$scenarioType = 'PROVIDER_CHANGE' or $scenarioType = 'TAKEOVER'">
            <!-- alte Kundennummer -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0945</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:if>
          <!-- Instant Access -->
          <xsl:if test="request-param[@name='instantAccessIndicator'] != ''">
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V8003</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='instantAccessIndicator']"/>
              </xsl:element>
            </xsl:element>
          </xsl:if>          
        </xsl:element>
        <xsl:element name="suppress_directory_entry">
          <xsl:value-of select="request-param[@name='suppressDirectoryEntry']"/>
        </xsl:element>  
        <xsl:element name="technology_change_reason_rd">
          <xsl:value-of select="request-param[@name='technologyChangeReason']"/>
        </xsl:element>  
        <xsl:element name="keep_contract_conditions">
          <xsl:value-of select="$keepContractConditions"/>
        </xsl:element>
        <xsl:element name="excluded_services">
          <xsl:element name="CcmFifPassingValueCont">
            <xsl:element name="service_code">I1359</xsl:element>
          </xsl:element>
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
    
    <!-- Add monthly charge V0017 -->
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
          <xsl:if test="$targetAccountNumber != ''">
              <xsl:value-of select="$targetAccountNumber"/>                
          </xsl:if>  
          <xsl:if test="$targetAccountNumber = ''">
              <xsl:if test="$scenarioType = 'TAKEOVER'
                  or $scenarioType = 'PROVIDER_CHANGE'">
                  <xsl:element name="command_id">find_target_account</xsl:element>
                  <xsl:element name="field_name">parameter_value</xsl:element>   
              </xsl:if> 
              <xsl:if test="$scenarioType != 'TAKEOVER'
                  and $scenarioType != 'PROVIDER_CHANGE'">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">account_number</xsl:element>   
              </xsl:if> 
          </xsl:if>
        </xsl:element>  
        <xsl:element name="service_characteristic_list"/>           
      </xsl:element>
    </xsl:element>        
    
    <!-- if the bandwidth is not provided, this must be a contract partner change 
      without any changes to the products of the customer, so we need to get the
      bandwidth from the old contract -->         
      <xsl:if test="request-param[@name='DSLBandwidth'] = ''">
        <xsl:element name="CcmFifFindServiceTicketPositionCmd">
          <xsl:element name="command_id">find_most_recent_stp</xsl:element>
          <xsl:element name="CcmFifFindServiceTicketPositionInCont">
            <xsl:element name="contract_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>          
            </xsl:element>
            <xsl:element name="find_stp_parameters">
              <xsl:element name="CcmFifFindStpParameterCont">
                <xsl:element name="service_code">V0113</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifFindStpParameterCont">
                <xsl:element name="service_code">V0088</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifFindStpParameterCont">
                <xsl:element name="service_code">I1210</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifFindStpParameterCont">
                <xsl:element name="service_code">I1213</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <xsl:element name="CcmFifFindServCharValueForServCharCmd">
          <xsl:element name="command_id">find_V0826</xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharInCont">
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_most_recent_stp</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>          
            </xsl:element>
            <xsl:element name="service_char_code">V0826</xsl:element>
            <xsl:element name="no_csc_error">N</xsl:element>
            <xsl:element name="retrieve_all_characteristics">Y</xsl:element>
          </xsl:element>
        </xsl:element>			
        
        <xsl:element name="CcmFifMapStringCmd">
          <xsl:element name="command_id">map_bandwidth_service_code</xsl:element>
          <xsl:element name="CcmFifMapStringInCont">
            <xsl:element name="input_string_type">oldDSLBandwidth</xsl:element>
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_V0826</xsl:element>
                <xsl:element name="field_name">characteristic_value</xsl:element>							
              </xsl:element>
            </xsl:element>
            <xsl:element name="output_string_type">bandwidthServiceCode</xsl:element>
            <xsl:element name="string_mapping_list">
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">DSL 1000</xsl:element>
                <xsl:element name="output_string">V0118</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">DSL 2000</xsl:element>
                <xsl:element name="output_string">V0174</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">DSL 6000</xsl:element>
                <xsl:element name="output_string">V0178</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">DSL 16000</xsl:element>
                <xsl:element name="output_string">V018C</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">DSL 25000</xsl:element>
                <xsl:element name="output_string">V018G</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">DSL 50000</xsl:element>
                <xsl:element name="output_string">V018H</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="no_mapping_error">N</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Add Service V0118 DSL Anschluss 1000  if DSLBandwidth is  DSL 1000   -->
    <xsl:variable name="bandwidthServiceCode">
      <xsl:choose>
        <xsl:when test="request-param[@name='DSLBandwidth'] = 'DSL 1000'">V0118</xsl:when>
        <xsl:when test="request-param[@name='DSLBandwidth'] = 'DSL 2000'">V0174</xsl:when>
        <xsl:when test="request-param[@name='DSLBandwidth'] = 'DSL 6000'">V0178</xsl:when>
        <xsl:when test="request-param[@name='DSLBandwidth'] = 'DSL 16000'">V018C</xsl:when>
        <xsl:when test="request-param[@name='DSLBandwidth'] = 'DSL 25000'">V018G</xsl:when>
        <xsl:when test="request-param[@name='DSLBandwidth'] = 'DSL 50000'">V018H</xsl:when>
        <xsl:otherwise>Illegal bandwidth</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:element name="CcmFifAddServiceSubsCmd">
      <xsl:element name="command_id">add_service_1</xsl:element>
      <xsl:element name="CcmFifAddServiceSubsInCont">
        <xsl:element name="product_subscription_ref">
          <xsl:element name="command_id">clone_order_form_1</xsl:element>
          <xsl:element name="field_name">product_subscription_id</xsl:element>
        </xsl:element>
        <xsl:if test="$bandwidthServiceCode != ''">                  
          <xsl:element name="service_code">
            <xsl:value-of select="$bandwidthServiceCode"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="$bandwidthServiceCode = ''">                  
          <xsl:element name="service_code_ref">
            <xsl:element name="command_id">map_bandwidth_service_code</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
        </xsl:if>
        <xsl:element name="parent_service_subs_ref">
          <xsl:element name="command_id">clone_order_form_1</xsl:element>
          <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
        </xsl:element>
        <xsl:element name="desired_date">
          <xsl:value-of select="$today"/>
        </xsl:element>
        <xsl:element name="desired_schedule_type">ASAP</xsl:element>
        <xsl:element name="reason_rd">
          <xsl:value-of select="$ReasonRd"/>
        </xsl:element>
        <xsl:element name="account_number_ref">
          <xsl:element name="command_id">find_cloned_service</xsl:element>
          <xsl:element name="field_name">account_number</xsl:element>          
        </xsl:element>
        <xsl:element name="service_characteristic_list"/>
        <xsl:element name="detailed_reason_ref">
          <xsl:element name="command_id">clone_order_form_1</xsl:element>
          <xsl:element name="field_name">detailed_reason_rd</xsl:element>
        </xsl:element>   
      </xsl:element>
    </xsl:element>
    
  <!-- look for a bundle (item) of the original contract -->
  <xsl:element name="CcmFifFindBundleCmd">
    <xsl:element name="command_id">find_bundle_1</xsl:element>
    <xsl:element name="CcmFifFindBundleInCont">
      <xsl:element name="bundle_item_type_rd">
        <xsl:if test="$currentProductCode = $ISDNProductCode">VOICE_SERVICE</xsl:if>
        <xsl:if test="$currentProductCode = $BitStreamDSLProductCode">BITACCESS</xsl:if>
        <xsl:if test="$currentProductCode = $DSLProductCode">ACCESS</xsl:if>
      </xsl:element>
      <xsl:element name="supported_object_id_ref">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="field_name">service_subscription_id</xsl:element>
      </xsl:element>
      <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
    </xsl:element>
  </xsl:element>
  
  <xsl:if test="$currentProductCode != $ISDNProductCode">
    <!-- look for a bundle (item) of the original contract -->
    <xsl:element name="CcmFifFindBundleCmd">
      <xsl:element name="command_id">find_bundle_2</xsl:element>
      <xsl:element name="CcmFifFindBundleInCont">
        <xsl:element name="bundle_id_ref">
          <xsl:element name="command_id">find_bundle_1</xsl:element>
          <xsl:element name="field_name">bundle_id</xsl:element>
        </xsl:element>
        <xsl:element name="bundle_item_type_rd">
          <xsl:if test="$currentProductCode = $BitStreamDSLProductCode">BITVOIP</xsl:if>
          <xsl:if test="$currentProductCode = $DSLProductCode">VOICE</xsl:if>
        </xsl:element>
        <xsl:element name="process_ind_ref">
          <xsl:element name="command_id">find_bundle_1</xsl:element>
          <xsl:element name="field_name">bundle_found</xsl:element>
        </xsl:element>
        <xsl:element name="required_process_ind">Y</xsl:element>
      </xsl:element>
    </xsl:element>
    
    <!-- Find VoIP Service Subscription by bundled SS id, if a bundle was found -->           
    <xsl:element name="CcmFifFindServiceSubsCmd">
      <xsl:element name="command_id">find_service_2</xsl:element>
      <xsl:element name="CcmFifFindServiceSubsInCont">
        <xsl:element name="service_subscription_id_ref">
          <xsl:element name="command_id">find_bundle_2</xsl:element>
          <xsl:element name="field_name">supported_object_id</xsl:element>
        </xsl:element>
        <xsl:element name="process_ind_ref">
          <xsl:element name="command_id">find_bundle_2</xsl:element>
          <xsl:element name="field_name">bundle_found</xsl:element>
        </xsl:element>
        <xsl:element name="required_process_ind">Y</xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:if>
  
      <!-- Clone Order Form -->
      <xsl:element name="CcmFifCloneOrderFormCmd">
        <xsl:element name="command_id">clone_order_form_2</xsl:element>
        <xsl:element name="CcmFifCloneOrderFormInCont">
          <xsl:element name="scenario_type">
            <xsl:value-of select="$scenarioType"/>
          </xsl:element>
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_cloned_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>          
          </xsl:element>
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_cloned_service</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>          
          </xsl:element>          
          <xsl:if test="$currentProductCode = $ISDNProductCode"> 
            <xsl:element name="contract_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>          
            </xsl:element>
          </xsl:if>
          <xsl:if test="$currentProductCode != $ISDNProductCode"> 
            <xsl:element name="contract_number_ref">
              <xsl:element name="command_id">find_service_2</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>   
          </xsl:if>
          <xsl:element name="sales_org_num_value">
            <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
          </xsl:element>            
           <xsl:element name="sales_org_num_value_vf">
			<xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
		  </xsl:element>                 
          <xsl:element name="target_product_code">
            <xsl:value-of select="$VoIPProductCode"/>
          </xsl:element>
          <xsl:element name="target_pricing_structure_code">
            <xsl:value-of select="request-param[@name='tariffVoice']"/>
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
          <xsl:element name="target_product_type">
            <xsl:text>NGN_</xsl:text>
            <xsl:value-of select="$targetProductType"/>
          </xsl:element>                                
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
              <!-- Line Owner Address -->
              <xsl:element name="CcmFifAddressCharacteristicCont">
                <xsl:element name="service_char_code">V0126</xsl:element>
                <xsl:element name="data_type">ADDRESS</xsl:element>
                <xsl:element name="address_ref">
                  <xsl:element name="command_id">find_location_address</xsl:element>
                  <xsl:element name="field_name">output_string</xsl:element>
                </xsl:element>
              </xsl:element>              
            </xsl:if>
            <xsl:if test="$scenarioType = 'RELOCATION'">
              <!-- Anschlussbereich_kennz. -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0934</xsl:element>
                <xsl:element name="data_type">INTEGER</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='asb']"/>
                </xsl:element>
              </xsl:element>
              <!-- Lage TAE -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0123</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='locationTAE']"/>
                </xsl:element>
              </xsl:element>        
              <!-- ONKZ -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0124</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='localAreaCode']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>    
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$desiredDateOPM"/>
              </xsl:element>
            </xsl:element>
            <!-- Bearbeitungsart -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">VI002</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">OP</xsl:element>
            </xsl:element>    
            <!-- Bemerkung -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='userName']"/>
              </xsl:element>
            </xsl:element> 
            <!-- Carrier -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0081</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='carrier']"/>
              </xsl:element>
            </xsl:element>
            <!-- DTAG-Freitext -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0141</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='DTAGFreetext']"/>
              </xsl:element>
            </xsl:element>
            <!-- Rückrufnummer -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0125</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='customerCallBackNumber']"/>
              </xsl:element>
            </xsl:element>  
            <!-- Technology Change Reason -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0943</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='technologyChangeReason']"/>
              </xsl:element>
            </xsl:element>                                                                                                    
            <!-- Auftragsvariante  -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0810</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>                                                                      
              <xsl:element name="configured_value">
                <xsl:value-of select="$OrderVariant"/>
              </xsl:element>    
            </xsl:element>
            
            <xsl:if test="$OrderVariant != 'Umzug ohne Rufnummernübernahme'">            
              <xsl:choose>
                <xsl:when test="$isDowngrade = 'Y'">
                  <!-- In case of downgrade, all numbers have to be mentioned. If the selected
                    number is not the first access number, the numbers have to be swapped when 
                    populated on the characteristics -->            
                  <xsl:variable name="selectedNumberPosition">
                    <xsl:variable name="selectedNumberCountryCode">
                      <xsl:value-of select="request-param-list[@name='accessNumberList']/request-param-list-item[1]/request-param[@name='countryCode']"/>
                    </xsl:variable>
                    <xsl:variable name="selectedNumberAreaCode">
                      <xsl:value-of select="request-param-list[@name='accessNumberList']/request-param-list-item[1]/request-param[@name='areaCode']"/>
                    </xsl:variable>
                    <xsl:variable name="selectedNumberLocalNumber">
                      <xsl:value-of select="request-param-list[@name='accessNumberList']/request-param-list-item[1]/request-param[@name='localNumber']"/>
                    </xsl:variable>
                    
                    <xsl:for-each select="request-param-list[@name='oldAccessNumberList']/request-param-list-item">
                      <xsl:if test="request-param[@name='countryCode'] = $selectedNumberCountryCode
                        and request-param[@name='areaCode'] = $selectedNumberAreaCode
                        and request-param[@name='localNumber'] = $selectedNumberLocalNumber">
                        <xsl:value-of select="position()"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:variable>            
                  
                  <xsl:for-each select="request-param-list[@name='oldAccessNumberList']/request-param-list-item">              
                    <xsl:variable name="serviceCharCode">
                      <xsl:choose>
                        <xsl:when test="position() = $selectedNumberPosition">V0001</xsl:when>
                        <xsl:when test="position() = 2 and $selectedNumberPosition != 2">V0070</xsl:when>
                        <xsl:when test="position() = 3 and $selectedNumberPosition != 3">V0071</xsl:when>
                        <xsl:when test="position() = 4 and $selectedNumberPosition != 4">V0072</xsl:when>
                        <xsl:when test="position() = 5 and $selectedNumberPosition != 5">V0073</xsl:when>
                        <xsl:when test="position() = 6 and $selectedNumberPosition != 6">V0074</xsl:when>
                        <xsl:when test="position() = 7 and $selectedNumberPosition != 7">V0075</xsl:when>
                        <xsl:when test="position() = 8 and $selectedNumberPosition != 8">V0076</xsl:when>
                        <xsl:when test="position() = 9 and $selectedNumberPosition != 9">V0077</xsl:when>
                        <xsl:when test="position() = 10 and $selectedNumberPosition != 10">V0078</xsl:when>
                        <xsl:when test="position() = 1 and $selectedNumberPosition != 1">
                          <xsl:choose>
                            <xsl:when test="$selectedNumberPosition = 2">V0070</xsl:when>
                            <xsl:when test="$selectedNumberPosition = 3">V0071</xsl:when>
                            <xsl:when test="$selectedNumberPosition = 4">V0072</xsl:when>
                            <xsl:when test="$selectedNumberPosition = 5">V0073</xsl:when>
                            <xsl:when test="$selectedNumberPosition = 6">V0074</xsl:when>
                            <xsl:when test="$selectedNumberPosition = 7">V0075</xsl:when>
                            <xsl:when test="$selectedNumberPosition = 8">V0076</xsl:when>
                            <xsl:when test="$selectedNumberPosition = 9">V0077</xsl:when>
                            <xsl:when test="$selectedNumberPosition = 10">V0078</xsl:when>                      
                          </xsl:choose>
                        </xsl:when>                  
                      </xsl:choose>      
                    </xsl:variable>
                    
                    <!-- Rufnummer -->
                    <xsl:element name="CcmFifAccessNumberCont">
                      <xsl:element name="service_char_code">
                        <xsl:value-of select="$serviceCharCode"/>
                      </xsl:element>
                      <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                      <xsl:element name="country_code">
                        <xsl:value-of select="request-param[@name='countryCode']"/>
                      </xsl:element>
                      <xsl:element name="city_code">
                        <xsl:value-of select="request-param[@name='areaCode']"/>
                      </xsl:element>
                      <xsl:element name="local_number">
                        <xsl:value-of select="request-param[@name='localNumber']"/>
                      </xsl:element>
                    </xsl:element>
                  </xsl:for-each>
                </xsl:when>
                
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="count(request-param-list[@name='accessNumberList']/request-param-list-item) > 0">
                      <xsl:for-each select="request-param-list[@name='accessNumberList']/request-param-list-item">              
                        <xsl:variable name="serviceCharCode">
                          <xsl:choose>
                            <xsl:when test="position() = 1">V0001</xsl:when>
                            <xsl:when test="position() = 2">V0070</xsl:when>
                            <xsl:when test="position() = 3">V0071</xsl:when>
                            <xsl:when test="position() = 4">V0072</xsl:when>
                            <xsl:when test="position() = 5">V0073</xsl:when>
                            <xsl:when test="position() = 6">V0074</xsl:when>
                            <xsl:when test="position() = 7">V0075</xsl:when>
                            <xsl:when test="position() = 8">V0076</xsl:when>
                            <xsl:when test="position() = 9">V0077</xsl:when>
                            <xsl:when test="position() = 10">V0078</xsl:when>
                          </xsl:choose>      
                        </xsl:variable>
                        
                        <!-- Rufnummer -->
                        <xsl:element name="CcmFifAccessNumberCont">
                          <xsl:element name="service_char_code">
                            <xsl:value-of select="$serviceCharCode"/>
                          </xsl:element>
                          <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                          <xsl:element name="country_code">
                            <xsl:value-of select="request-param[@name='countryCode']"/>
                          </xsl:element>
                          <xsl:element name="city_code">
                            <xsl:value-of select="request-param[@name='areaCode']"/>
                          </xsl:element>
                          <xsl:element name="local_number">
                            <xsl:value-of select="request-param[@name='localNumber']"/>
                          </xsl:element>
                        </xsl:element>
                      </xsl:for-each>                    
                    </xsl:when>
                    <xsl:when test="$keepAccessNumbers = 'Y'">
                      <xsl:for-each select="request-param-list[@name='oldAccessNumberList']/request-param-list-item">              
                        <xsl:variable name="serviceCharCode">
                          <xsl:choose>
                            <xsl:when test="position() = 1">V0001</xsl:when>
                            <xsl:when test="position() = 2">V0070</xsl:when>
                            <xsl:when test="position() = 3">V0071</xsl:when>
                            <xsl:when test="position() = 4">V0072</xsl:when>
                            <xsl:when test="position() = 5">V0073</xsl:when>
                            <xsl:when test="position() = 6">V0074</xsl:when>
                            <xsl:when test="position() = 7">V0075</xsl:when>
                            <xsl:when test="position() = 8">V0076</xsl:when>
                            <xsl:when test="position() = 9">V0077</xsl:when>
                            <xsl:when test="position() = 10">V0078</xsl:when>
                          </xsl:choose>      
                        </xsl:variable>
                        
                        <!-- Rufnummer -->
                        <xsl:element name="CcmFifAccessNumberCont">
                          <xsl:element name="service_char_code">
                            <xsl:value-of select="$serviceCharCode"/>
                          </xsl:element>
                          <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                          <xsl:element name="country_code">
                            <xsl:value-of select="request-param[@name='countryCode']"/>
                          </xsl:element>
                          <xsl:element name="city_code">
                            <xsl:value-of select="request-param[@name='areaCode']"/>
                          </xsl:element>
                          <xsl:element name="local_number">
                            <xsl:value-of select="request-param[@name='localNumber']"/>
                          </xsl:element>
                        </xsl:element>
                      </xsl:for-each>                
                    </xsl:when>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
            <!-- Premium Type -->
            <xsl:if test="request-param[@name='desiredPremiumType'] != ''">							
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0190</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='desiredPremiumType']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>							
            <!-- Premium Type Change -->
            <xsl:if test="request-param[@name='allowPremiumTypeChange'] != ''">													
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0191</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='allowPremiumTypeChange']"/>
                </xsl:element>
              </xsl:element>    
            </xsl:if>           
            <!-- Anzahl der neue Rufnummern -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0936</xsl:element>
              <xsl:element name="data_type">INTEGER</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='numberOfNewAccessNumbers']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="suppress_directory_entry">
            <xsl:value-of select="request-param[@name='suppressDirectoryEntry']"/>
          </xsl:element> 
          <!-- Technolgy reason -->
          <xsl:element name="technology_change_reason_rd">
            <xsl:value-of select="request-param[@name='technologyChangeReason']"/>
          </xsl:element>         
          <xsl:element name="keep_contract_conditions">
            <xsl:value-of select="$keepContractConditions"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
     
     <!-- Add monthly charge V0017 -->
     <xsl:element name="CcmFifAddServiceSubsCmd">
       <xsl:element name="command_id">add_monthly_charge_service_2</xsl:element>
       <xsl:element name="CcmFifAddServiceSubsInCont">
         <xsl:element name="product_subscription_ref">
           <xsl:element name="command_id">clone_order_form_2</xsl:element>
           <xsl:element name="field_name">product_subscription_id</xsl:element>
         </xsl:element>
         <xsl:element name="service_code">V0017</xsl:element>
         <xsl:element name="parent_service_subs_ref">
           <xsl:element name="command_id">clone_order_form_2</xsl:element>
           <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
         </xsl:element> 
         <xsl:element name="desired_date">
           <xsl:value-of select="$today"/>
         </xsl:element>
         <xsl:element name="reason_rd">
           <xsl:value-of select="$ReasonRd"/>
         </xsl:element>          
         <xsl:element name="account_number_ref"> 
           <xsl:if test="$targetAccountNumber != ''">
               <xsl:value-of select="$targetAccountNumber"/>                
           </xsl:if>  
           <xsl:if test="$targetAccountNumber = ''">
               <xsl:if test="$scenarioType = 'TAKEOVER'
                   or $scenarioType = 'PROVIDER_CHANGE'">
                   <xsl:element name="command_id">find_target_account</xsl:element>
                   <xsl:element name="field_name">parameter_value</xsl:element>   
               </xsl:if> 
               <xsl:if test="$scenarioType != 'TAKEOVER'
                   and $scenarioType != 'PROVIDER_CHANGE'">
                   <xsl:element name="command_id">find_service_1</xsl:element>
                   <xsl:element name="field_name">account_number</xsl:element>   
               </xsl:if> 
           </xsl:if>
         </xsl:element> 
         <xsl:element name="service_characteristic_list"/>           
       </xsl:element>
     </xsl:element>             
     
     <xsl:element name="CcmFifReadExternalNotificationCmd">
       <xsl:element name="command_id">read_internet_stp</xsl:element>
       <xsl:element name="CcmFifReadExternalNotificationInCont">
         <xsl:element name="transaction_id">
           <xsl:value-of select="request-param[@name='requestListId']"/>
         </xsl:element>
         <xsl:element name="parameter_name">
           <xsl:value-of select="request-param[@name='internetFunctionID']"/>
           <xsl:text>_SERVICE_TICKET_POSITION_ID</xsl:text>
         </xsl:element>
         <xsl:element name="ignore_empty_result">Y</xsl:element>
       </xsl:element>
     </xsl:element>                          
     
     <xsl:element name="CcmFifReadExternalNotificationCmd">
       <xsl:element name="command_id">read_voice_stp</xsl:element>
       <xsl:element name="CcmFifReadExternalNotificationInCont">
         <xsl:element name="transaction_id">
           <xsl:value-of select="request-param[@name='requestListId']"/>
         </xsl:element>
         <xsl:element name="parameter_name">
           <xsl:value-of select="request-param[@name='voiceFunctionID']"/>
           <xsl:text>_SERVICE_TICKET_POSITION_ID</xsl:text>
         </xsl:element>
         <xsl:element name="ignore_empty_result">Y</xsl:element>
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
            <xsl:element name="ao_status">
              <xsl:value-of select="request-param[@name='amdocsOrderingIndicator']"/>
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
        <xsl:element name="bundle_item_type_rd">ACCESS</xsl:element>
        <xsl:element name="supported_object_id_ref">
          <xsl:element name="command_id">clone_order_form_1</xsl:element>
          <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
        </xsl:element>
        <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
        <xsl:element name="action_name">ADD</xsl:element>
      </xsl:element>
    </xsl:element>
    
    <!-- add the new voice over IP  bundle item if a bundle is found -->
    <xsl:element name="CcmFifModifyBundleItemCmd">
      <xsl:element name="command_id">modify_bundle_item_2</xsl:element>
      <xsl:element name="CcmFifModifyBundleItemInCont">
        <xsl:element name="bundle_id_ref">
          <xsl:element name="command_id">modify_bundle_1</xsl:element>
          <xsl:element name="field_name">bundle_id</xsl:element>
        </xsl:element>
        <xsl:element name="bundle_item_type_rd">ONLINE</xsl:element>
        <xsl:element name="supported_object_id_ref">
          <xsl:element name="command_id">clone_order_form_1</xsl:element>
          <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
        </xsl:element>
        <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
        <xsl:element name="action_name">ADD</xsl:element>
      </xsl:element>
    </xsl:element>
    
    <!-- add the new voice over IP bundle item if a bundle is found -->
    <xsl:element name="CcmFifModifyBundleItemCmd">
      <xsl:element name="command_id">modify_bundle_item_3</xsl:element>
      <xsl:element name="CcmFifModifyBundleItemInCont">
        <xsl:element name="bundle_id_ref">
          <xsl:element name="command_id">modify_bundle_1</xsl:element>
          <xsl:element name="field_name">bundle_id</xsl:element>
        </xsl:element>
        <xsl:element name="bundle_item_type_rd">VOICE</xsl:element>
        <xsl:element name="supported_object_id_ref">
          <xsl:element name="command_id">clone_order_form_2</xsl:element>
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
            <xsl:when test="request-param[@name='providerTrackingNumberInternetTarget'] != ''">
              <xsl:value-of select="request-param[@name='providerTrackingNumberInternetTarget']" />
            </xsl:when>
            <xsl:otherwise>003</xsl:otherwise>
          </xsl:choose>
        </xsl:element>
        <xsl:element name="service_ticket_pos_list">
          <xsl:element name="CcmFifCommandRefCont">
            <xsl:element name="command_id">clone_order_form_1</xsl:element>
            <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
          </xsl:element>          
          <xsl:element name="CcmFifCommandRefCont">
            <xsl:element name="command_id">add_monthly_charge_service_1</xsl:element>
            <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
          </xsl:element>
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
    
    <!-- Create Customer Orders for the addition of VoIP  -->
    <xsl:element name="CcmFifCreateCustOrderCmd">
      <xsl:element name="command_id">create_voip_co</xsl:element>
      <xsl:element name="CcmFifCreateCustOrderInCont">
        <xsl:element name="customer_number_ref">
          <xsl:element name="command_id">find_cloned_service</xsl:element>
          <xsl:element name="field_name">customer_number</xsl:element>          
        </xsl:element>
        <xsl:element name="customer_tracking_id">
          <xsl:value-of select="$activationBarcode"/>
        </xsl:element>
        <xsl:element name="sales_rep_dept_ref">
          <xsl:element name="command_id">find_service_2</xsl:element>
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
            <xsl:element name="command_id">clone_order_form_2</xsl:element>
            <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
          </xsl:element>
          <xsl:element name="CcmFifCommandRefCont">
            <xsl:element name="command_id">add_monthly_charge_service_2</xsl:element>
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
    
    <!-- Release Customer Order for Cloning  VoIP services -->
    <xsl:element name="CcmFifReleaseCustOrderCmd">
      <xsl:element name="CcmFifReleaseCustOrderInCont">
        <xsl:element name="customer_number_ref">
          <xsl:element name="command_id">find_cloned_service</xsl:element>
          <xsl:element name="field_name">customer_number</xsl:element>          
        </xsl:element>
        <xsl:element name="customer_order_ref">
          <xsl:element name="command_id">create_voip_co</xsl:element>
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
          <xsl:element name="command_id">find_service_2</xsl:element>
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
            <xsl:element name="command_id">clone_order_form_2</xsl:element>
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
          <xsl:element name="command_id">create_voip_co</xsl:element>
          <xsl:element name="field_name">customer_order_id</xsl:element>          	
        </xsl:element>
      </xsl:element>
    </xsl:element>    
    
    <xsl:if test="$currentProductCode = $ISDNProductCode">  
      <!-- Terminate the ISDN Contract -->
      &TerminateService_ISDN; 
    </xsl:if>
    
    <xsl:if test="$currentProductCode = $DSLProductCode">       
      <!-- Terminate the NGN DSL Contract -->
      &TerminateService_NGN; 
    </xsl:if>
    
    <xsl:if test="$currentProductCode = $BitStreamDSLProductCode"> 
      <!-- Terminate the NGN Contract -->   
      &TerminateService_BitStream; 
    </xsl:if>
    
    <!-- add the new voice over IP  bundle item if a bundle is found -->
    <xsl:element name="CcmFifModifyBundleItemCmd">
        <xsl:element name="CcmFifModifyBundleItemInCont">
            <xsl:element name="bundle_id_ref">
                <xsl:element name="command_id">modify_bundle_1</xsl:element>
                <xsl:element name="field_name">bundle_id</xsl:element>
            </xsl:element>
            <xsl:element name="supported_object_id_ref">
                <xsl:element name="command_id">clone_order_form_1</xsl:element>
                <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
            </xsl:element>
            <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
            <xsl:element name="action_name">MODIFY</xsl:element>
            <xsl:element name="future_indicator">Y</xsl:element>
        </xsl:element>
    </xsl:element>
    
    <!-- add the new voice over IP bundle item if a bundle is found -->
    <xsl:element name="CcmFifModifyBundleItemCmd">
        <xsl:element name="CcmFifModifyBundleItemInCont">
            <xsl:element name="bundle_id_ref">
                <xsl:element name="command_id">modify_bundle_1</xsl:element>
                <xsl:element name="field_name">bundle_id</xsl:element>
            </xsl:element>
            <xsl:element name="supported_object_id_ref">
                <xsl:element name="command_id">clone_order_form_2</xsl:element>
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
          <xsl:if test="request-param[@name='voiceFunctionID'] != ''">  
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">
                <xsl:value-of select="request-param[@name='voiceFunctionID']"/>
                <xsl:text>_SERVICE_SUBSCRIPTION_ID</xsl:text>
              </xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">clone_order_form_2</xsl:element>
                <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
              </xsl:element>
            </xsl:element>  
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">
                <xsl:value-of select="request-param[@name='voiceFunctionID']"/>
                <xsl:text>_DETAILED_REASON_RD</xsl:text>
              </xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">clone_order_form_2</xsl:element>
                <xsl:element name="field_name">detailed_reason_rd</xsl:element>
              </xsl:element>
            </xsl:element>  
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">
                <xsl:value-of select="request-param[@name='voiceFunctionID']"/>
                <xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
              </xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">create_voip_co</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
            </xsl:element>  
            <!-- customer order id of the reconfiguration of the main access -->
            <xsl:if test="request-param[@name='currentTechnology'] = 'ISDN'">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">
                  <xsl:value-of select="request-param[@name='voiceFunctionID']"/>
                  <xsl:text>_TERM_CUSTOMER_ORDER_ID</xsl:text>
                </xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">create_co_1</xsl:element>
                  <xsl:element name="field_name">customer_order_id</xsl:element>
                </xsl:element>
              </xsl:element>  
            </xsl:if>            
          </xsl:if>
          <xsl:if test="request-param[@name='internetFunctionID'] != ''">  
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">
                <xsl:value-of select="request-param[@name='internetFunctionID']"/>
                <xsl:text>_SERVICE_SUBSCRIPTION_ID</xsl:text>
              </xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">clone_order_form_1</xsl:element>
                <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
              </xsl:element>
            </xsl:element>  
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">
                <xsl:value-of select="request-param[@name='internetFunctionID']"/>
                <xsl:text>_DETAILED_REASON_RD</xsl:text>
              </xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">clone_order_form_1</xsl:element>
                <xsl:element name="field_name">detailed_reason_rd</xsl:element>
              </xsl:element>
            </xsl:element>  
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">
                <xsl:value-of select="request-param[@name='internetFunctionID']"/>
                <xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
              </xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">create_activation_co</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
            </xsl:element>  
            <!-- customer order id of the reconfiguration of the main access -->
            <xsl:if test="request-param[@name='currentTechnology'] != 'ISDN'">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">
                  <xsl:value-of select="request-param[@name='internetFunctionID']"/>
                  <xsl:text>_TERM_CUSTOMER_ORDER_ID</xsl:text>
                </xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">create_co_1</xsl:element>
                  <xsl:element name="field_name">customer_order_id</xsl:element>
                </xsl:element>
              </xsl:element>  
            </xsl:if>
          </xsl:if>          
          <xsl:element name="CcmFifParameterValueCont">
            <xsl:element name="parameter_name">SOURCE_PACKET</xsl:element>
            <xsl:element name="parameter_value_ref">
              <xsl:element name="command_id">clone_order_form_1</xsl:element>
              <xsl:element name="field_name">source_packet</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    
    <xsl:if test="request-param[@name='manualRollback'] = 'N'">
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">accessType</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">ngn</xsl:element>							
            </xsl:element>                
          </xsl:element>
        </xsl:element>
      </xsl:element>      
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">accessService</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_cloned_service</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>							
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>      
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">accessContractNumber</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_cloned_service</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>							
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>   

      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">newInternetService</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_cloned_service</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>							
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>      
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">internetContractNumber</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_cloned_service</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>							
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>   
      
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">newVoiceService</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">clone_order_form_2</xsl:element>
              <xsl:element name="field_name">main_access_service_sub_id</xsl:element>							
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>      
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">voiceContractNumber</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">clone_order_form_2</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>							
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>                 
    </xsl:if>
    
    <xsl:element name="CcmFifConcatStringsCmd">
      <xsl:element name="command_id">voiceActivationPTN</xsl:element>
      <xsl:element name="CcmFifConcatStringsInCont">
        <xsl:element name="input_string_list">
          <xsl:element name="CcmFifCommandRefCont">
            <xsl:element name="command_id">create_voip_co</xsl:element>
            <xsl:element name="field_name">provider_tracking_no</xsl:element>							
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>             
    <xsl:element name="CcmFifConcatStringsCmd">
      <xsl:element name="command_id">internetActivationPTN</xsl:element>
      <xsl:element name="CcmFifConcatStringsInCont">
        <xsl:element name="input_string_list">
          <xsl:element name="CcmFifCommandRefCont">
            <xsl:element name="command_id">create_activation_co</xsl:element>
            <xsl:element name="field_name">provider_tracking_no</xsl:element>							
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>             
    
