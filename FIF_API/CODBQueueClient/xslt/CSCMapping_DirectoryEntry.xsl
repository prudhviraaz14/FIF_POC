<xsl:variable name="dataType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'listedPhoneNumber'">DIRECTORY_ENTRY</xsl:when>   
    <xsl:when test="request-param[@name='parameterName'] = 'directoryEntryType'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'dtagId'">STRING</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'inverseSearchIndicator'">STRING</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'listedPhoneNumber'">V0100</xsl:when>   
    <xsl:when test="request-param[@name='parameterName'] = 'directoryEntryType'">V0101</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'dtagId'">V0102</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'inverseSearchIndicator'">V0148</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="addressType"/>
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
    <xsl:when test="request-param[@name='parameterName'] = 'inverseSearchIndicator'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'true'">J</xsl:when>
        <xsl:when test="$valueToUse = 'false'">N</xsl:when>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$valueToUse"/>
    </xsl:otherwise>    
  </xsl:choose>
</xsl:variable>
