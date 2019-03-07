<!-- Add Main Service Subscription  -->
<xsl:element name="CcmFifAddServiceSubsCmd">
	<xsl:element name="command_id">add_service_subs</xsl:element>
	<xsl:element name="CcmFifAddServiceSubsInCont">
		<xsl:element name="product_subscription_ref">
			<xsl:element name="command_id">add_product_subscription_1</xsl:element>
			<xsl:element name="field_name">product_subscription_id</xsl:element>
		</xsl:element>
		<xsl:element name="service_code">
			<xsl:value-of select="request-param[@name='serviceCode']"/>
		</xsl:element>
		<xsl:element name="desired_date">
			<xsl:value-of select="$desireDate"/>
		</xsl:element>
		<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
		<xsl:element name="reason_rd">
			<xsl:value-of select="request-param[@name='reasonRd']"/>
		</xsl:element>
		<xsl:if test="request-param[@name='accountNumber']=''">
			<xsl:element name="account_number_ref">
				<xsl:element name="command_id">read_account_num_from_ext_noti</xsl:element>
				<xsl:element name="field_name">parameter_value</xsl:element>
			</xsl:element>
		</xsl:if>
		<xsl:if test="request-param[@name='accountNumber']!=''">
			<xsl:element name="account_number">
				<xsl:value-of select="request-param[@name='accountNumber']"/>
			</xsl:element>
		</xsl:if>
		<xsl:element name="service_characteristic_list">
			<xsl:if test="request-param[@name='serviceCode'] = 'V9001'">
			<!--  MA Personalnummer -->
				<xsl:element name="CcmFifConfiguredValueCont">
					<xsl:element name="service_char_code">V0218</xsl:element>
					<xsl:element name="data_type">STRING</xsl:element>
					<xsl:element name="configured_value">
						<xsl:value-of select="request-param[@name='employeeNumber']"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>													
			<!-- Bemerkung -->
			<xsl:element name="CcmFifConfiguredValueCont">
				<xsl:element name="service_char_code">V0008</xsl:element>
				<xsl:element name="data_type">STRING</xsl:element>
					<xsl:element name="configured_value">
						<xsl:value-of select="request-param[@name='remarks']"/>
					</xsl:element>
				</xsl:element>
				<!-- Billing Account Number -->
				<xsl:element name="CcmFifConfiguredValueCont">
					<xsl:element name="service_char_code">V1002</xsl:element>
					<xsl:element name="data_type">STRING</xsl:element>
					<xsl:element name="configured_value">
						<xsl:value-of select="request-param[@name='billingAccountNumber']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
	</xsl:element>
</xsl:element>
<!-- Create Customer Order for new services  -->
<xsl:element name="CcmFifCreateCustOrderCmd">
	<xsl:element name="command_id">create_co_1</xsl:element>
	<xsl:element name="CcmFifCreateCustOrderInCont">
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
		<xsl:element name="customer_tracking_id">
			<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
		</xsl:element>
		<xsl:element name="lan_path_file_string">
			<xsl:value-of select="request-param[@name='lanPathFileString']"/>
		</xsl:element>
		<xsl:element name="sales_rep_dept">
			<xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
		</xsl:element>
		<xsl:element name="provider_tracking_no">
			<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
		</xsl:element>
		<xsl:element name="super_customer_tracking_id">
			<xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
		</xsl:element>
		<xsl:element name="scan_date">
			<xsl:value-of select="request-param[@name='scanDate']"/>
		</xsl:element>
		<xsl:element name="order_entry_date">
			<xsl:value-of select="request-param[@name='entryDate']"/>
		</xsl:element>
		<xsl:element name="service_ticket_pos_list">
			<!-- DSL Resale Voice -->
			<xsl:element name="CcmFifCommandRefCont">
				<xsl:element name="command_id">add_service_subs</xsl:element>
				<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
			</xsl:element>
		</xsl:element>
		<xsl:element name="e_shop_id">
			<xsl:value-of select="request-param[@name='eShopID']"/>
		</xsl:element>
	</xsl:element>
</xsl:element>

<!-- Release stand alone customer Order -->
<xsl:element name="CcmFifReleaseCustOrderCmd">
	<xsl:element name="command_id">release_co_1</xsl:element>
	<xsl:element name="CcmFifReleaseCustOrderInCont">
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
		<xsl:element name="customer_order_ref">
			<xsl:element name="command_id">create_co_1</xsl:element>
			<xsl:element name="field_name">customer_order_id</xsl:element>
		</xsl:element>
	</xsl:element>
	</xsl:element>

