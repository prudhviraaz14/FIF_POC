<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for sending KBA notification for PTSG 
	
	@author makuier 
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0" xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
			<xsl:variable name="contactText">
				<xsl:text>Die Bevorrechtigung Ihres Anschlusses endet in Kürze! </xsl:text>
				<xsl:text>wir möchten Sie darauf hinweisen, dass die befristete Gültigkeit Ihrer Bevorrechtigungsbescheinigung nach dem Post- und Telekommunikationssicherstellungsgesetz (PTSG) in Kürze endet. </xsl:text>
				<xsl:text>Nach § 7 Absatz 2 Satz 1 PTSG haben wir die Vorkehrungen zur Bevorrechtigung Ihres Anschlusses/ Ihrer Anschlüsse nach Ablauf der Frist unverzüglich aufzuheben. Falls Sie anschließend eine erneute Einrichtung dieser Bevorrechtigung wünschen, berechnen wir erneut die einmalige Pauschale je Anschluss gemäß § 9 Absatz 1 PTSG. </xsl:text>
				<xsl:text>Bitte beachten Sie: Sollten Sie uns eine neue Bevorrechtigungsbescheinigung nach § 6 Absatz 2 Satz 1 Nummer 9 PTSG rechtzeitig vor Ablauf der Gültigkeitsfrist der aktuellen Bevorrechtigungsbescheinigung vorlegen, so werden die bestehenden Bevorrechtigungen Ihres Anschlusses/ Ihrer Anschlüsse kostenfrei verlängert. </xsl:text>
				<xsl:text>Haben Sie weitere Fragen? Sie erreichen ihre Vodafone Kundenbetreuung unter 0123/456789.</xsl:text>
			</xsl:variable>
			<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_service_1</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="service_subscription_id">
						<xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
					</xsl:element>
					<xsl:element name="no_service_error">N</xsl:element>
					<xsl:element name="target_state">TERMINATED</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<!-- Get today's date -->
				<xsl:element name="command_id">create_kba_notification_1</xsl:element>
				<xsl:element name="CcmFifCreateExternalNotificationInCont">
					<xsl:element name="notification_action_name">createKBANotification</xsl:element>
					<xsl:element name="target_system">KBA</xsl:element>
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">find_service_1</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TYPE</xsl:element>
							<xsl:element name="parameter_value">PROCESS</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CATEGORY</xsl:element>
							<xsl:element name="parameter_value">PTSG</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">USER_NAME</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='clientName']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element>
							<xsl:element name="parameter_value">CCB</xsl:element>
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
								<xsl:value-of select="$contactText"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
