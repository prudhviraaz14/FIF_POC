<xsl:variable name="dataType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'serviceLocation'">SERVICE_LOCATION</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'asb'">INTEGER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'numberOfNewAccessNumbers'">INTEGER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">ADDRESS</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange1'">ACC_NUM_RANGE</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange2'">ACC_NUM_RANGE</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange3'">ACC_NUM_RANGE</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'entryTimeBackOffice'">DATE</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'entryTimeAKS'">DATE</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'desiredDate'">DATE</xsl:when> 
    <xsl:when test="request-param[@name='parameterName'] = 'technicalServiceId'">USER_ACCOUNT_NUM</xsl:when>
    <xsl:otherwise>STRING</xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'primaryCustSignDate'">A0030</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineTypeOP'">A0040</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'entryTimeBackOffice'">A0060</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'entryTimeAKS'">A0065</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'desiredDate'">A0070</xsl:when> 
    <xsl:when test="request-param[@name='parameterName'] = 'fixedOrderDateIndicator'">A0075</xsl:when> 
    <xsl:when test="request-param[@name='parameterName'] = 'networkElementId'">Z0100</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'carrier'">V0081</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'serviceLocation'">V0015</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'centralNumber'">V0016</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'asb'">V0934</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">V0014</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'numberOfNewAccessNumbers'">V0936</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'remarks'">V0008</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange1'">V0002</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange2'">W9002</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange3'">W9003</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'responsibleRegion'">V0012</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'responsibleDepartment'">V0013</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldLocalExchangeCarrierOP'">V0060</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldInterExchangeCarrierOP'">V0062</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'technicalServiceId'">A0050</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'customerCommunication'">V0216</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberChangeAnnouncementIndicator'">V0217</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'provisioningDiscount'">V0149</xsl:when> 
    <xsl:when test="request-param[@name='parameterName'] = 'opProcessingType'">V0018</xsl:when> 
    <xsl:when test="request-param[@name='parameterName'] = 'processingType'">V0971</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'activationTime'">V0940</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'relocationVariant'">V2024</xsl:when> 
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
    <xsl:when test="request-param[@name='parameterName'] = 'technicalServiceId'">V0152</xsl:when>
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
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberChangeAnnouncementIndicator'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'true'">Abschalteanordnung</xsl:when>
        <xsl:otherwise>keine</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'primaryCustSignDate' or
      request-param[@name='parameterName'] = 'entryTimeBackOffice' or
      request-param[@name='parameterName'] = 'entryTimeAKS' or
      request-param[@name='parameterName'] = 'desiredDate'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'today'">
          <xsl:value-of select="dateutils:createOPMDate(dateutils:getCurrentDate())"/>          
        </xsl:when>
        <xsl:when test="$valueToUse != ''">
          <xsl:value-of select="dateutils:SOM2OPMDate($valueToUse)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$valueToUse"/>
    </xsl:otherwise>    
  </xsl:choose>
</xsl:variable>
