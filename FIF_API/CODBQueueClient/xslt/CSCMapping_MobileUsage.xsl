<xsl:variable name="dataType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber'">MOBIL_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'billingAccountNumber'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'simSerialNumber'">STRING</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber'">V0180</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'billingAccountNumber'">V0080</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'simSerialNumber'">V0108</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="anotherServiceCharCode"/>
<xsl:variable name="addressType"/>
<xsl:variable name="value">
  <xsl:choose>
    <xsl:when test="request-param[@name='configuredValue'] != ''">
      <xsl:value-of select="request-param[@name='configuredValue']"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="request-param[@name='existingValue']"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
