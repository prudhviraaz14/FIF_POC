<xsl:element name="CcmFifCommandList">
  <xsl:element name="transaction_id">
    <xsl:value-of select="request-param[@name='transactionID']"/>
  </xsl:element>
  <xsl:element name="client_name">
    <xsl:value-of select="request-param[@name='clientName']"/>
  </xsl:element>
  <xsl:variable name="TopAction" select="//request/action-name"/>
  <xsl:element name="action_name">
    <xsl:value-of select="concat($TopAction, '_Default')"/>
  </xsl:element>   
  <xsl:element name="override_system_date">
    <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
  </xsl:element>
  <xsl:element name="Command_List">

    <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
    <xsl:variable name="tomorrow" select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
    
    <xsl:variable name="applyDate">  
      <xsl:choose>
        <xsl:when test="request-param[@name='desiredDate'] != '' and
          dateutils:compareString(request-param[@name='desiredDate'], $tomorrow) = '-1'">
          <xsl:value-of select="$tomorrow"/>
        </xsl:when>          
        <xsl:otherwise>
          <xsl:value-of select="request-param[@name='desiredDate']"/>
        </xsl:otherwise>
      </xsl:choose>                      
    </xsl:variable>
         
    <xsl:element name="CcmFifConcatStringsCmd">
      <xsl:element name="command_id">functionID</xsl:element>
      <xsl:element name="CcmFifConcatStringsInCont">
        <xsl:element name="input_string_list">
          <xsl:element name="CcmFifPassingValueCont">
            <xsl:element name="value">
              <xsl:value-of select="request-param[@name='functionID']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    <xsl:element name="CcmFifConcatStringsCmd">
      <xsl:element name="command_id">providerTrackingNumber</xsl:element>
      <xsl:element name="CcmFifConcatStringsInCont">
        <xsl:element name="input_string_list">
          <xsl:element name="CcmFifPassingValueCont">
            <xsl:element name="value">
              <xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
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

      <!-- check for a bandwidth change -->
      <xsl:element name="CcmFifValidatePreviousActionCmd">
        <xsl:element name="command_id">validate_previous_action_1</xsl:element>
        <xsl:element name="CcmFifValidatePreviousActionInCont">
          <xsl:element name="action_name">changeDSLBandwidth</xsl:element>
        </xsl:element>
      </xsl:element>
  

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
              <xsl:value-of select="$applyDate"/>
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
              <xsl:value-of select="$applyDate"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>     
    

      <xsl:element name="CcmFifReadExternalNotificationCmd">
        <xsl:element name="command_id">read_external_notification_1</xsl:element>
        <xsl:element name="CcmFifReadExternalNotificationInCont">
          <xsl:element name="transaction_id">
            <xsl:value-of select="request-param[@name='requestListId']"/>
          </xsl:element>
          <xsl:element name="parameter_name">SERVICE_SUBSCRIPTION_ID</xsl:element>  
          <xsl:element name="ignore_empty_result">Y</xsl:element>                      
        </xsl:element>
      </xsl:element>
         
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">read_external_notification_1</xsl:element>
            <xsl:element name="field_name">parameter_value</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_previous_action_1</xsl:element>
            <xsl:element name="field_name">action_performed_ind</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>          
        </xsl:element>
      </xsl:element>
 
      <!-- find an open customer order for the main service -->
      <xsl:element name="CcmFifFindCustomerOrderCmd">
        <xsl:element name="command_id">find_customer_order_1</xsl:element>
        <xsl:element name="CcmFifFindCustomerOrderInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="state_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">ASSIGNED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">RELEASED</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="allow_children">Y</xsl:element>
          <xsl:element name="usage_mode">2</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_previous_action_1</xsl:element>
            <xsl:element name="field_name">action_performed_ind</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>  
        </xsl:element>
      </xsl:element>

      <!-- Sign Order Form And Apply New Pricing Structure
      	   dependent apply is used, if an open customer order is found -->
      <xsl:element name="CcmFifSignAndApplyNewPricingStructCmd">
        <xsl:element name="command_id">sign_apply_1</xsl:element>
        <xsl:element name="CcmFifSignAndApplyNewPricingStructInCont">
          <xsl:element name="supported_object_id">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">O</xsl:element>
          <xsl:if test="request-param[@name='desiredDate'] != ''">
            <xsl:element name="apply_swap_date">
              <xsl:value-of select="$applyDate"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='desiredDate'] = ''">
            <xsl:element name="apply_swap_date_ref">
              <xsl:element name="command_id">get_cycle</xsl:element>
              <xsl:element name="field_name">due_date</xsl:element>
            </xsl:element>
          </xsl:if>          
          <xsl:element name="board_sign_name">ARCOR</xsl:element>
          <xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
          <xsl:element name="customer_order_id_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>          
        </xsl:element>
      </xsl:element>
      
      <xsl:if test="request-param[@name='clearBundle'] = 'Y'">
        <!-- Create notification for SLS to clear bundle -->
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_sls_notification_1</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="notification_action_name">clearBundle</xsl:element>
            <xsl:element name="target_system">CCM-SLS</xsl:element>
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">get_owning_customer_1</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>     
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- for tariff change create notification for further creation od discount service -->
      <!-- find stp -->
      <xsl:element name="CcmFifFindServiceTicketPositionCmd">
        <xsl:element name="command_id">find_stp_1</xsl:element>
        <xsl:element name="CcmFifFindServiceTicketPositionInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">get_owning_customer_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>
          <xsl:element name="no_stp_error">N</xsl:element>
          <xsl:element name="find_stp_parameters">
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">V0003</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">FINAL</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">V0010</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">FINAL</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">V0011</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">FINAL</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">I1210</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">FINAL</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">VI002</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">FINAL</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">VI003</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">FINAL</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">I1302</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">FINAL</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">I1303</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">FINAL</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">V0003</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">COMPLETED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">V0010</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">COMPLETED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">V0011</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">COMPLETED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">I1210</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">COMPLETED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">VI002</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">COMPLETED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">VI003</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">COMPLETED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">I1302</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">COMPLETED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">I1303</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">COMPLETED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">V0003</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">RELEASED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">V0010</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">RELEASED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">V0011</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">RELEASED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">I1210</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">RELEASED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">VI002</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">RELEASED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">VI003</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">RELEASED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">I1302</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">RELEASED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">I1303</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">RELEASED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">V0003</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">DEFINED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">V0010</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">DEFINED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">V0011</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">DEFINED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">I1210</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">DEFINED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">VI002</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">DEFINED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">VI003</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">DEFINED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">I1302</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">DEFINED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="service_code">I1303</xsl:element>
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">DEFINED</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- get data from STP -->
      <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
        <xsl:element name="command_id">get_stp_data_1</xsl:element>
        <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_stp_1</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_stp_1</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>							
      
      <xsl:element name="CcmFifReadExternalNotificationCmd">
        <xsl:element name="command_id">read_external_notification_2</xsl:element>
        <xsl:element name="CcmFifReadExternalNotificationInCont">
          <xsl:element name="transaction_id">
            <xsl:value-of select="request-param[@name='requestListId']"/>
          </xsl:element>
          <xsl:element name="parameter_name">TC_SERVICE_SUBSCRIPTION_ID</xsl:element>  
          <xsl:element name="ignore_empty_result">Y</xsl:element>                      
        </xsl:element>
      </xsl:element>
            
      <xsl:if test="request-param[@name='clientName'] != 'CODB'">
        <!-- Create KBA notification, if the request is not a KBA request -->
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_kba_notification_1</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:if test="request-param[@name='desiredDate'] != ''">
              <xsl:element name="effective_date">
                <xsl:value-of select="$applyDate"/>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='desiredDate'] = ''">
              <xsl:element name="effective_date_ref">
                <xsl:element name="command_id">get_cycle</xsl:element>
                <xsl:element name="field_name">due_date</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:element name="notification_action_name">createKBANotification</xsl:element>
            <xsl:element name="target_system">KBA</xsl:element>
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='customerNumber']"/></xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TYPE</xsl:element>
                <xsl:element name="parameter_value">CONTACT</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CATEGORY</xsl:element>
                <xsl:element name="parameter_value">Tariff</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">USER_NAME</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='clientName']"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">WORK_DATE</xsl:element>
                <xsl:if test="request-param[@name='desiredDate'] != ''">
                  <xsl:element name="parameter_value">
                    <xsl:value-of select="$applyDate"/>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='desiredDate'] = ''">
                  <xsl:element name="parameter_value_ref">
                    <xsl:element name="command_id">get_cycle</xsl:element>
                    <xsl:element name="field_name">due_date</xsl:element>
                  </xsl:element>
                </xsl:if>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TEXT</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:text>Tarifwechsel/Vertragsänderung über </xsl:text>
                  <xsl:value-of select="request-param[@name='clientName']"/>
                  <xsl:text>.</xsl:text>
                  <xsl:if test="request-param[@name='newPricingStructureCode'] != ''">
                    <xsl:text>  Neuer Tarif: </xsl:text>
                    <xsl:value-of select="request-param[@name='newPricingStructureCode']"/>
                    <xsl:text>.</xsl:text>
                  </xsl:if>
                  <xsl:if test="request-param[@name='pricingStructureBillingName'] != ''">
                    <xsl:text>  Pricing Structure Billing Name: </xsl:text>
                    <xsl:value-of select="request-param[@name='pricingStructureBillingName']"/>
                    <xsl:text>.</xsl:text>
                  </xsl:if>
                  <xsl:if test="request-param[@name='changeMinimumDuration'] = 'Y'">
                    <xsl:text>  Neue Vertragslaufzeit: </xsl:text>
                    <xsl:value-of select="request-param[@name='newMinPeriodDurationValue']"/>
                    <xsl:text>.</xsl:text>
                  </xsl:if>						
                </xsl:element>
              </xsl:element>
            </xsl:element>     
          </xsl:element>
        </xsl:element>
      </xsl:if>
     
  </xsl:element>
</xsl:element>
