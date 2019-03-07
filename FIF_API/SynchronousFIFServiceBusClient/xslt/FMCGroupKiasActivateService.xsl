<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for KIAS service bus transaction
  
  @author schwarje
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" exclude-result-prefixes="dateutils" version="1.0">
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
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
		<xsl:element name="package_name">
			<xsl:value-of select="request-param[@name='packageName']"/>
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
		</xsl:element>
		<xsl:element name="Command_List">
			<xsl:variable name="GroupId">
				<xsl:value-of select="request-param[@name='GroupId']"/>
			</xsl:variable>
			<xsl:variable name="GroupType">
				<xsl:value-of select="request-param[@name='GroupType']"/>
			</xsl:variable>
			<!-- Find Service Subscription by  service_subscription id -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_service_1</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="service_subscription_id">
						<xsl:value-of select="request-param[@name='ServiceSubscriptionId']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Find the DSL service to check, if there is a open customer order for ISDN-->
			<xsl:if test="request-param[@name='GroupType'] = 'MobileGroup'">
				<xsl:element name="CcmFifFindExclusiveChildServSubsCmd">
					<xsl:element name="command_id">find_mobil_service_1</xsl:element>
					<xsl:element name="CcmFifFindExclusiveChildServSubsInCont">
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code_list">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="service_code">V104B</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:for-each select="request-param-list[@name='MsisdnList;Msisdn']/request-param-list-item">
				<xsl:element name="CcmFifCreateDiscountGroupCmd">
					<xsl:element name="command_id">create_dg_1</xsl:element>
					<xsl:element name="CcmFifCreateDiscountGroupInCont">
						<xsl:element name="group_id"><xsl:value-of select="$GroupId"/></xsl:element>
						<xsl:element name="begin_number">
							<xsl:if test="starts-with(request-param[@name='MobileNumber'], 'GSM')">
								<xsl:text>49</xsl:text>
								<xsl:value-of select="substring-after(request-param[@name='MobileNumber'], 'GSM')"/>
							</xsl:if>
							<xsl:if test="not(starts-with(request-param[@name='MobileNumber'], 'GSM'))">
								<xsl:value-of select="request-param[@name='MobileNumber']"/>
							</xsl:if>
						</xsl:element>			
						<xsl:element name="discount_group_type_rd"><xsl:value-of select="$GroupType"/></xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
			<xsl:element name="CcmFifConfigurePPSCmd">
				<xsl:element name="command_id">update_pps_1</xsl:element>
				<xsl:element name="CcmFifConfigurePPSInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:if test="request-param[@name='GroupType'] = 'MobileGroup'">
						<xsl:element name="price_plan_code">V104B</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='GroupType'] = 'CorporateGroup'">
						<xsl:element name="price_plan_code">V0110</xsl:element>
					</xsl:if>
					<xsl:element name="group_id"><xsl:value-of select="$GroupId"/></xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact_1</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="contact_type_rd">INFO</xsl:element>
					<xsl:element name="short_description">TBD</xsl:element>
					<xsl:element name="long_description_text">TBD</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<xsl:element name="command_id">create_kba_notification_1</xsl:element>
				<xsl:element name="CcmFifCreateExternalNotificationInCont">
					<xsl:element name="effective_date">
						<xsl:value-of select="dateutils:getCurrentDate()"/>
					</xsl:element>
					<xsl:element name="notification_action_name">createKBANotification</xsl:element>
					<xsl:element name="target_system">KBA</xsl:element>
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">find_service_1</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
