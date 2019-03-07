<!-- Calculate today and one day before the desired date -->
<xsl:variable name="today" select="dateutils:getCurrentDate()"/>

<xsl:variable name="MaskingDigits">
	<xsl:choose>
		<xsl:when test="request-param[@name='cdrEgnFormat'] = 'NO_EGN'">0</xsl:when>
		<xsl:when test="request-param[@name='cdrEgnFormat'] = 'ABBREVIATED_EGN'">20</xsl:when>
		<xsl:when test="request-param[@name='cdrEgnFormat'] = 'FULL_EGN'">-1</xsl:when>
		<xsl:when test="request-param[@name='cdrEgnFormat'] = 'NORMAL_EGN'">-1</xsl:when>
		<xsl:otherwise>unknown</xsl:otherwise>
	</xsl:choose>
	
</xsl:variable>

<xsl:variable name="StorageMaskingDigits">
	<xsl:choose>
		<xsl:when test="request-param[@name='cdrStorageFormat'] = 'IMMEDIATE_DELETION'">0</xsl:when>
		<xsl:when test="request-param[@name='cdrStorageFormat'] = 'ABBREVIATED_STORAGE'">20</xsl:when>
		<xsl:when test="request-param[@name='cdrStorageFormat'] = 'FULL_STORAGE'">-1</xsl:when>
		<xsl:when test="request-param[@name='cdrStorageFormat'] = 'NORMAL_STORAGE'">-1</xsl:when>
		<xsl:otherwise>unknown</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="RetentionPeriod">				
	<xsl:choose>
		<xsl:when test="request-param[@name='cdrEgnFormat'] = 'NO_EGN'">80NODT</xsl:when>
		<xsl:when test="request-param[@name='cdrEgnFormat'] = 'ABBREVIATED_EGN'">80DETL</xsl:when>
		<xsl:when test="request-param[@name='cdrEgnFormat'] = 'FULL_EGN'">80DETL</xsl:when>
		<xsl:when test="request-param[@name='cdrEgnFormat'] = 'NORMAL_EGN'">80DETL</xsl:when>						
		<xsl:otherwise>unknown</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:if test="$MaskingDigits = 'unknown'
	or $StorageMaskingDigits = 'unknown'
	or $RetentionPeriod = 'unknown'">
	<xsl:element name="CcmFifRaiseErrorCmd">
		<xsl:element name="command_id">raise_error_unknown_value</xsl:element>
		<xsl:element name="CcmFifRaiseErrorInCont">
			<xsl:element name="error_text">Unbekannter Wert für EGN gewaehlt.</xsl:element>
		</xsl:element>
	</xsl:element>
</xsl:if>

<!-- Get Customer number if not provided-->
<xsl:if test="(request-param[@name='customerNumber'] = '')">
	<xsl:element name="CcmFifReadExternalNotificationCmd">
		<xsl:element name="command_id">read_cust_num_from_ext_noti</xsl:element>
		<xsl:element name="CcmFifReadExternalNotificationInCont">
			<xsl:element name="transaction_id">
				<xsl:value-of select="request-param[@name='requestListId']"/>
			</xsl:element>
			<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
		</xsl:element>
	</xsl:element>
</xsl:if>

<!-- Get Account number if not provided -->
<xsl:if test="(request-param[@name='accountNumber'] = '')">
	<xsl:element name="CcmFifReadExternalNotificationCmd">
		<xsl:element name="command_id">read_account_num_from_ext_noti</xsl:element>
		<xsl:element name="CcmFifReadExternalNotificationInCont">
			<xsl:element name="transaction_id">
				<xsl:value-of select="request-param[@name='requestListId']"/>
			</xsl:element>
			<xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
		</xsl:element>
	</xsl:element>
</xsl:if>

<!-- Normalize Address  if the address id is provided. -->
<xsl:if test="request-param[@name='addressId'] != ''">
	<xsl:element name="CcmFifNormalizeAddressCmd">
		<xsl:element name="command_id">normalize_address_1</xsl:element>
		<xsl:element name="CcmFifNormalizeAddressInCont">
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
			<xsl:element name="address_id">
				<xsl:value-of select="request-param[@name='addressId']"/>
			</xsl:element>
		</xsl:element>
	</xsl:element>
</xsl:if>

<!-- Get Entity Information -->   
<xsl:element name="CcmFifGetEntityCmd">
	<xsl:element name="command_id">get_entity_data</xsl:element>
	<xsl:element name="CcmFifGetEntityInCont">
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
	</xsl:element>
</xsl:element>

<!-- Create Address if not provided -->
<xsl:if test="request-param[@name='addressId'] = ''">	
	<!-- Create Address-->
	<xsl:element name="CcmFifCreateAddressCmd">
		<xsl:element name="command_id">create_address</xsl:element>
		<xsl:element name="CcmFifCreateAddressInCont">
			<xsl:element name="entity_ref">
				<xsl:element name="command_id">get_entity_data</xsl:element>
				<xsl:element name="field_name">entity_id</xsl:element>
			</xsl:element>
			<xsl:element name="address_type">STD</xsl:element>
			<xsl:element name="street_name">
				<xsl:value-of select="request-param[@name='streetName']"/>
			</xsl:element>
			<xsl:element name="street_number">
				<xsl:value-of select="request-param[@name='streetNumber']"/>
			</xsl:element>
			<xsl:element name="street_number_suffix">
				<xsl:value-of select="request-param[@name='numberSuffix']"/>
			</xsl:element>
			<xsl:element name="postal_code">
				<xsl:value-of select="request-param[@name='postalCode']"/>
			</xsl:element>
			<xsl:element name="city_name">
				<xsl:value-of select="request-param[@name='city']"/>
			</xsl:element>
			<xsl:element name="city_suffix_name">
				<xsl:value-of select="request-param[@name='citySuffix']"/>
			</xsl:element>
			<xsl:if test="request-param[@name='country']!=''">
				<xsl:element name="country_code">
					<xsl:value-of select="request-param[@name='country']"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="request-param[@name='country']=''">
				<xsl:element name="country_code">DE</xsl:element>
			</xsl:if>
			<xsl:element name="address_additional_text">
				<xsl:value-of select="request-param[@name='additionalText']"/>
			</xsl:element>
			<xsl:element name="set_primary_address">N</xsl:element>
			<xsl:element name="ignore_existing_address">Y</xsl:element>
		</xsl:element>
	</xsl:element>
</xsl:if>

<!-- Create Address if not provided -->
<xsl:if test="request-param[@name='createAdditionalAddress'] = 'Y'">	
	<!-- Create Address-->
	<xsl:element name="CcmFifCreateAddressCmd">
		<xsl:element name="command_id">create_additional_address</xsl:element>
		<xsl:element name="CcmFifCreateAddressInCont">
			<xsl:element name="entity_ref">
				<xsl:element name="command_id">get_entity_data</xsl:element>
				<xsl:element name="field_name">entity_id</xsl:element>
			</xsl:element>
			<xsl:element name="address_type">STD</xsl:element>
			<xsl:element name="street_name">
				<xsl:value-of select="request-param[@name='additionalStreetName']"/>
			</xsl:element>
			<xsl:element name="street_number">
				<xsl:value-of select="request-param[@name='additionalStreetNumber']"/>
			</xsl:element>
			<xsl:element name="street_number_suffix">
				<xsl:value-of select="request-param[@name='additionalNumberSuffix']"/>
			</xsl:element>
			<xsl:element name="postal_code">
				<xsl:value-of select="request-param[@name='additionalPostalCode']"/>
			</xsl:element>
			<xsl:element name="city_name">
				<xsl:value-of select="request-param[@name='additionalCity']"/>
			</xsl:element>
			<xsl:element name="city_suffix_name">
				<xsl:value-of select="request-param[@name='additionalCitySuffix']"/>
			</xsl:element>
			<xsl:if test="request-param[@name='additionalCountry']!=''">
				<xsl:element name="country_code">
					<xsl:value-of select="request-param[@name='additionalCountry']"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="request-param[@name='additionalCountry']=''">
				<xsl:element name="country_code">DE</xsl:element>
			</xsl:if>
			<xsl:element name="address_additional_text">
				<xsl:value-of select="request-param[@name='additionalText']"/>
			</xsl:element>
			<xsl:element name="set_primary_address">N</xsl:element>
			<xsl:element name="ignore_existing_address">Y</xsl:element>
		</xsl:element>
	</xsl:element>
</xsl:if>



