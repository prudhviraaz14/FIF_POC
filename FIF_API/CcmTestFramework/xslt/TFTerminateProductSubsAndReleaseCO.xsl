<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--
  XSLT file for creating a FIF request for terminating a product subscription and releasing customer order

  @author banania
-->
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
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
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
		</xsl:element>
		<xsl:element name="Command_List">
			<xsl:element name="CcmFifTerminateProductSubsCmd">
				<xsl:element name="command_id">terminate_product_subs_1</xsl:element>
				<xsl:element name="CcmFifTerminateProductSubsInCont">
					<xsl:element name="product_subscription_id">
						<xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">
						<xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
					</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='REASON_RD']"/>
					</xsl:element>
					<xsl:element name="auto_customer_order">
						<xsl:value-of select="request-param[@name='AUTO_CUSTOMER_ORDER']"/>
					</xsl:element>
					<xsl:element name="detailed_reason_rd">KKG</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Create Customer Order for Termination -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">002</xsl:element>
					<xsl:element name="service_ticket_pos_list_ref">
						<xsl:element name="command_id">terminate_product_subs_1</xsl:element>
						<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Release Customer Order for Termination -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">release_co_1</xsl:element>			
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
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
