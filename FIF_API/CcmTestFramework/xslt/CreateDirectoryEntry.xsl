<?xml version="1.0" encoding="utf-8"?>
<!--xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"-->
<!--
XSLT file for creating a FIF request for Adding Directory Entry
@author Vinit Sawalkar
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
	
	<xsl:variable name="today"
		select="dateutils:getCurrentDate()"/>

	<xsl:element name="Command_List">
	
		<xsl:variable name="DirectoryEntryServiceCode">
			<xsl:choose>
				<xsl:when test="request-param[@name='serviceCode'] = 'V0327'">V0327</xsl:when>
				<xsl:otherwise>V0100</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="accessNumber">
			<xsl:choose>
				<xsl:when test="request-param[@name='accessNumber'] = ''">123456789</xsl:when>
				<xsl:when test="request-param[@name='localNumber'] = ''">123456789</xsl:when>
				<xsl:when test="request-param[@name='accessNumber'] != ''">
					<xsl:value-of select="concat('RUF 00',
						number(substring-before(request-param[@name='accessNumber'], ';')),
						' 0',
						number(substring-before(substring-after(request-param[@name='accessNumber'],';'), ';')),
						'/',
						number(substring-after(substring-after(request-param[@name='accessNumber'],';'), ';')))"/>
				</xsl:when>
				<xsl:when test="request-param[@name='localNumber'] != ''">
					<xsl:value-of select="concat('RUF 00',
						request-param[@name='countryCode'],
						' 0',
						request-param[@name='areaCode'],
						'/',
						request-param[@name='localNumber'])"/>
				</xsl:when>
			</xsl:choose>	
		</xsl:variable>		
		
		<xsl:choose>
			<xsl:when test="request-param[@name='processingStatus'] = 'completedOPM'">
				
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
								<xsl:element name="service_code">VI002</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">VI003</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">VI006</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">VI009</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">VI010</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">VI018</xsl:element>
								<xsl:element name="usage_mode_value_rd">1</xsl:element>
								<xsl:element name="service_subscription_state">SUBSCRIBED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">VI019</xsl:element>
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
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">find_main_stp</xsl:element>
							<xsl:element name="field_name">stp_found</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">N</xsl:element>						
					</xsl:element>
				</xsl:element>
				
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
				
				<!-- Add Directory Entry-->
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_dir_entry</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:value-of select="$DirectoryEntryServiceCode"/>
						</xsl:element>
						<xsl:element name="service_subscription_id">
							<xsl:value-of select="request-param[@name='allocatedServiceSubscriptionId']"/>
						</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element> 					
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:element name="reason_rd">
							<xsl:value-of select="request-param[@name='reason']"/>
						</xsl:element>
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">account_number</xsl:element>
						</xsl:element>
						<xsl:element name="service_characteristic_list">
							<xsl:choose>
								<xsl:when test="request-param[@name='directoryEntryText'] != ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0100</xsl:element>
										<xsl:element name="data_type">DIRECTORY_ENTRY</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of select="request-param[@name='directoryEntryText']"/>
										</xsl:element>
									</xsl:element>
								</xsl:when>			
								<xsl:otherwise>
									<xsl:element name="CcmFifDirectoryEntryCont">
										<xsl:element name="service_char_code">V0100</xsl:element>
										<xsl:element name="data_type">DIRECTORY_ENTRY</xsl:element>
										<xsl:element name="type">01  PRN  ELewAUS</xsl:element>
										<xsl:element name="access_number">
											<xsl:value-of select="$accessNumber"/>
										</xsl:element>
										<xsl:element name="name">
											<xsl:value-of select="request-param[@name='name']"/>
										</xsl:element>
										<xsl:element name="forename">
											<xsl:value-of select="request-param[@name='forename']"/>
										</xsl:element>
										<xsl:element name="nobility_prefix">
											<xsl:value-of select="request-param[@name='nobilityPrefixDescription']"/>
										</xsl:element>
										<xsl:element name="title">
											<xsl:value-of select="request-param[@name='titleDescription']"/>
										</xsl:element>
										<xsl:element name="surname_prefix">
											<xsl:value-of select="request-param[@name='surnamePrefix']"/>
										</xsl:element>
										<xsl:element name="profession">
											<xsl:value-of select="request-param[@name='profession']"/>
										</xsl:element>
										<xsl:element name="industry_group">
											<xsl:value-of select="request-param[@name='industrialSectorRd']"/>
										</xsl:element>
										<xsl:element name="address_additional_text">
											<xsl:value-of select="request-param[@name='additionalText']"/>
										</xsl:element>                                                                                                                                                                                                                                
										<xsl:element name="street_name">
											<xsl:value-of select="request-param[@name='streetName']"/>
										</xsl:element>
										<xsl:element name="street_number">
											<xsl:value-of select="request-param[@name='streetNumber']"/>
										</xsl:element>
										<xsl:element name="street_number_suffix">
											<xsl:value-of select="request-param[@name='numberSuffix']"/>
										</xsl:element>
										<xsl:element name="post_office_box">
											<xsl:value-of select="request-param[@name='postOfficeBox']"/>
										</xsl:element>
										<xsl:element name="postal_code">
											<xsl:value-of select="request-param[@name='postalCode']"/>
										</xsl:element>
										<xsl:element name="city_name">
											<xsl:value-of select="request-param[@name='city']"/>
										</xsl:element>
										<xsl:element name="city_suffix">
											<xsl:value-of select="request-param[@name='citySuffix']"/>
										</xsl:element>
										<xsl:element name="country">DE</xsl:element>
									</xsl:element>	
								</xsl:otherwise>
							</xsl:choose>							
							<!-- Directory Entry type -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0101</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='directoryEntryType']"/>
								</xsl:element>
							</xsl:element>
							<!-- DTAG ID -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0102</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='DTAGID']"/>
								</xsl:element>
							</xsl:element>
							<!-- Inverssuche -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0148</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='inverseSearchIndicator']"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="provider_tracking_no">
							<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
						</xsl:element>
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
								<xsl:element name="command_id">add_dir_entry</xsl:element>
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
					<xsl:element name="command_id">create_co_1</xsl:element>
					<xsl:element name="CcmFifCreateCustOrderInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="cust_order_description">Telefonbucheintrag</xsl:element>          
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
								<xsl:element name="command_id">add_dir_entry</xsl:element>
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
				
				<xsl:element name="CcmFifCreateExternalNotificationCmd">
					<xsl:element name="command_id">create_notification_1</xsl:element>
					<xsl:element name="CcmFifCreateExternalNotificationInCont">
						<xsl:element name="effective_date">
							<xsl:value-of select="$today"/>
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
									<xsl:element name="command_id">create_co_1</xsl:element>
									<xsl:element name="field_name">customer_order_id</xsl:element>
								</xsl:element>
							</xsl:element>	
						</xsl:element>          
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">create_co_1</xsl:element>
							<xsl:element name="field_name">customer_order_created</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>   
					</xsl:element>
				</xsl:element>  
				
			</xsl:when>			
			<xsl:otherwise>
				
				<xsl:variable name="Type" select="request-param[@name='type']"/> 
				
				<!-- Find Service Subscription by SS ID -->
				<xsl:if test="(request-param[@name='serviceSubscriptionId'] != '')">
					<xsl:element name="CcmFifFindServiceSubsCmd">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="CcmFifFindServiceSubsInCont">
							<xsl:element name="service_subscription_id">
								<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
				
				<!-- Take value of serviceSubscriptionId from ccm external notification if not not provided -->
				<xsl:if test="(request-param[@name='serviceSubscriptionId'] = '')">		
					
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
					</xsl:if> 
					
					<xsl:element name="CcmFifFindServiceSubsCmd">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="CcmFifFindServiceSubsInCont">
							<xsl:element name="service_subscription_id_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
							<xsl:element name="effective_date">
								<xsl:value-of select="request-param[@name='desiredDate']"/>
							</xsl:element>						
						</xsl:element>
					</xsl:element>
				</xsl:if>
				
				<!-- find an open customer order for the main access service -->
				<xsl:element name="CcmFifFindCustomerOrderCmd">
					<xsl:element name="command_id">find_customer_order_1</xsl:element>
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
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">PROVISIONED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">INSTALLED</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="allow_children">Y</xsl:element>
						<xsl:element name="usage_mode">1</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<xsl:variable name="inverseSearchIndicator">
					<xsl:if test="request-param[@name='inverseSearchIndicator'] = 'Y'">J</xsl:if>
					<xsl:if test="request-param[@name='inverseSearchIndicator'] != 'Y'">
						<xsl:value-of select="request-param[@name='inverseSearchIndicator']"/>
					</xsl:if>
				</xsl:variable>
				
				<!-- Add Directory Entry-->
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_dir_entry</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0100</xsl:element>
						<xsl:element name="service_subscription_id">
							<xsl:value-of select="request-param[@name='allocatedServiceSubscriptionId']"/>
						</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element> 					
						<xsl:element name="desired_date">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
						<xsl:if test="(request-param[@name='reasonRd'] = '')">
							<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
						</xsl:if>	
						<xsl:if test="(request-param[@name='reasonRd'] != '')">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>					
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">account_number</xsl:element>
						</xsl:element>
						<xsl:element name="service_characteristic_list">
							<xsl:if test="(request-param[@name='directoryEntryText'] = '')">
								<xsl:element name="CcmFifDirectoryEntryCont">
									<xsl:element name="service_char_code">V0100</xsl:element>
									<xsl:element name="data_type">DIRECTORY_ENTRY</xsl:element>
									<xsl:element name="type">01  PRN  ELewAUS</xsl:element>
									<xsl:element name="access_number">
										<xsl:value-of select="$accessNumber"/>
									</xsl:element>
									<xsl:element name="name">
										<xsl:value-of select="request-param[@name='name']"/>
									</xsl:element>
									<xsl:element name="forename">
										<xsl:value-of select="request-param[@name='forename']"/>
									</xsl:element>
									<xsl:element name="nobility_prefix">
										<xsl:value-of select="request-param[@name='nobilityPrefixDescription']"/>
									</xsl:element>
									<xsl:element name="title">
										<xsl:value-of select="request-param[@name='titleDescription']"/>
									</xsl:element>
									<xsl:element name="surname_prefix">
										<xsl:value-of select="request-param[@name='surnamePrefix']"/>
									</xsl:element>
									<xsl:element name="profession">
										<xsl:value-of select="request-param[@name='profession']"/>
									</xsl:element>
									<xsl:element name="industry_group">
										<xsl:value-of select="request-param[@name='industrialSectorRd']"/>
									</xsl:element>
									<xsl:element name="address_additional_text">
										<xsl:value-of select="request-param[@name='additionalText']"/>
									</xsl:element>                                                                                                                                                                                                                                
									<xsl:element name="street_name">
										<xsl:value-of select="request-param[@name='streetName']"/>
									</xsl:element>
									<xsl:element name="street_number">
										<xsl:value-of select="request-param[@name='streetNumber']"/>
									</xsl:element>
									<xsl:element name="street_number_suffix">
										<xsl:value-of select="request-param[@name='numberSuffix']"/>
									</xsl:element>
									<xsl:element name="post_office_box">
										<xsl:value-of select="request-param[@name='postOfficeBox']"/>
									</xsl:element>
									<xsl:element name="postal_code">
										<xsl:value-of select="request-param[@name='postalCode']"/>
									</xsl:element>
									<xsl:element name="city_name">
										<xsl:value-of select="request-param[@name='city']"/>
									</xsl:element>
									<xsl:element name="city_suffix">
										<xsl:value-of select="request-param[@name='citySuffix']"/>
									</xsl:element>
									<xsl:element name="country">DE</xsl:element>
								</xsl:element>	
							</xsl:if>	
							<xsl:if test="(request-param[@name='directoryEntryText'] != '')">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0100</xsl:element>
									<xsl:element name="data_type">DIRECTORY_ENTRY</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='directoryEntryText']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>			
							<!-- Directory Entry type -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0101</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='directoryEntryType']"/>
								</xsl:element>
							</xsl:element>
							<!-- DTAG ID -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0102</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='DTAGID']"/>
								</xsl:element>
							</xsl:element>
							<!-- Inverssuche -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0148</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="$inverseSearchIndicator"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="provider_tracking_no">
							<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- Create Customer Order for new service  -->
				<xsl:element name="CcmFifCreateCustOrderCmd">
					<xsl:element name="command_id">create_co_1</xsl:element>
					<xsl:element name="CcmFifCreateCustOrderInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="cust_order_description">Add Directory Entry</xsl:element>
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
						<xsl:element name="scan_date">
							<xsl:value-of select="request-param[@name='scanDate']"/>
						</xsl:element>
						<xsl:element name="order_entry_date">
							<xsl:value-of select="request-param[@name='entryDate']"/>
						</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] = 'PROVIDER_CHANGE'">
							<xsl:element name="offset_release_days">1</xsl:element> 
						</xsl:if> 
						<xsl:element name="service_ticket_pos_list">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_dir_entry</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>	
				
				<!-- Release delayed CO if an open CO is found -->               
				<xsl:element name="CcmFifReleaseCustOrderCmd">
					<xsl:element name="CcmFifReleaseCustOrderInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="customer_order_ref">
							<xsl:element name="command_id">create_co_1</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>
						</xsl:element>
						<xsl:element name="parent_customer_order_id_ref">
							<xsl:element name="command_id">find_customer_order_1</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>          	
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
			</xsl:otherwise>
		</xsl:choose>
		
		<!-- Create Contact for Directory Entry -->
		<xsl:element name="CcmFifCreateContactCmd">
			<xsl:element name="CcmFifCreateContactInCont">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">find_main_service</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>
				</xsl:element>
				<xsl:element name="contact_type_rd">TELBUCH</xsl:element>
				<xsl:element name="short_description">
					<xsl:text>Telefonbucheintrag angelegt</xsl:text>					
				</xsl:element>
				<xsl:element name="long_description_text">
					<xsl:text>Transaction ID: </xsl:text>
					<xsl:value-of select="request-param[@name='transactionID']"/>
					<xsl:text> (</xsl:text>
					<xsl:value-of select="request-param[@name='clientName']"/>
					<xsl:text>)</xsl:text>
					<xsl:if test="(request-param[@name='userName'] != '')">
						<xsl:text>&#xA;UserName: </xsl:text>
						<xsl:value-of select="request-param[@name='userName']"/>
					</xsl:if>
					<xsl:text>&#xA;</xsl:text>
					<xsl:if test="(request-param[@name='desiredDate'] != '')">
						<xsl:variable name="Contact1" select="request-param[@name='desiredDate']"/>
						<xsl:value-of select="concat('Der Telephonbucheintrag wurde am ',$Contact1,' angelegt')"/>
					</xsl:if>						 
					<xsl:if test="(request-param[@name='desiredDate'] = '')">
						<xsl:variable name="Contact1" select="$today"/>
						<xsl:value-of select="concat('Der Telephonbucheintrag wurde am ',$Contact1,' angelegt')"/>
					</xsl:if>
				</xsl:element>
			</xsl:element>
		</xsl:element>
		
		<xsl:if test="request-param[@name='functionID'] != ''">		
			<xsl:element name="CcmFifPassBackValueCmd">
				<xsl:element name="command_id">passback_1</xsl:element>
				<xsl:element name="CcmFifPassBackValueInCont">
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">functionID</xsl:element>
							<xsl:element name="parameter_value">
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
	</xsl:element>
</xsl:template>
</xsl:stylesheet>
