<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--
  XSLT file for creating a FIF request for signing a SDC

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
			<xsl:element name="CcmFifSignServiceDelivContCmd">
				<xsl:element name="command_id">sign_sdc_1</xsl:element>
				<xsl:element name="CcmFifSignServiceDelivContInCont">
					<xsl:element name="contract_number">
						<xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
					</xsl:element>
					<xsl:element name="board_sign_name">
						<xsl:value-of select="request-param[@name='BOARD_SIGN_NAME']"/>
					</xsl:element>
					<xsl:element name="board_sign_date">
						<xsl:value-of select="request-param[@name='BOARD_SIGN_DATE']"/>
					</xsl:element>
					<xsl:element name="primary_cust_sign_name">
						<xsl:value-of select="request-param[@name='PRIMARY_CUST_SIGN_NAME']"/>
					</xsl:element>
					<xsl:element name="primary_cust_sign_date">
						<xsl:value-of select="request-param[@name='PRIMARY_CUST_SIGN_DATE']"/>
					</xsl:element>
					<xsl:element name="secondary_cust_sign_name">
						<xsl:value-of select="request-param[@name='SECONDARY_CUST_SIGN_NAME']"/>
					</xsl:element>
					<xsl:element name="secondary_cust_sign_date">
						<xsl:value-of select="request-param[@name='SECONDARY_CUST_SIGN_DATE']"/>
					</xsl:element>
					<xsl:element name="process_ind">
						<xsl:value-of select="request-param[@name='PROCESS_IND']"/>
					</xsl:element>
					<xsl:element name="required_process_ind">
						<xsl:value-of select="request-param[@name='REQUIRED_PROCESS_IND']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
