<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--
  XSLT file for creating a FIF request for creating access information

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
			<!-- Create Access Information -->
            <xsl:element name="CcmFifUpdateAccessInformCmd">
               <xsl:element name="command_id">create_access_information_1</xsl:element>
				<xsl:element name="CcmFifUpdateAccessInformInCont">
					<xsl:element name="entity_id">
						<xsl:value-of select="request-param[@name='ENTITY_ID']"/>
					</xsl:element>
					<xsl:element name="access_information_type_rd">
						<xsl:value-of select="request-param[@name='ACCESS_INFORMATION_TYPE']"/>
					</xsl:element>
					<xsl:element name="contact_name">
						<xsl:value-of select="request-param[@name='CONTACT_NAME']"/>
					</xsl:element>
					<xsl:element name="phone_number">
						<xsl:value-of select="request-param[@name='PHONE_NUMBER']"/>
					</xsl:element>
					<xsl:element name="mobile_number">
						<xsl:value-of select="request-param[@name='MOBILE_NUMBER']"/>
					</xsl:element>
					<xsl:element name="fax_number">
						<xsl:value-of select="request-param[@name='FAX_NUMBER']"/>
					</xsl:element>
					<xsl:element name="email_address">
						<xsl:value-of select="request-param[@name='EMAIL_ADDRESS']"/>
					</xsl:element>
					<xsl:element name="electronic_contact_indicator">
						<xsl:value-of select="request-param[@name='ELECTRONIC_CONTACT_INDICATOR']"/>
					</xsl:element>
				</xsl:element>
            </xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
