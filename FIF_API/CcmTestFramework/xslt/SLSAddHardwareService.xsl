<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<!--
  XSLT file for creating a FIF request for Adding Hardware Service
  @author wlazlow
-->
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
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
			<!-- Find Service Subscription by access number, STP Id or Service Subscription Id-->
			<xsl:if test="(request-param[@name='ACCESS_NUMBER'] != '') or (request-param[@name='SERVICE_TICKET_POSITION_ID'] != '') or (request-param[@name='SERVICE_SUBSCRIPTION_ID'] != '')">
				<xsl:element name="CcmFifFindServiceSubsCmd">
					<xsl:element name="command_id">find_service_1</xsl:element>
					<xsl:element name="CcmFifFindServiceSubsInCont">
						<xsl:if test="((request-param[@name='ACCESS_NUMBER'] != '' )and ((request-param[@name='SERVICE_TICKET_POSITION_ID'] = '') and (request-param[@name='SERVICE_SUBSCRIPTION_ID'] = '')))">
							<xsl:element name="access_number">
								<xsl:value-of select="request-param[@name='ACCESS_NUMBER']"/>
							</xsl:element>
							<xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
						</xsl:if>
						<xsl:if test="(request-param[@name='SERVICE_TICKET_POSITION_ID'] != '') and (request-param[@name='SERVICE_SUBSCRIPTION_ID'] = '')">
							<xsl:element name="service_ticket_position_id">
								<xsl:value-of select="request-param[@name='SERVICE_TICKET_POSITION_ID']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='SERVICE_SUBSCRIPTION_ID'] != ''">
							<xsl:element name="service_subscription_id">
								<xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="effective_date">
							<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
						</xsl:element>
						<xsl:if test="request-param[@name='CUSTOMER_NUMBER'] != ''">
							<xsl:element name="customer_number">
								<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
							</xsl:element>
						</xsl:if>
						
						<xsl:element name="contract_number">
							<xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="request-param[@name='HARDWARE_DELIVERY_ADDRESS_ID'] = ''">
				<!-- Get Entity Information -->
				<xsl:element name="CcmFifGetEntityCmd">
					<xsl:element name="command_id">get_entity_1</xsl:element>
					<xsl:element name="CcmFifGetEntityInCont">
						<xsl:if test="request-param[@name='CUSTOMER_NUMBER'] != ''">
							<xsl:element name="customer_number">
								<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
							</xsl:element>
						</xsl:if>
						
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
						<xsl:element name="address_type">LOKA</xsl:element>
						<xsl:element name="street_name">
							<xsl:value-of select="request-param[@name='HARDWARE_DELIVERY_STREET']"/>
						</xsl:element>
						<xsl:element name="street_number">
							<xsl:value-of select="request-param[@name='HARDWARE_DELIVERY_NUMBER']"/>
						</xsl:element>
						<xsl:element name="street_number_suffix">
							<xsl:value-of select="request-param[@name='HARDWARE_DELIVERY_NUMBER_SUFFIX']"/>
						</xsl:element>
						<xsl:element name="postal_code">
							<xsl:value-of select="request-param[@name='HARDWARE_DELIVERY_POSTAL_CODE']"/>
						</xsl:element>
						<xsl:element name="city_name">
							<xsl:value-of select="request-param[@name='HARDWARE_DELIVERY_CITY']"/>
						</xsl:element>
						<xsl:element name="city_suffix_name">
							<xsl:value-of select="request-param[@name='HARDWARE_DELIVERY_CITY_SUFFIX']"/>
						</xsl:element>
						<xsl:element name="country_code">DE</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Add hardware Service V0114-->
			<xsl:if test="(request-param[@name='ADD_IAD_HARDWARE_SERVICE']!='Y')">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_1</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0114</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
						<xsl:element name="reason_rd">AEND</xsl:element>
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">account_number</xsl:element>
						</xsl:element>
						<xsl:element name="service_characteristic_list">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0110</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='HARDWARE_DELIVERY_SALUTATION']"/>
									<xsl:text>;</xsl:text>
									<xsl:value-of select="request-param[@name='HARDWARE_DELIVERY_SURNAME']"/>
									<xsl:text>;</xsl:text>
									<xsl:value-of select="request-param[@name='HARDWARE_DELIVERY_FORENAME']"/>
								</xsl:element>
							</xsl:element>
							<!-- Lieferanschrift -->
							<xsl:element name="CcmFifAddressCharacteristicCont">
								<xsl:element name="service_char_code">V0111</xsl:element>
								<xsl:element name="data_type">ADDRESS</xsl:element>
								<xsl:if test="request-param[@name='HARDWARE_DELIVERY_ADDRESS_ID'] != ''">
									<xsl:element name="address_id">
										<xsl:value-of select="request-param[@name='HARDWARE_DELIVERY_ADDRESS_ID']"/>
									</xsl:element>
								</xsl:if>
								<xsl:if test="request-param[@name='HARDWARE_DELIVERY_ADDRESS_ID'] = ''">
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
									<xsl:value-of select="request-param[@name='ARTICLE_NUMBER']"/>
								</xsl:element>
							</xsl:element>
							<!-- Subventionierungskennzeichen -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0114</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='SUBVENTION_INDICATOR']"/>
								</xsl:element>
							</xsl:element>
							<!-- Artikelbezeichnung -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0116</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='ARTICLE_NAME']"/>
								</xsl:element>
							</xsl:element>
							<!-- Zahlungsoption -->
							<xsl:if test="request-param[@name='SHIPPING_COSTS'] != ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0119</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='SHIPPING_COSTS']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Bestellgrund -->
							<xsl:if test="request-param[@name='ORDER_REASON'] != ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0989</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='ORDER_REASON']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- VO-Nummer -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0990</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='SALES_ORGANISATION_NUMBER']"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!--Add Hardware service for Ngn as V011A -->
			<xsl:if test="(request-param[@name='ADD_IAD_HARDWARE_SERVICE']='Y')">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_1</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V011A</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
						<xsl:element name="reason_rd">AEND</xsl:element>
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">account_number</xsl:element>
						</xsl:element>
						<xsl:element name="service_characteristic_list">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0110</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='HARDWARE_DELIVERY_SALUTATION']"/>
									<xsl:text>;</xsl:text>
									<xsl:value-of select="request-param[@name='HARDWARE_DELIVERY_SURNAME']"/>
									<xsl:text>;</xsl:text>
									<xsl:value-of select="request-param[@name='HARDWARE_DELIVERY_FORENAME']"/>
								</xsl:element>
							</xsl:element>
							<!-- Lieferanschrift -->
							<xsl:element name="CcmFifAddressCharacteristicCont">
								<xsl:element name="service_char_code">V0111</xsl:element>
								<xsl:element name="data_type">ADDRESS</xsl:element>
								<xsl:if test="request-param[@name='HARDWARE_DELIVERY_ADDRESS_ID'] != ''">
									<xsl:element name="address_id">
										<xsl:value-of select="request-param[@name='HARDWARE_DELIVERY_ADDRESS_ID']"/>
									</xsl:element>
								</xsl:if>
								<xsl:if test="request-param[@name='HARDWARE_DELIVERY_ADDRESS_ID'] = ''">
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
									<xsl:value-of select="request-param[@name='ARTICLE_NUMBER']"/>
								</xsl:element>
							</xsl:element>
							<!-- Subventionierungskennzeichen -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0114</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='SUBVENTION_INDICATOR']"/>
								</xsl:element>
							</xsl:element>
							<!-- Artikelbezeichnung -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0116</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='ARTICLE_NAME']"/>
								</xsl:element>
							</xsl:element>
							<!-- Zahlungsoption -->
							<xsl:if test="request-param[@name='SHIPPING_COSTS'] != ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0119</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='SHIPPING_COSTS']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- VO-Nummer -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0990</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='SALES_ORGANISATION_NUMBER']"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Create stand alone Customer Order for new service  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:if test="request-param[@name='CUSTOMER_NUMBER'] != ''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
						</xsl:element>
					</xsl:if>
					
					<xsl:element name="cust_order_description">Add hardware service</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">001</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!--Release customer order for hardware service-->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:if test="request-param[@name='CUSTOMER_NUMBER'] != ''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
						</xsl:element>
					</xsl:if>				
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_1</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Contact for hardware Service Addition -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:if test="request-param[@name='CUSTOMER_NUMBER'] != ''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
						</xsl:element>
					</xsl:if>					
					<xsl:element name="contact_type_rd">ADD_HARDWARE</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>Dienst hinzugefügt über</xsl:text>
						<xsl:value-of select="request-param[@name='clientName']"/>
					</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>TransactionID:</xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
						<xsl:text>&#xA;Hardware Service Code:</xsl:text>
						<xsl:if test="request-param[@name='ADD_IAD_HARDWARE_SERVICE']!='Y'">
							<xsl:text>V0114</xsl:text>
						</xsl:if>
						<xsl:if test="request-param[@name='ADD_IAD_HARDWARE_SERVICE']='Y'">
							<xsl:text>V011A</xsl:text>
						</xsl:if>
						<xsl:text>&#xA;Desired Date:</xsl:text>
						<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create external notification -->
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<xsl:element name="command_id">create_external_notification_1</xsl:element>
				<xsl:element name="CcmFifCreateExternalNotificationInCont">
					<xsl:element name="effective_date">						
						<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>					
					</xsl:element>
					<xsl:element name="notification_action_name">createKBANotification</xsl:element>
					<xsl:element name="target_system">KBA</xsl:element>                           				
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>											
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TYPE</xsl:element>
							<xsl:element name="parameter_value">CONTACT</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CATEGORY</xsl:element>
							<xsl:element name="parameter_value">Migration</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">USER_NAME</xsl:element>
							<xsl:element name="parameter_value">SLS-Clearing</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element>
							<xsl:element name="parameter_value">CCB</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">WORK_DATE</xsl:element>
							<xsl:element name="parameter_value">								
								<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>														
							</xsl:element>
						</xsl:element>					
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TEXT</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:text>Add Hardware Service.</xsl:text>
							</xsl:element>
						</xsl:element>					
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
