<xsl:variable name="dataType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">ADDRESS</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'dialInAccountName'">USER_ACCOUNT_NUM</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'asb'">INTEGER</xsl:when>
    <xsl:otherwise>STRING</xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'tenderArea'">I0015</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ngabLineID'">I1020</xsl:when>  
    <xsl:when test="request-param[@name='parameterName'] = 'multimediaPort'">I1323</xsl:when>    
    <xsl:when test="request-param[@name='parameterName'] = 'DTAGOrderNumber'">I1326</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'dialInAccountName'">I9058</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">V0014</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'carrier'">V0081</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'serviceProvider'">V0088</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'upstreamBandwidth'">V0092</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountType'">V0097</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessTechnology'">V009C</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'projectOrderIndicator'">V0104</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'salesSegment'">V0105</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationTAE'">V0123</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'localAreaCode'">V0124</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineType'">V0138</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'specialTimeWindow'">V0139</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'dtagFreeText'">V0141</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'technicalServiceId'">V0152</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'iadPin'">V0153</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountID'">V0162</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineTakeover'">V0214</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'customerCommunication'">V0216</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'DSLBandwidth'">V0826</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'resultDate'">V0909</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'asb'">V0934</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldCustomerNumber'">V0945</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'billingAccountNumber'">V1002</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'providerCompletionDate'">VI062</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'networkElementId'">Z0100</xsl:when>
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
    <xsl:when test="request-param[@name='parameterName'] = 'lineTakeover'">
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
    <xsl:when test="request-param[@name='parameterName'] = 'DSLBandwidth'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'IG001'">Glasfaser 50</xsl:when>
        <xsl:when test="$valueToUse = 'IG002'">Glasfaser 100</xsl:when>
        <xsl:when test="$valueToUse = 'IG003'">Glasfaser 250</xsl:when>
        <xsl:when test="$valueToUse = 'IG004'">Glasfaser 500</xsl:when>
        <xsl:when test="$valueToUse = 'IG005'">Glasfaser 750</xsl:when>
        <xsl:when test="$valueToUse = 'IG006'">Glasfaser 1000</xsl:when>
        <xsl:when test="$valueToUse = 'IG007'">Glasfaser 1500</xsl:when>
        <xsl:when test="$valueToUse = 'IG008'">Glasfaser 2000</xsl:when>
        <xsl:otherwise>unknown</xsl:otherwise>
      </xsl:choose>      
    </xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'providerCompletionDate'">
      <xsl:value-of select="dateutils:SOM2OPMDate($valueToUse)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$valueToUse"/>
    </xsl:otherwise>    
  </xsl:choose>
</xsl:variable>
