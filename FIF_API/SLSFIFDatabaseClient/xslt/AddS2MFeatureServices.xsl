<!-- Create Feature Services -->
<xsl:if	test="count(request-param-list[@name='featureServiceList']/request-param-list-item) != 0">
	<xsl:for-each select="request-param-list[@name='featureServiceList']/request-param-list-item">
		<xsl:variable name="featureServiceCode" select="request-param[@name='serviceCode']"/>
		<xsl:element name="CcmFifAddServiceSubsCmd">
			<xsl:element name="command_id">
				<xsl:value-of select="concat($AddServCommandId, $featureServiceCode)"/>
			</xsl:element>
			<xsl:element name="CcmFifAddServiceSubsInCont">
				<xsl:element name="product_subscription_ref">
					<xsl:element name="command_id">add_product_subscription_1</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="service_code">
					<xsl:value-of select="$featureServiceCode"/>
				</xsl:element>
				<xsl:element name="parent_service_subs_ref">
					<xsl:element name="command_id">add_service_1</xsl:element>
					<xsl:element name="field_name">service_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="desired_schedule_type">ASAP</xsl:element>
				<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
				<xsl:if test="//request-param[@name='accountNumber'] = ''">
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">read_account_num_from_ext_noti</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:if test="//request-param[@name='accountNumber'] != ''">
					<xsl:element name="account_number">
						<xsl:value-of select="//request-param[@name='accountNumber']"/>
					</xsl:element>
				</xsl:if>
				<xsl:element name="service_characteristic_list"/>
			</xsl:element>
		</xsl:element>
	</xsl:for-each>
</xsl:if>

<xsl:if test="request-param[@name='clientName'] !='POS'">
	<!-- Add Feature Service V0138  if block0190/0900 is set -->
	<xsl:if test="request-param[@name='block0190/0900'] = 'Y'">
		<xsl:element name="CcmFifAddServiceSubsCmd">
			<xsl:element name="command_id">add_service_2</xsl:element>
			<xsl:element name="CcmFifAddServiceSubsInCont">
				<xsl:element name="product_subscription_ref">
					<xsl:element name="command_id">add_product_subscription_1</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="service_code">V0138</xsl:element>
				<xsl:element name="parent_service_subs_ref">
					<xsl:element name="command_id">add_service_1</xsl:element>
					<xsl:element name="field_name">service_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="desired_date">
					<xsl:value-of select="$today"/>
				</xsl:element>
				<xsl:element name="desired_schedule_type">ASAP</xsl:element>
				<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
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
					<!-- Steuerung über OP -->
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">I0018</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>
						<xsl:element name="configured_value">mit OP</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:if>

	<!-- Add Feature Service V0054 if addCLIPNoScreening is set -->
	<xsl:if test="request-param[@name='addCLIPNoScreening'] = 'Y'">
		<xsl:element name="CcmFifAddServiceSubsCmd">
			<xsl:element name="command_id">add_service_3</xsl:element>
			<xsl:element name="CcmFifAddServiceSubsInCont">
				<xsl:element name="product_subscription_ref">
					<xsl:element name="command_id">add_product_subscription_1</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="service_code">V0054</xsl:element>
				<xsl:element name="parent_service_subs_ref">
					<xsl:element name="command_id">add_service_1</xsl:element>
					<xsl:element name="field_name">service_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="desired_date">
					<xsl:value-of select="$today"/>
				</xsl:element>
				<xsl:element name="desired_schedule_type">ASAP</xsl:element>
				<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
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
					<!-- Steuerung über OP -->
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">I0018</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>
						<xsl:element name="configured_value">mit OP</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:if>

	<!-- Add Features for serviceLevel -->
	<xsl:if test="request-param[@name='serviceLevel'] != ''">
		<xsl:element name="CcmFifAddServiceSubsCmd">
			<xsl:element name="command_id">add_service_4</xsl:element>
			<xsl:element name="CcmFifAddServiceSubsInCont">
				<xsl:element name="product_subscription_ref">
					<xsl:element name="command_id">add_product_subscription_1</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="service_code">V0071</xsl:element>
				<xsl:element name="parent_service_subs_ref">
					<xsl:element name="command_id">add_service_1</xsl:element>
					<xsl:element name="field_name">service_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="desired_date">
					<xsl:value-of select="$today"/>
				</xsl:element>
				<xsl:element name="desired_schedule_type">ASAP</xsl:element>
				<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
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
					<!-- Steuerung über OP -->
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">I0018</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>
						<xsl:element name="configured_value">mit OP</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:if>

	<!-- Add Tarifinformation V0050 -->
	<xsl:if test="request-param[@name='AoC'] != ''">
		<xsl:element name="CcmFifAddServiceSubsCmd">
			<xsl:element name="command_id">add_service_5</xsl:element>
			<xsl:element name="CcmFifAddServiceSubsInCont">
				<xsl:element name="product_subscription_ref">
					<xsl:element name="command_id">add_product_subscription_1</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="service_code">V0050</xsl:element>
				<xsl:element name="parent_service_subs_ref">
					<xsl:element name="command_id">add_service_1</xsl:element>
					<xsl:element name="field_name">service_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="desired_date">
					<xsl:value-of select="$today"/>
				</xsl:element>
				<xsl:element name="desired_schedule_type">ASAP</xsl:element>
				<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
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
					<!-- Steuerung über OP -->
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">I0018</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>
						<xsl:element name="configured_value">mit OP</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:if>

	<!-- Add Weiterleitung bei Störung V0248 -->
	<xsl:if test="request-param[@name='addForwardCall'] != ''">
		<xsl:element name="CcmFifAddServiceSubsCmd">
			<xsl:element name="command_id">add_service_6</xsl:element>
			<xsl:element name="CcmFifAddServiceSubsInCont">
				<xsl:element name="product_subscription_ref">
					<xsl:element name="command_id">add_product_subscription_1</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="service_code">V0248</xsl:element>
				<xsl:element name="parent_service_subs_ref">
					<xsl:element name="command_id">add_service_1</xsl:element>
					<xsl:element name="field_name">service_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="desired_date">
					<xsl:value-of select="$today"/>
				</xsl:element>
				<xsl:element name="desired_schedule_type">ASAP</xsl:element>
				<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
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
					<!-- Steuerung über OP -->
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">I0018</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>
						<xsl:element name="configured_value">mit OP</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:if>

	<!-- Aktionskennung monatlich V0318 -->
	<xsl:if test="request-param[@name='monthlyCondition'] != ''">
		<xsl:element name="CcmFifAddServiceSubsCmd">
			<xsl:element name="command_id">add_service_7</xsl:element>
			<xsl:element name="CcmFifAddServiceSubsInCont">
				<xsl:element name="product_subscription_ref">
					<xsl:element name="command_id">add_product_subscription_1</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="service_code">V0318</xsl:element>
				<xsl:element name="parent_service_subs_ref">
					<xsl:element name="command_id">add_service_1</xsl:element>
					<xsl:element name="field_name">service_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="desired_date">
					<xsl:value-of select="$today"/>
				</xsl:element>
				<xsl:element name="desired_schedule_type">ASAP</xsl:element>
				<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
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
					<!-- Aktionskennung monatlich -->
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">V0193</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>
						<xsl:element name="configured_value">
							<xsl:value-of select="request-param[@name='monthlyConditionId']"/>
						</xsl:element>
					</xsl:element>
					<!-- Steuerung über OP -->
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">I0018</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>
						<xsl:element name="configured_value">mit OP</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:if>
</xsl:if>
