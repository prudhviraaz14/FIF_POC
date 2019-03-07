
      <xsl:if test="request-param[@name='PRODUCT_CODE'] = '' or 
        request-param[@name='PRODUCT_VERSION_CODE'] = '' or 
        request-param[@name='PRICING_STRUCTURE_CODE'] = '' or 
        request-param[@name='SALES_ORGANISATION_NUMBER'] = ''">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">missing_parameter</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Following parameters have to be provided: PRODUCT_CODE, PRODUCT_VERSION_CODE, PRICING_STRUCTURE_CODE, SALES_ORGANISATION_NUMBER</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>  

      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_by_stp_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_ticket_position_id">
            <xsl:value-of select="request-param[@name='SERVICE_TICKET_POSITION_ID']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Get main access service -->
      <xsl:element name="CcmFifFindServiceSubsForProductCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsForProductInCont">
          <xsl:element name="product_subscription_id_ref">
            <xsl:element name="command_id">find_service_by_stp_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0010</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0003</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- find STP -->
      <xsl:element name="CcmFifFindServiceTicketPositionCmd">
        <xsl:element name="command_id">find_stp_1</xsl:element>
        <xsl:element name="CcmFifFindServiceTicketPositionInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="usage_mode_value_rd">1</xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
        <xsl:element name="command_id">get_stp_data_1</xsl:element>
        <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_stp_1</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>
          </xsl:element>
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
            
      <xsl:element name="CcmFifGetOrderFormDataCmd">
        <xsl:element name="command_id">get_of_data_1</xsl:element>
        <xsl:element name="CcmFifGetOrderFormDataInCont">
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">find_service_by_stp_1</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create KBA notification  -->
      <xsl:element name="CcmFifCreateExternalNotificationCmd">
        <xsl:element name="command_id">create_pos_notification_1</xsl:element>
        <xsl:element name="CcmFifCreateExternalNotificationInCont">
          <xsl:element name="effective_date_ref">
            <xsl:element name="command_id">get_stp_data_1</xsl:element>
            <xsl:element name="field_name">desired_date</xsl:element>
          </xsl:element>
          <xsl:element name="notification_action_name">
            <xsl:value-of select="request-param[@name='NOTIFICATION_TYPE']"/>
          </xsl:element>
          <xsl:element name="target_system">POS</xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_service_by_stp_1</xsl:element>
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
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
            </xsl:element>
             
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">REASON_RD</xsl:element>
              <xsl:if test="request-param[@name='ONLINE_REASON_RD'] = ''"> 
                 <xsl:element name="parameter_value_ref">
                    <xsl:element name="command_id">get_stp_data_1</xsl:element>
                    <xsl:element name="field_name">reason_rd</xsl:element>
                 </xsl:element>
              </xsl:if>
              <xsl:if test="request-param[@name='ONLINE_REASON_RD'] != ''">
              	 <xsl:element name="parameter_value">
                    <xsl:value-of select="request-param[@name='ONLINE_REASON_RD']"/>
                 </xsl:element>
              </xsl:if> 	
            </xsl:element>             
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">MIN_PERIOD_DUR_VALUE</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_of_data_1</xsl:element>
                <xsl:element name="field_name">min_per_dur_value</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">MIN_PERIOD_DUR_UNIT_RD</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_of_data_1</xsl:element>
                <xsl:element name="field_name">min_per_dur_unit</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">PRODUCT_CODE</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='PRODUCT_CODE']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">PRODUCT_VERSION</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='PRODUCT_VERSION_CODE']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">ONLINE_TARIFF</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='PRICING_STRUCTURE_CODE']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SALES_ORGANISATION_NUMBER</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='SALES_ORGANISATION_NUMBER']"/>
              </xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='SKELETON_CONTRACT_NUMBER'] != ''">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">SKELETON_CONTRACT_NUMBER</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='SKELETON_CONTRACT_NUMBER']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='CREATE_STAT_IP_SERVICE'] != ''">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CREATE_STAT_IP_SERVICE</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='CREATE_STAT_IP_SERVICE']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>   
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">NOTICE_PERIOD_DUR_VALUE</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_of_data_1</xsl:element>
                <xsl:element name="field_name">notice_per_dur_value</xsl:element>
              </xsl:element>
            </xsl:element>         
          </xsl:element>
        </xsl:element>
      </xsl:element>
