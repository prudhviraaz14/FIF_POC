<xsl:variable name="dataType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'multimediaPort'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'simSerialNumber'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'instantAcess'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'imsi'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'iadPin'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'carrier'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'serviceProvider'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'projectOrderIndicator'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'salesSegment'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'localAreaCode'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountType'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountID'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'orderVariant'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'allowBandwidthDowngrade'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'asb'">INTEGER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldCustomerNumber'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'desiredBandwidth'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DSLBandwidth'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">ADDRESS</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineID'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'mobileAccessNumber'">MOBIL_ACCESS_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'simPuk'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'technicalServiceGroup'">STRING</xsl:when>
    <xsl:otherwise>STRING</xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'multimediaPort'">I1323</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'simSerialNumber'">V0108</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'instantAcess'">V8003</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'imsi'">VI074</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'iadPin'">V0153</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'carrier'">V0081</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'serviceProvider'">V0088</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'projectOrderIndicator'">V0104</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'salesSegment'">V0105</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'localAreaCode'">V0124</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountType'">V0097</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountID'">V0162</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'orderVariant'">V0810</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'allowBandwidthDowngrade'">V0875</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'asb'">V0934</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldCustomerNumber'">V0945</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'desiredBandwidth'">V0876</xsl:when>        
    <xsl:when test="request-param[@name='parameterName'] = 'DSLBandwidth'">V0826</xsl:when>            
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">V0014</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineID'">V0144</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'mobileAccessNumber'">V0180</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'simPuk'">V0179</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'technicalServiceGroup'">V0154</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'relocationVariant'">V2024</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'processingType'">V0971</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'billingAccountNumber'">V1002</xsl:when>
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

    <xsl:when test="request-param[@name='parameterName'] = 'allowBandwidthDowngrade'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'true'">Ja</xsl:when>
        <xsl:otherwise>Nein</xsl:otherwise>
      </xsl:choose>      
    </xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'desiredBandwidth'
      or request-param[@name='parameterName'] = 'DSLBandwidth'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'V017E'">LTE 1200</xsl:when>
        <xsl:when test="$valueToUse = 'V018J'">LTE 1200 Outdoor</xsl:when>
        <xsl:when test="$valueToUse = 'V017J'">LTE 3600</xsl:when>
        <xsl:when test="$valueToUse = 'V018O'">LTE 3600 Outdoor</xsl:when>
        <xsl:when test="$valueToUse = 'V017K'">LTE 7200</xsl:when>
        <xsl:when test="$valueToUse = 'V018P'">LTE 7200 Outdoor</xsl:when>
        <xsl:when test="$valueToUse = 'V017L'">LTE 21600</xsl:when>
        <xsl:when test="$valueToUse = 'V018Q'">LTE 21600 Outdoor</xsl:when>
        <xsl:when test="$valueToUse = 'V017M'">LTE 50000</xsl:when>
        <xsl:when test="$valueToUse = 'V018R'">LTE 50000 Outdoor</xsl:when>        
        <xsl:otherwise>unknown</xsl:otherwise>
      </xsl:choose>      
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$valueToUse"/>
    </xsl:otherwise>    
  </xsl:choose>
</xsl:variable>
