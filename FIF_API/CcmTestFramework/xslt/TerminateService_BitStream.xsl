              
              <xsl:element name="CcmFifFindServiceSubsCmd">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="CcmFifFindServiceSubsInCont">
                  <xsl:element name="service_subscription_id">
                    <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
                  </xsl:element>
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
              
              <!-- Terminate Order Form -->
              <xsl:element name="CcmFifTerminateOrderFormCmd">
                <xsl:element name="command_id">terminate_of_1</xsl:element>
                <xsl:element name="CcmFifTerminateOrderFormInCont">
                	<xsl:element name="contract_number_ref">
                		<xsl:element name="command_id">find_service_1</xsl:element>
                		<xsl:element name="field_name">contract_number</xsl:element>
                	</xsl:element>
                	<xsl:element name="termination_date">
                    <xsl:value-of select="$TerminationDate"/>
                  </xsl:element>
                  <xsl:element name="notice_per_start_date">
                    <xsl:value-of select="$NoticePeriodStartDate"/>
                  </xsl:element>
                  <xsl:element name="override_restriction">Y</xsl:element>
                  <xsl:element name="termination_reason_rd">
                    <xsl:value-of select="$TerminationReason"/>
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
                        <xsl:value-of select="$TerminationReason"/>
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
                    <!-- Auftragsvariante  -->
                    <xsl:element name="CcmFifConfiguredValueCont">
                      <xsl:element name="service_char_code">V0810</xsl:element>
                      <xsl:element name="data_type">STRING</xsl:element>                                                                      
                      <xsl:element name="configured_value">
                        <xsl:value-of select="$OrderVariant"/>
                      </xsl:element>    
                    </xsl:element>	
                    <!-- Relocation Variant-->
                    <xsl:if test="request-param[@name='relocationVariant'] != ''">
                      <xsl:element name="CcmFifConfiguredValueCont">
                        <xsl:element name="service_char_code">V2024</xsl:element>
                        <xsl:element name="data_type">STRING</xsl:element>
                        <xsl:element name="configured_value">
                          <xsl:value-of select="request-param[@name='relocationVariant']"/>
                        </xsl:element>
                      </xsl:element>
                    </xsl:if>
                  </xsl:element>
                  <xsl:element name="detailed_reason_ref">
                    <xsl:element name="command_id">clone_order_form_1</xsl:element>
                    <xsl:element name="field_name">detailed_reason_rd</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>  
              
              <xsl:if test="request-param[@name='keepMMAccessHardware'] != ''">	
              	&HandleMMAccessHardware;
              </xsl:if>
              
              <!-- Terminate Product Subscription -->
              <xsl:element name="CcmFifTerminateProductSubsCmd">
          		<xsl:element name="command_id">terminate_ps_1</xsl:element>
          		<xsl:element name="CcmFifTerminateProductSubsInCont">
          			<xsl:element name="product_subscription_ref">
          				<xsl:element name="command_id">find_service_1</xsl:element>
          				<xsl:element name="field_name">product_subscription_id</xsl:element>
          			</xsl:element>
          			<xsl:element name="desired_date">
          				<xsl:value-of select="$TerminationDate"/>
          			</xsl:element>
          			<xsl:element name="desired_schedule_type">END_BEFORE</xsl:element>
          			<xsl:element name="reason_rd">
          				<xsl:value-of select="$ReasonRd"/>
          			</xsl:element>
          			<xsl:element name="auto_customer_order">N</xsl:element>
          			<xsl:element name="detailed_reason_ref">
                          <xsl:element name="command_id">clone_order_form_1</xsl:element>
                          <xsl:element name="field_name">detailed_reason_rd</xsl:element>
                        </xsl:element>
          		</xsl:element>
          	</xsl:element>
          	
          	<!-- Create Customer Order for Reconfiguration -->
          	<xsl:element name="CcmFifCreateCustOrderCmd">
          		<xsl:element name="command_id">ts_create_co_1</xsl:element>
          		<xsl:element name="CcmFifCreateCustOrderInCont">
          			<xsl:element name="customer_number_ref">
          				<xsl:element name="command_id">find_service_1</xsl:element>
          				<xsl:element name="field_name">customer_number</xsl:element>
          			</xsl:element>
          			<xsl:if test="$OrderVariant = 'Wechsel der Anschlussart'">
          				<xsl:element name="parent_customer_order_ref">
          					<xsl:element name="command_id">
          						<xsl:choose>
          							<xsl:when test="$scenarioType != '' and 
          								request-param[@name='clientName'] = 'CODB' and 
          								//request/action-name != 'upgradeToPremium'">create_activation_co</xsl:when>
          							<xsl:otherwise>create_co_1</xsl:otherwise>
          						</xsl:choose>
          					</xsl:element>
          					<xsl:element name="field_name">customer_order_id</xsl:element>
          				</xsl:element>  
          			</xsl:if> 
          			<xsl:element name="customer_tracking_id">
          				<xsl:value-of select="$terminationBarcode"/>
          			</xsl:element>
          			<xsl:element name="provider_tracking_no">
          				<xsl:choose>
          					<xsl:when test="request-param[@name='providerTrackingNumberInternetChange'] != ''">
          						<xsl:value-of select="request-param[@name='providerTrackingNumberInternetChange']" />
          					</xsl:when>
          					<xsl:otherwise>001</xsl:otherwise>
          				</xsl:choose>
          			</xsl:element>
          			<xsl:element name="service_ticket_pos_list">
          				<xsl:element name="CcmFifCommandRefCont">
          					<xsl:element name="command_id">reconf_serv_1</xsl:element>
          					<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
          				</xsl:element>
          				<xsl:element name="CcmFifCommandRefCont">
          					<xsl:element name="command_id">reconf_hardware_service</xsl:element>
          					<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
          				</xsl:element>
          				<xsl:element name="CcmFifCommandRefCont">
          					<xsl:element name="command_id">read_internet_stp</xsl:element>
          					<xsl:element name="field_name">parameter_value</xsl:element>
          				</xsl:element>
          			</xsl:element>
          		</xsl:element>
          	</xsl:element>
          	
          	
          	<!-- Create Customer Order for Termination -->
          	<xsl:element name="CcmFifCreateCustOrderCmd">
          		<xsl:element name="command_id">ts_create_co_2</xsl:element>
          		<xsl:element name="CcmFifCreateCustOrderInCont">
          			<xsl:element name="customer_number_ref">
          				<xsl:element name="command_id">find_service_1</xsl:element>
          				<xsl:element name="field_name">customer_number</xsl:element>
          			</xsl:element>
          			<xsl:element name="parent_customer_order_ref">
          				<xsl:element name="command_id">ts_create_co_1</xsl:element>
          				<xsl:element name="field_name">customer_order_id</xsl:element>
          			</xsl:element>
          			<xsl:element name="customer_tracking_id">
          				<xsl:value-of select="$terminationBarcode"/>
          			</xsl:element>
          			<xsl:element name="provider_tracking_no">
          				<xsl:choose>
          					<xsl:when test="request-param[@name='providerTrackingNumberInternetDefault'] != ''">
          						<xsl:value-of select="request-param[@name='providerTrackingNumberInternetDefault']" />
          					</xsl:when>
          					<xsl:otherwise>002</xsl:otherwise>
          				</xsl:choose>
          			</xsl:element>
          			<xsl:element name="service_ticket_pos_list">
          				<xsl:element name="CcmFifCommandRefCont">
          					<xsl:element name="command_id">terminate_ps_1</xsl:element>
          					<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
          				</xsl:element>
          			</xsl:element>
          		</xsl:element>
          	</xsl:element>
          	
          	<!-- Release Customer Order for Reconfiguration -->
          	<xsl:element name="CcmFifReleaseCustOrderCmd">
          		<xsl:element name="CcmFifReleaseCustOrderInCont">
          			<xsl:element name="customer_number_ref">
          				<xsl:element name="command_id">find_service_1</xsl:element>
          				<xsl:element name="field_name">customer_number</xsl:element>
          			</xsl:element>
          			<xsl:element name="customer_order_ref">
          				<xsl:element name="command_id">ts_create_co_1</xsl:element>
          				<xsl:element name="field_name">customer_order_id</xsl:element>
          			</xsl:element>
          		</xsl:element>
          	</xsl:element>
          	
          	
          	<!-- Release Customer Order for Termination -->
          	<xsl:element name="CcmFifReleaseCustOrderCmd">
          		<xsl:element name="CcmFifReleaseCustOrderInCont">
          			<xsl:element name="customer_number_ref">
          				<xsl:element name="command_id">find_service_1</xsl:element>
          				<xsl:element name="field_name">customer_number</xsl:element>
          			</xsl:element>
          			<xsl:element name="customer_order_ref">
          				<xsl:element name="command_id">ts_create_co_2</xsl:element>
          				<xsl:element name="field_name">customer_order_id</xsl:element>
          			</xsl:element>
          		</xsl:element>
          	</xsl:element>
        
            <xsl:element name="CcmFifModifyBundleItemCmd">
                <xsl:element name="CcmFifModifyBundleItemInCont">
                    <xsl:element name="bundle_id_ref">
                        <xsl:element name="command_id">find_bundle_1</xsl:element>
                        <xsl:element name="field_name">bundle_id</xsl:element>
                    </xsl:element>
                    <xsl:element name="supported_object_id_ref">
                        <xsl:element name="command_id">find_service_1</xsl:element>
                        <xsl:element name="field_name">service_subscription_id</xsl:element>
                    </xsl:element>
                    <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
                    <xsl:element name="action_name">MODIFY</xsl:element>
                    <xsl:element name="future_indicator">T</xsl:element>
                    <xsl:element name="process_ind_ref">
                        <xsl:element name="command_id">find_bundle_1</xsl:element>
                        <xsl:element name="field_name">bundle_found</xsl:element>
                    </xsl:element>
                    <xsl:element name="required_process_ind">Y</xsl:element>
                </xsl:element>
            </xsl:element>
            
            <!-- TERMINATE THE BIT VOIP -->

          	<!-- Find bundle for the BIT VoIP service attached to the BIT-DSL service -->
          	<xsl:element name="CcmFifFindBundleCmd"> 
          		<xsl:element name="command_id">find_bundle_1</xsl:element> 
          		<xsl:element name="CcmFifFindBundleInCont"> 
          		    <xsl:element name="bundle_item_type_rd">BITACCESS</xsl:element> 
          			<xsl:element name="supported_object_id_ref"> 
          				<xsl:element name="command_id">find_service_1</xsl:element> 
          				<xsl:element name="field_name">service_subscription_id</xsl:element> 
          			</xsl:element>     
          		</xsl:element>         
          	</xsl:element> 
          	
          	<xsl:if test="$scenarioType = '' or 
          		request-param[@name='clientName'] != 'CODB' or 
          		//request/action-name = 'upgradeToPremium'">          		
          		<!-- Find the Bit VOIP service attached to the Bit DSL service -->	
          		<xsl:element name="CcmFifFindBundleCmd">
          			<xsl:element name="command_id">find_bundle_2</xsl:element>
          			<xsl:element name="CcmFifFindBundleInCont">
          				<xsl:element name="bundle_id_ref">
          					<xsl:element name="command_id">find_bundle_1</xsl:element>
          					<xsl:element name="field_name">bundle_id</xsl:element>
          				</xsl:element>
          				<xsl:element name="bundle_item_type_rd">BITVOIP</xsl:element>
          				<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
          				<xsl:element name="process_ind_ref">
          					<xsl:element name="command_id">find_bundle_1</xsl:element>
          					<xsl:element name="field_name">bundle_found</xsl:element>
          				</xsl:element>
          				<xsl:element name="required_process_ind">Y</xsl:element>
          			</xsl:element>	
          		</xsl:element>	
          	</xsl:if>
          	
          	<!--Find service subscription for Bit VOIP to get contract number-->
          	<xsl:element name="CcmFifFindServiceSubsCmd">
          		<xsl:element name="command_id">find_service_2</xsl:element>
          		<xsl:element name="CcmFifFindServiceSubsInCont">
          			<xsl:element name="service_subscription_id_ref">
          				<xsl:element name="command_id">find_bundle_2</xsl:element>
          				<xsl:element name="field_name">supported_object_id</xsl:element>	
          			</xsl:element>	
          			<xsl:element name="customer_number_ref">
          				<xsl:element name="command_id">find_service_1</xsl:element>
          				<xsl:element name="field_name">customer_number</xsl:element>
          			</xsl:element>
          			<xsl:element name="process_ind_ref">
          				<xsl:element name="command_id">find_bundle_2</xsl:element>
          				<xsl:element name="field_name">bundle_found</xsl:element>	
          			</xsl:element>
          			<xsl:element name="required_process_ind">Y</xsl:element>
          		</xsl:element>	
          	</xsl:element>	
        
              <!-- find voice stp -->
          	<xsl:element name="CcmFifFindServiceTicketPositionCmd">
          	  <xsl:element name="command_id">find_voice_stp</xsl:element>
          	  <xsl:element name="CcmFifFindServiceTicketPositionInCont">
          	    <xsl:element name="service_subscription_id_ref">
          			<xsl:element name="command_id">find_service_2</xsl:element>
          			<xsl:element name="field_name">service_subscription_id</xsl:element>	
          	    </xsl:element>
          	    <xsl:element name="no_stp_error">N</xsl:element>
          	    <xsl:element name="find_stp_parameters">
          	    	<xsl:element name="CcmFifFindStpParameterCont">
          	        	<xsl:element name="customer_order_state">FINAL</xsl:element>
          	    	</xsl:element>
          	    	<xsl:element name="CcmFifFindStpParameterCont">
          	        	<xsl:element name="customer_order_state">COMPLETED</xsl:element>
          	    	</xsl:element>
          	    </xsl:element>
          	  </xsl:element>
          	</xsl:element>
                 
                <!-- Find an service characteristic value required in notification -->
                <xsl:element name="CcmFifFindServCharValueForServCharCmd">
                  <xsl:element name="command_id">find_serv_char_1</xsl:element>
                  <xsl:element name="CcmFifFindServCharValueForServCharInCont">
                    <xsl:element name="service_ticket_position_id_ref">
          			<xsl:element name="command_id">find_voice_stp</xsl:element>
          			<xsl:element name="field_name">service_ticket_position_id</xsl:element>	
                    </xsl:element>
                    <xsl:element name="service_char_code">V0014</xsl:element>
                    <xsl:element name="retrieve_all_characteristics">Y</xsl:element>          
                  </xsl:element>
                </xsl:element>
        
          	<xsl:element name="CcmFifNormalizeAddressCmd">
          		<xsl:element name="command_id">normalize_address_1</xsl:element>
          		<xsl:element name="CcmFifNormalizeAddressInCont">
          			<xsl:element name="customer_number_ref">
          				<xsl:element name="command_id">find_service_1</xsl:element>
          				<xsl:element name="field_name">customer_number</xsl:element>
          			</xsl:element>
          			<xsl:element name="address_id_ref">
                  		<xsl:element name="command_id">find_serv_char_1</xsl:element>
                  		<xsl:element name="field_name">address_id</xsl:element>	
          			</xsl:element>
          		</xsl:element>
          	</xsl:element>
        
                 <!-- Terminate Order Form for bundled Bit VoIP -->
                <xsl:element name="CcmFifTerminateOrderFormCmd">
                  <xsl:element name="command_id">terminate_of_2</xsl:element>
                  <xsl:element name="CcmFifTerminateOrderFormInCont">
                  	<xsl:element name="contract_number_ref">
                  		<xsl:element name="command_id">find_service_2</xsl:element>
                  		<xsl:element name="field_name">contract_number</xsl:element>	
                  	</xsl:element>
                  	<xsl:element name="termination_date">
                  		<xsl:value-of select="$TerminationDate"/>
                  	</xsl:element>
                  	<xsl:element name="notice_per_start_date">
                  		<xsl:value-of select="$NoticePeriodStartDate"/>
                  	</xsl:element>
                  	<xsl:element name="override_restriction">Y</xsl:element>
                  	<xsl:element name="termination_reason_rd">
                  		<xsl:value-of select="$TerminationReason"/>
                  	</xsl:element>        			
                  </xsl:element>
                </xsl:element>
                
                <!-- Ensure that the termination has not been performed before -->
                <xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
                  <xsl:element name="command_id">find_cancel_stp_2</xsl:element>
                  <xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
                  	<xsl:element name="product_subscription_ref">
                  		<xsl:element name="command_id">find_service_2</xsl:element>
                  		<xsl:element name="field_name">product_subscription_id</xsl:element>
                  	</xsl:element>
                  	<xsl:element name="reason_rd">TERMINATION</xsl:element>      			
                  </xsl:element>
                </xsl:element>
          	
          	<!-- Reconfigure service subscription for  Bit VoIP  Premium Service-->
          	
          	<xsl:element name="CcmFifReconfigServiceCmd">
          		<xsl:element name="command_id">reconf_serv_2</xsl:element>
          		<xsl:element name="CcmFifReconfigServiceInCont">
          			<xsl:element name="service_subscription_ref">
          				<xsl:element name="command_id">find_service_2</xsl:element>
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
          							<xsl:when test="request-param[@name='carrier'] != '' 
          								and $OrderVariant = 'Echte Kündigung'">
          								<xsl:value-of select="request-param[@name='carrier']"/>    
          							</xsl:when>
          							<xsl:otherwise>**NULL**</xsl:otherwise>
          						</xsl:choose>                              									
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
          				<!-- Bemerkung -->
          				<xsl:element name="CcmFifConfiguredValueCont">
          					<xsl:element name="service_char_code">V0008</xsl:element>
          					<xsl:element name="data_type">STRING</xsl:element>
          					<xsl:element name="configured_value">
          						<xsl:value-of select="request-param[@name='userName']"/>
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
          						<xsl:value-of select="$TerminationReason"/>
          					</xsl:element>
          				</xsl:element>        				
          				<!-- Backporting of VoIP Access Number 1 -->
          				<xsl:if test="request-param[@name='portAccessNumber1'] != ''">
          					<xsl:element name="CcmFifConfiguredValueCont">
          						<xsl:element name="service_char_code">V0165</xsl:element>
          						<xsl:element name="data_type">STRING</xsl:element>
          						<xsl:element name="configured_value">
          							<xsl:value-of select="request-param[@name='portAccessNumber1']"/>
          						</xsl:element>
          					</xsl:element>
          				</xsl:if>          				
          			</xsl:element>
          			<xsl:element name="detailed_reason_ref">
          				<xsl:element name="command_id">clone_order_form_1</xsl:element>
          				<xsl:element name="field_name">detailed_reason_rd</xsl:element>
          			</xsl:element>				
          		</xsl:element>
          	</xsl:element>
               
              <!-- Terminate Product Subscription for bundled Bit VOIP -->
              <xsl:element name="CcmFifTerminateProductSubsCmd">
                <xsl:element name="command_id">terminate_ps_2</xsl:element>
                <xsl:element name="CcmFifTerminateProductSubsInCont">
                  <xsl:element name="product_subscription_ref">
                  	<xsl:element name="command_id">find_service_2</xsl:element>
                  	<xsl:element name="field_name">product_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="desired_date">
                  	<xsl:value-of select="$TerminationDate"/>
                  </xsl:element>
                  <xsl:element name="desired_schedule_type">END_BEFORE</xsl:element>
                  <xsl:element name="reason_rd">
                  	<xsl:value-of select="$ReasonRd"/>
                  </xsl:element>
                  <xsl:element name="auto_customer_order">N</xsl:element>   
                  <xsl:element name="detailed_reason_ref">
                  	<xsl:element name="command_id">clone_order_form_1</xsl:element>
                        <xsl:element name="field_name">detailed_reason_rd</xsl:element>
                      </xsl:element>
                </xsl:element>
              </xsl:element>
       
              <!-- Create Customer Order for Reconfiguration of bundled Bit VoIP-->
              <xsl:element name="CcmFifCreateCustOrderCmd">
              	<xsl:element name="command_id">ts_create_co_bit_voip_1</xsl:element>
                <xsl:element name="CcmFifCreateCustOrderInCont">
                	<xsl:element name="customer_number_ref">
                		<xsl:element name="command_id">find_service_1</xsl:element>
                		<xsl:element name="field_name">customer_number</xsl:element>
                	</xsl:element>                	
                	<xsl:if test="$OrderVariant = 'Wechsel der Anschlussart'">
                		<xsl:element name="parent_customer_order_ref">
                			<xsl:element name="command_id">
                				<xsl:choose>
                					<xsl:when test="$scenarioType != '' and 
                						request-param[@name='clientName'] = 'CODB' and 
                						//request/action-name != 'upgradeToPremium'">create_voip_co</xsl:when>
                					<xsl:otherwise>create_co_2</xsl:otherwise>
                				</xsl:choose>
                			</xsl:element>
                			<xsl:element name="field_name">customer_order_id</xsl:element>
                		</xsl:element>  
                	</xsl:if>         		
                  <xsl:element name="customer_tracking_id">
                  	<xsl:value-of select="$terminationBarcode"/>
                  </xsl:element>
                	<xsl:element name="provider_tracking_no">
                		<xsl:choose>
                			<xsl:when test="request-param[@name='providerTrackingNumberVoiceChange'] != ''">
                				<xsl:value-of select="request-param[@name='providerTrackingNumberVoiceChange']" />
                			</xsl:when>
                			<xsl:otherwise>001v</xsl:otherwise>
                		</xsl:choose>
                	</xsl:element>
                	<xsl:element name="service_ticket_pos_list">
                  	<xsl:element name="CcmFifCommandRefCont">
                  		<xsl:element name="command_id">reconf_serv_2</xsl:element>
                  		<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                  	</xsl:element>
                  	<xsl:element name="CcmFifCommandRefCont">
                  		<xsl:element name="command_id">read_voice_stp</xsl:element>
                  		<xsl:element name="field_name">parameter_value</xsl:element>
                  	</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>        	
            
              <!-- Create Customer Order for Termination -->
              <xsl:element name="CcmFifCreateCustOrderCmd">
              	<xsl:element name="command_id">ts_create_co_bit_voip_2</xsl:element>
                <xsl:element name="CcmFifCreateCustOrderInCont">
                	<xsl:element name="customer_number_ref">
                		<xsl:element name="command_id">find_service_1</xsl:element>
                		<xsl:element name="field_name">customer_number</xsl:element>
                	</xsl:element>
                	<xsl:element name="parent_customer_order_ref">
                		<xsl:element name="command_id">ts_create_co_bit_voip_1</xsl:element>
                  		<xsl:element name="field_name">customer_order_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="customer_tracking_id">
                  	<xsl:value-of select="$terminationBarcode"/>
                  </xsl:element>
                	<xsl:element name="provider_tracking_no">
                		<xsl:choose>
                			<xsl:when test="request-param[@name='providerTrackingNumberVoiceDefault'] != ''">
                				<xsl:value-of select="request-param[@name='providerTrackingNumberVoiceDefault']" />
                			</xsl:when>
                			<xsl:otherwise>002v</xsl:otherwise>
                		</xsl:choose>
                	</xsl:element>
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
                	<xsl:element name="customer_number_ref">
                		<xsl:element name="command_id">find_service_1</xsl:element>
                		<xsl:element name="field_name">customer_number</xsl:element>
                	</xsl:element>
                	<xsl:element name="customer_order_ref">
                		<xsl:element name="command_id">ts_create_co_bit_voip_1</xsl:element>
                  	<xsl:element name="field_name">customer_order_id</xsl:element>
                  </xsl:element>
                  
                </xsl:element>
              </xsl:element>
      
              <!-- Release Customer Order for Termination for bundled Bit VoIP -->
              <xsl:element name="CcmFifReleaseCustOrderCmd">
                <xsl:element name="CcmFifReleaseCustOrderInCont">
                	<xsl:element name="customer_number_ref">
                		<xsl:element name="command_id">find_service_1</xsl:element>
                		<xsl:element name="field_name">customer_number</xsl:element>
                	</xsl:element>
                	<xsl:element name="customer_order_ref">
                		<xsl:element name="command_id">ts_create_co_bit_voip_2</xsl:element>
                  	<xsl:element name="field_name">customer_order_id</xsl:element>
                  </xsl:element> 
                </xsl:element>
              </xsl:element>
                           
            <xsl:element name="CcmFifModifyBundleItemCmd">
                <xsl:element name="CcmFifModifyBundleItemInCont">
                    <xsl:element name="bundle_id_ref">
                        <xsl:element name="command_id">find_bundle_1</xsl:element>
                        <xsl:element name="field_name">bundle_id</xsl:element>
                    </xsl:element>
                    <xsl:element name="supported_object_id_ref">
                        <xsl:element name="command_id">find_service_2</xsl:element>
                        <xsl:element name="field_name">service_subscription_id</xsl:element>
                    </xsl:element>
                    <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
                    <xsl:element name="action_name">MODIFY</xsl:element>
                    <xsl:element name="future_indicator">T</xsl:element>
                    <xsl:element name="process_ind_ref">
                        <xsl:element name="command_id">find_bundle_1</xsl:element>
                        <xsl:element name="field_name">bundle_found</xsl:element>
                    </xsl:element>
                    <xsl:element name="required_process_ind">Y</xsl:element>
                </xsl:element>
            </xsl:element>
            
            <!-- Create Contact for the Service Termination (both Bit DSL and Bit VOIP)-->
                 <xsl:element name="CcmFifCreateContactCmd">
                 	<xsl:element name="CcmFifCreateContactInCont">
                 		<xsl:element name="customer_number_ref">
                 			<xsl:element name="command_id">find_service_1</xsl:element>
                 			<xsl:element name="field_name">customer_number</xsl:element>
                 		</xsl:element>
                 		<xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
                 		<xsl:element name="short_description">Automatische Kündigung</xsl:element>
                 		<xsl:element name="description_text_list">
                 			<xsl:element name="CcmFifPassingValueCont">
                 				<xsl:element name="contact_text">
                 					<xsl:text>TransactionID: </xsl:text>
                 					<xsl:value-of select="request-param[@name='transactionID']"/>
                 					<xsl:text>&#xA;Client: </xsl:text>
                 					<xsl:value-of select="request-param[@name='clientName']"/>
                 					<xsl:text>&#xA;Kündigungsgrund: </xsl:text>
                 					<xsl:value-of select="$TerminationReason"/>
                 					<xsl:text>&#xA;Benutzername: </xsl:text>
                 					<xsl:value-of select="request-param[@name='userName']"/>
                 					<xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
                 					<xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
                 					<xsl:text>&#xA;Vertragsnummer Bit-DSL: </xsl:text>
                 				</xsl:element>
                 			</xsl:element>
                 			<xsl:element name="CcmFifCommandRefCont">
                 				<xsl:element name="command_id">find_service_1</xsl:element>
                 				<xsl:element name="field_name">contract_number</xsl:element>
                 			</xsl:element>
                 			<xsl:element name="CcmFifPassingValueCont">
                 				<xsl:element name="contact_text">                          			
                 					<xsl:text>&#xA;Vertragsnummer Bit-VoIP: </xsl:text>
                 				</xsl:element> 
                 			</xsl:element>
                 			<xsl:element name="CcmFifCommandRefCont">
                 				<xsl:element name="command_id">find_service_2</xsl:element>
                 				<xsl:element name="field_name">contract_number</xsl:element>
                 			</xsl:element>
                 		</xsl:element>
                 	</xsl:element> 
                 </xsl:element>
                 
                 <xsl:if test="$scenarioType != '' and request-param[@name='clientName'] = 'CODB'">                 					
                 	<xsl:element name="CcmFifConcatStringsCmd">
                 		<xsl:element name="command_id">voiceReconfPTN</xsl:element>
                 		<xsl:element name="CcmFifConcatStringsInCont">
                 			<xsl:element name="input_string_list">
                 				<xsl:element name="CcmFifCommandRefCont">
                 					<xsl:element name="command_id">ts_create_co_bit_voip_1</xsl:element>
                 					<xsl:element name="field_name">provider_tracking_no</xsl:element>							
                 				</xsl:element>
                 			</xsl:element>
                 		</xsl:element>
                 	</xsl:element>      
                 	<xsl:element name="CcmFifConcatStringsCmd">
                 		<xsl:element name="command_id">voiceTerminationPTN</xsl:element>
                 		<xsl:element name="CcmFifConcatStringsInCont">
                 			<xsl:element name="input_string_list">
                 				<xsl:element name="CcmFifCommandRefCont">
                 					<xsl:element name="command_id">ts_create_co_bit_voip_2</xsl:element>
                 					<xsl:element name="field_name">provider_tracking_no</xsl:element>							
                 				</xsl:element>
                 			</xsl:element>
                 		</xsl:element>
                 	</xsl:element>
                 	<xsl:element name="CcmFifConcatStringsCmd">
                 		<xsl:element name="command_id">oldVoiceService</xsl:element>
                 		<xsl:element name="CcmFifConcatStringsInCont">
                 			<xsl:element name="input_string_list">
                 				<xsl:element name="CcmFifCommandRefCont">
                 					<xsl:element name="command_id">find_service_2</xsl:element>
                 					<xsl:element name="field_name">service_subscription_id</xsl:element>							
                 				</xsl:element>
                 			</xsl:element>
                 		</xsl:element>
                 	</xsl:element>
                 	
                 	<xsl:element name="CcmFifConcatStringsCmd">
                 		<xsl:element name="command_id">internetReconfPTN</xsl:element>
                 		<xsl:element name="CcmFifConcatStringsInCont">
                 			<xsl:element name="input_string_list">
                 				<xsl:element name="CcmFifCommandRefCont">
                 					<xsl:element name="command_id">ts_create_co_1</xsl:element>
                 					<xsl:element name="field_name">provider_tracking_no</xsl:element>							
                 				</xsl:element>
                 			</xsl:element>
                 		</xsl:element>
                 	</xsl:element>      
                 	<xsl:element name="CcmFifConcatStringsCmd">
                 		<xsl:element name="command_id">internetTerminationPTN</xsl:element>
                 		<xsl:element name="CcmFifConcatStringsInCont">
                 			<xsl:element name="input_string_list">
                 				<xsl:element name="CcmFifCommandRefCont">
                 					<xsl:element name="command_id">ts_create_co_2</xsl:element>
                 					<xsl:element name="field_name">provider_tracking_no</xsl:element>							
                 				</xsl:element>
                 			</xsl:element>
                 		</xsl:element>
                 	</xsl:element>
                 	<xsl:element name="CcmFifConcatStringsCmd">
                 		<xsl:element name="command_id">oldInternetService</xsl:element>
                 		<xsl:element name="CcmFifConcatStringsInCont">
                 			<xsl:element name="input_string_list">
                 				<xsl:element name="CcmFifCommandRefCont">
                 					<xsl:element name="command_id">find_service_1</xsl:element>
                 					<xsl:element name="field_name">service_subscription_id</xsl:element>							
                 				</xsl:element>
                 			</xsl:element>
                 		</xsl:element>
                 	</xsl:element>
                 </xsl:if>				
                 
