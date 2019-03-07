<!--
  XSLT file for creating an ISDN contract relocation FIF request

  @author banania
-->

      <!-- Clone Order Form -->
      <xsl:element name="CcmFifCloneOrderFormCmd">
        <xsl:element name="command_id">clone_order_form_1</xsl:element>
        <xsl:element name="CcmFifCloneOrderFormInCont">
          <xsl:element name="scenario_type">
            <xsl:value-of select="$scenarioType"/>
          </xsl:element>
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="sales_org_num_value">
            <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
          </xsl:element>     
          <xsl:element name="sales_org_num_value_vf">
			<xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
		  </xsl:element>                      
          <xsl:element name="target_product_code">
            <xsl:value-of select="$TargetProductCode"/>
          </xsl:element>
          <xsl:element name="target_pricing_structure_code">
            <xsl:value-of select="request-param[@name='tariffVoice']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="$ReasonRd"/>
          </xsl:element>  
          <xsl:element name="board_sign_name">
            <xsl:value-of select="request-param[@name='boardSignName']"/>
          </xsl:element>
          <xsl:element name="primary_cust_sign_name">
            <xsl:value-of select="request-param[@name='primaryCustSignName']"/>
          </xsl:element> 
          <xsl:element name="min_per_dur_value">
            <xsl:value-of select="request-param[@name='minPeriodDurationValue']"/>
          </xsl:element>
          <xsl:element name="min_per_dur_unit">
            <xsl:value-of select="request-param[@name='minPeriodDurationUnit']"/>
          </xsl:element> 
          <xsl:element name="address_ref">
            <xsl:element name="command_id">create_addr_1</xsl:element>
            <xsl:element name="field_name">address_id</xsl:element>
          </xsl:element>  
          <xsl:element name="auto_extent_period_value">
            <xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>
          </xsl:element>                         
          <xsl:element name="auto_extent_period_unit">
            <xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>
          </xsl:element>                         
          <xsl:element name="auto_extension_ind">
            <xsl:value-of select="request-param[@name='autoExtensionInd']"/>
          </xsl:element>  
          <xsl:if test="$ProductType = ''">
            <xsl:element name="target_product_type">Premium</xsl:element> 
          </xsl:if>
          <xsl:if test="$ProductType != ''">
            <xsl:element name="target_product_type">
              <xsl:value-of select="$ProductType"/>
            </xsl:element>         
          </xsl:if>                                             
          <xsl:if test="count(request-param-list[@name='featureServiceListISDN']/request-param-list-item) != 0">
            <xsl:element name="service_code_list">
              <!-- Pass in the list of service codes -->
              <xsl:for-each
                select="request-param-list[@name='featureServiceListISDN']/request-param-list-item">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="service_code">
                    <xsl:value-of select="request-param"/>
                  </xsl:element>
                </xsl:element>
              </xsl:for-each>
            </xsl:element>
          </xsl:if>
          <xsl:element name="service_characteristic_list">
              <!-- New location -->
              <xsl:element name="CcmFifAddressCharacteristicCont">
                <xsl:element name="service_char_code">V0014</xsl:element>
                <xsl:element name="data_type">ADDRESS</xsl:element>
                <xsl:element name="address_ref">
                  <xsl:element name="command_id">create_addr_1</xsl:element>
                  <xsl:element name="field_name">address_id</xsl:element>
                </xsl:element>
              </xsl:element>              
                <!-- Aktivierungsdatum-->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">V0909</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">
                    <xsl:value-of select="$relocationDateOPM"/>
                  </xsl:element>
                </xsl:element>
              <!-- Anschlussbereich_kennz. -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0934</xsl:element>
                <xsl:element name="data_type">INTEGER</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='ASBNumber']"/>
                </xsl:element>
              </xsl:element>
              <!-- Anschlussbereich_kennz. -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0123</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='locationTAE']"/>
                </xsl:element>
              </xsl:element>
              <!-- ONKZ -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0124</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='ONKZ']"/>
                </xsl:element>
              </xsl:element>
            <!-- Auftragsvariante  -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0810</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>  
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='relocationType']"/>
                </xsl:element>                                  
              </xsl:element>
              <!-- Bearbeitungsart -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0971</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">TAL</xsl:element>
              </xsl:element>
            <!-- Bemerkung -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='userName']"/>
              </xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='createDSL'] != 'Y'">
              <!-- DSL -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0090</xsl:element>
                <xsl:element name="data_type">BOOLEAN</xsl:element>
                <xsl:element name="configured_value">N</xsl:element>
              </xsl:element>
            </xsl:if>
              <xsl:if test="request-param[@name='createDSL'] = 'Y'">
                <!-- DSL -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">V0090</xsl:element>
                  <xsl:element name="data_type">BOOLEAN</xsl:element>
                  <xsl:element name="configured_value">Y</xsl:element>
                </xsl:element>
                <!-- DSL Bandbreite -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">V0093</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">
                    <xsl:value-of select="request-param[@name='DSLBandwidth']"/>
                  </xsl:element>
                </xsl:element>
              </xsl:if>
              <!-- Leitungstyp -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">V0138</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">
                    <xsl:value-of select="request-param[@name='lineType']"/>
                  </xsl:element>
                </xsl:element>
              <!-- Carrier -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0081</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='carrier']"/>
                </xsl:element>
              </xsl:element>
              <!-- DTAG-Freitext -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0141</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='DTAGFreetext']"/>
                </xsl:element>
              </xsl:element>  
              <xsl:if test="request-param[@name='customerCallBackNumber'] != ''">      
              <!-- Rückrufnummer -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">V0125</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">
                    <xsl:value-of select="request-param[@name='customerCallBackNumber']"/>
                  </xsl:element>
                </xsl:element>  
              </xsl:if>  
              <!-- Anzahl der neue Rufnummern -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0936</xsl:element>
                <xsl:element name="data_type">INTEGER</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='numberOfNewAccessNumbers']"/>
                </xsl:element>
              </xsl:element>             
            <xsl:if test="request-param[@name='numberOfNewAccessNumbers'] = '0'">
                <!-- Rufnummer -->
                <xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0001</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code">
                    <xsl:value-of select="substring-before(request-param[@name='accessNumber1'], ';')"/>
                  </xsl:element>
                  <xsl:element name="city_code">
                    <xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber1'], ';'), ';')"/>
                  </xsl:element>
                  <xsl:element name="local_number">
                    <xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber1'], ';'), ';')"/>
                  </xsl:element>
                </xsl:element>
                <!-- Weitere Rufnummern -->
                <xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0070</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code">
                    <xsl:value-of select="substring-before(request-param[@name='accessNumber2'], ';')"/>
                  </xsl:element>
                  <xsl:element name="city_code">
                    <xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber2'], ';'), ';')"/>
                  </xsl:element>
                  <xsl:element name="local_number">
                    <xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber2'], ';'), ';')"/>
                  </xsl:element>
                </xsl:element>
                <!-- Weitere Rufnummern -->
                <xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0071</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code">
                    <xsl:value-of select="substring-before(request-param[@name='accessNumber3'], ';')"/>
                  </xsl:element>
                  <xsl:element name="city_code">
                    <xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber3'], ';'), ';')"/>
                  </xsl:element>
                  <xsl:element name="local_number">
                    <xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber3'], ';'), ';')"/>
                  </xsl:element>
                </xsl:element>                
                <!-- Update Selected Destination -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">V0877</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">
                    <xsl:value-of select="request-param[@name='updateSelectedDestination']"/>
                  </xsl:element>
                </xsl:element>                
                <!-- Weitere Rufnummern -->
                <xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0072</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code">
                    <xsl:value-of select="substring-before(request-param[@name='accessNumber4'], ';')"/>
                  </xsl:element>
                  <xsl:element name="city_code">
                    <xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber4'], ';'), ';')"/>
                  </xsl:element>
                  <xsl:element name="local_number">
                    <xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber4'], ';'), ';')"/>
                  </xsl:element>
                </xsl:element>
                <!-- Weitere Rufnummern -->
                <xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0073</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code">
                    <xsl:value-of select="substring-before(request-param[@name='accessNumber5'], ';')"/>
                  </xsl:element>
                  <xsl:element name="city_code">
                    <xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber5'], ';'), ';')"/>
                  </xsl:element>
                  <xsl:element name="local_number">
                    <xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber5'], ';'), ';')"/>
                  </xsl:element>
                </xsl:element>
                <!-- Weitere Rufnummern -->
                <xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0074</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code">
                    <xsl:value-of select="substring-before(request-param[@name='accessNumber6'], ';')"/>
                  </xsl:element>
                  <xsl:element name="city_code">
                    <xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber6'], ';'), ';')"/>
                  </xsl:element>
                  <xsl:element name="local_number">
                    <xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber6'], ';'), ';')"/>
                  </xsl:element>
                </xsl:element>
                <!-- Weitere Rufnummern -->
                <xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0075</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code">
                    <xsl:value-of select="substring-before(request-param[@name='accessNumber7'], ';')"/>
                  </xsl:element>
                  <xsl:element name="city_code">
                    <xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber7'], ';'), ';')"/>
                  </xsl:element>
                  <xsl:element name="local_number">
                    <xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber7'], ';'), ';')"/>
                  </xsl:element>
                </xsl:element>
                <!-- Weitere Rufnummern -->
                <xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0076</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code">
                    <xsl:value-of select="substring-before(request-param[@name='accessNumber8'], ';')"/>
                  </xsl:element>
                  <xsl:element name="city_code">
                    <xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber8'], ';'), ';')"/>
                  </xsl:element>
                  <xsl:element name="local_number">
                    <xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber8'], ';'), ';')"/>
                  </xsl:element>
                </xsl:element>
                <!-- Weitere Rufnummern -->
                <xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0077</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code">
                    <xsl:value-of select="substring-before(request-param[@name='accessNumber9'], ';')"/>
                  </xsl:element>
                  <xsl:element name="city_code">
                    <xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber9'], ';'), ';')"/>
                  </xsl:element>
                  <xsl:element name="local_number">
                    <xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber9'], ';'), ';')"/>
                  </xsl:element>
                </xsl:element>
                <!-- Weitere Rufnummern -->
                <xsl:element name="CcmFifAccessNumberCont">
                  <xsl:element name="service_char_code">V0078</xsl:element>
                  <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                  <xsl:element name="country_code">
                    <xsl:value-of select="substring-before(request-param[@name='accessNumber10'], ';')"/>
                  </xsl:element>
                  <xsl:element name="city_code">
                    <xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber10'], ';'), ';')"/>
                  </xsl:element>
                  <xsl:element name="local_number">
                    <xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber10'], ';'), ';')"/>
                  </xsl:element>
                </xsl:element>               
              </xsl:if>
            <!-- Relocation Variant-->
            <xsl:if test="request-param[@name='relocationVariant'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V2024</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='relocationVariant']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            
             <!-- Premium Type -->
			<xsl:if test="request-param[@name='desiredPremiumType'] != '' and $ProductType = 'Premium'">							
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0190</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='desiredPremiumType']"/>
									</xsl:element>
								</xsl:element>
			</xsl:if>
							
			<!-- Premium Type Change -->
			<xsl:if test="request-param[@name='allowPremiumTypeChange'] != '' and $ProductType = 'Premium'">													
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0191</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='allowPremiumTypeChange']"/>
									</xsl:element>
								</xsl:element>
			</xsl:if>    
          <!-- set ACS  -->
            <xsl:if test="((request-param[@name='setACSIndicator'] != '')
              and ((request-param[@name='setACSIndicator'] = 'Y')
              or (request-param[@name='setACSIndicator'] = 'Ja')))">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0196</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">Ja</xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Instant Access -->
            <xsl:if test="request-param[@name='instantAccessIndicator']!= ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V8003</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='instantAccessIndicator']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Multimedia-VC -->
            <xsl:if test="request-param[@name='multimediaProduct'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">I1323</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='multimediaProduct']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
          </xsl:element>
          <xsl:element name="suppress_directory_entry">
            <xsl:value-of select="request-param[@name='suppressDirectoryEntry']"/>
          </xsl:element>   
          <xsl:if test="request-param[@name='keepMMAccessHardware'] = 'N'">
            <xsl:element name="excluded_services">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">I1359</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:if>
        </xsl:element>
      </xsl:element>

      <xsl:if test="request-param[@name='createDSL'] = 'Y'">
        <!-- Add DSL Service -->
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_1</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">clone_order_form_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V0113</xsl:element>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">clone_order_form_1</xsl:element>
              <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="$today"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">
              <xsl:value-of select="$ReasonRd"/>
            </xsl:element> 
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='accountNumber']"/>
            </xsl:element>
            <xsl:element name="service_characteristic_list">
              <!-- DSLBandbreite -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0826</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='DSLBandwidth']"/>
                </xsl:element>
              </xsl:element>
              <!-- DSL Upstream Bandbreite -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0092</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='upstreamBandwidth']"/>
                </xsl:element>
              </xsl:element>
              <!-- Allow Downgrade -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0875</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='allowDowngrade']"/>
                </xsl:element>
              </xsl:element>
              <!-- Desired Bandwidth -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0876</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='desiredBandwidth']"/>
                </xsl:element>
              </xsl:element>  
              <!-- change To UR2 -->
              <xsl:if test="request-param[@name='changeToUR2'] != ''">
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">V0878</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">
                    <xsl:value-of select="request-param[@name='changeToUR2']"/>
                  </xsl:element>
                </xsl:element>
              </xsl:if>                                      
            </xsl:element>
            <xsl:element name="detailed_reason_ref">
                <xsl:element name="command_id">clone_order_form_1</xsl:element>
                <xsl:element name="field_name">detailed_reason_rd</xsl:element>
            </xsl:element>     
          </xsl:element>
        </xsl:element>
        
        <!-- Add DSL Anschluss service -->
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_2</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">clone_order_form_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 500'">
              <xsl:element name="service_code">V0179</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='DSLBandwidth'] = 'Premium'">
              <xsl:element name="service_code">V0116</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='DSLBandwidth'] = 'Gold'">
              <xsl:element name="service_code">V0117</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 1000'">
              <xsl:element name="service_code">V0118</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 2000'">
              <xsl:element name="service_code">V0174</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 3000'">
              <xsl:element name="service_code">V0175</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 4000'">
              <xsl:element name="service_code">V0176</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 5000'">
              <xsl:element name="service_code">V0177</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 6000'">
              <xsl:element name="service_code">V0178</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 8000'">
              <xsl:element name="service_code">V0180</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 10000'">
              <xsl:element name="service_code">V018A</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 12000'">
              <xsl:element name="service_code">V018B</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 16000'">
              <xsl:element name="service_code">V018C</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 20000'">
              <xsl:element name="service_code">V018D</xsl:element>
            </xsl:if>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">clone_order_form_1</xsl:element>
              <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="$today"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">
              <xsl:value-of select="$ReasonRd"/>
            </xsl:element> 
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='accountNumber']"/>
            </xsl:element>
            <xsl:element name="service_characteristic_list"/>
            <xsl:element name="detailed_reason_ref">
                <xsl:element name="command_id">clone_order_form_1</xsl:element>
                <xsl:element name="field_name">detailed_reason_rd</xsl:element>
            </xsl:element>     
          </xsl:element>
        </xsl:element>
        <!-- Add Upstream Service, if requested -->
        <xsl:if test="(request-param[@name='upstreamBandwidth'] != 'Standard')">
          <xsl:element name="CcmFifAddServiceSubsCmd">
            <xsl:element name="command_id">add_service_3</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">clone_order_form_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:if test="(request-param[@name='DSLBandwidth'] = 'DSL 1500') and (request-param[@name='upstreamBandwidth'] = '384')">
                <xsl:element name="service_code">V0197</xsl:element>
              </xsl:if>
              <xsl:if test="(request-param[@name='DSLBandwidth'] = 'DSL 2000') and (request-param[@name='upstreamBandwidth'] = '384')">
                <xsl:element name="service_code">V0198</xsl:element>
              </xsl:if>               
              <xsl:if test="(request-param[@name='DSLBandwidth'] = 'DSL 3000') and (request-param[@name='upstreamBandwidth'] = '512')">
                <xsl:element name="service_code">V0199</xsl:element>
              </xsl:if>
              <xsl:if test="(request-param[@name='DSLBandwidth'] = 'DSL 4000') and (request-param[@name='upstreamBandwidth'] = '512')">
                <xsl:element name="service_code">V0199</xsl:element>
              </xsl:if>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">add_service_2</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$today"/>	
              </xsl:element>
              <xsl:element name="desired_schedule_type">ASAP</xsl:element>
              <xsl:element name="reason_rd">
                <xsl:value-of select="$ReasonRd"/>
              </xsl:element> 
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
              <xsl:element name="service_characteristic_list"/>
              <xsl:element name="detailed_reason_ref">
                <xsl:element name="command_id">clone_order_form_1</xsl:element>
                <xsl:element name="field_name">detailed_reason_rd</xsl:element>
              </xsl:element>     
            </xsl:element>
          </xsl:element>
        </xsl:if>        
        
      </xsl:if>

      <xsl:if test="request-param[@name='instantAccessOption'] != ''">
        <!-- Add DSL Service -->
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_sim_id_service_1</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">clone_order_form_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V8042</xsl:element>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">clone_order_form_1</xsl:element>
              <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="$today"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">
              <xsl:value-of select="$ReasonRd"/>
            </xsl:element>                                  
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='accountNumber']"/>
            </xsl:element>
            <!-- Bemerkung -->
            <xsl:element name="service_characteristic_list">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0108</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='SIMID']"/>
                </xsl:element>
              </xsl:element> 
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V8004</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='instantAccessOption']"/>
                </xsl:element>
              </xsl:element>                             
            </xsl:element>
            <xsl:element name="detailed_reason_ref">
              <xsl:element name="command_id">clone_order_form_1</xsl:element>
              <xsl:element name="field_name">detailed_reason_rd</xsl:element>
            </xsl:element> 
          </xsl:element>
        </xsl:element>
      </xsl:if>
    <!-- look for a voice bundle (item) -->
    <xsl:element name="CcmFifFindBundleCmd">
      <xsl:element name="command_id">find_bundle_1</xsl:element>
      <xsl:element name="CcmFifFindBundleInCont">
        <xsl:element name="supported_object_id_ref">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="field_name">service_subscription_id</xsl:element>
        </xsl:element>
        <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
      </xsl:element>
    </xsl:element>
    
    <!-- Create a new bundle if no one has been found -->
    <xsl:element name="CcmFifModifyBundleCmd">
      <xsl:element name="command_id">modify_bundle_1</xsl:element>
      <xsl:element name="CcmFifModifyBundleInCont">
        <xsl:element name="bundle_id_ref">
          <xsl:element name="command_id">find_bundle_1</xsl:element>
          <xsl:element name="field_name">bundle_id</xsl:element>
        </xsl:element>           
        <xsl:element name="customer_number">
          <xsl:value-of select="request-param[@name='customerNumber']"/>
        </xsl:element>          
        <xsl:element name="bundle_found_ref">
          <xsl:element name="command_id">find_bundle_1</xsl:element>
          <xsl:element name="field_name">bundle_found</xsl:element>
        </xsl:element>         
      </xsl:element>
    </xsl:element>
    
    
    <!-- add the new voice over IP  bundle item if a bundle is found -->
    <xsl:element name="CcmFifModifyBundleItemCmd">
      <xsl:element name="command_id">modify_bundle_item_1</xsl:element>
      <xsl:element name="CcmFifModifyBundleItemInCont">
        <xsl:element name="bundle_id_ref">
          <xsl:element name="command_id">find_bundle_1</xsl:element>
          <xsl:element name="field_name">bundle_id</xsl:element>
        </xsl:element>
        <xsl:element name="bundle_item_type_rd">VOICE_SERVICE</xsl:element>
        <xsl:element name="supported_object_id_ref">
          <xsl:element name="command_id">clone_order_form_1</xsl:element>
          <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
        </xsl:element>
        <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
        <xsl:element name="action_name">ADD</xsl:element>
        <xsl:element name="process_ind_ref">
          <xsl:element name="command_id">find_bundle_1</xsl:element>
          <xsl:element name="field_name">bundle_found</xsl:element>
        </xsl:element>
        <xsl:element name="required_process_ind">Y</xsl:element>
      </xsl:element>
    </xsl:element>
    
    <!-- add the new voice over IP  bundle item to the new bundle if created only -->
    <xsl:element name="CcmFifModifyBundleItemCmd">
      <xsl:element name="command_id">modify_bundle_item_2</xsl:element>
      <xsl:element name="CcmFifModifyBundleItemInCont">
        <xsl:element name="bundle_id_ref">
          <xsl:element name="command_id">modify_bundle_1</xsl:element>
          <xsl:element name="field_name">bundle_id</xsl:element>
        </xsl:element>
        <xsl:element name="bundle_item_type_rd">VOICE_SERVICE</xsl:element>
        <xsl:element name="supported_object_id_ref">
          <xsl:element name="command_id">clone_order_form_1</xsl:element>
          <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
        </xsl:element>
        <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
        <xsl:element name="action_name">ADD</xsl:element>
        <xsl:element name="process_ind_ref">
          <xsl:element name="command_id">find_bundle_1</xsl:element>
          <xsl:element name="field_name">bundle_found</xsl:element>
        </xsl:element>
        <xsl:element name="required_process_ind">N</xsl:element>
      </xsl:element>
    </xsl:element>

      <!-- Create Customer Orders for Cloning of Services -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="sales_rep_dept_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
          <xsl:element name="provider_tracking_no">003</xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">clone_order_form_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_2</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element> 
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_3</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>  
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_sim_id_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>                             
         </xsl:element>
         <xsl:element name="e_shop_id">
		    <xsl:value-of select="request-param[@name='eShopID']"/>
		 </xsl:element>
        </xsl:element>
      </xsl:element>
  
      <!-- Create Customer Order for Directory Entry -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_2</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>         
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="sales_rep_dept_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
          <xsl:element name="provider_tracking_no">003t</xsl:element>
          <xsl:element name="ignore_empty_list_ind">Y</xsl:element> 
          <xsl:element name="service_ticket_pos_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">clone_order_form_1</xsl:element>
                <xsl:element name="field_name">directory_entry_stp_list</xsl:element>
              </xsl:element>                          
          </xsl:element>
          <xsl:element name="e_shop_id">
		    <xsl:value-of select="request-param[@name='eShopID']"/>
		  </xsl:element>
        </xsl:element>
      </xsl:element>
  
      <!-- Release Customer Orders for Cloning + DSL services  -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
        </xsl:element> 

    <!-- Release Customer Order for  Directory Entry -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_2</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
          <xsl:element name="parent_customer_order_id_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>          	
          </xsl:element>          
        </xsl:element>
      </xsl:element>

 
     <!-- Terminate the old Voice Contract -->   

     &TerminateService_ISDN;

    <!-- Write the main access service to the external Notification -->   
    <xsl:element name="CcmFifCreateExternalNotificationCmd">
      <xsl:element name="command_id">create_notification_1</xsl:element>
      <xsl:element name="CcmFifCreateExternalNotificationInCont">
        <xsl:element name="effective_date">
            <xsl:value-of select="$today"/>
        </xsl:element>
        <xsl:element name="transaction_id">
          <xsl:value-of select="request-param[@name='requestListId']"/>
        </xsl:element>
        <xsl:element name="processed_indicator">Y</xsl:element>
        <xsl:element name="notification_action_name">RelocateContract</xsl:element>
        <xsl:element name="target_system">FIF</xsl:element>
        <xsl:element name="parameter_value_list">
          <xsl:element name="CcmFifParameterValueCont">
            <xsl:element name="parameter_name">VOICE_SERVICE_SUBSCRIPTION_ID</xsl:element>
            <xsl:element name="parameter_value_ref">
              <xsl:element name="command_id">clone_order_form_1</xsl:element>
              <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="CcmFifParameterValueCont">
            <xsl:element name="parameter_name">ISDN_SERVICE_SUBSCRIPTION_ID</xsl:element>
            <xsl:element name="parameter_value_ref">
              <xsl:element name="command_id">clone_order_form_1</xsl:element>
              <xsl:element name="field_name">main_access_service_sub_id</xsl:element>
            </xsl:element>
          </xsl:element>  
          <xsl:element name="CcmFifParameterValueCont">
            <xsl:element name="parameter_name">ISDN_DETAILED_REASON_RD</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">clone_order_form_1</xsl:element>
                <xsl:element name="field_name">detailed_reason_rd</xsl:element>
              </xsl:element>
          </xsl:element>  	        							  
        </xsl:element>
        
      </xsl:element>
    </xsl:element>
              
      <!-- Create Contact for the Service relocation -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">AUTO_RELOCATION</xsl:element>
          <xsl:element name="short_description">Automatischer Umzug</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;ContractNumber: </xsl:text>
            <xsl:value-of select="request-param[@name='contractNumber']"/>
            <xsl:text>&#xA;User Name: </xsl:text>
            <xsl:value-of select="request-param[@name='userName']"/>
            <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
            <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
