<xsl:element name="CcmFifCommandList">
	<xsl:element name="transaction_id">
		<xsl:value-of select="request-param[@name='transactionID']"/>
	</xsl:element>
	<xsl:element name="client_name">
		<xsl:value-of select="request-param[@name='clientName']"/>
	</xsl:element>
	<xsl:variable name="TopAction" select="//request/action-name"/>
	<xsl:element name="action_name">
		<xsl:value-of select="concat($TopAction, '_NgnVoIP')"/>
	</xsl:element>   
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='overrideSystemDate']"/>
    </xsl:element>
    <xsl:element name="Command_List">
    	<!-- Validate termination reason for provider change -->
    	<xsl:if test="request-param[@name='reasonRd'] = 'PROVIDER_CHANGE' and 
    		request-param[@name='terminationReason'] != 'AGKPW'">
    		<xsl:element name="CcmFifRaiseErrorCmd">
    			<xsl:element name="command_id">wrong_term_reason_for_prov_change</xsl:element>
    			<xsl:element name="CcmFifRaiseErrorInCont">
    				<xsl:element name="error_text">Provider Change scenario must have termination reason = 'AGKPW'!</xsl:element>
    			</xsl:element>
    		</xsl:element>
    	</xsl:if>
    	<xsl:if test="request-param[@name='terminationReason'] = 'AGKPW' and
    		request-param[@name='reasonRd'] != 'PROVIDER_CHANGE'">
    		<xsl:element name="CcmFifRaiseErrorCmd">
    			<xsl:element name="command_id">wrong_term_reason_for_prov_change</xsl:element>
    			<xsl:element name="CcmFifRaiseErrorInCont">
    				<xsl:element name="error_text">terminationReason 'AGKPW'(Provider change) requires  requires reason rd 'PROVIDER_CHANGE'!</xsl:element>
    			</xsl:element>
    		</xsl:element>
    	</xsl:if>
    	
    	<!-- Validate termination reason for provider change -->
    	<xsl:if test="request-param[@name='reasonRd'] = 'PROVIDER_CHANGE' and 
    		$parentCustomerOrderID = ''">
    		<xsl:element name="CcmFifRaiseErrorCmd">
    			<xsl:element name="command_id">customer_order_for_prov_change_not_set</xsl:element>
    			<xsl:element name="CcmFifRaiseErrorInCont">
    				<xsl:element name="error_text">In a Provider Change scenario the parameter customerOrderID must be set!</xsl:element>
    			</xsl:element>
    		</xsl:element>
    	</xsl:if>
    	
    	<xsl:if test="request-param[@name='reasonRd'] = 'PROVIDER_CHANGE'"> 		
    		<!-- get CO data -->
    		<xsl:element name="CcmFifFindServiceTicketPositionCmd">
    			<xsl:element name="command_id">find_stp_1</xsl:element>
    			<xsl:element name="CcmFifFindServiceTicketPositionInCont">
    				<xsl:element name="customer_order_id">
    					<xsl:value-of select="$parentCustomerOrderID"/>
    				</xsl:element>
    				<xsl:element name="usage_mode_value_rd">1</xsl:element>
    			  <xsl:element name="reason_rd">PROVIDER_CHANGE</xsl:element>
    			</xsl:element>
    		</xsl:element>    		 
    		
    		<!-- get data from STP -->
    		<xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
    			<xsl:element name="command_id">get_stp_data_1</xsl:element>
    			<xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
    				<xsl:element name="service_ticket_position_id_ref">
    					<xsl:element name="command_id">find_stp_1</xsl:element>
    					<xsl:element name="field_name">service_ticket_position_id</xsl:element>
    				</xsl:element>
    				<xsl:element name="process_ind_ref">
    					<xsl:element name="command_id">find_stp_1</xsl:element>
    					<xsl:element name="field_name">stp_found</xsl:element>							
    				</xsl:element>
    				<xsl:element name="required_process_ind">Y</xsl:element>
    			</xsl:element>
    		</xsl:element>    		
    		
    		<xsl:element name="CcmFifGetCustomerOrderDataCmd">
    			<xsl:element name="command_id">get_co_data_1</xsl:element>
    			<xsl:element name="CcmFifGetCustomerOrderDataInCont">
    				<xsl:element name="customer_order_id">
    					<xsl:value-of select="$parentCustomerOrderID"/>
    				</xsl:element>
    			</xsl:element>
    		</xsl:element> 
    	</xsl:if>  
    	<!--Find Service Subscription-->
    	<xsl:element name="CcmFifFindServiceSubsCmd">
    		<xsl:element name="command_id">find_service_1</xsl:element>
    		<xsl:element name="CcmFifFindServiceSubsInCont">                  
    			<xsl:element name="service_subscription_id">
    				<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
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
        		<xsl:if test="request-param[@name='reasonRd'] != ''">
        			<xsl:element name="reason_rd">
        				<xsl:value-of select="request-param[@name='reasonRd']"/>
        			</xsl:element>
        		</xsl:if>
        		<xsl:if test="request-param[@name='reasonRd'] = ''">
        			<xsl:element name="reason_rd">TERMINATION</xsl:element>
        		</xsl:if>	
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
        					<xsl:value-of select="request-param[@name='carrier']"/>
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
        					<xsl:value-of select="request-param[@name='terminationReason']"/>
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
        		<xsl:element name="process_ind_ref">
        			<xsl:element name="command_id">find_voip_service_code</xsl:element>
        			<xsl:element name="field_name">service_code_valid</xsl:element>
        		</xsl:element>
        		<xsl:element name="required_process_ind">Y</xsl:element>
        		<xsl:element name="detailed_reason_ref">
        			<xsl:element name="command_id">get_stp_data_1</xsl:element>
        			<xsl:element name="field_name">detailed_reason_rd</xsl:element>
        		</xsl:element>  
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
        		<xsl:if test="request-param[@name='reasonRd'] != ''">
        			<xsl:element name="reason_rd">
        				<xsl:value-of select="request-param[@name='reasonRd']"/>
        			</xsl:element>
        		</xsl:if>
        		<xsl:if test="request-param[@name='reasonRd'] = ''">
        			<xsl:element name="reason_rd">TERMINATION</xsl:element>
        		</xsl:if>	
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
        					<xsl:value-of select="request-param[@name='carrier']"/>
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
        					<xsl:value-of select="request-param[@name='terminationReason']"/>
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
        			<!-- Backporting of VoIP Access Number 2 -->
        			<xsl:if test="request-param[@name='portAccessNumber2'] != ''">
        				<xsl:element name="CcmFifConfiguredValueCont">
        					<xsl:element name="service_char_code">V0166</xsl:element>
        					<xsl:element name="data_type">STRING</xsl:element>
        					<xsl:element name="configured_value">
        						<xsl:value-of select="request-param[@name='portAccessNumber2']"/>
        					</xsl:element>
        				</xsl:element>
        			</xsl:if>
        			<!-- Backporting of VoIP Access Number 3 -->
        			<xsl:if test="request-param[@name='portAccessNumber3'] != ''">
        				<xsl:element name="CcmFifConfiguredValueCont">
        					<xsl:element name="service_char_code">V0167</xsl:element>
        					<xsl:element name="data_type">STRING</xsl:element>
        					<xsl:element name="configured_value">
        						<xsl:value-of select="request-param[@name='portAccessNumber3']"/>
        					</xsl:element>
        				</xsl:element>
        			</xsl:if>
        			<!-- Backporting of VoIP Access Number 4 -->
        			<xsl:if test="request-param[@name='portAccessNumber4'] != ''">
        				<xsl:element name="CcmFifConfiguredValueCont">
        					<xsl:element name="service_char_code">V0168</xsl:element>
        					<xsl:element name="data_type">STRING</xsl:element>
        					<xsl:element name="configured_value">
        						<xsl:value-of select="request-param[@name='portAccessNumber4']"/>
        					</xsl:element>
        				</xsl:element>
        			</xsl:if>
        			<!-- Backporting of VoIP Access Number 5 -->
        			<xsl:if test="request-param[@name='portAccessNumber5'] != ''">
        				<xsl:element name="CcmFifConfiguredValueCont">
        					<xsl:element name="service_char_code">V0169</xsl:element>
        					<xsl:element name="data_type">STRING</xsl:element>
        					<xsl:element name="configured_value">
        						<xsl:value-of select="request-param[@name='portAccessNumber5']"/>
        					</xsl:element>
        				</xsl:element>
        			</xsl:if>
        			<!-- Backporting of VoIP Access Number 6 -->
        			<xsl:if test="request-param[@name='portAccessNumber6'] != ''">
        				<xsl:element name="CcmFifConfiguredValueCont">
        					<xsl:element name="service_char_code">V0170</xsl:element>
        					<xsl:element name="data_type">STRING</xsl:element>
        					<xsl:element name="configured_value">
        						<xsl:value-of select="request-param[@name='portAccessNumber6']"/>
        					</xsl:element>
        				</xsl:element>
        			</xsl:if>
        			<!-- Backporting of VoIP Access Number 7 -->
        			<xsl:if test="request-param[@name='portAccessNumber7'] != ''">
        				<xsl:element name="CcmFifConfiguredValueCont">
        					<xsl:element name="service_char_code">V0171</xsl:element>
        					<xsl:element name="data_type">STRING</xsl:element>
        					<xsl:element name="configured_value">
        						<xsl:value-of select="request-param[@name='portAccessNumber7']"/>
        					</xsl:element>
        				</xsl:element>
        			</xsl:if>
        			<!-- Backporting of VoIP Access Number 8 -->
        			<xsl:if test="request-param[@name='portAccessNumber8'] != ''">
        				<xsl:element name="CcmFifConfiguredValueCont">
        					<xsl:element name="service_char_code">V0172</xsl:element>
        					<xsl:element name="data_type">STRING</xsl:element>
        					<xsl:element name="configured_value">
        						<xsl:value-of select="request-param[@name='portAccessNumber8']"/>
        					</xsl:element>
        				</xsl:element>
        			</xsl:if>
        			<!-- Backporting of VoIP Access Number 9 -->
        			<xsl:if test="request-param[@name='portAccessNumber9'] != ''">
        				<xsl:element name="CcmFifConfiguredValueCont">
        					<xsl:element name="service_char_code">V0173</xsl:element>
        					<xsl:element name="data_type">STRING</xsl:element>
        					<xsl:element name="configured_value">
        						<xsl:value-of select="request-param[@name='portAccessNumber9']"/>
        					</xsl:element>
        				</xsl:element>
        			</xsl:if>
        			<!-- Backporting of VoIP Access Number 10 -->
        			<xsl:if test="request-param[@name='portAccessNumber10'] != ''">
        				<xsl:element name="CcmFifConfiguredValueCont">
        					<xsl:element name="service_char_code">V0174</xsl:element>
        					<xsl:element name="data_type">STRING</xsl:element>
        					<xsl:element name="configured_value">
        						<xsl:value-of select="request-param[@name='portAccessNumber10']"/>
        					</xsl:element>
        				</xsl:element>
        			</xsl:if>
        			</xsl:element>
        		<xsl:element name="process_ind_ref">
        			<xsl:element name="command_id">find_voip_service_code</xsl:element>
        			<xsl:element name="field_name">service_code_valid</xsl:element>
           		</xsl:element>
        	    <xsl:element name="required_process_ind">N</xsl:element>
        		<xsl:element name="detailed_reason_ref">
        			<xsl:element name="command_id">get_stp_data_1</xsl:element>
        			<xsl:element name="field_name">detailed_reason_rd</xsl:element>
        		</xsl:element>  
        	</xsl:element>
        </xsl:element>
        
        <!-- Add Termination Fee Service -->
        <xsl:if test="request-param[@name='terminationFeeServiceCode'] != ''">
        	<xsl:element name="CcmFifAddServiceSubsCmd">
        		<xsl:element name="command_id">add_service_2</xsl:element>
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
        			<xsl:if test="request-param[@name='reasonRd'] != ''">
        				<xsl:element name="reason_rd">
        					<xsl:value-of select="request-param[@name='reasonRd']"/>
        				</xsl:element>
        			</xsl:if>
        			<xsl:if test="request-param[@name='reasonRd'] = ''">
        				<xsl:element name="reason_rd">TERMINATION</xsl:element>
        			</xsl:if>	
				<xsl:element name="account_number_ref">
        				<xsl:element name="command_id">find_service_1</xsl:element>
        				<xsl:element name="field_name">account_number</xsl:element>
        			</xsl:element>

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
        			<xsl:value-of select="request-param[@name='terminationDate']"/>
        		</xsl:element>
        		<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
        		<xsl:if test="request-param[@name='reasonRd'] != ''">
        			<xsl:element name="reason_rd">
        				<xsl:value-of select="request-param[@name='reasonRd']"/>
        			</xsl:element>
        		</xsl:if>
        		<xsl:if test="request-param[@name='reasonRd'] = ''">
        			<xsl:element name="reason_rd">TERMINATION</xsl:element>
        		</xsl:if>	
        		<xsl:element name="auto_customer_order">N</xsl:element>
        		<xsl:element name="detailed_reason_rd">
        			<xsl:value-of select="request-param[@name='terminationReason']"/>
        		</xsl:element>
        	</xsl:element>
        </xsl:element>
        
        <!-- Create Customer Order for Reconfiguration of NGN VoIP-->
        <xsl:element name="CcmFifCreateCustOrderCmd">
        	<xsl:element name="command_id">create_co_ngn_voip_1</xsl:element>
        	<xsl:element name="CcmFifCreateCustOrderInCont">
        		<xsl:element name="customer_number_ref">
        			<xsl:element name="command_id">find_service_1</xsl:element>
        			<xsl:element name="field_name">customer_number</xsl:element>
        		</xsl:element>
        		<xsl:element name="customer_tracking_id">
        			<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
        		</xsl:element>
        		<xsl:element name="lan_path_file_string">
        			<xsl:value-of select="request-param[@name='lanPathFileString']"/>
        		</xsl:element>
        		<xsl:element name="sales_rep_dept">
        			<xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
        		</xsl:element>		
 <!--       		<xsl:if test="request-param[@name='providerTrackingNumber'] = ''" > 
        			<xsl:element name="provider_tracking_no">001v</xsl:element> 
        		</xsl:if>
        		<xsl:if test="request-param[@name='providerTrackingNumber'] != ''">             
        			<xsl:element name="provider_tracking_no">
        				<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
        			</xsl:element>
        		</xsl:if> -->
        		<xsl:element name="super_customer_tracking_id">
        			<xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
        		</xsl:element>
        		<xsl:element name="scan_date">
        			<xsl:value-of select="request-param[@name='scanDate']"/>
        		</xsl:element>
        		<xsl:element name="order_entry_date">
        			<xsl:value-of select="request-param[@name='entryDate']"/>
        		</xsl:element>
        		<xsl:element name="service_ticket_pos_list">
        			<xsl:element name="CcmFifCommandRefCont">
        				<xsl:element name="command_id">reconf_serv_2</xsl:element>
        				<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
        			</xsl:element>
        		</xsl:element>
        	</xsl:element>
        </xsl:element>        	
        
        <!-- Create Customer Order for Add Service for NGN VOIP-->
        <xsl:if test="request-param[@name='terminationFeeServiceCode'] != ''">
        	<xsl:element name="CcmFifCreateCustOrderCmd">
        		<xsl:element name="command_id">create_co_ngn_voip_3</xsl:element>
        		<xsl:element name="CcmFifCreateCustOrderInCont">
        			<xsl:element name="customer_number_ref">
        				<xsl:element name="command_id">find_service_1</xsl:element>
        				<xsl:element name="field_name">customer_number</xsl:element>
        			</xsl:element>
        			<xsl:element name="parent_customer_order_ref">
        				<xsl:element name="command_id">create_co_ngn_voip_1</xsl:element>
        				<xsl:element name="field_name">customer_order_id</xsl:element>
        			</xsl:element>
        			<xsl:element name="customer_tracking_id">
        				<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
        			</xsl:element>
        			<xsl:element name="lan_path_file_string">
        				<xsl:value-of select="request-param[@name='lanPathFileString']"/>
        			</xsl:element>
        			<xsl:element name="sales_rep_dept">
        				<xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
        			</xsl:element>
        			<xsl:element name="super_customer_tracking_id">
        				<xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
        			</xsl:element>
        			<xsl:element name="scan_date">
        				<xsl:value-of select="request-param[@name='scanDate']"/>
        			</xsl:element>
        			<xsl:element name="order_entry_date">
        				<xsl:value-of select="request-param[@name='entryDate']"/>
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
        		<xsl:element name="customer_number_ref">
        			<xsl:element name="command_id">find_service_1</xsl:element>
        			<xsl:element name="field_name">customer_number</xsl:element>
        		</xsl:element>
        		<xsl:element name="parent_customer_order_ref">
        			<xsl:element name="command_id">create_co_ngn_voip_1</xsl:element>
        			<xsl:element name="field_name">customer_order_id</xsl:element>
        		</xsl:element>
        		<xsl:element name="customer_tracking_id">
        			<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
        		</xsl:element>
        		<xsl:element name="lan_path_file_string">
        			<xsl:value-of select="request-param[@name='lanPathFileString']"/>
        		</xsl:element>
        		<xsl:element name="sales_rep_dept">
        			<xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
        		</xsl:element>        			
        		<xsl:if test="request-param[@name='providerTrackingNumber'] = ''" > 
        			<xsl:element name="provider_tracking_no">002v</xsl:element> 
        		</xsl:if>
        		<xsl:if test="request-param[@name='providerTrackingNumber'] != ''">             
        			<xsl:element name="provider_tracking_no">
        				<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
        			</xsl:element>
        		</xsl:if>
        		<xsl:element name="super_customer_tracking_id">
        			<xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
        		</xsl:element>
        		<xsl:element name="scan_date">
        			<xsl:value-of select="request-param[@name='scanDate']"/>
        		</xsl:element>
        		<xsl:element name="order_entry_date">
        			<xsl:value-of select="request-param[@name='entryDate']"/>
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
        			<xsl:element name="command_id">create_co_ngn_voip_1</xsl:element>
        			<xsl:element name="field_name">customer_order_id</xsl:element>
        		</xsl:element>
        		
        	</xsl:element>
        </xsl:element>
        
        <!-- Release Customer Order for Add Service -->
        <xsl:if test="request-param[@name='terminationFeeServiceCode'] != ''">
        	<xsl:element name="CcmFifReleaseCustOrderCmd">
        		<xsl:element name="CcmFifReleaseCustOrderInCont">
        			<xsl:element name="customer_number_ref">
        				<xsl:element name="command_id">find_service_1</xsl:element>
        				<xsl:element name="field_name">customer_number</xsl:element>
        			</xsl:element>
        			<xsl:element name="customer_order_ref">
        				<xsl:element name="command_id">create_co_ngn_voip_3</xsl:element>
        				<xsl:element name="field_name">customer_order_id</xsl:element>
        			</xsl:element>
        		</xsl:element>
        	</xsl:element>
        </xsl:if>             
        
        <!-- Release Customer Order for Termination for NGN VoIP -->
        <xsl:element name="CcmFifReleaseCustOrderCmd">
        	<xsl:element name="CcmFifReleaseCustOrderInCont">
        		<xsl:element name="customer_number_ref">
        			<xsl:element name="command_id">find_service_1</xsl:element>
        			<xsl:element name="field_name">customer_number</xsl:element>
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
    			<xsl:element name="customer_number_ref">
    				<xsl:element name="command_id">find_service_1</xsl:element>
    				<xsl:element name="field_name">customer_number</xsl:element>
    			</xsl:element>
    			<xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
    			<xsl:element name="short_description">Automatische Kündigung</xsl:element>
    			<xsl:element name="long_description_text">
    				<xsl:text>Kündigung der Produktnutzung für Dienst </xsl:text>
    				<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
    				<xsl:text> durch </xsl:text>
    				<xsl:value-of select="request-param[@name='clientName']"/> 
    				<xsl:text>.&#xA;TransactionID: </xsl:text>
    				<xsl:value-of select="request-param[@name='transactionID']"/>
    				<xsl:text>&#xA;User name: </xsl:text>
    				<xsl:value-of select="request-param[@name='userName']"/>				  
    			</xsl:element>
    		</xsl:element>
    	</xsl:element>
    	
	</xsl:element>
</xsl:element>		  
