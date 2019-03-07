
      <xsl:if test="request-param[@name='SERVICE_CODE'] = ''">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">missing_parameter</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Following parameter have to be provided: SERVICE_CODE</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>  

      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_ticket_position_id">
            <xsl:value-of select="request-param[@name='SERVICE_TICKET_POSITION_ID']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:if test="request-param[@name='SERVICE_CODE'] != 'I104B'">
        <xsl:element name="CcmFifFindServCharValueForServCharCmd">
          <xsl:element name="command_id">get_csc_data_1</xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharInCont">
            <xsl:element name="service_ticket_position_id">
              <xsl:value-of select="request-param[@name='SERVICE_TICKET_POSITION_ID']"/>
            </xsl:element>
            <xsl:element name="service_char_code">I9058</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:if test="request-param[@name='SERVICE_CODE'] = 'I104B'">
        <!-- Get first the AAA-account -->
        <xsl:element name="CcmFifFindServCharValueForServCharCmd">
          <xsl:element name="command_id">get_csc_data_2</xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharInCont">
            <xsl:element name="service_ticket_position_id">
              <xsl:value-of select="request-param[@name='SERVICE_TICKET_POSITION_ID']"/>
            </xsl:element>
            <xsl:element name="service_char_code">I905A</xsl:element>
          </xsl:element>
        </xsl:element>
                
        <!-- Get the IP-Adress -->
        <xsl:element name="CcmFifFindServCharValueForServCharCmd">
          <xsl:element name="command_id">get_csc_data_3</xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharInCont">
            <xsl:element name="service_ticket_position_id">
              <xsl:value-of select="request-param[@name='SERVICE_TICKET_POSITION_ID']"/>
            </xsl:element>
            <xsl:element name="service_char_code">I905B</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
        <xsl:element name="command_id">get_stp_data_1</xsl:element>
        <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
          <xsl:element name="service_ticket_position_id">
            <xsl:value-of select="request-param[@name='SERVICE_TICKET_POSITION_ID']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:element name="CcmFifMapStringCmd">
        <xsl:element name="command_id">map_create_notification</xsl:element>
        <xsl:element name="CcmFifMapStringInCont">
          <xsl:element name="input_string_type">ReasonRd</xsl:element>
          <xsl:element name="input_string_ref">
            <xsl:element name="command_id">get_stp_data_1</xsl:element>
            <xsl:element name="field_name">reason_rd</xsl:element>
          </xsl:element>
          <xsl:element name="output_string_type">ReasonRd</xsl:element>
          <xsl:element name="string_mapping_list">
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">DSLTERM_NO_DEACT</xsl:element>
              <xsl:element name="output_string">N</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="no_mapping_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifGetCustomerOrderDataCmd">
        <xsl:element name="command_id">get_co_data_1</xsl:element>
        <xsl:element name="CcmFifGetCustomerOrderDataInCont">
          <xsl:element name="customer_order_id_ref">
            <xsl:element name="command_id">get_stp_data_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:element name="CcmFifGetProductCommitmentDataCmd">
        <xsl:element name="command_id">get_prod_comm_data_1</xsl:element>
        <xsl:element name="CcmFifGetProductCommitmentDataInCont">
          <xsl:element name="product_commitment_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create KBA notification  -->
      <xsl:element name="CcmFifCreateExternalNotificationCmd">
        <xsl:element name="command_id">create_pos_notification_1</xsl:element>
        <xsl:element name="CcmFifCreateExternalNotificationInCont">
          <xsl:element name="effective_date">
            <xsl:value-of select="dateutils:getCurrentDate()"/>
          </xsl:element>
          <xsl:element name="notification_action_name">
            <xsl:value-of select="request-param[@name='NOTIFICATION_TYPE']"/>
          </xsl:element>
          <xsl:element name="target_system">POS</xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">DESIRED_DATE</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_stp_data_1</xsl:element>
                <xsl:element name="field_name">desired_date</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CUSTOMER_ORDER_ID</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_stp_data_1</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">BARCODE</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_co_data_1</xsl:element>
                <xsl:element name="field_name">customer_tracking_id</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SERVICE_SUBSCRIPTION</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_stp_data_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='SERVICE_CODE'] != 'I104B'">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ONLINE_ACCOUNT</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">get_csc_data_1</xsl:element>
                  <xsl:element name="field_name">characteristic_value</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='SERVICE_CODE'] = 'I104B'">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">ONLINE_ACCOUNT</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">get_csc_data_2</xsl:element>
                  <xsl:element name="field_name">characteristic_value</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">IP_ADRESS</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">get_csc_data_3</xsl:element>
                  <xsl:element name="field_name">characteristic_value</xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">REASON_RD</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_stp_data_1</xsl:element>
                <xsl:element name="field_name">reason_rd</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">PRODUCT_CODE</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_prod_comm_data_1</xsl:element>
                <xsl:element name="field_name">product_code</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">PRODUCT_VERSION</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_prod_comm_data_1</xsl:element>
                <xsl:element name="field_name">product_version_code</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_create_notification</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>            
        </xsl:element>
      </xsl:element>

