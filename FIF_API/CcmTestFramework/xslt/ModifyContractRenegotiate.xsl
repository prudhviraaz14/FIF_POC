      <!-- Get Order Form Data for APPROVED row -->
      <xsl:element name="CcmFifGetOrderFormDataCmd">
        <xsl:element name="command_id">get_order_form_data_0_approved</xsl:element>
        <xsl:element name="CcmFifGetOrderFormDataInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="target_state">APPROVED</xsl:element>
          <xsl:element name="ignore_not_exists">Y</xsl:element>
          <xsl:element name="most_effective">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- cancel order form version -->
      <xsl:element name="CcmFifTransitionLegalAgreementCmd">
        <xsl:element name="command_id">transition_la_0</xsl:element>
        <xsl:element name="CcmFifTransitionLegalAgreementInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="state_rd">CANCELED</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">get_order_form_data_0_approved</xsl:element>
            <xsl:element name="field_name">record_found</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>              
        </xsl:element>
      </xsl:element>
      
      
      
      <!-- Get Order Form Data for CREATED row -->
      <xsl:element name="CcmFifGetOrderFormDataCmd">
        <xsl:element name="command_id">get_order_form_data_1_created</xsl:element>
        <xsl:element name="CcmFifGetOrderFormDataInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="target_state">CREATED</xsl:element>
          <xsl:element name="ignore_not_exists">Y</xsl:element>
          <xsl:element name="most_effective">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- cancel order form version -->
      <xsl:element name="CcmFifTransitionLegalAgreementCmd">
        <xsl:element name="command_id">transition_la_1</xsl:element>
        <xsl:element name="CcmFifTransitionLegalAgreementInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="state_rd">CANCELED</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">get_order_form_data_1_created</xsl:element>
            <xsl:element name="field_name">record_found</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
          
   
      <!-- get the owning customer for the contract -->
      <xsl:element name="CcmFifGetOwningCustomerCmd">
        <xsl:element name="command_id">get_owning_customer_1</xsl:element>
        <xsl:element name="CcmFifGetOwningCustomerInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- if desired date is not set, use the next cycle due date -->      
      <xsl:if test="request-param[@name='desiredDate'] = ''">
        <!-- get customer data for retrieving cycle name -->
        <xsl:element name="CcmFifGetCustomerDataCmd">
          <xsl:element name="command_id">get_customer_data</xsl:element>
          <xsl:element name="CcmFifGetCustomerDataInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">get_owning_customer_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Get Cycle Data -->
        <xsl:element name="CcmFifGetCycleCmd">
          <xsl:element name="command_id">get_cycle</xsl:element>
          <xsl:element name="CcmFifGetCycleInCont">
            <xsl:element name="cycle_name_ref">
              <xsl:element name="command_id">get_customer_data</xsl:element>
              <xsl:element name="field_name">cycle_name</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <xsl:if test="request-param[@name='newPricingStructureCode'] != ''">
        <!-- Add PassBack containers -->
        <xsl:element name="CcmFifPassBackValueCmd">
          <xsl:element name="command_id">passback_1</xsl:element>
          <xsl:element name="CcmFifPassBackValueInCont">
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">newPricingStructureCode</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='newPricingStructureCode']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Renegotiate Order Form  -->
      <xsl:element name="CcmFifRenegotiateOrderFormCmd">
        <xsl:element name="command_id">renegotiate_order_form_1</xsl:element>
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
            <xsl:if test="request-param[@name='desiredDate'] != ''">
              <xsl:element name="term_start_date">
                <xsl:value-of select="request-param[@name='desiredDate']"/>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='desiredDate'] = ''">
              <xsl:element name="term_start_date_ref">
                <xsl:element name="command_id">get_cycle</xsl:element>
                <xsl:element name="field_name">due_date</xsl:element>
              </xsl:element>
            </xsl:if>
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
          <xsl:if test="request-param[@name='OMTSOrderID'] != ''">
            <xsl:element name="customer_tracking_id">
              <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
            </xsl:element> 
          </xsl:if>     
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

