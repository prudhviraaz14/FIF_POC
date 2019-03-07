<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for modifying a bundle
  
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
		<xsl:element name="transaction_id">
			<xsl:value-of select="request-param[@name='transactionID']"/>
		</xsl:element>
		<xsl:element name="client_name">SLS</xsl:element>
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
		</xsl:element>
		<xsl:element name="Command_List">
			<xsl:variable name="hierarchyIndicator" select="request-param[@name='HIERARCHY_INDICATOR']"/>
			<xsl:choose>
				<xsl:when test="request-param[@name='BUNDLE_ID'] != '' or
	        count(request-param-list[@name='BUNDLE_ITEM_LIST']/request-param-list-item[request-param[@name='BUNDLE_ITEM_ID'] != '']) = 0">
					<!-- Modify Bundle, state is not modified because it might change in ModifyBundleItem -->
					<xsl:element name="CcmFifModifyBundleCmd">
						<xsl:element name="command_id">modify_bundle_1</xsl:element>
						<xsl:element name="CcmFifModifyBundleInCont">
							<xsl:element name="bundle_id">
								<xsl:value-of select="request-param[@name='BUNDLE_ID']"/>
							</xsl:element>
							<xsl:element name="effective_date">
								<xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
							</xsl:element>
							<xsl:element name="customer_number">
								<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
							</xsl:element>
							<xsl:element name="ao_status">
								<xsl:value-of select="request-param[@name='AO_STATUS']"/>
							</xsl:element>
							<xsl:element name="terminate_empty_ind">
								<xsl:value-of select="request-param[@name='TERMINATE_EMPTY']"/>
							</xsl:element>
							<xsl:element name="hierarchy_ind">
								<xsl:value-of select="$hierarchyIndicator"/>
							</xsl:element>
							<xsl:element name="bundle_role_rd">
								<xsl:value-of select="request-param[@name='BUNDLE_ROLE_RD']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="CcmFifRaiseErrorCmd">
						<xsl:element name="command_id">bundleIDProvided</xsl:element>
						<xsl:element name="CcmFifRaiseErrorInCont">
							<xsl:element name="error_text">BUNDLE_ID muss gesetzt sein, falls kein Bundle erstellt werden soll.</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:variable name="effectiveDate" select="request-param[@name='EFFECTIVE_DATE']" />
			<xsl:for-each select="request-param-list[@name='BUNDLE_ITEM_LIST']/request-param-list-item">
				<!-- get service by serv subs id -->
				<xsl:if test="$hierarchyIndicator = 'Y' and request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] = 'SERVSUB'">
					<xsl:element name="CcmFifFindServiceSubsCmd">
						<xsl:element name="command_id">find_source_service</xsl:element>
						<xsl:element name="CcmFifFindServiceSubsInCont">
							<xsl:element name="service_subscription_id">
								<xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
							</xsl:element>
							<xsl:element name="no_service_error">Y</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
				<!-- Modify Bundle Item -->
				<xsl:element name="CcmFifModifyBundleItemCmd">
					<xsl:element name="CcmFifModifyBundleItemInCont">
						<xsl:element name="bundle_item_id">
							<xsl:value-of select="request-param[@name='BUNDLE_ITEM_ID']"/>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="$effectiveDate"/>
						</xsl:element>
						<xsl:element name="bundle_id_ref">
							<xsl:element name="command_id">modify_bundle_1</xsl:element>
							<xsl:element name="field_name">bundle_id</xsl:element>
						</xsl:element>
						<xsl:element name="bundle_item_type_rd">
							<xsl:value-of select="request-param[@name='BUNDLE_ITEM_TYPE_RD']"/>
						</xsl:element>
						<xsl:element name="supported_object_id">
							<xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_ID']"/>
						</xsl:element>
						<xsl:element name="supported_object_type_rd">
							<xsl:value-of select="request-param[@name='SUPPORTED_OBJECT_TYPE_RD']"/>
						</xsl:element>
						<xsl:element name="action_name">
							<xsl:value-of select="request-param[@name='ACTION_NAME']"/>
						</xsl:element>
						<xsl:element name="future_indicator">
							<xsl:value-of select="request-param[@name='FUTURE_INDICATOR']"/>
						</xsl:element>
						<xsl:if test="$hierarchyIndicator = 'Y' and request-param[@name='SUPPORTED_OBJECT_TYPE_RD'] = 'SERVSUB'">
							<xsl:element name="deviating_customer_number_ref">
								<xsl:element name="command_id">find_source_service</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
