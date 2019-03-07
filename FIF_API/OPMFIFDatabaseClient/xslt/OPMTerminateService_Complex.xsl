<xsl:element name="Command_List">
  
  <!-- Generate a FIF date that is one day before the termination date -->
  <xsl:variable name="oneDayBefore"
    select="dateutils:createFIFDateOffset(request-param[@name='TERMINATION_DATE'], 'DATE', '-1')"/>
  <!-- Convert the termination date to OPM format -->
  <xsl:variable name="terminationDateOPM"
    select="dateutils:createOPMDate(request-param[@name='TERMINATION_DATE'])"/>
  
  <xsl:if test="request-param[@name='PRODUCT_CODE'] = ''">
    <xsl:element name="CcmFifRaiseErrorCmd">
      <xsl:element name="command_id">prod_code_not_provided</xsl:element>
      <xsl:element name="CcmFifRaiseErrorInCont">
        <xsl:element name="error_text">No product code provided for complex termination</xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:if>
  
  <xsl:if test="request-param[@name='PRODUCT_CODE'] = 'I1204'
    or request-param[@name='PRODUCT_CODE'] = 'I1203'
    or request-param[@name='PRODUCT_CODE'] = 'I1208'">
    
    <xsl:element name="CcmFifRaiseErrorCmd">
      <xsl:element name="command_id">wrong_product_code_error</xsl:element>
      <xsl:element name="CcmFifRaiseErrorInCont">
        <xsl:element name="error_text">Please use for the termiation of the bundle the voice product code!</xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:if>
  
  <xsl:if test="request-param[@name='PRODUCT_CODE'] != 'VI001' 
    and request-param[@name='PRODUCT_CODE'] != 'I1201' 
    and (request-param[@name='PRODUCT_CODE'] = 'V0002'
        or request-param[@name='PRODUCT_CODE'] = 'I1204'
        or request-param[@name='PRODUCT_CODE'] = 'VI202'
        or request-param[@name='PRODUCT_CODE'] = 'VI208'
        or request-param[@name='PRODUCT_CODE'] = 'VI203')">
    &TerminateService_SOM; 
  </xsl:if>	
 
  <!-- 
  <xsl:if test="request-param[@name='PRODUCT_CODE'] = 'VI203'">
    
      Use OP/OPM for the termination of Bitstream bundle

    &TerminateService_Bit;
  </xsl:if>
   -->
  
  <xsl:if test="request-param[@name='PRODUCT_CODE'] = 'I1201'">		  
    &TerminateServ_Resale; 
  </xsl:if>
  
  <xsl:if test="request-param[@name='PRODUCT_CODE'] = 'VI001'">		  
    &TerminateServ_Call;
  </xsl:if>
  
</xsl:element>		
