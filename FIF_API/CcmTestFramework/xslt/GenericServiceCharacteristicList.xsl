<xsl:choose>
	<!-- address characteristic -->
	<xsl:when test="request-param[@name='DATA_TYPE'] = 'ADDRESS'">
		<xsl:element name="CcmFifAddressCharacteristicCont">
			<xsl:element name="service_char_code"><xsl:value-of select="request-param[@name='SERVICE_CHAR_CODE']"/></xsl:element>
			<xsl:element name="data_type"><xsl:value-of select="request-param[@name='DATA_TYPE']"/></xsl:element>
			<xsl:choose>
				<xsl:when test="request-param[@name='ADDRESS_ID'] = ''">
					<xsl:element name="address_ref">
						<xsl:element name="command_id">
							<xsl:text>create_address_</xsl:text>
							<xsl:value-of select="request-param[@name='SERVICE_CHAR_CODE']"/>
						</xsl:element>
						<xsl:element name="field_name">address_id</xsl:element>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="address_id">
						<xsl:value-of select="request-param[@name='ADDRESS_ID']"/>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:when>
	
	<!-- configured value characteristic -->
	<xsl:when test="request-param[@name='DATA_TYPE'] = 'BOOLEAN' or request-param[@name='DATA_TYPE'] = 'DATE' or
				request-param[@name='DATA_TYPE'] = 'DECIMAL' or request-param[@name='DATA_TYPE'] = 'INTEGER' or
				request-param[@name='DATA_TYPE'] = 'PIN_NUMBER' or request-param[@name='DATA_TYPE'] = 'STRING' or
				request-param[@name='DATA_TYPE'] = 'DIRECTORY_ENTRY' or request-param[@name='DATA_TYPE'] = 'TIME'">
		<xsl:element name="CcmFifConfiguredValueCont">
			<xsl:element name="service_char_code"><xsl:value-of select="request-param[@name='SERVICE_CHAR_CODE']"/></xsl:element>
			<xsl:element name="data_type"><xsl:value-of select="request-param[@name='DATA_TYPE']"/></xsl:element>
			<xsl:element name="configured_value"><xsl:value-of select="request-param[@name='CONFIGURED_VALUE']"/></xsl:element>
		</xsl:element>
	</xsl:when>
	
	<!-- access number characteristic -->
	<xsl:when test="request-param[@name='DATA_TYPE'] = 'ACC_NUM_RANGE' or request-param[@name='DATA_TYPE'] = 'ACC_NUM_RANGE_PC' or
				request-param[@name='DATA_TYPE'] = 'CALLING_CARD' or request-param[@name='DATA_TYPE'] = 'CUST_ACCESS_NUM' or
				request-param[@name='DATA_TYPE'] = 'EXT_CARRIER' or request-param[@name='DATA_TYPE'] = 'IP_NET_ADDRESS' or
				request-param[@name='DATA_TYPE'] = 'MAIN_ACCESS_NUM' or request-param[@name='DATA_TYPE'] = 'MAIN_ACCESS_PC' or
				request-param[@name='DATA_TYPE'] = 'NET_USER_ID' or request-param[@name='DATA_TYPE'] = 'NODE_ID' or
				request-param[@name='DATA_TYPE'] = 'NUI_CALL_CARD' or request-param[@name='DATA_TYPE'] = 'USER_ACCOUNT_NUM' or
				request-param[@name='DATA_TYPE'] = 'X_121_ADDRESS' or request-param[@name='DATA_TYPE'] = 'X_400_ADDRESS' or
				request-param[@name='DATA_TYPE'] = 'TECH_SERVICE_ID' or request-param[@name='DATA_TYPE'] = 'MOBIL_ACCESS_NUM'">
		<xsl:element name="CcmFifAccessNumberCont">
			<xsl:element name="service_char_code"><xsl:value-of select="request-param[@name='SERVICE_CHAR_CODE']"/></xsl:element>
			<xsl:element name="data_type"><xsl:value-of select="request-param[@name='DATA_TYPE']"/></xsl:element>
			<xsl:element name="masking_digits_rd"><xsl:value-of select="request-param[@name='MASKING_DIGITS_RD']"/></xsl:element>
			<xsl:element name="retention_period_rd"><xsl:value-of select="request-param[@name='RETENTION_PERIOD_RD']"/></xsl:element>
			<xsl:element name="storage_masking_digits_rd"><xsl:value-of select="request-param[@name='STORAGE_MASKING_DIGITS_RD']"/></xsl:element>
			<xsl:choose>
				<xsl:when test="request-param[@name='DATA_TYPE'] = 'ACC_NUM_RANGE' or 
							request-param[@name='DATA_TYPE'] = 'MAIN_ACCESS_NUM' or 
							request-param[@name='DATA_TYPE'] = 'MOBIL_ACCESS_NUM'">
					<xsl:element name="validate_duplicate_indicator">
						<xsl:value-of select="/request/request-params/request-param[@name='VALIDATE_ACCESS_NUMBERS']"/>
					</xsl:element>
					<xsl:element name="country_code"><xsl:value-of select="request-param[@name='COUNTRY_CODE']"/></xsl:element>
					<xsl:element name="city_code"><xsl:value-of select="request-param[@name='CITY_CODE']"/></xsl:element>
					<xsl:element name="local_number"><xsl:value-of select="request-param[@name='LOCAL_NUMBER']"/></xsl:element>
					<xsl:element name="from_ext_num"><xsl:value-of select="request-param[@name='FROM_EXT_NUM']"/></xsl:element>
					<xsl:element name="to_ext_num"><xsl:value-of select="request-param[@name='TO_EXT_NUM']"/></xsl:element>
				</xsl:when>
				<xsl:when test="(request-param[@name='DATA_TYPE'] = 'IP_NET_ADDRESS')">
					<xsl:element name="ip_number"><xsl:value-of select="request-param[@name='IP_NUMBER']"/></xsl:element>
					<xsl:element name="subnet_mask"><xsl:value-of select="request-param[@name='SUBNET_MASK']"/></xsl:element>
					<xsl:element name="alias"><xsl:value-of select="request-param[@name='ALIAS']"/></xsl:element>
				</xsl:when>
				<xsl:when test="(request-param[@name='DATA_TYPE'] = 'USER_ACCOUNT_NUM')">
					<xsl:element name="network_account"><xsl:value-of select="request-param[@name='NETWORK_ACCOUNT']"/></xsl:element>
				</xsl:when>  
				<xsl:when test="(request-param[@name='DATA_TYPE'] = 'X_121_ADDRESS')">
					<xsl:element name="area_id"><xsl:value-of select="request-param[@name='AREA_ID']"/></xsl:element>
					<xsl:element name="number"><xsl:value-of select="request-param[@name='NUMBER']"/></xsl:element>
					<xsl:element name="data_network_id_code"><xsl:value-of select="request-param[@name='DATA_NETWORK_ID_CODE']"/></xsl:element>
					<xsl:element name="sub_address"><xsl:value-of select="request-param[@name='SUB_ADDRESS']"/></xsl:element>
				</xsl:when>  
				<xsl:when test="(request-param[@name='DATA_TYPE'] = 'X_400_ADDRESS')">
					<xsl:element name="country"><xsl:value-of select="request-param[@name='COUNTRY']"/></xsl:element>
					<xsl:element name="admin_mgmt_domain"><xsl:value-of select="request-param[@name='ADMIN_MGMT_DOMAIN']"/></xsl:element>
					<xsl:element name="private_mgmt_domain"><xsl:value-of select="request-param[@name='PRIVATE_MGMT_DOMAIN']"/></xsl:element>
					<xsl:element name="surname"><xsl:value-of select="request-param[@name='SURNAME']"/></xsl:element>
					<xsl:element name="middle_initial"><xsl:value-of select="request-param[@name='MIDDLE_INITIAL']"/></xsl:element>
					<xsl:element name="given_name"><xsl:value-of select="request-param[@name='GIVEN_NAME']"/></xsl:element>
					<xsl:element name="personal_name"><xsl:value-of select="request-param[@name='PERSONAL_NAME']"/></xsl:element>
					<xsl:element name="generation_qualifier"><xsl:value-of select="request-param[@name='GENERATION_QUALIFIER']"/></xsl:element>
					<xsl:element name="organization"><xsl:value-of select="request-param[@name='ORGANIZATION']"/></xsl:element>
					<xsl:element name="org_unit_1"><xsl:value-of select="request-param[@name='ORG_UNIT_1']"/></xsl:element>
					<xsl:element name="org_unit_2"><xsl:value-of select="request-param[@name='ORG_UNIT_2']"/></xsl:element>
					<xsl:element name="org_unit_3"><xsl:value-of select="request-param[@name='ORG_UNIT_3']"/></xsl:element>
					<xsl:element name="org_unit_4"><xsl:value-of select="request-param[@name='ORG_UNIT_4']"/></xsl:element>
					<xsl:element name="gateway_domain"><xsl:value-of select="request-param[@name='GATEWAY_DOMAIN']"/></xsl:element>
				</xsl:when>  
				<xsl:when test="(request-param[@name='DATA_TYPE'] = 'CUST_ACCESS_NUM')">
					<xsl:element name="number"><xsl:value-of select="request-param[@name='NUMBER']"/></xsl:element>
				</xsl:when>  
				<xsl:when test="(request-param[@name='DATA_TYPE'] = 'NET_USER_ID')">
					<xsl:element name="network_user_identifier"><xsl:value-of select="request-param[@name='NETWORK_USER_IDENTIFIER']"/></xsl:element>
				</xsl:when>  
				<xsl:when test="(request-param[@name='DATA_TYPE'] = 'EXT_CARRIER')">
					<xsl:element name="external_carrier_code"><xsl:value-of select="request-param[@name='EXTERNAL_CARRIER_CODE']"/></xsl:element>
				</xsl:when>  
				<xsl:when test="(request-param[@name='DATA_TYPE'] = 'TECH_SERVICE_ID')">
					<xsl:element name="network_account"><xsl:value-of select="request-param[@name='TECH_SERVICE_ID']"/></xsl:element>
				</xsl:when> 
			</xsl:choose> 
		</xsl:element>
	</xsl:when>
	
	<!-- service location characteristic -->
	<xsl:when test="request-param[@name='DATA_TYPE'] = 'SERVICE_LOCATION'">
		<xsl:element name="CcmFifServiceLocationCont">
			<xsl:element name="service_char_code"><xsl:value-of select="request-param[@name='SERVICE_CHAR_CODE']"/></xsl:element>
			<xsl:element name="data_type"><xsl:value-of select="request-param[@name='DATA_TYPE']"/></xsl:element>
			<xsl:element name="floor"><xsl:value-of select="request-param[@name='FLOOR']"/></xsl:element>
			<xsl:element name="room_number"><xsl:value-of select="request-param[@name='ROOM_NUMBER']"/></xsl:element>
			<xsl:element name="jack_location"><xsl:value-of select="request-param[@name='JACK_LOCATION']"/></xsl:element>
			<xsl:element name="desk_number"><xsl:value-of select="request-param[@name='DESK_NUMBER']"/></xsl:element>
			<xsl:element name="additional_location_info"><xsl:value-of select="request-param[@name='ADDITIONAL_LOCATION_INFO']"/></xsl:element>
		</xsl:element>
	</xsl:when>
</xsl:choose>
