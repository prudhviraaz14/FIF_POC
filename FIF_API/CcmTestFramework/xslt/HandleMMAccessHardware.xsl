  
    <!-- Find Set Top Box Service -->
    <xsl:element name="CcmFifFindServiceSubsCmd">
      <xsl:element name="command_id">find_hardware_service</xsl:element>
      <xsl:element name="CcmFifFindServiceSubsInCont">
        <xsl:element name="product_subscription_id_ref">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="field_name">product_subscription_id</xsl:element>
        </xsl:element>  
        <xsl:element name="service_code">I1359</xsl:element> 
        <xsl:element name="no_service_error">N</xsl:element>         
        <xsl:element name="target_state">RENTED_LEASED</xsl:element>                   
      </xsl:element>
    </xsl:element>
  
    <!-- Reconfigure Service Subscription for DSL Product -->
    <xsl:element name="CcmFifReconfigServiceCmd">
      <xsl:element name="command_id">reconf_hardware_service</xsl:element>
      <xsl:element name="CcmFifReconfigServiceInCont">
        <xsl:element name="service_subscription_ref">
          <xsl:element name="command_id">find_hardware_service</xsl:element>
          <xsl:element name="field_name">service_subscription_id</xsl:element>
        </xsl:element>
        <xsl:element name="desired_schedule_type">ASAP</xsl:element>
        <xsl:element name="reason_rd">AEND</xsl:element>
        <xsl:element name="service_characteristic_list">
          <!-- Bestellgrund-->
          <xsl:if test="request-param[@name='keepMMAccessHardware'] = 'Y'">
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0989</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Doku - Kein Versand</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='keepMMAccessHardware'] != 'Y'">
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0989</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Rückgabe Settop-Box</xsl:element>
            </xsl:element>
          </xsl:if>
          <!-- I1335 Ausgleichszahlung für Settopbox bei Nichtrücksendung-->
          <xsl:if test="request-param[@name='compensationFee']!= ''">
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1335</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='compensationFee']"/>
              </xsl:element>
            </xsl:element>
          </xsl:if>                    
        </xsl:element>      
        <xsl:element name="process_ind_ref">
          <xsl:element name="command_id">find_hardware_service</xsl:element>
          <xsl:element name="field_name">service_found</xsl:element>
        </xsl:element>
        <xsl:element name="required_process_ind">Y</xsl:element>  
      </xsl:element>
    </xsl:element> 
