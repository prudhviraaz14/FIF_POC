<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
  XSLT file for creating an Add Installation Service FIF request

  @author schwarje
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" version="1.0" exclude-result-prefixes="dateutils">
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
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

			<xsl:variable name="Type">
				<xsl:text/>
				<xsl:value-of select="request-param[@name='type']"/>
			</xsl:variable>
			
			<xsl:variable name="today"
				select="dateutils:getCurrentDate()"/>
			
			<xsl:variable name="tomorrow"
				select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>

			<xsl:variable name="signatureRequiredIndicator">
				<xsl:if test="request-param[@name='signatureRequiredIndicator'] = 'Y'">Ja</xsl:if>
				<xsl:if test="request-param[@name='signatureRequiredIndicator'] != 'Y'">Nein</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="sundayService">
				<xsl:if test="request-param[@name='sundayService'] = 'Y'">Ja</xsl:if>
				<xsl:if test="request-param[@name='sundayService'] != 'Y'">Nein</xsl:if>
			</xsl:variable>
			
			<!-- Convert the desired date to OPM format -->
			<xsl:variable name="desiredDateOPM"  select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>      
			
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
			
			<!-- Take value of serviceSubscriptionId from ccm external notification if serviceSubscriptionId not provided -->
			<xsl:if test="request-param[@name='serviceSubscriptionId'] = ''">
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_main_service_subscription</xsl:element>
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
			
			<!-- try to find the main access service -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_main_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
						<xsl:element name="service_subscription_id">
							<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
						</xsl:element>
						<xsl:if test="request-param[@name='ignoreMissingParentService'] = 'Y'">
							<xsl:element name="no_service_error">N</xsl:element>
						</xsl:if>
					</xsl:if>
					<xsl:if test="request-param[@name='serviceSubscriptionId'] = ''">
						<xsl:element name="service_subscription_id_ref">
							<xsl:element name="command_id">read_main_service_subscription</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>							
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:element>
			
			<xsl:choose>
				<xsl:when test="request-param[@name='processingStatus'] = 'completedOPM'">
					
					<!-- add service -->
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">add_install_service</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">
								<xsl:value-of select="request-param[@name='installationServiceCode']"/>
							</xsl:element>
							<xsl:element name="service_subscription_id">
								<xsl:value-of select="request-param[@name='allocatedServiceSubscriptionId']"/>
							</xsl:element>
							<xsl:element name="parent_service_subs_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="desired_schedule_type">ASAP</xsl:element>
							<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
							<xsl:element name="order_date">
								<xsl:value-of select="request-param[@name='orderDate']"/>
							</xsl:element>
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">service_found</xsl:element>
							</xsl:element>
							<xsl:element name="required_process_ind">Y</xsl:element>							
							<xsl:element name="service_characteristic_list">
								<!-- Installationspakete -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0201</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='installationPackage']"/>
									</xsl:element>
								</xsl:element>
								<!-- Installationspakete Vodafone Office Net -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">VI076</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='installationPackage']"/>
									</xsl:element>
								</xsl:element>								
								<!-- Anzahl Ausprägungen Installationspakete -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">VI079</xsl:element>
									<xsl:element name="data_type">INTEGER</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='quantity']"/>
									</xsl:element>
								</xsl:element>
								<!-- Unterschrift erforderlich -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0204</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="$signatureRequiredIndicator"/>
									</xsl:element>
								</xsl:element>
								<!-- Installationstermin -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0202</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="$desiredDateOPM"/>
									</xsl:element>
								</xsl:element>
								<!-- Rückrufnummer des Kunden -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0182</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='contactPhoneNumber']"/>
									</xsl:element>
								</xsl:element>
								<!-- Preisinformation des Installationspakets -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0183</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='pricingInformation']"/>
									</xsl:element>
								</xsl:element>
								<!-- Sonntagsservice -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0208</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="$sundayService"/>
									</xsl:element>
								</xsl:element>
							</xsl:element>
							<xsl:element name="cio_data">
								<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
							</xsl:element>
							<xsl:element name="provider_tracking_no">
								<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>		
					
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
					
					<!-- Add STPs to subscribe customer order if exists -->   
					<xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
						<xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
							<xsl:element name="customer_order_id_ref">
								<xsl:element name="command_id">read_customer_order</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
							<xsl:element name="service_ticket_pos_list">
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">add_install_service</xsl:element>
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
					
					<xsl:element name="CcmFifCreateCustOrderCmd">
						<xsl:element name="command_id">create_co</xsl:element>
						<xsl:element name="CcmFifCreateCustOrderInCont">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
							<xsl:element name="cust_order_description">Erstellung Installationsdienst</xsl:element>          
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
									<xsl:element name="command_id">add_install_service</xsl:element>
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
					
				</xsl:when>
				<xsl:otherwise>
					<!-- find STP -->
					<xsl:element name="CcmFifFindServiceTicketPositionCmd">
						<xsl:element name="command_id">find_main_stp</xsl:element>
						<xsl:element name="CcmFifFindServiceTicketPositionInCont">
							<xsl:element name="service_subscription_id_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
						</xsl:element>
					</xsl:element>
					
					<!-- get stp data -->
					<xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
						<xsl:element name="command_id">get_main_stp_data</xsl:element>
						<xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
							<xsl:element name="service_ticket_position_id_ref">
								<xsl:element name="command_id">find_main_stp</xsl:element>
								<xsl:element name="field_name">service_ticket_position_id</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					
					<!-- map synchronization -->
					<xsl:element name="CcmFifMapStringCmd">
						<xsl:element name="command_id">map_synchronization</xsl:element>
						<xsl:element name="CcmFifMapStringInCont">
							<xsl:element name="input_string_type">STP State</xsl:element>
							<xsl:element name="input_string_ref">
								<xsl:element name="command_id">get_main_stp_data</xsl:element>
								<xsl:element name="field_name">state_rd</xsl:element>
							</xsl:element>
							<xsl:element name="output_string_type">Value for V0205</xsl:element>
							<xsl:element name="string_mapping_list">
								<xsl:element name="CcmFifStringMappingCont">
									<xsl:element name="input_string">RELEASED</xsl:element>
									<xsl:element name="output_string">Ja</xsl:element>
								</xsl:element>
								<xsl:element name="CcmFifStringMappingCont">
									<xsl:element name="input_string">PROVISIONED</xsl:element>
									<xsl:element name="output_string">Ja</xsl:element>
								</xsl:element>
								<xsl:element name="CcmFifStringMappingCont">
									<xsl:element name="input_string">INSTALLED</xsl:element>
									<xsl:element name="output_string">Nein</xsl:element>
								</xsl:element>
								<xsl:element name="CcmFifStringMappingCont">
									<xsl:element name="input_string">ACTIVATED</xsl:element>
									<xsl:element name="output_string">Nein</xsl:element>
								</xsl:element>
							</xsl:element>
							<xsl:element name="no_mapping_error">Y</xsl:element>
						</xsl:element>
					</xsl:element>
										
					<!-- Add Installation Service, case of synchronization:
						desired date: tomorrow
						schedule type: START_AFTER -->
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">add_install_service</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">
								<xsl:value-of select="request-param[@name='installationServiceCode']"/>
							</xsl:element>
							<xsl:element name="service_subscription_id">
								<xsl:value-of select="request-param[@name='allocatedServiceSubscriptionId']"/>
							</xsl:element>
							<xsl:element name="parent_service_subs_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="desired_date">
								<xsl:value-of select="$tomorrow"/>
							</xsl:element>
							<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
							<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
							<xsl:element name="order_date">
								<xsl:if test="request-param[@name='orderDate'] != ''">
									<xsl:value-of select="request-param[@name='orderDate']"/>
								</xsl:if>
								<xsl:if test="count(request-param[@name='orderDate']) = 0 or request-param[@name='orderDate'] = ''">
									<xsl:value-of select="dateutils:getCurrentDate(true)"/>
								</xsl:if>
							</xsl:element>
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">map_synchronization</xsl:element>
								<xsl:element name="field_name">output_string</xsl:element>								
							</xsl:element>
							<xsl:element name="required_process_ind">Ja</xsl:element>					
							<xsl:element name="service_characteristic_list">
								<!-- Installationspakete -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0201</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='installationPackage']"/>
									</xsl:element>
								</xsl:element>
								<!-- Unterschrift erforderlich -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0204</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="$signatureRequiredIndicator"/>
									</xsl:element>
								</xsl:element>
								<!-- Installationstermin -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0202</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="$desiredDateOPM"/>
									</xsl:element>
								</xsl:element>
								<!-- Synchronisation mit bestehendem Auftrag -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0205</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value_ref">
										<xsl:element name="command_id">map_synchronization</xsl:element>
										<xsl:element name="field_name">output_string</xsl:element>								
									</xsl:element>
								</xsl:element>
								<!-- Rückrufnummer des Kunden -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0182</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='contactPhoneNumber']"/>
									</xsl:element>
								</xsl:element>
								<!-- Preisinformation des Installationspakets -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0183</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='pricingInformation']"/>
									</xsl:element>
								</xsl:element>
								<!-- Sonntagsservice -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0208</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="$sundayService"/>
									</xsl:element>
								</xsl:element>
							</xsl:element>
							<xsl:element name="cio_data">
								<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
							</xsl:element>
							<xsl:element name="provider_tracking_no">
								<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					
					<!-- Add Installation Service, case of no synchronization:
						desired date: desired date of main service
						schedule type: START_BEFORE -->			
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">add_install_service</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">
								<xsl:value-of select="request-param[@name='installationServiceCode']"/>
							</xsl:element>
							<xsl:element name="service_subscription_id">
								<xsl:value-of select="request-param[@name='allocatedServiceSubscriptionId']"/>
							</xsl:element>
							<xsl:element name="parent_service_subs_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="desired_date_ref">
								<xsl:element name="command_id">get_main_stp_data</xsl:element>
								<xsl:element name="field_name">desired_date</xsl:element>
							</xsl:element>
							<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
							<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
							<xsl:element name="order_date">
								<xsl:if test="request-param[@name='orderDate'] != ''">
									<xsl:value-of select="request-param[@name='orderDate']"/>
								</xsl:if>
								<xsl:if test="count(request-param[@name='orderDate']) = 0 or request-param[@name='orderDate'] = ''">
									<xsl:value-of select="dateutils:getCurrentDate(true)"/>
								</xsl:if>
							</xsl:element>
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">map_synchronization</xsl:element>
								<xsl:element name="field_name">output_string</xsl:element>								
							</xsl:element>
							<xsl:element name="required_process_ind">Nein</xsl:element>					
							<xsl:element name="service_characteristic_list">
								<!-- Installationspakete -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0201</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='installationPackage']"/>
									</xsl:element>
								</xsl:element>
								<!-- Unterschrift erforderlich -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0204</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="$signatureRequiredIndicator"/>
									</xsl:element>
								</xsl:element>
								<!-- Installationstermin -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0202</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="$desiredDateOPM"/>
									</xsl:element>
								</xsl:element>
								<!-- Synchronisation mit bestehendem Auftrag -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0205</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value_ref">
										<xsl:element name="command_id">map_synchronization</xsl:element>
										<xsl:element name="field_name">output_string</xsl:element>								
									</xsl:element>
								</xsl:element>
								<!-- Rückrufnummer des Kunden -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0182</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='contactPhoneNumber']"/>
									</xsl:element>
								</xsl:element>
								<!-- Preisinformation des Installationspakets -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0183</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='pricingInformation']"/>
									</xsl:element>
								</xsl:element>
								<!-- Sonntagsservice -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0208</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="$sundayService"/>
									</xsl:element>
								</xsl:element>
							</xsl:element>
							<xsl:element name="cio_data">
								<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
							</xsl:element>
							<xsl:element name="provider_tracking_no">
								<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>	
									
					<!-- Create Customer Order -->
					<xsl:element name="CcmFifCreateCustOrderCmd">
						<xsl:element name="command_id">create_co</xsl:element>
						<xsl:element name="CcmFifCreateCustOrderInCont">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
							<xsl:element name="cust_order_description">Erstellung Installationsdienst</xsl:element>
							<xsl:element name="customer_tracking_id">
								<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
							</xsl:element>
							<xsl:element name="lan_path_file_string">
								<xsl:value-of select="request-param[@name='lanPathFileString']"/>
							</xsl:element>
							<xsl:element name="provider_tracking_no">
								<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
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
									<xsl:element name="command_id">add_install_service</xsl:element>
									<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
								</xsl:element>
							</xsl:element>
							<xsl:element name="e_shop_id">
								<xsl:value-of select="request-param[@name='eShopID']"/>
							</xsl:element>
							<xsl:element name="processing_status">
								<xsl:value-of select="request-param[@name='processingStatus']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					
					<!-- Release Customer Order -->
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
						</xsl:element>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
						
			<!-- Create Contact for Install Service Addition -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="contact_type_rd">ADD_INST_SERVICE</xsl:element>
					<xsl:element name="short_description">Installationsdienst erstellt</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>Installationsdienst hinzugefügt über </xsl:text>
						<xsl:value-of select="request-param[@name='clientName']"/>
						<xsl:text>&#xA;TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
						<xsl:if test="request-param[@name='requestListId'] != ''">
							<xsl:text>&#xA;RequestListId: </xsl:text>
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:if>
						<xsl:text>&#xA;Installationsdienst: </xsl:text>
						<xsl:value-of select="request-param[@name='installationServiceCode']"/>
						<xsl:text>&#xA;Wunschdatum: </xsl:text>
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:if test="request-param[@name='clientName'] != 'CODB'">
				<!-- Create KBA notification  -->
				<xsl:element name="CcmFifCreateExternalNotificationCmd">
					<xsl:element name="command_id">create_kba_notification_1</xsl:element>
					<xsl:element name="CcmFifCreateExternalNotificationInCont">
						<xsl:element name="effective_date"/>
						<xsl:element name="notification_action_name">createKBANotification</xsl:element>
						<xsl:element name="target_system">KBA</xsl:element>
						<xsl:element name="parameter_value_list">
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
								<xsl:element name="parameter_value_ref">
									<xsl:element name="command_id">find_main_service</xsl:element>
									<xsl:element name="field_name">customer_number</xsl:element>
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">TYPE</xsl:element>
								<xsl:element name="parameter_value">CONTACT</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">CATEGORY</xsl:element>
								<xsl:element name="parameter_value">addInstallationService</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">USER_NAME</xsl:element>
								<xsl:element name="parameter_value">
									<xsl:value-of select="request-param[@name='clientName']"/>
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">WORK_DATE</xsl:element>
								<xsl:element name="parameter_value">
									<xsl:value-of select="request-param[@name='desiredDate']"/>
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">TEXT</xsl:element>
								<xsl:element name="parameter_value">
									<xsl:text>Installationsdienst hinzugefügt über </xsl:text>
									<xsl:value-of select="request-param[@name='clientName']"/>
									<xsl:text>&#xA;TransactionID: </xsl:text>
									<xsl:value-of select="request-param[@name='transactionID']"/>
									<xsl:if test="request-param[@name='requestListId'] != ''">
										<xsl:text>&#xA;RequestListId: </xsl:text>
										<xsl:value-of select="request-param[@name='requestListId']"/>
									</xsl:if>
									<xsl:text>&#xA;Installationsdienst: </xsl:text>
									<xsl:value-of select="request-param[@name='installationServiceCode']"/>
									<xsl:text>&#xA;Wunschdatum: </xsl:text>
									<xsl:value-of select="request-param[@name='desiredDate']"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
