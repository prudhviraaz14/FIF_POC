<xsl:variable name="dataType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'fixedIPAddress'">IP_NET_ADDRESS</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'dialInAccountNameStatic'">USER_ACCOUNT_NUM</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'fixedIPAddress'">I905B</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'dialInAccountNameStatic'">I905A</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="anotherServiceCharCode"/>
<xsl:variable name="addressType"/>
<xsl:variable name="value">
  <xsl:choose>
     <xsl:when test="request-param[@name='configuredValue'] ='UNCONFIGURED'">
      <xsl:value-of select="';0.0.0.0;0.0.0.0'"/>
    </xsl:when>
    <xsl:when test="(request-param[@name='configuredValue'] != '')">
      <xsl:value-of select="request-param[@name='configuredValue']"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="request-param[@name='existingValue']"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
