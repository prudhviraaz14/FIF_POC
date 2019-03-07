<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for activating a copy of a product subscription.
  @author naveen
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
		<xsl:element name="Command_List">
			<!-- Calculate today -->
			<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
			<!-- Calculate tomorrow -->
			<xsl:variable name="tomorrow" select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
			<xsl:if test="dateutils:compareString(request-param[@name='desiredDate'], $tomorrow) = '-1'">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">wrong_desiredDate</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">
							<xsl:text>Das Wunschdatum (desiredDate) muss mindestens morgen sein.</xsl:text>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_open_stp</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="product_subscription_id">
						<xsl:value-of select="request-param[@name='sourceProductSubscriptionId']"/>
					</xsl:element>
					<xsl:element name="no_stp_error">N</xsl:element>
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_ticket_position_state">UNASSIGNED</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_ticket_position_state">ASSIGNED</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_ticket_position_state">RELEASED</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_ticket_position_state">PROVISIONED</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_ticket_position_state">INSTALLED</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">open_stp_found</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
					<xsl:element name="error_text">
						<xsl:text>Mindestens eine offene Dienstekonfiguration besteht for Produktnutzung </xsl:text>
						<xsl:value-of select="request-param[@name='sourceProductSubscriptionId']"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_open_stp</xsl:element>
						<xsl:element name="field_name">stp_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifFindExternalOrderCmd">
				<xsl:element name="command_id">find_open_external_order</xsl:element>
				<xsl:element name="CcmFifFindExternalOrderInCont">
					<xsl:element name="product_subscription_id">
						<xsl:value-of select="request-param[@name='sourceProductSubscriptionId']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">open_stp_found</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
					<xsl:element name="error_text">
						<xsl:text>Mindestens ein offener externer Auftrag besteht for Produktnutzung </xsl:text>
						<xsl:value-of select="request-param[@name='sourceProductSubscriptionId']"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_open_external_order</xsl:element>
						<xsl:element name="field_name">external_order_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifValidateFutureDatedApplyExistsCmd">
				<xsl:element name="command_id">validate_future_apply</xsl:element>
				<xsl:element name="CcmFifValidateFutureDatedApplyExistsInCont">
					<xsl:element name="product_subscription_id">
						<xsl:value-of select="request-param[@name='sourceProductSubscriptionId']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">open_stp_found</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
					<xsl:element name="error_text">
						<xsl:text>Zukunftiger Tarifwechsel ist noch offen for Produktnutzung </xsl:text>
						<xsl:value-of select="request-param[@name='sourceProductSubscriptionId']"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">validate_future_apply</xsl:element>
						<xsl:element name="field_name">future_dated_apply_exists</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifGetProductCommitmentDataCmd">
				<xsl:element name="command_id">check_latest_version</xsl:element>
				<xsl:element name="CcmFifGetProductCommitmentDataInCont">
					<xsl:element name="product_commitment_number">
						<xsl:value-of select="request-param[@name='sourceProductCommitmentNumber']"/>
					</xsl:element>
					<xsl:element name="retrieve_signed_version">Y</xsl:element>
					<xsl:element name="contract_type_rd">
						<xsl:value-of select="request-param[@name='sourceContractType']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifMapStringCmd">
				<xsl:element name="command_id">check_contract_state</xsl:element>
				<xsl:element name="CcmFifMapStringInCont">
					<xsl:element name="input_string_type">Vertragsstatus</xsl:element>
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">check_latest_version</xsl:element>
							<xsl:element name="field_name">state_rd</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="output_string_type">Unterzeichnet</xsl:element>
					<xsl:element name="string_mapping_list">
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">SIGNED</xsl:element>
							<xsl:element name="output_string">Y</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="no_mapping_error">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">termination_date_set</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
					<xsl:element name="error_text">
						<xsl:text>Das Kundigungsdatum des </xsl:text>
						<xsl:choose>
							<xsl:when test="request-param[@name='sourceContractType'] = 'O'">
								<xsl:text>Auftragformulars </xsl:text>
								<xsl:value-of select="request-param[@name='sourceContractNumber']"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>Servicescheins </xsl:text>
								<xsl:value-of select="request-param[@name='sourceProductCommitmentNumber']"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:text> ist gesetzt.</xsl:text>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">check_latest_version</xsl:element>
						<xsl:element name="field_name">termination_date_set</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Get BundleId if not provided from external notification-->
			<xsl:if test="request-param[@name='targetBundleId'] = ''">
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_bundle_Id_from_ext_noti</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="target_system">FIF</xsl:element>
						<xsl:element name="parameter_name">BUNDLE_ID</xsl:element>
						<xsl:element name="ignore_empty_result">Y</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Find BundleId is active or not-->
			<xsl:element name="CcmFifFindBundleCmd">
				<xsl:element name="command_id">find_bundle</xsl:element>
				<xsl:element name="CcmFifFindBundleInCont">
					<xsl:if test="request-param[@name='targetBundleId'] != ''">
						<xsl:element name="bundle_id">
							<xsl:value-of select="request-param[@name='targetBundleId']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='targetBundleId'] = ''">
						<xsl:element name="bundle_id_ref">
							<xsl:element name="command_id">read_bundle_Id_from_ext_noti</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:element name="effective_status">ACTIVE</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifMapStringCmd">
				<xsl:element name="command_id">map_validate_extenal_bundle</xsl:element>
				<xsl:element name="CcmFifMapStringInCont">
					<xsl:element name="input_string_type">[Y;N]</xsl:element>
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">read_bundle_Id_from_ext_noti</xsl:element>
							<xsl:element name="field_name">value_found</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">;</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="output_string_type">[Y,N]</xsl:element>
					<xsl:element name="string_mapping_list">
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">Y;</xsl:element>
							<xsl:element name="output_string">Y</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="no_mapping_error">N</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifMapStringCmd">
				<xsl:element name="command_id">map_validate_bundle_presence</xsl:element>
				<xsl:element name="CcmFifMapStringInCont">
					<xsl:element name="input_string_type">[Y,N];[Y,N]</xsl:element>
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">read_bundle_Id_from_ext_noti</xsl:element>
							<xsl:element name="field_name">value_found</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">;</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_bundle</xsl:element>
							<xsl:element name="field_name">bundle_found</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="output_string_type">[Y,N]</xsl:element>
					<xsl:element name="string_mapping_list">
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">Y;Y</xsl:element>
							<xsl:element name="output_string">Y</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">N;N</xsl:element>
							<xsl:element name="output_string">Y</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">;Y</xsl:element>
							<xsl:element name="output_string">Y</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="no_mapping_error">N</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">no_bundle_found</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
					<xsl:element name="error_text">
						<xsl:text>Kein aktives Bundel gefunden mit ID </xsl:text>
						<xsl:value-of select="request-param[@name='targetBundleId']"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">map_validate_bundle_presence</xsl:element>
						<xsl:element name="field_name">output_string_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- create a new bundle if no bundle is provided and createBundle is set to Y -->
			<xsl:if test="request-param[@name='createBundle'] = 'Y'">
				<xsl:element name="CcmFifModifyBundleCmd">
					<xsl:element name="command_id">create_bundle</xsl:element>
					<xsl:element name="CcmFifModifyBundleInCont">
						<xsl:element name="effective_date">
							<xsl:value-of select="dateutils:getCurrentDate()"/>
						</xsl:element>
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='targetCustomerNumber']"/>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">find_bundle</xsl:element>
							<xsl:element name="field_name">bundle_found</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">N</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Terminate Product Subscription -->
			<xsl:element name="CcmFifTerminateProductSubsCmd">
				<xsl:element name="command_id">terminate_ps</xsl:element>
				<xsl:element name="CcmFifTerminateProductSubsInCont">
					<xsl:element name="product_subscription_id">
						<xsl:value-of select="request-param[@name='sourceProductSubscriptionId']"/>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">NOT_RELEVANT</xsl:element>
					<xsl:element name="auto_customer_order">N</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Create Customer Order for Termination -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_termination_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='sourceCustomerNumber']"/>
					</xsl:element>
					<xsl:element name="cust_order_description">Produktnutzung kopieren - Kundigung</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_ps</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="processing_status">completedOPM</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- copies the product subscription
                        Input:
                                - ps source also as reference
                                (- customer)
                                - account
                                - target PC (contract)
                                - bundle
                                - desired date
                                - schedule type START_AFTER
                                - reason COPYPS_ACT

                                  - clone bundle items
                                  - set old bundle items to T
                                  - new bundle item to Y

                                - validate access numbers
                                - create address objects (only create, if not exists => for new customer)
                                - clone SD for identical price plan
                                - warn about other SDs
                                - clone CI, where internal
                                - warn about other CIs
                                - warn about PPS options, if different price plan
                                - warn about PSGs
                                - warn about complex account usage
                                - warn about not cloned services

                                Output:
                                - stp_list
                                - productSubsID
                                - bundleID

                        -->
			<!-- Copy or move product subscriptions if a bundle is provided or found in external notifications table -->
			<xsl:element name="CcmFifCopyMoveProductSubscriptionCmd">
				<xsl:element name="command_id">copy_ps</xsl:element>
				<xsl:element name="CcmFifCopyMoveProductSubscriptionInCont">
					<xsl:element name="product_subscription_id">
						<xsl:value-of select="request-param[@name='sourceProductSubscriptionId']"/>
					</xsl:element>
					<xsl:element name="target_customer_number">
						<xsl:value-of select="request-param[@name='targetCustomerNumber']"/>
					</xsl:element>
					<xsl:element name="target_account_number">
						<xsl:value-of select="request-param[@name='targetAccountNumber']"/>
					</xsl:element>
					<xsl:element name="target_contract_number">
						<xsl:value-of select="request-param[@name='targetContractNumber']"/>
					</xsl:element>
					<xsl:element name="target_product_commitment_number">
						<xsl:value-of select="request-param[@name='targetProductCommitmentNumber']"/>
					</xsl:element>
					<xsl:element name="target_bundle_id_ref">
						<xsl:element name="command_id">find_bundle</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">NOT_RELEVANT</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_bundle</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Copy or move product subscriptions to newly created bundle -->
			<xsl:element name="CcmFifCopyMoveProductSubscriptionCmd">
				<xsl:element name="command_id">copy_ps</xsl:element>
				<xsl:element name="CcmFifCopyMoveProductSubscriptionInCont">
					<xsl:element name="product_subscription_id">
						<xsl:value-of select="request-param[@name='sourceProductSubscriptionId']"/>
					</xsl:element>
					<xsl:element name="target_customer_number">
						<xsl:value-of select="request-param[@name='targetCustomerNumber']"/>
					</xsl:element>
					<xsl:element name="target_account_number">
						<xsl:value-of select="request-param[@name='targetAccountNumber']"/>
					</xsl:element>
					<xsl:element name="target_contract_number">
						<xsl:value-of select="request-param[@name='targetContractNumber']"/>
					</xsl:element>
					<xsl:element name="target_product_commitment_number">
						<xsl:value-of select="request-param[@name='targetProductCommitmentNumber']"/>
					</xsl:element>
					<xsl:element name="target_bundle_id_ref">
						<xsl:element name="command_id">create_bundle</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">NOT_RELEVANT</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_bundle</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifConcatStringsCmd">
				<xsl:element name="command_id">find_product_subscription_id</xsl:element>
				<xsl:element name="CcmFifConcatStringsInCont">
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">copy_ps</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Create Customer Order for Termination -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_activation_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='targetCustomerNumber']"/>
					</xsl:element>
					<xsl:element name="cust_order_description">Produktnutzung kopieren - Aktivierung</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">copy_ps</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="processing_status">completedOPM</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Write to Provider-Change-Log -->
			<xsl:element name="CcmFifCreateProviderChangeLogCmd">
				<xsl:element name="command_id">create_provider_change_log</xsl:element>
				<xsl:element name="CcmFifCreateProviderChangeLogInCont">
					<xsl:element name="act_customer_order_id_ref">
						<xsl:element name="command_id">create_activation_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="term_customer_order_id_ref">
						<xsl:element name="command_id">create_termination_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="source_system">
						<xsl:value-of select="request-param[@name='clientName']"/>
					</xsl:element>
					<xsl:element name="creation_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
					<xsl:element name="reason_rd">COPYPS</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- "release" act CO with delay -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">release_activation_co</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='targetCustomerNumber']"/>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_activation_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="release_delay_date">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!--
                                "release" term CO with dependency
                        - dependent from activation CO
                        => also cancel when canceled
                         -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">release_termination_co</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='sourceCustomerNumber']"/>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_termination_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="parent_customer_order_id_ref">
						<xsl:element name="command_id">create_activation_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='sourceCustomerNumber']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">COPYPS</xsl:element>
					<xsl:element name="short_description">Produktnutzung verschoben</xsl:element>
					<xsl:element name="description_text_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>Verschieben einer Produktnutzung wurde zum </xsl:text>
								<xsl:value-of select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
								<xsl:text> wie folgt beauftragt:</xsl:text>
								<xsl:text>&#xA;Quelle:</xsl:text>
								<xsl:text>&#xA;- Kunde: </xsl:text>
								<xsl:value-of select="request-param[@name='sourceCustomerNumber']"/>
								<xsl:choose>
									<xsl:when test="request-param[@name='sourceContractType'] = 'O'">
										<xsl:text>&#xA;- Auftragsformular: </xsl:text>
										<xsl:value-of select="request-param[@name='sourceContractNumber']"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>&#xA;- Dienstleistungsvertrag: </xsl:text>
										<xsl:value-of select="request-param[@name='sourceContractNumber']"/>
										<xsl:text>&#xA;- Serviceschein: </xsl:text>
										<xsl:value-of select="request-param[@name='sourceProductCommitmentNumber']"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>&#xA;- Produktnutzung: </xsl:text>
								<xsl:value-of select="request-param[@name='sourceProductSubscriptionId']"/>
								<xsl:if test="request-param[@name='sourceBundleId'] != ''">
									<xsl:text>&#xA;- Bundel: </xsl:text>
									<xsl:value-of select="request-param[@name='sourceBundleId']"/>
								</xsl:if>
								<xsl:text>&#xA;Ziel:</xsl:text>
								<xsl:text>&#xA;- Kunde: </xsl:text>
								<xsl:value-of select="request-param[@name='targetCustomerNumber']"/>
								<xsl:choose>
									<xsl:when test="request-param[@name='targetContractType'] = 'O'">
										<xsl:text>&#xA;- Auftragsformular: </xsl:text>
										<xsl:value-of select="request-param[@name='targetContractNumber']"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>&#xA;- Dienstleistungsvertrag: </xsl:text>
										<xsl:value-of select="request-param[@name='targetContractNumber']"/>
										<xsl:text>&#xA;- Serviceschein: </xsl:text>
										<xsl:value-of select="request-param[@name='targetProductCommitmentNumber']"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>&#xA;- Produktnutzung: </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">copy_ps</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>&#xA;- Bundel: </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">copy_ps</xsl:element>
							<xsl:element name="field_name">target_bundle_id</xsl:element>
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
			<xsl:if test="request-param[@name='targetCustomerNumber'] != request-param[@name='sourceCustomerNumber']">
				<xsl:element name="CcmFifCreateContactCmd">
					<xsl:element name="CcmFifCreateContactInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='targetCustomerNumber']"/>
						</xsl:element>
						<xsl:element name="contact_type_rd">COPYPS</xsl:element>
						<xsl:element name="short_description">Produktnutzung verschoben</xsl:element>
						<xsl:element name="description_text_list">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="contact_text">
									<xsl:text>Verschieben einer Produktnutzung wurde zum </xsl:text>
									<xsl:value-of select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
									<xsl:text> wie folgt beauftragt:</xsl:text>
									<xsl:text>&#xA;Quelle:</xsl:text>
									<xsl:text>&#xA;- Kunde: </xsl:text>
									<xsl:value-of select="request-param[@name='sourceCustomerNumber']"/>
									<xsl:choose>
										<xsl:when test="request-param[@name='sourceContractType'] = 'O'">
											<xsl:text>&#xA;- Auftragsformular: </xsl:text>
											<xsl:value-of select="request-param[@name='sourceContractNumber']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>&#xA;- Dienstleistungsvertrag: </xsl:text>
											<xsl:value-of select="request-param[@name='sourceContractNumber']"/>
											<xsl:text>&#xA;- Serviceschein: </xsl:text>
											<xsl:value-of select="request-param[@name='sourceProductCommitmentNumber']"/>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:text>&#xA;- Produktnutzung: </xsl:text>
									<xsl:value-of select="request-param[@name='sourceProductSubscriptionId']"/>
									<xsl:if test="request-param[@name='sourceBundleId'] != ''">
										<xsl:text>&#xA;- Bundel: </xsl:text>
										<xsl:value-of select="request-param[@name='sourceBundleId']"/>
									</xsl:if>
									<xsl:text>&#xA;Ziel:</xsl:text>
									<xsl:text>&#xA;- Kunde: </xsl:text>
									<xsl:value-of select="request-param[@name='targetCustomerNumber']"/>
									<xsl:choose>
										<xsl:when test="request-param[@name='targetContractType'] = 'O'">
											<xsl:text>&#xA;- Auftragsformular: </xsl:text>
											<xsl:value-of select="request-param[@name='targetContractNumber']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>&#xA;- Dienstleistungsvertrag: </xsl:text>
											<xsl:value-of select="request-param[@name='targetContractNumber']"/>
											<xsl:text>&#xA;- Serviceschein: </xsl:text>
											<xsl:value-of select="request-param[@name='targetProductCommitmentNumber']"/>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:text>&#xA;- Produktnutzung: </xsl:text>
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">copy_ps</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="contact_text">
									<xsl:text>&#xA;- Bundel: </xsl:text>
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">copy_ps</xsl:element>
								<xsl:element name="field_name">target_bundle_id</xsl:element>
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
			</xsl:if>
			<xsl:if test="request-param[@name='requestListId'] != ''">
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<xsl:element name="command_id">create_notification</xsl:element>
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
							<xsl:element name="parameter_name">BUNDLE_ID</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">copy_ps</xsl:element>
								<xsl:element name="field_name">target_bundle_id</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">map_validate_extenal_bundle</xsl:element>
						<xsl:element name="field_name">output_string_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				</xsl:element>
			</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
