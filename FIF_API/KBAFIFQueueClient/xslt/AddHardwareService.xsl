<?xml version="1.0" encoding="utf-8"?>

<!DOCTYPE XSL [
<!ENTITY AddSurchargeService SYSTEM "AddSurchargeService.xsl">
]> 

<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
	<!--
		XSLT file for creating a FIF request for Adding Hardware Service
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

	<!-- Convert the delivery date to OPM format -->
	<xsl:variable name="deliveryDateOPM">
		<xsl:if test="request-param[@name='deliveryDate'] != ''">
			<xsl:value-of select="dateutils:createOPMDate(request-param[@name='deliveryDate'])"/>		
		</xsl:if>
	</xsl:variable>
	
	<xsl:element name="Command_List">
		
		<xsl:variable name="usageMode">
			<xsl:choose>
				<xsl:when test="request-param[@name='isRentedHardware'] = 'Y'">6</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="request-param[@name='functionID'] != ''">
			<xsl:element name="CcmFifConcatStringsCmd">
				<xsl:element name="command_id">functionID</xsl:element>
				<xsl:element name="CcmFifConcatStringsInCont">
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">
								<xsl:value-of select="request-param[@name='functionID']"/>
							</xsl:element>							
						</xsl:element>                
					</xsl:element>
				</xsl:element>
			</xsl:element>     

			<xsl:element name="CcmFifConcatStringsCmd">
				<xsl:element name="command_id">functionStatus</xsl:element>
				<xsl:element name="CcmFifConcatStringsInCont">
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">
								<xsl:choose>
									<xsl:when test="request-param[@name='processingStatus'] = 'completedOPM'">SUCCESS</xsl:when>
									<xsl:otherwise>ACKNOWLEDGED</xsl:otherwise>                  
								</xsl:choose>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>			
		</xsl:if>         
		
		<!-- Read the customer order from the external notification -->
		<xsl:element name="CcmFifReadExternalNotificationCmd">
			<xsl:element name="command_id">read_customer_order</xsl:element>
			<xsl:element name="CcmFifReadExternalNotificationInCont">
				<xsl:element name="transaction_id">
					<xsl:value-of select="request-param[@name='requestListId']"/>
				</xsl:element>
				<xsl:element name="parameter_name">
					<xsl:value-of select="request-param[@name='type']"/>
					<xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
				</xsl:element>
				<xsl:element name="ignore_empty_result">Y</xsl:element>
			</xsl:element>
		</xsl:element>  
		
		<xsl:choose>
			<!-- simple addHardwareService, after OPM has completed the order -->
			<xsl:when test="request-param[@name='processingStatus'] = 'completedOPM'">
				
				<!-- Get bundle id -->     
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_bundle_id</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="parameter_name">
							<xsl:text>BUNDLE_ID</xsl:text>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- check if the SS provided is still active -->
				<xsl:element name="CcmFifFindServiceTicketPositionCmd">
					<xsl:element name="command_id">find_main_stp</xsl:element>
					<xsl:element name="CcmFifFindServiceTicketPositionInCont">
						<xsl:element name="service_subscription_id">
							<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
						</xsl:element>
						<xsl:element name="no_stp_error">N</xsl:element>
						<xsl:element name="find_stp_parameters">
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">ORDERED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- if the SS provided is no longer active, look for the main access service in the bundle -->
				<xsl:element name="CcmFifFindServiceTicketPositionCmd">
					<xsl:element name="command_id">find_main_stp</xsl:element>
					<xsl:element name="CcmFifFindServiceTicketPositionInCont">
						<xsl:element name="no_stp_error">Y</xsl:element>
						<xsl:element name="bundle_id_ref">
							<xsl:element name="command_id">read_bundle_id</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
						<xsl:element name="find_stp_parameters">
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">V0003</xsl:element>								
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">V0010</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">V0011</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">V0012</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">I1210</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">I1213</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">I1290</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">VI010</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>							
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">VI020</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>							
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">VI021</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>							
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">VI250</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>							
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">find_main_stp</xsl:element>
							<xsl:element name="field_name">stp_found</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">N</xsl:element>						
					</xsl:element>
				</xsl:element>
				
				<!-- get service by STP found before -->
				<xsl:element name="CcmFifFindServiceSubsCmd">
					<xsl:element name="command_id">find_main_service</xsl:element>
					<xsl:element name="CcmFifFindServiceSubsInCont">
						<xsl:element name="service_ticket_position_id_ref">
							<xsl:element name="command_id">find_main_stp</xsl:element>
							<xsl:element name="field_name">service_ticket_position_id</xsl:element>
						</xsl:element>
						<xsl:element name="no_service_error">Y</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">find_main_stp</xsl:element>
							<xsl:element name="field_name">stp_found</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>						
					</xsl:element>
				</xsl:element>
				
				<xsl:if test="request-param[@name='hardwareDeliveryAddressID'] = ''">
					<!-- Get Entity Information -->
					<xsl:element name="CcmFifGetEntityCmd">
						<xsl:element name="command_id">get_entity_1</xsl:element>
						<xsl:element name="CcmFifGetEntityInCont">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					<!--Create new hardware address-->
					<xsl:element name="CcmFifCreateAddressCmd">
						<xsl:element name="command_id">create_addr_1</xsl:element>
						<xsl:element name="CcmFifCreateAddressInCont">
							<xsl:element name="entity_ref">
								<xsl:element name="command_id">get_entity_1</xsl:element>
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
							<xsl:if test="request-param[@name='validationTypeRd'] != ''">
								<xsl:element name="validation_type_rd">
									<xsl:value-of select="request-param[@name='validationTypeRd']"/>
								</xsl:element>
							</xsl:if>
						</xsl:element>
					</xsl:element>
				</xsl:if>				
				
				<!-- Add hardware Service -->				
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_hardware_service</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:value-of select="request-param[@name='hardwareServiceCode']"/>
						</xsl:element>
						<xsl:element name="sales_organisation_number">
							<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
						</xsl:element>   
						<xsl:element name="sales_organisation_number_vf">
							<xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
						</xsl:element>   
						<xsl:element name="service_subscription_id">
							<xsl:value-of select="request-param[@name='allocatedServiceSubscriptionId']"/>
						</xsl:element>
						<xsl:if test="request-param[@name='isDependentService'] = 'Y'">
							<xsl:element name="parent_service_subs_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:element name="reason_rd">
							<xsl:value-of select="request-param[@name='reason']"/>
						</xsl:element>								
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">account_number</xsl:element>
						</xsl:element>
						<xsl:element name="usage_mode_value_rd">
							<xsl:value-of select="$usageMode"/>
						</xsl:element>
						<xsl:element name="service_characteristic_list">
							<xsl:if test="request-param[@name='remarks'] != ''">
								<!-- Bemerkung -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0008</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='remarks']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Seriennummer -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0109</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='serialNumber']"/>
								</xsl:element>
							</xsl:element>
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
										<xsl:element name="command_id">create_addr_1</xsl:element>
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
							<!-- V0117  Prüfziffer -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0117</xsl:element>
								<xsl:element name="data_type">DECIMAL</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='checkingNumber']"/>
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
								<xsl:element name="configured_value">          	
									<xsl:value-of select="request-param[@name='serviceProvider']"/>
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
					        <!-- I1337 Imei -->
					        <xsl:element name="CcmFifConfiguredValueCont">
					            <xsl:element name="service_char_code">I1337</xsl:element>
					            <xsl:element name="data_type">STRING</xsl:element>
					            <xsl:element name="configured_value">
					                <xsl:value-of select="request-param[@name='imei']"/>
					            </xsl:element>
					        </xsl:element>
						    <!-- I1338 Hardware-Aktionscode -->
						    <xsl:element name="CcmFifConfiguredValueCont">
						        <xsl:element name="service_char_code">I1338</xsl:element>
						        <xsl:element name="data_type">STRING</xsl:element>
						        <xsl:element name="configured_value">
						            <xsl:value-of select="request-param[@name='sapActionCode']"/>
						        </xsl:element>
						    </xsl:element>		
							<!-- I1336 Hardware-sapOrderId -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">I1336</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='sapOrderId']"/>
								</xsl:element>
							</xsl:element>
							<xsl:if test="request-param[@name='simSerialNumber'] != ''">
							<!-- V0108 SIM ID -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0108</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='simSerialNumber']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- V0884 delivery note number -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0884</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='deliveryNoteNumber']"/>
								</xsl:element>
							</xsl:element>						    
							<!-- V0885 delivery date -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0885</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="$deliveryDateOPM" /> 
								</xsl:element>
							</xsl:element>						    
							<!-- VI115 Anzahl -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">VI115</xsl:element>
								<xsl:element name="data_type">INTEGER</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='quantity']"/>
								</xsl:element>
							</xsl:element>						    
							<!-- VI120 Techniker Info zum Kunden -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">VI120</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='remarkForTechnician']"/>
								</xsl:element>
							</xsl:element>						    
						</xsl:element>
						<xsl:element name="provider_tracking_no">
							<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			
			    <xsl:if test="request-param[@name='surchargeIndicator'] = 'Y'">			        
			        &AddSurchargeService;
			    </xsl:if>
				
				<!-- Add STPs to subscribe customer order if exists -->   
				<xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
					<xsl:element name="command_id">add_stp_to_co</xsl:element>
					<xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
						<xsl:element name="customer_order_id_ref">
							<xsl:element name="command_id">read_customer_order</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
						<xsl:element name="service_ticket_pos_list">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_hardware_service</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						    <xsl:element name="CcmFifCommandRefCont">
						        <xsl:element name="command_id">add_service_surcharge</xsl:element>
						        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						    </xsl:element>
						</xsl:element>
						<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
						<xsl:element name="processing_status">
							<xsl:value-of select="request-param[@name='processingStatus']"/>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">read_customer_order</xsl:element>
							<xsl:element name="field_name">value_found</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>   
					</xsl:element>
				</xsl:element>
				
				<!-- Create Customer Order if neither reconfigure or subscribe customer orders not exist -->
				<xsl:element name="CcmFifCreateCustOrderCmd">
					<xsl:element name="command_id">create_co</xsl:element>
					<xsl:element name="CcmFifCreateCustOrderInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="cust_order_description">Erstellung Hardwaredienst</xsl:element>          
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
							<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
						</xsl:element>
						<xsl:element name="super_customer_tracking_id">
							<xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
						</xsl:element>
						<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
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
						    <xsl:element name="CcmFifCommandRefCont">
						        <xsl:element name="command_id">add_service_surcharge</xsl:element>
						        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						    </xsl:element>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">read_customer_order</xsl:element>
							<xsl:element name="field_name">value_found</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">N</xsl:element>   
						<xsl:element name="e_shop_id">
							<xsl:value-of select="request-param[@name='eShopID']"/>
						</xsl:element>
						<xsl:element name="processing_status">
							<xsl:value-of select="request-param[@name='processingStatus']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
			</xsl:when>
			<!-- "old" addHardwareService -->
			<xsl:otherwise>
				
				<xsl:variable name="Type">
					<xsl:choose>
						<xsl:when test="request-param[@name='accessNumber'] != ''"/>				
						<xsl:when test="request-param[@name='serviceSubscriptionId'] != ''"/>
						<xsl:otherwise>
							<xsl:value-of select="request-param[@name='type']"/>
						</xsl:otherwise>				
					</xsl:choose>
				</xsl:variable> 
				
				<!-- Validate the zero charge indicator -->
				<xsl:if test="request-param[@name='zeroChargeIndicator'] != ''
					and request-param[@name='zeroChargeIndicator'] != 'JA'
					and request-param[@name='zeroChargeIndicator'] != 'NEIN'">
					<xsl:element name="CcmFifRaiseErrorCmd">
						<xsl:element name="command_id">zerocharge_error</xsl:element>
						<xsl:element name="CcmFifRaiseErrorInCont">
							<xsl:element name="error_text">The parameter zeroChargeIndicator has to be set to JA or NEIN!</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>		
				
				<!-- Validate address details -->
				<xsl:if test="(request-param[@name='hardwareDeliveryAddressID'] = '')
					and (( request-param[@name='hardwareDeliveryStreet'] = '' )
					or( request-param[@name='hardwareDeliveryNumber'] = '' )
					or( request-param[@name='hardwareDeliveryPostalCode'] = '' )
					or( request-param[@name='hardwareDeliveryCity'] = '' ))">
					<xsl:element name="CcmFifRaiseErrorCmd">
						<xsl:element name="command_id">address_field_error</xsl:element>
						<xsl:element name="CcmFifRaiseErrorInCont">
							<xsl:element name="error_text">Either address id or address details must be provided.</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>		
				
				<xsl:choose>
					<xsl:when test="request-param[@name='providerTrackingNumber'] != ''"/>
					<xsl:otherwise>
						<!-- get the next available PTN for the OMTSOrderID -->
						<xsl:element name="CcmFifGetNextAvailableProviderTrackingNumberCmd">
							<xsl:element name="command_id">get_ptn</xsl:element>
							<xsl:element name="CcmFifGetNextAvailableProviderTrackingNumberInCont">
								<xsl:element name="customer_tracking_id">
									<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
				
				<!-- Find Service Subscription by access number, STP Id or Service Subscription Id-->
				<xsl:if test="$Type = ''">
					<xsl:element name="CcmFifFindServiceSubsCmd">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="CcmFifFindServiceSubsInCont">
							<xsl:if test="((request-param[@name='accessNumber'] != '' )and
								(request-param[@name='serviceSubscriptionId'] = ''))">
								<xsl:element name="access_number">
									<xsl:value-of select="request-param[@name='accessNumber']"/>
								</xsl:element>
								<xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
								<xsl:element name="effective_date">
									<xsl:value-of select="request-param[@name='desiredDate']"/>
								</xsl:element>
								<xsl:element name="customer_number">
									<xsl:value-of select="request-param[@name='customerNumber']"/>
								</xsl:element>
								<xsl:element name="contract_number">
									<xsl:value-of select="request-param[@name='contractNumber']"/>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
								<xsl:element name="service_subscription_id">
									<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
								</xsl:element>
							</xsl:if>
						</xsl:element>
					</xsl:element>
				</xsl:if>
				
				<xsl:if test="$Type != ''">                          
					<xsl:element name="CcmFifReadExternalNotificationCmd">
						<xsl:element name="command_id">read_external_notification_2</xsl:element>
						<xsl:element name="CcmFifReadExternalNotificationInCont">
							<xsl:element name="transaction_id">
								<xsl:value-of select="request-param[@name='requestListId']"/>
							</xsl:element>
							<xsl:element name="parameter_name">
								<xsl:value-of select="concat($Type, '_SERVICE_SUBSCRIPTION_ID')"/>
							</xsl:element>                        
						</xsl:element>
					</xsl:element>
					
					<xsl:element name="CcmFifFindServiceSubsCmd">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="CcmFifFindServiceSubsInCont">
							<xsl:element name="service_subscription_id_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:if test="request-param[@name='hardwareServiceCode'] = 'V011A'">  
						
						<xsl:element name="CcmFifFindExclusiveChildServSubsCmd">
							<xsl:element name="command_id">find_excl_child_1</xsl:element>
							<xsl:element name="CcmFifFindExclusiveChildServSubsInCont">
								<xsl:element name="parent_service_subs_ref">
									<xsl:element name="command_id">find_main_service</xsl:element>
									<xsl:element name="field_name">service_subscription_id</xsl:element>
								</xsl:element>
								<xsl:element name="service_code_list">
									<!-- V001A -->		  
									<xsl:element name="CcmFifPassingValueCont">
										<xsl:element name="service_code">V011A</xsl:element>
									</xsl:element>          		  
								</xsl:element>
							</xsl:element>
						</xsl:element>
						
						<!-- find STP -->
						<xsl:element name="CcmFifFindServiceTicketPositionCmd">
							<xsl:element name="command_id">find_hardware_stp_1</xsl:element>
							<xsl:element name="CcmFifFindServiceTicketPositionInCont">
								<xsl:element name="service_subscription_id_ref">
									<xsl:element name="command_id">find_excl_child_1</xsl:element>
									<xsl:element name="field_name">service_subscription_id</xsl:element>
								</xsl:element>
								<xsl:element name="usage_mode_value_rd">5</xsl:element>
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">find_excl_child_1</xsl:element>
									<xsl:element name="field_name">service_found</xsl:element>          	
								</xsl:element>
								<xsl:element name="required_process_ind">Y</xsl:element>
							</xsl:element>
						</xsl:element>
						
						<!-- cancel hardware STP -->
						
						<xsl:element name="CcmFifCancelServiceTicketPositionCmd">
							<xsl:element name="command_id">cancel_hardware_service_1</xsl:element>
							<xsl:element name="CcmFifCancelServiceTicketPositionInCont">
								<xsl:element name="service_ticket_position_id_ref">
									<xsl:element name="command_id">find_hardware_stp_1</xsl:element>
									<xsl:element name="field_name">service_ticket_position_id</xsl:element>          	
								</xsl:element>
								<xsl:element name="cancel_reason_rd">CUST_REQUEST</xsl:element>
								<xsl:element name="remove_cust_order_id">Y</xsl:element>
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">find_hardware_stp_1</xsl:element>
									<xsl:element name="field_name">stp_found</xsl:element>          	
								</xsl:element>
								<xsl:element name="required_process_ind">Y</xsl:element>            
							</xsl:element>
						</xsl:element>
						
					</xsl:if>			
				</xsl:if>
				

				<xsl:if test="request-param[@name='hardwareDeliveryAddressID'] = ''">
					<!-- Get Entity Information -->
					<xsl:element name="CcmFifGetEntityCmd">
						<xsl:element name="command_id">get_entity_1</xsl:element>
						<xsl:element name="CcmFifGetEntityInCont">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					<!--Create new hardware address-->
					<xsl:element name="CcmFifCreateAddressCmd">
						<xsl:element name="command_id">create_addr_1</xsl:element>
						<xsl:element name="CcmFifCreateAddressInCont">
							<xsl:element name="entity_ref">
								<xsl:element name="command_id">get_entity_1</xsl:element>
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
							<xsl:if test="request-param[@name='validationTypeRd'] != ''">
								<xsl:element name="validation_type_rd">
									<xsl:value-of select="request-param[@name='validationTypeRd']"/>
								</xsl:element>
							</xsl:if>
						</xsl:element>
					</xsl:element>
				</xsl:if>
				
				<!-- check for a previous action to set reason rd and detailed reason rd -->
				<xsl:element name="CcmFifValidatePreviousActionCmd">
					<xsl:element name="command_id">validate_previous_action_1</xsl:element>
					<xsl:element name="CcmFifValidatePreviousActionInCont">
						<xsl:element name="list_of_action_name">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">relocateContract</xsl:element>          	  
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">changeTechnology</xsl:element>          	  
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">downgradeToBasis</xsl:element>          	  
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">upgradeToPremium</xsl:element>          	  
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">changeProductType</xsl:element>          	  
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				<xsl:element name="CcmFifValidatePreviousActionCmd">
					<xsl:element name="command_id">validate_previous_action_2</xsl:element>
					<xsl:element name="CcmFifValidatePreviousActionInCont">
						<xsl:element name="list_of_action_name">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">upgradeToDSL</xsl:element>          	  
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">reconfigureFunction</xsl:element>          	  
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>

				<!-- find reconfigure STP for upgradeToDSL -->
				<xsl:element name="CcmFifFindServiceTicketPositionCmd">
					<xsl:element name="command_id">find_stp_1</xsl:element>
					<xsl:element name="CcmFifFindServiceTicketPositionInCont">
						<xsl:element name="service_subscription_id_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="usage_mode_value_rd">2</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">validate_previous_action_2</xsl:element>
							<xsl:element name="field_name">action_performed_ind</xsl:element>          	
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
					</xsl:element>
				</xsl:element>
				<!-- find subscribe STP for relocateContract, changeTechnology, downgradeToBasis, upgradeToPremium -->
				<xsl:element name="CcmFifFindServiceTicketPositionCmd">
					<xsl:element name="command_id">find_stp_2</xsl:element>
					<xsl:element name="CcmFifFindServiceTicketPositionInCont">
						<xsl:element name="service_subscription_id_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="usage_mode_value_rd">1</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">validate_previous_action_1</xsl:element>
							<xsl:element name="field_name">action_performed_ind</xsl:element>          	
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
					</xsl:element>
				</xsl:element>
				<xsl:element name="CcmFifConcatStringsCmd">
					<xsl:element name="command_id">concat_find_stp</xsl:element>
					<xsl:element name="CcmFifConcatStringsInCont">
						<xsl:element name="input_string_list">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">find_stp_1</xsl:element>
								<xsl:element name="field_name">stp_found</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">;</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">find_stp_1</xsl:element>
								<xsl:element name="field_name">stp_found</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				<xsl:element name="CcmFifMapStringCmd">
					<xsl:element name="command_id">map_find_stp</xsl:element>
					<xsl:element name="CcmFifMapStringInCont">
						<xsl:element name="input_string_type">[Y,N];[Y,N]</xsl:element>
						<xsl:element name="input_string_ref">
							<xsl:element name="command_id">concat_find_stp</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>
						</xsl:element>
						<xsl:element name="output_string_type">action_performed_ind</xsl:element>
						<xsl:element name="string_mapping_list">
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">Y;N</xsl:element>
								<xsl:element name="output_string">Y</xsl:element>								
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">N;Y</xsl:element>
								<xsl:element name="output_string">Y</xsl:element>								
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">Y;Y</xsl:element>
								<xsl:element name="output_string">Y</xsl:element>								
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">N;N</xsl:element>
								<xsl:element name="output_string">N</xsl:element>								
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">;</xsl:element>
								<xsl:element name="output_string">N</xsl:element>								
							</xsl:element>
						</xsl:element>
						<xsl:element name="no_mapping_error">Y</xsl:element>
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
							<xsl:element name="command_id">map_find_stp</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>          	
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
					</xsl:element>
				</xsl:element>							
				
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
				
				<xsl:variable name="hardwareServiceCode">
					<xsl:choose>
						<xsl:when test="request-param[@name='hardwareServiceCode'] = ''">
							<xsl:if test="request-param[@name='addIADHardwareService'] != 'Y'">V0114</xsl:if>
							<xsl:if test="request-param[@name='addIADHardwareService'] = 'Y'">V011A</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="request-param[@name='hardwareServiceCode']"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="isDependentService">
					<xsl:choose>
						<xsl:when test="request-param[@name='isDependentService'] = 'Y'">Y</xsl:when>
						<xsl:when test="$hardwareServiceCode = 'V0114'
							or $hardwareServiceCode = 'I1350'
							or $hardwareServiceCode = 'I1359'">N</xsl:when>
						<xsl:otherwise>Y</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<!-- Add hardware Service -->				
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_hardware_service</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:value-of select="$hardwareServiceCode"/>
						</xsl:element>
						<xsl:element name="sales_organisation_number">
							<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
						</xsl:element>   
						<xsl:element name="sales_organisation_number_vf">
							<xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
						</xsl:element>   
						<xsl:element name="service_subscription_id">
							<xsl:value-of select="request-param[@name='allocatedServiceSubscriptionId']"/>
						</xsl:element>
						<xsl:if test="$isDependentService = 'Y'">
							<xsl:element name="parent_service_subs_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:element name="reason_rd">AEND</xsl:element>
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">account_number</xsl:element>
						</xsl:element>
						<xsl:element name="usage_mode_value_rd">
							<xsl:value-of select="$usageMode"/>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">map_find_stp</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>          	
						</xsl:element>                    
						<xsl:element name="required_process_ind">N</xsl:element>          
						<xsl:element name="service_characteristic_list">
							<xsl:if test="request-param[@name='remarks'] != ''">
								<!-- Bemerkung -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0008</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='remarks']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Seriennummer -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0109</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='serialNumber']"/>
								</xsl:element>
							</xsl:element>
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
										<xsl:element name="command_id">create_addr_1</xsl:element>
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
							<!-- V0117  Prüfziffer -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0117</xsl:element>
								<xsl:element name="data_type">DECIMAL</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='checkingNumber']"/>
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
							<!-- I1335 Ausgleichszahlung für Settopbox bei Nichtrücksendung-->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">I1335</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='compensationFee']"/>
								</xsl:element>
							</xsl:element>		
						    <!-- I1337 Imei -->
						    <xsl:element name="CcmFifConfiguredValueCont">
						        <xsl:element name="service_char_code">I1337</xsl:element>
						        <xsl:element name="data_type">STRING</xsl:element>
						        <xsl:element name="configured_value">
						            <xsl:value-of select="request-param[@name='imei']"/>
						        </xsl:element>
						    </xsl:element>
						    <!-- I1338 Hardware-Aktionscode -->
						    <xsl:element name="CcmFifConfiguredValueCont">
						        <xsl:element name="service_char_code">I1338</xsl:element>
						    	<xsl:element name="data_type">STRING</xsl:element>
						        <xsl:element name="configured_value">
						            <xsl:value-of select="request-param[@name='sapActionCode']"/>
						        </xsl:element>
						    </xsl:element>
							<!-- I1336 Hardware-sapOrderId -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">I1336</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='sapOrderId']"/>
								</xsl:element>
							</xsl:element>
							<xsl:if test="request-param[@name='simSerialNumber'] != ''">
								<!-- V0108 SIM ID -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0108</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='simSerialNumber']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- V0884 delivery note number -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0884</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='deliveryNoteNumber']"/>
								</xsl:element>
							</xsl:element>						    
							<!-- V0885 delivery date -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0885</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="$deliveryDateOPM" /> 
								</xsl:element>
							</xsl:element>						    
							<!-- VI115 Anzahl -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">VI115</xsl:element>
								<xsl:element name="data_type">INTEGER</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='quantity']"/>
								</xsl:element>
							</xsl:element>						    
							<!-- VI120 Techniker Info zum Kunden -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">VI120</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='remarkForTechnician']"/>
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
				
				<!-- Add hardware Service -->				
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_hardware_service</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:value-of select="$hardwareServiceCode"/>
						</xsl:element>
						<xsl:element name="sales_organisation_number">
							<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
						</xsl:element>   
						<xsl:element name="sales_organisation_number_vf">
							<xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
						</xsl:element>   
						<xsl:element name="service_subscription_id">
							<xsl:value-of select="request-param[@name='allocatedServiceSubscriptionId']"/>
						</xsl:element>
						<xsl:if test="$isDependentService = 'Y'">
							<xsl:element name="parent_service_subs_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:element name="reason_rd_ref">
							<xsl:element name="command_id">get_stp_data_1</xsl:element>
							<xsl:element name="field_name">reason_rd</xsl:element>
						</xsl:element>
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">account_number</xsl:element>
						</xsl:element>
						<xsl:element name="usage_mode_value_rd">
							<xsl:value-of select="$usageMode"/>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">map_find_stp</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>          	
						</xsl:element>                    
						<xsl:element name="required_process_ind">Y</xsl:element>          
						<xsl:element name="service_characteristic_list">
							<xsl:if test="request-param[@name='remarks'] != ''">
								<!-- Bemerkung -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0008</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='remarks']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Seriennummer -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0109</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='serialNumber']"/>
								</xsl:element>
							</xsl:element>					
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
										<xsl:element name="command_id">create_addr_1</xsl:element>
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
							<!-- I1335 Ausgleichszahlung für Settopbox bei Nichtrücksendung-->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">I1335</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='compensationFee']"/>
								</xsl:element>
							</xsl:element>	
						    <!-- I1337 Imei -->
						    <xsl:element name="CcmFifConfiguredValueCont">
						        <xsl:element name="service_char_code">I1337</xsl:element>
						        <xsl:element name="data_type">STRING</xsl:element>
						        <xsl:element name="configured_value">
						            <xsl:value-of select="request-param[@name='imei']"/>
						        </xsl:element>
						    </xsl:element>
						    <!-- I1338 Hardware-Aktionscode -->
						    <xsl:element name="CcmFifConfiguredValueCont">
						        <xsl:element name="service_char_code">I1338</xsl:element>
						    	<xsl:element name="data_type">STRING</xsl:element>
						        <xsl:element name="configured_value">
						            <xsl:value-of select="request-param[@name='sapActionCode']"/>
						        </xsl:element>
						    </xsl:element>				
							<!-- I1336 Hardware-sapOrderId -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">I1336</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='sapOrderId']"/>
								</xsl:element>
							</xsl:element>
							<xsl:if test="request-param[@name='simSerialNumber'] != ''">
								<!-- V0108 SIM ID -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0108</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='simSerialNumber']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- V0884 delivery note number -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0884</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='deliveryNoteNumber']"/>
								</xsl:element>
							</xsl:element>						    
							<!-- V0885 delivery date -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0885</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="$deliveryDateOPM" /> 
								</xsl:element>
							</xsl:element>						    
						</xsl:element>
						<xsl:element name="sub_order_id">
							<xsl:value-of select="request-param[@name='subOrderId']"/>
						</xsl:element>
						<xsl:element name="detailed_reason_ref">
							<xsl:element name="command_id">get_stp_data_1</xsl:element>
							<xsl:element name="field_name">detailed_reason_rd</xsl:element>
						</xsl:element>
						<xsl:element name="provider_tracking_no">
							<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>

			    <xsl:if test="request-param[@name='surchargeIndicator'] = 'Y'">			        
			        &AddSurchargeService;
			    </xsl:if>
			    
				<xsl:choose>
					<xsl:when test="request-param[@name='standaloneOrder'] = 'Y'">
						
						<xsl:if test="request-param[@name='requestListId'] != ''">
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
								<xsl:element name="command_id">add_stp_to_co</xsl:element>
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
									    <xsl:element name="CcmFifCommandRefCont">
									        <xsl:element name="command_id">add_service_surcharge</xsl:element>
									        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
									    </xsl:element>
									</xsl:element>						
									<xsl:element name="processing_status">
										<xsl:value-of select="request-param[@name='processingStatus']"/>
									</xsl:element>
									<xsl:element name="process_ind_ref">
										<xsl:element name="command_id">read_standalone_co</xsl:element>
										<xsl:element name="field_name">value_found</xsl:element>
									</xsl:element>
									<xsl:element name="required_process_ind">Y</xsl:element>
								</xsl:element>
							</xsl:element>						
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
								    <xsl:element name="CcmFifCommandRefCont">
								        <xsl:element name="command_id">add_service_surcharge</xsl:element>
								        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
								    </xsl:element>
								</xsl:element>
								<xsl:if test="request-param[@name='requestListId'] != ''">
									<xsl:element name="process_ind_ref">
										<xsl:element name="command_id">read_standalone_co</xsl:element>
										<xsl:element name="field_name">value_found</xsl:element>
									</xsl:element>
									<xsl:element name="required_process_ind">N</xsl:element>
								</xsl:if>
								<xsl:element name="e_shop_id">
									<xsl:value-of select="request-param[@name='eShopID']"/>
								</xsl:element>
								<xsl:element name="processing_status">
									<xsl:value-of select="request-param[@name='processingStatus']"/>
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
									<xsl:element name="process_ind_ref">
										<xsl:element name="command_id">read_standalone_co</xsl:element>
										<xsl:element name="field_name">value_found</xsl:element>
									</xsl:element>
									<xsl:element name="required_process_ind">N</xsl:element>
								</xsl:if>
							</xsl:element>
						</xsl:element>
					</xsl:when>
					
					<xsl:otherwise>				
						<!-- find an open customer order for the main service -->
						<xsl:element name="CcmFifFindCustomerOrderCmd">
							<xsl:element name="command_id">find_customer_order</xsl:element>
							<xsl:element name="CcmFifFindCustomerOrderInCont">
								<xsl:element name="service_subscription_id_ref">
									<xsl:element name="command_id">find_main_service</xsl:element>
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
								<xsl:element name="usage_mode">
									<xsl:choose>
										<xsl:when test="$Type != ''">1</xsl:when>
										<xsl:otherwise>2</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
								<xsl:element name="customer_tracking_id">
									<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
								</xsl:element>						
							</xsl:element>
						</xsl:element>
						<!-- Add STPs to customer order if exists -->
						<xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
							<xsl:element name="command_id">add_stp_to_co</xsl:element>
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
								    <xsl:element name="CcmFifCommandRefCont">
								        <xsl:element name="command_id">add_service_surcharge</xsl:element>
								        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
								    </xsl:element>
								</xsl:element>
								<xsl:element name="processing_status">
									<xsl:value-of select="request-param[@name='processingStatus']"/>
								</xsl:element>
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">find_customer_order</xsl:element>
									<xsl:element name="field_name">customer_order_found</xsl:element>
								</xsl:element>
								<xsl:element name="required_process_ind">Y</xsl:element>
							</xsl:element>
						</xsl:element>
						<!-- Create stand alone Customer Order for new service if there's no open C.O. -->
						<xsl:element name="CcmFifCreateCustOrderCmd">
							<xsl:element name="command_id">create_co</xsl:element>
							<xsl:element name="CcmFifCreateCustOrderInCont">
								<xsl:element name="customer_number_ref">
									<xsl:element name="command_id">find_main_service</xsl:element>
									<xsl:element name="field_name">customer_number</xsl:element>
								</xsl:element>
								<xsl:element name="cust_order_description">Add hardware service</xsl:element>
								<xsl:element name="customer_tracking_id">
									<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
								</xsl:element>
								<xsl:choose>
									<xsl:when test="request-param[@name='providerTrackingNumber'] != ''">
										<xsl:element name="provider_tracking_no">
											<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
										</xsl:element>										
									</xsl:when>
									<xsl:otherwise>
										<xsl:element name="provider_tracking_no_ref">
											<xsl:element name="command_id">get_ptn</xsl:element>
											<xsl:element name="field_name">provider_tracking_number</xsl:element>
										</xsl:element>										
									</xsl:otherwise>
								</xsl:choose>
								<xsl:element name="service_ticket_pos_list">
									<xsl:element name="CcmFifCommandRefCont">
										<xsl:element name="command_id">add_hardware_service</xsl:element>
										<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
									</xsl:element>
								    <xsl:element name="CcmFifCommandRefCont">
								        <xsl:element name="command_id">add_service_surcharge</xsl:element>
								        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
								    </xsl:element>
								</xsl:element>
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">find_customer_order</xsl:element>
									<xsl:element name="field_name">customer_order_found</xsl:element>
								</xsl:element>
								<xsl:element name="required_process_ind">N</xsl:element>
								<xsl:element name="e_shop_id">
									<xsl:value-of select="request-param[@name='eShopID']"/>
								</xsl:element>
								<xsl:element name="processing_status">
									<xsl:value-of select="request-param[@name='processingStatus']"/>
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
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">find_customer_order</xsl:element>
									<xsl:element name="field_name">customer_order_found</xsl:element>
								</xsl:element>
								<xsl:element name="required_process_ind">N</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
				
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
		
		<xsl:if test="request-param[@name='functionID'] != ''">		
			<!-- Write the main access service to the external Notification -->   
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<xsl:element name="command_id">create_notification_1</xsl:element>
				<xsl:element name="CcmFifCreateExternalNotificationInCont">
					<xsl:element name="effective_date">
						<xsl:value-of select="dateutils:getCurrentDate()"/>
					</xsl:element>
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="processed_indicator">Y</xsl:element>
					<xsl:element name="notification_action_name">
						<xsl:value-of select="//request/action-name"/>
					</xsl:element>
					<xsl:element name="target_system">FIF</xsl:element>
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">
								<xsl:value-of select="request-param[@name='functionID']"/>
								<xsl:text>_SERVICE_SUBSCRIPTION_ID</xsl:text>
							</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">add_hardware_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
						</xsl:element>  
					</xsl:element>				
				</xsl:element>
			</xsl:element>
						
			<!--  Create external notification for internal purposes -->
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<xsl:element name="command_id">create_notification_1</xsl:element>
				<xsl:element name="CcmFifCreateExternalNotificationInCont">
					<xsl:element name="effective_date">
						<xsl:value-of select="dateutils:getCurrentDate()"/>
					</xsl:element>
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="processed_indicator">Y</xsl:element>
					<xsl:element name="notification_action_name">
						<xsl:value-of select="//request/action-name"/>
					</xsl:element>
					<xsl:element name="target_system">FIF</xsl:element>
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">
								<xsl:value-of select="request-param[@name='functionID']"/>
								<xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
							</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">create_co</xsl:element>
								<xsl:element name="field_name">customer_order_id</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">create_co</xsl:element>
						<xsl:element name="field_name">customer_order_created</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>   
				</xsl:element>
			</xsl:element>		

			<!--  Create external notification for internal purposes -->
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<xsl:element name="command_id">create_notification_1</xsl:element>
				<xsl:element name="CcmFifCreateExternalNotificationInCont">
					<xsl:element name="effective_date">
						<xsl:value-of select="dateutils:getCurrentDate()"/>
					</xsl:element>
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="processed_indicator">Y</xsl:element>
					<xsl:element name="notification_action_name">
						<xsl:value-of select="//request/action-name"/>
					</xsl:element>
					<xsl:element name="target_system">FIF</xsl:element>
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">
								<xsl:value-of select="request-param[@name='functionID']"/>
								<xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
							</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">add_stp_to_co</xsl:element>
								<xsl:element name="field_name">customer_order_id</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">add_stp_to_co</xsl:element>
						<xsl:element name="field_name">stp_added</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>   
				</xsl:element>
			</xsl:element>	
		</xsl:if>
				
		<xsl:element name="CcmFifConcatStringsCmd">
			<xsl:element name="command_id">concat_contact_text</xsl:element>
			<xsl:element name="CcmFifConcatStringsInCont">
				<xsl:element name="input_string_list">
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="value">
							<xsl:text>Hardware (Artikelnummer: </xsl:text>
							<xsl:value-of select="request-param[@name='articleNumber']"/>
							<xsl:text>) bestellt über </xsl:text>
							<xsl:value-of select="request-param[@name='clientName']"/>							
							<xsl:text>&#xA;TransactionID: </xsl:text>
							<xsl:value-of select="request-param[@name='transactionID']"/>
							<xsl:text>&#xA;Hardware Service Code: </xsl:text>
							<xsl:if test="request-param[@name='addIADHardwareService']!='Y'
								and request-param[@name='hardwareServiceCode'] = ''">
								<xsl:text>V0114</xsl:text>
							</xsl:if>
							<xsl:if test="request-param[@name='addIADHardwareService']='Y'
								and request-param[@name='hardwareServiceCode'] = ''">
								<xsl:text>V011A</xsl:text>
							</xsl:if>
							<xsl:if test="request-param[@name='hardwareServiceCode']!=''">
								<xsl:value-of select="request-param[@name='hardwareServiceCode']"/>
							</xsl:if>
							<xsl:text>&#xA;Dienstenutzung: </xsl:text>		
						</xsl:element>							
					</xsl:element>
					<xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">add_hardware_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>							
					</xsl:element>				    
				    <xsl:if test="request-param[@name='surchargeIndicator']='Y'">			    
    				    <xsl:element name="CcmFifPassingValueCont">
    				        <xsl:element name="contact_text">
    				            <xsl:text>&#xA;Aufpreis Service Code: </xsl:text>  
    				            <xsl:text>V0850</xsl:text>
    				            <xsl:text>&#xA;Dienstenutzung: </xsl:text>	
    				        </xsl:element>
    				    </xsl:element>
    				    <xsl:element name="CcmFifCommandRefCont">
    				        <xsl:element name="command_id">add_service_surcharge</xsl:element>
    				        <xsl:element name="field_name">service_subscription_id</xsl:element>
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
				<xsl:element name="contact_type_rd">ADD_HARDWARE</xsl:element>
				<xsl:element name="short_description">Hardware bestellt</xsl:element>
				<xsl:element name="description_text_list">
					<xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">concat_contact_text</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>							
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>							
		
	</xsl:element>
</xsl:template>
</xsl:stylesheet>
