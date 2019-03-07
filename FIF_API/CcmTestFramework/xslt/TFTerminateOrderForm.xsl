<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--
  XSLT file for creating a FIF request for creating a Customer Message

  @author banania
-->
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1"
		doctype-system="fif_transaction.dtd"/>
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
			<xsl:element name="CcmFifTerminateOrderFormCmd">
				<xsl:element name="command_id">terminate_order_form_1</xsl:element>
				<xsl:element name="CcmFifTerminateOrderFormInCont">
					<xsl:element name="contract_number">
						<xsl:value-of
							select="request-param[@name='CONTRACT_NUMBER']"/>
					</xsl:element>
					<xsl:element name="termination_date">
						<xsl:value-of
							select="request-param[@name='TERMINATION_DATE']"/>
					</xsl:element>
					<xsl:element name="notice_per_start_date">
						<xsl:value-of
							select="request-param[@name='NOTICE_PER_START_DATE']"
						/>
					</xsl:element>
					<xsl:element name="override_restriction">
						<xsl:value-of
							select="request-param[@name='OVERRIDE_RESTRICTION']"
						/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
