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
				<xsl:element name="command_id">find_wholesale_lte_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="service_subscription_id">
						<xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
					</xsl:element>					
					<xsl:element name="no_service_error">N</xsl:element>
					<xsl:element name="no_service_warning">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:if test="request-param[@name='BANDWIDTH'] != ''">
				<!-- Renegotiate Order Form  -->
				<xsl:element name="CcmFifRenegotiateOrderFormCmd">
					<xsl:element name="command_id">renegotiate</xsl:element>
					<xsl:element name="CcmFifRenegotiateOrderFormInCont">
						<xsl:element name="contract_number_ref">
							<xsl:element name="command_id">find_wholesale_lte_service</xsl:element>
							<xsl:element name="field_name">contract_number</xsl:element>
						</xsl:element>
						<xsl:element name="product_commit_list">
							<xsl:element name="CcmFifProductCommitCont">
								<xsl:element name="new_pricing_structure_code">
									<xsl:choose>
										<xsl:when test="request-param[@name='BANDWIDTH'] = 'WHE LTE 3600'">YI003</xsl:when>
										<xsl:when test="request-param[@name='BANDWIDTH'] = 'WHE LTE 7200'">YI004</xsl:when>
										<xsl:when test="request-param[@name='BANDWIDTH'] = 'WHE LTE 21600'">YI006</xsl:when>					
										<xsl:when test="request-param[@name='BANDWIDTH'] = 'WHE LTE 50000'">YI005</xsl:when>
									</xsl:choose>                      
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- Sign Order Form And Apply New Pricing Structure -->
				<xsl:element name="CcmFifSignAndApplyNewPricingStructCmd">
					<xsl:element name="command_id">sign_apply_1</xsl:element>
					<xsl:element name="CcmFifSignAndApplyNewPricingStructInCont">
						<xsl:element name="supported_object_id_ref">
							<xsl:element name="command_id">find_wholesale_lte_service</xsl:element>
							<xsl:element name="field_name">contract_number</xsl:element>
						</xsl:element>
						<xsl:element name="supported_object_type_rd">O</xsl:element>
						<xsl:element name="apply_swap_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="board_sign_name">Vodafone</xsl:element>
						<xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="request-param[@name='LOK_ADDRESS.City'] != ''">
				<!-- Get Entity Information -->   
				<xsl:element name="CcmFifGetEntityCmd">
					<xsl:element name="command_id">get_entity</xsl:element>
					<xsl:element name="CcmFifGetEntityInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_wholesale_lte_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- Create Address-->
				<xsl:element name="CcmFifCreateAddressCmd">
					<xsl:element name="command_id">create_address</xsl:element>
					<xsl:element name="CcmFifCreateAddressInCont">
						<xsl:element name="entity_ref">
							<xsl:element name="command_id">get_entity</xsl:element>
							<xsl:element name="field_name">entity_id</xsl:element>
						</xsl:element>
						<xsl:element name="address_type">LOKA</xsl:element>
						<xsl:element name="street_name">
							<xsl:value-of select="request-param[@name='LOK_ADDRESS.StreetName']"/>
						</xsl:element>
						<xsl:element name="street_number">
							<xsl:value-of select="request-param[@name='LOK_ADDRESS.StreetNumber']"/>
						</xsl:element>
						<xsl:element name="street_number_suffix">
							<xsl:value-of select="request-param[@name='LOK_ADDRESS.NumberSuffix']"/>
						</xsl:element>
						<xsl:element name="postal_code">
							<xsl:value-of select="request-param[@name='LOK_ADDRESS.PostalCode']"/>
						</xsl:element>
						<xsl:element name="city_name">
							<xsl:value-of select="request-param[@name='LOK_ADDRESS.City']"/>
						</xsl:element>
						<xsl:element name="city_suffix_name">
							<xsl:value-of select="request-param[@name='LOK_ADDRESS.CitySuffix']"/>
						</xsl:element>
						<xsl:element name="country_code">
							<xsl:value-of select="request-param[@name='LOK_ADDRESS.Country']"/>
						</xsl:element>
						<xsl:element name="set_primary_address">Y</xsl:element>
						<xsl:element name="ignore_existing_address">Y</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>			
			
			<xsl:element name="CcmFifReconfigServiceCmd">
				<xsl:element name="command_id">reconfigure_service</xsl:element>
				<xsl:element name="CcmFifReconfigServiceInCont">
					<xsl:element name="service_subscription_ref">
						<xsl:element name="command_id">find_wholesale_lte_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$desiredDate"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">MODIFY_WHS_LTE</xsl:element>
					<xsl:element name="service_characteristic_list">
						<xsl:if test="request-param[@name='LOK_ADDRESS.City'] != ''">
							<!-- Standort-Adresse -->
							<xsl:element name="CcmFifAddressCharacteristicCont">
								<xsl:element name="service_char_code">V0014</xsl:element>
								<xsl:element name="data_type">ADDRESS</xsl:element>
								<xsl:element name="address_ref">
									<xsl:element name="command_id">create_address</xsl:element>
									<xsl:element name="field_name">address_id</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:if>
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
						<xsl:if test="request-param[@name='GEO_ID'] != ''">
							<!-- Geo-ID -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V010A</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='GEO_ID']"/> 
								</xsl:element>
							</xsl:element>
						</xsl:if>						
						<xsl:if test="request-param[@name='MSISDN_NDC'] != ''">
							<!-- MSISDN_NDC -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V015A</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='MSISDN_NDC']"/> 
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='MSISDN_SN'] != ''">
							<!-- MSISDN_SN -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V015B</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='MSISDN_SN']"/> 
								</xsl:element>
							</xsl:element>								
						</xsl:if>
						<xsl:if test="request-param[@name='DESIRED_BANDWIDTH'] != ''">
							<!-- Gewünschte Bandbreite -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V081A</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='DESIRED_BANDWIDTH']"/> 
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='BANDWIDTH'] != ''">
							<!-- DSLBandbreite -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V082A</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='BANDWIDTH']"/> 
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='SIMSERIAL_NUMBER'] != ''">
							<!-- SIMSERIAL_NUMBER -->
							<xsl:element name="CcmFifAccessNumberCont">
								<xsl:element name="service_char_code">V093A</xsl:element>
								<xsl:element name="data_type">TECH_SERVICE_ID</xsl:element>
								<xsl:element name="network_account">
									<xsl:value-of select="request-param[@name='SIMSERIAL_NUMBER']"/> 
								</xsl:element>
							</xsl:element>						
						</xsl:if>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_wholesale_lte_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>					
				</xsl:element>
			</xsl:element>
			
			<!-- Create Customer Order for new services  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_wholesale_lte_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">002v</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">reconfigure_service</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_wholesale_lte_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>																
				</xsl:element>
			</xsl:element>

			<!-- Release stand alone customer Order --> 
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">release_co</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_wholesale_lte_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_wholesale_lte_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>											
				</xsl:element>
			</xsl:element>
			
			<!-- concat text parts for contact text --> 
			<xsl:element name="CcmFifConcatStringsCmd">
				<xsl:element name="command_id">concat_contact_text</xsl:element>
				<xsl:element name="CcmFifConcatStringsInCont">
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">
								<xsl:text>Wholesale-Internet-Vertrag geändert über </xsl:text>
								<xsl:value-of select="request-param[@name='clientName']"/>
								<xsl:text>&#xA;TransactionID: </xsl:text>
								<xsl:value-of select="request-param[@name='transactionID']"/>
								<xsl:text>&#xA;Vertragsnummer: </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_wholesale_lte_service</xsl:element>
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
						<xsl:element name="command_id">find_wholesale_lte_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="contact_type_rd">MODIFY_WHS_LTE</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>Wholesale-Internet geändert</xsl:text>
					</xsl:element>
					<xsl:element name="description_text_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">concat_contact_text</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>							
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_wholesale_lte_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>											
				</xsl:element>
			</xsl:element>
            
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
