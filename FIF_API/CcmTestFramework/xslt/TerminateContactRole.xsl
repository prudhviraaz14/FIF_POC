<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--
  XSLT file for creating a FIF request for creating a full customer. It creates following:
  Entity, Address, Mailing, Account and Customer

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
			
			<!-- Get contact role entity -->
			<xsl:if test="request-param[@name='contactRoleEntityId'] != ''
				and request-param[@name='contactRoleId'] != ''">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">error</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">contactRoleEntityId und contactRoleId duerfen nicht beide angegeben werden.</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>			
						
			<xsl:if test="request-param[@name='contactRoleId'] != ''">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">notimplemented</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">Not implemented yet.</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Create Contact Role-->
			<xsl:element name="CcmFifTerminateContactRoleCmd">
				<xsl:element name="command_id">terminate</xsl:element>
				<xsl:element name="CcmFifTerminateContactRoleInCont">
					<xsl:if test="request-param[@name='contactRoleId'] != ''">
						<xsl:element name="contact_role_id">
							<xsl:value-of select="request-param[@name='contactRoleId']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='contactRoleEntityId'] != ''">
						<xsl:element name="contact_role_entity_id">
							<xsl:value-of select="request-param[@name='contactRoleEntityId']"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>				
			</xsl:element>			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
			
