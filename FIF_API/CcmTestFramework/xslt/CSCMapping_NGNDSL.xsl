<xsl:variable name="dataType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">ADDRESS</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'dialInAccountName'">USER_ACCOUNT_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'asb'">INTEGER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'serviceLocation'">SERVICE_LOCATION</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'localAreaCode'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'disableInternetUsageIndicator'">BOOLEAN</xsl:when>
    <xsl:otherwise>STRING</xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">V0014</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'serviceLocation'">V0015</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'reconfigurationReason'">V0943</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'instantAccessVariant'">V8003</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'processingType'">V0971</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'multimediaPort'">I1323</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'carrier'">V0081</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountID'">V0162</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountType'">V0097</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'dialInAccountName'">I9058</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'upstreamBandwidth'">V0092</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'desiredBandwidth'">V0876</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'allowBandwidthDowngrade'">V0875</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DSLBandwidth'">V0826</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineID'">V0144</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'iadPin'">V0153</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldAccess'">V0094</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineType'">V0138</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationTAE'">V0123</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'asb'">V0934</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'localAreaCode'">V0124</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessTechnology'">V009C</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'customerCommunication'">V0216</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'serviceProvider'">V0088</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'networkElementId'">Z0100</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'projectOrderIndicator'">V0104</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'salesSegment'">V0105</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'automaticMailingIndicator'">V0131</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'specialTimeWindow'">V0139</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'fixedOrderDateIndicator'">V0140</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'technicalServiceId'">V0152</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineTakeover'">V0214</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'orderVariant'">V0810</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'relocationVariant'">V2024</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldCustomerNumber'">V0945</xsl:when>
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
    <xsl:when test="request-param[@name='parameterName'] = 'billingAccountNumber'">V1002</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ngabLineID'">I1020</xsl:when>  
    <xsl:when test="request-param[@name='parameterName'] = 'disableInternetUsageIndicator'">I0104</xsl:when>
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
    <xsl:when test="request-param[@name='parameterName'] = 'automaticMailingIndicator'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'true'">J</xsl:when>
        <xsl:otherwise>N</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineTakeover' or
      request-param[@name='parameterName'] = 'fixedOrderDateIndicator' or
      request-param[@name='parameterName'] = 'allowBandwidthDowngrade'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'true'">Ja</xsl:when>
        <xsl:otherwise>Nein</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'projectOrderIndicator'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'true'">ja</xsl:when>
        <xsl:otherwise>nein</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'upstreamBandwidth'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'V0197'">384</xsl:when>
        <xsl:when test="$valueToUse = 'V0198'">384</xsl:when>
        <xsl:when test="$valueToUse = 'V0199'">512</xsl:when>
        <xsl:otherwise>Standard</xsl:otherwise>
      </xsl:choose>      
    </xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'disableInternetUsageIndicator'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'true'">Y</xsl:when>
        <xsl:otherwise>N</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'desiredBandwidth'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'V0115'">DSL 1000</xsl:when>
        <xsl:when test="$valueToUse = 'V0179'">Standard</xsl:when>
        <xsl:when test="$valueToUse = 'V0116'">Premium</xsl:when>
        <xsl:when test="$valueToUse = 'V0118'">DSL 1000</xsl:when>
        <xsl:when test="$valueToUse = 'V0117'">DSL 1000</xsl:when>
        <xsl:when test="$valueToUse = 'V0174'">DSL 2000</xsl:when>
        <xsl:when test="$valueToUse = 'V0175'">DSL 3000</xsl:when>
        <xsl:when test="$valueToUse = 'V0176'">DSL 4000</xsl:when>
        <xsl:when test="$valueToUse = 'V0177'">DSL 4000</xsl:when>
        <xsl:when test="$valueToUse = 'V0178'">DSL 6000</xsl:when>
        <xsl:when test="$valueToUse = 'V0180'">DSL 6000</xsl:when>
        <xsl:when test="$valueToUse = 'V018A'">DSL 6000</xsl:when>
        <xsl:when test="$valueToUse = 'V018B'">DSL 6000</xsl:when>
        <xsl:when test="$valueToUse = 'V018C'">DSL 16000</xsl:when>
        <xsl:when test="$valueToUse = 'V018D'">DSL 16000</xsl:when>
        <xsl:when test="$valueToUse = 'V018G'">DSL 25000</xsl:when>
        <xsl:when test="$valueToUse = 'V018H'">DSL 50000</xsl:when>
        <xsl:when test="$valueToUse = 'V018N'">DSL 100000</xsl:when>
        <xsl:otherwise>unknown</xsl:otherwise>
      </xsl:choose>      
    </xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DSLBandwidth'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'V0115'">DSL 1000</xsl:when>
        <xsl:when test="$valueToUse = 'V0179'">Standard</xsl:when>
        <xsl:when test="$valueToUse = 'V0116'">Premium</xsl:when>
        <xsl:when test="$valueToUse = 'V0118'">DSL 1000</xsl:when>
        <xsl:when test="$valueToUse = 'V0117'">DSL 1500</xsl:when>
        <xsl:when test="$valueToUse = 'V0174'">DSL 2000</xsl:when>
        <xsl:when test="$valueToUse = 'V0175'">DSL 3000</xsl:when>
        <xsl:when test="$valueToUse = 'V0176'">DSL 4000</xsl:when>
        <xsl:when test="$valueToUse = 'V0177'">DSL 4000</xsl:when>
        <xsl:when test="$valueToUse = 'V0178'">DSL 6000</xsl:when>
        <xsl:when test="$valueToUse = 'V0180'">DSL 6000</xsl:when>
        <xsl:when test="$valueToUse = 'V018A'">DSL 6000</xsl:when>
        <xsl:when test="$valueToUse = 'V018B'">DSL 6000</xsl:when>
        <xsl:when test="$valueToUse = 'V018C'">DSL 16000</xsl:when>
        <xsl:when test="$valueToUse = 'V018D'">DSL 16000</xsl:when>
        <xsl:when test="$valueToUse = 'V018G'">DSL 25000</xsl:when>
        <xsl:when test="$valueToUse = 'V018H'">DSL 50000</xsl:when>
        <xsl:when test="$valueToUse = 'V018N'">DSL 100000</xsl:when>
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
