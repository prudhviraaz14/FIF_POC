<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a mobile phone contract 

  @author schwarje
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1" indent="yes" method="xml"/>
	<xsl:template match="/">
		<xsl:element name="CcmFifCommandList">
			<xsl:apply-templates select="request/request-params"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="request-params">
		
		<!-- Copy over transaction ID and action name -->
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

			<!-- use today as desired date if not provided -->
			<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
			<xsl:variable name="desiredDate">
				<xsl:value-of select="$today"/>
			</xsl:variable>
			<xsl:variable name="desiredDateOPM" select="dateutils:createOPMDate($desiredDate)"/>
			
			<xsl:if test="request-param[@name='CustomerNumber'] != ''">
				<!-- check for a service for this tariff for determining if an extra fee has to be paid -->
				<xsl:element name="CcmFifFindBundlesForCustomerCmd">
					<xsl:element name="command_id">find_bundle_for_cust</xsl:element>
					<xsl:element name="CcmFifFindBundlesForCustomerInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='CustomerNumber']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- create bundle, if none is found --> 
				<xsl:element name="CcmFifModifyBundleCmd">
					<xsl:element name="command_id">modify_bundle_1</xsl:element>
					<xsl:element name="CcmFifModifyBundleInCont">
						<xsl:element name="bundle_id_list_ref">
							<xsl:element name="command_id">find_bundle_for_cust</xsl:element>
							<xsl:element name="field_name">bundle_id_list</xsl:element>
						</xsl:element>
						<xsl:if test="request-param[@name='AoMastered'] = 'true'">
							<xsl:element name="ao_status">Y</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='AoMastered'] = 'false'">
							<xsl:element name="ao_status">N</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="request-param[@name='ServiceSubscriptionID'] != ''">
     			<!-- create bundle, if none is found --> 
				<xsl:element name="CcmFifModifyBundleCmd">
					<xsl:element name="command_id">modify_bundle_1</xsl:element>
					<xsl:element name="CcmFifModifyBundleInCont">
						<xsl:element name="service_subscription_id">
							<xsl:value-of select="request-param[@name='ServiceSubscriptionID']"/>
						</xsl:element>
						<xsl:if test="request-param[@name='AoMastered'] = 'true'">
							<xsl:element name="ao_status">Y</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='AoMastered'] = 'false'">
							<xsl:element name="ao_status">N</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="request-param[@name='BundleId'] != ''">
				<!-- create bundle, if none is found --> 
				<xsl:element name="CcmFifModifyBundleCmd">
					<xsl:element name="command_id">modify_bundle_1</xsl:element>
					<xsl:element name="CcmFifModifyBundleInCont">
						<xsl:element name="bundle_id">
							<xsl:value-of select="request-param[@name='BundleId']"/>
						</xsl:element>
						<xsl:if test="request-param[@name='AoMastered'] = 'true'">
							<xsl:element name="ao_status">Y</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='AoMastered'] = 'false'">
								<xsl:element name="ao_status">N</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
