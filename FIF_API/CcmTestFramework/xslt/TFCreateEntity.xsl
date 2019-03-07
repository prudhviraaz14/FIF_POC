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
			<!-- Create Entity-->
			<xsl:element name="CcmFifCreateEntityCmd">
				<xsl:element name="command_id">create_entity_1</xsl:element>
				<xsl:element name="CcmFifCreateEntityInCont">
					<xsl:element name="entity_type">
						<xsl:value-of
							select="request-param[@name='ENTITY_TYPE']"/>
					</xsl:element>
					<xsl:element name="salutation_description">
						<xsl:value-of
							select="request-param[@name='SALUTATION_DESCRIPTION']"
						/>
					</xsl:element>
					<xsl:element name="title_description">
						<xsl:value-of
							select="request-param[@name='TITLE_DESCRIPTION']"/>
					</xsl:element>
					<xsl:element name="nobility_prefix_description">
						<xsl:value-of
							select="request-param[@name='NOBILITY_PREFIX_DESCRIPTION']"
						/>
					</xsl:element>
					<xsl:element name="forename">
						<xsl:value-of select="request-param[@name='FORENAME']"/>
					</xsl:element>
					<xsl:element name="name">
						<xsl:value-of select="request-param[@name='NAME']"/>
					</xsl:element>
					<xsl:element name="birth_date">
						<xsl:value-of select="request-param[@name='BIRTH_DATE']"
						/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
