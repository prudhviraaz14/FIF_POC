		<!-- Look for the mobile service -->    
		<xsl:element name="CcmFifFindServiceSubsCmd">
			<xsl:element name="command_id">find_mobile_service</xsl:element>
			<xsl:element name="CcmFifFindServiceSubsInCont">
				<xsl:element name="service_subscription_id">
					<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
				</xsl:element>
				<xsl:element name="effective_date">
					<xsl:value-of select="$TerminationDate"/>
				</xsl:element>           
			</xsl:element>
		</xsl:element>

		<!-- Get PC data to retrieve the current tariff -->
		<xsl:element name="CcmFifGetProductCommitmentDataCmd">
			<xsl:element name="command_id">get_tariff</xsl:element>
			<xsl:element name="CcmFifGetProductCommitmentDataInCont">
				<xsl:element name="product_commitment_number_ref">
					<xsl:element name="command_id">find_mobile_service</xsl:element>
					<xsl:element name="field_name">product_commitment_number</xsl:element>
				</xsl:element>
				<xsl:element name="retrieve_signed_version">Y</xsl:element>
			</xsl:element>
		</xsl:element>

		<!-- check for a monthly fee service below the mobile service -->
		<xsl:element name="CcmFifFindServiceSubsCmd">
			<xsl:element name="command_id">find_monthly_fee_service</xsl:element>
			<xsl:element name="CcmFifFindServiceSubsInCont">
				<xsl:element name="product_subscription_id_ref">
					<xsl:element name="command_id">find_mobile_service</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>							
				</xsl:element>
				<xsl:element name="service_code">V8033</xsl:element>
				<xsl:element name="no_service_error">N</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">get_tariff</xsl:element>
					<xsl:element name="field_name">pricing_structure_code</xsl:element>
				</xsl:element>
				<xsl:element name="required_process_ind">V8004</xsl:element>
			</xsl:element>
		</xsl:element>
		
		<!-- check if there is another V8004 service (except) -->
		<xsl:element name="CcmFifFindServiceSubsCmd">
			<xsl:element name="command_id">find_service_for_tariff_V8004</xsl:element>
			<xsl:element name="CcmFifFindServiceSubsInCont">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">find_mobile_service</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>							
				</xsl:element>
				<xsl:element name="product_code">V8000</xsl:element>
				<xsl:element name="pricing_structure_code">V8004</xsl:element>
				<xsl:element name="service_code">V8000</xsl:element>
				<xsl:element name="no_service_error">N</xsl:element>          
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">find_monthly_fee_service</xsl:element>
					<xsl:element name="field_name">service_found</xsl:element>
				</xsl:element>
				<xsl:element name="required_process_ind">Y</xsl:element>				
				<xsl:element name="excluded_services">
					<xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">find_mobile_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
				</xsl:element>
				<xsl:element name="retrieve_signed_version">Y</xsl:element>
			</xsl:element>
		</xsl:element>
		
		<!-- add the fee service for another mobile service -->
		<xsl:element name="CcmFifAddServiceSubsCmd">
			<xsl:element name="command_id">add_additional_fee_service</xsl:element>
			<xsl:element name="CcmFifAddServiceSubsInCont">
				<xsl:element name="product_subscription_ref">
					<xsl:element name="command_id">find_service_for_tariff_V8004</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="service_code">V8033</xsl:element>
				<xsl:element name="parent_service_subs_ref">
					<xsl:element name="command_id">find_service_for_tariff_V8004</xsl:element>
					<xsl:element name="field_name">service_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="desired_date">
					<xsl:value-of select="dateutils:createFIFDateOffset($TerminationDate, 'DATE', '1')"/>
				</xsl:element>
				<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
				<xsl:element name="reason_rd">TERMINATION</xsl:element>        
				<xsl:element name="account_number_ref">
					<xsl:element name="command_id">find_service_for_tariff_V8004</xsl:element>
					<xsl:element name="field_name">account_number</xsl:element>
				</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">find_service_for_tariff_V8004</xsl:element>
					<xsl:element name="field_name">service_found</xsl:element>
				</xsl:element>
				<xsl:element name="required_process_ind">Y</xsl:element>
				<xsl:element name="service_characteristic_list"/>
			</xsl:element>
		</xsl:element>              

		<!-- Ensure that the termination has not been performed before -->
		<xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
			<xsl:element name="command_id">find_cancel_stp_mobile_1</xsl:element>
			<xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
				<xsl:element name="product_subscription_ref">
					<xsl:element name="command_id">find_mobile_service</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="reason_rd">TERMINATION</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">find_mobile_service</xsl:element>
					<xsl:element name="field_name">service_found</xsl:element>           
				</xsl:element>
				<xsl:element name="required_process_ind">Y</xsl:element>						
			</xsl:element>
		</xsl:element>

		<!-- Terminate Order Form -->			
		<xsl:element name="CcmFifTerminateOrderFormCmd">
			<xsl:element name="command_id">terminate_of_mobile_1</xsl:element>
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
			<xsl:element name="command_id">reconf_serv_mobile_1</xsl:element>
			<xsl:element name="CcmFifReconfigServiceInCont">
				<xsl:element name="service_subscription_ref">
					<xsl:element name="command_id">find_mobile_service</xsl:element>
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
					<!-- Aktivierungsdatum -->
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">V0909</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>
						<xsl:element name="configured_value">
							<xsl:value-of select="$terminationDateOPM"/>
						</xsl:element>
					</xsl:element>						 
				</xsl:element>	
			</xsl:element>
		</xsl:element>		
		
		<!-- Add Termination Fee Service -->
		<xsl:if test="request-param[@name='terminationFeeServiceCode'] != ''">
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_term_fee_service_1</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_mobile_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">
						<xsl:value-of select="request-param[@name='terminationFeeServiceCode']"/>
					</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">find_mobile_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="$ReasonRd"/>
					</xsl:element>
					
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_mobile_service</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>
					</xsl:element>
					
					<xsl:element name="service_characteristic_list">
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>		  
		
		<!-- Terminate the online Product Subscription -->
		<xsl:element name="CcmFifTerminateProductSubsCmd">
			<xsl:element name="command_id">terminate_ps_mobile_1</xsl:element>
			<xsl:element name="CcmFifTerminateProductSubsInCont">
				<xsl:element name="product_subscription_ref">
					<xsl:element name="command_id">find_mobile_service</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="desired_date">
					<xsl:value-of select="$TerminationDate"/>
				</xsl:element>
				<xsl:element name="desired_schedule_type">END_BEFORE</xsl:element>
				<xsl:element name="reason_rd">TERMINATION</xsl:element>
				<xsl:element name="auto_customer_order">N</xsl:element>	
			</xsl:element>
		</xsl:element>

		<!-- get the next available PTN -->
		<xsl:element name="CcmFifGetNextAvailableProviderTrackingNumberCmd">
			<xsl:element name="command_id">get_reconfigure_ptn</xsl:element>
			<xsl:element name="CcmFifGetNextAvailableProviderTrackingNumberInCont">
				<xsl:element name="customer_tracking_id">
					<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
				</xsl:element>
				<xsl:element name="provider_tracking_number_suffix">m</xsl:element>
			</xsl:element>
		</xsl:element>
		
		<!-- Create Customer Order for Reconf. of the mobile product -->
		<xsl:element name="CcmFifCreateCustOrderCmd">
			<xsl:element name="command_id">create_co_1</xsl:element>
			<xsl:element name="CcmFifCreateCustOrderInCont">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">find_mobile_service</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>
				</xsl:element>
				<xsl:element name="customer_tracking_id">
					<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
				</xsl:element>					
				<xsl:choose>
					<xsl:when test="request-param[@name='providerTrackingNumberChange'] != ''">
						<xsl:element name="provider_tracking_no">
							<xsl:value-of select="request-param[@name='providerTrackingNumberChange']" />
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="provider_tracking_no_ref">
							<xsl:element name="command_id">get_reconfigure_ptn</xsl:element>
							<xsl:element name="field_name">provider_tracking_number</xsl:element>
						</xsl:element>						
					</xsl:otherwise>
				</xsl:choose>				
				<xsl:element name="service_ticket_pos_list">
					<xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">reconf_serv_mobile_1</xsl:element>
						<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
					</xsl:element>
				</xsl:element>			
			</xsl:element>
		</xsl:element>
		
		<!-- Release Customer Order for Reconf. of the mobile PS-->
		<xsl:element name="CcmFifReleaseCustOrderCmd">
			<xsl:element name="CcmFifReleaseCustOrderInCont">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">find_mobile_service</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>
				</xsl:element>
				<xsl:element name="customer_order_ref">
					<xsl:element name="command_id">create_co_1</xsl:element>
					<xsl:element name="field_name">customer_order_id</xsl:element>
				</xsl:element>	
			</xsl:element>					
		</xsl:element>
		
		<!-- Create Customer Order for Add Service -->
		<xsl:if test="request-param[@name='terminationFeeServiceCode'] != ''">
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_4</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_mobile_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
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
							<xsl:element name="command_id">add_term_fee_service_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_mobile_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_4</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>		  
		
		<!-- get the next available PTN -->
		<xsl:element name="CcmFifGetNextAvailableProviderTrackingNumberCmd">
			<xsl:element name="command_id">get_terminate_ptn</xsl:element>
			<xsl:element name="CcmFifGetNextAvailableProviderTrackingNumberInCont">
				<xsl:element name="customer_tracking_id">
					<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
				</xsl:element>
				<xsl:element name="provider_tracking_number_suffix">m</xsl:element>
			</xsl:element>
		</xsl:element>
		
		<!-- Create Customer Order for Termination of the mobile product -->
		<xsl:element name="CcmFifCreateCustOrderCmd">
			<xsl:element name="command_id">create_co_2</xsl:element>
			<xsl:element name="CcmFifCreateCustOrderInCont">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">find_mobile_service</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>
				</xsl:element>
				<xsl:element name="parent_customer_order_ref">
					<xsl:element name="command_id">create_co_1</xsl:element>
					<xsl:element name="field_name">customer_order_id</xsl:element>
				</xsl:element>
				<xsl:element name="customer_tracking_id">
					<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
				</xsl:element>						
				<xsl:choose>
					<xsl:when test="request-param[@name='providerTrackingNumberDefault'] != ''">
						<xsl:element name="provider_tracking_no">
							<xsl:value-of select="request-param[@name='providerTrackingNumberDefault']" />
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="provider_tracking_no_ref">
							<xsl:element name="command_id">get_terminate_ptn</xsl:element>
							<xsl:element name="field_name">provider_tracking_number</xsl:element>
						</xsl:element>						
					</xsl:otherwise>
				</xsl:choose>				
				<xsl:element name="service_ticket_pos_list">
					<xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">terminate_ps_mobile_1</xsl:element>
						<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
					</xsl:element>
				</xsl:element>				
			</xsl:element>
		</xsl:element>			
		
		<!-- Release Customer Order for Termination of the mobile PS-->
		<xsl:element name="CcmFifReleaseCustOrderCmd">
			<xsl:element name="CcmFifReleaseCustOrderInCont">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">find_mobile_service</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>
				</xsl:element>
				<xsl:element name="customer_order_ref">
					<xsl:element name="command_id">create_co_2</xsl:element>
					<xsl:element name="field_name">customer_order_id</xsl:element>
				</xsl:element>				
			</xsl:element>					
		</xsl:element>
		
		<!-- Create Customer Order for Termination of the mobile product -->
		<xsl:element name="CcmFifCreateCustOrderCmd">
			<xsl:element name="command_id">create_co_3</xsl:element>
			<xsl:element name="CcmFifCreateCustOrderInCont">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">find_mobile_service</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>
				</xsl:element>
				<xsl:element name="parent_customer_order_ref">
					<xsl:element name="command_id">create_co_2</xsl:element>
					<xsl:element name="field_name">customer_order_id</xsl:element>
				</xsl:element>
				<xsl:element name="customer_tracking_id">
					<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
				</xsl:element>
				<xsl:element name="ignore_empty_list_ind">Y</xsl:element>			
				<xsl:element name="service_ticket_pos_list">
					<xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">add_additional_fee_service</xsl:element>
						<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
					</xsl:element>
				</xsl:element>				
			</xsl:element>
		</xsl:element>
		
		<!-- Release Customer Order for Termination of the mobile PS-->
		<xsl:element name="CcmFifReleaseCustOrderCmd">
			<xsl:element name="CcmFifReleaseCustOrderInCont">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">find_mobile_service</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>
				</xsl:element>
				<xsl:element name="customer_order_ref">
					<xsl:element name="command_id">create_co_3</xsl:element>
					<xsl:element name="field_name">customer_order_id</xsl:element>
				</xsl:element>	
				<xsl:element name="ignore_empty_list_ind">Y</xsl:element>			
			</xsl:element>					
		</xsl:element>
		
		<!-- Create Contact for the termination of the rabate product -->
		<xsl:element name="CcmFifCreateContactCmd">
			<xsl:element name="CcmFifCreateContactInCont">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">find_mobile_service</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>
				</xsl:element>
				<xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
				<xsl:element name="short_description">Automatische Kündigung</xsl:element>
				<xsl:element name="description_text_list">
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="contact_text">
							<xsl:text>TransactionID: </xsl:text>
							<xsl:value-of select="request-param[@name='transactionID']"/>
							<xsl:text>&#xA;User name: </xsl:text>
							<xsl:value-of select="request-param[@name='userName']"/>
							<xsl:text>&#xA;TerminationReason: </xsl:text>
							<xsl:value-of select="$TerminationReason"/>
							<xsl:text>&#xA;ContractNumber : </xsl:text>
						</xsl:element> 
					</xsl:element>
					<xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">find_mobile_service</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
