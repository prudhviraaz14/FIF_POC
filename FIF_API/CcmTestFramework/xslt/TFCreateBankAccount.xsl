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
			<!-- Create Address-->
			<xsl:element name="CcmFifCreateBankAccountCmd">
				<xsl:element name="command_id">create_bank_account_1</xsl:element>
				<xsl:element name="CcmFifCreateBankAccountInCont">
					<xsl:element name="customer_number">
						<xsl:value-of
							select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="bank_account_number">
						<xsl:value-of
							select="request-param[@name='BANK_ACCOUNT_NUMBER']"
						/>
					</xsl:element>
					<xsl:element name="owner_full_name">
						<xsl:value-of
							select="request-param[@name='OWNER_FULL_NAME']"/>
					</xsl:element>
					<xsl:element name="bank_clearing_code">
						<xsl:value-of
							select="request-param[@name='BANK_CLEARING_CODE']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
