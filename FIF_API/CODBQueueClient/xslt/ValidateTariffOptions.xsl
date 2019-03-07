<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for validating trariff options
	
	@author wlazlow
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0" xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
			
			<xsl:element name="CcmFifValidateTariffOptionsCmd">
				<xsl:element name="command_id">validate_tariff_options_1</xsl:element>
				<xsl:element name="CcmFifValidateTariffOptionsInCont">
			
					<xsl:if test="count(request-param-list[@name='tariffOptionsList']/request-param-list-item) != 0">
						<xsl:element name="tariff_options_list">
							<!-- Pass in the list of tariff_options -->
							<xsl:for-each select="request-param-list[@name='tariffOptionsList']/request-param-list-item">
								<xsl:element name="CcmFifPassingValueCont">
									<xsl:element name="service_code">
										<xsl:value-of select="request-param[@name='serviceCode']"/>										
									</xsl:element>
								</xsl:element>
							</xsl:for-each>
						</xsl:element>
					</xsl:if> 
				
					
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
