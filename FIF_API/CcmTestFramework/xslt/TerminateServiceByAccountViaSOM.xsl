<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for changing selected destinations
  
  @author schwarje
-->
<xsl:stylesheet version="1.0" xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1" indent="yes" method="xml"/>
	<xsl:template match="/">
		<xsl:element name="CcmFifCommandList">
			<xsl:apply-templates select="request/request-params"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="request-params">
		<xsl:variable name="TerminationReason">
			<xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
		</xsl:variable>
		<!-- Convert the termination date to OPM format -->
		<xsl:variable name="terminationDateOPM" select="dateutils:createOPMDate(request-param[@name='TERMINATION_DATE'])"/>
		<xsl:variable name="Today" select="dateutils:getCurrentDate()"/>
		<xsl:variable name="TerminationDate">
			<xsl:choose>
				<xsl:when test="dateutils:compareString(request-param[@name='TERMINATION_DATE'], $Today) = '-1'">
					<xsl:value-of select="$Today"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- Copy over transaction ID and action name -->
		<xsl:element name="transaction_id">
			<xsl:value-of select="request-param[@name='transactionID']"/>
		</xsl:element>
		<xsl:element name="client_name">SLS</xsl:element>
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
		</xsl:element>
		<xsl:element name="Command_List">
			<!-- call store function to check if termination is allowed -->
			<xsl:element name="CcmFifModifyRowForMigrationCmd">
				<xsl:element name="command_id">allow_termination_1</xsl:element>
				<xsl:element name="CcmFifModifyRowForMigrationInCont">
					<xsl:element name="sql_where">
						<xsl:text>select allow_termination_pkg.ALLOW_TERMINATION(&apos;</xsl:text>
						<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
						<xsl:text>&apos;) from dual</xsl:text>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- reaise error  -->
			<xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">termination_not_pssible_error_1</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
					<xsl:element name="error_text">
						<xsl:text>Die Kündigung der mit Rechnungskonto </xsl:text>
						<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
						<xsl:text> verbundenen Verträge ist aus einem oder mehreren der folgenden Gründe nicht möglich: Offene COM-Aufträge, offene interne Aufträge, zukunftsdatierte Vertragsänderung oder unvollständige Bündel.</xsl:text>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">allow_termination_1</xsl:element>
						<xsl:element name="field_name">result</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">NO</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- get account data -->
			<xsl:element name="CcmFifGetAccountDataCmd">
				<xsl:element name="command_id">get_account_data</xsl:element>
				<xsl:element name="CcmFifGetAccountDataInCont">
					<xsl:element name="account_number">
						<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
					</xsl:element>
					<xsl:element name="effective_date">
						<xsl:value-of select="$Today"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifGetCustomerDataCmd">
				<xsl:element name="command_id">get_customer_data</xsl:element>
				<xsl:element name="CcmFifGetCustomerDataInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">get_account_data</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifMapStringCmd">
				<xsl:element name="command_id">continue_termination</xsl:element>
				<xsl:element name="CcmFifMapStringInCont">
					<xsl:element name="input_string_type">ClassificationRd</xsl:element>
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">get_customer_data</xsl:element>
							<xsl:element name="field_name">classification_rd</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="output_string_type">BLikeClassificationExists</xsl:element>
					<xsl:element name="string_mapping_list">
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">B</xsl:element>
							<xsl:element name="output_string">Y</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">B1</xsl:element>
							<xsl:element name="output_string">Y</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">B2</xsl:element>
							<xsl:element name="output_string">Y</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">B3</xsl:element>
							<xsl:element name="output_string">Y</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">B4</xsl:element>
							<xsl:element name="output_string">Y</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="no_mapping_error">N</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Find main access Services -->
			<xsl:element name="CcmFifGetMainAccessServicesForAccountCmd">
				<xsl:element name="command_id">get_main_access_services_1</xsl:element>
				<xsl:element name="CcmFifGetMainAccessServicesForAccountInCont">
					<xsl:element name="account_number">
						<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
					</xsl:element>
					<xsl:element name="ignore_pending_termination">
						<xsl:value-of select="request-param[@name='IGNORE_PENDING_TERMINATION']"/>
					</xsl:element>
					<xsl:element name="effective_date">
						<xsl:value-of select="$TerminationDate"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Terminate simple services & cancels ordered ones -->
			<xsl:element name="CcmFifTerminateServicesSOMCmd">
				<xsl:element name="command_id">term_simple_services_1</xsl:element>
				<xsl:element name="CcmFifTerminateServicesSOMInCont">
					<xsl:element name="service_subscription_list_ref">
						<xsl:element name="command_id">get_main_access_services_1</xsl:element>
						<xsl:element name="field_name">service_subscription_list</xsl:element>
					</xsl:element>
					<xsl:element name="termination_date">
						<xsl:value-of select="$TerminationDate"/>
					</xsl:element>
					<xsl:element name="notice_per_start_date">
						<xsl:value-of select="$Today"/>
					</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='REASON_RD']"/>
					</xsl:element>
					<xsl:element name="termination_reason_rd">
						<xsl:value-of select="$TerminationReason"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">continue_termination</xsl:element>
						<xsl:element name="field_name">output_string_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Create KBA notification  -->
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<!-- Get today's date -->
				<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
				<xsl:element name="command_id">create_kba_notification_1</xsl:element>
				<xsl:element name="CcmFifCreateExternalNotificationInCont">
					<xsl:element name="effective_date">
						<xsl:value-of select="$TerminationDate"/>
					</xsl:element>
					<xsl:element name="notification_action_name">createKBANotification</xsl:element>
					<xsl:element name="target_system">KBA</xsl:element>
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">get_account_data</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TYPE</xsl:element>
							<xsl:element name="parameter_value">PROCESS</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CATEGORY</xsl:element>
							<xsl:element name="parameter_value">SAPTerminationPorting</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">USER_NAME</xsl:element>
							<xsl:element name="parameter_value">SLS-Clearing</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">WORK_DATE</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="$today"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TEXT</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:text>Mahnstufenkündigung  des Rechnungskontos:</xsl:text>
								<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
								<xsl:text>.</xsl:text>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">continue_termination</xsl:element>
						<xsl:element name="field_name">output_string_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Create Contact for the Service Termination -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">get_account_data</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
					<xsl:element name="short_description">Automatische Kündigung</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>Kündigung der Dienste, die mit dem Rechnungskonto </xsl:text>
						<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
						<xsl:text> verknüpft sind.</xsl:text>
						<xsl:text>&#xA;Client name : </xsl:text>
						<xsl:value-of select="request-param[@name='clientName']"/>
						<xsl:text>&#xA;TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
						<xsl:text>&#xA;User name: </xsl:text>
						<xsl:value-of select="request-param[@name='USER_NAME']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
