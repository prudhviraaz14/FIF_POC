<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
	<!--
		XSLT file for creating a FIF request for ordering a Arcor Mobile sim card
		@author schwarje 
	-->
	<xsl:template match="/">
	<xsl:element name="CcmFifCommandList">
		<xsl:apply-templates select="request/request-params"/>
	</xsl:element>
</xsl:template>
<xsl:template match="request-params">
	<!-- Copy over transaction ID, client name, override system date and action name -->
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
		<xsl:variable name="Type" select="request-param[@name='type']"/> 

		<xsl:choose>
			<!-- Validate the zero charge indicator -->
			<xsl:when test="request-param[@name='zeroChargeIndicator'] != ''
				and request-param[@name='zeroChargeIndicator'] != 'JA'
				and request-param[@name='zeroChargeIndicator'] != 'NEIN'">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">zerocharge_error</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">The parameter zeroChargeIndicator has to be set to JA or NEIN!</xsl:element>
					</xsl:element>
				</xsl:element>		
			</xsl:when>
			
			<!-- Validate address details -->
			<xsl:when test="(request-param[@name='hardwareDeliveryAddressID'] = '')
				and (request-param[@name='hardwareDeliveryStreet'] = '' 
				or request-param[@name='hardwareDeliveryNumber'] = '' 
				or request-param[@name='hardwareDeliveryPostalCode'] = '' 
				or request-param[@name='hardwareDeliveryCity'] = '')">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">address_field_error</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">Either address id or address details must be provided.</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:when>		
			
			<!-- Validate the parameter type -->
			<xsl:when test="$Type != ''
				and $Type != 'VoIP'
				and $Type != 'NGNVoIP'
				and $Type != 'NGNDSL'
				and $Type != 'MOFU'
				and $Type != 'IPTV'
				and $Type != 'VOD'		
				and $Type != 'VOICE'
				and $Type != 'ISDN'
				and $Type != 'BitDSL'        
				and $Type != 'BitVoIP'        					
				and request-param[@name='serviceSubscriptionId'] = ''
				and request-param[@name='accessNumber'] = ''">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">type_error</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">The parameter type has to  be set to ISDN, VoIP, MOFU, IPTV, VOD, NGNVoIP, BitDSL, BitVoIP  or NGNDSL!</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:when>
		
			<xsl:otherwise>

				<xsl:element name="CcmFifGetNextAvailableProviderTrackingNumberCmd">
					<xsl:element name="command_id">get_ptn</xsl:element>
					<xsl:element name="CcmFifGetNextAvailableProviderTrackingNumberInCont">
						<xsl:element name="customer_tracking_id">
							<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
						</xsl:element>
						<xsl:element name="provider_tracking_number_suffix">m</xsl:element>
					</xsl:element>
				</xsl:element>				

				<!-- Take value of serviceSubscriptionId from ccm external notification if accessNumber,serviceTicketPositionId,serviceSubscriptionId not provided -->
				<xsl:if test="request-param[@name='serviceSubscriptionId'] = ''">
					<xsl:element name="CcmFifReadExternalNotificationCmd">
						<xsl:element name="command_id">read_main_service</xsl:element>
						<xsl:element name="CcmFifReadExternalNotificationInCont">
							<xsl:element name="transaction_id">
								<xsl:value-of select="request-param[@name='requestListId']"/>
							</xsl:element>
							<xsl:element name="parameter_name">
								<xsl:value-of select="concat($Type, '_SERVICE_SUBSCRIPTION_ID')"/>
							</xsl:element>                        
						</xsl:element>
					</xsl:element>
				</xsl:if>
				
				<xsl:element name="CcmFifFindServiceSubsCmd">
					<xsl:element name="command_id">find_main_service</xsl:element>
					<xsl:element name="CcmFifFindServiceSubsInCont">
						<xsl:choose>
							<xsl:when test="request-param[@name='serviceSubscriptionId'] != ''">
								<xsl:element name="service_subscription_id">
									<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
								</xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="service_subscription_id_ref">
									<xsl:element name="command_id">read_main_service</xsl:element>
									<xsl:element name="field_name">parameter_value</xsl:element>
								</xsl:element>						
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:element>
				
				<xsl:if test="request-param[@name='hardwareDeliveryAddressID'] = ''">
					<!-- Get Entity Information -->
					<xsl:element name="CcmFifGetEntityCmd">
						<xsl:element name="command_id">get_entity</xsl:element>
						<xsl:element name="CcmFifGetEntityInCont">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					<!--Create new hardware address-->
					<xsl:element name="CcmFifCreateAddressCmd">
						<xsl:element name="command_id">create_hardware_address</xsl:element>
						<xsl:element name="CcmFifCreateAddressInCont">
							<xsl:element name="entity_ref">
								<xsl:element name="command_id">get_entity</xsl:element>
								<xsl:element name="field_name">entity_id</xsl:element>
							</xsl:element>
							<xsl:element name="address_type">HARD</xsl:element>
							<xsl:element name="street_name">
								<xsl:value-of select="request-param[@name='hardwareDeliveryStreet']"/>
							</xsl:element>
							<xsl:element name="street_number">
								<xsl:value-of select="request-param[@name='hardwareDeliveryNumber']"/>
							</xsl:element>
							<xsl:element name="street_number_suffix">
								<xsl:value-of
									select="request-param[@name='hardwareDeliveryNumberSuffix']"/>
							</xsl:element>
							<xsl:element name="postal_code">
								<xsl:value-of select="request-param[@name='hardwareDeliveryPostalCode']"/>
							</xsl:element>
							<xsl:element name="city_name">
								<xsl:value-of select="request-param[@name='hardwareDeliveryCity']"/>
							</xsl:element>
							<xsl:element name="city_suffix_name">
								<xsl:value-of select="request-param[@name='hardwareDeliveryCitySuffix']"/>
							</xsl:element>
							<xsl:element name="country_code">DE</xsl:element>
							<xsl:element name="ignore_existing_address">Y</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
				
				<!-- Check customer classification -->
				<xsl:element name="CcmFifGetCustomerDataCmd">
					<xsl:element name="command_id">get_customer_data</xsl:element>
					<xsl:element name="CcmFifGetCustomerDataInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- Concat the result of recent command to create promary value of cross reference  --> 
				<xsl:element name="CcmFifConcatStringsCmd">
					<xsl:element name="command_id">concat_primary_value</xsl:element>
					<xsl:element name="CcmFifConcatStringsInCont">
						<xsl:element name="input_string_list">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">V0088_</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">get_customer_data</xsl:element>
								<xsl:element name="field_name">classification_rd</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>							
				
				<!-- Get service code value for given customer classification from reference data -->
				<xsl:element name="CcmFifGetCrossRefSecondaryValueCmd">
					<xsl:element name="command_id">get_cross_ref_data</xsl:element>
					<xsl:element name="CcmFifGetCrossRefSecondaryValueInCont">
						<xsl:element name="group_code">SCCLASSDEF</xsl:element>
						<xsl:element name="primary_value_ref">
							<xsl:element name="command_id">concat_primary_value</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>
						</xsl:element>
						<xsl:element name="ignore_empty_result">Y</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- Add hardware Service -->				
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_hardware_service</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0114</xsl:element>
						<xsl:element name="sales_organisation_number">
							<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
						</xsl:element>   
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:element name="reason_rd">CREATE_MOBILE</xsl:element>
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">account_number</xsl:element>
						</xsl:element>
						<xsl:element name="service_characteristic_list">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0110</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='hardwareDeliverySalutation']"/>
									<xsl:text>;</xsl:text>
									<xsl:value-of
										select="request-param[@name='hardwareDeliverySurname']"/>
									<xsl:text>;</xsl:text>
									<xsl:value-of
										select="request-param[@name='hardwareDeliveryForename']"/>
								</xsl:element>
							</xsl:element>
							<!-- Lieferanschrift -->
							<xsl:element name="CcmFifAddressCharacteristicCont">
								<xsl:element name="service_char_code">V0111</xsl:element>
								<xsl:element name="data_type">ADDRESS</xsl:element>
								<xsl:if test="request-param[@name='hardwareDeliveryAddressID'] !=''">
									<xsl:element name="address_id">
										<xsl:value-of
											select="request-param[@name='hardwareDeliveryAddressID']"/>
									</xsl:element>
								</xsl:if>
								<xsl:if test="request-param[@name='hardwareDeliveryAddressID'] = ''">
									<xsl:element name="address_ref">
										<xsl:element name="command_id">create_hardware_address</xsl:element>
										<xsl:element name="field_name">address_id</xsl:element>
									</xsl:element>
								</xsl:if>
							</xsl:element>
							<!-- Artikelnumber -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0112</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='articleNumber']"/>
								</xsl:element>
							</xsl:element>
							<!-- Subventionierungskennzeichen -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0114</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='subventionIndicator']"/>
								</xsl:element>
							</xsl:element>
							<!-- Artikelbezeichnung -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0116</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='articleName']"/>
								</xsl:element>
							</xsl:element>
							<!-- Zahlungsoption -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0119</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='shippingCosts']"/>
								</xsl:element>
							</xsl:element>
							<!-- Bestellgrund -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0989</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='orderReason']"/>
								</xsl:element>
							</xsl:element>
							<!-- VO-Nummer -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0990</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
								</xsl:element>
							</xsl:element>
							<!-- Service Provider -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0088</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value_ref">
									<xsl:element name="command_id">get_cross_ref_data</xsl:element>
									<xsl:element name="field_name">secondary_value</xsl:element>          	
								</xsl:element>
							</xsl:element>
							<!-- zeroPrice -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0184</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='zeroChargeIndicator']"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="sub_order_id">
							<xsl:value-of select="request-param[@name='subOrderId']"/>
						</xsl:element>
						<xsl:element name="provider_tracking_no">
							<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>

				<xsl:if test="request-param[@name='requestListId'] != ''">
					<xsl:if test="request-param[@name='standaloneOrder'] = 'Y'">
						<!-- look for a previously created standalone customer order -->				
						<xsl:element name="CcmFifReadExternalNotificationCmd">
							<xsl:element name="command_id">read_standalone_co</xsl:element>
							<xsl:element name="CcmFifReadExternalNotificationInCont">
								<xsl:element name="transaction_id">
									<xsl:value-of select="request-param[@name='requestListId']"/>
								</xsl:element>
								<xsl:element name="parameter_name">STANDALONE_CO</xsl:element>            
								<xsl:element name="ignore_empty_result">Y</xsl:element>            
							</xsl:element>
						</xsl:element>
						
						<!-- Add STPs to customer order if exists -->
						<xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
							<xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
								<xsl:element name="customer_order_id_ref">
									<xsl:element name="command_id">read_standalone_co</xsl:element>
									<xsl:element name="field_name">parameter_value</xsl:element>
								</xsl:element>
								<xsl:element name="service_ticket_pos_list">
									<xsl:element name="CcmFifCommandRefCont">
										<xsl:element name="command_id">add_hardware_service</xsl:element>
										<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
									</xsl:element>
								</xsl:element>						
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">read_standalone_co</xsl:element>
									<xsl:element name="field_name">value_found</xsl:element>
								</xsl:element>
								<xsl:element name="required_process_ind">Y</xsl:element>
							</xsl:element>
						</xsl:element>						
					</xsl:if>
					
					<xsl:if test="request-param[@name='standaloneOrder'] != 'Y'">
						<!-- find main access stp in case of hw service -->
						<xsl:element name="CcmFifFindServiceTicketPositionCmd">
							<xsl:element name="command_id">find_main_access_stp</xsl:element>
							<xsl:element name="CcmFifFindServiceTicketPositionInCont">
								<xsl:element name="service_subscription_id_ref">
									<xsl:element name="command_id">find_main_service</xsl:element>
									<xsl:element name="field_name">service_subscription_id</xsl:element>
								</xsl:element>
								<xsl:element name="no_stp_error">N</xsl:element>
								<xsl:element name="find_stp_parameters">
									<xsl:element name="CcmFifFindStpParameterCont">
										<xsl:element name="usage_mode_value_rd">2</xsl:element>
										<xsl:element name="customer_order_state">RELEASED</xsl:element>
									</xsl:element>
									<xsl:element name="CcmFifFindStpParameterCont">
										<xsl:element name="usage_mode_value_rd">1</xsl:element>
										<xsl:element name="customer_order_state">RELEASED</xsl:element>
									</xsl:element>
									<xsl:element name="CcmFifFindStpParameterCont">
										<xsl:element name="usage_mode_value_rd">1</xsl:element>
										<xsl:element name="customer_order_state">COMPLETED</xsl:element>
									</xsl:element>
									<xsl:element name="CcmFifFindStpParameterCont">
										<xsl:element name="usage_mode_value_rd">1</xsl:element>
										<xsl:element name="customer_order_state">FINAL</xsl:element>
									</xsl:element>									
								</xsl:element>
							</xsl:element>
						</xsl:element>
						
						<xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
							<xsl:element name="command_id">find_customer_order</xsl:element>
							<xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
								<xsl:element name="service_ticket_position_id_ref">
									<xsl:element name="command_id">find_main_access_stp</xsl:element>
									<xsl:element name="field_name">service_ticket_position_id</xsl:element>
								</xsl:element>
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">find_main_access_stp</xsl:element>
									<xsl:element name="field_name">stp_found</xsl:element>							
								</xsl:element>
								<xsl:element name="required_process_ind">Y</xsl:element>
							</xsl:element>
						</xsl:element>
						
						<xsl:element name="CcmFifMapStringCmd">
							<xsl:element name="command_id">mapCreateCO</xsl:element>
							<xsl:element name="CcmFifMapStringInCont">
								<xsl:element name="input_string_type">STPState</xsl:element>
								<xsl:element name="input_string_ref">
									<xsl:element name="command_id">find_customer_order</xsl:element>
									<xsl:element name="field_name">state_rd</xsl:element>							
								</xsl:element>
								<xsl:element name="output_string_type">CreateCO</xsl:element>
								<xsl:element name="string_mapping_list">
									<xsl:element name="CcmFifStringMappingCont">
										<xsl:element name="input_string">PROVISIONED</xsl:element>
										<xsl:element name="output_string">dependent</xsl:element>
									</xsl:element>
									<xsl:element name="CcmFifStringMappingCont">
										<xsl:element name="input_string">INSTALLED</xsl:element>
										<xsl:element name="output_string">dependent</xsl:element>
									</xsl:element>
									<xsl:element name="CcmFifStringMappingCont">
										<xsl:element name="input_string">ACTIVATED</xsl:element>
										<xsl:element name="output_string">independent</xsl:element>
									</xsl:element>
								</xsl:element>
								<xsl:element name="no_mapping_error">N</xsl:element>
							</xsl:element>
						</xsl:element>
						
						<!-- Add STPs to customer order if exists -->
						<xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
							<xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
								<xsl:element name="customer_order_id_ref">
									<xsl:element name="command_id">find_customer_order</xsl:element>
									<xsl:element name="field_name">customer_order_id</xsl:element>
								</xsl:element>
								<xsl:element name="service_ticket_pos_list">
									<xsl:element name="CcmFifCommandRefCont">
										<xsl:element name="command_id">add_hardware_service</xsl:element>
										<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
									</xsl:element>
								</xsl:element>						
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">mapCreateCO</xsl:element>
									<xsl:element name="field_name">output_string_found</xsl:element>							
								</xsl:element>
								<xsl:element name="required_process_ind">N</xsl:element>
							</xsl:element>
						</xsl:element>
						
						<xsl:element name="CcmFifCreateCustOrderCmd">
							<xsl:element name="command_id">createNonStandaloneHWOrder</xsl:element>
							<xsl:element name="CcmFifCreateCustOrderInCont">
								<xsl:element name="customer_number_ref">
									<xsl:element name="command_id">find_main_service</xsl:element>
									<xsl:element name="field_name">customer_number</xsl:element>
								</xsl:element>
								<xsl:element name="cust_order_description">SIM-Kartenbestellung</xsl:element>
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
										<xsl:element name="command_id">add_hardware_service</xsl:element>
										<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
									</xsl:element>
								</xsl:element>
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">mapCreateCO</xsl:element>
									<xsl:element name="field_name">output_string_found</xsl:element>							
								</xsl:element>
								<xsl:element name="required_process_ind">Y</xsl:element>								
								<xsl:element name="e_shop_id">
									<xsl:value-of select="request-param[@name='eShopID']"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
						
					</xsl:if>					
				</xsl:if>
				
				<!-- Create stand alone Customer Order for new service if there's no open C.O. -->
				<xsl:element name="CcmFifCreateCustOrderCmd">
					<xsl:element name="command_id">create_co</xsl:element>
					<xsl:element name="CcmFifCreateCustOrderInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="cust_order_description">SIM-Kartenbestellung</xsl:element>
						<xsl:element name="customer_tracking_id">
							<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
						</xsl:element>
						<xsl:element name="lan_path_file_string">
							<xsl:value-of select="request-param[@name='lanPathFileString']"/>
						</xsl:element>
						<xsl:element name="sales_rep_dept">
							<xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
						</xsl:element>
						<xsl:element name="provider_tracking_no">
							<xsl:choose>
								<xsl:when test="request-param[@name='providerTrackingNumber'] != ''">
									<xsl:value-of select="substring(request-param[@name='providerTrackingNumber'], 0, 4)"/>
									<xsl:text>z</xsl:text>
								</xsl:when>
								<xsl:otherwise>001z</xsl:otherwise>
							</xsl:choose>							
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
								<xsl:element name="command_id">add_hardware_service</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:if test="request-param[@name='requestListId'] != ''">
							<xsl:if test="request-param[@name='standaloneOrder'] = 'Y'">
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">read_standalone_co</xsl:element>
									<xsl:element name="field_name">value_found</xsl:element>
								</xsl:element>
								<xsl:element name="required_process_ind">N</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='standaloneOrder'] != 'Y'">
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">find_main_access_stp</xsl:element>
									<xsl:element name="field_name">stp_found</xsl:element>							
								</xsl:element>
								<xsl:element name="required_process_ind">N</xsl:element>								
							</xsl:if>
						</xsl:if>
						<xsl:element name="e_shop_id">
							<xsl:value-of select="request-param[@name='eShopID']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!--Release customer order for hardware service-->
				<xsl:element name="CcmFifReleaseCustOrderCmd">
					<xsl:element name="CcmFifReleaseCustOrderInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="customer_order_ref">
							<xsl:element name="command_id">create_co</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>
						</xsl:element>
						<xsl:if test="request-param[@name='requestListId'] != ''">
							<xsl:if test="request-param[@name='standaloneOrder'] = 'Y'">
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">read_standalone_co</xsl:element>
									<xsl:element name="field_name">value_found</xsl:element>
								</xsl:element>
								<xsl:element name="required_process_ind">N</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='standaloneOrder'] != 'Y'">
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">find_main_access_stp</xsl:element>
									<xsl:element name="field_name">stp_found</xsl:element>							
								</xsl:element>
								<xsl:element name="required_process_ind">N</xsl:element>								
							</xsl:if>
						</xsl:if>
					</xsl:element>
				</xsl:element>
				
				<!--Release customer order for hardware service-->
				<xsl:element name="CcmFifReleaseCustOrderCmd">
					<xsl:element name="CcmFifReleaseCustOrderInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="customer_order_ref">
							<xsl:element name="command_id">createNonStandaloneHWOrder</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>
						</xsl:element>
						<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">mapCreateCO</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>							
						</xsl:element>
						<xsl:element name="required_process_ind">independent</xsl:element>								
					</xsl:element>
				</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderCmd">
					<xsl:element name="CcmFifReleaseCustOrderInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="customer_order_ref">
							<xsl:element name="command_id">createNonStandaloneHWOrder</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>
						</xsl:element>
						<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">mapCreateCO</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>							
						</xsl:element>
						<xsl:element name="required_process_ind">dependent</xsl:element>
						<xsl:element name="parent_customer_order_id_ref">
							<xsl:element name="command_id">find_customer_order</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>							
						</xsl:element>								
					</xsl:element>
				</xsl:element>
				
				<xsl:if test="request-param[@name='primaryCustSignDate'] != '' and
					request-param[@name='tariff'] != ''">

					<!-- Create Order Form-->
					<xsl:element name="CcmFifCreateOrderFormCmd">
						<xsl:element name="command_id">create_mobile_contract</xsl:element>
						<xsl:element name="CcmFifCreateOrderFormInCont">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
							<xsl:element name="min_per_dur_value">
								<xsl:value-of select="request-param[@name='minPeriodDurationValue']"/>
							</xsl:element>
							<xsl:element name="min_per_dur_unit">
								<xsl:value-of select="request-param[@name='minPeriodDurationUnit']"/>
							</xsl:element>
							<xsl:element name="sales_org_num_value">
								<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
							</xsl:element>
							<xsl:element name="sales_org_num_value_vf">
								<xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
							</xsl:element>
							<xsl:element name="doc_template_name">Vertrag</xsl:element>
							<xsl:element name="assoc_skeleton_cont_num">
								<xsl:value-of select="request-param[@name='assocSkeletonContNum']"/>
							</xsl:element>
							<xsl:element name="auto_extent_period_value">
								<xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>
							</xsl:element>                         
							<xsl:element name="auto_extent_period_unit">
								<xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>
							</xsl:element>                         
							<xsl:element name="auto_extension_ind">
								<xsl:value-of select="request-param[@name='autoExtensionInd']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>		
					
					<xsl:element name="CcmFifAddProductCommitCmd">
						<xsl:element name="command_id">add_mobile_product_commitment</xsl:element>
						<xsl:element name="CcmFifAddProductCommitInCont">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
							<xsl:element name="contract_number_ref">
								<xsl:element name="command_id">create_mobile_contract</xsl:element>
								<xsl:element name="field_name">contract_number</xsl:element>
							</xsl:element>
							<xsl:element name="product_code">V8000</xsl:element>
							<xsl:element name="pricing_structure_code">
								<xsl:value-of select="request-param[@name='tariff']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					
					<xsl:element name="CcmFifSignOrderFormCmd">
						<xsl:element name="command_id">populate_sign_date</xsl:element>
						<xsl:element name="CcmFifSignOrderFormInCont">
							<xsl:element name="contract_number_ref">
								<xsl:element name="command_id">create_mobile_contract</xsl:element>
								<xsl:element name="field_name">contract_number</xsl:element>
							</xsl:element>
							<xsl:element name="board_sign_name">ARCOR</xsl:element>							
							<xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
							<xsl:element name="primary_cust_sign_date">
								<xsl:value-of select="request-param[@name='primaryCustSignDate']"/>
							</xsl:element>
							<xsl:element name="sign_ind">N</xsl:element>
						</xsl:element>
					</xsl:element>					
					
					<xsl:element name="CcmFifAddProductSubsCmd">
						<xsl:element name="command_id">add_mobile_ps</xsl:element>
						<xsl:element name="CcmFifAddProductSubsInCont">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
							<xsl:element name="product_commitment_number_ref">
								<xsl:element name="command_id">add_mobile_product_commitment</xsl:element>
								<xsl:element name="field_name">product_commitment_number</xsl:element>
							</xsl:element>	
						</xsl:element>
					</xsl:element>
					
					<!-- Add Mobile Phone main Service V8000 -->
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">add_mobile_service</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">add_mobile_ps</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">V8000</xsl:element>
							<xsl:element name="desired_schedule_type">ASAP</xsl:element>
							<xsl:element name="reason_rd">CREATE_MOBILE</xsl:element>        
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
							<xsl:element name="service_characteristic_list">
								<!-- Rufnummer -->
								<!-- TODO defaults or from input 
								<xsl:element name="CcmFifAccessNumberCont">
									<xsl:element name="service_char_code">V0180</xsl:element>
									<xsl:element name="data_type">MOBIL_ACCESS_NUM</xsl:element>
									<xsl:element name="masking_digits_rd"/>									
									<xsl:element name="retention_period_rd"/>									
									<xsl:element name="storage_masking_digits_rd"/>																
									<xsl:element name="validate_duplicate_indicator">Y</xsl:element>
									<xsl:element name="country_code">49</xsl:element>
									<xsl:element name="city_code">dummy</xsl:element>
									<xsl:element name="local_number">dummy</xsl:element>
								</xsl:element>			
								-->							
								<!-- Artikelnummer -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0178</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='articleNumber']"/>
									</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					
					<!-- Create Customer Order for new services  -->
					<xsl:element name="CcmFifCreateCustOrderCmd">
						<xsl:element name="command_id">create_mobile_co</xsl:element>
						<xsl:element name="CcmFifCreateCustOrderInCont">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
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
							<xsl:element name="provider_tracking_no_ref">
								<xsl:element name="command_id">get_ptn</xsl:element>
								<xsl:element name="field_name">provider_tracking_number</xsl:element>
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
								<!-- V8000 -->
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">add_mobile_service</xsl:element>
									<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
								</xsl:element>
							</xsl:element>
							<xsl:element name="generate_customer_tracking_id">Y</xsl:element>
						</xsl:element>
					</xsl:element>
					
					<!-- find bundle for service, if exists -->
					<xsl:element name="CcmFifFindBundleCmd">
						<xsl:element name="command_id">find_bundle</xsl:element>
						<xsl:element name="CcmFifFindBundleInCont">
							<xsl:element name="supported_object_id_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
						</xsl:element>
					</xsl:element>
					
					<!-- add the new bundle item of type MOBILE_SERVICE --> 
					<xsl:element name="CcmFifModifyBundleItemCmd">
						<xsl:element name="command_id">add_mobile_bundle_item</xsl:element>
						<xsl:element name="CcmFifModifyBundleItemInCont">
							<xsl:element name="bundle_id_ref">
								<xsl:element name="command_id">find_bundle</xsl:element>
								<xsl:element name="field_name">bundle_id</xsl:element>
							</xsl:element>
							<xsl:element name="bundle_item_type_rd">MOBILE_SERVICE</xsl:element>
							<xsl:element name="supported_object_id_ref">
								<xsl:element name="command_id">add_mobile_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
							<xsl:element name="action_name">ADD</xsl:element>
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">find_bundle</xsl:element>
								<xsl:element name="field_name">bundle_found</xsl:element>							
							</xsl:element>
							<xsl:element name="required_process_ind">Y</xsl:element>															
						</xsl:element>
					</xsl:element>			
					
					<xsl:element name="CcmFifCreateExternalNotificationCmd">
						<xsl:element name="command_id">create_mobile_service_notif</xsl:element>
						<xsl:element name="CcmFifCreateExternalNotificationInCont">
							<xsl:element name="transaction_id">
								<xsl:value-of select="request-param[@name='requestListId']"/>
							</xsl:element>
							<xsl:element name="notification_action_name">mobileContractIdentifier</xsl:element>
							<xsl:element name="target_system">FIF</xsl:element>
							<xsl:element name="parameter_value_list">
								<xsl:element name="CcmFifParameterValueCont">
									<xsl:element name="parameter_name">
										<xsl:value-of select="request-param[@name='transactionID']"/>
										<xsl:text>_SERVICE_SUBSCRIPTION_ID</xsl:text>
									</xsl:element>
									<xsl:element name="parameter_value_ref">
										<xsl:element name="command_id">add_mobile_service</xsl:element>
										<xsl:element name="field_name">service_subscription_id</xsl:element>
									</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
				
				<xsl:element name="CcmFifConcatStringsCmd">
					<xsl:element name="command_id">concat_contact_text</xsl:element>
					<xsl:element name="CcmFifConcatStringsInCont">
						<xsl:element name="input_string_list">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">
									<xsl:text>SIM-Karte (Artikelnummer: </xsl:text>
									<xsl:value-of select="request-param[@name='articleNumber']"/>
									<xsl:text>) bestellt über </xsl:text>
									<xsl:value-of select="request-param[@name='clientName']"/>							
									<xsl:text>&#xA;TransactionID: </xsl:text>
									<xsl:value-of select="request-param[@name='transactionID']"/>
									<xsl:text>&#xA;Dienstenutzung: </xsl:text>		
								</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_hardware_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>							
							</xsl:element>
							<xsl:if test="request-param[@name='primaryCustSignDate'] != '' and
								request-param[@name='tariff'] != ''">
								<xsl:element name="CcmFifPassingValueCont">
									<xsl:element name="value">
										<xsl:text>&#xA;Mobilfunkvertrag: </xsl:text>
									</xsl:element>
								</xsl:element>
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">create_mobile_contract</xsl:element>
									<xsl:element name="field_name">contract_number</xsl:element>
								</xsl:element>								
							</xsl:if>
						</xsl:element>
					</xsl:element>
				</xsl:element>							
				
				<!-- Create Contact for hardware Service Addition -->
				<xsl:element name="CcmFifCreateContactCmd">
					<xsl:element name="CcmFifCreateContactInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="contact_type_rd">CREATE_MOBILE</xsl:element>
						<xsl:element name="short_description">SIM-Karte bestellt</xsl:element>
						<xsl:element name="description_text_list">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">concat_contact_text</xsl:element>
								<xsl:element name="field_name">output_string</xsl:element>							
							</xsl:element>
						</xsl:element>						
					</xsl:element>
				</xsl:element>
				
				<!-- Create External notification  -->
				<xsl:if test="request-param[@name='requestListId'] != '' and 
					request-param[@name='standaloneOrder'] = 'Y'">				
					<xsl:element name="CcmFifCreateExternalNotificationCmd">
						<xsl:element name="command_id">create_standalone_co_notification</xsl:element>
						<xsl:element name="CcmFifCreateExternalNotificationInCont">
							<xsl:element name="transaction_id">
								<xsl:value-of select="request-param[@name='requestListId']"/>
							</xsl:element>
							<xsl:element name="notification_action_name">standaloneCustomerOrder</xsl:element>
							<xsl:element name="target_system">FIF</xsl:element>
							<xsl:element name="parameter_value_list">
								<xsl:element name="CcmFifParameterValueCont">
									<xsl:element name="parameter_name">STANDALONE_CO</xsl:element>
									<xsl:element name="parameter_value_ref">
										<xsl:element name="command_id">create_co</xsl:element>
										<xsl:element name="field_name">customer_order_id</xsl:element>
									</xsl:element>
								</xsl:element>
							</xsl:element>
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">read_standalone_co</xsl:element>
								<xsl:element name="field_name">value_found</xsl:element>
							</xsl:element>
							<xsl:element name="required_process_ind">N</xsl:element>							
						</xsl:element>
					</xsl:element>
				</xsl:if>				
				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>
</xsl:stylesheet>
