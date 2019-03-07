<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  exclude-result-prefixes="dateutils">
	<!--
  XSLT file for creating a FIF request for sending a SOM to COM
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
			<xsl:variable name="somTemplate">
				<xsl:choose>
					<xsl:when test="request-param[@name='somTemplateID'] != ''">
						<xsl:value-of select="dateutils:getSomTemplate(request-param[@name='somTemplateID'])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='somTemplate']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$somTemplate = ''">
					<xsl:element name="CcmFifRaiseErrorCmd">
						<xsl:element name="command_id">missingSomTemplate</xsl:element>
						<xsl:element name="CcmFifRaiseErrorInCont">
							<xsl:element name="error_text">SOM-Template is empty. Either a valid somTemplateID or somTemplate has to be provided.</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:when>
				<xsl:when test="not(contains($somTemplate, '${orderID}'))
							or not(contains($somTemplate, '${somVersion}'))">
					<xsl:element name="CcmFifRaiseErrorCmd">
						<xsl:element name="command_id">missingPlaceholders</xsl:element>
						<xsl:element name="CcmFifRaiseErrorInCont">
							<xsl:element name="error_text">Placeholders for orderID and somVersion have to be provided in somTemplate</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="replaceID">
						<xsl:value-of select="dateutils:initReplace($somTemplate, request-param[@name='transactionID'])"/>
					</xsl:variable>
					<!-- replace SOM version -->
					<xsl:value-of select="dateutils:replace($replaceID, '\$\{somVersion\}', request-param[@name='somVersion'])"/>
					<!-- insert sub templates -->
					<xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
						<xsl:variable name="searchPattern">
							<xsl:text>\$\{</xsl:text>
							<xsl:value-of select="request-param[@name='parameterName']"/>
							<xsl:text>\}</xsl:text>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="starts-with(request-param[@name='parameterValue'], 'subtemplate:')">
								<xsl:value-of select="dateutils:replace($replaceID, $searchPattern, dateutils:getSomSubTemplate(substring-after(request-param[@name='parameterValue'], 'subtemplate:')))"/>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
					<!-- replace parameters -->
					<xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
						<xsl:variable name="searchPattern">
							<xsl:text>\$\{</xsl:text>
							<xsl:value-of select="request-param[@name='parameterName']"/>
							<xsl:text>\}</xsl:text>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="
									starts-with(request-param[@name='parameterValue'], 'datetime:') or
									starts-with(request-param[@name='parameterValue'], 'date:')">
								<xsl:value-of select="dateutils:replace($replaceID, $searchPattern, dateutils:createSOMDate(request-param[@name='parameterValue']))"/>
							</xsl:when>
							<xsl:when test="
									contains($searchPattern, 'name') or
									contains($searchPattern, 'Name') or
									contains($searchPattern, 'owner') or
									contains($searchPattern, 'remark')">
								<xsl:variable name="valueCDATA">
									<xsl:text>&lt;![CDATA[</xsl:text>
									<xsl:value-of select="request-param[@name='parameterValue']"/>
									<xsl:text>]]&gt;</xsl:text>
								</xsl:variable>
								<xsl:value-of select="dateutils:replace($replaceID, $searchPattern, $valueCDATA)"/>
							</xsl:when>
							<xsl:when test="starts-with(request-param[@name='parameterValue'], 'subtemplate:')"/>
							<xsl:otherwise>
								<xsl:value-of select="dateutils:replace($replaceID, $searchPattern, request-param[@name='parameterValue'])"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
					<!-- replace current date -->
					<xsl:value-of select="dateutils:replace($replaceID, '\$\{currentDateTime\}', dateutils:createSOMDate(dateutils:getCurrentDate(false)))"/>

   				<xsl:if test="not (contains(dateutils:getReplacedString($replaceID),'${barcode}'))">
						<xsl:if test="contains(substring-after(dateutils:getReplacedString($replaceID), '${orderID}'), '${')">
							<xsl:element name="CcmFifRaiseErrorCmd">
								<xsl:element name="command_id">openPlaceholders</xsl:element>
								<xsl:element name="CcmFifRaiseErrorInCont">
									<xsl:element name="error_text">Not all placeholders in somTemplate have been replaced. Note: orderID, somVersion and currentDateTime are automatically replaced.</xsl:element>
									<xsl:comment>
										<xsl:value-of select="dateutils:getReplacedString($replaceID)"/>
									</xsl:comment>
								</xsl:element>
							</xsl:element>
						</xsl:if>
					   <xsl:element name="CcmFifGenerateCustomerOrderBarcodeCmd">
						   <xsl:element name="command_id">getOrderID</xsl:element>
						   <xsl:element name="CcmFifGenerateCustomerOrderBarcodeInCont"/>
                  </xsl:element>
						<xsl:element name="CcmFifConcatStringsCmd">
							<xsl:element name="command_id">concatSOM</xsl:element>
							<xsl:element name="CcmFifConcatStringsInCont">
								<xsl:element name="input_string_list">
									<xsl:element name="CcmFifPassingValueCont">
										<xsl:element name="value">
											<xsl:value-of select="substring-before(dateutils:getReplacedString($replaceID), '${orderID}')"/>
										</xsl:element>
									</xsl:element>
									<xsl:element name="CcmFifCommandRefCont">
										<xsl:element name="command_id">getOrderID</xsl:element>
										<xsl:element name="field_name">customer_tracking_id</xsl:element>
									</xsl:element>
									<xsl:element name="CcmFifPassingValueCont">
										<xsl:element name="value">
											<xsl:value-of select="substring-after(dateutils:getReplacedString($replaceID), '${orderID}')"/>
										</xsl:element>
									</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
               </xsl:if>
   				<xsl:if test="contains(dateutils:getReplacedString($replaceID),'${barcode}')">
						<xsl:if test="contains(substring-after(dateutils:getReplacedString($replaceID), '${barcode}'), '${')">
							<xsl:element name="CcmFifRaiseErrorCmd">
								<xsl:element name="command_id">openPlaceholders</xsl:element>
								<xsl:element name="CcmFifRaiseErrorInCont">
									<xsl:element name="error_text">Not all placeholders in somTemplate have been replaced. Note: orderID, barcode, somVersion and currentDateTime are automatically replaced.</xsl:element>
									<xsl:comment>
										<xsl:value-of select="dateutils:getReplacedString($replaceID)"/>
									</xsl:comment>
								</xsl:element>
							</xsl:element>
						</xsl:if>
					   <xsl:element name="CcmFifGenerateCustomerOrderBarcodeCmd">
						   <xsl:element name="command_id">getOrderID</xsl:element>
						   <xsl:element name="CcmFifGenerateCustomerOrderBarcodeInCont"/>
                  </xsl:element>
						<xsl:element name="CcmFifConcatStringsCmd">
							<xsl:element name="command_id">concatSOM</xsl:element>
							<xsl:element name="CcmFifConcatStringsInCont">
								<xsl:element name="input_string_list">
									<xsl:element name="CcmFifPassingValueCont">
										<xsl:element name="value">
											<xsl:value-of select="substring-before(dateutils:getReplacedString($replaceID), '${orderID}')"/>
										</xsl:element>
									</xsl:element>
									<xsl:element name="CcmFifCommandRefCont">
										<xsl:element name="command_id">getOrderID</xsl:element>
										<xsl:element name="field_name">customer_tracking_id</xsl:element>
									</xsl:element>
									<xsl:element name="CcmFifPassingValueCont">
										<xsl:element name="value">
											<xsl:value-of select="substring-before(substring-after(dateutils:getReplacedString($replaceID), '${orderID}'),'${barcode}')"/>
										</xsl:element>
									</xsl:element>
									<xsl:element name="CcmFifCommandRefCont">
										<xsl:element name="command_id">getOrderID</xsl:element>
										<xsl:element name="field_name">customer_tracking_id</xsl:element>
									</xsl:element>
									<xsl:element name="CcmFifPassingValueCont">
										<xsl:element name="value">
											<xsl:value-of select="substring-after(dateutils:getReplacedString($replaceID), '${barcode}')"/>
										</xsl:element>
									</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
               </xsl:if>
					<xsl:element name="CcmFifProcessServiceBusRequestCmd">
						<xsl:element name="command_id">sendSOM</xsl:element>
						<xsl:element name="CcmFifProcessServiceBusRequestInCont">
							<xsl:element name="package_name">net.arcor.com.epsm_com_001</xsl:element>
							<xsl:element name="service_name">StartPreclearedFixedLineOrder</xsl:element>
							<xsl:element name="synch_ind">N</xsl:element>
							<xsl:element name="external_system_id_ref">
								<xsl:element name="command_id">getOrderID</xsl:element>
								<xsl:element name="field_name">customer_tracking_id</xsl:element>
							</xsl:element>
							<xsl:element name="parameter_value_list">
								<xsl:element name="CcmFifParameterValueCont">
									<xsl:element name="parameter_name">Barcode</xsl:element>
									<xsl:element name="parameter_value_ref">
										<xsl:element name="command_id">getOrderID</xsl:element>
										<xsl:element name="field_name">customer_tracking_id</xsl:element>
									</xsl:element>
								</xsl:element>
								<xsl:element name="CcmFifParameterValueCont">
									<xsl:element name="parameter_name">SendingSystem</xsl:element>
									<xsl:element name="parameter_value">CCM</xsl:element>
								</xsl:element>
								<xsl:element name="CcmFifParameterValueCont">
									<xsl:element name="parameter_name">SomString</xsl:element>
									<xsl:element name="parameter_value_ref">
										<xsl:element name="command_id">concatSOM</xsl:element>
										<xsl:element name="field_name">output_string</xsl:element>
									</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					<!-- cleanup -->
					<xsl:value-of select="dateutils:endReplace($replaceID)"/>
				</xsl:otherwise>
			</xsl:choose>
		<xsl:if test="request-param[@name='customerNumber'] !=''">
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact_1</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">SOM_MASS_IMPORT</xsl:element>
					<xsl:element name="short_description">SOM-Massenimport</xsl:element>
					<xsl:element name="description_text_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>&#xA;SOM-Auftrag: </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">getOrderID</xsl:element>
							<xsl:element name="field_name">customer_tracking_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>;&#xA;für: </xsl:text>
								<xsl:value-of select="request-param[@name='orderDescription']"/>
								<xsl:text>;&#xA;wurde erstellt und an COM gesendet.</xsl:text>
								<xsl:text> &#xA;Betroffenes Bündel: </xsl:text>
								<xsl:value-of select="request-param[@name='bundleID']"/>
								<xsl:text>;&#xA;TransactionID: </xsl:text>
								<xsl:value-of select="request-param[@name='transactionID']"/>
								<xsl:text>;&#xA; </xsl:text>
								<xsl:value-of select="request-param[@name='clientName']"/>
								<xsl:text>;&#xA; </xsl:text>
								<xsl:value-of select="request-param[@name='csvImportInfo']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
