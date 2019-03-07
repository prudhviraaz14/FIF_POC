<xsl:variable name="dataType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'activationKey'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'activationDate'">DATE</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'remarks'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountType'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountID'">STRING</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'activationKey'">I1402</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'activationDate'">I1403</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'remarks'">V0008</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountType'">V0097</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountID'">V0162</xsl:when>
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
    <xsl:when test="request-param[@name='parameterName'] = 'activationDate'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'today'">
          <xsl:value-of select="dateutils:createOPMDate(dateutils:getCurrentDate())"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="dateutils:createOPMDate(dateutils:SOM2CCBDate($valueToUse))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$valueToUse"/>
    </xsl:otherwise>    
  </xsl:choose>
</xsl:variable>
