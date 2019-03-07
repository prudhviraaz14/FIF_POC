<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--
  XSLT file for creating a FIF request for finding a SS

  @author banania
-->
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
	<xsl:template match="/">
		<xsl:element name="CcmFifCommandList">
			<xsl:apply-templates select="request/request-params"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="request-params">
		<!-- Copy over transaction ID,action name & override_system_date -->
		<xsl:element name="transaction_id">
			<xsl:value-of select="request-param[@name='transactionID']"/>
		</xsl:element>
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
		</xsl:element>
		<xsl:element name="Command_List">
			<!-- Ensure that either access_number, service_ticket_position_id or service_subscription_id are provided -->
			<xsl:if test="(request-param[@name='ACCESS_NUMBER'] = '') and
				(request-param[@name='SERVICE_TICKET_POSITION_ID'] = '')  and
				(request-param[@name='SERVICE_SUBSCRIPTION_ID'] = '')">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">create_find_ss_error</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">At least one of the following params must be provided: access_number, service_ticket_position_id or service_subscription_id.</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_ss_1</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:if test="((request-param[@name='ACCESS_NUMBER'] != '' )and
						((request-param[@name='SERVICE_TICKET_POSITION_ID'] = '') and
						(request-param[@name='SERVICE_SUBSCRIPTION_ID'] = '')))">
						<xsl:element name="access_number">
							<xsl:value-of select="request-param[@name='ACCESS_NUMBER']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="(request-param[@name='SERVICE_TICKET_POSITION_ID'] != '') and
						(request-param[@name='SERVICE_SUBSCRIPTION_ID'] = '')">
						<xsl:element name="service_ticket_position_id">
							<xsl:value-of select="request-param[@name='SERVICE_TICKET_POSITION_ID']"
							/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='SERVICE_SUBSCRIPTION_ID'] != ''">
						<xsl:element name="service_subscription_id">
							<xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="contract_number">
						<xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
