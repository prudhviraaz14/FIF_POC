<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--
  XSLT file for creating a FIF request for creating a Customer Message

  @author banania
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
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
		</xsl:element>
		<xsl:element name="Command_List">
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_customer_order_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of
							select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="parent_customer_order_id">
						<xsl:value-of
							select="request-param[@name='PARENT_CUSTOMER_ORDER_ID']"
						/>
					</xsl:element>
					<xsl:element name="created_by_name">
						<xsl:value-of
							select="request-param[@name='CREATED_BY_NAME']"/>
					</xsl:element>
					<xsl:element name="created_by_phone_no">
						<xsl:value-of
							select="request-param[@name='CREATED_BY_PHONE_NO']"
						/>
					</xsl:element>
					<xsl:element name="created_by_department">
						<xsl:value-of
							select="request-param[@name='CREATED_BY_DEPARTMENT']"
						/>
					</xsl:element>
					<xsl:element name="bill_activation_indicator">
						<xsl:value-of
							select="request-param[@name='BILL_ACTIVATION_INDICATOR']"
						/>
					</xsl:element>
					<xsl:element name="priority_rd">
						<xsl:value-of
							select="request-param[@name='PRIORITY_RD']"/>
					</xsl:element>
					<xsl:element name="reserv_order_indicator">
						<xsl:value-of
							select="request-param[@name='RESERV_ORDER_INDICATOR']"
						/>
					</xsl:element>
					<xsl:element name="cust_order_description">
						<xsl:value-of
							select="request-param[@name='CUST_ORDER_DESCRIPTION']"
						/>
					</xsl:element>
					<xsl:element name="mailing_id">
						<xsl:value-of select="request-param[@name='MAILING_ID']"
						/>
					</xsl:element>
					<xsl:element name="region_rd">
						<xsl:value-of select="request-param[@name='REGION_RD']"
						/>
					</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of
							select="request-param[@name='CUSTOMER_TRACKING_ID']"
						/>
					</xsl:element>
					<xsl:element name="sales_organization_id">
						<xsl:value-of
							select="request-param[@name='SALES_ORGANIZATION_ID']"
						/>
					</xsl:element>
					<xsl:element name="confirm_output_device">
						<xsl:value-of
							select="request-param[@name='CONFIRM_OUTPUT_DEVICE']"
						/>
					</xsl:element>
					<xsl:element name="confirmation_date">
						<xsl:value-of
							select="request-param[@name='CONFIRMATION_DATE']"/>
					</xsl:element>
					<xsl:element name="confirmation_subject">
						<xsl:value-of
							select="request-param[@name='CONFIRMATION_SUBJECT']"
						/>
					</xsl:element>
					<xsl:element name="doc_template_name">
						<xsl:value-of
							select="request-param[@name='DOC_TEMPLATE_NAME']"/>
					</xsl:element>
					<xsl:element name="lan_path_file_string">
						<xsl:value-of
							select="request-param[@name='LAN_PATH_FILE_STRING']"
						/>
					</xsl:element>
					<xsl:element name="language_rd">
						<xsl:value-of
							select="request-param[@name='LANGUAGE_RD']"/>
					</xsl:element>
					<xsl:element name="sales_rep_name">
						<xsl:value-of
							select="request-param[@name='SALES_REP_NAME']"/>
					</xsl:element>
					<xsl:element name="sales_rep_dept">
						<xsl:value-of
							select="request-param[@name='SALES_REP_DEPT']"/>
					</xsl:element>
					<xsl:element name="sales_rep_phone_no">
						<xsl:value-of
							select="request-param[@name='SALES_REP_PHONE_NO']"/>
					</xsl:element>
					<xsl:element name="consultant_name">
						<xsl:value-of
							select="request-param[@name='CONSULTANT_NAME']"/>
					</xsl:element>
					<xsl:element name="consultant_department">
						<xsl:value-of
							select="request-param[@name='CONSULTANT_DEPARTMENT']"
						/>
					</xsl:element>
					<xsl:element name="consultant_phone_no">
						<xsl:value-of
							select="request-param[@name='CONSULTANT_PHONE_NO']"
						/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">
						<xsl:value-of
							select="request-param[@name='PROVIDER_TRACKING_NO']"
						/>
					</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:for-each
							select="request-param-list[@name='SERVICE_TICKET_POS_LIST']/request-param-list-item">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="service_ticket_pos_id">
									<xsl:value-of
										select="request-param[@name='SERVICE_TICKET_POS_ID']"
									/>
								</xsl:element>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
