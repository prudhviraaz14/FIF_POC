<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--
  XSLT file for creating a FIF request for applying a new pricing structure

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
			<!-- Create Entity-->
			<xsl:element name="CcmFifApplyNewPricingStructCmd">
				<xsl:element name="command_id">sign_and_apply_new_ps_1</xsl:element>
				<xsl:element name="CcmFifApplyNewPricingStructInCont">
					<xsl:element name="supported_object_id">
						<xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">
						<xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_TYPE_RD']"/>
					</xsl:element>
					<xsl:element name="apply_swap_date">
						<xsl:value-of select="request-param[@name='APPLY_SWAP_DATE']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
