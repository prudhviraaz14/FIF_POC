
            <!-- Ensure that serviceSubscriptionId are provided -->
            <xsl:if test="request-param[@name='serviceSubscriptionId'] = ''">
              <xsl:element name="CcmFifRaiseErrorCmd">
                <xsl:element name="command_id">create_find_ss_error</xsl:element>
                <xsl:element name="CcmFifRaiseErrorInCont">
                  <xsl:element name="error_text">serviceSubscriptionId must be provided for the termination of the TV Center product!</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:if>

            <xsl:if test="request-param[@name='terminateDSLIndicator'] = 'N'">

              <!-- Look for the DSL service -->
              <xsl:element name="CcmFifFindServiceSubsCmd">
                <xsl:element name="command_id">find_dsl_service</xsl:element>
                <xsl:element name="CcmFifFindServiceSubsInCont">
                  <xsl:element name="service_subscription_id">
                    <xsl:value-of select="request-param[@name='DSLServiceSubscriptionId']"/>
                  </xsl:element>
                </xsl:element>
              </xsl:element>

              <!-- find an open customer order for the main service -->
              <xsl:element name="CcmFifFindCustomerOrderCmd">
                <xsl:element name="command_id">find_customer_order_1</xsl:element>
                <xsl:element name="CcmFifFindCustomerOrderInCont">
                  <xsl:element name="service_subscription_id_ref">
                    <xsl:element name="command_id">find_dsl_service</xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="state_list">
                    <xsl:element name="CcmFifPassingValueCont">
                      <xsl:element name="value">ASSIGNED</xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifPassingValueCont">
                      <xsl:element name="value">RELEASED</xsl:element>
                    </xsl:element>
                  </xsl:element>
                  <xsl:element name="allow_children">Y</xsl:element>
                  <xsl:element name="usage_mode">2</xsl:element>
                </xsl:element>
              </xsl:element>

              <!-- Reconfigure Service Subscription for DSL Product only if there's no open customer order -->
              <xsl:element name="CcmFifReconfigServiceCmd">
                <xsl:element name="command_id">reconf_sdsl_service</xsl:element>
                <xsl:element name="CcmFifReconfigServiceInCont">
                  <xsl:element name="service_subscription_ref">
                    <xsl:element name="command_id">find_dsl_service</xsl:element>
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
                    <xsl:if test="(request-param[@name='multimediaPort'] != '')">
                      <xsl:element name="CcmFifConfiguredValueCont">
                        <xsl:element name="service_char_code">I1323</xsl:element>
                        <xsl:element name="data_type">STRING</xsl:element>
                        <xsl:element name="configured_value">
                          <xsl:value-of select="request-param[@name='multimediaPort']"/>
                        </xsl:element>
                      </xsl:element>   
                    </xsl:if>
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
                    <xsl:element name="command_id">find_customer_order_1</xsl:element>
                    <xsl:element name="field_name">customer_order_found</xsl:element>
                  </xsl:element>
                  <xsl:element name="required_process_ind">N</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:if test="request-param[@name='keepMMAccessHardware'] = 'N'">
                <!-- Find Set Top Box Service -->
                <xsl:element name="CcmFifFindServiceSubsCmd">
                  <xsl:element name="command_id">find_hardware_service</xsl:element>
                  <xsl:element name="CcmFifFindServiceSubsInCont">
                    <xsl:element name="effective_date">
                      <xsl:value-of select="$TerminationDate"/>
                    </xsl:element>
                    <xsl:element name="product_subscription_id_ref">
                      <xsl:element name="command_id">find_dsl_service</xsl:element>
                      <xsl:element name="field_name">product_subscription_id</xsl:element>
                    </xsl:element>
                    <xsl:element name="service_code">I1359</xsl:element>
                    <xsl:element name="no_service_error">N</xsl:element>
                    <xsl:element name="target_state">RENTED_LEASED</xsl:element>
                  </xsl:element>
                </xsl:element>

                <!-- Reconfigure Service Subscription for DSL Product -->
                <xsl:element name="CcmFifReconfigServiceCmd">
                    <xsl:element name="command_id">reconf_hardware_service</xsl:element>
                    <xsl:element name="CcmFifReconfigServiceInCont">
                        <xsl:element name="service_subscription_ref">
                            <xsl:element name="command_id">find_hardware_service</xsl:element>
                            <xsl:element name="field_name">service_subscription_id</xsl:element>
                        </xsl:element>
                        <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                        <xsl:element name="reason_rd">AEND</xsl:element>
                        <xsl:element name="service_characteristic_list">
                            <!-- Bestellgrund-->
                            <xsl:element name="CcmFifConfiguredValueCont">
                                <xsl:element name="service_char_code">V0989</xsl:element>
                                <xsl:element name="data_type">STRING</xsl:element>
                                <xsl:element name="configured_value">Rückgabe Settop-Box</xsl:element>
                            </xsl:element>
                            <!-- I1335 Ausgleichszahlung für Settopbox bei Nichtrücksendung-->
                            <xsl:if test="request-param[@name='compensationFee']!= ''">
                                <xsl:element name="CcmFifConfiguredValueCont">
                                    <xsl:element name="service_char_code">I1335</xsl:element>
                                    <xsl:element name="data_type">STRING</xsl:element>
                                    <xsl:element name="configured_value">
                                        <xsl:value-of select="request-param[@name='compensationFee']"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>
                        </xsl:element>
                        <xsl:element name="process_ind_ref">
                            <xsl:element name="command_id">find_hardware_service</xsl:element>
                            <xsl:element name="field_name">service_found</xsl:element>
                        </xsl:element>
                        <xsl:element name="required_process_ind">Y</xsl:element>
                    </xsl:element>
                </xsl:element>

                <!-- Terminate Set Top Box Service  -->
                <xsl:element name="CcmFifTermSuspReactServiceSubsCmd">
                  <xsl:element name="command_id">terminate_hardware_service</xsl:element>
                  <xsl:element name="CcmFifTermSuspReactServiceSubsInCont">
                    <xsl:element name="service_subscription_ref">
                      <xsl:element name="command_id">find_hardware_service</xsl:element>
                      <xsl:element name="field_name">service_subscription_id</xsl:element>
                    </xsl:element>
                    <xsl:element name="usage_mode">4</xsl:element>
   					<xsl:element name="desired_date">
                      <xsl:value-of select="$TerminationDate"/>
                    </xsl:element>
                    <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
                    <xsl:element name="reason_rd">TERMINATION</xsl:element>
                    <xsl:element name="process_ind_ref">
                      <xsl:element name="command_id">find_hardware_service</xsl:element>
                      <xsl:element name="field_name">service_found</xsl:element>
                    </xsl:element>
                    <xsl:element name="required_process_ind">Y</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:if>

              <!-- Create Customer Order for the reconfiguration + termination of the hardware  -->
              <xsl:element name="CcmFifCreateCustOrderCmd">
                <xsl:element name="command_id">create_dsl_co</xsl:element>
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
                      <xsl:otherwise>001hs</xsl:otherwise>
                    </xsl:choose>
                  </xsl:element>
                  <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
                  <xsl:element name="service_ticket_pos_list">
                    <xsl:element name="CcmFifCommandRefCont">
                      <xsl:element name="command_id">reconf_sdsl_service</xsl:element>
                      <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                    </xsl:element>
                     <xsl:element name="CcmFifCommandRefCont">
                         <xsl:element name="command_id">reconf_hardware_service</xsl:element>
                         <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                     </xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>

              <!-- Create Customer Order for the reconfiguration + termination of the hardware  -->
              <xsl:element name="CcmFifCreateCustOrderCmd">
                <xsl:element name="command_id">create_settopbox_term_co</xsl:element>
                <xsl:element name="CcmFifCreateCustOrderInCont">
                  <xsl:element name="customer_number">
                    <xsl:value-of select="request-param[@name='customerNumber']"/>
                  </xsl:element>
                  <xsl:element name="customer_tracking_id">
                    <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                  </xsl:element>
                  <xsl:element name="provider_tracking_no">
                    <xsl:choose>
                      <xsl:when test="request-param[@name='providerTrackingNumberMainAccessDefault'] != ''">
                        <xsl:value-of select="request-param[@name='providerTrackingNumberMainAccessDefault']" />
                      </xsl:when>
                      <xsl:otherwise>002hs</xsl:otherwise>
                    </xsl:choose>
                  </xsl:element>
                  <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
                  <xsl:element name="service_ticket_pos_list">
                    <xsl:element name="CcmFifCommandRefCont">
                      <xsl:element name="command_id">terminate_hardware_service</xsl:element>
                      <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>

              <!-- Release Customer Order -->
              <xsl:element name="CcmFifReleaseCustOrderCmd">
                <xsl:element name="CcmFifReleaseCustOrderInCont">
                  <xsl:element name="customer_number">
                    <xsl:value-of select="request-param[@name='customerNumber']"/>
                  </xsl:element>
                  <xsl:element name="customer_order_ref">
                    <xsl:element name="command_id">create_dsl_co</xsl:element>
                    <xsl:element name="field_name">customer_order_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
                </xsl:element>
              </xsl:element>

                <!-- Release Customer Order -->
                <xsl:element name="CcmFifReleaseCustOrderCmd">
                    <xsl:element name="CcmFifReleaseCustOrderInCont">
                        <xsl:element name="customer_number">
                            <xsl:value-of select="request-param[@name='customerNumber']"/>
                        </xsl:element>
                        <xsl:element name="customer_order_ref">
                            <xsl:element name="command_id">create_settopbox_term_co</xsl:element>
                            <xsl:element name="field_name">customer_order_id</xsl:element>
                        </xsl:element>
                        <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
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
                        <xsl:element name="service_char_code">I1331</xsl:element>
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

            <!-- Create Customer Order for Reconfiguration -->
            <xsl:element name="CcmFifCreateCustOrderCmd">
              <xsl:element name="command_id">create_co_1</xsl:element>
              <xsl:element name="CcmFifCreateCustOrderInCont">
                    <xsl:element name="customer_number">
                      <xsl:value-of select="request-param[@name='customerNumber']"/>
                    </xsl:element>
                    <xsl:element name="customer_tracking_id">
                      <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                    </xsl:element>
                <xsl:element name="provider_tracking_no">
                  <xsl:choose>
                    <xsl:when test="request-param[@name='providerTrackingNumberChange'] != ''">
                      <xsl:value-of select="request-param[@name='providerTrackingNumberChange']" />
                    </xsl:when>
                    <xsl:when test="request-param[@name='providerTrackingNumberTVCenterChange'] != ''">
                      <xsl:value-of select="request-param[@name='providerTrackingNumberTVCenterChange']" />
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
                    <xsl:when test="request-param[@name='providerTrackingNumberTVCenterDefault'] != ''">
                      <xsl:value-of select="request-param[@name='providerTrackingNumberTVCenterDefault']" />
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



