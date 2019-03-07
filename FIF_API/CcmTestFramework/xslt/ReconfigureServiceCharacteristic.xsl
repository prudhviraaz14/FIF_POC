<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for modifying access information

  @author iarizova
-->
<!DOCTYPE XSL [

<!ENTITY GenericServiceCharacteristicList SYSTEM "GenericServiceCharacteristicList.xsl">
<!ENTITY GenericCreateAddress SYSTEM "GenericCreateAddress.xsl">
]>
<xsl:stylesheet 
    exclude-result-prefixes="dateutils" 
    version="1.0"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1"
		indent="yes" method="xml"/>
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
			<xsl:if test="count(request-param-list[@name='CONF_SERVICE_CHAR_LIST']/request-param-list-item) != 0
	        			and request-param[@name='SERVICE_CHAR_CODE'] != ''">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">onlyUseListsOrSimpleParameters</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">Bitte CONF_SERVICE_CHAR_LIST ODER einfache Parameter nutzen, nicht beide.</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="request-param[@name='ACTIVATE_SERVICE'] = 'Y' and
	        			request-param[@name='DESIRED_DATE'] != ''">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">noDesiredDateForAutomaticActivation</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">Dienste werden bei ACTIVATE_SERVICE = Y automatisch am gleichen Tag aktiviert. In diesem Fall bitte kein DESIRED_DATE setzen.</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
			<xsl:variable name="desiredDate">
				<xsl:choose>
					<xsl:when test ="request-param[@name='DESIRED_DATE'] = '' or
						request-param[@name='DESIRED_DATE'] = 'today' or
						request-param[@name='ACTIVATE_SERVICE'] = 'Y'">
						<xsl:value-of select="$today"/>
					</xsl:when>
					<xsl:when test ="dateutils:compareString(request-param[@name='DESIRED_DATE'], $today) = '-1'">
						<xsl:value-of select="$today"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="desiredScheduleType">
				<xsl:choose>
					<xsl:when test ="dateutils:compareString($desiredDate, $today) = '0'">ASAP</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<!-- Find Service Subscription by service_subscription id  -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="service_subscription_id">
						<xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- lock product to avoid concurrency problems -->
			<xsl:element name="CcmFifLockObjectCmd">
				<xsl:element name="CcmFifLockObjectInCont">
					<xsl:element name="object_id_ref">
						<xsl:element name="command_id">find_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="object_type">PROD_SUBS</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifGetEntityCmd">
				<xsl:element name="command_id">get_entity</xsl:element>
				<xsl:element name="CcmFifGetEntityInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:choose>
				<xsl:when test="count(request-param-list[@name='CONF_SERVICE_CHAR_LIST']/request-param-list-item) != 0">
					<xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST']/request-param-list-item">
						&GenericCreateAddress;
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					&GenericCreateAddress;
				</xsl:otherwise>
			</xsl:choose>
			<!-- reconfigure service subscription -->
			<xsl:element name="CcmFifReconfigServiceCmd">
				<xsl:element name="command_id">reconfigure_service</xsl:element>
				<xsl:element name="CcmFifReconfigServiceInCont">
					<xsl:element name="service_subscription_id">
						<xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$desiredDate"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">
						<xsl:value-of select="$desiredScheduleType"/>
					</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='REASON_RD']"/>
					</xsl:element>
					<xsl:element name="service_characteristic_list">
						<xsl:choose>
							<xsl:when test="count(request-param-list[@name='CONF_SERVICE_CHAR_LIST']/request-param-list-item) != 0">
								<xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST']/request-param-list-item">
									&GenericServiceCharacteristicList;
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								&GenericServiceCharacteristicList;
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:element name="allow_stp_modification">
						<xsl:value-of select="request-param[@name='ALLOW_STP_MODIFICATION']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- create customer order  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_customer_order_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">
						<xsl:value-of select="request-param[@name='PROVIDER_TRACKING_NUMBER']"/>
					</xsl:element>
					<xsl:if test="request-param[@name='ALLOW_STP_MODIFICATION'] = 'Y' and 
					request-param[@name='ACTIVATE_CUSTOMER_ORDER'] = 'Y'">
						<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
					</xsl:if>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">reconfigure_service</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:choose>
						<xsl:when test="request-param[@name='ACTIVATE_CUSTOMER_ORDER'] = 'Y'">
							<xsl:element name="processing_status">completedOPM</xsl:element>
						</xsl:when>
						<xsl:when test="request-param[@name='ACTIVATE_SERVICE'] = 'Y'">
							<xsl:element name="processing_status">completedOPM</xsl:element>
						</xsl:when>
					</xsl:choose>
				</xsl:element>
			</xsl:element>
			<xsl:if test="request-param[@name='RELEASE_CUSTOMER_ORDER'] = 'Y'">
				<!-- release customer order -->
				<xsl:element name="CcmFifReleaseCustOrderCmd">
					<xsl:element name="command_id">release_customer_order_1</xsl:element>
					<xsl:element name="CcmFifReleaseCustOrderInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="customer_order_ref">
							<xsl:element name="command_id">create_customer_order_1</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>
						</xsl:element>
						<xsl:if test="request-param[@name='ALLOW_STP_MODIFICATION'] = 'Y' and 
										request-param[@name='ACTIVATE_CUSTOMER_ORDER'] = 'Y'">
							<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!--  Create  external notification if the requestListId is set  -->
			<xsl:if test="request-param[@name='CUST_ORDER_REF_ID'] != ''
		        and request-param[@name='requestListId'] != ''">
				<xsl:element name="CcmFifCreateExternalNotificationCmd">
					<xsl:element name="command_id">create_notification_1</xsl:element>
					<xsl:element name="CcmFifCreateExternalNotificationInCont">
						<xsl:element name="effective_date">
							<xsl:value-of select="$desiredDate"/>
						</xsl:element>
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="processed_indicator">Y</xsl:element>
						<xsl:element name="notification_action_name">ReconfigureServiceCharacteristic</xsl:element>
						<xsl:element name="target_system">FIF</xsl:element>
						<xsl:element name="parameter_value_list">
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">
									<xsl:value-of select="concat(request-param[@name='CUST_ORDER_REF_ID'], '_CUSTOMER_ORDER_ID')"/>
								</xsl:element>
								<xsl:element name="parameter_value_ref">
									<xsl:element name="command_id">create_customer_order_1</xsl:element>
									<xsl:element name="field_name">customer_order_id</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Create Contact -->
			<xsl:if test="request-param[@name='CREATE_CONTACT'] != 'N'">
				<xsl:element name="CcmFifCreateContactCmd">
					<xsl:element name="command_id">create_contact</xsl:element>
					<xsl:element name="CcmFifCreateContactInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="contact_type_rd">
							<xsl:choose>
								<xsl:when test="request-param[@name='CONTACT_TYPE_RD'] != ''">
									<xsl:value-of select="request-param[@name='CONTACT_TYPE_RD']"/>
								</xsl:when>
								<xsl:otherwise>RECONF_FUNCTION</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="short_description">
							<xsl:choose>
								<xsl:when test="request-param[@name='SHORT_DESCRIPTION'] != ''">
									<xsl:value-of select="request-param[@name='SHORT_DESCRIPTION']"/>
								</xsl:when>
								<xsl:otherwise>Dienst umkonfiguriert</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="description_text_list">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="contact_text">
									<xsl:if test="request-param[@name='LONG_DESCRIPTION_TEXT'] != ''">
										<xsl:value-of select="request-param[@name='LONG_DESCRIPTION_TEXT']"/>
										<xsl:text>&#xA;</xsl:text>
									</xsl:if>
									<xsl:text>Dienstenutzung </xsl:text>
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">find_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="contact_text">
									<xsl:text> wurde mit Dienstekonfiguration </xsl:text>
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">reconfigure_service</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="contact_text">
									<xsl:text> geändert.&#xA;TransactionID: </xsl:text>
									<xsl:value-of select="request-param[@name='transactionID']"/>
									<xsl:text> (</xsl:text>
									<xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
									<xsl:text>)</xsl:text>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
