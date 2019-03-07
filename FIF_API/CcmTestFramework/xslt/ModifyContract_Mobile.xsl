<xsl:element name="CcmFifCommandList">
  <xsl:element name="transaction_id">
    <xsl:value-of select="request-param[@name='transactionID']"/>
  </xsl:element>
  <xsl:element name="client_name">
    <xsl:value-of select="request-param[@name='clientName']"/>
  </xsl:element>
  <xsl:variable name="TopAction" select="//request/action-name"/>
  <xsl:element name="action_name">
    <xsl:value-of select="concat($TopAction, '_Mobile')"/>
  </xsl:element>   
  <xsl:element name="override_system_date">
    <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
  </xsl:element>
  <xsl:element name="Command_List">

    <!-- check desired date and article number -->
    <xsl:if test="request-param[@name='desiredDate'] = ''
      or request-param[@name='articleNumber'] = ''">
      <xsl:element name="CcmFifRaiseErrorCmd">
        <xsl:element name="command_id">missing_parameters</xsl:element>
        <xsl:element name="CcmFifRaiseErrorInCont">
          <xsl:element name="error_text">Die Parameter articleNumber und desiredDate muessen bei einem Arcor-Mobil Tarifwechsel angegeben werden.</xsl:element>
        </xsl:element>
      </xsl:element>        
    </xsl:if>
    
    <!-- Find Main Access Service Subscription for contract -->
    <xsl:element name="CcmFifFindServiceSubsCmd">
      <xsl:element name="command_id">find_mobile_service</xsl:element>
      <xsl:element name="CcmFifFindServiceSubsInCont">
        <xsl:element name="contract_number">
          <xsl:value-of select="request-param[@name='contractNumber']"/>
        </xsl:element>
        <xsl:element name="service_code">V8000</xsl:element>                   
      </xsl:element>
    </xsl:element>
    
    <!-- Get PC data to retrieve the current tariff -->
    <xsl:element name="CcmFifGetProductCommitmentDataCmd">
      <xsl:element name="command_id">get_tariff</xsl:element>
      <xsl:element name="CcmFifGetProductCommitmentDataInCont">
        <xsl:element name="product_commitment_number_ref">
          <xsl:element name="command_id">find_mobile_service</xsl:element>
          <xsl:element name="field_name">product_commitment_number</xsl:element>
        </xsl:element>
        <xsl:element name="retrieve_signed_version">Y</xsl:element>
      </xsl:element>
    </xsl:element>
    
    <xsl:if test="request-param[@name='changeTariff'] = 'Y'">
      <!-- check if tariff was changed -->
      <xsl:element name="CcmFifValidateValueCmd">
        <xsl:element name="command_id">validate_tariff_changed</xsl:element>
        <xsl:element name="CcmFifValidateValueInCont">
          <xsl:element name="value_ref">
            <xsl:element name="command_id">get_tariff</xsl:element>
            <xsl:element name="field_name">pricing_structure_code</xsl:element>
          </xsl:element>
          <xsl:element name="object_type">productCommitment</xsl:element>
          <xsl:element name="value_type">pricingStructureCode</xsl:element>
          <xsl:element name="allowed_values">
            <xsl:if test="request-param[@name='newPricingStructureCode'] != 'V8000'">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">V8000</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='newPricingStructureCode'] != 'V8002'">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">V8002</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='newPricingStructureCode'] != 'V8003'">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">V8003</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='newPricingStructureCode'] != 'V8004'">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">V8004</xsl:element>
              </xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:if>
    
    <!-- Renegotiate Order Form  -->
    <xsl:element name="CcmFifRenegotiateOrderFormCmd">
      <xsl:element name="command_id">renegotiate_order_form</xsl:element>
      <xsl:element name="CcmFifRenegotiateOrderFormInCont">
        <xsl:element name="contract_number">
          <xsl:value-of select="request-param[@name='contractNumber']"/>
        </xsl:element>
        <!-- Change the mimimum period, if needed -->
        <xsl:if test="request-param[@name='changeMinimumDuration'] = 'Y'">
          <xsl:element name="min_per_dur_value">
            <xsl:value-of select="request-param[@name='newMinPeriodDurationValue']"/>
          </xsl:element>
          <xsl:element name="min_per_dur_unit">
            <xsl:value-of select="request-param[@name='newMinPeriodDurationUnit']"/>
          </xsl:element>
          <xsl:element name="term_start_date">
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
        </xsl:if>
        <!-- Change the tariff, if needed -->
        <xsl:if test="request-param[@name='changeTariff'] = 'Y'">
          <xsl:element name="product_commit_list">
            <xsl:element name="CcmFifProductCommitCont">
              <xsl:element name="new_pricing_structure_code">
                <xsl:value-of select="request-param[@name='newPricingStructureCode']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>
        <xsl:element name="auto_extent_period_value">
          <xsl:value-of select="request-param[@name='newAutoExtentPeriodValue']"/>
        </xsl:element>                         
        <xsl:element name="auto_extent_period_unit">
          <xsl:value-of select="request-param[@name='newAutoExtentPeriodUnit']"/>
        </xsl:element>                         
        <xsl:element name="auto_extension_ind">
          <xsl:value-of select="request-param[@name='newAutoExtensionInd']"/>
        </xsl:element>     
        <xsl:if test="request-param[@name='specialTerminationRight'] != ''">
          <xsl:element name="special_termination_right">
            <xsl:value-of select="request-param[@name='specialTerminationRight']"/>
          </xsl:element>                         
        </xsl:if> 
        <xsl:element name="customer_tracking_id">
          <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
        </xsl:element>         
      </xsl:element>
    </xsl:element>
    

    <!-- Add commissing information  -->
    <xsl:if test="request-param[@name='salesOrganisationNumber'] != ''">
      <xsl:element name="CcmFifAddCommissionInfoCmd">
        <xsl:element name="command_id">add_commission_info</xsl:element>
        <xsl:element name="CcmFifAddCommissionInfoInCont">
          <xsl:element name="supported_object_id">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">O</xsl:element>
          <xsl:element name="cio_type_rd">ONE_TIME</xsl:element>
          <xsl:element name="cio_data">
            <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:if>     
    
    <xsl:if test="request-param[@name='salesOrganisationNumberVF'] != ''">
      <xsl:element name="CcmFifAddCommissionInfoCmd">
        <xsl:element name="command_id">add_commission_info_vf</xsl:element>
        <xsl:element name="CcmFifAddCommissionInfoInCont">
          <xsl:element name="supported_object_id">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">O</xsl:element>
          <xsl:element name="cio_type_rd">ONE_TIME_VF</xsl:element>
          <xsl:element name="cio_data">
            <xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:if>     


    <!-- Reconfigure the mobile service -->
    <xsl:element name="CcmFifReconfigServiceCmd">
      <xsl:element name="command_id">reconfigure_mobile_service</xsl:element>
      <xsl:element name="CcmFifReconfigServiceInCont">          
        <xsl:element name="service_subscription_ref">
          <xsl:element name="command_id">find_mobile_service</xsl:element>
          <xsl:element name="field_name">service_subscription_id</xsl:element>
        </xsl:element>
        <xsl:element name="desired_date">
          <xsl:value-of select="request-param[@name='desiredDate']"/>
        </xsl:element>
        <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
        <xsl:element name="reason_rd">MOBILETARIFCHG</xsl:element>
        <xsl:element name="service_characteristic_list">
          <!-- Artikelnummer -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">V0178</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">
              <xsl:value-of select="request-param[@name='articleNumber']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    
    <!-- Create Customer Order for new services  -->
    <xsl:element name="CcmFifCreateCustOrderCmd">
      <xsl:element name="command_id">create_activation_co</xsl:element>
      <xsl:element name="CcmFifCreateCustOrderInCont">
        <xsl:element name="customer_number_ref">
          <xsl:element name="command_id">find_mobile_service</xsl:element>
          <xsl:element name="field_name">customer_number</xsl:element>
        </xsl:element>
        <xsl:element name="cust_order_description">Mobilfunk-Tarifwechsel</xsl:element>
        <xsl:element name="customer_tracking_id">
          <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
        </xsl:element>
        <xsl:element name="service_ticket_pos_list">
          <!-- mobile service -->
          <xsl:element name="CcmFifCommandRefCont">
            <xsl:element name="command_id">reconfigure_mobile_service</xsl:element>
            <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
          </xsl:element>
        </xsl:element>         
      </xsl:element>
    </xsl:element>    

      
    <!-- the actual processing is done, the remaining commands are only used 
      for telling aip to trigger the tariff change at D2 and to write a contact
      documenting the tariff change -->            
    
    <!-- find STP -->
    <xsl:element name="CcmFifFindServiceTicketPositionCmd">
      <xsl:element name="command_id">find_initial_stp</xsl:element>
      <xsl:element name="CcmFifFindServiceTicketPositionInCont">
        <xsl:element name="service_subscription_id_ref">
          <xsl:element name="command_id">find_mobile_service</xsl:element>
          <xsl:element name="field_name">service_subscription_id</xsl:element>
        </xsl:element>
        <xsl:element name="find_stp_parameters">
          <xsl:element name="CcmFifFindStpParameterCont">
            <xsl:element name="usage_mode_value_rd">2</xsl:element>
            <xsl:element name="customer_order_state">FINAL</xsl:element>
          </xsl:element>
          <xsl:element name="CcmFifFindStpParameterCont">
            <xsl:element name="usage_mode_value_rd">1</xsl:element>
            <xsl:element name="customer_order_state">FINAL</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    
    <!-- values for passing back to the front end -->
    <xsl:element name="CcmFifFindServCharValueForServCharCmd">
      <xsl:element name="command_id">get_sim_id</xsl:element>
      <xsl:element name="CcmFifFindServCharValueForServCharInCont">
        <xsl:element name="service_ticket_position_id_ref">
          <xsl:element name="command_id">find_initial_stp</xsl:element>
          <xsl:element name="field_name">service_ticket_position_id</xsl:element>
        </xsl:element>
        <xsl:element name="service_char_code">V0108</xsl:element>
        <xsl:element name="no_csc_error">Y</xsl:element>
        <xsl:element name="retrieve_all_characteristics">Y</xsl:element>
      </xsl:element>
    </xsl:element>							      
    
    <!-- get the temp access number -->
    <xsl:element name="CcmFifFindServCharValueForServCharCmd">
      <xsl:element name="command_id">get_access_number</xsl:element>
      <xsl:element name="CcmFifFindServCharValueForServCharInCont">
        <xsl:element name="service_ticket_position_id_ref">
          <xsl:element name="command_id">find_initial_stp</xsl:element>
          <xsl:element name="field_name">service_ticket_position_id</xsl:element>
        </xsl:element>
        <xsl:element name="service_char_code">V0180</xsl:element>
        <xsl:element name="no_csc_error">Y</xsl:element>
        <xsl:element name="retrieve_all_characteristics">Y</xsl:element>
      </xsl:element>
    </xsl:element>							      
    
    <!-- pass back city code -->
    <xsl:element name="CcmFifConcatStringsCmd">
      <xsl:element name="command_id">passback_city_code</xsl:element>
      <xsl:element name="CcmFifConcatStringsInCont">
        <xsl:element name="input_string_list">
          <xsl:element name="CcmFifPassingValueCont">
            <xsl:element name="value">0</xsl:element>							
          </xsl:element>
          <xsl:element name="CcmFifCommandRefCont">
            <xsl:element name="command_id">get_access_number</xsl:element>
            <xsl:element name="field_name">city_code</xsl:element>							
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>							      
    
    <!-- create the string for the contact text -->
    <xsl:element name="CcmFifConcatStringsCmd">
      <xsl:element name="command_id">concat_contact_text</xsl:element>
      <xsl:element name="CcmFifConcatStringsInCont">
        <xsl:element name="input_string_list">
          <xsl:element name="CcmFifPassingValueCont">
            <xsl:element name="value">
              <xsl:text>Der Tarif für Arcor Mobil für Rufnummer </xsl:text>
            </xsl:element>
          </xsl:element>							
          <xsl:element name="CcmFifCommandRefCont">
            <xsl:element name="command_id">passback_city_code</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>
          <xsl:element name="CcmFifPassingValueCont">
            <xsl:element name="value">/</xsl:element>
          </xsl:element>							
          <xsl:element name="CcmFifCommandRefCont">
            <xsl:element name="command_id">get_access_number</xsl:element>
            <xsl:element name="field_name">local_number</xsl:element>
          </xsl:element>
          <xsl:element name="CcmFifPassingValueCont">
            <xsl:element name="value">
              <xsl:text> wurde auf </xsl:text>
              <xsl:value-of select="request-param[@name='newPricingStructureCode']"/> 
              <xsl:text> geändert.&#xA;Vertragsnummer: </xsl:text>
              <xsl:value-of select="request-param[@name='contractNumber']"/>
              <xsl:text>&#xA;Client: </xsl:text>
              <xsl:value-of select="request-param[@name='clientName']"/>
              <xsl:text>&#xA;TransactionID: </xsl:text>
              <xsl:value-of select="request-param[@name='transactionID']"/>
            </xsl:element>
          </xsl:element>							                
        </xsl:element>
      </xsl:element>
    </xsl:element>    
    
    <!-- create contact -->
    <xsl:element name="CcmFifCreateContactCmd">
      <xsl:element name="command_id">create_contact</xsl:element>
      <xsl:element name="CcmFifCreateContactInCont">
        <xsl:element name="customer_number_ref">
          <xsl:element name="command_id">find_mobile_service</xsl:element>
          <xsl:element name="field_name">customer_number</xsl:element>
        </xsl:element>
        <xsl:element name="contact_type_rd">MOBILETARIFCHG</xsl:element>
        <xsl:element name="short_description">Mobilfunktarif gewechselt</xsl:element>
        <xsl:element name="description_text_list">
          <xsl:element name="CcmFifCommandRefCont">
            <xsl:element name="command_id">concat_contact_text</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>            
        </xsl:element>
      </xsl:element>
    </xsl:element>
    
    <xsl:element name="CcmFifProcessServiceBusRequestCmd">
      <xsl:element name="command_id">call_aip</xsl:element>
      <xsl:element name="CcmFifProcessServiceBusRequestInCont">
        <xsl:element name="package_name">net.arcor.aip.epsm_aip_tarifwechsel_001</xsl:element>
        <xsl:element name="service_name">Tarifwechsel</xsl:element>
        <xsl:element name="synch_ind">N</xsl:element>
        <xsl:element name="external_system_id_ref">
          <xsl:element name="command_id">find_mobile_service</xsl:element>
          <xsl:element name="field_name">product_commitment_number</xsl:element>
        </xsl:element>
        <xsl:element name="parameter_value_list">
          <xsl:element name="CcmFifParameterValueCont">
            <xsl:element name="parameter_name">Rufnummer;Mobilvorwahl</xsl:element>
            <xsl:element name="parameter_value_ref">
              <xsl:element name="command_id">passback_city_code</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="CcmFifParameterValueCont">
            <xsl:element name="parameter_name">Rufnummer;Mobilfunkrufnummer</xsl:element>
            <xsl:element name="parameter_value_ref">
              <xsl:element name="command_id">get_access_number</xsl:element>
              <xsl:element name="field_name">local_number</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="CcmFifParameterValueCont">
            <xsl:element name="parameter_name">SimId</xsl:element>
            <xsl:element name="parameter_value_ref">
              <xsl:element name="command_id">get_sim_id</xsl:element>
              <xsl:element name="field_name">characteristic_value</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="CcmFifParameterValueCont">
            <xsl:element name="parameter_name">Artikelnummer</xsl:element>
            <xsl:element name="parameter_value">
              <xsl:value-of select="request-param[@name='articleNumber']"/>
            </xsl:element>
          </xsl:element>
          <xsl:element name="CcmFifParameterValueCont">
            <xsl:element name="parameter_name">GueltigkeitsDatum</xsl:element>
            <xsl:element name="parameter_value">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:element>
          </xsl:element>
          <xsl:element name="CcmFifParameterValueCont">
            <xsl:element name="parameter_name">TechnUser</xsl:element>
            <xsl:element name="parameter_value">FIF</xsl:element>
          </xsl:element>
        </xsl:element>          
      </xsl:element>
    </xsl:element>
    
  </xsl:element>
</xsl:element>
