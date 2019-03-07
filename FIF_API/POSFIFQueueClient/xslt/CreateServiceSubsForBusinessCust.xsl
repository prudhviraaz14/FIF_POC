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
			<xsl:value-of select="request-param[@name='desiredDate']"/>
		</xsl:element>
		<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
		<xsl:element name="reason_rd">
			<xsl:value-of select="request-param[@name='reasonRd']"/>
		</xsl:element>
		<xsl:if test="request-param[@name='accountNumber']=''">
			<xsl:element name="account_number_ref">
				<xsl:element name="command_id">reas_account_num_from_ext_noti</xsl:element>
				<xsl:element name="field_name">parameter_value</xsl:element>
			</xsl:element>
		</xsl:if>
		<xsl:if test="request-param[@name='accountNumber']!=''">
			<xsl:element name="account_number">
				<xsl:value-of select="request-param[@name='accountNumber']"/>
			</xsl:element>
		</xsl:if>
		<xsl:element name="service_characteristic_list">
			<xsl:for-each select="request-param-list[@name='configServiceCharList']/request-param-list-item">
				<!-- address characteristic -->
				<xsl:if test="request-param[@name='dataType'] = 'ADDRESS'">

					<xsl:variable name="addressId">
						<xsl:text/>
						<xsl:value-of select="../request-param[@name='addressId']"/>
					</xsl:variable>

					<xsl:variable name="useAdditionalCreatedAddress">
						<xsl:text/>
						<xsl:value-of select="request-param[@name='useAdditionalCreatedAddress']"/>
					</xsl:variable>
					
					<xsl:variable name="useCreatedAddress">
						<xsl:choose>
							<xsl:when test="$addressId = '' and $useAdditionalCreatedAddress != 'Y'">Y</xsl:when>
							<xsl:otherwise>N</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:element name="CcmFifAddressCharacteristicCont">
						<xsl:element name="service_char_code"><xsl:value-of select="request-param[@name='serviceCharCode']"/></xsl:element>
						<xsl:element name="data_type">ADDRESS</xsl:element>
						<xsl:if test="$useCreatedAddress= 'Y'">
							<xsl:element name="address_ref">
								<xsl:element name="command_id">create_address</xsl:element>
								<xsl:element name="field_name">address_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="$useAdditionalCreatedAddress = 'Y'">
							<xsl:element name="address_ref">
								<xsl:element name="command_id">create_additional_address</xsl:element>
								<xsl:element name="field_name">address_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="$useCreatedAddress != 'Y' and $useAdditionalCreatedAddress != 'Y'">
							<xsl:element name="address_id">
								<xsl:value-of select="$addressId"/>
							</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:if>
				<!-- configured value characteristic -->
				<xsl:if test="(request-param[@name='dataType'] = 'BOOLEAN' or request-param[@name='dataType'] = 'DATE' or
					request-param[@name='dataType'] = 'DECIMAL' or request-param[@name='dataType'] = 'INTEGER' or
					request-param[@name='dataType'] = 'PIN_NUMBER' or request-param[@name='dataType'] = 'STRING' or
					request-param[@name='dataType'] = 'TIME')">
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code"><xsl:value-of select="request-param[@name='serviceCharCode']"/></xsl:element>
						<xsl:element name="data_type"><xsl:value-of select="request-param[@name='dataType']"/></xsl:element>
						<xsl:element name="configured_value"><xsl:value-of select="request-param[@name='configuredValue']"/></xsl:element>
					</xsl:element>
				</xsl:if>
				<!-- User Account ID -->
				<xsl:if test="request-param[@name='dataType'] = 'USER_ACCOUNT_NUM'">
					<xsl:element name="CcmFifAccessNumberCont">
						<xsl:element name="service_char_code"><xsl:value-of select="request-param[@name='serviceCharCode']"/></xsl:element>
						<xsl:element name="data_type">USER_ACCOUNT_NUM</xsl:element>
						<xsl:element name="masking_digits_rd"><xsl:value-of select="$MaskingDigits"/></xsl:element>
						<xsl:element name="retention_period_rd"><xsl:value-of select="$RetentionPeriod"/></xsl:element>
						<xsl:element name="storage_masking_digits_rd"><xsl:value-of select="$StorageMaskingDigits"/></xsl:element>
							<xsl:element name="network_account"><xsl:value-of select="request-param[@name='userAccountId']"/></xsl:element>
					</xsl:element>
				</xsl:if>

				<!-- service location characteristic -->
				<xsl:if test="request-param[@name='dataType'] = 'SERVICE_LOCATION'">
					<xsl:element name="CcmFifServiceLocationCont">
						<xsl:element name="service_char_code"><xsl:value-of select="request-param[@name='serviceCharCode']"/></xsl:element>
						<xsl:element name="data_type">SERVICE_LOCATION</xsl:element>
						<xsl:element name="jack_location">
							<xsl:value-of select="request-param[@name='serviceLocation']"/>
						</xsl:element>
					</xsl:element>
				</xsl:if>
			</xsl:for-each>
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

