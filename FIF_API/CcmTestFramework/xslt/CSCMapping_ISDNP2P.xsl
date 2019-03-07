<xsl:variable name="dataType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'serviceLocation'">SERVICE_LOCATION</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'asb'">INTEGER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DSLIndicator'">BOOLEAN</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'numberOfNewAccessNumbers'">INTEGER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner1'">LINEOWNER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner2'">LINEOWNER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">ADDRESS</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange1'">ACC_NUM_RANGE</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange2'">ACC_NUM_RANGE</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange3'">ACC_NUM_RANGE</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwnerAddress'">ADDRESS</xsl:when>
    <xsl:otherwise>STRING</xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'networkElementId'">Z0100</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DSLIndicator'">V0090</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'carrier'">V0081</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldAccess'">V0094</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'automaticMailingIndicator'">V0131</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'serviceLocation'">V0015</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'centralNumber'">V0016</xsl:when>
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
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">V0014</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineID'">V0144</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'numberOfNewAccessNumbers'">V0936</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'reconfigurationReason'">V0943</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'processingType'">V0971</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'activationTime'">V0940</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'remarks'">V0008</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange1'">V0002</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange2'">W9002</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange3'">W9003</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumberRange1'">V0986</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumberRange2'">V0987</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumberRange3'">V0988</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner1'">V0127</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner2'">V0129</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwnerAddress'">V0126</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'responsibleRegion'">V0012</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'responsibleDepartment'">V0013</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldLocalExchangeCarrier'">V0060</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldInterExchangeCarrier'">V0062</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'activationType'">V0133</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'technicalServiceId'">V0152</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'customerCommunication'">V0216</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberChangeAnnouncementIndicator'">V0217</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'providerContractNumber'">I1325</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DTAGContractNumber'">I1325</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DTAGOrderNumber'">I1326</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'providerCompletionDate'">VI062</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DTAGCompletionDate'">VI062</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'providerPaymentDate'">I1327</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DTAGPaymentDate'">I1327</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'dtagFreeText'">V0141</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'provisioningDiscount'">V0149</xsl:when> 
    <xsl:when test="request-param[@name='parameterName'] = 'witaUsage'">V010B</xsl:when> 
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
