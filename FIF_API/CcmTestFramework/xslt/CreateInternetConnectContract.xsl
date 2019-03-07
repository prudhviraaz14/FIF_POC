<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for creating a FIF request for a Internet Connect contract.

	@author banania
-->
<!DOCTYPE XSL [

<!ENTITY CreateBasicContractData SYSTEM "CreateBasicContractData.xsl">
<!ENTITY CreateServiceSubsForBusinessCust SYSTEM "CreateServiceSubsForBusinessCust.xsl">
<!ENTITY CreateAndFetchBasicData SYSTEM "CreateAndFetchBasicData.xsl">
]>


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

		<xsl:variable name="contractName">Internet Connect</xsl:variable>

		&CreateAndFetchBasicData;
		&CreateBasicContractData;
		&CreateServiceSubsForBusinessCust;

		<!-- Create contact  for Service Addition -->
	    <xsl:if test="request-param[@name='productCommitmentNumber']=''">
		<xsl:element name="CcmFifCreateContactCmd">
			<xsl:element name="command_id">create_contact_1</xsl:element>
			<xsl:element name="CcmFifCreateContactInCont">
				<xsl:if test="request-param[@name='customerNumber']=''">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">read_cust_num_from_ext_noti</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:if test="request-param[@name='customerNumber']!=''">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
				</xsl:if>
				<xsl:element name="contact_type_rd">CREATE_INT_CONN</xsl:element>
				<xsl:element name="short_description">
					<xsl:text>Anlage Int. Connect Vertrag.</xsl:text>
				</xsl:element>
				<xsl:element name="long_description_text">
					<xsl:text>TransactionID: </xsl:text>
					<xsl:value-of select="request-param[@name='transactionID']"/>
					<xsl:text>&#xA;Internet Connect Contract has been created on:</xsl:text>
					<xsl:value-of select="request-param[@name='desiredDate']"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	    </xsl:if>

        <!-- Create contact  for Service Addition -->
	    <xsl:if test="request-param[@name='productCommitmentNumber']!=''">
		<xsl:element name="CcmFifCreateContactCmd">
			<xsl:element name="command_id">create_contact_1_ps</xsl:element>
			<xsl:element name="CcmFifCreateContactInCont">
				<xsl:if test="request-param[@name='customerNumber']=''">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">read_cust_num_from_ext_noti</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:if test="request-param[@name='customerNumber']!=''">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
				</xsl:if>
				<xsl:element name="contact_type_rd">CREATE_INT_CONN</xsl:element>
				<xsl:element name="short_description">
					<xsl:text>Anlage Int. Connect PS.</xsl:text>
				</xsl:element>
				<xsl:element name="long_description_text">
					<xsl:text>TransactionID: </xsl:text>
					<xsl:value-of select="request-param[@name='transactionID']"/>
					<xsl:text>&#xA;Internet Connect Product subscription has been added on:</xsl:text>
					<xsl:value-of select="request-param[@name='desiredDate']"/>
					<xsl:text>&#xA;Username:</xsl:text>
					<xsl:value-of select="request-param[@name='userName']"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
		</xsl:if>

		<!--  Create  external notification if the requestListId is set  -->
		<xsl:if test="request-param[@name='requestListId'] != ''">
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<xsl:element name="command_id">create_notification_1</xsl:element>
				<xsl:element name="CcmFifCreateExternalNotificationInCont">
					<xsl:element name="effective_date">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="processed_indicator">Y</xsl:element>
					<xsl:element name="notification_action_name">CreateInternetConnectContract</xsl:element>
					<xsl:element name="target_system">FIF</xsl:element>
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">INT_CONNECT_SERVICE_SUBSCRIPTION_ID</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">add_service_subs</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">PRODUCT_SUBSCRIPTION_ID</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">add_product_subscription_1</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CUSTOMER_ORDER_ID</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">create_co_1</xsl:element>
								<xsl:element name="field_name">customer_order_id</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>

	</xsl:element>

	</xsl:template>
</xsl:stylesheet>
