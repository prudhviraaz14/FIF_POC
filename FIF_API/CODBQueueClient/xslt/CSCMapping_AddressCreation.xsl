<xsl:if test="$dataType = 'ADDRESS'">
  
 
  
  <!-- Create Address-->
  <xsl:element name="CcmFifCreateAddressCmd">
    <xsl:element name="command_id">
      <xsl:text>create_address_</xsl:text>
      <xsl:value-of select="request-param[@name='parameterName']"/>
    </xsl:element>
    <xsl:element name="CcmFifCreateAddressInCont">
      <xsl:element name="entity_ref">
        <xsl:element name="command_id">get_entity</xsl:element>
        <xsl:element name="field_name">entity_id</xsl:element>
      </xsl:element>
      <xsl:element name="address_type">
        <xsl:value-of select="$addressType"/>
      </xsl:element>
      <xsl:element name="street_name">
        <xsl:choose>
          <xsl:when test="request-param[@name='configuredCity'] != '' ">
            <xsl:value-of select="request-param[@name='configuredStreet']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='existingStreet']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:element name="street_number">
        <xsl:choose>
          <xsl:when test="request-param[@name='configuredCity'] != '' ">
            <xsl:value-of select="request-param[@name='configuredStreetNumber']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='existingStreetNumber']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:element name="street_number_suffix">
        <xsl:choose>
          <xsl:when test="request-param[@name='configuredCity'] != '' ">
            <xsl:value-of select="request-param[@name='configuredStreetNumberSuffix']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='existingStreetNumberSuffix']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:element name="postal_code">
        <xsl:choose>
          <xsl:when test="request-param[@name='configuredCity'] != '' ">
            <xsl:value-of select="request-param[@name='configuredPostalCode']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='existingPostalCode']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:element name="city_name">
        <xsl:choose>
          <xsl:when test="request-param[@name='configuredCity'] != '' ">
            <xsl:value-of select="request-param[@name='configuredCity']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='existingCity']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:element name="city_suffix_name">
        <xsl:choose>
          <xsl:when test="request-param[@name='configuredCity'] != '' ">
            <xsl:value-of select="request-param[@name='configuredCitySuffix']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='existingCitySuffix']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:element name="country_code">
        <xsl:choose>
          <xsl:when test="request-param[@name='configuredCountry'] != ''">
            <xsl:value-of select="request-param[@name='configuredCountry']"/>
          </xsl:when>
          <xsl:when test="request-param[@name='existingCountry'] != ''">
            <xsl:value-of select="request-param[@name='existingCountry']"/>
          </xsl:when>
          <xsl:otherwise>DE</xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:element name="address_additional_text">
        <xsl:choose>
          <xsl:when test="request-param[@name='configuredCity'] != '' ">
            <xsl:value-of select="request-param[@name='configuredAdditionalAddressDescription']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='existingAdditionalAddressDescription']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:element name="set_primary_address">N</xsl:element>
      <xsl:element name="ignore_existing_address">Y</xsl:element>
      <xsl:if test="request-param[@name='validationTypeRd'] != ''">
        <xsl:element name="validation_type_rd">
          <xsl:value-of select="request-param[@name='validationTypeRd']"/>
        </xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:element>
</xsl:if>
