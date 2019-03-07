<xsl:variable name="dataType">
  <xsl:choose>
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
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber1'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber2'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber3'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber4'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber5'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber6'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber7'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber8'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber9'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber10'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange1'">ACC_NUM_RANGE</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange2'">ACC_NUM_RANGE</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange3'">ACC_NUM_RANGE</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumberRange1'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumberRange2'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumberRange3'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'networkElementId'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'consumerGuidingCondition'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'responsibleRegion'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'responsibleDepartment'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'serviceLocation'">SERVICE_LOCATION</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'centralNumber'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldLocalExchangeCarrier'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldInterExchangeCarrier'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationTAE'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'localAreaCode'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'numberOfOldLines'">INTEGER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'newAccessNumberType'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'numberOfNewAccessNumbers'">INTEGER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oneGroupID'">TECH_SERVICE_ID</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'siteType'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'splitNumberRangeIndicator'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'projectFlag'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'siteID'">TECH_SERVICE_ID</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'technicalServiceId'">TECH_SERVICE_ID</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'remarks'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner1'">LINEOWNER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner2'">LINEOWNER</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">ADDRESS</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwnerAddress'">ADDRESS</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'networkElementId'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountType'">STRING</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountID'">STRING</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber1'">V0001</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber2'">V0070</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber3'">V0071</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber4'">V0072</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber5'">V0073</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber6'">V0074</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber7'">V0075</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber8'">V0076</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber9'">V0077</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumber10'">V0078</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber1'">V0976</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber2'">V0977</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber3'">V0978</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber4'">V0979</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber5'">V0980</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber6'">V0981</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber7'">V0982</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber8'">V0983</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber9'">V0984</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumber10'">V0985</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange1'">V0002</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange2'">W9002</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'accessNumberRange3'">W9003</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumberRange1'">V0986</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumberRange2'">V0987</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'ownerAccessNumberRange3'">V0988</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'networkElementId'">Z0100</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'consumerGuidingCondition'">GC004</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'responsibleRegion'">V0012</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'responsibleDepartment'">V0013</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'serviceLocation'">V0015</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'centralNumber'">V0016</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldLocalExchangeCarrier'">V0060</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oldInterExchangeCarrier'">V0062</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationTAE'">V0123</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'localAreaCode'">V0124</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'numberOfOldLines'">V0132</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'newAccessNumberType'">VI082</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'numberOfNewAccessNumbers'">V0936</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oneGroupID'">VI086</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'siteType'">VI072</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'splitNumberRangeIndicator'">VI077</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'projectFlag'">VI081</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'siteID'">VI078</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'technicalServiceId'">VI080</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'remarks'">V0008</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner1'">V0127</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner2'">V0129</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">V0014</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwnerAddress'">V0126</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'networkElementId'">Z0100</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountType'">V0097</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'discountID'">V0162</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="addressType">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'locationAddress'">LOKA</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwnerAddress'">ANSC</xsl:when>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="anotherServiceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner1'">V0128</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'lineOwner2'">V0130</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'oneGroupID'">VI071</xsl:when>
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
    <xsl:when test="request-param[@name='parameterName'] = 'projectFlag'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'true'">ja</xsl:when>
        <xsl:otherwise>nein</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'splitNumberRangeIndicator'">
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
