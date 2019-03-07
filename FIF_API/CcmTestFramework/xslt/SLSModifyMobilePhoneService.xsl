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
			<xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
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
				<xsl:if test="request-param[@name='DESIRED_DATE'] = ''">
					<xsl:value-of select="$today"/>
				</xsl:if>
				<xsl:if test="request-param[@name='DESIRED_DATE'] != ''">
					<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
				</xsl:if>				
			</xsl:variable>
			
			<!-- Find service -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_service_1</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="access_number">
						<xsl:value-of select="request-param[@name='ACCESS_NUMBER']"/>
					</xsl:element>
					<xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>										
			
			<!-- reconfigure service subscription -->
			<xsl:element name="CcmFifReconfigServiceCmd">
				<xsl:element name="command_id">reconf_service_1</xsl:element>
				<xsl:element name="CcmFifReconfigServiceInCont">
					<xsl:element name="service_subscription_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$desiredDate"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
					<xsl:element name="service_characteristic_list">
						<!-- SimID -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0108</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='NEW_SIM_ID']"/>
							</xsl:element>
						</xsl:element>
						<xsl:if test="request-param[@name='NEW_ARTICLE_NUMBER'] != ''">
							<!-- Artikelnummer -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0178</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='NEW_ARTICLE_NUMBER']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Customer Order for reconfiguration  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">
						<xsl:value-of select="request-param[@name='PROVIDER_TRACKING_NUMBER']"/>
					</xsl:element>
					<xsl:element name="super_customer_tracking_id">
						<xsl:value-of select="request-param[@name='SUPER_CUST_TRACKING_ID']"/>
					</xsl:element>
					<xsl:element name="scan_date">
						<xsl:value-of select="request-param[@name='SCAN_DATE']"/>
					</xsl:element>
					<xsl:element name="order_entry_date">
						<xsl:value-of select="request-param[@name='ENTRY_DATE']"/>
					</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">reconf_service_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Release Customer Order for Dual Mode Services -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_1</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Contact for Service Addition -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">CUSTOMER_ORDER</xsl:element>
					<xsl:element name="short_description">Mobilfunkdienst geändert</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>Mobilfunkdienst geändert mit </xsl:text>
						<xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
						<xsl:text>&#xA;TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
						<xsl:text>&#xA;Anschlusskennung: </xsl:text>
						<xsl:value-of select="request-param[@name='ACCESS_NUMBER']"/>
						<xsl:text>&#xA;Username: </xsl:text>
						<xsl:value-of select="request-param[@name='USER_NAME']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create external notification -->
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<xsl:element name="command_id">create_external_notification_1</xsl:element>
				<xsl:element name="CcmFifCreateExternalNotificationInCont">
					<xsl:element name="effective_date">
						<xsl:value-of select="$desiredDate"/>
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
							<xsl:element name="parameter_value">Kundenauftrag</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">USER_NAME</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='USER_NAME']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element>
							<xsl:element name="parameter_value">CCB</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">WORK_DATE</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="$today"/>
							</xsl:element>
						</xsl:element>					
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TEXT</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:text>Mobilfunkdienst geändert mit </xsl:text>
								<xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
								<xsl:text>&#xA;TransactionID: </xsl:text>
								<xsl:value-of select="request-param[@name='transactionID']"/>
								<xsl:text>&#xA;Anschlusskennung: </xsl:text>
								<xsl:value-of select="request-param[@name='ACCESS_NUMBER']"/>
								<xsl:text>&#xA;Username: </xsl:text>
								<xsl:value-of select="request-param[@name='USER_NAME']"/>
							</xsl:element>
						</xsl:element>					
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
