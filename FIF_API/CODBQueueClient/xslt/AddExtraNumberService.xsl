<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a IPCSITE contract

  @author schwarje 
-->

<!DOCTYPE XSL [

<!ENTITY CSCMapping SYSTEM "CSCMapping.xsl">
<!ENTITY CSCMapping_ExtraNumbers SYSTEM "CSCMapping_ExtraNumbers.xsl">
<!ENTITY CSCMapping_AddressCreation SYSTEM "CSCMapping_AddressCreation.xsl">
]>

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
		
		<!-- variable for indicating that this is not a reconfiguration -->
		<xsl:variable name="isReconfiguration">N</xsl:variable>
		
		<!-- Calculate today and one day before the desired date -->
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
		
		<!-- Convert the desired date to OPM format -->
		<xsl:variable name="activationDateOPM"
			select="dateutils:createOPMDate(request-param[@name='activationDate'])"/>
		
		<xsl:variable name="desiredDate">
			<xsl:choose>
				<xsl:when test="request-param[@name='desiredDate'] != ''">
					<xsl:value-of select="request-param[@name='desiredDate']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$today"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:element name="Command_List">
						
			<!-- service subscription ID of main service (of parent function) -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_main_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="service_subscription_id">
						<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>			
			
			
			<!-- Get Entity Information -->   
			<xsl:element name="CcmFifGetEntityCmd">
				<xsl:element name="command_id">get_entity</xsl:element>
				<xsl:element name="CcmFifGetEntityInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
				&CSCMapping_ExtraNumbers;
				&CSCMapping_AddressCreation;
			</xsl:for-each>
			
			<!-- additional "Einzelrufnummern" -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_extra_number_service</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">
						<xsl:choose>
							<xsl:when test="request-param[@name='accessType'] = 'ipCentrex' and
								request-param[@name='serviceType'] = 'singleNumber'">VI061</xsl:when>
							<xsl:when test="request-param[@name='accessType'] = 'ipCentrex' and
								request-param[@name='serviceType'] = 'numberRange'">VI062</xsl:when>
							<xsl:when test="request-param[@name='accessType'] = 'sipTrunk' and
								request-param[@name='serviceType'] = 'singleNumber'">VI076</xsl:when>
							<xsl:when test="request-param[@name='accessType'] = 'sipTrunk' and
								request-param[@name='serviceType'] = 'numberRange'">VI077</xsl:when>
							<xsl:when test="request-param[@name='accessType'] = 'businessVoip' and
								request-param[@name='serviceType'] = 'singleNumber'">VI076</xsl:when>
							<xsl:when test="request-param[@name='accessType'] = 'businessVoip' and
								request-param[@name='serviceType'] = 'numberRange'">VI077</xsl:when>
							<xsl:when test="request-param[@name='accessType'] = 'oneNetBusiness' and
								request-param[@name='serviceType'] = 'singleNumber'">VI076</xsl:when>
							<xsl:when test="request-param[@name='accessType'] = 'oneNetBusiness' and
								request-param[@name='serviceType'] = 'numberRange'">VI077</xsl:when>
						</xsl:choose>
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
						<xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
							&CSCMapping_ExtraNumbers;
							&CSCMapping;
						</xsl:for-each>						
						<!-- Aktivierungsdatum -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0909</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$activationDateOPM" /> 
							</xsl:element>
						</xsl:element>						
					</xsl:element>
					<xsl:element name="provider_tracking_no">
						<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:choose>
				<!-- create a new customer order, if the main function was completed before -->
				<xsl:when test="request-param[@name='createCustomerOrder'] = 'Y'">
					<!-- Create Customer Order for new services  -->
					<xsl:element name="CcmFifCreateCustOrderCmd">
						<xsl:element name="command_id">create_co</xsl:element>
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
								<!-- extra number service -->
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">add_extra_number_service</xsl:element>
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
					
					<!--  Create external notification for internal purposes -->
					<xsl:element name="CcmFifCreateExternalNotificationCmd">
						<xsl:element name="command_id">create_notification</xsl:element>
						<xsl:element name="CcmFifCreateExternalNotificationInCont">
							<xsl:element name="effective_date">
								<xsl:value-of select="$desiredDate"/>
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
						</xsl:element>
					</xsl:element>				
				</xsl:when>
				<!-- attach the STP to the customer order of the main function, if they come together -->
				<xsl:otherwise>
					<!--Get customer order id from the previous request -->     
					<xsl:element name="CcmFifReadExternalNotificationCmd">
						<xsl:element name="command_id">read_customer_order_id</xsl:element>
						<xsl:element name="CcmFifReadExternalNotificationInCont">
							<xsl:element name="transaction_id">
								<xsl:value-of select="request-param[@name='requestListId']"/>
							</xsl:element>
							<xsl:element name="parameter_name">
								<xsl:value-of select="request-param[@name='type']"/>
								<xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
							</xsl:element>							
						</xsl:element>
					</xsl:element>
					<!-- add the STP -->
					<xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
						<xsl:element name="command_id">add_stps</xsl:element>
						<xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
							<xsl:element name="customer_order_id_ref">
								<xsl:element name="command_id">read_customer_order_id</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
							<xsl:element name="service_ticket_pos_list">
								<!-- extra number service -->
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">add_extra_number_service</xsl:element>
									<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
								</xsl:element>
							</xsl:element>     
							<xsl:element name="processing_status">
								<xsl:value-of select="request-param[@name='processingStatus']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>												
				</xsl:otherwise>
			</xsl:choose>
							
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="contact_type_rd">ADD_EXTRANUMBERS</xsl:element>
					<xsl:element name="short_description">IPC-Rufnummern hinzugefügt</xsl:element>
					<xsl:element name="description_text_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>IPC-Rufnummern hinzugefügt, Dienstenutzung: </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_extra_number_service</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>          
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">                								
								<xsl:text>&#xA;TransactionID: </xsl:text>
								<xsl:value-of select="request-param[@name='transactionID']"/>
								<xsl:text> (</xsl:text>
								<xsl:value-of select="request-param[@name='clientName']"/>
								<xsl:text>)</xsl:text>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
						
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
			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
