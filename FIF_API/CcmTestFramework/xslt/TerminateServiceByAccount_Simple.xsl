	
		<!-- Find main access Services -->     
		<xsl:element name="CcmFifGetMainAccessServicesForAccountCmd">
			<xsl:element name="command_id">get_main_access_services_1</xsl:element>
			<xsl:element name="CcmFifGetMainAccessServicesForAccountInCont">
				<xsl:element name="account_number">
					<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
				</xsl:element>  
				<xsl:element name="effective_date">
					<xsl:value-of select="$TerminationDate"/>
				</xsl:element>            
			</xsl:element>
		</xsl:element> 
		
		<!-- Terminate simple services & cancels ordered ones -->     
		<xsl:element name="CcmFifTerminateSimpleProductsCmd">
			<xsl:element name="command_id">term_simple_services_1</xsl:element>
			<xsl:element name="CcmFifTerminateSimpleProductsInCont">
				<xsl:element name="service_subscription_list_ref">
					<xsl:element name="command_id">get_main_access_services_1</xsl:element>
					<xsl:element name="field_name">service_subscription_list</xsl:element>
				</xsl:element>              
				<xsl:element name="termination_date">
					<xsl:value-of select="$TerminationDate"/>
				</xsl:element>  
				<xsl:element name="notice_per_start_date">
					<xsl:value-of select="$Today"/>
				</xsl:element>
				<xsl:element name="reason_rd">
					<xsl:value-of select="$ReasonRd"/>
				</xsl:element>    
				<xsl:element name="termination_reason_rd">
					<xsl:value-of select="$TerminationReason"/>
				</xsl:element> 
				<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
				<xsl:element name="excluded_services">
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">V0010</xsl:element>
					</xsl:element>
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">V0003</xsl:element>
					</xsl:element>                                        
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">I1210</xsl:element>
					</xsl:element>     
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">I1043</xsl:element>
					</xsl:element>    
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">VI201</xsl:element>
					</xsl:element>
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">V8000</xsl:element>
					</xsl:element> 
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">I1302</xsl:element>
					</xsl:element>  
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">I1303</xsl:element>
					</xsl:element>    
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">VI003</xsl:element>
					</xsl:element>   
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">VI002</xsl:element>
					</xsl:element>                       
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">I4000</xsl:element>
					</xsl:element>                       
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">I4001</xsl:element>
					</xsl:element>  
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">I1305</xsl:element>
					</xsl:element>  
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">I1306</xsl:element>
					</xsl:element>      
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">I1213</xsl:element>
					</xsl:element> 
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">VI009</xsl:element>
					</xsl:element> 
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="service_code">VI006</xsl:element>
					</xsl:element> 					
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
			</xsl:element>
		</xsl:element>
