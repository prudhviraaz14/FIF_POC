<xsl:variable name="dataType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'cancellationIndicator'">BOOLEAN</xsl:when>
    <xsl:otherwise>STRING</xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'networkElementId'">Z0100</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineID'">V0854</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'isdnActiveVariant'">V0864</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'remarks'">V0008</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'cancellationIndicator'">V0226</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'provisioningDiscount'">V0149</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'providerContractNumber'">I1325</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DTAGContractNumber'">I1325</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DTAGOrderNumber'">I1326</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'providerCompletionDate'">VI062</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DTAGCompletionDate'">VI062</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'providerPaymentDate'">I1327</xsl:when>  
    <xsl:when test="request-param[@name='parameterName'] = 'DTAGPaymentDate'">I1327</xsl:when>
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
    <xsl:when test="request-param[@name='parameterName'] = 'cancellationIndicator'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'true'">Y</xsl:when>
        <xsl:otherwise>N</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'providerCompletionDate' or request-param[@name='parameterName'] = 'DTAGCompletionDate'
      or request-param[@name='parameterName'] = 'providerPaymentDate' or request-param[@name='parameterName'] = 'DTAGPaymentDate'">
      <xsl:value-of select="dateutils:SOM2OPMDate($valueToUse)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$valueToUse"/>
    </xsl:otherwise>    
  </xsl:choose>
</xsl:variable>
