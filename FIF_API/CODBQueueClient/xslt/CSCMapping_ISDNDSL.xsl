<xsl:variable name="dataType">STRING</xsl:variable>
<xsl:variable name="serviceCharCode">
  <xsl:choose>
    <xsl:when test="request-param[@name='parameterName'] = 'upstreamBandwidth'">V0092</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'allowBandwidthDowngrade'">V0875</xsl:when>
    <xsl:when test="request-param[@name='parameterName'] = 'desiredBandwidth'">V0876</xsl:when>        
    <xsl:when test="request-param[@name='parameterName'] = 'DSLBandwidth'">V0826</xsl:when>            
    <xsl:when test="request-param[@name='parameterName'] = 'changeToUR2'">V0878</xsl:when>           
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
    <xsl:when test="request-param[@name='parameterName'] = 'allowBandwidthDowngrade' or
      request-param[@name='parameterName'] = 'changeToUR2'">
      <xsl:choose>
        <xsl:when test="$valueToUse = 'true'">Ja</xsl:when>
        <xsl:otherwise>Nein</xsl:otherwise>
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
        <xsl:otherwise>unknown</xsl:otherwise>
      </xsl:choose>      
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$valueToUse"/>
    </xsl:otherwise>    
  </xsl:choose>
</xsl:variable>
