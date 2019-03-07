<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for creating a wholesale TAL contract
	
	@author schwarje 
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
		
		<!-- Calculate today and one day before the desired date -->
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
		<xsl:variable name="tomorrow" select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
		
		<xsl:element name="Command_List">
			
			<xsl:variable name="desiredDate">
				<xsl:choose>
					<xsl:when test="request-param[@name='DESIRED_DATE'] != ''
						and dateutils:compareString(request-param[@name='DESIRED_DATE'], $today) = '-1'">
						<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$today"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>	
			
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="access_number">
						<xsl:value-of select="request-param[@name='VOICE_SERVICE_ID']"/>
					</xsl:element>
					<xsl:element name="access_number_type">TECH_SERVICE_ID</xsl:element>
					<xsl:element name="no_service_error">N</xsl:element>
					<xsl:element name="no_service_warning">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="CcmFifReconfigServiceCmd">
				<xsl:element name="command_id">reconfigure_service</xsl:element>
				<xsl:element name="CcmFifReconfigServiceInCont">
					<xsl:element name="service_subscription_ref">
						<xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$desiredDate"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">MODIFY_WHS_VOICE</xsl:element>
					<xsl:element name="service_characteristic_list">
						<xsl:if test="request-param[@name='ASB'] != ''">
							<!-- ASB -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0934</xsl:element>
								<xsl:element name="data_type">INTEGER</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='ASB']"/> 
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='ACCESS_NUMBER_1.LocalAreaCode'] != ''">
							<!-- ONKZ -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0124</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:if test="substring(request-param[@name='ACCESS_NUMBER_1.LocalAreaCode'],1,1) != '0'
										and substring(request-param[@name='ACCESS_NUMBER_1.LocalAreaCode'],1,1) != ''">0</xsl:if>
									<xsl:value-of select="request-param[@name='ACCESS_NUMBER_1.LocalAreaCode']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='ACCESS_NUMBER_1.LocalNumber'] != ''">
							<xsl:element name="CcmFifAccessNumberCont">
								<xsl:element name="service_char_code">V0001</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">
									<xsl:value-of select="request-param[@name='VALIDATE_DUPLICATE_INDICATOR']"/>
								</xsl:element>							
								<xsl:element name="country_code">49</xsl:element>
								<xsl:element name="city_code">
									<xsl:choose>
										<xsl:when test="substring(request-param[@name='ACCESS_NUMBER_1.LocalAreaCode'],1,1) != '0'">
											<xsl:value-of select="request-param[@name='ACCESS_NUMBER_1.LocalAreaCode']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring-after(request-param[@name='ACCESS_NUMBER_1.LocalAreaCode'], '0')"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
								<xsl:element name="local_number">
									<xsl:value-of select="request-param[@name='ACCESS_NUMBER_1.LocalNumber']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='ACCESS_NUMBER_1.LocalNumber'] = ''"> 		
							<xsl:element name="CcmFifAccessNumberCont">	
							    <xsl:element name="service_char_code">V0001</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">N</xsl:element>		
								<xsl:element name="country_code"></xsl:element>
								<xsl:element name="city_code"></xsl:element>
								<xsl:element name="local_number"></xsl:element>		
							</xsl:element>						
						</xsl:if> 	
						<xsl:if test="request-param[@name='ACCESS_NUMBER_2.LocalNumber'] != ''">
							<xsl:element name="CcmFifAccessNumberCont">
								<xsl:element name="service_char_code">V0070</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">
									<xsl:value-of select="request-param[@name='VALIDATE_DUPLICATE_INDICATOR']"/>
								</xsl:element>								
								<xsl:element name="country_code">49</xsl:element>
								<xsl:element name="city_code">
									<xsl:choose>
										<xsl:when test="substring(request-param[@name='ACCESS_NUMBER_2.LocalAreaCode'],1,1) != '0'">
											<xsl:value-of select="request-param[@name='ACCESS_NUMBER_2.LocalAreaCode']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring-after(request-param[@name='ACCESS_NUMBER_2.LocalAreaCode'], '0')"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
								<xsl:element name="local_number">
									<xsl:value-of select="request-param[@name='ACCESS_NUMBER_2.LocalNumber']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='ACCESS_NUMBER_2.LocalNumber'] = ''"> 		
							<xsl:element name="CcmFifAccessNumberCont">	
							    <xsl:element name="service_char_code">V0070</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">N</xsl:element>		
								<xsl:element name="country_code"></xsl:element>
								<xsl:element name="city_code"></xsl:element>
								<xsl:element name="local_number"></xsl:element>		
							</xsl:element>						
						</xsl:if> 	
						<xsl:if test="request-param[@name='ACCESS_NUMBER_3.LocalNumber'] != ''">
							<xsl:element name="CcmFifAccessNumberCont">
								<xsl:element name="service_char_code">V0071</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">
									<xsl:value-of select="request-param[@name='VALIDATE_DUPLICATE_INDICATOR']"/>
								</xsl:element>							
								<xsl:element name="country_code">49</xsl:element>
								<xsl:element name="city_code">
									<xsl:choose>
										<xsl:when test="substring(request-param[@name='ACCESS_NUMBER_3.LocalAreaCode'],1,1) != '0'">
											<xsl:value-of select="request-param[@name='ACCESS_NUMBER_3.LocalAreaCode']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring-after(request-param[@name='ACCESS_NUMBER_3.LocalAreaCode'], '0')"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
								<xsl:element name="local_number">
									<xsl:value-of select="request-param[@name='ACCESS_NUMBER_3.LocalNumber']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='ACCESS_NUMBER_3.LocalNumber'] = ''"> 		
							<xsl:element name="CcmFifAccessNumberCont">	
							    <xsl:element name="service_char_code">V0071</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">N</xsl:element>		
								<xsl:element name="country_code"></xsl:element>
								<xsl:element name="city_code"></xsl:element>
								<xsl:element name="local_number"></xsl:element>		
							</xsl:element>						
						</xsl:if> 	
						<xsl:if test="request-param[@name='ACCESS_NUMBER_4.LocalNumber'] != ''">
							<xsl:element name="CcmFifAccessNumberCont">
								<xsl:element name="service_char_code">V0072</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">
									<xsl:value-of select="request-param[@name='VALIDATE_DUPLICATE_INDICATOR']"/>
								</xsl:element>							
								<xsl:element name="country_code">49</xsl:element>
								<xsl:element name="city_code">
									<xsl:choose>
										<xsl:when test="substring(request-param[@name='ACCESS_NUMBER_4.LocalAreaCode'],1,1) != '0'">
											<xsl:value-of select="request-param[@name='ACCESS_NUMBER_4.LocalAreaCode']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring-after(request-param[@name='ACCESS_NUMBER_4.LocalAreaCode'], '0')"/>
										</xsl:otherwise>
									</xsl:choose>									
								</xsl:element>
								<xsl:element name="local_number">
									<xsl:value-of select="request-param[@name='ACCESS_NUMBER_4.LocalNumber']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='ACCESS_NUMBER_4.LocalNumber'] = ''"> 		
							<xsl:element name="CcmFifAccessNumberCont">	
							    <xsl:element name="service_char_code">V0072</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">N</xsl:element>		
								<xsl:element name="country_code"></xsl:element>
								<xsl:element name="city_code"></xsl:element>
								<xsl:element name="local_number"></xsl:element>		
							</xsl:element>						
						</xsl:if> 	
						<xsl:if test="request-param[@name='ACCESS_NUMBER_5.LocalNumber'] != ''">
							<xsl:element name="CcmFifAccessNumberCont">
								<xsl:element name="service_char_code">V0073</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">
									<xsl:value-of select="request-param[@name='VALIDATE_DUPLICATE_INDICATOR']"/>
								</xsl:element>								
								<xsl:element name="country_code">49</xsl:element>
								<xsl:element name="city_code">
									<xsl:choose>
										<xsl:when test="substring(request-param[@name='ACCESS_NUMBER_5.LocalAreaCode'],1,1) != '0'">
											<xsl:value-of select="request-param[@name='ACCESS_NUMBER_5.LocalAreaCode']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring-after(request-param[@name='ACCESS_NUMBER_5.LocalAreaCode'], '0')"/>
										</xsl:otherwise>
									</xsl:choose>									
								</xsl:element>
								<xsl:element name="local_number">
									<xsl:value-of select="request-param[@name='ACCESS_NUMBER_5.LocalNumber']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='ACCESS_NUMBER_5.LocalNumber'] = ''"> 		
							<xsl:element name="CcmFifAccessNumberCont">	
							    <xsl:element name="service_char_code">V0073</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">N</xsl:element>		
								<xsl:element name="country_code"></xsl:element>
								<xsl:element name="city_code"></xsl:element>
								<xsl:element name="local_number"></xsl:element>		
							</xsl:element>						
						</xsl:if> 	
						<xsl:if test="request-param[@name='ACCESS_NUMBER_6.LocalNumber'] != ''">
							<xsl:element name="CcmFifAccessNumberCont">
								<xsl:element name="service_char_code">V0074</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">
									<xsl:value-of select="request-param[@name='VALIDATE_DUPLICATE_INDICATOR']"/>
								</xsl:element>							
								<xsl:element name="country_code">49</xsl:element>
								<xsl:element name="city_code">
									<xsl:choose>
										<xsl:when test="substring(request-param[@name='ACCESS_NUMBER_6.LocalAreaCode'],1,1) != '0'">
											<xsl:value-of select="request-param[@name='ACCESS_NUMBER_6.LocalAreaCode']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring-after(request-param[@name='ACCESS_NUMBER_6.LocalAreaCode'], '0')"/>
										</xsl:otherwise>
									</xsl:choose>									
								</xsl:element>
								<xsl:element name="local_number">
									<xsl:value-of select="request-param[@name='ACCESS_NUMBER_6.LocalNumber']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='ACCESS_NUMBER_6.LocalNumber'] = ''"> 		
							<xsl:element name="CcmFifAccessNumberCont">	
							    <xsl:element name="service_char_code">V0074</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">N</xsl:element>		
								<xsl:element name="country_code"></xsl:element>
								<xsl:element name="city_code"></xsl:element>
								<xsl:element name="local_number"></xsl:element>		
							</xsl:element>						
						</xsl:if> 	
						<xsl:if test="request-param[@name='ACCESS_NUMBER_7.LocalNumber'] != ''">
							<xsl:element name="CcmFifAccessNumberCont">
								<xsl:element name="service_char_code">V0075</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">
									<xsl:value-of select="request-param[@name='VALIDATE_DUPLICATE_INDICATOR']"/>
								</xsl:element>							
								<xsl:element name="country_code">49</xsl:element>
								<xsl:element name="city_code">
									<xsl:choose>
										<xsl:when test="substring(request-param[@name='ACCESS_NUMBER_7.LocalAreaCode'],1,1) != '0'">
											<xsl:value-of select="request-param[@name='ACCESS_NUMBER_7.LocalAreaCode']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring-after(request-param[@name='ACCESS_NUMBER_7.LocalAreaCode'], '0')"/>
										</xsl:otherwise>
									</xsl:choose>									
								</xsl:element>
								<xsl:element name="local_number">
									<xsl:value-of select="request-param[@name='ACCESS_NUMBER_7.LocalNumber']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='ACCESS_NUMBER_7.LocalNumber'] = ''"> 		
							<xsl:element name="CcmFifAccessNumberCont">	
							    <xsl:element name="service_char_code">V0075</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">N</xsl:element>		
								<xsl:element name="country_code"></xsl:element>
								<xsl:element name="city_code"></xsl:element>
								<xsl:element name="local_number"></xsl:element>		
							</xsl:element>						
						</xsl:if> 	
						<xsl:if test="request-param[@name='ACCESS_NUMBER_8.LocalNumber'] != ''">
							<xsl:element name="CcmFifAccessNumberCont">
								<xsl:element name="service_char_code">V0076</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">
									<xsl:value-of select="request-param[@name='VALIDATE_DUPLICATE_INDICATOR']"/>
								</xsl:element>							
								<xsl:element name="country_code">49</xsl:element>
								<xsl:element name="city_code">
									<xsl:choose>
										<xsl:when test="substring(request-param[@name='ACCESS_NUMBER_8.LocalAreaCode'],1,1) != '0'">
											<xsl:value-of select="request-param[@name='ACCESS_NUMBER_8.LocalAreaCode']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring-after(request-param[@name='ACCESS_NUMBER_8.LocalAreaCode'], '0')"/>
										</xsl:otherwise>
									</xsl:choose>									
								</xsl:element>
								<xsl:element name="local_number">
									<xsl:value-of select="request-param[@name='ACCESS_NUMBER_8.LocalNumber']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='ACCESS_NUMBER_8.LocalNumber'] = ''"> 		
							<xsl:element name="CcmFifAccessNumberCont">	
							    <xsl:element name="service_char_code">V0076</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">N</xsl:element>		
								<xsl:element name="country_code"></xsl:element>
								<xsl:element name="city_code"></xsl:element>
								<xsl:element name="local_number"></xsl:element>		
							</xsl:element>						
						</xsl:if> 	
						<xsl:if test="request-param[@name='ACCESS_NUMBER_9.LocalNumber'] != ''">
							<xsl:element name="CcmFifAccessNumberCont">
								<xsl:element name="service_char_code">V0077</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">
									<xsl:value-of select="request-param[@name='VALIDATE_DUPLICATE_INDICATOR']"/>
								</xsl:element>
								<xsl:element name="country_code">49</xsl:element>
								<xsl:element name="city_code">
									<xsl:choose>
										<xsl:when test="substring(request-param[@name='ACCESS_NUMBER_9.LocalAreaCode'],1,1) != '0'">
											<xsl:value-of select="request-param[@name='ACCESS_NUMBER_9.LocalAreaCode']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring-after(request-param[@name='ACCESS_NUMBER_9.LocalAreaCode'], '0')"/>
										</xsl:otherwise>
									</xsl:choose>								
								</xsl:element>
								<xsl:element name="local_number">
									<xsl:value-of select="request-param[@name='ACCESS_NUMBER_9.LocalNumber']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='ACCESS_NUMBER_9.LocalNumber'] = ''"> 		
							<xsl:element name="CcmFifAccessNumberCont">	
							    <xsl:element name="service_char_code">V0077</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">N</xsl:element>		
								<xsl:element name="country_code"></xsl:element>
								<xsl:element name="city_code"></xsl:element>
								<xsl:element name="local_number"></xsl:element>		
							</xsl:element>						
						</xsl:if> 	
						<xsl:if test="request-param[@name='ACCESS_NUMBER_10.LocalNumber'] != ''"> 						
							<xsl:element name="CcmFifAccessNumberCont">
								<xsl:element name="service_char_code">V0078</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">
									<xsl:value-of select="request-param[@name='VALIDATE_DUPLICATE_INDICATOR']"/>
								</xsl:element>								
								<xsl:element name="country_code">49</xsl:element>
								<xsl:element name="city_code">
									<xsl:choose>
										<xsl:when test="substring(request-param[@name='ACCESS_NUMBER_10.LocalAreaCode'],1,1) != '0'">
											<xsl:value-of select="request-param[@name='ACCESS_NUMBER_10.LocalAreaCode']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring-after(request-param[@name='ACCESS_NUMBER_10.LocalAreaCode'], '0')"/>
										</xsl:otherwise>
									</xsl:choose>									
								</xsl:element>
								<xsl:element name="local_number">
									<xsl:value-of select="request-param[@name='ACCESS_NUMBER_10.LocalNumber']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if> 
						<xsl:if test="request-param[@name='ACCESS_NUMBER_10.LocalNumber'] = ''"> 		
							<xsl:element name="CcmFifAccessNumberCont">	
							    <xsl:element name="service_char_code">V0078</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="validate_duplicate_indicator">N</xsl:element>		
								<xsl:element name="country_code"></xsl:element>
								<xsl:element name="city_code"></xsl:element>
								<xsl:element name="local_number"></xsl:element>		
							</xsl:element>						
						</xsl:if> 	
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>	
					<xsl:element name="allow_stp_modification">Y</xsl:element>				
				</xsl:element>
			</xsl:element>
			
			<xsl:if test="request-param[@name='PROVISIONED_ACCESS_NUMBER_COUNT'] != ''
				and request-param[@name='PROVISIONED_ACCESS_NUMBER_COUNT'] != '0'">								
				<!-- get customer data to retrieve customer category-->
				<xsl:element name="CcmFifGetCustomerDataCmd">
					<xsl:element name="command_id">get_customer_data</xsl:element>
					<xsl:element name="CcmFifGetCustomerDataInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="no_customer_error">N</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- look for the parent's voice account -->
				<xsl:element name="CcmFifFindAccountCmd">
					<xsl:element name="command_id">find_parent_account</xsl:element>
					<xsl:element name="CcmFifFindAccountInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">get_customer_data</xsl:element>
							<xsl:element name="field_name">associated_customer_number</xsl:element>						
						</xsl:element>
						<xsl:element name="type_rd">VOICE</xsl:element>
						<xsl:element name="no_account_error">Y</xsl:element>
					</xsl:element>
				</xsl:element>			
								
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_counting_service</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">Wh012</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>						
						<xsl:element name="desired_date">
							<xsl:value-of select="$desiredDate"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
						<xsl:element name="reason_rd">MODIFY_WHS_VOICE</xsl:element>
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">find_parent_account</xsl:element>
							<xsl:element name="field_name">account_number</xsl:element>
						</xsl:element>					
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
							<xsl:element name="field_name">service_found</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>											
						<xsl:element name="service_characteristic_list">						
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0198</xsl:element>
								<xsl:element name="data_type">INTEGER</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='PROVISIONED_ACCESS_NUMBER_COUNT']"/> 
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>			
			</xsl:if>
			
			<!-- Create Customer Order for new services  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">002v</xsl:element>
					<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">reconfigure_service</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_counting_service</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>																
					<xsl:element name="processing_status">completedOPM</xsl:element>
				</xsl:element>
			</xsl:element>

			<xsl:element name="CcmFifActivateCustomerOrderCmd">
				<xsl:element name="command_id">activate_co</xsl:element>
				<xsl:element name="CcmFifActivateCustomerOrderInCont">
					<xsl:element name="customer_order_id_ref">
						<xsl:element name="command_id">create_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>      
			
			<!-- concat text parts for contact text --> 
			<xsl:element name="CcmFifConcatStringsCmd">
				<xsl:element name="command_id">concat_contact_text</xsl:element>
				<xsl:element name="CcmFifConcatStringsInCont">
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">
								<xsl:text>Wholesale-Voice-Vertrag geändert über </xsl:text>
								<xsl:value-of select="request-param[@name='clientName']"/>
								<xsl:text>&#xA;TransactionID: </xsl:text>
								<xsl:value-of select="request-param[@name='transactionID']"/>
								<xsl:text>&#xA;Vertragsnummer: </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
							<xsl:element name="field_name">contract_number</xsl:element>							
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>							
						
			<!-- Create contact for Service Addition -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="contact_type_rd">MODIFY_WHS_VOICE</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>Wholesale-Voice geändert</xsl:text>
					</xsl:element>
					<xsl:element name="description_text_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">concat_contact_text</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>							
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_wholesale_voice_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>											
				</xsl:element>
			</xsl:element>
            
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
