<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for creating a OneGroup object
	
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
		
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>	
		
		<xsl:element name="Command_List">

			<xsl:element name="CcmFifReadExternalNotificationCmd">
				<xsl:element name="command_id">read_bundle_id</xsl:element>
				<xsl:element name="CcmFifReadExternalNotificationInCont">
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="parameter_name">
						<xsl:text>BUNDLE_ID</xsl:text>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create OneGroup -->
			<xsl:element name="CcmFifCreateOneNetSiteCmd">
				<xsl:element name="command_id">create_one_net_site</xsl:element>
				<xsl:element name="CcmFifCreateOneNetSiteInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>		
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">read_bundle_id</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>		
					<xsl:element name="one_net_id">
						<xsl:value-of select="request-param[@name='oneNetId']"/>
					</xsl:element>
					<xsl:element name="one_net_id_name">OneNetID</xsl:element>
					<xsl:element name="one_net_id_description">Defaultwert nach Vertragspartnerwechsel</xsl:element>					
					<xsl:element name="site_id">
						<xsl:value-of select="request-param[@name='siteId']"/>
					</xsl:element>
					<xsl:element name="site_name">Site</xsl:element>
					<xsl:element name="site_description">Defaultwert nach Vertragspartnerwechsel</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Contact for creation of new objects -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>		
					<xsl:element name="contact_type_rd">CREATE_ONB</xsl:element>
					<xsl:element name="short_description">OneNetID erstellt</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>OneNetID </xsl:text>
						<xsl:value-of select="request-param[@name='oneNetId']"/>
						<xsl:text> wurde erstellt.&#xA;TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
						<xsl:text> (</xsl:text>
						<xsl:value-of select="request-param[@name='clientName']"/>
						<xsl:text>)</xsl:text>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">create_one_net_site</xsl:element>
						<xsl:element name="field_name">one_net_id_created</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Contact for creation of new objects -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>		
					<xsl:element name="contact_type_rd">CREATE_ONB</xsl:element>
					<xsl:element name="short_description">SiteID erstellt</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>SiteID </xsl:text>
						<xsl:value-of select="request-param[@name='siteId']"/>
						<xsl:text> wurde erstellt.&#xA;TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
						<xsl:text> (</xsl:text>
						<xsl:value-of select="request-param[@name='clientName']"/>
						<xsl:text>)</xsl:text>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">create_one_net_site</xsl:element>
						<xsl:element name="field_name">site_created</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
						
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
