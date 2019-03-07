<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for changing access numbers.
	
	@author banania
-->

<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1" indent="yes" method="xml"/>
	<xsl:template match="/">
		<xsl:element name="CcmFifCommandList">
			<xsl:apply-templates select="request/request-params"/>
		</xsl:element>
		
	</xsl:template>
	<xsl:template match="request-params">
		<!-- Copy over transaction ID and action name -->
		<xsl:element name="transaction_id">
			<xsl:value-of select="request-param[@name='transactionID']"/>
		</xsl:element>
		<xsl:element name="client_name">
			<xsl:value-of select="request-param[@name='clientName']"/>
		</xsl:element>
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
		</xsl:element>
	
		<xsl:element name="Command_List">
			
			<!-- Convert the desired date to OPM format -->
			<xsl:variable name="desiredDateOPM"
				select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
			
			<!-- Calculate today and one day before the desired date -->
			<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
				
			<!--  Ordering new access numbers and deleting old one in not allowed within the same transaction -->
			<xsl:if test="request-param[@name='numberOfNewAccessNumbers'] = '0'
				and request-param[@name='portingAccessNumber1'] = ''
				and request-param[@name='portingAccessNumber2'] = ''
				and request-param[@name='portingAccessNumber3'] = ''
				and request-param[@name='portingAccessNumber4'] = ''
				and request-param[@name='portingAccessNumber5'] = ''
				and request-param[@name='portingAccessNumber6'] = ''
				and request-param[@name='portingAccessNumber7'] = ''
				and request-param[@name='portingAccessNumber8'] = ''
				and request-param[@name='portingAccessNumber9'] = ''
				and request-param[@name='portingAccessNumber10'] = ''">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">reconfigure_error_1</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">Either the parameter numberOfNewAccessNumbers or the parameter for access number porting must be set!</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
						
			<!-- Find Service Subscription-->		
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_service_1</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="service_subscription_id">
						<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
					</xsl:element>			
				</xsl:element>
			</xsl:element>

			<!-- Validate the service code-->
			<xsl:element name="CcmFifValidateValueCmd">
				<xsl:element name="command_id">validate_service_code</xsl:element>
				<xsl:element name="CcmFifValidateValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>          
						<xsl:element name="field_name">service_code</xsl:element>            
					</xsl:element>      
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">V0003</xsl:element>
						</xsl:element>						
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">V0010</xsl:element>
						</xsl:element>  					
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">VI002</xsl:element>
						</xsl:element> 						
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">VI003</xsl:element>
						</xsl:element> 
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">VI006</xsl:element>
						</xsl:element>   
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">VI009</xsl:element>
						</xsl:element>						
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">VI201</xsl:element>
						</xsl:element>             
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Find if the main access service is ISDN or not-->
			<xsl:element name="CcmFifValidateSCValueCmd">
				<xsl:element name="command_id">find_isdn_premium_service</xsl:element>
				<xsl:element name="CcmFifValidateSCValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>          
						<xsl:element name="field_name">service_code</xsl:element>            
					</xsl:element>      
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">V0010</xsl:element>
						</xsl:element>                       
					</xsl:element>
				</xsl:element>
			</xsl:element>
	
			<!-- Find if the main access service is ISDN or not-->
			<xsl:element name="CcmFifValidateSCValueCmd">
				<xsl:element name="command_id">find_isdn_basis_service</xsl:element>
				<xsl:element name="CcmFifValidateSCValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>          
						<xsl:element name="field_name">service_code</xsl:element>            
					</xsl:element>      
					<xsl:element name="allowed_values">  
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">V0003</xsl:element>
						</xsl:element>                    
					</xsl:element>
				</xsl:element>
			</xsl:element>
		
			<!-- Find if the main access service is ISDN or not-->
			<xsl:element name="CcmFifValidateSCValueCmd">
				<xsl:element name="command_id">find_non_isdn_premium_service</xsl:element>
				<xsl:element name="CcmFifValidateSCValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>          
						<xsl:element name="field_name">service_code</xsl:element>            
					</xsl:element>      
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">VI201</xsl:element>
						</xsl:element>  
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">VI006</xsl:element>
						</xsl:element>  
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">VI003</xsl:element>
						</xsl:element>                       
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Find if the main access service is ISDN or not-->
			<xsl:element name="CcmFifValidateSCValueCmd">
				<xsl:element name="command_id">find_non_isdn_basis_service</xsl:element>
				<xsl:element name="CcmFifValidateSCValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>          
						<xsl:element name="field_name">service_code</xsl:element>            
					</xsl:element>      
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">VI002</xsl:element>
						</xsl:element>   
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">VI009</xsl:element>
						</xsl:element>                    
					</xsl:element>
				</xsl:element>
			</xsl:element>	
					
            <!-- Reconfigure Service Subscription : Access Numbers for an ISDN premium service -->
			<xsl:element name="CcmFifReconfigServiceCmd">
				<xsl:element name="command_id">reconf_serv_1</xsl:element>
				<xsl:element name="CcmFifReconfigServiceInCont">
					<xsl:element name="service_subscription_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
					<xsl:element name="reason_rd">MODIFY_ACCESS_NU</xsl:element>
					<xsl:element name="service_characteristic_list">
						<!-- Bearbeitungsart -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0971</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">TAL</xsl:element>
						</xsl:element>
						<!-- Grund der Neukonfiguration -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0943</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">Rufnummernänderung</xsl:element>
						</xsl:element> 
						<!-- Special Letter Indicator  -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0216</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='specialLetter']"/>  
							</xsl:element>
						</xsl:element>		
						<!-- Aktivierungsdatum -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0909</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$desiredDateOPM"/>
							</xsl:element>
						</xsl:element>
						<xsl:if test="request-param[@name='notice'] != ''">
							<!-- Ansage -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0217</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='notice']"/>                                                                  
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Number of new access numbers -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0936</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='numberOfNewAccessNumbers']"/>
							</xsl:element>
						</xsl:element>                                        
						<!--  Porting Access Number 1 -->
						<xsl:if test="request-param[@name='portingAccessNumber1']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0165</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber1']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>                                                       
						<!--  Porting Access Number2 -->
						<xsl:if test="request-param[@name='portingAccessNumber2']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0166</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber2']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 3 -->
						<xsl:if test="request-param[@name='portingAccessNumber3']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0167</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber3']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 4 -->
						<xsl:if test="request-param[@name='portingAccessNumber4']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0168</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber4']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 5 -->
						<xsl:if test="request-param[@name='portingAccessNumber5']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0169</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber5']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 6 -->
						<xsl:if test="request-param[@name='portingAccessNumber6']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0170</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber6']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 7 -->
						<xsl:if test="request-param[@name='portingAccessNumber7']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0171</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber7']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 8 -->
						<xsl:if test="request-param[@name='portingAccessNumber8']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0172</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber8']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 9 -->
						<xsl:if test="request-param[@name='portingAccessNumber9']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0173</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber9']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 10 -->
						<xsl:if test="request-param[@name='portingAccessNumber10']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0174</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber10']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- NEUER TNB -->                                              
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0061</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">**NULL**</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_isdn_premium_service</xsl:element>
						<xsl:element name="field_name">service_code_valid</xsl:element>          	
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element> 
				</xsl:element>
			</xsl:element>

			<!-- Reconfigure Service Subscription : Access Numbers for ISDN basis-->
			<xsl:element name="CcmFifReconfigServiceCmd">
				<xsl:element name="command_id">reconf_serv_1</xsl:element>
				<xsl:element name="CcmFifReconfigServiceInCont">
					<xsl:element name="service_subscription_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
					<xsl:element name="reason_rd">MODIFY_ACCESS_NU</xsl:element>
					<xsl:element name="service_characteristic_list">
						<!-- Bearbeitungsart -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0971</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">TAL</xsl:element>
						</xsl:element>
						<!-- Grund der Neukonfiguration -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0943</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">Rufnummernänderung</xsl:element>
						</xsl:element> 
						<!-- Special Letter Indicator  -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0216</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='specialLetter']"/>  
							</xsl:element>
						</xsl:element>		
						<!-- Aktivierungsdatum -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0909</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$desiredDateOPM"/>
							</xsl:element>
						</xsl:element>
						<xsl:if test="request-param[@name='notice'] != ''">
							<!-- Ansage -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0217</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='notice']"/>                                                                  
								</xsl:element>
							</xsl:element>
						</xsl:if>                                       
						<!--  Porting Access Number 1 -->
						<xsl:if test="request-param[@name='portingAccessNumber1']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0165</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber1']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>                                                       
						<!--  Porting Access Number2 -->
						<xsl:if test="request-param[@name='portingAccessNumber2']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0166</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber2']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 3 -->
						<xsl:if test="request-param[@name='portingAccessNumber3']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0167</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber3']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 4 -->
						<xsl:if test="request-param[@name='portingAccessNumber4']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0168</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber4']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 5 -->
						<xsl:if test="request-param[@name='portingAccessNumber5']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0169</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber5']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 6 -->
						<xsl:if test="request-param[@name='portingAccessNumber6']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0170</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber6']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 7 -->
						<xsl:if test="request-param[@name='portingAccessNumber7']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0171</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber7']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 8 -->
						<xsl:if test="request-param[@name='portingAccessNumber8']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0172</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber8']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 9 -->
						<xsl:if test="request-param[@name='portingAccessNumber9']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0173</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber9']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 10 -->
						<xsl:if test="request-param[@name='portingAccessNumber10']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0174</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber10']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>                                              
						<!-- NEUER TNB -->                                              
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0061</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">**NULL**</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_isdn_basis_service</xsl:element>
						<xsl:element name="field_name">service_code_valid</xsl:element>          	
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element> 
				</xsl:element>
			</xsl:element>

						
			<!-- Reconfigure Service Subscription : Access Numbers for NGN, Bitstream and VoIP -->
			<xsl:element name="CcmFifReconfigServiceCmd">
				<xsl:element name="command_id">reconf_serv_1</xsl:element>
				<xsl:element name="CcmFifReconfigServiceInCont">
					<xsl:element name="service_subscription_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
					<xsl:element name="reason_rd">MODIFY_ACCESS_NU</xsl:element>
					<xsl:element name="service_characteristic_list">
						<!-- Bearbeitungsart -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">VI002</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">OP</xsl:element>
						</xsl:element>
						<!-- Grund der Neukonfiguration -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">VI008</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">Rufnummernänderung</xsl:element>
						</xsl:element>
						<!-- Special Letter  -->				
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0216</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='specialLetter']"/>  
							</xsl:element>
						</xsl:element>					
						<!-- Aktivierungsdatum -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0909</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$desiredDateOPM"/>
							</xsl:element>
						</xsl:element>
						<xsl:if test="request-param[@name='notice'] != ''">
							<!-- Ansage -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0217</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='notice']"/>                                                                  
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Number of new access numbers -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0936</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='numberOfNewAccessNumbers']"/>
							</xsl:element>
						</xsl:element>
						<!--  Porting Access Number 1 -->
						<xsl:if test="request-param[@name='portingAccessNumber1']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0165</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber1']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>							
							<!--  Porting Access Number2 -->
							<xsl:if test="request-param[@name='portingAccessNumber2']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0166</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='portingAccessNumber2']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!--  Porting Access Number 3 -->
							<xsl:if test="request-param[@name='portingAccessNumber3']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0167</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='portingAccessNumber3']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!--  Porting Access Number 4 -->
							<xsl:if test="request-param[@name='portingAccessNumber4']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0168</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='portingAccessNumber4']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!--  Porting Access Number 5 -->
							<xsl:if test="request-param[@name='portingAccessNumber5']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0169</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='portingAccessNumber5']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!--  Porting Access Number 6 -->
							<xsl:if test="request-param[@name='portingAccessNumber6']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0170</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='portingAccessNumber6']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!--  Porting Access Number 7 -->
							<xsl:if test="request-param[@name='portingAccessNumber7']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0171</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='portingAccessNumber7']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!--  Porting Access Number 8 -->
							<xsl:if test="request-param[@name='portingAccessNumber8']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0172</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='portingAccessNumber8']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!--  Porting Access Number 9 -->
							<xsl:if test="request-param[@name='portingAccessNumber9']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0173</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='portingAccessNumber9']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!--  Porting Access Number 10 -->
							<xsl:if test="request-param[@name='portingAccessNumber10']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0174</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='portingAccessNumber10']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>            			
						<!-- NEUER TNB -->                                              
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0061</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">**NULL**</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_non_isdn_premium_service</xsl:element>
						<xsl:element name="field_name">service_code_valid</xsl:element>          	
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element> 
				</xsl:element>
			</xsl:element>
		
			<!-- Reconfigure Service Subscription : Access Numbers for Bitstream and NGN basis -->
			<xsl:element name="CcmFifReconfigServiceCmd">
				<xsl:element name="command_id">reconf_serv_1</xsl:element>
				<xsl:element name="CcmFifReconfigServiceInCont">
					<xsl:element name="service_subscription_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
					<xsl:element name="reason_rd">MODIFY_ACCESS_NU</xsl:element>
					<xsl:element name="service_characteristic_list">
						<!-- Bearbeitungsart -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">VI002</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">OP</xsl:element>
						</xsl:element>
						<!-- Grund der Neukonfiguration -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">VI008</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">Rufnummernänderung</xsl:element>
						</xsl:element>
						<!-- Special Letter  -->				
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0216</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='specialLetter']"/>  
							</xsl:element>
						</xsl:element>					
						<!-- Aktivierungsdatum -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0909</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$desiredDateOPM"/>
							</xsl:element>
						</xsl:element>
						<xsl:if test="request-param[@name='notice'] != ''">
							<!-- Ansage -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0217</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='notice']"/>                                                                  
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 1 -->
						<xsl:if test="request-param[@name='portingAccessNumber1']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0165</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber1']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>							
						<!--  Porting Access Number2 -->
						<xsl:if test="request-param[@name='portingAccessNumber2']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0166</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber2']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 3 -->
						<xsl:if test="request-param[@name='portingAccessNumber3']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0167</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber3']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 4 -->
						<xsl:if test="request-param[@name='portingAccessNumber4']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0168</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber4']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 5 -->
						<xsl:if test="request-param[@name='portingAccessNumber5']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0169</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber5']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 6 -->
						<xsl:if test="request-param[@name='portingAccessNumber6']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0170</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber6']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 7 -->
						<xsl:if test="request-param[@name='portingAccessNumber7']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0171</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber7']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 8 -->
						<xsl:if test="request-param[@name='portingAccessNumber8']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0172</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber8']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 9 -->
						<xsl:if test="request-param[@name='portingAccessNumber9']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0173</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber9']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--  Porting Access Number 10 -->
						<xsl:if test="request-param[@name='portingAccessNumber10']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0174</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='portingAccessNumber10']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>            			
						<!-- NEUER TNB -->                                              
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0061</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">**NULL**</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_non_isdn_basis_service</xsl:element>
						<xsl:element name="field_name">service_code_valid</xsl:element>          	
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element> 
				</xsl:element>
			</xsl:element>	
			<!-- Create Customer Order for new services  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
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
			
			
			<!-- Create Contact -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">					
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>			
					<xsl:element name="contact_type_rd">MODIFY_ACCESS_NU</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>Rufnummernänderung</xsl:text>
					</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>Rufnummernänderung über: </xsl:text>
						<xsl:value-of select="request-param[@name='clientName']"/>
						<xsl:text>&#xA;TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
						<xsl:text>&#xA;User name: </xsl:text>
						<xsl:value-of select="request-param[@name='userName']"/>
						<xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
						<xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
						<xsl:text>&#xA;Desired date: </xsl:text>
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
