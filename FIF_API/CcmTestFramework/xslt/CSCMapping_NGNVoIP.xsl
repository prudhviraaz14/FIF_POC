<xsl:variable name="dataType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'mailboxAlias'">USER_ACCOUNT_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">ADDRESS</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'numberOfNewAccessNumbers'">INTEGER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'asb'">INTEGER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber1'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber2'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber3'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber4'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber5'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber6'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber7'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber8'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber9'">MAIN_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber10'">MAIN_ACCESS_NUM</xsl:when>
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
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner1'">LINEOWNER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner2'">LINEOWNER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwnerAddress'">ADDRESS</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountID'">STRING</xsl:when>
    <xsl:otherwise>STRING</xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">V0014</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'numberOfNewAccessNumbers'">V0936</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'processingType'">VI002</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountType'">V0097</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'reconfigurationReason'">VI008</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber1'">V0001</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber2' and $serviceType != 'voiceBasis'">V0070</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber3' and $serviceType != 'voiceBasis'">V0071</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber4' and $serviceType != 'voiceBasis'">V0072</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber5' and $serviceType != 'voiceBasis'">V0073</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber6' and $serviceType != 'voiceBasis'">V0074</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber7' and $serviceType != 'voiceBasis'">V0075</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber8' and $serviceType != 'voiceBasis'">V0076</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber9' and $serviceType != 'voiceBasis'">V0077</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber10' and $serviceType != 'voiceBasis'">V0078</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber1'">V0976</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber2' and $serviceType != 'voiceBasis'">V0977</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber3' and $serviceType != 'voiceBasis'">V0978</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber4' and $serviceType != 'voiceBasis'">V0979</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber5' and $serviceType != 'voiceBasis'">V0980</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber6' and $serviceType != 'voiceBasis'">V0981</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber7' and $serviceType != 'voiceBasis'">V0982</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber8' and $serviceType != 'voiceBasis'">V0983</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber9' and $serviceType != 'voiceBasis'">V0984</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber10' and $serviceType != 'voiceBasis'">V0985</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount1'">VI011</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount2' and $serviceType != 'voiceBasis'">VI012</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount3' and $serviceType != 'voiceBasis'">VI013</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount4' and $serviceType != 'voiceBasis'">VI014</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount5' and $serviceType != 'voiceBasis'">VI015</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount6' and $serviceType != 'voiceBasis'">VI016</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount7' and $serviceType != 'voiceBasis'">VI017</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount8' and $serviceType != 'voiceBasis'">VI018</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount9' and $serviceType != 'voiceBasis'">VI019</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'voipAccount10' and $serviceType != 'voiceBasis'">VI020</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'mailboxAlias'">VI051</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'networkElementId'">Z0100</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldLocalExchangeCarrier'">V0060</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldInterExchangeCarrier'">V0062</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'localAreaCode'">V0124</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'newAccessNumberType'">VI082</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'remarks'">V0008</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner1'">V0127</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner2'">V0129</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwnerAddress'">V0126</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountID'">V0162</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'projectOrderIndicator'">V0104</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'salesSegment'">V0105</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'customerCallBackNumber'">V0125</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'fixedOrderDateIndicator'">V0140</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'automaticMailingIndicator'">V0131</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'activationType'">V0133</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'technicalServiceId'">V0152</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'technicalServiceGroup'">V0154</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'customerCommunication'">V0216</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'orderVariant'">V0810</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'asb'">V0934</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'mailboxAlias'">VI051</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldCustomerNumber'">V0945</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode1OP'">V0165</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode2OP'">V0166</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode3OP'">V0167</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode4OP'">V0168</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode5OP'">V0169</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode6OP'">V0170</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode7OP'">V0171</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode8OP'">V0172</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode9OP'">V0173</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'portingMode10OP'">V0174</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'newLocalExchangeCarrierOP'">V0061</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberChangeAnnouncementIndicator'">V0217</xsl:when> 
    <xsl:when test="request-param[@name='parameterName'] = 'billingAccountNumber'and $serviceType != 'voiceBasis'">V1002</xsl:when>   
  </xsl:choose>
</xsl:variable>
<xsl:variable name="addressType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">LOKA</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="anotherServiceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner1'">V0128</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner2'">V0130</xsl:when>
  </xsl:choose>
</xsl:variable>
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
    <xsl:when test="request-param[@name='parameterName'] = 'fixedOrderDateIndicator'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'true'">Ja</xsl:when>
        <xsl:otherwise>Nein</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'automaticMailingIndicator'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'true'">J</xsl:when>
        <xsl:otherwise>N</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'projectOrderIndicator'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'true'">ja</xsl:when>
        <xsl:otherwise>nein</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberChangeAnnouncementIndicator'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'true'">Abschalteanordnung</xsl:when>
        <xsl:otherwise>keine</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$valueToUse"/>
    </xsl:otherwise>    
  </xsl:choose>
</xsl:variable>
