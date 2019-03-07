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
              <xsl:value-of select="request-param[@name='desiredDate']"/>
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
                <xsl:value-of select="request-param[@name='desiredDate']"/>
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
                    <xsl:value-of select="request-param[@name='desiredDate']"/>
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
