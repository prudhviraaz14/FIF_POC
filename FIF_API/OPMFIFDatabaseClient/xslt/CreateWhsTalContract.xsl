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

			<xsl:variable name="ProductCode">  
				<xsl:choose>
					<xsl:when test ="request-param[@name='TECHNOLOGY_FLAG'] = 'LTE'">Wh004</xsl:when>
					<xsl:otherwise>
						<xsl:text>Wh001</xsl:text>
					</xsl:otherwise>
				</xsl:choose>                      
			</xsl:variable> 
			
			<xsl:variable name="LTEPricingStructureCode">  
				<xsl:choose>
					<xsl:when test="request-param[@name='BANDWIDTH'] = 'WHE LTE 3600'">YI003</xsl:when>
					<xsl:when test="request-param[@name='BANDWIDTH'] = 'WHE LTE 7200'">YI004</xsl:when>
					<xsl:when test="request-param[@name='BANDWIDTH'] = 'WHE LTE 21600'">YI006</xsl:when>					
					<xsl:when test="request-param[@name='BANDWIDTH'] = 'WHE LTE 50000'">YI005</xsl:when>
					<xsl:otherwise>unknown</xsl:otherwise>
				</xsl:choose>                      
			</xsl:variable> 
			
			<!-- get customer data to retrieve customer category-->
			<xsl:element name="CcmFifGetCustomerDataCmd">
				<xsl:element name="command_id">get_customer_data</xsl:element>
				<xsl:element name="CcmFifGetCustomerDataInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- look for the parent's voice account -->
			<xsl:element name="CcmFifFindAccountCmd">
				<xsl:element name="command_id">find_account</xsl:element>
				<xsl:element name="CcmFifFindAccountInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">get_customer_data</xsl:element>
						<xsl:element name="field_name">associated_customer_number</xsl:element>						
					</xsl:element>
					<xsl:element name="type_rd">VOICE</xsl:element>
					<xsl:element name="no_account_error">Y</xsl:element>
				</xsl:element>
			</xsl:element>			
									
			<!-- Get Entity Information -->   
			<xsl:element name="CcmFifGetEntityCmd">
				<xsl:element name="command_id">get_entity</xsl:element>
				<xsl:element name="CcmFifGetEntityInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
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
					<!-- TODO unklar, ob die beiden verwendet werden sollen, haengt davon ab, was 1und1 schickt -->
					<xsl:element name="street_number">
						<xsl:value-of select="request-param[@name='LOK_ADDRESS.StreetNumber']"/>
					</xsl:element>
					<xsl:element name="street_number_suffix">
						<xsl:value-of select="request-param[@name='LOK_ADDRESS.NumberSuffix']"/>
					</xsl:element>
					<!-- TODO Ende -->
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
			
			<xsl:element name="CcmFifMapStringCmd">
				<xsl:element name="command_id">map_group_code</xsl:element>
				<xsl:element name="CcmFifMapStringInCont">
					<xsl:element name="input_string_type">Kundenkategorie</xsl:element>
					<xsl:element name="input_string_ref">
						<xsl:element name="command_id">get_customer_data</xsl:element>
						<xsl:element name="field_name">category_rd</xsl:element>
					</xsl:element>
					<xsl:element name="output_string_type">GroupCode</xsl:element>
					<xsl:element name="string_mapping_list">
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">RESIDENTIAL</xsl:element>
							<xsl:element name="output_string">WHS_VO_PK</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">BUSINESS</xsl:element>
							<xsl:element name="output_string">WHS_VO_GK</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="no_mapping_error">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- get sales org number from refdata -->				
			<xsl:element name="CcmFifGetCrossRefSecondaryValueCmd">
				<xsl:element name="command_id">get_sales_org_number</xsl:element>
				<xsl:element name="CcmFifGetCrossRefSecondaryValueInCont">
					<xsl:element name="group_code_ref">
						<xsl:element name="command_id">map_group_code</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>						
					</xsl:element>
					<xsl:element name="primary_value">
						<xsl:value-of select="request-param[@name='WHOLESALE_PARTNER']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>			
			
			<!-- get sales org number from refdata -->				
			<xsl:element name="CcmFifGetCrossRefSecondaryValueCmd">
				<xsl:element name="command_id">get_contract_number</xsl:element>
				<xsl:element name="CcmFifGetCrossRefSecondaryValueInCont">
					<xsl:element name="group_code">WHS_SKTAL</xsl:element>
					<xsl:element name="primary_value">
						<xsl:value-of select="request-param[@name='WHOLESALE_PARTNER']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>			
			
			<xsl:choose>
				<xsl:when test="request-param[@name='TECHNOLOGY_FLAG'] = 'LTE'"/>
				<xsl:otherwise>
					<!-- get sales org number from refdata -->				
					<xsl:element name="CcmFifGetCrossRefSecondaryValueCmd">
						<xsl:element name="command_id">get_tariff</xsl:element>
						<xsl:element name="CcmFifGetCrossRefSecondaryValueInCont">
							<xsl:element name="group_code">
								<xsl:choose>
									<xsl:when test="request-param[@name='TECHNOLOGY_FLAG'] = 'LTE'">WHS_PSCLTE</xsl:when>
									<xsl:otherwise>WHS_PSCTAL</xsl:otherwise>
								</xsl:choose>						
							</xsl:element>
							<xsl:element name="primary_value">
								<xsl:value-of select="request-param[@name='WHOLESALE_PARTNER']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>						
			
			<!-- Create Order Form-->
			<xsl:element name="CcmFifCreateOrderFormCmd">
				<xsl:element name="command_id">create_order_form</xsl:element>
				<xsl:element name="CcmFifCreateOrderFormInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="min_per_dur_value">0</xsl:element>
					<xsl:element name="min_per_dur_unit">MONTH</xsl:element>
					<xsl:element name="sales_org_num_value_ref">
						<xsl:element name="command_id">get_sales_org_number</xsl:element>
						<xsl:element name="field_name">secondary_value</xsl:element>
					</xsl:element>
					<xsl:element name="doc_template_name">Vertrag</xsl:element>
					<xsl:element name="assoc_skeleton_cont_num_ref">
						<xsl:element name="command_id">get_contract_number</xsl:element>
						<xsl:element name="field_name">secondary_value</xsl:element>
					</xsl:element>
					<xsl:element name="auto_extension_ind">N</xsl:element>
				</xsl:element>				
			</xsl:element>
						
			<!-- Add Order Form Product Commitment -->
			<xsl:element name="CcmFifAddProductCommitCmd">
				<xsl:element name="command_id">add_product_commitment</xsl:element>
				<xsl:element name="CcmFifAddProductCommitInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">create_order_form</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
					<xsl:element name="product_code">
						<xsl:value-of select="$ProductCode"/>
					</xsl:element>
					<xsl:choose>
						<xsl:when test="request-param[@name='TECHNOLOGY_FLAG'] = 'LTE'">
							<xsl:element name="pricing_structure_code">
								<xsl:value-of select="$LTEPricingStructureCode"/>								
							</xsl:element>							
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="pricing_structure_code_ref">
								<xsl:element name="command_id">get_tariff</xsl:element>
								<xsl:element name="field_name">secondary_value</xsl:element>						
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>						
				</xsl:element>
			</xsl:element>
			
			<!-- Sign Order Form -->
			<xsl:element name="CcmFifSignOrderFormCmd">
				<xsl:element name="command_id">sign_of</xsl:element>
				<xsl:element name="CcmFifSignOrderFormInCont">
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">create_order_form</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
					<xsl:element name="board_sign_name">ARCOR</xsl:element>
					<xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Add Product Subscription -->
			<xsl:element name="CcmFifAddProductSubsCmd">
				<xsl:element name="command_id">add_product_subscription</xsl:element>
				<xsl:element name="CcmFifAddProductSubsInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="product_commitment_number_ref">
						<xsl:element name="command_id">add_product_commitment</xsl:element>
						<xsl:element name="field_name">product_commitment_number</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>

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

			<xsl:choose>
				<xsl:when test="request-param[@name='TECHNOLOGY_FLAG'] = 'LTE'">
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">add_service</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">add_product_subscription</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">Wh004</xsl:element>
							<xsl:element name="desired_date">
								<xsl:value-of select="$desiredDate"/>
							</xsl:element>
							<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
							<xsl:element name="reason_rd">CREATE_WHS_TAL</xsl:element>
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_account</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>					
							<xsl:element name="service_characteristic_list">
								<!-- Standort-Adresse -->
								<xsl:element name="CcmFifAddressCharacteristicCont">
									<xsl:element name="service_char_code">V0014</xsl:element>
									<xsl:element name="data_type">ADDRESS</xsl:element>
									<xsl:element name="address_ref">
										<xsl:element name="command_id">create_address</xsl:element>
										<xsl:element name="field_name">address_id</xsl:element>
									</xsl:element>
								</xsl:element>
								<!-- Geo-ID -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V010A</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='GEO_ID']"/> 
									</xsl:element>
								</xsl:element>
								<!-- ONKZ -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0124</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='ONKZ']"/> 
									</xsl:element>
								</xsl:element>
								<!-- MSISDN_NDC -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V015A</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='MSISDN_NDC']"/> 
									</xsl:element>
								</xsl:element>
								<!-- MSISDN_SN -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V015B</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='MSISDN_SN']"/> 
									</xsl:element>
								</xsl:element>								
								<!-- Gewünschte Bandbreite -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V081A</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='DESIRED_BANDWIDTH']"/> 
									</xsl:element>
								</xsl:element>
								<!-- DSLBandbreite -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V082A</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='BANDWIDTH']"/> 
									</xsl:element>
								</xsl:element>
								<!-- Anschlußbereich-Kennzeichen -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0934</xsl:element>
									<xsl:element name="data_type">INTEGER</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='ASB']"/> 
									</xsl:element>
								</xsl:element>
								<!-- SIMSERIAL_NUMBER -->
								<xsl:element name="CcmFifAccessNumberCont">
									<xsl:element name="service_char_code">V093A</xsl:element>
									<xsl:element name="data_type">TECH_SERVICE_ID</xsl:element>
									<xsl:element name="network_account">
										<xsl:value-of select="request-param[@name='SIMSERIAL_NUMBER']"/> 
									</xsl:element>
								</xsl:element>						
							</xsl:element>
						</xsl:element>
					</xsl:element>					
				
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">add_installation_fee</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">add_product_subscription</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">Wh007</xsl:element>
							<xsl:element name="desired_date">
								<xsl:value-of select="$desiredDate"/>
							</xsl:element>
							<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
							<xsl:element name="reason_rd">CREATE_WHS_TAL</xsl:element>
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_account</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>					
							<xsl:element name="service_characteristic_list"/>
						</xsl:element>
					</xsl:element>										
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">add_service</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">add_product_subscription</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">Wh003</xsl:element>
							<xsl:element name="desired_date">
								<xsl:value-of select="$desiredDate"/>
							</xsl:element>
							<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
							<xsl:element name="reason_rd">CREATE_WHS_TAL</xsl:element>
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_account</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>					
							<xsl:element name="service_characteristic_list">
								<!-- Standort Addresse -->
								<xsl:element name="CcmFifAddressCharacteristicCont">
									<xsl:element name="service_char_code">V0014</xsl:element>
									<xsl:element name="data_type">ADDRESS</xsl:element>
									<xsl:element name="address_ref">
										<xsl:element name="command_id">create_address</xsl:element>
										<xsl:element name="field_name">address_id</xsl:element>
									</xsl:element>
								</xsl:element>
								<!-- ASB -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0934</xsl:element>
									<xsl:element name="data_type">INTEGER</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='ASB']"/> 
									</xsl:element>
								</xsl:element>
								<!-- Lage TAE -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0123</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='LAGE_TAE']"/> 
									</xsl:element>
								</xsl:element>
								<!-- ONKZ -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0124</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='ONKZ']"/> 
									</xsl:element>
								</xsl:element>
								<!-- Line-ID -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0144</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='LINE_ID']"/> 
									</xsl:element>
								</xsl:element>
								<!-- Portkennung  -->
								<xsl:element name="CcmFifAccessNumberCont">
									<xsl:element name="service_char_code">V0188</xsl:element>
									<xsl:element name="data_type">TECH_SERVICE_ID</xsl:element>
									<xsl:element name="network_account">
										<xsl:value-of select="request-param[@name='TECH_SERVICE_ID']"/> 
									</xsl:element>
								</xsl:element>						
								<!-- Wholesale-Partner -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0189</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='WHOLESALE_PARTNER']"/> 
									</xsl:element>
								</xsl:element>
								<!-- Technology flag -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">VI048</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='TECHNOLOGY_FLAG']"/> 
									</xsl:element>
								</xsl:element>
								<!-- Status Endleitungsbau -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0582</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='LINE_INSTALLATION_INDICATOR']"/> 
									</xsl:element>
								</xsl:element>
								<!-- Carrier -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0081</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='CARRIER']"/> 
									</xsl:element>
								</xsl:element>	
								<!-- ngabLineID -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">I1020</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='NGAB_LINE_ID']"/> 
									</xsl:element>
								</xsl:element>													
							</xsl:element>
						</xsl:element>
					</xsl:element>					
				</xsl:otherwise>	
			</xsl:choose>
			
			
			<xsl:element name="CcmFifFindBundleCmd">
				<xsl:element name="command_id">find_bundle</xsl:element>
				<xsl:element name="CcmFifFindBundleInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
	
			<!-- look for a voice service in that bundle -->
			<xsl:element name="CcmFifFindBundleCmd">
				<xsl:element name="command_id">find_voice_bundle_item</xsl:element>
				<xsl:element name="CcmFifFindBundleInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">find_bundle</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd">WHSVOICE_SERVICE</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_bundle</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Find voice Service Subscription by bundled SS id, if a bundle was found -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_voice_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_voice_bundle_item</xsl:element>
						<xsl:element name="field_name">supported_object_id</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_bundle</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Find Product Code from Product Commitment -->
			<xsl:element name="CcmFifGetProductCommitmentDataCmd">
				<xsl:element name="command_id">get_voice_pc_data</xsl:element>
				<xsl:element name="CcmFifGetProductCommitmentDataInCont">
					<xsl:element name="product_commitment_number_ref">
						<xsl:element name="command_id">find_voice_service</xsl:element>
						<xsl:element name="field_name">product_commitment_number</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_bundle</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>					
				</xsl:element>
			</xsl:element>
			
			<!-- Validate Product Code based on the value of the parameter "TECHNOLOGY_FLAG" -->
			<xsl:element name="CcmFifValidateValueCmd">
				<xsl:element name="command_id">validate_product_code_1</xsl:element>
				<xsl:element name="CcmFifValidateValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">get_voice_pc_data</xsl:element>
						<xsl:element name="field_name">product_code</xsl:element>
					</xsl:element>
					<xsl:element name="object_type">ORDER_FORM_PRODUCT_COMMIT</xsl:element>
					<xsl:element name="value_type">PRODUCT_CODE</xsl:element>
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:if test="request-param[@name='TECHNOLOGY_FLAG']= 'LTE'">
								<xsl:element name="value">Wh005</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='TECHNOLOGY_FLAG']!= 'LTE'">
								<xsl:element name="value">Wh002</xsl:element>
							</xsl:if>							
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_bundle</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>	
				</xsl:element>
			</xsl:element>
					
			<!-- create new bundle for DSL contracts-->
			<xsl:element name="CcmFifModifyBundleCmd">
				<xsl:element name="command_id">modify_bundle</xsl:element>
				<xsl:element name="CcmFifModifyBundleInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">find_bundle</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- add the new  bundle item of type WHSTAL_SERVICE -->
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">modify_bundle</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>					
					<xsl:element name="bundle_item_type_rd">WHSTAL_SERVICE</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">add_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Create Customer Order for new services  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">001</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_installation_fee</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>						
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Release stand alone customer Order --> 
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">release_co</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="customer_order_ref">
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
								<xsl:text>Wholesale-TAL-Vertrag erstellt über </xsl:text>
								<xsl:value-of select="request-param[@name='clientName']"/>
								<xsl:text>&#xA;TransactionID: </xsl:text>
								<xsl:value-of select="request-param[@name='transactionID']"/>
								<xsl:text>&#xA;Vertragsnummer: </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">create_order_form</xsl:element>
							<xsl:element name="field_name">contract_number</xsl:element>							
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>							
						
			<!-- Create contact for Service Addition -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">CREATE_WHS_TAL</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>Wholesale-TAL-Vertrag erstellt</xsl:text>
					</xsl:element>
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
