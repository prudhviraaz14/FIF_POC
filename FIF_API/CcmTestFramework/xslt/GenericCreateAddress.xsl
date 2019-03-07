<xsl:if test="request-param[@name='DATA_TYPE'] = 'ADDRESS' and request-param[@name='ADDRESS_ID'] = ''">
	<xsl:element name="CcmFifCreateAddressCmd">
		<xsl:element name="command_id">
			<xsl:text>create_address_</xsl:text>
			<xsl:value-of select="request-param[@name='SERVICE_CHAR_CODE']"/>								
		</xsl:element>
		<xsl:element name="CcmFifCreateAddressInCont">
			<xsl:element name="entity_ref">
				<xsl:element name="command_id">get_entity</xsl:element>
				<xsl:element name="field_name">entity_id</xsl:element>            
			</xsl:element>
			<xsl:element name="address_type">
				<xsl:value-of select="request-param[@name='ADDRESS_TYPE']"/>
			</xsl:element>
			<xsl:element name="street_name">
				<xsl:value-of select="request-param[@name='STREET_NAME']"/>
			</xsl:element>
			<xsl:element name="street_number">
				<xsl:value-of select="request-param[@name='STREET_NUMBER']"/>
			</xsl:element>
			<xsl:element name="street_number_suffix">
				<xsl:value-of select="request-param[@name='STREET_NUMBER_SUFFIX']"/>
			</xsl:element>
			<xsl:element name="postal_code">
				<xsl:value-of select="request-param[@name='POSTAL_CODE']"/>
			</xsl:element>
			<xsl:element name="city_name">
				<xsl:value-of select="request-param[@name='CITY_NAME']"/>
			</xsl:element>
			<xsl:element name="city_suffix_name">
				<xsl:value-of select="request-param[@name='CITY_SUFFIX_NAME']"/>
			</xsl:element>
			<xsl:if test="request-param[@name='COUNTRY_CODE'] != ''">
			  <xsl:element name="country_code">
				  <xsl:value-of select="request-param[@name='COUNTRY_CODE']"/>
			  </xsl:element>
			</xsl:if>
			<xsl:if test="request-param[@name='COUNTRY_CODE']=''">
			 <xsl:element name="country_code">DE</xsl:element>
			</xsl:if>
			<xsl:element name="address_additional_text">
				<xsl:value-of select="request-param[@name='ADDRESS_ADDITIONAL_TEXT']"/>
			</xsl:element>
			<xsl:element name="set_primary_address">N</xsl:element>
			<xsl:element name="ignore_existing_address">Y</xsl:element>
		</xsl:element>
	</xsl:element>
</xsl:if>
