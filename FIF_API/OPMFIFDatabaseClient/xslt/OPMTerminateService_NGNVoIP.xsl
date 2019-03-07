  
        
              
   <!-- Ensure that either ACCESS_NUMBER or  SERVICE_TICKET_POSITION_ID are provided -->
   <xsl:if test="(request-param[@name='ACCESS_NUMBER'] = '') and
                   (request-param[@name='SERVICE_TICKET_POSITION_ID'] = '') and
                   (request-param[@name='SERVICE_SUBSCRIPTION_ID'] = '')">
     <xsl:element name="CcmFifRaiseErrorCmd">
       <xsl:element name="command_id">create_find_ss_error</xsl:element>
       <xsl:element name="CcmFifRaiseErrorInCont">
         <xsl:element name="error_text">At least one of the following params must be provided:
               ACCESS_NUMBER or SERVICE_TICKET_POSITION_ID or SERVICE_SUBSCRIPTION_ID.
         </xsl:element>
       </xsl:element>
     </xsl:element>
   </xsl:if>
   <!-- Find Service Subscription by SERVICE_SUBSCRIPTION_ID or ACCESS_NUMBER or
          SERVICE_TICKET_POSITION_ID -->
   <xsl:element name="CcmFifFindServiceSubsCmd">
     <xsl:element name="command_id">find_service_1</xsl:element>
     <xsl:element name="CcmFifFindServiceSubsInCont">
       <xsl:if test="request-param[@name='SERVICE_SUBSCRIPTION_ID'] != ''">
         <xsl:element name="service_subscription_id">
           <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
         </xsl:element>
       </xsl:if>
       <xsl:if test="((request-param[@name='SERVICE_SUBSCRIPTION_ID'] = '' )and
                     ((request-param[@name='SERVICE_TICKET_POSITION_ID'] != '')))">
         <xsl:element name="service_ticket_position_id">
           <xsl:value-of select="request-param[@name='SERVICE_TICKET_POSITION_ID']"/>
         </xsl:element>
       </xsl:if>
       <xsl:if test="((request-param[@name='ACCESS_NUMBER'] != '' )and
               (request-param[@name='SERVICE_SUBSCRIPTION_ID'] = '')and
               (request-param[@name='SERVICE_TICKET_POSITION_ID'] = ''))">
         <xsl:element name="access_number">
           <xsl:value-of select="request-param[@name='ACCESS_NUMBER']"/>
         </xsl:element>
         <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
       </xsl:if>
       <xsl:element name="customer_number">
         <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
       </xsl:element>
       <xsl:element name="contract_number">
         <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
       </xsl:element>
     </xsl:element>
   </xsl:element>
              
   <!-- Ensure that characteristic V0138 on main access service is not equal to OPAL -->
   <xsl:element name="CcmFifValidateCharacteristicValueCmd">
     <xsl:element name="command_id">valid_char_value_1</xsl:element>
     <xsl:element name="CcmFifValidateCharacteristicValueInCont">
       <xsl:element name="service_subscription_ref">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="field_name">service_subscription_id</xsl:element>
       </xsl:element>
       <xsl:element name="service_char_code">V0138</xsl:element>
       <xsl:element name="configured_value">OPAL</xsl:element>
     </xsl:element>
   </xsl:element>

      
      <!-- get contract type -->
      <xsl:element name="CcmFifGetContractTypeCmd">
        <xsl:element name="command_id">get_contract_type_1</xsl:element>
        <xsl:element name="CcmFifGetContractTypeInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>					
        </xsl:element>
      </xsl:element>
      
      <!-- Check if there's only one PC exists -->
      <xsl:element name="CcmFifCheckOnlyOnePCExistsCmd">
        <xsl:element name="command_id">check_pc_count_1</xsl:element>
        <xsl:element name="CcmFifCheckOnlyOnePCExistsInCont">
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">get_contract_type_1</xsl:element>
            <xsl:element name="field_name">contract_type_rd</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">O</xsl:element>                    
        </xsl:element>
      </xsl:element>
    
    <!-- Check if there's only one PS exists -->
    <xsl:element name="CcmFifCheckOnlyOnePSExistsCmd">
      <xsl:element name="command_id">check_ps_count_1</xsl:element>
      <xsl:element name="CcmFifCheckOnlyOnePSExistsInCont">
        <xsl:element name="product_commitment_number_ref">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="field_name">product_commitment_number</xsl:element>
        </xsl:element>
        <xsl:element name="effective_date">
          <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>     
     
     <!-- Terminate Order Form -->
     <xsl:element name="CcmFifTerminateOrderFormCmd">
       <xsl:element name="command_id">terminate_of_1</xsl:element>
       <xsl:element name="CcmFifTerminateOrderFormInCont">
         <xsl:element name="contract_number">
           <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
         </xsl:element>
         <xsl:element name="termination_date">
           <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
         </xsl:element>
         <xsl:element name="notice_per_start_date">
           <xsl:value-of select="request-param[@name='NOTICE_PERIOD_START_DATE']"/>
         </xsl:element>
         <xsl:element name="override_restriction">Y</xsl:element>
         <xsl:element name="termination_reason_rd">
           <xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
         </xsl:element>
         <xsl:element name="process_ind_ref">
           <xsl:element name="command_id">get_contract_type_1</xsl:element>
           <xsl:element name="field_name">contract_type_rd</xsl:element>          	
         </xsl:element>
         <xsl:element name="required_process_ind">O</xsl:element>
         <xsl:element name="multiple_pc_found_ref">
           <xsl:element name="command_id">check_pc_count_1</xsl:element>
           <xsl:element name="field_name">multiple_pc_found</xsl:element>           
         </xsl:element>
         <xsl:element name="multiple_ps_found_ref">
           <xsl:element name="command_id">check_ps_count_1</xsl:element>
           <xsl:element name="field_name">multiple_ps_found</xsl:element>           
         </xsl:element>
       </xsl:element>
     </xsl:element>
     
     <!-- Terminate SDC PC if exists -->
     <xsl:element name="CcmFifTerminateSDCProductCommitmentCmd">
       <xsl:element name="command_id">terminate_sdc_pc_1</xsl:element>
       <xsl:element name="CcmFifTerminateSDCProductCommitmentInCont">
         <xsl:element name="product_commitment_number_ref">
           <xsl:element name="command_id">find_service_1</xsl:element>
           <xsl:element name="field_name">product_commitment_number</xsl:element>
         </xsl:element>
         <xsl:element name="termination_date">
           <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
         </xsl:element>
         <xsl:element name="notice_per_start_date">
           <xsl:value-of select="request-param[@name='NOTICE_PERIOD_START_DATE']"/>
         </xsl:element>
         <xsl:element name="override_restriction">Y</xsl:element>
         <xsl:element name="termination_reason_rd">
           <xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
         </xsl:element>
         <xsl:element name="process_ind_ref">
           <xsl:element name="command_id">get_contract_type_1</xsl:element>
           <xsl:element name="field_name">contract_type_rd</xsl:element>          	
         </xsl:element>
         <xsl:element name="required_process_ind">S</xsl:element>
         <xsl:element name="multiple_ps_found_ref">
           <xsl:element name="command_id">check_ps_count_1</xsl:element>
           <xsl:element name="field_name">multiple_ps_found</xsl:element>           
         </xsl:element>
       </xsl:element>
     </xsl:element>

   <!-- Ensure that the termination has not been performed before -->
   <xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
     <xsl:element name="command_id">find_cancel_stp_2</xsl:element>
     <xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
       <xsl:element name="product_subscription_ref">
         <xsl:element name="command_id">find_service_1</xsl:element>
         <xsl:element name="field_name">product_subscription_id</xsl:element>
       </xsl:element>
       <xsl:element name="reason_rd">TERMINATION</xsl:element>
     </xsl:element>
   </xsl:element>

   <!--Determine if VoIP service is Basis / Premium-->
   <xsl:element name="CcmFifValidateSCValueCmd">
     <xsl:element name="command_id">find_voip_service_code</xsl:element>
     <xsl:element name="CcmFifValidateSCValueInCont">
       <xsl:element name="value_ref">
         <xsl:element name="command_id">find_service_1</xsl:element>
         <xsl:element name="field_name">service_code</xsl:element>  
       </xsl:element>
       <xsl:element name="allowed_values">
         <xsl:element name="CcmFifPassingValueCont">
           <xsl:element name="value">VI002</xsl:element>
         </xsl:element>  
       </xsl:element>
     </xsl:element>
   </xsl:element>

   <!-- Reconfigure service subscription for  NGN VoIP Basis Service-->
   <xsl:element name="CcmFifReconfigServiceCmd">
     <xsl:element name="command_id">reconf_serv_2</xsl:element>
     <xsl:element name="CcmFifReconfigServiceInCont">
       <xsl:element name="service_subscription_ref">
         <xsl:element name="command_id">find_service_1</xsl:element>
         <xsl:element name="field_name">service_subscription_id</xsl:element>
       </xsl:element>
       <xsl:element name="desired_schedule_type">ASAP</xsl:element>
       <xsl:element name="reason_rd">TERMINATION</xsl:element>
       <xsl:element name="service_characteristic_list">
         <!-- Projektauftrag -->
         <xsl:element name="CcmFifConfiguredValueCont">
           <xsl:element name="service_char_code">V0104</xsl:element>
           <xsl:element name="data_type">STRING</xsl:element>
           <xsl:element name="configured_value">nein</xsl:element>
         </xsl:element>
         <!-- DTAG Free Text-->
         <xsl:element name="CcmFifConfiguredValueCont">
           <xsl:element name="service_char_code">V0141</xsl:element>
           <xsl:element name="data_type">STRING</xsl:element>
           <xsl:element name="configured_value"></xsl:element>
         </xsl:element>
         <!-- Automatische Versand -->
         <xsl:element name="CcmFifConfiguredValueCont">
           <xsl:element name="service_char_code">V0131</xsl:element>
           <xsl:element name="data_type">STRING</xsl:element>
           <xsl:element name="configured_value">J</xsl:element>
         </xsl:element>
         <!-- Neuer TNB -->
         <xsl:element name="CcmFifConfiguredValueCont">
           <xsl:element name="service_char_code">V0061</xsl:element>
           <xsl:element name="data_type">STRING</xsl:element>
           <xsl:element name="configured_value">
             <xsl:value-of select="request-param[@name='CARRIER']"/>
           </xsl:element>
         </xsl:element>
         <!-- Grund der Neukonfiguration -->
         <xsl:element name="CcmFifConfiguredValueCont">
           <xsl:element name="service_char_code">VI008</xsl:element>
           <xsl:element name="data_type">STRING</xsl:element>
           <xsl:element name="configured_value">Vorbereitung zur Kuendigung</xsl:element>
         </xsl:element> 
         <!-- Bearbeitungsart -->
         <xsl:element name="CcmFifConfiguredValueCont">
           <xsl:element name="service_char_code">VI002</xsl:element>
           <xsl:element name="data_type">STRING</xsl:element>
           <xsl:element name="configured_value">OP</xsl:element>
         </xsl:element>
         <!-- Order Variant -->
         <xsl:element name="CcmFifConfiguredValueCont">
           <xsl:element name="service_char_code">V0810</xsl:element>
           <xsl:element name="data_type">STRING</xsl:element>
           <xsl:element name="configured_value">Echte Kündigung</xsl:element>
         </xsl:element> 
         <!-- Aktivierungsdatum -->
         <xsl:element name="CcmFifConfiguredValueCont">
           <xsl:element name="service_char_code">V0909</xsl:element>
           <xsl:element name="data_type">STRING</xsl:element>
           <xsl:element name="configured_value">
             <xsl:value-of select="$terminationDateOPM"/>
           </xsl:element>
         </xsl:element>
         <!-- Backporting of VoIP Access Number 1 -->
         <xsl:if test="request-param[@name='PORT_ACCESS_NUMBER_1'] != ''">
           <xsl:element name="CcmFifConfiguredValueCont">
             <xsl:element name="service_char_code">V0165</xsl:element>
             <xsl:element name="data_type">STRING</xsl:element>
             <xsl:element name="configured_value">
               <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_1']"/>
             </xsl:element>
           </xsl:element>
         </xsl:if>
       </xsl:element>
       <xsl:element name="process_ind_ref">
         <xsl:element name="command_id">find_voip_service_code</xsl:element>
         <xsl:element name="field_name">service_code_valid</xsl:element>
       </xsl:element>
       <xsl:element name="required_process_ind">Y</xsl:element>
     </xsl:element>
   </xsl:element>

   <!-- Reconfigure service subscription for  NGN VoIP  Premium Service-->
   <xsl:element name="CcmFifReconfigServiceCmd">
     <xsl:element name="command_id">reconf_serv_2</xsl:element>
     <xsl:element name="CcmFifReconfigServiceInCont">
       <xsl:element name="service_subscription_ref">
         <xsl:element name="command_id">find_service_1</xsl:element>
         <xsl:element name="field_name">service_subscription_id</xsl:element>
       </xsl:element>
       <xsl:element name="desired_schedule_type">ASAP</xsl:element>
       <xsl:element name="reason_rd">TERMINATION</xsl:element>
       <xsl:element name="service_characteristic_list">
         <!-- Projektauftrag -->
         <xsl:element name="CcmFifConfiguredValueCont">
           <xsl:element name="service_char_code">V0104</xsl:element>
           <xsl:element name="data_type">STRING</xsl:element>
           <xsl:element name="configured_value">nein</xsl:element>
         </xsl:element>
         <!-- DTAG Free Text-->
         <xsl:element name="CcmFifConfiguredValueCont">
           <xsl:element name="service_char_code">V0141</xsl:element>
           <xsl:element name="data_type">STRING</xsl:element>
           <xsl:element name="configured_value"></xsl:element>
         </xsl:element>
         <!-- Automatische Versand -->
         <xsl:element name="CcmFifConfiguredValueCont">
           <xsl:element name="service_char_code">V0131</xsl:element>
           <xsl:element name="data_type">STRING</xsl:element>
           <xsl:element name="configured_value">J</xsl:element>
         </xsl:element>
         <!-- Neuer TNB -->
         <xsl:element name="CcmFifConfiguredValueCont">
           <xsl:element name="service_char_code">V0061</xsl:element>
           <xsl:element name="data_type">STRING</xsl:element>
           <xsl:element name="configured_value">
             <xsl:value-of select="request-param[@name='CARRIER']"/>
           </xsl:element>
         </xsl:element>
         <!-- Grund der Neukonfiguration -->
         <xsl:element name="CcmFifConfiguredValueCont">
           <xsl:element name="service_char_code">VI008</xsl:element>
           <xsl:element name="data_type">STRING</xsl:element>
           <xsl:element name="configured_value">Vorbereitung zur Kuendigung</xsl:element>
         </xsl:element>
         <!-- Bearbeitungsart -->
         <xsl:element name="CcmFifConfiguredValueCont">
           <xsl:element name="service_char_code">VI002</xsl:element>
           <xsl:element name="data_type">STRING</xsl:element>
           <xsl:element name="configured_value">OP</xsl:element>
         </xsl:element>
         <!-- Order Variant -->
         <xsl:element name="CcmFifConfiguredValueCont">
           <xsl:element name="service_char_code">V0810</xsl:element>
           <xsl:element name="data_type">STRING</xsl:element>
           <xsl:element name="configured_value">Echte Kündigung</xsl:element>
         </xsl:element>
         <!-- Aktivierungsdatum -->
         <xsl:element name="CcmFifConfiguredValueCont">
           <xsl:element name="service_char_code">V0909</xsl:element>
           <xsl:element name="data_type">STRING</xsl:element>
           <xsl:element name="configured_value">
             <xsl:value-of select="$terminationDateOPM"/>
           </xsl:element>
         </xsl:element>
         <!-- Backporting of VoIP Access Number 1 -->
         <xsl:if test="request-param[@name='PORT_ACCESS_NUMBER_1'] != ''">
           <xsl:element name="CcmFifConfiguredValueCont">
             <xsl:element name="service_char_code">V0165</xsl:element>
             <xsl:element name="data_type">STRING</xsl:element>
             <xsl:element name="configured_value">
               <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_1']"/>
             </xsl:element>
           </xsl:element>
         </xsl:if>
         <!-- Backporting of VoIP Access Number 2 -->
         <xsl:if test="request-param[@name='PORT_ACCESS_NUMBER_2'] != ''">
           <xsl:element name="CcmFifConfiguredValueCont">
             <xsl:element name="service_char_code">V0166</xsl:element>
             <xsl:element name="data_type">STRING</xsl:element>
             <xsl:element name="configured_value">
               <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_2']"/>
             </xsl:element>
           </xsl:element>
         </xsl:if>
         <!-- Backporting of VoIP Access Number 3 -->
         <xsl:if test="request-param[@name='PORT_ACCESS_NUMBER_3'] != ''">
           <xsl:element name="CcmFifConfiguredValueCont">
             <xsl:element name="service_char_code">V0167</xsl:element>
             <xsl:element name="data_type">STRING</xsl:element>
             <xsl:element name="configured_value">
               <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_3']"/>
             </xsl:element>
           </xsl:element>
         </xsl:if>
         <!-- Backporting of VoIP Access Number 4 -->
         <xsl:if test="request-param[@name='PORT_ACCESS_NUMBER_4'] != ''">
           <xsl:element name="CcmFifConfiguredValueCont">
             <xsl:element name="service_char_code">V0168</xsl:element>
             <xsl:element name="data_type">STRING</xsl:element>
             <xsl:element name="configured_value">
               <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_4']"/>
             </xsl:element>
           </xsl:element>
         </xsl:if>
         <!-- Backporting of VoIP Access Number 5 -->
         <xsl:if test="request-param[@name='PORT_ACCESS_NUMBER_5'] != ''">
           <xsl:element name="CcmFifConfiguredValueCont">
             <xsl:element name="service_char_code">V0169</xsl:element>
             <xsl:element name="data_type">STRING</xsl:element>
             <xsl:element name="configured_value">
               <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_5']"/>
             </xsl:element>
           </xsl:element>
         </xsl:if>
         <!-- Backporting of VoIP Access Number 6 -->
         <xsl:if test="request-param[@name='PORT_ACCESS_NUMBER_6'] != ''">
           <xsl:element name="CcmFifConfiguredValueCont">
             <xsl:element name="service_char_code">V0170</xsl:element>
             <xsl:element name="data_type">STRING</xsl:element>
             <xsl:element name="configured_value">
               <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_6']"/>
             </xsl:element>
           </xsl:element>
         </xsl:if>
         <!-- Backporting of VoIP Access Number 7 -->
         <xsl:if test="request-param[@name='PORT_ACCESS_NUMBER_7'] != ''">
           <xsl:element name="CcmFifConfiguredValueCont">
             <xsl:element name="service_char_code">V0171</xsl:element>
             <xsl:element name="data_type">STRING</xsl:element>
             <xsl:element name="configured_value">
               <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_7']"/>
             </xsl:element>
           </xsl:element>
         </xsl:if>
         <!-- Backporting of VoIP Access Number 8 -->
         <xsl:if test="request-param[@name='PORT_ACCESS_NUMBER_8'] != ''">
           <xsl:element name="CcmFifConfiguredValueCont">
             <xsl:element name="service_char_code">V0172</xsl:element>
             <xsl:element name="data_type">STRING</xsl:element>
             <xsl:element name="configured_value">
               <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_9']"/>
             </xsl:element>
           </xsl:element>
         </xsl:if>
         <!-- Backporting of VoIP Access Number 9 -->
         <xsl:if test="request-param[@name='PORT_ACCESS_NUMBER_9'] != ''">
           <xsl:element name="CcmFifConfiguredValueCont">
             <xsl:element name="service_char_code">V0173</xsl:element>
             <xsl:element name="data_type">STRING</xsl:element>
             <xsl:element name="configured_value">
               <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_9']"/>
             </xsl:element>
           </xsl:element>
         </xsl:if>
         <!-- Backporting of VoIP Access Number 10 -->
         <xsl:if test="request-param[@name='PORT_ACCESS_NUMBER_10'] != ''">
           <xsl:element name="CcmFifConfiguredValueCont">
             <xsl:element name="service_char_code">V0174</xsl:element>
             <xsl:element name="data_type">STRING</xsl:element>
             <xsl:element name="configured_value">
               <xsl:value-of select="request-param[@name='PORT_ACCESS_NUMBER_10']"/>
             </xsl:element>
           </xsl:element>
         </xsl:if>
       </xsl:element>
       <xsl:element name="process_ind_ref">
         <xsl:element name="command_id">find_voip_service_code</xsl:element>
         <xsl:element name="field_name">service_code_valid</xsl:element>
       </xsl:element>
       <xsl:element name="required_process_ind">N</xsl:element>
     </xsl:element>
   </xsl:element>

   <!-- Add Termination Fee Service -->
   <xsl:if test="request-param[@name='TERMINATION_FEE_SERVICE_CODE'] != ''">
     <xsl:element name="CcmFifAddServiceSubsCmd">
       <xsl:element name="command_id">add_service_2</xsl:element>
       <xsl:element name="CcmFifAddServiceSubsInCont">
         <xsl:element name="product_subscription_ref">
           <xsl:element name="command_id">find_service_1</xsl:element>
           <xsl:element name="field_name">product_subscription_id</xsl:element>
         </xsl:element>
         <xsl:element name="service_code">
           <xsl:value-of select="request-param[@name='TERMINATION_FEE_SERVICE_CODE']"/>
         </xsl:element>
         <xsl:element name="parent_service_subs_ref">
           <xsl:element name="command_id">find_service_1</xsl:element>
           <xsl:element name="field_name">service_subscription_id</xsl:element>
         </xsl:element>
         <xsl:element name="desired_schedule_type">ASAP</xsl:element>
         <xsl:element name="reason_rd">TERMINATION</xsl:element>
         <xsl:element name="service_characteristic_list">
         </xsl:element>
       </xsl:element>
     </xsl:element>
   </xsl:if>
   <!-- Terminate Product Subscription for NGN VOIP -->
   <xsl:element name="CcmFifTerminateProductSubsCmd">
     <xsl:element name="command_id">terminate_ps_2</xsl:element>
     <xsl:element name="CcmFifTerminateProductSubsInCont">
       <xsl:element name="product_subscription_ref">
         <xsl:element name="command_id">find_service_1</xsl:element>
         <xsl:element name="field_name">product_subscription_id</xsl:element>
       </xsl:element>
       <xsl:element name="desired_date">
         <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
       </xsl:element>
       <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
       <xsl:element name="reason_rd">TERMINATION</xsl:element>
       <xsl:element name="auto_customer_order">N</xsl:element>
     </xsl:element>
   </xsl:element>
   
   <!-- Create Customer Order for Reconfiguration of NGN VoIP-->
   <xsl:element name="CcmFifCreateCustOrderCmd">
     <xsl:element name="command_id">create_co_ngn_voip_1</xsl:element>
     <xsl:element name="CcmFifCreateCustOrderInCont">
       <xsl:element name="customer_number">
         <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
       </xsl:element>
       <xsl:element name="customer_tracking_id">
         <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
       </xsl:element>
       <xsl:element name="provider_tracking_no">001v</xsl:element>
       <xsl:element name="service_ticket_pos_list">
         <xsl:element name="CcmFifCommandRefCont">
           <xsl:element name="command_id">reconf_serv_2</xsl:element>
           <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
         </xsl:element>
       </xsl:element>
     </xsl:element>
   </xsl:element>
     
   <!-- Create Customer Order for Add Service for NGN VOIP-->
   <xsl:if test="request-param[@name='TERMINATION_FEE_SERVICE_CODE'] != ''">
     <xsl:element name="CcmFifCreateCustOrderCmd">
       <xsl:element name="command_id">create_co_ngn_voip_3</xsl:element>
       <xsl:element name="CcmFifCreateCustOrderInCont">
         <xsl:element name="customer_number">
           <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
         </xsl:element>
         <xsl:element name="parent_customer_order_ref">
           <xsl:element name="command_id">create_co_ngn_voip_1</xsl:element>
           <xsl:element name="field_name">customer_order_id</xsl:element>
         </xsl:element>
         <xsl:element name="customer_tracking_id">
           <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
         </xsl:element>
         <xsl:element name="service_ticket_pos_list">
           <xsl:element name="CcmFifCommandRefCont">
             <xsl:element name="command_id">add_service_2</xsl:element>
             <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
           </xsl:element>
         </xsl:element>
       </xsl:element>
     </xsl:element>
   </xsl:if>

   <!-- Create Customer Order for Termination -->
   <xsl:element name="CcmFifCreateCustOrderCmd">
     <xsl:element name="command_id">create_co_ngn_voip_2</xsl:element>
     <xsl:element name="CcmFifCreateCustOrderInCont">
       <xsl:element name="customer_number">
         <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
       </xsl:element>
       <xsl:element name="parent_customer_order_ref">
         <xsl:element name="command_id">create_co_ngn_voip_1</xsl:element>
         <xsl:element name="field_name">customer_order_id</xsl:element>
       </xsl:element>
       <xsl:element name="customer_tracking_id">
         <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
       </xsl:element>
       <xsl:element name="provider_tracking_no">002v</xsl:element>
       <xsl:element name="service_ticket_pos_list">
         <xsl:element name="CcmFifCommandRefCont">
           <xsl:element name="command_id">terminate_ps_2</xsl:element>
           <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
         </xsl:element>
       </xsl:element>
     </xsl:element>
   </xsl:element>
               
   <!-- Release Customer Order for Reconfiguration -->
   <xsl:element name="CcmFifReleaseCustOrderCmd">
     <xsl:element name="CcmFifReleaseCustOrderInCont">
       <xsl:element name="customer_number">
         <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
       </xsl:element>
       <xsl:element name="customer_order_ref">
         <xsl:element name="command_id">create_co_ngn_voip_1</xsl:element>
         <xsl:element name="field_name">customer_order_id</xsl:element>
       </xsl:element>
     </xsl:element>
   </xsl:element>
   
   <!-- Release Customer Order for Add Service -->
   <xsl:if test="request-param[@name='TERMINATION_FEE_SERVICE_CODE'] != ''">
     <xsl:element name="CcmFifReleaseCustOrderCmd">
       <xsl:element name="CcmFifReleaseCustOrderInCont">
         <xsl:element name="customer_number">
           <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
         </xsl:element>
         <xsl:element name="customer_order_ref">
           <xsl:element name="command_id">create_co_ngn_voip_3</xsl:element>
           <xsl:element name="field_name">customer_order_id</xsl:element>
         </xsl:element>
       </xsl:element>
     </xsl:element>
   </xsl:if>
   
   <!-- Release Customer Order for Termination for  NGN VoIP -->
   <xsl:element name="CcmFifReleaseCustOrderCmd">
     <xsl:element name="CcmFifReleaseCustOrderInCont">
       <xsl:element name="customer_number">
         <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
       </xsl:element>
       <xsl:element name="customer_order_ref">
         <xsl:element name="command_id">create_co_ngn_voip_2</xsl:element>
         <xsl:element name="field_name">customer_order_id</xsl:element>
       </xsl:element>
     </xsl:element>
    </xsl:element>

   <!-- Create Contact for the Service Termination -->
   <xsl:element name="CcmFifCreateContactCmd">
     <xsl:element name="CcmFifCreateContactInCont">
       <xsl:element name="customer_number">
         <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
       </xsl:element>
       <xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
       <!--added -->
       <xsl:element name="short_description">Automatische Kündigung</xsl:element>
       <xsl:element name="long_description_text">
         <xsl:text>TransactionID: </xsl:text>
         <xsl:value-of select="request-param[@name='transactionID']"/>
         <xsl:text>&#xA;UserName: </xsl:text>
         <xsl:value-of select="request-param[@name='USER_NAME']"/>
         <xsl:text>&#xA;ContractNumber: </xsl:text>
         <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
         <xsl:text>&#xA;TerminationReason: </xsl:text>
         <xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
         <xsl:text>&#xA;DeactivateOnlineAccount: Y</xsl:text>
         <xsl:text>&#xA;SendConfirmationLetter: </xsl:text>
         <xsl:if test="(request-param[@name='TERMINATION_REASON'] = 'ZTCOM') or (request-param[@name='TERMINATION_REASON'] = 'UMZN')">N</xsl:if> 
         <xsl:if test="(request-param[@name='TERMINATION_REASON'] != 'ZTCOM') and (request-param[@name='TERMINATION_REASON'] != 'UMZN')">
           <xsl:value-of select="request-param[@name='SEND_CONFIRMATION_LETTER']"/>
         </xsl:if>
         <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
         <xsl:value-of select="request-param[@name='ROLLEN_BEZEICHNUNG']"/>
       </xsl:element>
     </xsl:element>
   </xsl:element>
