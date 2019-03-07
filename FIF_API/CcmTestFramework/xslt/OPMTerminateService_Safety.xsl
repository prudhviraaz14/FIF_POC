			<!-- look for a Safety Package bundle (item) -->
			<xsl:element name="CcmFifFindBundleCmd">
				<xsl:element name="command_id">find_bundle_sec_1</xsl:element>
				<xsl:element name="CcmFifFindBundleInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">find_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>          
					<xsl:element name="bundle_item_type_rd">SOFTWARE</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>          	
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Find online SS ID by bundled SS id, if a bundle was found -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_service_sec_1</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_bundle_sec_1</xsl:element>
						<xsl:element name="field_name">supported_object_id</xsl:element>
					</xsl:element>
					<xsl:element name="effective_date">
						<xsl:value-of select="$TerminationDate"/>
					</xsl:element>                  
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_bundle_sec_1</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>           
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Ensure that the termination has not been performed before -->
			<xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
				<xsl:element name="command_id">find_cancel_stp_sec_1</xsl:element>
				<xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_service_sec_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="reason_rd">TERMINATION</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_bundle_sec_1</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>           
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Terminate Order Form -->
			<xsl:element name="CcmFifTerminateOrderFormCmd">
				<xsl:element name="command_id">terminate_of_sec_1</xsl:element>
				<xsl:element name="CcmFifTerminateOrderFormInCont">
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">find_service_sec_1</xsl:element>
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
						<xsl:element name="command_id">find_bundle_sec_1</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>           
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>			  	
				</xsl:element>
			</xsl:element>
		
			<!-- Terminate the online Product Subscription -->
			<xsl:element name="CcmFifTerminateProductSubsCmd">
				<xsl:element name="command_id">terminate_ps_sec_1</xsl:element>
				<xsl:element name="CcmFifTerminateProductSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_service_sec_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$TerminationDate"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">END_BEFORE</xsl:element>
					<xsl:element name="reason_rd">TERMINATION</xsl:element>
					<xsl:element name="auto_customer_order">N</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_bundle_sec_1</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>           
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
	
			<!-- Create Customer Order for Termination of the safety package product -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_sec_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="parent_customer_order_ref">
						<xsl:element name="command_id">create_co_term_1</xsl:element>
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
					<xsl:element name="provider_tracking_no">002fd</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_ps_sec_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_bundle_sec_1</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>           
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>					
				</xsl:element>
			</xsl:element>

			<!-- Release Customer Order for Termination of the safety package PS-->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element> 
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_sec_1</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_bundle_sec_1</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>           
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>					
				</xsl:element>					
			</xsl:element>

			<!-- Create Contact for the termination of the Safety package product -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">	
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
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
							<xsl:element name="command_id">find_service_sec_1</xsl:element>
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
						<xsl:element name="command_id">find_bundle_sec_1</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>           
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>           
				</xsl:element>
			</xsl:element>

