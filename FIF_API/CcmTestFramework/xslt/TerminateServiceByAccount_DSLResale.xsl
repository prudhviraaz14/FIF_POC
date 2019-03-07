<xsl:element name="CcmFifCommandList">

	<!-- Copy over transaction ID and action name -->
	<xsl:element name="transaction_id">
		<xsl:value-of select="request-param[@name='transactionID']"/>
	</xsl:element>
	<xsl:element name="client_name">
		<xsl:value-of select="request-param[@name='clientName']"/>
	</xsl:element>
	<xsl:variable name="TopAction" select="//request/action-name"/>
	<xsl:element name="action_name">
		<xsl:value-of select="concat($TopAction, '_Resale')"/>
	</xsl:element>
	<xsl:element name="override_system_date">
		<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
	</xsl:element>
	
	<xsl:element name="Command_List">
		
		<!-- Generate Barcode -->     
		<xsl:element name="CcmFifGenerateCustomerOrderBarcodeCmd">
			<xsl:element name="command_id">generate_barcode_1</xsl:element>
		</xsl:element> 
		
		<!-- Terminate or cancle simple services first -->
		&TerminateService_Simple; 
		
		<!-- Find Service Subscription by access number,or service_subscription id  -->     
		<xsl:element name="CcmFifFindServiceSubsCmd">
			<xsl:element name="command_id">find_service_1</xsl:element>
			<xsl:element name="CcmFifFindServiceSubsInCont">
				<xsl:element name="account_number">
					<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
				</xsl:element>
				<xsl:element name="service_code_list">
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">I1043</xsl:element>
					</xsl:element>
					
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
			        <xsl:element name="command_id">find_cancel_stp__1</xsl:element>
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
			                <!-- Auftragsvariante -->
			                <xsl:element name="CcmFifConfiguredValueCont">
			                    <xsl:element name="service_char_code">I1011</xsl:element>
			                    <xsl:element name="data_type">STRING</xsl:element>
			                    <xsl:if test="($TerminationReason = 'ZTCOM') or ($TerminationReason = 'UMZN')">
			                        <xsl:element name="configured_value">Kündigung T-Com</xsl:element>
			                    </xsl:if>
			                    <xsl:if test="($TerminationReason != 'ZTCOM') and ($TerminationReason != 'UMZN')">
			                        <xsl:element name="configured_value">Kündigung Arcor</xsl:element>
			                    </xsl:if>					 
			                </xsl:element>
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
			            <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
			            <xsl:element name="reason_rd">
			            	<xsl:value-of select="$ReasonRd"/>
			            </xsl:element>
			            <xsl:element name="auto_customer_order">N</xsl:element>
			        </xsl:element>
			    </xsl:element>
			    
			    <!-- Create Customer Order for Reconfiguration -->
			    <xsl:element name="CcmFifCreateCustOrderCmd">
			        <xsl:element name="command_id">create_co_1</xsl:element>
			        <xsl:element name="CcmFifCreateCustOrderInCont">
			        	<xsl:element name="customer_number_ref">
			        		<xsl:element name="command_id">find_service_1</xsl:element>
			        		<xsl:element name="field_name">customer_number</xsl:element>
			        	</xsl:element>
			        	<xsl:if test="request-param[@name='OMTS_ORDER_ID'] = ''">			
			        		<xsl:element name="customer_tracking_id_ref">
			        			<xsl:element name="command_id">generate_barcode_1</xsl:element>
			        			<xsl:element name="field_name">customer_tracking_id</xsl:element>
			        		</xsl:element> 
			        	</xsl:if>
			        	<xsl:if test="request-param[@name='OMTS_ORDER_ID'] != ''">			
			        		<xsl:element name="customer_tracking_id">
			        			<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
			        		</xsl:element> 
			        	</xsl:if> 
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
			        <xsl:element name="command_id">create_co_2</xsl:element>
			        <xsl:element name="CcmFifCreateCustOrderInCont">
			        	<xsl:element name="customer_number_ref">
			        		<xsl:element name="command_id">find_service_1</xsl:element>
			        		<xsl:element name="field_name">customer_number</xsl:element>
			        	</xsl:element>
			            <xsl:element name="parent_customer_order_ref">
			                <xsl:element name="command_id">create_co_1</xsl:element>
			                <xsl:element name="field_name">customer_order_id</xsl:element>
			            </xsl:element>
			        	<xsl:if test="request-param[@name='OMTS_ORDER_ID'] = ''">			
			        		<xsl:element name="customer_tracking_id_ref">
			        			<xsl:element name="command_id">generate_barcode_1</xsl:element>
			        			<xsl:element name="field_name">customer_tracking_id</xsl:element>
			        		</xsl:element> 
			        	</xsl:if>
			        	<xsl:if test="request-param[@name='OMTS_ORDER_ID'] != ''">			
			        		<xsl:element name="customer_tracking_id">
			        			<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
			        		</xsl:element> 
			        	</xsl:if>
			            <xsl:element name="provider_tracking_no">002</xsl:element>
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
			                <xsl:element name="command_id">create_co_1</xsl:element>
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
			                <xsl:element name="command_id">create_co_2</xsl:element>
			                <xsl:element name="field_name">customer_order_id</xsl:element>
			            </xsl:element>
			        </xsl:element>
			    </xsl:element>
				      
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
                                     <xsl:text>&#xA;User name: </xsl:text>
                                             <xsl:value-of select="request-param[@name='USER_NAME']"/>
									<xsl:text>&#xA;TerminationReason: </xsl:text>
									<xsl:value-of select="$TerminationReason"/>
									<xsl:text>&#xA;ContractNumber : </xsl:text>
								</xsl:element> 
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">find_service_1</xsl:element>
								<xsl:element name="field_name">contract_number</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element> 
				</xsl:element>		

		
				<!-- Terminate VoIP Second Line if any exists -->
				&TerminateServ_VoIP;
				
				<!-- Terminate The Mobile Service if any exists -->
				&TerminateService_Mobile; 

				&TerminateServiceByAccount_MOS;
				&TerminateServiceByAccount_PCBackup;

				<!-- Validates if all the services connected to the account have been terminated -->
				&CheckNoActiveServicesForAccountExists;
				
	</xsl:element> 
</xsl:element>	
