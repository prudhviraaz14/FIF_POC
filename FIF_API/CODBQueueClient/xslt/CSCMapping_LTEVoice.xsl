<xsl:variable name="dataType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber1'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber2'
      and $serviceType != 'voiceBasis'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber3'
      and $serviceType != 'voiceBasis'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber4'
      and $serviceType != 'voiceBasis'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber5'
      and $serviceType != 'voiceBasis'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber6'
      and $serviceType != 'voiceBasis'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber7'
      and $serviceType != 'voiceBasis'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber8'
      and $serviceType != 'voiceBasis'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber9'
      and $serviceType != 'voiceBasis'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber10'
      and $serviceType != 'voiceBasis'">MAIN_ACCESS_NUM</xsl:when>
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
    <xsl:when test="request-param[@name='parameterName'] = 'networkElementId'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldLocalExchangeCarrier'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'localAreaCode'">STRING</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'remarks'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">ADDRESS</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'networkElementId'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountType'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountID'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'activationType'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'salesSegment'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'projectOrderIndicator'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'orderVariant'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldCustomerNumber'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'asb'">INTEGER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'billingAccountNumber'">STRING</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber1'">V0001</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber2'
      and $serviceType != 'voiceBasis'">V0070</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber3'
      and $serviceType != 'voiceBasis'">V0071</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber4'
      and $serviceType != 'voiceBasis'">V0072</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber5'
      and $serviceType != 'voiceBasis'">V0073</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber6'
      and $serviceType != 'voiceBasis'">V0074</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber7'
      and $serviceType != 'voiceBasis'">V0075</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber8'
      and $serviceType != 'voiceBasis'">V0076</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber9'
      and $serviceType != 'voiceBasis'">V0077</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber10'
      and $serviceType != 'voiceBasis'">V0078</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount1'">VI011</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount2'and $serviceType != 'voiceBasis'">VI012</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount3'and $serviceType != 'voiceBasis'">VI013</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount4'and $serviceType != 'voiceBasis'">VI014</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount5'and $serviceType != 'voiceBasis'">VI015</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount6'and $serviceType != 'voiceBasis'">VI016</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount7'and $serviceType != 'voiceBasis'">VI017</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount8'and $serviceType != 'voiceBasis'">VI018</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount9'and $serviceType != 'voiceBasis'">VI019</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount10'and $serviceType != 'voiceBasis'">VI020</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'mailboxAlias'">VI051</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'networkElementId'">Z0100</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldLocalExchangeCarrier'">V0060</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'localAreaCode'">V0124</xsl:when>   
    <xsl:when test="request-param[@name='parameterName'] = 'remarks'">V0008</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">V0014</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountType'">V0097</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountID'">V0162</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'activationType'">V0133</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'salesSegment'">V0105</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'projectOrderIndicator'">V0104</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'orderVariant'">V0810</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldCustomerNumber'">V0945</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'asb'">V0934</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'billingAccountNumber'and $serviceType != 'voiceBasis'">V1002</xsl:when>
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
    <xsl:when test="request-param[@name='parameterName'] = 'projectOrderIndicator'">
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
