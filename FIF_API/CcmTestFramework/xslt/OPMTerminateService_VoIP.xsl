    <!-- look for a VoIP bundle (item) -->
    <xsl:element name="CcmFifFindBundleCmd">
      <xsl:element name="command_id">find_bundle_voip_1</xsl:element>
      <xsl:element name="CcmFifFindBundleInCont">
        <xsl:element name="bundle_id_ref">
          <xsl:element name="command_id">find_bundle_1</xsl:element>
          <xsl:element name="field_name">bundle_id</xsl:element>
        </xsl:element>          
        <xsl:element name="bundle_item_type_rd">VOIP_SERVICE</xsl:element>
        <xsl:element name="process_ind_ref">
          <xsl:element name="command_id">find_bundle_1</xsl:element>
          <xsl:element name="field_name">bundle_found</xsl:element>          	
        </xsl:element>
        <xsl:element name="required_process_ind">Y</xsl:element>
      </xsl:element>
    </xsl:element>
       
       <!-- Find online SS ID by bundled SS id, if a bundle was found -->
       <xsl:element name="CcmFifFindServiceSubsCmd">
         <xsl:element name="command_id">find_service_voip_1</xsl:element>
         <xsl:element name="CcmFifFindServiceSubsInCont">
           <xsl:element name="service_subscription_id_ref">
             <xsl:element name="command_id">find_bundle_voip_1</xsl:element>
             <xsl:element name="field_name">supported_object_id</xsl:element>
           </xsl:element>
           <xsl:element name="effective_date">
             <xsl:value-of select="$TerminationDate"/>
           </xsl:element>                  
           <xsl:element name="process_ind_ref">
             <xsl:element name="command_id">find_bundle_voip_1</xsl:element>
             <xsl:element name="field_name">bundle_found</xsl:element>           
           </xsl:element>
           <xsl:element name="required_process_ind">Y</xsl:element>
         </xsl:element>
       </xsl:element>
          
        <!-- Ensure that the termination has not been performed before -->
        <xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
          <xsl:element name="command_id">find_cancel_stp_voip_1</xsl:element>
          <xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
                <xsl:element name="product_subscription_ref">
                  <xsl:element name="command_id">find_service_voip_1</xsl:element>
                  <xsl:element name="field_name">product_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="reason_rd">TERMINATION</xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_bundle_voip_1</xsl:element>
                  <xsl:element name="field_name">bundle_found</xsl:element>          	
                </xsl:element>
                <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element>

        <!-- Terminate Order Form -->
        <xsl:element name="CcmFifTerminateOrderFormCmd">
          <xsl:element name="command_id">terminate_of_voip_1</xsl:element>
          <xsl:element name="CcmFifTerminateOrderFormInCont">
            <xsl:element name="contract_number_ref">
                <xsl:element name="command_id">find_service_voip_1</xsl:element>
                <xsl:element name="field_name">contract_number</xsl:element>
              </xsl:element>
                <xsl:element name="termination_date">
                    <xsl:value-of select="$TerminationDate"/>
                </xsl:element>
                <xsl:if test="$NoticePeriodStartDate != ''">
                    <xsl:element name="notice_per_start_date">
                        <xsl:value-of select="$NoticePeriodStartDate"/>
                    </xsl:element>
                 </xsl:if>
                <xsl:if test="$NoticePeriodStartDate = ''">
                    <xsl:element name="notice_per_start_date">
                      <xsl:value-of select="$Today"/>
                    </xsl:element>
                </xsl:if>
                <xsl:element name="override_restriction">Y</xsl:element>
                <xsl:element name="termination_reason_rd">
                    <xsl:value-of select="$TerminationReason"/>
                </xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_bundle_voip_1</xsl:element>
                  <xsl:element name="field_name">bundle_found</xsl:element>          	
                </xsl:element>
                <xsl:element name="required_process_ind">Y</xsl:element>            
          </xsl:element>
        </xsl:element>

        <!-- Reconfigure Service Subscription -->
        <xsl:element name="CcmFifReconfigServiceCmd">
          <xsl:element name="command_id">reconf_serv_voip_1</xsl:element>
          <xsl:element name="CcmFifReconfigServiceInCont">
                <xsl:element name="service_subscription_ref">
                  <xsl:element name="command_id">find_service_voip_1</xsl:element>
                  <xsl:element name="field_name">service_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                <xsl:element name="reason_rd">TERMINATION</xsl:element>
                <xsl:element name="service_characteristic_list">
                  <!-- Kündigungsgrund -->
                  <xsl:element name="CcmFifConfiguredValueCont">
                         <xsl:element name="service_char_code">V0137</xsl:element>
                         <xsl:element name="data_type">STRING</xsl:element>
                         <xsl:element name="configured_value">
                             <xsl:value-of select="$TerminationReason"/>
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
                  <!-- Aktivierungsdatum -->
                  <xsl:element name="CcmFifConfiguredValueCont">
                         <xsl:element name="service_char_code">V0909</xsl:element>
                         <xsl:element name="data_type">STRING</xsl:element>
                         <xsl:element name="configured_value">
                           <xsl:value-of select="$terminationDateOPM"/>
                         </xsl:element>
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
                </xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_bundle_voip_1</xsl:element>
                  <xsl:element name="field_name">bundle_found</xsl:element>          	
                </xsl:element>
                <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element>

        <!-- Terminate Product Subscription -->
        <xsl:element name="CcmFifTerminateProductSubsCmd">
          <xsl:element name="command_id">terminate_ps_voip_1</xsl:element>
          <xsl:element name="CcmFifTerminateProductSubsInCont">
                <xsl:element name="product_subscription_ref">
                  <xsl:element name="command_id">find_service_voip_1</xsl:element>
                  <xsl:element name="field_name">product_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="desired_date">
                  <xsl:value-of select="$TerminationDate"/>
                </xsl:element>
                <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
                <xsl:element name="reason_rd">TERMINATION</xsl:element>
       			<xsl:element name="auto_customer_order">N</xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_bundle_voip_1</xsl:element>
                  <xsl:element name="field_name">bundle_found</xsl:element>          	
                </xsl:element>
                <xsl:element name="required_process_ind">Y</xsl:element>            
          </xsl:element>
        </xsl:element>

        <!-- Create Customer Order for Reconfiguration -->
        <xsl:element name="CcmFifCreateCustOrderCmd">
          <xsl:element name="command_id">create_co_1</xsl:element>
          <xsl:element name="CcmFifCreateCustOrderInCont">
                <xsl:if test="$CustomerNumber != ''">
                  <xsl:element name="customer_number">
                    <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="$CustomerNumber = ''">
                  <xsl:element name="customer_number_ref">
                    <xsl:element name="command_id">find_service_voip_1</xsl:element>
                    <xsl:element name="field_name">customer_number</xsl:element>
                  </xsl:element>
                </xsl:if>             
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
                        <xsl:element name="command_id">reconf_serv_voip_1</xsl:element>
                        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                  </xsl:element>
                </xsl:element>
                <xsl:if test="$OMTSOrderId = ''">
                  <xsl:element name="generate_customer_tracking_id">Y</xsl:element>	
                </xsl:if>             
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_bundle_voip_1</xsl:element>
                  <xsl:element name="field_name">bundle_found</xsl:element>          	
                </xsl:element>
                <xsl:element name="required_process_ind">Y</xsl:element>            
          </xsl:element>
        </xsl:element>
           

        <!-- Create Customer Order for Termination -->
        <xsl:element name="CcmFifCreateCustOrderCmd">
          <xsl:element name="command_id">create_co_voip_1</xsl:element>
          <xsl:element name="CcmFifCreateCustOrderInCont">
                <xsl:if test="$CustomerNumber != ''">
                  <xsl:element name="customer_number">
                    <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="$CustomerNumber = ''">
                  <xsl:element name="customer_number_ref">
                    <xsl:element name="command_id">find_service_voip_1</xsl:element>
                    <xsl:element name="field_name">customer_number</xsl:element>
                  </xsl:element>
                </xsl:if> 
                <xsl:element name="parent_customer_order_ref">
                  <xsl:element name="command_id">create_co_1</xsl:element>
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
                        <xsl:element name="command_id">terminate_ps_voip_1</xsl:element>
                        <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
                  </xsl:element>
                </xsl:element>                    
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_bundle_voip_1</xsl:element>
                  <xsl:element name="field_name">bundle_found</xsl:element>          	
                </xsl:element>
                <xsl:element name="required_process_ind">Y</xsl:element>            
          </xsl:element>
        </xsl:element>

        <!-- Release Customer Order for Reconfiguration -->
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="CcmFifReleaseCustOrderInCont">
                <xsl:if test="$CustomerNumber != ''">
                  <xsl:element name="customer_number">
                    <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="$CustomerNumber = ''">
                  <xsl:element name="customer_number_ref">
                    <xsl:element name="command_id">find_service_voip_1</xsl:element>
                    <xsl:element name="field_name">customer_number</xsl:element>
                  </xsl:element>
                </xsl:if> 
                <xsl:element name="customer_order_ref">
                  <xsl:element name="command_id">create_co_1</xsl:element>
                  <xsl:element name="field_name">customer_order_id</xsl:element>
                </xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_bundle_voip_1</xsl:element>
                  <xsl:element name="field_name">bundle_found</xsl:element>          	
                </xsl:element>
                <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element>

        <!-- Release Customer Order for Termination -->
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="CcmFifReleaseCustOrderInCont">
                <xsl:if test="$CustomerNumber != ''">
                  <xsl:element name="customer_number">
                    <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="$CustomerNumber = ''">
                  <xsl:element name="customer_number_ref">
                    <xsl:element name="command_id">find_service_voip_1</xsl:element>
                    <xsl:element name="field_name">customer_number</xsl:element>
                  </xsl:element>
                </xsl:if> 
                <xsl:element name="customer_order_ref">
                  <xsl:element name="command_id">create_co_voip_1</xsl:element>
                  <xsl:element name="field_name">customer_order_id</xsl:element>
                </xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_bundle_voip_1</xsl:element>
                  <xsl:element name="field_name">bundle_found</xsl:element>          	
                </xsl:element>
                <xsl:element name="required_process_ind">Y</xsl:element>
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
                <xsl:element name="command_id">find_service_voip_1</xsl:element>
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
                <xsl:element name="command_id">find_service_voip_1</xsl:element>
                <xsl:element name="field_name">contract_number</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="contact_text">
                  <xsl:text>&#xA;TerminationReason: </xsl:text>
                  <xsl:value-of select="$TerminationReason"/>
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
