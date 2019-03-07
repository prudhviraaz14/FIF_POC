<xsl:element name="CcmFifCommandList">
	<xsl:element name="transaction_id">
		<xsl:value-of select="request-param[@name='transactionID']"/>
	</xsl:element>
	<xsl:element name="client_name">
		<xsl:value-of select="request-param[@name='clientName']"/>
	</xsl:element>
	<xsl:variable name="TopAction" select="//request/action-name"/>
	<xsl:element name="action_name">
		<xsl:value-of select="concat($TopAction, '_VoIP')"/>
	</xsl:element>   
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='overrideSystemDate']"/>
    </xsl:element>
    <xsl:element name="Command_List">

      <!-- Ensure that the paramter orderVariant is set to "Wechsel nach TAL" if provided -->
      <xsl:if test="request-param[@name='orderVariant'] != ''
        and request-param[@name='orderVariant'] != 'Wechsel nach TAL'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The paramter orderVariant can be set to 'Wechsel nach TAL' only! </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if> 
      
      <!-- find the service by the ss id -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Ensure that the termination has not been performed before -->
      <xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
        <xsl:element name="command_id">find_cancel_stp_1</xsl:element>
        <xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="reason_rd">TERMINATION</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- if moveNumbersToTarget set -->
      <xsl:if test="(request-param[@name='moveNumbersToTarget'] = 'Y')">

        <!-- check for termination/cancelation -->
        <xsl:element name="CcmFifFindServiceTicketPositionCmd">
          <xsl:element name="command_id">find_stp_val_1</xsl:element>
          <xsl:element name="CcmFifFindServiceTicketPositionInCont">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="request-param[@name='targetVoiceSubscriptionID']"/>
            </xsl:element>
            <xsl:element name="no_stp_error">N</xsl:element>
            <xsl:element name="find_stp_parameters">
              <xsl:element name="CcmFifFindStpParameterCont">
                <xsl:element name="service_code">VI006</xsl:element>
                <xsl:element name="usage_mode_value_rd">1</xsl:element>
                <xsl:element name="customer_order_state">RELEASED</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifFindStpParameterCont">
                <xsl:element name="service_code">VI006</xsl:element>
                <xsl:element name="usage_mode_value_rd">1</xsl:element>
                <xsl:element name="customer_order_state">COMPLETED</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifFindStpParameterCont">
                <xsl:element name="service_code">VI006</xsl:element>
                <xsl:element name="usage_mode_value_rd">1</xsl:element>
                <xsl:element name="customer_order_state">FINAL</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifFindStpParameterCont">
                <xsl:element name="service_code">VI009</xsl:element>
                <xsl:element name="usage_mode_value_rd">1</xsl:element>
                <xsl:element name="customer_order_state">RELEASED</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifFindStpParameterCont">
                <xsl:element name="service_code">VI009</xsl:element>
                <xsl:element name="usage_mode_value_rd">1</xsl:element>
                <xsl:element name="customer_order_state">COMPLETED</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifFindStpParameterCont">
                <xsl:element name="service_code">VI009</xsl:element>
                <xsl:element name="usage_mode_value_rd">1</xsl:element>
                <xsl:element name="customer_order_state">FINAL</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>			
        
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">raise_error_val_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Could not find VI006 or VI009 service indicated via customerOrderID.</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_stp_val_1</xsl:element>
              <xsl:element name="field_name">stp_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_val_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">    			
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_stp_val_1</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="no_service_error">N</xsl:element>
          </xsl:element>
        </xsl:element>

        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">raise_error_val_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Could not find VI006 or VI009 service indicated via customerOrderID.</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_service_val_1</xsl:element>
              <xsl:element name="field_name">service_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>
          </xsl:element>
        </xsl:element>

        <xsl:element name="CcmFifMapStringCmd">
          <xsl:element name="command_id">map_sc_move_num_mode</xsl:element>
          <xsl:element name="CcmFifMapStringInCont">
            <xsl:element name="input_string_type">serviceCode;moveNumbersMode</xsl:element>
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_service_val_1</xsl:element>
                <xsl:element name="field_name">service_code</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">;</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">							
                  <xsl:value-of select="request-param[@name='moveNumbersMode']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="output_string_type"></xsl:element>
            <xsl:element name="string_mapping_list">
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">VI006;ADD</xsl:element>
                <xsl:element name="output_string">Y</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">VI006;REPLACE</xsl:element>
                <xsl:element name="output_string">Y</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">VI009;ADD</xsl:element>
                <xsl:element name="output_string">N</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">VI009;REPLACE</xsl:element>
                <xsl:element name="output_string">Y</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="no_mapping_error">Y</xsl:element>
          </xsl:element>
        </xsl:element>

        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">raise_error_val_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Parameter moveNumbersToTarget for Basis is only allowed with mode REPLACE, not ADD.</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">map_sc_move_num_mode</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- get data from STP -->
        <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
          <xsl:element name="command_id">get_stp_data_1</xsl:element>
          <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_stp_val_1</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_stp_val_1</xsl:element>
              <xsl:element name="field_name">stp_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element>							
        
        <xsl:element name="CcmFifFindServCharValueForServCharCmd">
          <xsl:element name="command_id">find_serv_char_val_V0909</xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharInCont">
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_stp_val_1</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_char_code">V0909</xsl:element>
            <xsl:element name="no_csc_error">Y</xsl:element>
            <xsl:element name="retrieve_all_characteristics">Y</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_stp_val_1</xsl:element>
              <xsl:element name="field_name">stp_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- choose later date of VoIP termination and BitVoIP SS OPM desired date-->
        <xsl:element name="CcmFifValidateDateCmd">
          <xsl:element name="command_id">check_due_date_1</xsl:element>
          <xsl:element name="CcmFifValidateDateInCont">
            <xsl:element name="value_ref">
              <xsl:element name="command_id">find_serv_char_val_V0909</xsl:element> 
              <xsl:element name="field_name">characteristic_value</xsl:element> 
            </xsl:element>
            <xsl:element name="allowed_values">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">
                  <xsl:value-of select="request-param[@name='terminationDate']"/>
                </xsl:element>							
              </xsl:element>
            </xsl:element>
            <xsl:element name="operator">GREATER</xsl:element>
            <xsl:element name="raise_error_if_invalid">N</xsl:element>							
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_stp_val_1</xsl:element>
              <xsl:element name="field_name">stp_found</xsl:element>							
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element>							

        <!-- Find an service characteristic value required in notification -->
        <xsl:element name="CcmFifFindServiceTicketPositionCmd">
          <xsl:element name="command_id">find_stp_1</xsl:element>
          <xsl:element name="CcmFifFindServiceTicketPositionInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="no_stp_error">N</xsl:element>
            <xsl:element name="find_stp_parameters">
              <xsl:element name="CcmFifFindStpParameterCont">
                <xsl:element name="service_code">VI201</xsl:element>
                <xsl:element name="usage_mode_value_rd">2</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifFindStpParameterCont">
                <xsl:element name="service_code">VI201</xsl:element>
                <xsl:element name="usage_mode_value_rd">1</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>

        <!-- Find an service characteristic value required in notification -->
        <xsl:element name="CcmFifFindServCharValueForServCharCmd">
          <xsl:element name="command_id">find_serv_char_val_V0001</xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharInCont">
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_stp_1</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_char_code">V0001</xsl:element>
            <xsl:element name="no_csc_error">N</xsl:element>
            <xsl:element name="retrieve_all_characteristics">Y</xsl:element>
            </xsl:element>
        </xsl:element>
        <!-- Find an service characteristic value required in notification -->
        <xsl:element name="CcmFifFindServCharValueForServCharCmd">
          <xsl:element name="command_id">find_serv_char_val_V0070</xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharInCont">
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_stp_1</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_char_code">V0070</xsl:element>
            <xsl:element name="no_csc_error">N</xsl:element>
            <xsl:element name="retrieve_all_characteristics">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        <!-- Find an service characteristic value required in notification -->
        <xsl:element name="CcmFifFindServCharValueForServCharCmd">
          <xsl:element name="command_id">find_serv_char_val_V0071</xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharInCont">
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_stp_1</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_char_code">V0071</xsl:element>
            <xsl:element name="no_csc_error">N</xsl:element>
            <xsl:element name="retrieve_all_characteristics">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        <!-- Find an service characteristic value required in notification -->
        <xsl:element name="CcmFifFindServCharValueForServCharCmd">
          <xsl:element name="command_id">find_serv_char_val_V0072</xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharInCont">
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_stp_1</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_char_code">V0072</xsl:element>
            <xsl:element name="no_csc_error">N</xsl:element>
            <xsl:element name="retrieve_all_characteristics">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        <!-- Find an service characteristic value required in notification -->
        <xsl:element name="CcmFifFindServCharValueForServCharCmd">
          <xsl:element name="command_id">find_serv_char_val_V0073</xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharInCont">
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_stp_1</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_char_code">V0073</xsl:element>
            <xsl:element name="no_csc_error">N</xsl:element>
            <xsl:element name="retrieve_all_characteristics">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        <!-- Find an service characteristic value required in notification -->
        <xsl:element name="CcmFifFindServCharValueForServCharCmd">
          <xsl:element name="command_id">find_serv_char_val_V0074</xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharInCont">
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_stp_1</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_char_code">V0074</xsl:element>
            <xsl:element name="no_csc_error">N</xsl:element>
            <xsl:element name="retrieve_all_characteristics">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        <!-- Find an service characteristic value required in notification -->
        <xsl:element name="CcmFifFindServCharValueForServCharCmd">
          <xsl:element name="command_id">find_serv_char_val_V0075</xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharInCont">
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_stp_1</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_char_code">V0075</xsl:element>
            <xsl:element name="no_csc_error">N</xsl:element>
            <xsl:element name="retrieve_all_characteristics">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        <!-- Find an service characteristic value required in notification -->
        <xsl:element name="CcmFifFindServCharValueForServCharCmd">
          <xsl:element name="command_id">find_serv_char_val_V0076</xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharInCont">
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_stp_1</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_char_code">V0076</xsl:element>
            <xsl:element name="no_csc_error">N</xsl:element>
            <xsl:element name="retrieve_all_characteristics">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        <!-- Find an service characteristic value required in notification -->
        <xsl:element name="CcmFifFindServCharValueForServCharCmd">
          <xsl:element name="command_id">find_serv_char_val_V0077</xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharInCont">
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_stp_1</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_char_code">V0077</xsl:element>
            <xsl:element name="no_csc_error">N</xsl:element>
            <xsl:element name="retrieve_all_characteristics">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        <!-- Find an service characteristic value required in notification -->
        <xsl:element name="CcmFifFindServCharValueForServCharCmd">
          <xsl:element name="command_id">find_serv_char_val_V0078</xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharInCont">
            <xsl:element name="service_ticket_position_id_ref">
              <xsl:element name="command_id">find_stp_1</xsl:element>
              <xsl:element name="field_name">service_ticket_position_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_char_code">V0078</xsl:element>
            <xsl:element name="no_csc_error">N</xsl:element>
            <xsl:element name="retrieve_all_characteristics">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- create ccm_fif_request for modifyVoIP transaction -->
        <xsl:element name="CcmFifCreateFifRequestCmd">
          <xsl:element name="command_id">create_fif_request_1</xsl:element> 
          <xsl:element name="CcmFifCreateFifRequestInCont">
            <xsl:element name="action_name">modifyVoIP</xsl:element> 
            <xsl:element name="due_date">
              <xsl:value-of select="request-param[@name='terminationDate']"/>
            </xsl:element>
            <xsl:element name="offset_days">1</xsl:element> 
            <xsl:element name="dependent_transaction_id">dummy</xsl:element>
            <xsl:element name="priority">6</xsl:element>
            <xsl:element name="bypass_command">N</xsl:element>
            <xsl:element name="external_system_id_ref">
              <xsl:element name="command_id">find_service_val_1</xsl:element> 
              <xsl:element name="field_name">service_subscription_id</xsl:element> 
            </xsl:element>
            <xsl:element name="request_param_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">SERVICE_SUBSCRIPTION_ID</xsl:element> 
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_service_val_1</xsl:element> 
                  <xsl:element name="field_name">service_subscription_id</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">SOURCE_SERVICE_SUBSCRIPTION_ID</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element> 
                  <xsl:element name="field_name">service_subscription_id</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">PROCESSING_MODE</xsl:element> 
                <xsl:element name="parameter_value">
                    <xsl:value-of select="request-param[@name='moveNumbersMode']"/>
                </xsl:element>
              </xsl:element>                 
            </xsl:element>                 
            <xsl:element name="additional_param_list_name">ACCESS_NUMBER_LIST</xsl:element>            
            <xsl:element name="additional_param_list">           
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_1</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0001</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_2</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0070</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_3</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0071</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_4</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0072</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_5</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0073</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_6</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0074</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_7</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0075</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_8</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0076</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_9</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0077</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_10</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0078</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
            </xsl:element>          
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">check_due_date_1</xsl:element>
              <xsl:element name="field_name">is_valid</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>										
          </xsl:element>
        </xsl:element>
        
        <!-- create ccm_fif_request for modifyVoIP transaction -->
        <xsl:element name="CcmFifCreateFifRequestCmd">
          <xsl:element name="command_id">create_fif_request_1</xsl:element> 
          <xsl:element name="CcmFifCreateFifRequestInCont">
            <xsl:element name="action_name">modifyVoIP</xsl:element> 
            <xsl:element name="due_date_ref">
              <xsl:element name="command_id">find_serv_char_val_V0909</xsl:element> 
              <xsl:element name="field_name">characteristic_value</xsl:element> 
            </xsl:element> 
            <xsl:element name="offset_days">1</xsl:element> 
            <xsl:element name="dependent_transaction_id">dummy</xsl:element>
            <xsl:element name="priority">6</xsl:element>
            <xsl:element name="bypass_command">N</xsl:element>
            <xsl:element name="external_system_id_ref">
              <xsl:element name="command_id">find_service_val_1</xsl:element> 
              <xsl:element name="field_name">service_subscription_id</xsl:element> 
            </xsl:element>
            <xsl:element name="request_param_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">SERVICE_SUBSCRIPTION_ID</xsl:element> 
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_service_val_1</xsl:element> 
                  <xsl:element name="field_name">service_subscription_id</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">SOURCE_SERVICE_SUBSCRIPTION_ID</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element> 
                  <xsl:element name="field_name">service_subscription_id</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">PROCESSING_MODE</xsl:element> 
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='moveNumbersMode']"/>
                </xsl:element>
              </xsl:element>                 
            </xsl:element>                 
            <xsl:element name="additional_param_list_name">ACCESS_NUMBER_LIST</xsl:element>            
            <xsl:element name="additional_param_list">           
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_1</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0001</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_2</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0070</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_3</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0071</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_4</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0072</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_5</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0073</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_6</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0074</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_7</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0075</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_8</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0076</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_9</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0077</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ACCESS_NUMBER_10</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_serv_char_val_V0078</xsl:element> 
                  <xsl:element name="field_name">characteristic_value</xsl:element> 
                </xsl:element>
              </xsl:element>
            </xsl:element>          
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">check_due_date_1</xsl:element>
              <xsl:element name="field_name">is_valid</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>										
          </xsl:element>
        </xsl:element>

      </xsl:if>

      <!-- Reconfigure Service Subscription -->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconf_serv_1</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:if test="request-param[@name='reasonRd'] != ''">
            <xsl:element name="reason_rd">
              <xsl:value-of select="request-param[@name='reasonRd']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='reasonRd'] = ''">
            <xsl:element name="reason_rd">TERMINATION</xsl:element>
          </xsl:if>
          <xsl:element name="service_characteristic_list">
            <!-- Kündigungsgrund -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0137</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='terminationReason']"/>
              </xsl:element>
            </xsl:element>
            <!-- Grund der Neukonfiguration -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">VI008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Vorbereitung zur Kuendigung</xsl:element>
            </xsl:element>
            <!-- Bearbeitungsart -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">VI002</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">OP</xsl:element>
            </xsl:element>
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$terminationDateOPM"/>
              </xsl:element>
            </xsl:element>
            <!-- Neuer TNB -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0061</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='carrier']"/>
              </xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='orderVariant'] != ''">
              <!-- Auftragsvariante  -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">VI021</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>                
                <xsl:element name="configured_value">                
                  <xsl:value-of select="request-param[@name='orderVariant']"/>                
                </xsl:element>
              </xsl:element>
            </xsl:if>           
            <!-- Backporting of VoIP Access Number 1 -->
            <xsl:if test="request-param[@name='portAccessNumber1'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0165</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='portAccessNumber1']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Backporting of VoIP Access Number 2 -->
            <xsl:if test="request-param[@name='portAccessNumber2'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0166</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='portAccessNumber2']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Backporting of VoIP Access Number 3 -->
            <xsl:if test="request-param[@name='portAccessNumber3'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0167</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='portAccessNumber3']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Backporting of VoIP Access Number 4 -->
            <xsl:if test="request-param[@name='portAccessNumber4'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0168</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='portAccessNumber4']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Backporting of VoIP Access Number 5 -->
            <xsl:if test="request-param[@name='portAccessNumber5'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0169</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='portAccessNumber5']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Backporting of VoIP Access Number 6 -->
            <xsl:if test="request-param[@name='portAccessNumber6'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0170</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='portAccessNumber6']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Backporting of VoIP Access Number 7 -->
            <xsl:if test="request-param[@name='portAccessNumber7'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0171</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='portAccessNumber7']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Backporting of VoIP Access Number 8 -->
            <xsl:if test="request-param[@name='portAccessNumber8'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0172</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='portAccessNumber8']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Backporting of VoIP Access Number 9 -->
            <xsl:if test="request-param[@name='portAccessNumber9'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0173</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='portAccessNumber9']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Backporting of VoIP Access Number 10 -->
            <xsl:if test="request-param[@name='portAccessNumber10'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0174</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='portAccessNumber10']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>            
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Add Termination Fee Service -->
      <xsl:if test="request-param[@name='terminationFeeServiceCode'] != ''">
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_1</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">
              <xsl:value-of select="request-param[@name='terminationFeeServiceCode']"/>
            </xsl:element>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:if test="request-param[@name='reasonRd'] != ''">
              <xsl:element name="reason_rd">
                <xsl:value-of select="request-param[@name='reasonRd']"/>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='reasonRd'] = ''">
              <xsl:element name="reason_rd">TERMINATION</xsl:element>
            </xsl:if>
            <xsl:element name="service_characteristic_list">
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>             
      
      <!-- Terminate Product Subscription -->
      <xsl:element name="CcmFifTerminateProductSubsCmd">
        <xsl:element name="command_id">terminate_ps_1</xsl:element>
        <xsl:element name="CcmFifTerminateProductSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="request-param[@name='terminationDate']"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
          <xsl:if test="request-param[@name='reasonRd'] != ''">
            <xsl:element name="reason_rd">
              <xsl:value-of select="request-param[@name='reasonRd']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='reasonRd'] = ''">
            <xsl:element name="reason_rd">TERMINATION</xsl:element>
          </xsl:if>
          <xsl:element name="auto_customer_order">N</xsl:element>
          <xsl:element name="detailed_reason_rd">
            <xsl:value-of select="request-param[@name='terminationReason']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Customer Order for Reconfiguration -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="parent_customer_order_id">
            <xsl:value-of select="$parentCustomerOrderID"/>
          </xsl:element> 
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="lan_path_file_string">
            <xsl:value-of select="request-param[@name='lanPathFileString']"/>
          </xsl:element>
          <xsl:element name="sales_rep_dept">
            <xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
          </xsl:element>				      
<!--          <xsl:if test="request-param[@name='providerTrackingNumber'] = ''" > 
            <xsl:element name="provider_tracking_no">001v</xsl:element> 
          </xsl:if>
          <xsl:if test="request-param[@name='providerTrackingNumber'] != ''">             
            <xsl:element name="provider_tracking_no">
              <xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
            </xsl:element>
          </xsl:if> -->
          <xsl:element name="super_customer_tracking_id">
            <xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
          </xsl:element>
          <xsl:element name="scan_date">
            <xsl:value-of select="request-param[@name='scanDate']"/>
          </xsl:element>
          <xsl:element name="order_entry_date">
            <xsl:value-of select="request-param[@name='entryDate']"/>
          </xsl:element>				      
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconf_serv_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Customer Order for Add Service -->
      <xsl:if test="request-param[@name='terminationFeeServiceCode'] != ''">
        <xsl:element name="CcmFifCreateCustOrderCmd">
          <xsl:element name="command_id">create_co_3</xsl:element>
          <xsl:element name="CcmFifCreateCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="parent_customer_order_ref">
              <xsl:element name="command_id">create_co_1</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="customer_tracking_id">
              <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
            </xsl:element>
            <xsl:element name="lan_path_file_string">
              <xsl:value-of select="request-param[@name='lanPathFileString']"/>
            </xsl:element>
            <xsl:element name="sales_rep_dept">
              <xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
            </xsl:element>
            <xsl:element name="super_customer_tracking_id">
              <xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
            </xsl:element>
            <xsl:element name="scan_date">
              <xsl:value-of select="request-param[@name='scanDate']"/>
            </xsl:element>
            <xsl:element name="order_entry_date">
              <xsl:value-of select="request-param[@name='entryDate']"/>
            </xsl:element>				
            <xsl:element name="service_ticket_pos_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>		  
      
      <!-- Create Customer Order for Termination -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_2</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="parent_customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="lan_path_file_string">
            <xsl:value-of select="request-param[@name='lanPathFileString']"/>
          </xsl:element>
          <xsl:element name="sales_rep_dept">
            <xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
          </xsl:element>					      
          <xsl:if test="request-param[@name='providerTrackingNumber'] = ''" > 
            <xsl:element name="provider_tracking_no">002v</xsl:element> 
          </xsl:if>
          <xsl:if test="request-param[@name='providerTrackingNumber'] != ''">             
            <xsl:element name="provider_tracking_no">
              <xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:element name="super_customer_tracking_id">
            <xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
          </xsl:element>
          <xsl:element name="scan_date">
            <xsl:value-of select="request-param[@name='scanDate']"/>
          </xsl:element>
          <xsl:element name="order_entry_date">
            <xsl:value-of select="request-param[@name='entryDate']"/>
          </xsl:element>			
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">terminate_ps_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Release Customer Order for Reconfiguration -->
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
        </xsl:element>
      </xsl:element>
      
      <!-- Release Customer Order for Add Service -->
      <xsl:if test="request-param[@name='terminationFeeServiceCode'] != ''">
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="CcmFifReleaseCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">create_co_3</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>             
      
      <!-- Release Customer Order for Termination -->
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
        </xsl:element>
      </xsl:element>
      
      <!-- Create Contact for the Service Termination -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
          <xsl:element name="short_description">Automatische Kündigung</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>Kündigung der Produktnutzung für Dienst </xsl:text>
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
            <xsl:text> durch </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/> 
            <xsl:text>.&#xA;TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;User name: </xsl:text>
            <xsl:value-of select="request-param[@name='userName']"/>				  
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
    </xsl:element>
</xsl:element>
