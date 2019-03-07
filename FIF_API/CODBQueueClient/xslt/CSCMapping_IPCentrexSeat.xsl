<xsl:variable name="dataType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'imsi'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'msisdnStatus'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'remarks'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'fixedAccessNumber'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'mobileAccessNumber'">MOBIL_ACCESS_NUM</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'imsi'">VI074</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'msisdnStatus'">VI075</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'remarks'">V0008</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'fixedAccessNumber'">V0001</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'mobileAccessNumber'">V0180</xsl:when>
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
