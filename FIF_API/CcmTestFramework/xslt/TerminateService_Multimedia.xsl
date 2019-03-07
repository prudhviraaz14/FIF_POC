  
            <!-- Ensure that serviceSubscriptionId are provided -->
            <xsl:if test="request-param[@name='serviceSubscriptionId'] = ''">
              <xsl:element name="CcmFifRaiseErrorCmd">
                <xsl:element name="command_id">create_find_ss_error</xsl:element>
                <xsl:element name="CcmFifRaiseErrorInCont">
                  <xsl:element name="error_text">serviceSubscriptionId musst be provided for the termination of the Multimedia product!</xsl:element>
                </xsl:element>
              </xsl:element>
          </xsl:if>

            <!-- Look for the Multimedia service -->    
            <xsl:element name="CcmFifFindServiceSubsCmd">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="CcmFifFindServiceSubsInCont">
                <xsl:element name="service_subscription_id">
                  <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
                </xsl:element>
                <xsl:element name="effective_date">
                  <xsl:value-of select="$TerminationDate"/>
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
                    <xsl:element name="contract_number">
                      <xsl:value-of select="request-param[@name='contractNumber']"/>
                    </xsl:element>
                    <xsl:element name="termination_date">
                      <xsl:value-of select="$TerminationDate"/>
                    </xsl:element>
                    <xsl:element name="notice_per_start_date">
                      <xsl:value-of select="request-param[@name='noticePeriodStartDate']"/>
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
                      <!-- Grund der Neukonfiguration -->
                      <xsl:element name="CcmFifConfiguredValueCont">
                        <xsl:element name="service_char_code">I1312</xsl:element>
                        <xsl:element name="data_type">STRING</xsl:element>
                        <xsl:element name="configured_value">Vorbereitung zur Kündigung</xsl:element>
                      </xsl:element>	
                      <!-- Aktivierungsdatum -->
                      <xsl:element name="CcmFifConfiguredValueCont">
                        <xsl:element name="service_char_code">V0909</xsl:element>
                        <xsl:element name="data_type">STRING</xsl:element>
                        <xsl:element name="configured_value">
                        	<xsl:value-of select="$terminationDateOPM"/>
                        </xsl:element>
                      </xsl:element>                     
                      <!-- Kündigungsbrief-Versand -->
                      <xsl:if test="(request-param[@name='sendConfirmationLetter'] = 'N')">
                        <xsl:element name="CcmFifConfiguredValueCont">
                          <xsl:element name="service_char_code">V0580</xsl:element>
                          <xsl:element name="data_type">STRING</xsl:element>
                          <xsl:element name="configured_value">Nein</xsl:element>
                        </xsl:element>
                      </xsl:if>
                      <!-- Auftragsvariante  -->
                      <xsl:element name="CcmFifConfiguredValueCont">
                        <xsl:element name="service_char_code">I1311</xsl:element>
                        <xsl:element name="data_type">STRING</xsl:element>                                                                      
                        <xsl:element name="configured_value">
                          <xsl:value-of select="$OrderVariant"/>
                        </xsl:element>    
                      </xsl:element>
                      <!-- Bearbeitungsart -->
                      <xsl:element name="CcmFifConfiguredValueCont">
                        <xsl:element name="service_char_code">VI002</xsl:element>
                        <xsl:element name="data_type">STRING</xsl:element>
                        <xsl:element name="configured_value">OP</xsl:element>
                      </xsl:element>				
                    </xsl:element>
                <xsl:element name="detailed_reason_ref">
                  <xsl:element name="command_id">clone_order_form_1</xsl:element>
                  <xsl:element name="field_name">detailed_reason_rd</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>

            <!-- Add Termination Fee Service -->
            <xsl:if test="request-param[@name='terminationFeeServiceCode'] != ''">
              <xsl:element name="CcmFifAddServiceSubsCmd">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="CcmFifAddServiceSubsInCont">
                  <xsl:element name="product_subscription_ref">
                    <xsl:element name="command_id">find_service_1</xsl:element>
                    <xsl:element name="field_name">product_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="service_code">
                    <xsl:value-of select="request-param[@name='terminationFeeServiceCode']"/>
                  </xsl:element>
                  <xsl:element name="parent_service_subs_ref">
                    <xsl:element name="command_id">find_service_1</xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                  <xsl:element name="reason_rd">
                    <xsl:value-of select="$ReasonRd"/>
                  </xsl:element>
                  
                  <xsl:element name="account_number_ref">
                    <xsl:element name="command_id">find_service_1</xsl:element>
                    <xsl:element name="field_name">account_number</xsl:element>
                  </xsl:element>
                  
                  <xsl:element name="service_characteristic_list">
                  </xsl:element>
                </xsl:element>
              </xsl:element>
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

            <xsl:if test="request-param[@name='terminateNGNIndicator'] != 'Y'">     

              <xsl:element name="CcmFifReadExternalNotificationCmd">
                <xsl:element name="command_id">read_external_notification_1</xsl:element>
                <xsl:element name="CcmFifReadExternalNotificationInCont">
                  <xsl:element name="transaction_id">
                    <xsl:value-of select="request-param[@name='requestListId']"/>
                  </xsl:element>
                  <xsl:element name="parameter_name">NGNDSL_SERVICE_SUBSCRIPTION_ID</xsl:element> 
                  <xsl:element name="ignore_empty_result">Y</xsl:element>                        
                </xsl:element>
              </xsl:element>
              
              <xsl:element name="CcmFifFindServiceSubsCmd">
                <xsl:element name="command_id">find_service_2</xsl:element>
                <xsl:element name="CcmFifFindServiceSubsInCont">
                  <xsl:element name="service_subscription_id_ref">
                    <xsl:element name="command_id">read_external_notification_1</xsl:element>
                    <xsl:element name="field_name">parameter_value</xsl:element>
                  </xsl:element>
                  <xsl:element name="effective_date">
                    <xsl:value-of select="$TerminationDate"/>
                  </xsl:element>
                  <xsl:element name="process_ind_ref">
                    <xsl:element name="command_id">read_external_notification_1</xsl:element>
                    <xsl:element name="field_name">value_found</xsl:element>            	
                  </xsl:element>
                  <xsl:element name="required_process_ind">Y</xsl:element>                   
                </xsl:element>
              </xsl:element>    
              
              <!-- look for a NGN-DSL bundle (item) -->
              <xsl:element name="CcmFifFindBundleCmd">
                <xsl:element name="command_id">find_bundle_1</xsl:element>
                <xsl:element name="CcmFifFindBundleInCont">
                  <xsl:element name="supported_object_id_ref">
                    <xsl:element name="command_id">find_service_1</xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
                  <xsl:element name="process_ind_ref">
                    <xsl:element name="command_id">read_external_notification_1</xsl:element>
                    <xsl:element name="field_name">value_found</xsl:element>            	
                  </xsl:element>
                  <xsl:element name="required_process_ind">N</xsl:element>   
                </xsl:element>
              </xsl:element>


              <!-- look for an NGN DSL service in that bundle -->
              <xsl:element name="CcmFifFindBundleCmd">
                <xsl:element name="command_id">find_bundle_2</xsl:element>
                <xsl:element name="CcmFifFindBundleInCont">
                  <xsl:element name="bundle_id_ref">
                    <xsl:element name="command_id">find_bundle_1</xsl:element>
                    <xsl:element name="field_name">bundle_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="bundle_item_type_rd">ACCESS</xsl:element>
                  <xsl:element name="process_ind_ref">
                    <xsl:element name="command_id">read_external_notification_1</xsl:element>
                    <xsl:element name="field_name">value_found</xsl:element>            	
                  </xsl:element>
                  <xsl:element name="required_process_ind">N</xsl:element>   
                </xsl:element>
              </xsl:element>
              
              <!-- Find NGN DSL Service Subscription by bundled SS id, if a bundle was found -->
              <xsl:element name="CcmFifFindServiceSubsCmd">
                <xsl:element name="command_id">find_service_2</xsl:element>
                <xsl:element name="CcmFifFindServiceSubsInCont">
                  <xsl:element name="service_subscription_id_ref">
                    <xsl:element name="command_id">find_bundle_2</xsl:element>
                    <xsl:element name="field_name">supported_object_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="effective_date">
                    <xsl:value-of select="$TerminationDate"/>
                  </xsl:element>
                  <xsl:element name="process_ind_ref">
                    <xsl:element name="command_id">read_external_notification_1</xsl:element>
                    <xsl:element name="field_name">value_found</xsl:element>            	
                  </xsl:element>
                  <xsl:element name="required_process_ind">N</xsl:element> 
                </xsl:element>
              </xsl:element>
                                                              
              <!-- Reconfigure Service Subscription : For NGN Product -->
              <xsl:element name="CcmFifReconfigServiceCmd">
                <xsl:element name="command_id">reconf_serv_2</xsl:element>
                <xsl:element name="CcmFifReconfigServiceInCont">
                  <xsl:element name="service_subscription_ref">
                    <xsl:element name="command_id">find_service_2</xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                  <xsl:element name="reason_rd">AEND</xsl:element>
                  <xsl:element name="service_characteristic_list">
                    <!-- Reason for reconfiguration -->
                    <xsl:element name="CcmFifConfiguredValueCont">
                      <xsl:element name="service_char_code">V0943</xsl:element>
                      <xsl:element name="data_type">STRING</xsl:element>
                      <xsl:element name="configured_value">MM-Änderung</xsl:element>
                    </xsl:element>
                    <!-- Multimedia-VC -->
                    <xsl:element name="CcmFifConfiguredValueCont">
                      <xsl:element name="service_char_code">I1323</xsl:element>
                      <xsl:element name="data_type">STRING</xsl:element>
                      <xsl:element name="configured_value">nein</xsl:element>
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
                    <!-- Kündigungsbrief-Versand -->
                    <xsl:if test="(request-param[@name='sendConfirmationLetter'] = 'N')">
                      <xsl:element name="CcmFifConfiguredValueCont">
                        <xsl:element name="service_char_code">V0580</xsl:element>
                        <xsl:element name="data_type">STRING</xsl:element>
                        <xsl:element name="configured_value">Nein</xsl:element>
                      </xsl:element>
                    </xsl:if>
                  </xsl:element>  
                  <xsl:element name="process_ind_ref">
                    <xsl:element name="command_id">read_external_notification_1</xsl:element>
                    <xsl:element name="field_name">value_found</xsl:element>            	
                  </xsl:element>
                  <xsl:element name="required_process_ind">N</xsl:element>          
                </xsl:element>
              </xsl:element> 
                    
              <!-- Create Customer Order reconfigure NGN-DSL  -->        
              <xsl:element name="CcmFifCreateCustOrderCmd">
                <xsl:element name="command_id">create_co_4</xsl:element>
                <xsl:element name="CcmFifCreateCustOrderInCont">
                  <xsl:element name="customer_number">
                    <xsl:value-of select="request-param[@name='customerNumber']"/>
                  </xsl:element>
                  <xsl:element name="customer_tracking_id">
                    <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                  </xsl:element>
                  <xsl:element name="provider_tracking_no">
                    <xsl:choose>
                      <xsl:when test="request-param[@name='providerTrackingNumberMainAccessChange'] != ''">
                        <xsl:value-of select="request-param[@name='providerTrackingNumberMainAccessChange']" />
                      </xsl:when>
                      <xsl:otherwise>001</xsl:otherwise>
                    </xsl:choose>
                  </xsl:element>			  	
                  <xsl:element name="service_ticket_pos_list">
                    <!-- I1210 -->
                    <xsl:element name="CcmFifCommandRefCont">
                      <xsl:element name="command_id">reconf_serv_2</xsl:element>
                      <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                    </xsl:element>                                 
                  </xsl:element> 
                  <xsl:element name="process_ind_ref">
                    <xsl:element name="command_id">read_external_notification_1</xsl:element>
                    <xsl:element name="field_name">value_found</xsl:element>            	
                  </xsl:element>
                  <xsl:element name="required_process_ind">N</xsl:element>           
                </xsl:element>
              </xsl:element>
                      
              <!-- Release Customer Order for Reconfiguration -->                            
              <xsl:element name="CcmFifReleaseCustOrderCmd">
                <xsl:element name="CcmFifReleaseCustOrderInCont">
                  <xsl:element name="customer_number">
                    <xsl:value-of select="request-param[@name='customerNumber']"/>
                  </xsl:element>
                  <xsl:element name="customer_order_ref">
                    <xsl:element name="command_id">create_co_4</xsl:element>
                    <xsl:element name="field_name">customer_order_id</xsl:element>
                  </xsl:element>  
                  <xsl:element name="process_ind_ref">
                    <xsl:element name="command_id">read_external_notification_1</xsl:element>
                    <xsl:element name="field_name">value_found</xsl:element>            	
                  </xsl:element>
                  <xsl:element name="required_process_ind">N</xsl:element>                   
                </xsl:element>
              </xsl:element>       
            </xsl:if>
 
            <!-- Create Customer Order for Reconfiguration -->
            <xsl:element name="CcmFifCreateCustOrderCmd">
              <xsl:element name="command_id">create_co_1</xsl:element>
              <xsl:element name="CcmFifCreateCustOrderInCont">
                    <xsl:element name="customer_number">
                      <xsl:value-of select="request-param[@name='customerNumber']"/>
                    </xsl:element>
                    <xsl:if test="$OrderVariant = 'MM-Produktwechsel'">
                      <xsl:element name="parent_customer_order_ref">
                        <xsl:element name="command_id">create_co_mm_1</xsl:element>
                        <xsl:element name="field_name">customer_order_id</xsl:element>
                      </xsl:element>  
                    </xsl:if>              
                    <xsl:element name="customer_tracking_id">
                      <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                    </xsl:element>
                <xsl:element name="provider_tracking_no">
                  <xsl:choose>
                    <xsl:when test="request-param[@name='providerTrackingNumberChange'] != ''">
                      <xsl:value-of select="request-param[@name='providerTrackingNumberChange']" />
                    </xsl:when>
                    <xsl:otherwise>001h</xsl:otherwise>
                  </xsl:choose>
                </xsl:element>			  	
                    <xsl:element name="service_ticket_pos_list">
                      <xsl:element name="CcmFifCommandRefCont">
                            <xsl:element name="command_id">reconf_serv_1</xsl:element>
                            <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                      </xsl:element>
                    </xsl:element>
              </xsl:element>
            </xsl:element>

            <!-- Create Customer Order for Add Service -->
            <xsl:if test="request-param[@name='terminationFeeServiceCode'] != ''">
              <xsl:element name="CcmFifCreateCustOrderCmd">
                <xsl:element name="command_id">create_co_3</xsl:element>
                <xsl:element name="CcmFifCreateCustOrderInCont">
                  <xsl:element name="customer_number">
                    <xsl:value-of select="request-param[@name='customerNumber']"/>
                  </xsl:element>
                  <xsl:element name="parent_customer_order_ref">
                    <xsl:element name="command_id">create_co_1</xsl:element>
                    <xsl:element name="field_name">customer_order_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="customer_tracking_id">
                    <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                  </xsl:element>
                  <xsl:element name="service_ticket_pos_list">
                    <xsl:element name="CcmFifCommandRefCont">
                      <xsl:element name="command_id">add_service_1</xsl:element>
                      <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:if>

            <!-- Create Customer Order for Termination -->
            <xsl:element name="CcmFifCreateCustOrderCmd">
              <xsl:element name="command_id">create_co_2</xsl:element>
              <xsl:element name="CcmFifCreateCustOrderInCont">
                    <xsl:element name="customer_number">
                      <xsl:value-of select="request-param[@name='customerNumber']"/>
                    </xsl:element>
                    <xsl:element name="parent_customer_order_ref">
                      <xsl:element name="command_id">create_co_1</xsl:element>
                      <xsl:element name="field_name">customer_order_id</xsl:element>
                    </xsl:element>
                    <xsl:element name="customer_tracking_id">
                      <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                    </xsl:element>
                <xsl:element name="provider_tracking_no">
                  <xsl:choose>
                    <xsl:when test="request-param[@name='providerTrackingNumberDefault'] != ''">
                      <xsl:value-of select="request-param[@name='providerTrackingNumberDefault']" />
                    </xsl:when>
                    <xsl:otherwise>002h</xsl:otherwise>
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
                <xsl:element name="customer_number">
                  <xsl:value-of select="request-param[@name='customerNumber']"/>
                </xsl:element>
                <xsl:element name="customer_order_ref">
                  <xsl:element name="command_id">create_co_1</xsl:element>
                  <xsl:element name="field_name">customer_order_id</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            
            <!-- Release Customer Order for Add Service -->
            <xsl:if test="request-param[@name='terminationFeeServiceCode'] != ''">
              <xsl:element name="CcmFifReleaseCustOrderCmd">
                <xsl:element name="CcmFifReleaseCustOrderInCont">
                  <xsl:element name="customer_number">
                    <xsl:value-of select="request-param[@name='customerNumber']"/>
                  </xsl:element>
                  <xsl:element name="customer_order_ref">
                    <xsl:element name="command_id">create_co_3</xsl:element>
                    <xsl:element name="field_name">customer_order_id</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            
            <!-- Release Customer Order for Termination -->
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

            
           <!-- Create Contact for the Service Termination-->
           <xsl:element name="CcmFifCreateContactCmd">
              <xsl:element name="CcmFifCreateContactInCont">
                    <xsl:element name="customer_number">
                      <xsl:value-of select="request-param[@name='customerNumber']"/>
                    </xsl:element>
                    <xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
                    <xsl:element name="short_description">Automatische Kündigung</xsl:element>
                    <xsl:element name="long_description_text">
                      <xsl:text>TransactionID: </xsl:text>
                      <xsl:value-of select="request-param[@name='transactionID']"/>
                      <xsl:text>&#xA;User name: </xsl:text>
                      <xsl:value-of select="request-param[@name='userName']"/>
                      <xsl:text>&#xA;ContractNumber: </xsl:text>
                      <xsl:value-of select="request-param[@name='contractNumber']"/>
                      <xsl:text>&#xA;TerminationReason: </xsl:text>
                      <xsl:value-of select="$TerminationReason"/>
                      <xsl:text>&#xA;DeactivateOnlineAccount: Y</xsl:text>
                      <xsl:text>&#xA;SendConfirmationLetter: </xsl:text>
                      <xsl:if test="($TerminationReason = 'ZTCOM') or ($TerminationReason = 'UMZN')">N</xsl:if>
                      <xsl:if test="($TerminationReason != 'ZTCOM') and ($TerminationReason != 'UMZN')">
                            <xsl:value-of select="request-param[@name='sendConfirmationLetter']"/>
                  </xsl:if>
                      <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
                      <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
                    </xsl:element>
              </xsl:element>
            </xsl:element>
           

         
