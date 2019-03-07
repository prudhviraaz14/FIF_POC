<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
  XSLT file for modify Price Plan Subscription

  @author schwarje
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" exclude-result-prefixes="dateutils" version="1.0">
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
			
			<!-- Configure Price Plan -->
			<xsl:element name="CcmFifModifyPSMPricePlanCmd">
				<xsl:element name="command_id">modify_psm_pps_1</xsl:element>
				<xsl:element name="CcmFifModifyPSMPricePlanInCont">
					<xsl:element name="price_plan_subscription_id">
						<xsl:value-of select="request-param[@name='PRICE_PLAN_SUBSCRIPTION_ID']"/>
					</xsl:element>	
					<xsl:element name="account_number">
						<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
					</xsl:element>				
                    <xsl:element name="effective_date">
						<xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
					</xsl:element>					
					
				</xsl:element>
			</xsl:element>
			
			<xsl:if test="request-param[@name='CREATE_CONTACT'] = 'Y'">
				<!-- Create Contact -->
				<xsl:element name="CcmFifCreateContactCmd">
					<xsl:element name="CcmFifCreateContactInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
						</xsl:element>
						<xsl:element name="contact_type_rd">
							<xsl:value-of select="request-param[@name='CONTACT_TYPE_RD']"/>
						</xsl:element>
						<xsl:element name="short_description">
							<xsl:value-of select="request-param[@name='SHORT_DESCRIPTION']"/>
						</xsl:element>
						<xsl:element name="long_description_text">
							<xsl:value-of select="request-param[@name='LONG_DESCRIPTION_TEXT']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				<!-- Create KBA notification  -->
				<xsl:element name="CcmFifCreateExternalNotificationCmd">
					<!-- Get today's date -->
					<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
					<xsl:element name="command_id">create_kba_notification_1</xsl:element>
					<xsl:element name="CcmFifCreateExternalNotificationInCont">
						<xsl:element name="effective_date">
							<xsl:if test="request-param[@name='EFFECTIVE_DATE'] != ''">
								<xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
							</xsl:if>
							<xsl:if test="request-param[@name='START_DATE'] = ''">
								<xsl:value-of select="$today"/>
							</xsl:if>
						</xsl:element>
						<xsl:element name="notification_action_name">createKBANotification</xsl:element>
						<xsl:element name="target_system">KBA</xsl:element>
						<xsl:element name="parameter_value_list">
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
								<xsl:element name="parameter_value">
									<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">TYPE</xsl:element>
								<xsl:element name="parameter_value">CONTACT</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">CATEGORY</xsl:element>
								<xsl:element name="parameter_value">SelectedDestination</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">USER_NAME</xsl:element>
								<xsl:element name="parameter_value">SLS-Clearing</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">WORK_DATE</xsl:element>
								<xsl:element name="parameter_value">
									<xsl:if test="request-param[@name='EFFECTIVE_DATE'] != ''">
										<xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
									</xsl:if>
									<xsl:if test="request-param[@name='EFFECTIVE_DATE'] = ''">
										<xsl:value-of select="$today"/>
									</xsl:if>
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">TEXT</xsl:element>
								<xsl:element name="parameter_value">
									<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
									<xsl:value-of select="request-param[@name='LONG_DESCRIPTION_TEXT']" disable-output-escaping="yes"/>
									<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
