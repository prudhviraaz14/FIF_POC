<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
XSLT file for creating a FIF request for upgrade ISDN service to ACS by setting CSC V0196 to Ja
@author Marcin Leja
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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

			<xsl:variable name="today" select="dateutils:getCurrentDate()"/> 
			<!-- Convert the termination date to OPM format -->
			<xsl:variable name="activationDateOPM"
				select="dateutils:createOPMDate(request-param[@name='activationDate'])"/>
			
			<!-- Find Service Subscription by access number, STP Id or Service Subscription Id-->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_service_1</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
   					<xsl:element name="service_subscription_id">
							<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
					</xsl:element>
					<xsl:element name="effective_date">
						<xsl:value-of select="request-param[@name='activationDate']"/>
					</xsl:element>
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="contract_number">
						<xsl:value-of select="request-param[@name='contractNumber']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Validity of the ISDN service code-->
			<xsl:element name="CcmFifValidateValueCmd">
				<xsl:element name="command_id">validate_csc_value_1</xsl:element>
				<xsl:element name="CcmFifValidateValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_code</xsl:element>
					</xsl:element>
					<xsl:element name="object_type">SERVICE_SUBSCIPTION</xsl:element>
					<xsl:element name="value_type">ISDN</xsl:element>
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">V0003</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">V0010</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Validate the service subscription state -->
			<xsl:element name="CcmFifValidateServiceSubsStateCmd">
				<xsl:element name="command_id">validate_ss_state_1</xsl:element>
				<xsl:element name="CcmFifValidateServiceSubsStateInCont">
					<xsl:element name="service_subscription_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_state">SUBSCRIBED</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Find most recent stp for the service to be reconfigured -->
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_stp_1</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Get the ACS-Nutzung V0196 in parent service's CSC  -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_csc_value_1</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_stp_1</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_char_code">V0196</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Validate V0196 - cannot be already set to Ja (only if sth found)-->
			<xsl:element name="CcmFifValidateValueCmd">
				<xsl:element name="command_id">validate_csc_value_1</xsl:element>
				<xsl:element name="CcmFifValidateValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">find_csc_value_1</xsl:element>
						<xsl:element name="field_name">characteristic_value</xsl:element>
					</xsl:element>
					<xsl:element name="object_type">ISDN</xsl:element>
					<xsl:element name="value_type">V0196</xsl:element>
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">Nein</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_csc_value_1</xsl:element>
						<xsl:element name="field_name">characteristic_value</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Ja</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifValidateValueCmd">
				<xsl:element name="command_id">validate_csc_value_1</xsl:element>
				<xsl:element name="CcmFifValidateValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">find_csc_value_1</xsl:element>
						<xsl:element name="field_name">characteristic_value</xsl:element>
					</xsl:element>
					<xsl:element name="object_type">ISDN</xsl:element>
					<xsl:element name="value_type">V0196</xsl:element>
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">Nein</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_csc_value_1</xsl:element>
						<xsl:element name="field_name">characteristic_value</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Nein</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Validate the if V011A service subscription exists -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_service_2</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="effective_date">
						<xsl:value-of select="request-param[@name='activationDate']"/>
					</xsl:element>
					<xsl:element name="product_subscription_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V011A</xsl:element>
					<xsl:element name="no_service_error">N</xsl:element>
					<xsl:element name="target_state">ORDERED</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Validate the if V011A service subscription exists -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_service_3</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="effective_date">
						<xsl:value-of select="request-param[@name='activationDate']"/>
					</xsl:element>
					<xsl:element name="product_subscription_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V011A</xsl:element>
					<xsl:element name="no_service_error">N</xsl:element>
					<xsl:element name="target_state">PURCHASED</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Verify if V011A exists -->    
			<xsl:element name="CcmFifConcatStringsCmd">
				<xsl:element name="command_id">concat_validate_service</xsl:element>
				<xsl:element name="CcmFifConcatStringsInCont">
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_service_2</xsl:element>
							<xsl:element name="field_name">service_found</xsl:element>							
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">;</xsl:element>							
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_service_3</xsl:element>
							<xsl:element name="field_name">service_found</xsl:element>							
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifMapStringCmd">
				<xsl:element name="command_id">map_validate_service</xsl:element>
				<xsl:element name="CcmFifMapStringInCont">
					<xsl:element name="input_string_type">[Y,N];[Y,N]</xsl:element>
					<xsl:element name="input_string_ref">
						<xsl:element name="command_id">concat_validate_service</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>
					</xsl:element>
					<xsl:element name="output_string_type">[Y,N]</xsl:element>
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
							<xsl:element name="input_string">N;N</xsl:element>
							<xsl:element name="output_string">NOT_EXISTS</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="no_mapping_error">N</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifValidateValueCmd">
				<xsl:element name="command_id">validate_validate_service</xsl:element>
				<xsl:element name="CcmFifValidateValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">map_validate_service</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>
					</xsl:element>
					<xsl:element name="object_type">PS</xsl:element>
					<xsl:element name="value_type">V011A</xsl:element>
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">Y</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Reconfigure Service Subscription : For ISDN Product -->
			<xsl:element name="CcmFifReconfigServiceCmd">
				<xsl:element name="command_id">reconf_serv_1</xsl:element>
				<xsl:element name="CcmFifReconfigServiceInCont">
					<xsl:element name="service_subscription_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
					<xsl:element name="service_characteristic_list">
						<!-- ACS-Nutzung -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0196</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">Ja</xsl:element>
						</xsl:element>
						<!-- Aktivierungsdatum -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0909</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$activationDateOPM"/>
							</xsl:element>
						</xsl:element>						
						<!-- Reconfiguration reason -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0943</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">ACS-Migration</xsl:element>
						</xsl:element>
						<!-- Reconfiguration Bearbeitungsart -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0971</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">TAL</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		
			<!-- find an open customer order for the main access service for V011A -->
			<xsl:element name="CcmFifFindCustomerOrderCmd">
				<xsl:element name="command_id">find_customer_order_1</xsl:element>
				<xsl:element name="CcmFifFindCustomerOrderInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_service_2</xsl:element>
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
					<xsl:element name="allow_children">N</xsl:element>
					<xsl:element name="usage_mode">5</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Add STPs to customer order if exists -->
			<xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
				<xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
					<xsl:element name="customer_order_id_ref">
						<xsl:element name="command_id">find_customer_order_1</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">reconf_serv_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_customer_order_1</xsl:element>
						<xsl:element name="field_name">customer_order_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Customer Order for reconfigured main access ISDN service -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="cust_order_description">ACS-Migration</xsl:element>
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
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_customer_order_1</xsl:element>
						<xsl:element name="field_name">customer_order_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Release customer order for reconfiguration -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_1</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_customer_order_1</xsl:element>
						<xsl:element name="field_name">customer_order_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Create Contact for ACS-Migration -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">ACS_MIGRATION</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>ACS-Migration über KBA</xsl:text>
					</xsl:element>
					<xsl:element name="description_text_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>Transaction ID: </xsl:text>
								<xsl:value-of select="request-param[@name='transactionID']"/>
								<xsl:if test="(request-param[@name='userName'] != '')">
									<xsl:text>&#xA;UserName: </xsl:text>
									<xsl:value-of select="request-param[@name='userName']"/>
								</xsl:if>
								<xsl:text>&#xA;</xsl:text>
								<xsl:text>ACS-Migration für Dienstenutzung </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text> wurde am </xsl:text>
								<xsl:value-of select="request-param[@name='activationDate']"/>
								<xsl:text> angefordert.</xsl:text>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>

		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
