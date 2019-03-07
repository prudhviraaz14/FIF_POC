<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
XSLT file for creating a FIF request for Reset Internet Access Device Pin
@author Shrikant Bhagwan
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

			<!-- Convert the termination date to OPM format -->
			<xsl:variable name="desiredDateOPM"
				select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
			
			<!-- Find Service Subscription by access number, STP Id or Service Subscription Id-->
			<xsl:if
				test="(request-param[@name='productSubscriptionId'] != '') or (request-param[@name='accessNumber'] != '') or (request-param[@name='serviceTicketPositionId'] != '') or (request-param[@name='serviceSubscriptionId'] != '')">
				<xsl:element name="CcmFifFindServiceSubsCmd">
					<xsl:element name="command_id">find_service_1</xsl:element>
					<xsl:element name="CcmFifFindServiceSubsInCont">
						<xsl:if
							test="((request-param[@name='accessNumber'] != '' ) and (request-param[@name='serviceTicketPositionId'] = '') and (request-param[@name='serviceSubscriptionId'] = ''))">
							<xsl:element name="access_number">
								<xsl:value-of select="request-param[@name='accessNumber']"/>
							</xsl:element>
							<xsl:element name="access_number_format"
							>SEMICOLON_DELIMITED</xsl:element>
						</xsl:if>
						<xsl:if
							test="(request-param[@name='serviceTicketPositionId'] != '') and (request-param[@name='serviceSubscriptionId'] = '')">
							<xsl:element name="service_ticket_position_id">
								<xsl:value-of
									select="request-param[@name='serviceTicketPositionId']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
							<xsl:element name="service_subscription_id">
								<xsl:value-of select="request-param[@name='serviceSubscriptionId']"
								/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="effective_date">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:element>
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="contract_number">
							<xsl:value-of select="request-param[@name='contractNumber']"/>
						</xsl:element>
						<xsl:if
							test="((request-param[@name='productSubscriptionId'] != '' ) and (request-param[@name='accessNumber'] = '') and (request-param[@name='serviceTicketPositionId'] = '')  and (request-param[@name='serviceSubscriptionId'] = ''))">
							<xsl:element name="product_subscription_id">
								<xsl:value-of select="request-param[@name='productSubscriptionId']"
								/>
							</xsl:element>
							<xsl:element name="service_code">I1043</xsl:element>
							<xsl:element name="fetch_main_ss_from_ps_Ind">Y</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:if>


			<!-- Add Service Subscription for Reset IAD Pin -->
			<xsl:if test="request-param[@name='resetType'] != 'UpgradeToVoIP'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_1</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">I1211</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
						<xsl:element name="reason_rd">AEND</xsl:element>
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">account_number</xsl:element>
						</xsl:element>
						<xsl:element name="service_characteristic_list"/>
					</xsl:element>
				</xsl:element>
		    </xsl:if>

			<!-- Find productCode using productSubscriptionId -->
			<xsl:element name="CcmFifFindProductCommitmentCmd">
				<xsl:element name="command_id">find_product_commit_1</xsl:element>
				<xsl:element name="CcmFifFindProductCommitmentInCont">
					<xsl:element name="product_subscription_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Validity of the NGN productCode-->
			<xsl:element name="CcmFifValidateSCValueCmd">
				<xsl:element name="command_id">find_NGN_product_code</xsl:element>
				<xsl:element name="CcmFifValidateSCValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">find_product_commit_1</xsl:element>
						<xsl:element name="field_name">product_code</xsl:element>
					</xsl:element>
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">I1204</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>

 			<!-- Validity of the DSL-R productCode -->
			<xsl:element name="CcmFifValidateSCValueCmd">
				<xsl:element name="command_id">find_DSL_R_product_code</xsl:element>
				<xsl:element name="CcmFifValidateSCValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">find_product_commit_1</xsl:element>
						<xsl:element name="field_name">product_code</xsl:element>
					</xsl:element>
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">I1201</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Validity of the Bitstream productCode-->
			<xsl:element name="CcmFifValidateSCValueCmd">
				<xsl:element name="command_id">find_Bitstream_product_code</xsl:element>
				<xsl:element name="CcmFifValidateSCValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">find_product_commit_1</xsl:element>
						<xsl:element name="field_name">product_code</xsl:element>
					</xsl:element>
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">I1203</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Validity of the ISDN productCode-->
			<xsl:element name="CcmFifValidateSCValueCmd">
				<xsl:element name="command_id">find_ISDN_product_code</xsl:element>
				<xsl:element name="CcmFifValidateSCValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">find_product_commit_1</xsl:element>
						<xsl:element name="field_name">product_code</xsl:element>
					</xsl:element>
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">V0002</xsl:element>
						</xsl:element>
					</xsl:element>
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
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_ISDN_product_code</xsl:element>
						<xsl:element name="field_name">service_code_valid</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
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
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_ISDN_product_code</xsl:element>
						<xsl:element name="field_name">service_code_valid</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Validity of the ISDN productCode-->
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
							<xsl:element name="value">Ja</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_ISDN_product_code</xsl:element>
						<xsl:element name="field_name">service_code_valid</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Reconfigure Service Subscription : For NGN Product -->
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
						<!-- Reconfiguration reason : if resetType = Add -->
						<xsl:if
							test="(request-param[@name='resetType'] = '') or (request-param[@name='resetType'] = 'Add')">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0943</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">Änderung IAD-PIN</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Reconfiguration reason : if resetType = Replace -->
						<xsl:if test="(request-param[@name='resetType'] = 'Replace')">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0943</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">Ersetze IAD-PIN</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Aktivierungsdatum -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0909</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$desiredDateOPM"/>
							</xsl:element>
						</xsl:element>	
						<!-- Bearbeitungsart -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0971</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">TAL</xsl:element>
						</xsl:element>					
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_NGN_product_code</xsl:element>
						<xsl:element name="field_name">service_code_valid</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Reconfigure Service Subscription : For DSL-R Product-->
			<xsl:element name="CcmFifReconfigServiceCmd">
				<xsl:element name="command_id">reconf_serv_1</xsl:element>
				<xsl:element name="CcmFifReconfigServiceInCont">
					<xsl:element name="service_subscription_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:if test="request-param[@name='resetType'] = 'UpgradeToVoIP'">
						<xsl:element name="reason_rd">UPGRADE_VOIP</xsl:element>
					</xsl:if>	
					<xsl:if test="request-param[@name='resetType'] != 'UpgradeToVoIP'">
						<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">

						<!-- Reconfiguration reason : if resetType = Add -->
						<xsl:if
							test="(request-param[@name='resetType'] = '') or (request-param[@name='resetType'] = 'Add')">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">I1011</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">Änderung IAD-PIN</xsl:element>
							</xsl:element>
						</xsl:if>

						<!-- Auftragsvariante : if resetType = Replace -->
						<xsl:if test="(request-param[@name='resetType'] = 'Replace')">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">I1011</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">Ersetze IAD-PIN</xsl:element>
							</xsl:element>
						</xsl:if>
						
						<!-- Auftragsvariante : if resetType = Replace -->
						<xsl:if test="(request-param[@name='resetType'] = 'UpgradeToVoIP')">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">I1011</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">Upgrade DSL-R VoIP</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Aktivierungsdatum -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0909</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$desiredDateOPM"/>
							</xsl:element>
						</xsl:element>	
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_DSL_R_product_code</xsl:element>
						<xsl:element name="field_name">service_code_valid</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Reconfigure Service Subscription : For Bitstream Product -->
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
						<!-- Reconfiguration reason : if resetType = Add -->
						<xsl:if
							test="(request-param[@name='resetType'] = '') or (request-param[@name='resetType'] = 'Add')">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0943</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">Änderung IAD-PIN</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Reconfiguration reason : if resetType = Replace -->
						<xsl:if test="(request-param[@name='resetType'] = 'Replace')">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0943</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">Ersetze IAD-PIN</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Aktivierungsdatum -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0909</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$desiredDateOPM"/>
							</xsl:element>
						</xsl:element>	
						<!-- Bearbeitungsart -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0971</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">TAL</xsl:element>
						</xsl:element>					
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_Bitstream_product_code</xsl:element>
						<xsl:element name="field_name">service_code_valid</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
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
						<!-- Reconfiguration reason : if resetType = Add -->
						<xsl:if
							test="(request-param[@name='resetType'] = '') or (request-param[@name='resetType'] = 'Add')">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0943</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">Änderung IAD-PIN</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Reconfiguration reason : if resetType = Replace -->
						<xsl:if test="(request-param[@name='resetType'] = 'Replace')">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0943</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">Ersetze IAD-PIN</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Aktivierungsdatum -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0909</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$desiredDateOPM"/>
							</xsl:element>
						</xsl:element>
						<!-- Bearbeitungsart -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0971</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">TAL</xsl:element>
						</xsl:element>							
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">validate_csc_value_1</xsl:element>
						<xsl:element name="field_name">success_ind</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
		
			<!-- Create Customer Order for new service -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="cust_order_description">Reset IAD Pin</xsl:element>
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
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">reconf_serv_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>


			<!-- find an open customer order for the main access service  for ISDN-->
			<xsl:element name="CcmFifFindCustomerOrderCmd">
				<xsl:element name="command_id">find_customer_order_1</xsl:element>
				<xsl:element name="CcmFifFindCustomerOrderInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
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
					<xsl:element name="allow_children">N</xsl:element>
					<xsl:element name="usage_mode">1</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Release customer order without delay for Reset IAD Pin -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
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

			<!-- Create Contact for Reset IAD Pin -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">RESEND_KEY</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>Neuer Modem PIN</xsl:text>
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
								<xsl:text>Zusendung einer neuen IAD-PIN für Dienstenutzung </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text> wurde am </xsl:text>
								<xsl:value-of select="request-param[@name='desiredDate']"/>
								<xsl:text> angefordert.</xsl:text>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>

		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
