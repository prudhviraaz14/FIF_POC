<xsl:variable name="dataType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">ADDRESS</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'numberOfNewAccessNumbers'">INTEGER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'opProcessingType'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'processingType'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'synchronizationIndicator'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'bundleIndicator'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountType'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'preselectionTerminationIndicator'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'reconfigurationReason'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber1'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber2'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber3'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber4'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber5'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber6'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber7'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber8'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber9'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber10'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount1'">USER_ACCOUNT_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount2'">USER_ACCOUNT_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount3'">USER_ACCOUNT_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount4'">USER_ACCOUNT_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount5'">USER_ACCOUNT_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount6'">USER_ACCOUNT_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount7'">USER_ACCOUNT_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount8'">USER_ACCOUNT_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount9'">USER_ACCOUNT_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount10'">USER_ACCOUNT_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'mailboxAlias'">USER_ACCOUNT_NUM</xsl:when>    
    <xsl:otherwise>STRING</xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">V0014</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'numberOfNewAccessNumbers'">V0936</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'opProcessingType'">VI002</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'processingType'">VI002</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'synchronizationIndicator'">VI049</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'bundleIndicator'">VI047</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountType'">V0097</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'preselectionTerminationIndicator'">VI322</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'reconfigurationReason'">VI008</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber1'">V0001</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber2'">V0070</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber3'">V0071</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber4'">V0072</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber5'">V0073</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber6'">V0074</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber7'">V0075</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber8'">V0076</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber9'">V0077</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber10'">V0078</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount1'">VI011</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount2'">VI012</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount3'">VI013</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount4'">VI014</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount5'">VI015</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount6'">VI016</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount7'">VI017</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount8'">VI018</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount9'">VI019</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount10'">VI020</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'mailboxAlias'">VI051</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode1OP'">V0165</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode2OP'">V0166</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode3OP'">V0167</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode4OP'">V0168</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode5OP'">V0169</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode6OP'">V0170</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode7OP'">V0171</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode8OP'">V0172</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode9OP'">V0173</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode10OP'">V0174</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="addressType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">LOKA</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="anotherServiceCharCode"/>
<xsl:variable name="valueToUse">
  <xsl:choose>
    <xsl:when test="request-param[@name='configuredValue'] != ''">
      <xsl:value-of select="request-param[@name='configuredValue']"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="request-param[@name='existingValue']"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="value">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'synchronizationIndicator'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'true'">JA</xsl:when>
        <xsl:otherwise>NEIN</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'preselectionTerminationIndicator'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'true'">Ja</xsl:when>
        <xsl:otherwise>Nein</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$valueToUse"/>
    </xsl:otherwise>    
  </xsl:choose>
</xsl:variable>
