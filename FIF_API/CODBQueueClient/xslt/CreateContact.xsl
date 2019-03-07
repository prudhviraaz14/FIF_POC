<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
	<!--
		XSLT file for creating a FIF request for Adding Hardware Service
		@author schwarje 
	-->
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
		
		<!-- Create Contact for hardware Service Addition -->
		<xsl:element name="CcmFifCreateContactCmd">
			<xsl:element name="CcmFifCreateContactInCont">
				<xsl:element name="customer_number">
					<xsl:value-of select="request-param[@name='customerNumber']"/>					
				</xsl:element>
				<xsl:element name="contact_type_rd">
					<xsl:value-of select="request-param[@name='contactType']"/>
				</xsl:element>
				<xsl:element name="short_description">
					<xsl:value-of select="request-param[@name='shortDescription']"/>
				</xsl:element>
				<xsl:element name="long_description_text">
					<xsl:value-of select="request-param[@name='longDescription']"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>							
		
	</xsl:element>
</xsl:template>
</xsl:stylesheet>
