  
        
              
      <!-- Ensure that either ACCESS_NUMBER or  SERVICE_TICKET_POSITION_ID are provided -->
      <xsl:if test="(request-param[@name='ACCESS_NUMBER'] = '') and
                            (request-param[@name='SERVICE_TICKET_POSITION_ID'] = '') and
                            (request-param[@name='SERVICE_SUBSCRIPTION_ID'] = '')">
                            
                <xsl:element name="CcmFifRaiseErrorCmd">
                  <xsl:element name="command_id">create_find_ss_error</xsl:element>
                  <xsl:element name="CcmFifRaiseErrorInCont">
                    <xsl:element name="error_text">At least one of the following params must be provided:
                      ACCESS_NUMBER or SERVICE_TICKET_POSITION_ID or SERVICE_SUBSCRIPTION_ID.</xsl:element>
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

                <!-- Ensure that the termination has not been performed before -->
                <xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
                  <xsl:element name="command_id">find_cancel_stp_1</xsl:element>
                  <xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
                        <xsl:element name="product_subscription_ref">
                          <xsl:element name="command_id">find_service_1</xsl:element>
                          <xsl:element name="field_name">product_subscription_id</xsl:element>
                        </xsl:element>
                        <xsl:element name="reason_rd">TERMINATION</xsl:element>
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
              
              <!-- Check if there's only one PS exists -->
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

                <!-- Reconfigure Service Subscription -->
                <xsl:element name="CcmFifReconfigServiceCmd">
                  <xsl:element name="command_id">reconf_serv_1</xsl:element>
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
        				<xsl:element name="configured_value">Echte Kündigung</xsl:element>
        			</xsl:element> 				
                        </xsl:element>
                  </xsl:element>
                </xsl:element>

                <!-- Terminate Product Subscription -->
                <xsl:element name="CcmFifTerminateProductSubsCmd">
                  <xsl:element name="command_id">terminate_ps_1</xsl:element>
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

                <!-- Create Customer Order for Reconfiguration -->
                <xsl:element name="CcmFifCreateCustOrderCmd">
                  <xsl:element name="command_id">create_co_reconf_1</xsl:element>
                  <xsl:element name="CcmFifCreateCustOrderInCont">
                        <xsl:element name="customer_number">
                          <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
                        </xsl:element>
                        <xsl:element name="customer_tracking_id">
                          <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
                        </xsl:element>
                        <xsl:element name="provider_tracking_no">001</xsl:element>
                        <xsl:element name="service_ticket_pos_list">
                          <xsl:element name="CcmFifCommandRefCont">
                                <xsl:element name="command_id">reconf_serv_1</xsl:element>
                                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                          </xsl:element>
                        </xsl:element>
                  </xsl:element>
                </xsl:element>

                <!-- Create Customer Order for Termination -->
                <xsl:element name="CcmFifCreateCustOrderCmd">
                  <xsl:element name="command_id">create_co_term_1</xsl:element>
                  <xsl:element name="CcmFifCreateCustOrderInCont">
                        <xsl:element name="customer_number">
                          <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
                        </xsl:element>
                        <xsl:element name="parent_customer_order_ref">
                          <xsl:element name="command_id">create_co_reconf_1</xsl:element>
                          <xsl:element name="field_name">customer_order_id</xsl:element>
                        </xsl:element>
                        <xsl:element name="customer_tracking_id">
                          <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
                        </xsl:element>
                        <xsl:element name="provider_tracking_no">002</xsl:element>
                        <xsl:element name="service_ticket_pos_list">
                          <xsl:element name="CcmFifCommandRefCont">
                                <xsl:element name="command_id">terminate_ps_1</xsl:element>
                                <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
                          </xsl:element>
                        </xsl:element>
                        <xsl:if test="$ReasonRd = 'PROVIDER_CHANGE'">
                          <xsl:element name="generate_customer_tracking_id">Y</xsl:element>			  	   
                        </xsl:if>
                  </xsl:element>
                </xsl:element>

                <!-- Release Customer Order for Reconfiguration -->
                <xsl:element name="CcmFifReleaseCustOrderCmd">
                  <xsl:element name="CcmFifReleaseCustOrderInCont">
                        <xsl:element name="customer_number">
                          <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
                        </xsl:element>
                        <xsl:element name="customer_order_ref">
                          <xsl:element name="command_id">create_co_reconf_1</xsl:element>
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
                          <xsl:element name="command_id">create_co_term_1</xsl:element>
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

                <!-- Find bundle for the MULTIMEDIA service attached to the NGN-DSL service -->
                <xsl:element name="CcmFifFindBundleCmd"> 
                  <xsl:element name="command_id">find_bundle_1</xsl:element> 
                  <xsl:element name="CcmFifFindBundleInCont"> 
                    <xsl:element name="bundle_item_type_rd">ACCESS</xsl:element> 
                    <xsl:element name="supported_object_id_ref"> 
                      <xsl:element name="command_id">find_service_1</xsl:element> 
                      <xsl:element name="field_name">service_subscription_id</xsl:element> 
                    </xsl:element>     
                  </xsl:element>         
                </xsl:element> 

                <!-- Terminate MULTIMEDIA & Safety Package if bundeled -->
                &TerminateService_Multimedia;
                &TerminateService_Safety;
