<!-- 
  XSLT file for creating an automated Change Bandwidth FIF request

  @author lejam
-->
  
  <xsl:element name="CcmFifCommandList">
    <!-- Copy over transaction ID and action name -->
    <xsl:element name="transaction_id">
      <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="client_name">
      <xsl:value-of select="request-param[@name='clientName']"/>
    </xsl:element>
    <xsl:variable name="TopAction" select="//request/action-name"/>
    <xsl:element name="action_name">
      <xsl:value-of select="concat($TopAction, '_DSLR')"/>
    </xsl:element>    
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">
      <!-- Convert the desired date to OPM format -->
      <xsl:variable name="desiredDateOPM"  select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
      <!-- Calculate today and one day before the desired date -->
      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
      <xsl:variable name="oldBandwidthTerminationDate" select="dateutils:createFIFDateOffset(request-param[@name='desiredDate'], 'DATE', '-1')"/>
      
      <!-- Validate New DSL Bandwidth -->
      <xsl:if test="($newDSLBandwidth != 'Gold')
        and ($newDSLBandwidth != 'DSL 1000')
        and ($newDSLBandwidth != 'DSL 1500')
        and ($newDSLBandwidth != 'DSL 2000')
        and ($newDSLBandwidth != 'DSL 3000')
        and ($newDSLBandwidth != 'DSL 6000')
        and ($newDSLBandwidth != 'DSL 16000')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">new_dsl_bandwidth_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Invalid new DSL bandwidth value passed in for DSLR. Passed in value: <xsl:value-of select="$newDSLBandwidth"/>. Allowed values: DSL 1000, DSL 1500, DSL 2000, DSL 6000, DSL 16000.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>  
   
      <!-- Validate Old DSL Bandwidth -->
      <xsl:if test="($oldDSLBandwidth != 'Standard')
        and ($oldDSLBandwidth != 'Premium')
        and ($oldDSLBandwidth != 'Gold')
        and ($oldDSLBandwidth != 'DSL 1000')
        and ($oldDSLBandwidth != 'DSL 1500')
        and ($oldDSLBandwidth != 'DSL 2000')
        and ($oldDSLBandwidth != 'DSL 3000')
        and ($oldDSLBandwidth != 'DSL 6000')
        and ($oldDSLBandwidth != 'DSL 16000')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">old_dsl_bandwidth_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Invalid old DSL bandwidth value passed in for DSLR. Passed in value: <xsl:value-of select="$oldDSLBandwidth"/>. Allowed values: DSL 1000, DSL 1500, DSL 2000, DSL 6000, DSL 16000.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>  
      
      <!-- Validate New Upstream Bandwidth -->
      <xsl:if test="($newDSLBandwidth != $oldDSLBandwidth)
        or ($newUpstreamBandwidth != $oldUpstreamBandwidth)">
        
        <!-- Ensure that the upstream bandwidth is correct  -->
        <xsl:if test="($newUpstreamBandwidth != 'Standard')">
          <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">upstream_bandwidth_error</xsl:element>
            <xsl:element name="CcmFifRaiseErrorInCont">
              <xsl:element name="error_text">Invalid upstream bandwidth value passed in for DSLR. Passed in value: <xsl:value-of select="$newUpstreamBandwidth"/>. Allowed values: Standard.</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>
      </xsl:if>

      <!-- if changeDSLBandwidthAndTariff modify contract  -->
      <xsl:if test="request-param[@name='changeDSLBandwidthAndTariff'] = 'Y'">
        &ModifyContractRenegotiate;
      </xsl:if>
      
      <!-- Find Service Subscription by access number,or service_subscription id  -->     
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
            </xsl:element>
          </xsl:if>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
          </xsl:element>    
          <xsl:if test="request-param[@name='productSubscriptionId'] != ''">
            <xsl:element name="product_subscription_id">
              <xsl:value-of select="request-param[@name='productSubscriptionId']"/>
            </xsl:element>
            <xsl:element name="fetch_main_ss_from_ps_Ind">Y</xsl:element>
          </xsl:if>
        </xsl:element>
      </xsl:element>
      
      <!-- Lock product subscription  -->
      <xsl:element name="CcmFifLockObjectCmd">
        <xsl:element name="CcmFifLockObjectInCont">
          <xsl:element name="object_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="object_type">PROD_SUBS</xsl:element>
        </xsl:element>
      </xsl:element>   
      
      <!-- find an open customer order for the main access service  for DSLR-->
      <xsl:element name="CcmFifFindCustomerOrderCmd">
        <xsl:element name="command_id">find_customer_order_1</xsl:element>
        <xsl:element name="CcmFifFindCustomerOrderInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="reason_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">RELOCATION</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">DSL_MIGRATION</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="state_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">ASSIGNED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">RELEASED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">PROVISIONED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">INSTALLED</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="allow_children">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Validate desired date of the bandwidth change 
        make sure it is higher than the desired date of
        the relocation or dsl upgrade -->
      <xsl:element name="CcmFifValidateDateCmd">
        <xsl:element name="command_id">validate_desired_date_1</xsl:element>
        <xsl:element name="CcmFifValidateDateInCont">
          <xsl:element name="value_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">desired_date</xsl:element>
          </xsl:element>
          <xsl:element name="object_type">SERVICE_TICKET_POSITION</xsl:element>
          <xsl:element name="value_type">DESIRED_DATE</xsl:element>
          <xsl:element name="allowed_values">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:value-of select="request-param[@name='desiredDate']"/>
              </xsl:element>          	  
            </xsl:element>
          </xsl:element>
          <xsl:element name="operator">LESS</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_found</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>            
        </xsl:element>
      </xsl:element>
      
      <!-- Validate the service subscription state -->
      <xsl:element name="CcmFifValidateServiceSubsStateCmd">
        <xsl:element name="command_id">validate_ss_state_1</xsl:element>
        <xsl:element name="CcmFifValidateServiceSubsStateInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_state">SUBSCRIBED</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_found</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>            
        </xsl:element>
      </xsl:element>
      
      <!-- Validate no uncomplete STPs exist for main access service -->
      <xsl:element name="CcmFifValidateNoUncompleteStpCmd">
        <xsl:element name="command_id">validate_no_uncomplete_stp_1</xsl:element>
        <xsl:element name="CcmFifValidateNoUncompleteStpInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_found</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>
          
      <!-- Validate that the accounts are active  -->
      <xsl:element name="CcmFifValidateServiceAccountCmd">
        <xsl:element name="command_id">validate_ss_account_1</xsl:element>
        <xsl:element name="CcmFifValidateServiceAccountInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>     
      
      <!-- Reconfigure ASAP if no customer order found -->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconf_serv_1</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Bandbreite -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1004</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="substring-after($newDSLBandwidth, 'DSL ')"/>
              </xsl:element>
            </xsl:element>
            <!-- Upstream Bandwidth -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0092</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$newUpstreamBandwidth"/>
              </xsl:element>
            </xsl:element>            
            <!-- Allow Downgrade -->
            <xsl:if test="request-param[@name='allowDowngrade'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">I1005</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='allowDowngrade']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Auftragsvariante -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1011</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Leistungsänderung</xsl:element>
            </xsl:element>                                  
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$desiredDateOPM"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_found</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Reconfigure the main access service on desired date DSLR scenario if a customer order found -->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconf_serv_1</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$oldBandwidthTerminationDate"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
          <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Bandbreite -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1004</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="substring-after($newDSLBandwidth, 'DSL ')"/>
              </xsl:element>
            </xsl:element>
            <!-- Upstream Bandwidth -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0092</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$newUpstreamBandwidth"/>
              </xsl:element>
            </xsl:element>            
            <!-- Allow Downgrade -->
            <xsl:if test="request-param[@name='allowDowngrade'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">I1005</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='allowDowngrade']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Auftragsvariante -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1011</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Leistungsänderung</xsl:element>
            </xsl:element>                                  
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$desiredDateOPM"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_found</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Find the DSL bandwidth service for DSLR-->
      <xsl:element name="CcmFifFindExclusiveChildServSubsCmd">
        <xsl:element name="command_id">find_excl_child_2</xsl:element>
        <xsl:element name="CcmFifFindExclusiveChildServSubsInCont">
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code_list">
            <!-- DSL 384 Standard -->
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0133</xsl:element>
            </xsl:element>
            <!-- DSL 768 Premium -->
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0116</xsl:element>
            </xsl:element>	
            <!-- DSL 1500 Gold -->		  
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0117</xsl:element>
            </xsl:element>
            <!-- DSL 1000 -->		  
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0118</xsl:element>
            </xsl:element>
            <!-- DSL 2000 -->		  
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0174</xsl:element>
            </xsl:element>
            <!-- DSL 3000 -->		  
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0175</xsl:element>
            </xsl:element>
            <!-- DSL 6000 -->		  
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0178</xsl:element>
            </xsl:element>
            <!-- DSL 16000 -->		  
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V018C</xsl:element>
            </xsl:element>  
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      
      <!-- find an open customer order for the bandwidth service
      	   to validate that it is not activated yet -->
      <xsl:element name="CcmFifFindCustomerOrderCmd">
        <xsl:element name="command_id">find_bandwidth_service_1</xsl:element>
        <xsl:element name="CcmFifFindCustomerOrderInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">find_excl_child_2</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="reason_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">RELOCATION</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">DSL_MIGRATION</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="state_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">ASSIGNED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">RELEASED</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="allow_children">N</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Terminate upstream bandwidth service -->
      <xsl:if test="($newDSLBandwidth = $oldDSLBandwidth)
                    and ($newUpstreamBandwidth != $oldUpstreamBandwidth)
                    and ($oldUpstreamBandwidth != 'Standard')">
          <!-- Only terminate if  the upstream bandwidth is changing and the DSL bandwidth is not changing -->
          <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
            <xsl:element name="command_id">term_ss_1</xsl:element>
            <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
              <xsl:element name="service_subscription_ref">
                <xsl:element name="command_id">find_excl_child_2</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="no_child_error_ind">N</xsl:element>
              <xsl:element name="desired_date">
                <xsl:if test="request-param[@name='desiredDate'] != $today">
                  <xsl:value-of select="$oldBandwidthTerminationDate"/>
                </xsl:if>
                <xsl:if test="request-param[@name='desiredDate'] = $today">
                  <xsl:value-of select="request-param[@name='desiredDate']"/>
                </xsl:if>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
              <xsl:element name="service_code_list">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="service_code">V0196</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="service_code">V0197</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="service_code">V0198</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="service_code">V0199</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_bandwidth_service_1</xsl:element>
                <xsl:element name="field_name">customer_order_found</xsl:element>          	
              </xsl:element>
              <xsl:element name="required_process_ind">N</xsl:element>            
            </xsl:element>
          </xsl:element>
      </xsl:if>
     
      <!-- Terminate/cancel DSL Bandwidth Services -->
      <xsl:if test="$newDSLBandwidth != $oldDSLBandwidth">
        <!-- cancel one service ticket position -->
        <xsl:element name="CcmFifCancelServiceTicketPositionCmd">
          <xsl:element name="command_id">cancel_bandwidth_service_1</xsl:element>
          <xsl:element name="CcmFifCancelServiceTicketPositionInCont">
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_bandwidth_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>          	
            </xsl:element>
            <xsl:element name="cancel_reason_rd">CUST_REQUEST</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_bandwidth_service_1</xsl:element>
              <xsl:element name="field_name">customer_order_found</xsl:element>          	
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>            
          </xsl:element>
        </xsl:element>
        
        <!-- Only terminate if the DSL bandwidth is changing for DSLR-->          
        <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
          <xsl:element name="command_id">term_ss_1</xsl:element>
          <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="no_child_error_ind">N</xsl:element>
            <xsl:element name="desired_date">
              <xsl:if test="request-param[@name='desiredDate'] != $today">
                <xsl:value-of select="$oldBandwidthTerminationDate"/>
              </xsl:if>
              <xsl:if test="request-param[@name='desiredDate'] = $today">
                <xsl:value-of select="request-param[@name='desiredDate']"/>
              </xsl:if>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
            <xsl:element name="service_code_list">
              <!-- DSL 384 -->
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0133</xsl:element>
              </xsl:element>
              <!-- DSL 768 -->
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0116</xsl:element>
              </xsl:element>	
              <!-- DSL 1500 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0117</xsl:element>
              </xsl:element>
              <!-- DSL 1000 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0118</xsl:element>
              </xsl:element>
              <!-- DSL 2000 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0174</xsl:element>
              </xsl:element>
              <!-- DSL 3000 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0175</xsl:element>
              </xsl:element>
              <!-- DSL 6000 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0178</xsl:element>
              </xsl:element>
              <!-- DSL 16000 -->		  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V018C</xsl:element>
              </xsl:element>  
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_bandwidth_service_1</xsl:element>
              <xsl:element name="field_name">customer_order_found</xsl:element>          	
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>
          </xsl:element>
        </xsl:element>
        
      </xsl:if>
      
      <!-- Add New DSL Bandwidth Service -->
      <xsl:if test="($newDSLBandwidth= 'DSL 1000')
        or ($newDSLBandwidth= 'DSL 1500')
        or ($newDSLBandwidth= 'DSL 2000')
        or ($newDSLBandwidth= 'DSL 3000')
        or ($newDSLBandwidth= 'DSL 6000')
        or ($newDSLBandwidth= 'DSL 16000')">
        <xsl:if test="$newDSLBandwidth != $oldDSLBandwidth">
       
            <xsl:element name="CcmFifAddServiceSubsCmd">
            <xsl:element name="command_id">add_service_1</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:if test="$newDSLBandwidth = 'DSL 1000'">
                <xsl:element name="service_code">V0118</xsl:element>
              </xsl:if>
              <xsl:if test="$newDSLBandwidth = 'DSL 1500'">
                <xsl:element name="service_code">V0117</xsl:element>
              </xsl:if>
              <xsl:if test="$newDSLBandwidth = 'DSL 2000'">
                <xsl:element name="service_code">V0174</xsl:element>
              </xsl:if>
              <xsl:if test="$newDSLBandwidth = 'DSL 3000'">
                <xsl:element name="service_code">V0175</xsl:element>
              </xsl:if>
              <xsl:if test="$newDSLBandwidth = 'DSL 6000'">
                <xsl:element name="service_code">V0178</xsl:element>
              </xsl:if>
              <xsl:if test="$newDSLBandwidth = 'DSL 16000'">
                <xsl:element name="service_code">V018C</xsl:element>
              </xsl:if>            
              <xsl:element name="sales_organisation_number">
                <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
              </xsl:element>                                          
              <xsl:element name="sales_organisation_number_vf">
                <xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
              </xsl:element>                                          
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="request-param[@name='desiredDate']"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
              <!-- if changeDSLBandwidthAndTariff modify contract  -->
              <xsl:if test="request-param[@name='changeDSLBandwidthAndTariff'] = 'Y'">
                <xsl:element name="use_current_pc_version">Y</xsl:element>
              </xsl:if>
              <xsl:element name="service_characteristic_list">
              </xsl:element>
            </xsl:element>
          </xsl:element>
          </xsl:if>
       </xsl:if>
       
      <!-- Add Upstream Service, if requested -->
      <xsl:if test="$newDSLBandwidth != ''
        and $newUpstreamBandwidth != ''
        and $newUpstreamBandwidth != 'Standard'">
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_2</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:if test="$newUpstreamBandwidth = '256'">
              <xsl:element name="service_code">V0196</xsl:element>
            </xsl:if>
            <xsl:if test="$newUpstreamBandwidth = '384'
              and $newDSLBandwidth = 'DSL 1500'">
              <xsl:element name="service_code">V0197</xsl:element>
            </xsl:if>
            <xsl:if test="$newUpstreamBandwidth = '384'
              and $newDSLBandwidth != 'DSL 1500'">
              <xsl:element name="service_code">V0198</xsl:element>
            </xsl:if>
            <xsl:if test="$newUpstreamBandwidth = '512'">
              <xsl:element name="service_code">V0199</xsl:element>
            </xsl:if>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
                <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
            <!-- if changeDSLBandwidthAndTariff modify contract  -->
            <xsl:if test="request-param[@name='changeDSLBandwidthAndTariff'] = 'Y'">
              <xsl:element name="use_current_pc_version">Y</xsl:element>
            </xsl:if>
            <xsl:element name="service_characteristic_list">
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
	  <!-- Create Hardware Delivery Address, if needed -->
	  <xsl:if test="(request-param[@name='sendNewModem'] = 'Y') and (request-param[@name='hardwareDeliveryAddressID'] = '')">
		  <xsl:element name="CcmFifGetEntityCmd">
			<xsl:element name="command_id">get_entity_1</xsl:element>
			<xsl:element name="CcmFifGetEntityInCont">
			  <xsl:element name="customer_number_ref">
			    <xsl:element name="command_id">find_service_1</xsl:element>
			    <xsl:element name="field_name">customer_number</xsl:element>
			  </xsl:element>
			</xsl:element>
		  </xsl:element>
		  <xsl:element name="CcmFifCreateAddressCmd">
			<xsl:element name="command_id">create_addr_1</xsl:element>
			<xsl:element name="CcmFifCreateAddressInCont">
			  <xsl:element name="entity_ref">
				<xsl:element name="command_id">get_entity_1</xsl:element>
				<xsl:element name="field_name">entity_id</xsl:element>
			  </xsl:element>
			  <xsl:element name="address_type">HARD</xsl:element>
			  <xsl:element name="street_name">
				<xsl:value-of select="request-param[@name='hardwareDeliveryStreet']"/>
			  </xsl:element>
			  <xsl:element name="street_number">
				<xsl:value-of select="request-param[@name='hardwareDeliveryNumber']"/>
			  </xsl:element>
			  <xsl:element name="street_number_suffix">
				<xsl:value-of select="request-param[@name='hardwareDeliveryNumberSuffix']"/>
			  </xsl:element>
			  <xsl:element name="postal_code">
				<xsl:value-of select="request-param[@name='hardwareDeliveryPostalCode']"/>
			  </xsl:element>
			  <xsl:element name="city_name">
				<xsl:value-of select="request-param[@name='hardwareDeliveryCity']"/>
			  </xsl:element>
			  <xsl:element name="city_suffix_name">
				<xsl:value-of select="request-param[@name='hardwareDeliveryCitySuffix']"/>
			  </xsl:element>
			  <xsl:element name="country_code">DE</xsl:element>
			</xsl:element>
		  </xsl:element>
	  </xsl:if>		

	  		
      <!-- Add Modem Service, if needed -->
      <xsl:if test="request-param[@name='sendNewModem'] = 'Y'">
        
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_3</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V0114</xsl:element>
            <xsl:element name="sales_organisation_number">
                <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
            </xsl:element>                                                      
            <xsl:element name="sales_organisation_number_vf">
              <xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
            </xsl:element>                                          
            <xsl:element name="desired_date">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
            <xsl:element name="reason_rd">CHANGE_BANDWIDTH</xsl:element>
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
            <!-- if changeDSLBandwidthAndTariff modify contract  -->
            <xsl:if test="request-param[@name='changeDSLBandwidthAndTariff'] = 'Y'">
              <xsl:element name="use_current_pc_version">Y</xsl:element>
            </xsl:if>
            <xsl:element name="service_characteristic_list">
              <!-- Liefername -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0110</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='hardwareDeliverySalutation']"/>
                  <xsl:text>;</xsl:text>
                  <xsl:value-of select="request-param[@name='hardwareDeliverySurname']"/>
                  <xsl:text>;</xsl:text>
                  <xsl:value-of select="request-param[@name='hardwareDeliveryForename']"/>
                </xsl:element>
              </xsl:element>
              <!-- Lieferanschrift -->
              <xsl:element name="CcmFifAddressCharacteristicCont">
                <xsl:element name="service_char_code">V0111</xsl:element>
                <xsl:element name="data_type">ADDRESS</xsl:element>
				<xsl:if test="request-param[@name='hardwareDeliveryAddressID'] != ''"> 
					<xsl:element name="address_id">
					  <xsl:value-of select="request-param[@name='hardwareDeliveryAddressID']"/>
					</xsl:element>
				</xsl:if>
				<xsl:if test="request-param[@name='hardwareDeliveryAddressID'] = ''"> 
					<xsl:element name="address_ref">
					  <xsl:element name="command_id">create_addr_1</xsl:element>
					  <xsl:element name="field_name">address_id</xsl:element>
					</xsl:element>
				</xsl:if>
              </xsl:element>
              <!-- Artikelnummer -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0112</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='modemArticleNumber']"/>
                </xsl:element>
              </xsl:element>
              <!-- Subventionierungskennzeichen -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0114</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='modemSubventionIndicator']"/>
                </xsl:element>
              </xsl:element>
              <!-- Artikelbezeichnung -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0116</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='modemType']"/>
                </xsl:element>
              </xsl:element>
              <!-- Zahlungsoption -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0119</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">RG</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Create Customer Order for Termination -->
      <xsl:if test="(($newDSLBandwidth = $oldDSLBandwidth)
                    and ($newUpstreamBandwidth != $oldUpstreamBandwidth)
                    and ($oldUpstreamBandwidth != 'Standard'))
                    or ($newDSLBandwidth != $oldDSLBandwidth)">
        <xsl:element name="CcmFifCreateCustOrderCmd">
          <xsl:element name="command_id">create_co_1</xsl:element>
          <xsl:element name="CcmFifCreateCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="cust_order_description">Bandbreitenwechsel</xsl:element>
            <xsl:element name="customer_tracking_id">
              <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
            </xsl:element>
            <xsl:element name="provider_tracking_no">
              <xsl:choose>
                <xsl:when test="request-param[@name='providerTrackingNumberChange'] != ''">
                  <xsl:value-of select="request-param[@name='providerTrackingNumberChange']" />
                </xsl:when>
                <xsl:otherwise>001</xsl:otherwise>
              </xsl:choose>
            </xsl:element>			  	
            <xsl:element name="ignore_empty_list_ind">Y</xsl:element>            
            <xsl:element name="service_ticket_pos_list">
              <!-- DSL service termination -->
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">term_ss_1</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
              </xsl:element>
              <!-- Reconfiguration of main access service -->
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">reconf_serv_1</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>              
              <!-- New Modem -->
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_3</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>              
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      

      <!-- Create Customer Order for new services  -->
     <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_2</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="cust_order_description">Bandbreitenwechsel</xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="provider_tracking_no">
            <xsl:choose>
              <xsl:when test="request-param[@name='providerTrackingNumberDefault'] != ''">
                <xsl:value-of select="request-param[@name='providerTrackingNumberDefault']" />
              </xsl:when>
              <xsl:otherwise>002</xsl:otherwise>
            </xsl:choose>
          </xsl:element>			  	
          <xsl:element name="service_ticket_pos_list">
            <!-- DSL Bandwidth change -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <!-- Upstream bandwidth change -->
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_2</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>           
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Release Customer Orders dependent on a relocation or DSL migration, if exists -->
      <xsl:if test="(($newDSLBandwidth = $oldDSLBandwidth)
                    and ($newUpstreamBandwidth != $oldUpstreamBandwidth)
                    and ($oldUpstreamBandwidth != 'Standard'))
                    or ($newDSLBandwidth != $oldDSLBandwidth)">
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="CcmFifReleaseCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">create_co_1</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_customer_order_1</xsl:element>
              <xsl:element name="field_name">customer_order_found</xsl:element>          	
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>            
            <xsl:element name="parent_customer_order_id_ref">
              <xsl:element name="command_id">find_customer_order_1</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>          	
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_2</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_found</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>            
          <xsl:element name="parent_customer_order_id_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>          	
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- get default release delay dates -->
      <xsl:variable name="releaseDelayDateADSL2"
        select="dateutils:createFIFDateOffset(request-param[@name='desiredDate'], 'DATE', request-param[@name='releaseDelayOffsetADSL2'])"/>
      <xsl:variable name="releaseDelayDateDSL"
        select="dateutils:createFIFDateOffset(request-param[@name='desiredDate'], 'DATE', request-param[@name='releaseDelayOffsetDSL'])"/>

      <!-- Release Customer Orders delayed, if no other pending customer order for main access exists -->
      <xsl:if test="(($newDSLBandwidth = $oldDSLBandwidth)
                    and ($newUpstreamBandwidth != $oldUpstreamBandwidth)
                    and ($oldUpstreamBandwidth != 'Standard'))
                    or ($newDSLBandwidth != $oldDSLBandwidth)">
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="CcmFifReleaseCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">create_co_1</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="ignore_empty_list_ind">Y</xsl:element>            
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_customer_order_1</xsl:element>
              <xsl:element name="field_name">customer_order_found</xsl:element>          	
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>            
            <!-- set the release delay date depending on the new bandwidth -->
            <xsl:element name="release_delay_date">
              <xsl:if test="($newDSLBandwidth = 'DSL 16000')">
                <xsl:value-of select="$releaseDelayDateADSL2"/>	
              </xsl:if>
              <xsl:if test="($newDSLBandwidth != 'DSL 16000')">
                <xsl:value-of select="$releaseDelayDateDSL"/>	
              </xsl:if>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_2</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_found</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>            
          <xsl:element name="parent_customer_order_id_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>          	
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">CHANGE_BANDWIDTH</xsl:element>
          <xsl:element name="short_description">Bandbreitenwechsel</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;User name: </xsl:text>
            <xsl:value-of select="request-param[@name='userName']"/>
            <xsl:if test="request-param[@name='rollenBezeichnung'] != ''">
              <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
              <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
            </xsl:if>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:if test="request-param[@name='clientName'] != 'KBA'">
      <!-- Create KBA notification, if the request is not a KBA request -->
      <xsl:element name="CcmFifCreateExternalNotificationCmd">
        <xsl:element name="command_id">create_kba_notification_1</xsl:element>
        <xsl:element name="CcmFifCreateExternalNotificationInCont">
          <xsl:element name="effective_date">
            <xsl:if test="request-param[@name='desiredDate'] != ''">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:if>
            <xsl:if test="request-param[@name='desiredDate'] = ''">
              <xsl:value-of select="$today"/>
            </xsl:if>
          </xsl:element>
          <xsl:element name="notification_action_name">createKBANotification</xsl:element>
          <xsl:element name="target_system">KBA</xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TYPE</xsl:element>
              <xsl:element name="parameter_value">CONTACT</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CATEGORY</xsl:element>
              <xsl:element name="parameter_value">Bandwidth</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">USER_NAME</xsl:element>
              <xsl:element name="parameter_value">
              	<xsl:value-of select="request-param[@name='clientName']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">WORK_DATE</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:if test="request-param[@name='desiredDate'] != ''">
                  <xsl:value-of select="request-param[@name='desiredDate']"/>
                </xsl:if>
                <xsl:if test="request-param[@name='desiredDate'] = ''">
                  <xsl:value-of select="$today"/>
                </xsl:if>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TEXT</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:text>Bandbreitenwechsel über </xsl:text>
                <xsl:value-of select="request-param[@name='clientName']"/>
                <xsl:text> von </xsl:text>
                <xsl:value-of select="$oldDSLBandwidth"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="$oldUpstreamBandwidth"/>
                <xsl:text> zu </xsl:text>
                <xsl:value-of select="$newDSLBandwidth"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="$newUpstreamBandwidth"/>
                <xsl:text>.</xsl:text>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      
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
          <xsl:element name="notification_action_name">ChangeDSLBandwidth</xsl:element>
          <xsl:element name="target_system">FIF</xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SERVICE_SUBSCRIPTION_ID</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
            </xsl:element>	
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">DSLR_SERVICE_SUBSCRIPTION_ID</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
            </xsl:element>            						  
            <xsl:if test="request-param[@name='functionID'] != ''">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">
                  <xsl:value-of select="request-param[@name='functionID']"/>
                  <xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
                </xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">create_co_2</xsl:element>
                  <xsl:element name="field_name">customer_order_id</xsl:element>
                </xsl:element>
              </xsl:element>              
            </xsl:if>							  
          </xsl:element>          
        </xsl:element>
      </xsl:element>  
      
      <xsl:if test="request-param[@name='functionID'] != ''">
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_notification_2</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="effective_date">
              <xsl:value-of select="$today"/>
            </xsl:element>
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="processed_indicator">Y</xsl:element>
            <xsl:element name="notification_action_name">
              <xsl:value-of select="//request/action-name"/>
            </xsl:element>
            <xsl:element name="target_system">FIF</xsl:element>
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">
                  <xsl:value-of select="request-param[@name='functionID']"/>
                  <xsl:text>_TERM_CUSTOMER_ORDER_ID</xsl:text>
                </xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">create_co_1</xsl:element>
                  <xsl:element name="field_name">customer_order_id</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">create_co_1</xsl:element>
              <xsl:element name="field_name">customer_order_created</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- if changeDSLBandwidthAndTariff modify contract  -->
      <xsl:if test="request-param[@name='changeDSLBandwidthAndTariff'] = 'Y'">
        &ModifyContractSignAndApply;
      </xsl:if>
      
      <xsl:if test="request-param[@name='functionID'] != ''">
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
      </xsl:if>               
  </xsl:element>

</xsl:element>   

