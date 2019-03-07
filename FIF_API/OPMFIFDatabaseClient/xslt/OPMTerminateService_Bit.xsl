<xsl:variable name="orderVariant">
  <xsl:choose>
    <xsl:when test="request-param[@name='OMTS_ORDER_ID_ACTIVATION'] != ''
      and $ReasonRd = 'PROVIDER_CHANGE'">Providerwechsel</xsl:when>
    <xsl:otherwise>Echte Kündigung</xsl:otherwise>
  </xsl:choose>
</xsl:variable> 

<!-- Generate Barcode for provider_change-->
<xsl:if test="$OMTSOrderId = '' and $ReasonRd='PROVIDER_CHANGE'">                  
  <xsl:element name="CcmFifGenerateCustomerOrderBarcodeCmd">
    <xsl:element name="command_id">generate_barcode_1</xsl:element>
  </xsl:element> 
</xsl:if>

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

   <!-- Reconfigure service subscription for  BitVoIP  Premium Service-->
   <xsl:element name="CcmFifReconfigServiceCmd">
     <xsl:element name="command_id">reconf_serv_2</xsl:element>
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
             <xsl:choose>
               <xsl:when test="request-param[@name='CARRIER'] = 'Arcor'">D009</xsl:when>
               <xsl:otherwise>
                 <xsl:value-of select="request-param[@name='CARRIER']"/>
               </xsl:otherwise>
             </xsl:choose>                    	                    	
           </xsl:element>
         </xsl:element>
         <!-- Kündigungsgrund -->
         <xsl:element name="CcmFifConfiguredValueCont">
           <xsl:element name="service_char_code">V0137</xsl:element>
           <xsl:element name="data_type">STRING</xsl:element>
           <xsl:element name="configured_value">
             <xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
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
           <xsl:element name="configured_value">
             <xsl:value-of select="$orderVariant"/>
           </xsl:element>
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
         <xsl:element name="reason_rd">
           <xsl:value-of select="$ReasonRd"/>
         </xsl:element>
         <xsl:element name="service_characteristic_list">
         </xsl:element>
       </xsl:element>
     </xsl:element>
   </xsl:if>
   <!-- Terminate Product Subscription for Bit VoIP -->
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
       <xsl:element name="reason_rd">
         <xsl:value-of select="$ReasonRd"/>
       </xsl:element>
       <xsl:element name="auto_customer_order">N</xsl:element>
     </xsl:element>
   </xsl:element>
   
   <!-- Create Customer Order for Reconfiguration of Bit VoIP-->
   <xsl:element name="CcmFifCreateCustOrderCmd">
     <xsl:element name="command_id">create_co_bit_voip_1</xsl:element>
     <xsl:element name="CcmFifCreateCustOrderInCont">
       <xsl:element name="customer_number">
         <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
       </xsl:element>
       <xsl:if test="$OMTSOrderId != ''">
         <xsl:element name="customer_tracking_id">
           <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
         </xsl:element>
       </xsl:if> 	
       <xsl:if test="$OMTSOrderId = '' and $ReasonRd='PROVIDER_CHANGE'">        
         <xsl:element name="customer_tracking_id_ref">
           <xsl:element name="command_id">generate_barcode_1</xsl:element>
           <xsl:element name="field_name">customer_tracking_id</xsl:element>
         </xsl:element>      
       </xsl:if> 	
       <xsl:element name="provider_tracking_no">001v</xsl:element>
       <xsl:element name="service_ticket_pos_list">
         <xsl:element name="CcmFifCommandRefCont">
           <xsl:element name="command_id">reconf_serv_2</xsl:element>
           <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
         </xsl:element>
       </xsl:element>
     </xsl:element>
   </xsl:element>
     
   <!-- Create Customer Order for Add Service for NBit VoIP-->
   <xsl:if test="request-param[@name='TERMINATION_FEE_SERVICE_CODE'] != ''">
     <xsl:element name="CcmFifCreateCustOrderCmd">
       <xsl:element name="command_id">create_co_bit_voip_3</xsl:element>
       <xsl:element name="CcmFifCreateCustOrderInCont">
         <xsl:element name="customer_number">
           <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
         </xsl:element>
         <xsl:element name="parent_customer_order_ref">
           <xsl:element name="command_id">create_co_bit_voip_1</xsl:element>
           <xsl:element name="field_name">customer_order_id</xsl:element>
         </xsl:element>
         <xsl:if test="$OMTSOrderId != ''">
           <xsl:element name="customer_tracking_id">
             <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
           </xsl:element>
         </xsl:if> 	
         <xsl:if test="$OMTSOrderId = '' and $ReasonRd='PROVIDER_CHANGE'">        
           <xsl:element name="customer_tracking_id_ref">
             <xsl:element name="command_id">generate_barcode_1</xsl:element>
             <xsl:element name="field_name">customer_tracking_id</xsl:element>
           </xsl:element>      
         </xsl:if> 	
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
     <xsl:element name="command_id">create_co_bit_voip_2</xsl:element>
     <xsl:element name="CcmFifCreateCustOrderInCont">
       <xsl:element name="customer_number">
         <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
       </xsl:element>
       <xsl:element name="parent_customer_order_ref">
         <xsl:element name="command_id">create_co_bit_voip_1</xsl:element>
         <xsl:element name="field_name">customer_order_id</xsl:element>
       </xsl:element>
       <xsl:if test="$OMTSOrderId != ''">
         <xsl:element name="customer_tracking_id">
           <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
         </xsl:element>
       </xsl:if> 	
       <xsl:if test="$OMTSOrderId = '' and $ReasonRd='PROVIDER_CHANGE'">        
         <xsl:element name="customer_tracking_id_ref">
           <xsl:element name="command_id">generate_barcode_1</xsl:element>
           <xsl:element name="field_name">customer_tracking_id</xsl:element>
         </xsl:element>      
       </xsl:if> 	
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
         <xsl:element name="command_id">create_co_bit_voip_1</xsl:element>
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
           <xsl:element name="command_id">create_co_bit_voip_3</xsl:element>
           <xsl:element name="field_name">customer_order_id</xsl:element>
         </xsl:element>
       </xsl:element>
     </xsl:element>
   </xsl:if>
   
   <!-- Release Customer Order for Termination for  Bit VoIP -->
   <xsl:element name="CcmFifReleaseCustOrderCmd">
     <xsl:element name="CcmFifReleaseCustOrderInCont">
       <xsl:element name="customer_number">
         <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
       </xsl:element>
       <xsl:element name="customer_order_ref">
         <xsl:element name="command_id">create_co_bit_voip_2</xsl:element>
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
         <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
         <xsl:value-of select="request-param[@name='ROLLEN_BEZEICHNUNG']"/>
       </xsl:element>
     </xsl:element>
   </xsl:element>



  <!-- TERMINATE THE Bit DSL SERVICE-->
  <!-- Find bundle for the Bit VOIP service attached to the Bit-DSL service -->
  <xsl:element name="CcmFifFindBundleCmd"> 
    <xsl:element name="command_id">find_bundle_1</xsl:element> 
    <xsl:element name="CcmFifFindBundleInCont">
      <xsl:element name="bundle_item_type_rd">BITVOIP</xsl:element> 
      <xsl:element name="supported_object_id_ref"> 
        <xsl:element name="command_id">find_service_1</xsl:element> 
        <xsl:element name="field_name">service_subscription_id</xsl:element> 
      </xsl:element>     
    </xsl:element>         
  </xsl:element> 

  <!-- Find  the Bit DSL service -->	
  <xsl:element name="CcmFifFindBundleCmd">
    <xsl:element name="command_id">find_bundle_2</xsl:element>
    <xsl:element name="CcmFifFindBundleInCont">
      <xsl:element name="bundle_id_ref">
        <xsl:element name="command_id">find_bundle_1</xsl:element>
        <xsl:element name="field_name">bundle_id</xsl:element>
      </xsl:element>
      <xsl:element name="bundle_item_type_rd">BITACCESS</xsl:element>
      <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
    </xsl:element>	
  </xsl:element>	
  <!--Find service subscription for Bit VOIP to get contract number-->
  <xsl:element name="CcmFifFindServiceSubsCmd">
   <xsl:element name="command_id">find_service_dsl_1</xsl:element>
    <xsl:element name="CcmFifFindServiceSubsInCont">
      <xsl:element name="service_subscription_id_ref">
       <xsl:element name="command_id">find_bundle_2</xsl:element>
        <xsl:element name="field_name">supported_object_id</xsl:element>	
      </xsl:element>	
      <xsl:element name="customer_number">
        <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
      </xsl:element>
    </xsl:element>	
  </xsl:element>	

    <!-- Ensure that characteristic V0138 on main access service is not equal to OPAL -->
    <xsl:element name="CcmFifValidateCharacteristicValueCmd">
      <xsl:element name="command_id">valid_char_value_dls_1</xsl:element>
      <xsl:element name="CcmFifValidateCharacteristicValueInCont">
        <xsl:element name="service_subscription_ref">
          <xsl:element name="command_id">find_service_dsl_1</xsl:element>
          <xsl:element name="field_name">service_subscription_id</xsl:element>
        </xsl:element>
        <xsl:element name="service_char_code">V0138</xsl:element>
        <xsl:element name="configured_value">OPAL</xsl:element>
      </xsl:element>
    </xsl:element>


    <!-- Ensure that the termination has not been performed before -->
    <xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
      <xsl:element name="command_id">find_cancel_stp_dsl_1</xsl:element>
      <xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
        <xsl:element name="product_subscription_ref">
          <xsl:element name="command_id">find_service_dsl_1</xsl:element>
          <xsl:element name="field_name">product_subscription_id</xsl:element>
        </xsl:element>
        <xsl:element name="reason_rd">TERMINATION</xsl:element>
      </xsl:element>
    </xsl:element>
    
    <!-- Check if there's only one PC exists -->
    <xsl:element name="CcmFifCheckOnlyOnePCExistsCmd">
      <xsl:element name="command_id">check_pc_count_dsl_1</xsl:element>
      <xsl:element name="CcmFifCheckOnlyOnePCExistsInCont">
        <xsl:element name="contract_number_ref">
          <xsl:element name="command_id">find_service_dsl_1</xsl:element>
          <xsl:element name="field_name">contract_number</xsl:element>
        </xsl:element>
        <xsl:element name="effective_date">
          <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    
    <!-- Check if there's only one PS exists -->
    <xsl:element name="CcmFifCheckOnlyOnePSExistsCmd">
      <xsl:element name="command_id">check_ps_count_dsl_1</xsl:element>
      <xsl:element name="CcmFifCheckOnlyOnePSExistsInCont">
        <xsl:element name="product_commitment_number_ref">
          <xsl:element name="command_id">find_service_dsl_1</xsl:element>
          <xsl:element name="field_name">product_commitment_number</xsl:element>
        </xsl:element>
        <xsl:element name="effective_date">
          <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    
    <!-- Terminate Order Form -->
    <xsl:element name="CcmFifTerminateOrderFormCmd">
      <xsl:element name="command_id">terminate_of_dsl_1</xsl:element>
      <xsl:element name="CcmFifTerminateOrderFormInCont">
        <xsl:element name="contract_number_ref">
          <xsl:element name="command_id">find_service_dsl_1</xsl:element>
          <xsl:element name="field_name">contract_number</xsl:element>	
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
        <xsl:element name="multiple_pc_found_ref">
          <xsl:element name="command_id">check_pc_count_dsl_1</xsl:element>
          <xsl:element name="field_name">multiple_pc_found</xsl:element>           
        </xsl:element>
        <xsl:element name="multiple_ps_found_ref">
          <xsl:element name="command_id">check_ps_count_dsl_1</xsl:element>
          <xsl:element name="field_name">multiple_ps_found</xsl:element>           
        </xsl:element>	                    
      </xsl:element>
    </xsl:element>
    
    <!-- Reconfigure Service Subscription -->
    <xsl:element name="CcmFifReconfigServiceCmd">
      <xsl:element name="command_id">reconf_serv_dsl_1</xsl:element>
      <xsl:element name="CcmFifReconfigServiceInCont">
        <xsl:element name="service_subscription_ref">
          <xsl:element name="command_id">find_service_dsl_1</xsl:element>
          <xsl:element name="field_name">service_subscription_id</xsl:element>
        </xsl:element>
        <xsl:element name="desired_schedule_type">ASAP</xsl:element>
        <xsl:element name="reason_rd">
          <xsl:value-of select="$ReasonRd"/>
        </xsl:element>
        <xsl:element name="service_characteristic_list">
          <!-- Projektauftrag -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0104</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">nein</xsl:element>                   			
          </xsl:element>
          <!-- Automatische Versand -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0131</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">J</xsl:element>
          </xsl:element>
          <!-- Grund der Neukonfiguration -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0943</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">Vorbereitung zur Kuendigung</xsl:element>
          </xsl:element>
          <!-- Bearbeitungsart -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0971</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">TAL</xsl:element> 
            <!--<xsl:element name="configured_value">OP</xsl:element>-->
          </xsl:element>
          <!-- Aktivierungsdatum -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0909</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">
              <xsl:value-of select="$terminationDateOPM"/>
            </xsl:element>
          </xsl:element>
          <!-- Kündigungsgrund -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0137</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">
              <xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
            </xsl:element>
          </xsl:element>
          <!-- Sonderzeitfenster -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0139</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">NZF</xsl:element>
          </xsl:element>
          <!-- Fixer Bestelltermin -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0140</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">Nein</xsl:element>
          </xsl:element>  
          <!-- Order Variant -->
          <xsl:element name="CcmFifConfiguredValueCont"> 
            <xsl:element name="service_char_code">V0810</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">
              <xsl:value-of select="$orderVariant"/>
            </xsl:element>
          </xsl:element> 				
        </xsl:element>
      </xsl:element>
    </xsl:element>
    
    <!-- Terminate Product Subscription -->
    <xsl:element name="CcmFifTerminateProductSubsCmd">
      <xsl:element name="command_id">terminate_ps_dsl_1</xsl:element>
      <xsl:element name="CcmFifTerminateProductSubsInCont">
        <xsl:element name="product_subscription_ref">
          <xsl:element name="command_id">find_service_dsl_1</xsl:element>
          <xsl:element name="field_name">product_subscription_id</xsl:element>
        </xsl:element>
        <xsl:element name="desired_date">
          <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
        </xsl:element>
        <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
        <xsl:element name="reason_rd">
          <xsl:value-of select="$ReasonRd"/>
        </xsl:element>
        <xsl:element name="auto_customer_order">N</xsl:element>
      </xsl:element>
    </xsl:element>
    
    <!-- Create Customer Order for Reconfiguration -->
    <xsl:element name="CcmFifCreateCustOrderCmd">
      <xsl:element name="command_id">create_co_reconf_dsl_1</xsl:element>
      <xsl:element name="CcmFifCreateCustOrderInCont">
        <xsl:element name="customer_number">
          <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
        </xsl:element>
        <xsl:if test="$OMTSOrderId != ''">
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
          </xsl:element>
        </xsl:if> 	
        <xsl:if test="$OMTSOrderId = '' and $ReasonRd='PROVIDER_CHANGE'">        
          <xsl:element name="customer_tracking_id_ref">
            <xsl:element name="command_id">generate_barcode_1</xsl:element>
            <xsl:element name="field_name">customer_tracking_id</xsl:element>
          </xsl:element>      
        </xsl:if> 	
        <xsl:element name="provider_tracking_no">001</xsl:element>
        <xsl:element name="service_ticket_pos_list">
          <xsl:element name="CcmFifCommandRefCont">
            <xsl:element name="command_id">reconf_serv_dsl_1</xsl:element>
            <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    
    <!-- Create Customer Order for Termination -->
    <xsl:element name="CcmFifCreateCustOrderCmd">
      <xsl:element name="command_id">create_co_term_dsl_1</xsl:element>
      <xsl:element name="CcmFifCreateCustOrderInCont">
        <xsl:element name="customer_number">
          <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
        </xsl:element>
        <xsl:element name="parent_customer_order_ref">
          <xsl:element name="command_id">create_co_reconf_dsl_1</xsl:element>
          <xsl:element name="field_name">customer_order_id</xsl:element>
        </xsl:element>
        <xsl:if test="$OMTSOrderId != ''">
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
          </xsl:element>
        </xsl:if> 	
        <xsl:if test="$OMTSOrderId = '' and $ReasonRd='PROVIDER_CHANGE'">        
          <xsl:element name="customer_tracking_id_ref">
            <xsl:element name="command_id">generate_barcode_1</xsl:element>
            <xsl:element name="field_name">customer_tracking_id</xsl:element>
          </xsl:element>      
        </xsl:if> 	
        <xsl:element name="provider_tracking_no">002</xsl:element>
        <xsl:element name="service_ticket_pos_list">
          <xsl:element name="CcmFifCommandRefCont">
            <xsl:element name="command_id">terminate_ps_dsl_1</xsl:element>
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
          <xsl:element name="command_id">create_co_reconf_dsl_1</xsl:element>
          <xsl:element name="field_name">customer_order_id</xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    
    <!-- Release Customer Order for Termination -->
    <xsl:element name="CcmFifReleaseCustOrderCmd">
      <xsl:element name="CcmFifReleaseCustOrderInCont">
        <xsl:element name="customer_number">
          <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
        </xsl:element>
        <xsl:element name="customer_order_ref">
          <xsl:element name="command_id">create_co_term_dsl_1</xsl:element>
          <xsl:element name="field_name">customer_order_id</xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    
    <!-- Create Contact for the Service Termination -->
    <xsl:element name="CcmFifCreateContactCmd">
      <xsl:element name="CcmFifCreateContactInCont">
        <xsl:if test="$CustomerNumber != ''">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="$CustomerNumber = ''">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_dsl_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
        </xsl:if> 
        <xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
        <xsl:element name="short_description">Automatische Kündigung</xsl:element>
        <xsl:element name="description_text_list">
          <xsl:element name="CcmFifPassingValueCont">
            <xsl:element name="contact_text">
              <xsl:text>TransactionID: </xsl:text>
              <xsl:value-of select="request-param[@name='transactionID']"/>
              <xsl:text>&#xA;ContractNumber: </xsl:text>
            </xsl:element>
          </xsl:element>
          <xsl:element name="CcmFifCommandRefCont">
            <xsl:element name="command_id">find_service_dsl_1</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <xsl:element name="CcmFifPassingValueCont">
            <xsl:element name="contact_text">
              <xsl:text>&#xA;UserName: </xsl:text>
              <xsl:value-of select="request-param[@name='USER_NAME']"/>
              <xsl:text>&#xA;TerminationReason: </xsl:text>
              <xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
              <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
              <xsl:value-of select="request-param[@name='ROLLEN_BEZEICHNUNG']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        <xsl:element name="process_ind_ref">
          <xsl:element name="command_id">find_bundle_voip_1</xsl:element>
          <xsl:element name="field_name">bundle_found</xsl:element>          	
        </xsl:element>
        <xsl:element name="required_process_ind">Y</xsl:element>        
      </xsl:element>
    </xsl:element> 
    
    <!-- Terminate Safety Package if bundeled -->
    &TerminateService_Safety;
    
    <xsl:if test="request-param[@name='OMTS_ORDER_ID_ACTIVATION'] != ''">
    <!-- Create Customer Order -->
    <xsl:element name="CcmFifCreateCustOrderCmd">
      <xsl:element name="command_id">create_activation_co</xsl:element>
      <xsl:element name="CcmFifCreateCustOrderInCont">
        <xsl:element name="customer_number">
          <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
        </xsl:element>
        <xsl:element name="customer_tracking_id">
          <xsl:value-of select="request-param[@name='OMTS_ORDER_ID_ACTIVATION']"/>
        </xsl:element>
        <xsl:element name="provider_tracking_no">001v</xsl:element>
        <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
        <xsl:element name="create_empty_customer_order">Y</xsl:element>
        <xsl:element name="service_ticket_pos_list"/>              
      </xsl:element>
    </xsl:element>
    
    <!-- Write to Provider-Change-Log -->
    <xsl:element name="CcmFifCreateProviderChangeLogCmd">
      <xsl:element name="command_id">create_prov_change_log</xsl:element>
      <xsl:element name="CcmFifCreateProviderChangeLogInCont">
        <xsl:element name="act_customer_order_id_ref">
          <xsl:element name="command_id">create_activation_co</xsl:element>
          <xsl:element name="field_name">customer_order_id</xsl:element>
        </xsl:element>
        <xsl:element name="term_customer_order_id_ref">
          <xsl:element name="command_id">create_co_term_dsl_1</xsl:element>
          <xsl:element name="field_name">customer_order_id</xsl:element>
        </xsl:element>    				
        <xsl:element name="source_system">
          <xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
        </xsl:element>
        <xsl:element name="creation_date">
          <xsl:value-of select="dateutils:getCurrentDate()"/>
        </xsl:element>
        <xsl:element name="desired_date">
          <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
        </xsl:element>
        <xsl:element name="reason_rd">
          <xsl:value-of select="$ReasonRd"/>
        </xsl:element>
        <xsl:element name="detailed_reason_rd"/>
      </xsl:element>
    </xsl:element>      
    
    <!-- Create Contact for the provider change -->
    <xsl:element name="CcmFifCreateContactCmd">
      <xsl:element name="CcmFifCreateContactInCont">
        <xsl:element name="customer_number">
          <xsl:value-of select="$CustomerNumber"/>
        </xsl:element>
        <xsl:element name="contact_type_rd">PROV_CHG_TERM</xsl:element>
        <xsl:element name="short_description">Providerwechsel Kündigung</xsl:element>
        <xsl:element name="long_description_text">
          <xsl:text>Kündigung des Vertrags </xsl:text>
          <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
          <xsl:text> ist Teil eines Providerwechsels von &#xA;Kunde </xsl:text>
          <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>   
          <xsl:text> (Barcode: </xsl:text>
          <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
          <xsl:text>) zu &#xA;einem noch nicht erstellten Kunden (Barcode: </xsl:text>
          <xsl:value-of select="request-param[@name='OMTS_ORDER_ID_ACTIVATION']"/>
          <xsl:text>)&#xA;TransactionID: </xsl:text>
          <xsl:value-of select="request-param[@name='transactionID']"/>
          <xsl:text> (Client: </xsl:text>
          <xsl:value-of select="request-param[@name='CLIENT_NAME']"/>                  
          <xsl:text>)</xsl:text>
        </xsl:element>
      </xsl:element>
    </xsl:element>      
    
    </xsl:if>
