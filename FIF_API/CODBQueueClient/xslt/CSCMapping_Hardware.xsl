<xsl:variable name="dataType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'orderReason'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'sapOrderId' and ($serviceCode='V011A' or $serviceCode='I1359' or $serviceCode='I135A')">STRING</xsl:when>   
    <xsl:when test="request-param[@name='parameterName'] = 'articleNumber'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'articleName'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'serialNumber'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'simSerialNumber'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'subventionIndicator'
                    or request-param[@name='parameterName'] = 'subventionCode'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'checkingNumber'">DECIMAL</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'shippingCosts'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'salesOrganisationNumber'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'serviceProvider'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'zeroChargeIndicator'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'imei'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'sapActionCode'">STRING</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'salutationDescription'">DELIVERYNAME</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'hardwareRecipient'">DELIVERYNAME</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'hardwareMailingAddress'">ADDRESS</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'deliveryNoteNumber'">STRING</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'deliveryDate'">STRING</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'quantity' and $serviceCode='VI041'">INTEGER</xsl:when>    
  </xsl:choose>
</xsl:variable>

<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'orderReason'">V0989</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'sapOrderId' and ($serviceCode='V011A' or $serviceCode='I1359'or $serviceCode='I135A')">I1336</xsl:when>   
    <xsl:when test="request-param[@name='parameterName'] = 'articleNumber'">V0112</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'articleName'">V0116</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'serialNumber'">V0109</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'simSerialNumber'">V0108</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'subventionIndicator'
                    or request-param[@name='parameterName'] = 'subventionCode'">V0114</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'checkingNumber'">V0117</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'shippingCosts'">V0119</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'salesOrganisationNumber'">V0990</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'serviceProvider'">V0088</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'zeroChargeIndicator'">V0184</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'imei'">I1337</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'sapActionCode'">I1338</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'salutationDescription'">V0110</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'hardwareRecipient'">V0110</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'hardwareMailingAddress'">V0111</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'deliveryNoteNumber'">V0884</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'deliveryDate'">V0885</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'quantity' and $serviceCode='VI041'">VI115</xsl:when>    
  </xsl:choose>
</xsl:variable>

<xsl:variable name="addressType">HARD</xsl:variable>
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
    <xsl:when test="request-param[@name='parameterName'] = 'deliveryDate'">
      <xsl:variable name="deliveryDateOPM"
        select="dateutils:SOM2OPMDate(request-param[@name='configuredValue'])"/>
      <xsl:value-of select="$deliveryDateOPM"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$valueToUse"/>
    </xsl:otherwise>    
  </xsl:choose>
</xsl:variable>

