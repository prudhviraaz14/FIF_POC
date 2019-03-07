<xsl:variable name="dataType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'serviceLocation'">SERVICE_LOCATION</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'asb'">INTEGER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DSLIndicator'">BOOLEAN</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'numberOfNewAccessNumbers'">INTEGER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner1'">LINEOWNER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner2'">LINEOWNER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">ADDRESS</xsl:when>
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
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwnerAddress'">ADDRESS</xsl:when>
    <xsl:otherwise>STRING</xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'networkElementId'">Z0100</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DSLIndicator'">V0090</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'iadPin'">V0153</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'carrier'">V0081</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldAccess'">V0094</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'automaticMailingIndicator'">V0131</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'serviceLocation'">V0015</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'serviceProvider'">V0088</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'projectOrderIndicator'">V0104</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'salesSegment'">V0105</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationTAE'">V0123</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'localAreaCode'">V0124</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineType'">V0138</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'specialTimeWindow'">V0139</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'fixedOrderDateIndicator'">V0140</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountType'">V0097</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountID'">V0162</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineTakeover'">V0214</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'orderVariant'">V0810</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'asb'">V0934</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldCustomerNumber'">V0945</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DSLBandwidth'">V0093</xsl:when>            
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">V0014</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineID'">V0144</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'numberOfNewAccessNumbers'">V0936</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'reconfigurationReason'">V0943</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'processingType'">V0971</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'activationTime'">V0940</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'acsIndicator'">V0196</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'remarks'">V0008</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'instantAccessVariant'">V8003</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'multimediaPort'">I1323</xsl:when>    
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
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner1'">V0127</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner2'">V0129</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwnerAddress'">V0126</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'responsibleRegion'">V0012</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'responsibleDepartment'">V0013</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldLocalExchangeCarrier'">V0060</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldInterExchangeCarrier'">V0062</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'customerCallBackNumber'">V0125</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'activationType'">V0133</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'technicalServiceId'">V0152</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'technicalServiceGroup'">V0154</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'customerCommunication'">V0216</xsl:when>
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
    <xsl:when test="request-param[@name='parameterName'] = 'providerContractNumber'">I1325</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DTAGContractNumber'">I1325</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DTAGOrderNumber'">I1326</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'providerCompletionDate'">VI062</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DTAGCompletionDate'">VI062</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'providerPaymentDate'">I1327</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DTAGPaymentDate'">I1327</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'dtagFreeText'">V0141</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'witaUsage'">V010B</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'newLocalExchangeCarrierWitaIndicator'">V010C</xsl:when> 
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
    <xsl:when test="request-param[@name='parameterName'] = 'lineTakeover' or 
      request-param[@name='parameterName'] = 'fixedOrderDateIndicator' or 
      request-param[@name='parameterName'] = 'acsIndicator'">
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
    <xsl:when test="request-param[@name='parameterName'] = 'DSLIndicator'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'true'">Y</xsl:when>
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
    <xsl:when test="request-param[@name='parameterName'] = 'DSLBandwidth'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'V0115'">Standard</xsl:when>
        <xsl:when test="$valueToUse = 'V0133'">Standard</xsl:when>
        <xsl:when test="$valueToUse = 'V0179'">Standard</xsl:when>
        <xsl:when test="$valueToUse = 'V0116'">Premium</xsl:when>
        <xsl:when test="$valueToUse = 'V0118'">DSL 1000</xsl:when>
        <xsl:when test="$valueToUse = 'V0117'">DSL 1000</xsl:when>
        <xsl:when test="$valueToUse = 'V0174'">DSL 2000</xsl:when>
        <xsl:when test="$valueToUse = 'V0175'">DSL 3000</xsl:when>
        <xsl:when test="$valueToUse = 'V0176'">DSL 3000</xsl:when>
        <xsl:when test="$valueToUse = 'V0177'">DSL 3000</xsl:when>
        <xsl:when test="$valueToUse = 'V0178'">DSL 6000</xsl:when>
        <xsl:when test="$valueToUse = 'V0180'">DSL 6000</xsl:when>
        <xsl:when test="$valueToUse = 'V018A'">DSL 6000</xsl:when>
        <xsl:when test="$valueToUse = 'V018B'">DSL 6000</xsl:when>
        <xsl:when test="$valueToUse = 'V018C'">DSL 16000</xsl:when>
        <xsl:when test="$valueToUse = 'V018D'">DSL 16000</xsl:when>
        <xsl:when test="$valueToUse = 'V018G'">DSL 16000</xsl:when>
        <xsl:when test="$valueToUse = 'V018H'">DSL 16000</xsl:when>
        <xsl:otherwise>unknown</xsl:otherwise>
      </xsl:choose>      
    </xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldAccess'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'NEW'">keiner</xsl:when>
        <xsl:when test="$valueToUse = 'ANALOG'">analog</xsl:when>
        <xsl:when test="$valueToUse = 'DIGITAL'">digital</xsl:when>
        <xsl:when test="$valueToUse = 'P2MP'">Mehrgeräteanschluss</xsl:when>
        <xsl:when test="$valueToUse = 'P2P'">Anlagenanschluss</xsl:when>
        <xsl:when test="$valueToUse = 'PRI'">Primärmultiplexanschluss</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$valueToUse"/>
        </xsl:otherwise>
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
