
<!-- get GCI entry for articleNumber to retrieve the billing name -->
<xsl:element name="CcmFifValidateGeneralCodeItemCmd">
  <xsl:element name="command_id">find_article_name</xsl:element>
  <xsl:element name="CcmFifValidateGeneralCodeItemInCont">
    <xsl:element name="group_code">HW_ART_DES</xsl:element>
    <xsl:element name="value">
      <xsl:value-of select="request-param[@name='articleNumber']"/>
    </xsl:element>
    <xsl:element name="raise_error_if_invalid">Y</xsl:element>
  </xsl:element>
</xsl:element>

<!-- Add surcharge service V0850 -->
<xsl:element name="CcmFifAddServiceSubsCmd">
  <xsl:element name="command_id">add_service_surcharge</xsl:element>
  <xsl:element name="CcmFifAddServiceSubsInCont">
    <xsl:element name="product_subscription_ref">
      <xsl:element name="command_id">find_main_service</xsl:element>
      <xsl:element name="field_name">product_subscription_id</xsl:element>
    </xsl:element>
    <xsl:element name="service_code">V0850</xsl:element>
    <xsl:element name="parent_service_subs_ref">
      <xsl:element name="command_id">add_hardware_service</xsl:element>
      <xsl:element name="field_name">service_subscription_id</xsl:element>
    </xsl:element>
    <xsl:element name="desired_schedule_type">ASAP</xsl:element>
    <xsl:element name="reason_rd_ref">
      <xsl:element name="command_id">get_stp_data_1</xsl:element>
      <xsl:element name="field_name">reason_rd</xsl:element>
    </xsl:element>
    <xsl:element name="account_number_ref">
      <xsl:element name="command_id">find_main_service</xsl:element>
      <xsl:element name="field_name">account_number</xsl:element>
    </xsl:element>
    <xsl:element name="service_characteristic_list">
      <!--  Hardware Artikelnummer -->
      <xsl:element name="CcmFifConfiguredValueCont">
        <xsl:element name="service_char_code">V0880</xsl:element>
        <xsl:element name="data_type">STRING</xsl:element>
        <xsl:element name="configured_value">
          <xsl:value-of select="request-param[@name='articleNumber']"/>
        </xsl:element>
      </xsl:element>
      <!--  Hardware Bezeichnung -->
      <xsl:element name="CcmFifConfiguredValueCont">
        <xsl:element name="service_char_code">V0881</xsl:element>
        <xsl:element name="data_type">STRING</xsl:element>
        <xsl:element name="configured_value_ref">
          <xsl:element name="command_id">find_article_name</xsl:element>
          <xsl:element name="field_name">description</xsl:element>
        </xsl:element>
      </xsl:element>
      <!--  Unterdrückung Einmalpreis -->
      <xsl:element name="CcmFifConfiguredValueCont">
        <xsl:element name="service_char_code">V0882</xsl:element>
        <xsl:element name="data_type">STRING</xsl:element>
        <xsl:element name="configured_value">
          <xsl:value-of select="request-param[@name='suppressOneTimeCharge']"/>
        </xsl:element>
      </xsl:element>
      <!-- Z0100 -->
      <xsl:if test="request-param[@name='networkElementId']!= ''">
        <xsl:element name="CcmFifConfiguredValueCont">
          <xsl:element name="service_char_code">Z0100</xsl:element>
          <xsl:element name="data_type">STRING</xsl:element>
          <xsl:element name="configured_value">
            <xsl:value-of select="request-param[@name='networkElementId']"/>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      <!-- Startdatum -->
      <xsl:if test="request-param[@name='conditionStartDate']!= ''">
        <xsl:element name="CcmFifConfiguredValueCont">
          <xsl:element name="service_char_code">V0200</xsl:element>
          <xsl:element name="data_type">STRING</xsl:element>
          <xsl:element name="configured_value">
            <xsl:value-of select="request-param[@name='conditionStartDate']"/>
          </xsl:element>
        </xsl:element>
      </xsl:if>    			                
    </xsl:element>
  </xsl:element>
</xsl:element>	
