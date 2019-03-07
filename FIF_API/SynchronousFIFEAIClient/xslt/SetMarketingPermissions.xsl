<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
XSLT file for updating permissions

@author schwarje
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
	<xsl:template match="/">
		<xsl:element name="CcmFifCommandList">
			<xsl:apply-templates select="request/request-params"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="request-params">
		<!-- Copy over transaction ID and action name -->
		<xsl:element name="transaction_id">
			<xsl:value-of select="request-param[@name='transactionID']" />
		</xsl:element>
		<xsl:element name="client_name">
			<xsl:value-of select="request-param[@name='clientName']" />
		</xsl:element>
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name" />
		</xsl:element>
		<xsl:element name="package_name">
			<xsl:value-of select="request-param[@name='packageName']" />
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']" />
		</xsl:element>
	
		<xsl:element name="Command_List">
	
			<xsl:element name="CcmFifUpdatePermissionPreferenceCmd">
				<xsl:element name="command_id">update_permissions</xsl:element>
				<xsl:element name="CcmFifUpdatePermissionPreferenceInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CustomerNumber']"/>
					</xsl:element>
					<xsl:element name="permission_date">
						<xsl:value-of select="request-param[@name='EffectiveTime']"/>
					</xsl:element>
					<xsl:element name="source_system_id">
						<xsl:value-of select="request-param[@name='SourceSystemId']"/>
					</xsl:element>
					<xsl:element name="campaign_id">
						<xsl:value-of select="request-param[@name='CampaignID']"/>
					</xsl:element>
					<xsl:element name="VOID">
						<xsl:value-of select="request-param[@name='VOID']"/>
					</xsl:element>
					<xsl:element name="permission_preference_list">
						<xsl:for-each select="request-param-list[@name='PermissionDetailsList;PermissionDetails']/request-param-list-item">
							<xsl:element name="CcmFifPermissionPreferenceCont">
								<xsl:element name="permission_id">
									<xsl:value-of select="request-param[@name='PermissionId']"/>
								</xsl:element>
								<xsl:element name="service_id">
									<xsl:value-of select="request-param[@name='ServiceId']"/>
								</xsl:element>
								<xsl:element name="permission_value">
									<xsl:value-of select="request-param[@name='NewPermissionValue']"/>
								</xsl:element>
					         <xsl:element name="bew_version">
						         <xsl:value-of select="request-param[@name='BewVersion']"/>
					         </xsl:element>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:element>
			</xsl:element>

<!-- 			CreateContact -->
	
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
