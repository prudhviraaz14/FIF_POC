
		<!-- Find Service Subscription by access number,or service_subscription id  -->     
		<xsl:element name="CcmFifFindServiceSubsCmd">
			<xsl:element name="command_id">find_service_voip_1</xsl:element>
			<xsl:element name="CcmFifFindServiceSubsInCont">
				<xsl:element name="account_number">
					<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
				</xsl:element>
				<xsl:element name="service_code_list">
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">VI002</xsl:element>
					</xsl:element>
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">VI003</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element> 

        	<!-- Terminate Order Form for bundled Ngn VoIP -->
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
        	<xsl:element name="command_id">find_cancel_voip_1</xsl:element>
        	<xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
        		<xsl:element name="product_subscription_ref">
        			<xsl:element name="command_id">find_service_voip_1</xsl:element>
        			<xsl:element name="field_name">product_subscription_id</xsl:element>
        		</xsl:element>
        		<xsl:element name="reason_rd">TERMINATION</xsl:element>        			
        	</xsl:element>
        </xsl:element>
		
		<!-- Reconfigure service subscription for  NGN VoIP  Premium Service-->
		
		<xsl:element name="CcmFifReconfigServiceCmd">
			<xsl:element name="command_id">reconf_serv_voip_1</xsl:element>
			<xsl:element name="CcmFifReconfigServiceInCont">
				<xsl:element name="service_subscription_ref">
					<xsl:element name="command_id">find_service_voip_1</xsl:element>
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
					<!-- Auftragsvariante  -->
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">V0810</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>                                                                      
						<xsl:element name="configured_value">Echte Kündigung</xsl:element>    
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
					<!-- NEUER TNB -->
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">V0061</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>
						<xsl:element name="configured_value">**NULL**</xsl:element>
					</xsl:element>	
				</xsl:element>				
			</xsl:element>
		</xsl:element>
       
        <!-- Terminate Product Subscription for bundled NGN VOIP -->
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
        		<xsl:element name="desired_schedule_type">END_BEFORE</xsl:element>
        		<xsl:element name="reason_rd">
        			<xsl:value-of select="$ReasonRd"/>
        		</xsl:element>
        		<xsl:element name="auto_customer_order">N</xsl:element>  
        	</xsl:element>
        </xsl:element>
        
        <!-- Create Customer Order for Reconfiguration of bundled NGN VoIP-->
        <xsl:element name="CcmFifCreateCustOrderCmd">
        	<xsl:element name="command_id">create_co_ngn_voip_1</xsl:element>
        	<xsl:element name="CcmFifCreateCustOrderInCont">
        		<xsl:element name="customer_number_ref">
        			<xsl:element name="command_id">find_service_voip_1</xsl:element>
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
        		<xsl:element name="provider_tracking_no">001v</xsl:element>
        		<xsl:element name="service_ticket_pos_list">
        			<xsl:element name="CcmFifCommandRefCont">
        				<xsl:element name="command_id">reconf_serv_voip_1</xsl:element>
        				<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
        			</xsl:element>
        		</xsl:element>     		 
        	</xsl:element>
        </xsl:element>        	
      
        <!-- Create Customer Order for Termination -->
        <xsl:element name="CcmFifCreateCustOrderCmd">
        	<xsl:element name="command_id">create_co_ngn_voip_2</xsl:element>
        	<xsl:element name="CcmFifCreateCustOrderInCont">
        		<xsl:element name="customer_number_ref">
        			<xsl:element name="command_id">find_service_voip_1</xsl:element>
        			<xsl:element name="field_name">customer_number</xsl:element>
        		</xsl:element>
        		<xsl:element name="parent_customer_order_ref">
        			<xsl:element name="command_id">create_co_ngn_voip_1</xsl:element>
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
        		<xsl:element name="provider_tracking_no">002v</xsl:element>
        		<xsl:element name="service_ticket_pos_list">
        			<xsl:element name="CcmFifCommandRefCont">
        				<xsl:element name="command_id">terminate_ps_voip_1</xsl:element>
        				<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
        			</xsl:element>
        		</xsl:element>     		
        	</xsl:element>
        </xsl:element>    
                         
        <!-- Release Customer Order for Reconfiguration -->
        <xsl:element name="CcmFifReleaseCustOrderCmd">
        	<xsl:element name="CcmFifReleaseCustOrderInCont">
        		<xsl:element name="customer_number_ref">
        			<xsl:element name="command_id">find_service_voip_1</xsl:element>
        			<xsl:element name="field_name">customer_number</xsl:element>
        		</xsl:element>
        		<xsl:element name="customer_order_ref">
        			<xsl:element name="command_id">create_co_ngn_voip_1</xsl:element>
        			<xsl:element name="field_name">customer_order_id</xsl:element>
        		</xsl:element> 
        		
        	</xsl:element>
        </xsl:element>

        <!-- Release Customer Order for Termination for bundled NGN VoIP -->
        <xsl:element name="CcmFifReleaseCustOrderCmd">
        	<xsl:element name="CcmFifReleaseCustOrderInCont">
        		<xsl:element name="customer_number_ref">
        			<xsl:element name="command_id">find_service_voip_1</xsl:element>
        			<xsl:element name="field_name">customer_number</xsl:element>
        		</xsl:element>
        		<xsl:element name="customer_order_ref">
        			<xsl:element name="command_id">create_co_ngn_voip_2</xsl:element>
        			<xsl:element name="field_name">customer_order_id</xsl:element>
        		</xsl:element>
        	</xsl:element>
        </xsl:element>
        
 
            <!-- Create Contact for the Service Termination  NGN VOIP-->
           <xsl:element name="CcmFifCreateContactCmd">
              <xsl:element name="CcmFifCreateContactInCont">
              	<xsl:element name="customer_number_ref">
              		<xsl:element name="command_id">find_service_voip_1</xsl:element>
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
                               <xsl:element name="command_id">find_service_voip_1</xsl:element>
                               <xsl:element name="field_name">contract_number</xsl:element>
                           </xsl:element>
                        </xsl:element>           
              </xsl:element> 
            </xsl:element>
	  
