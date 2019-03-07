<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--
  XSLT file for creating a FIF request for sending a messag eto the bus

  @author schwarje
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
			<xsl:element name="CcmFifProcessServiceBusRequestCmd">
				<xsl:element name="command_id">call_aip</xsl:element>
				<xsl:element name="CcmFifProcessServiceBusRequestInCont">
					<xsl:element name="package_name">
						<xsl:value-of select="request-param[@name='packageName']"/>
					</xsl:element>
					<xsl:element name="service_name">
						<xsl:value-of select="request-param[@name='serviceName']"/>
					</xsl:element>
					<xsl:element name="synch_ind">
						<xsl:value-of select="request-param[@name='synchronousIndicator']"/>
					</xsl:element>
					<xsl:element name="xsd_file">
						<xsl:value-of select="request-param[@name='xsdFile']"/>
					</xsl:element>
					<xsl:element name="operation_name">
						<xsl:value-of select="request-param[@name='operationName']"/>
					</xsl:element>
					<xsl:element name="external_system_id">
						<xsl:value-of select="request-param[@name='externalSystemId']"/>
					</xsl:element>
					<xsl:element name="priority">
						<xsl:value-of select="request-param[@name='priority']"/>
					</xsl:element>
					
					<xsl:element name="parameter_value_list">
						<xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">
									<xsl:value-of select="request-param[@name='parameterName']"/>
								</xsl:element>
								<xsl:element name="parameter_value">
									<xsl:value-of select="request-param[@name='parameterValue']"/>
								</xsl:element>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
