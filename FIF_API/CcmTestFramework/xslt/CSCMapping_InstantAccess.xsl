<xsl:variable name="dataType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'simID'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'instantAccessTariff'">STRING</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'simID'">V0108</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'instantAccessTariff'">V8004</xsl:when>
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
  <xsl:value-of select="$valueToUse"/>
</xsl:variable>
