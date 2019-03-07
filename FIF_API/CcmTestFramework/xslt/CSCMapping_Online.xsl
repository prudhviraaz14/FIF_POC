<xsl:variable name="dataType">
  <xsl:choose>
    
    <xsl:when test="request-param[@name='parameterName'] = 'dialInAccountName'">USER_ACCOUNT_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountType'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountID'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'mailboxAccountName'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'mailboxAlias'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'billingAccountNumber'">STRING</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'dialInAccountName'">I9058</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountType'">V0097</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountID'">V0162</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'mailboxAccountName'">I0610</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'mailboxAlias'">I0590</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'billingAccountNumber'">V1002</xsl:when>
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
