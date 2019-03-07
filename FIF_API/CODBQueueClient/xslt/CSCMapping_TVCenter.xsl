<xsl:variable name="dataType">
  <xsl:choose>
      <xsl:when test="request-param[@name='parameterName'] = 'multimediaAccount'">USER_ACCOUNT_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">ADDRESS</xsl:when>
    <xsl:otherwise>STRING</xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'language'">I1316</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'reconfigurationReason'">I1312</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'multimediaAccount'">I1330</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'orderVariant'">I1331</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'initialOrderType'">I1332</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'rabatt'">V0097</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'rabattId'">V0162</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'fskLevel'">I1314</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">V0014</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'allowPartialCancel'">I1313</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'transmissionType'">I1305</xsl:when>
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
        <xsl:when test="request-param[@name='parameterName'] = 'allowPartialCancel'">
            <xsl:choose>
                <xsl:when test="$valueToUse = 'true'">ja</xsl:when>
                <xsl:otherwise>nein</xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$valueToUse"/>
        </xsl:otherwise>    
    </xsl:choose>
</xsl:variable>
