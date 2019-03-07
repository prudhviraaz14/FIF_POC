<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for writing to External Notification

  @author Marcin Leja
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1"
    indent="yes" method="xml"/>
  <xsl:template match="/">
    <xsl:element name="CcmFifCommandList">
      <xsl:apply-templates select="request/request-params"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="request-params">
    <!-- Copy over transaction ID and action name -->
    <xsl:element name="transaction_id">
      <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="client_name">CCM</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">
      <xsl:variable name="ServiceTicketPositionId" select="request-param[@name='SERVICE_TICKET_POSITION_ID']" />
      <xsl:variable name="FindServCharValueForServChar">find_serv_char_value_</xsl:variable>
      <xsl:variable name="CreatePermNotification">create_external_notification_</xsl:variable>
      <xsl:variable name="today" select="dateutils:getCurrentDate()"/> 
      
      <!-- Find the Service Ticket Position  for information required in notification -->
      <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
        <xsl:element name="command_id">find_service_ticket_position_1</xsl:element>
        <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
          <xsl:element name="service_ticket_position_id">
            <xsl:value-of select="$ServiceTicketPositionId"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Find the Service Subscription for information required in notification -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_subscription_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_ticket_position_id">
            <xsl:value-of select="$ServiceTicketPositionId"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Find an open customer order for information required in notification -->
      <xsl:element name="CcmFifGetCustomerOrderDataCmd">
        <xsl:element name="command_id">find_customer_order_1</xsl:element>
        <xsl:element name="CcmFifGetCustomerOrderDataInCont">
          <xsl:element name="customer_order_id_ref">
            <xsl:element name="command_id">find_service_ticket_position_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
        </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create External Notification for Service Characteristics Changed -->
      <xsl:for-each select="request-param-list[@name='FIF_SERVICE_CHARACTERISTIC_CODE_LIST']/request-param-list-item">
        <xsl:variable name="ServiceCharCode" select="request-param[@name='SERVICE_CHARACTERISTIC_CODE']"/>
        <xsl:variable name="FindServCharValueForServCharCmdId" select="concat($FindServCharValueForServChar, $ServiceCharCode)"/>
        <xsl:variable name="CreatePermNotificationCmdId" select="concat($CreatePermNotification, $ServiceCharCode)"/>
        
        <!-- Find an service characteristic value required in notification -->
        <xsl:element name="CcmFifFindServCharValueForServCharCmd">
          <xsl:element name="command_id">
            <xsl:value-of select="$FindServCharValueForServCharCmdId"/>
          </xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharInCont">
            <xsl:element name="service_ticket_position_id">
              <xsl:value-of select="$ServiceTicketPositionId"/>
            </xsl:element>
            <xsl:element name="service_char_code">
              <xsl:value-of select="$ServiceCharCode"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <xsl:if test="$ServiceCharCode = 'V0583'">
          <!-- Find an service characteristic value required in notification -->
          <xsl:element name="CcmFifFindServCharValueForServCharCmd">
            <xsl:element name="command_id">findEndleitungsbauCharV0585</xsl:element>
            <xsl:element name="CcmFifFindServCharValueForServCharInCont">
              <xsl:element name="service_ticket_position_id">
                <xsl:value-of select="$ServiceTicketPositionId"/>
              </xsl:element>
              <xsl:element name="service_char_code">V0585</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="CcmFifFindServCharValueForServCharCmd">
            <xsl:element name="command_id">findEndleitungsbauCharV0586</xsl:element>
            <xsl:element name="CcmFifFindServCharValueForServCharInCont">
              <xsl:element name="service_ticket_position_id">
                <xsl:value-of select="$ServiceTicketPositionId"/>
              </xsl:element>
              <xsl:element name="service_char_code">V0586</xsl:element>
            </xsl:element>
          </xsl:element>
          
          <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_main_access_service</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
              <xsl:element name="product_subscription_id_ref">
                <xsl:element name="command_id">find_service_subscription_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="fetch_main_ss_from_ps_Ind">Y</xsl:element>
            </xsl:element>
          </xsl:element>          
        </xsl:if>
        
        <xsl:element name="CcmFifMapStringCmd">
          <xsl:element name="command_id">map_sales_org_number_empty</xsl:element>
          <xsl:element name="CcmFifMapStringInCont">
            <xsl:element name="input_string_type">xxx</xsl:element>
            <xsl:element name="input_string">dummy</xsl:element>
            <xsl:element name="output_string_type">xxx</xsl:element>
            <xsl:element name="string_mapping_list">
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">dummy</xsl:element>
                <xsl:element name="output_string_ref">
                  <xsl:element name="command_id">find_customer_order_1</xsl:element>
                  <xsl:element name="field_name">customer_tracking_id</xsl:element>                                    
                </xsl:element>
              </xsl:element>                
            </xsl:element>
            <xsl:element name="no_mapping_error">N</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <xsl:variable name="actionName">
          <xsl:choose>
            <xsl:when test="$ServiceCharCode = 'V0583'">Abrechnung Endleitungsbau</xsl:when>
            <xsl:otherwise>ServiceCharChanged</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <!-- Create External Notification -->
        <xsl:element name="CcmFifCreatePermNotificationCmd">
          <xsl:element name="command_id">
            <xsl:value-of select="$CreatePermNotificationCmdId"/>
          </xsl:element>
          <xsl:element name="CcmFifCreatePermNotificationInCont">
            <xsl:element name="status">Released</xsl:element>
            <xsl:element name="action_name">
              <xsl:value-of select="$actionName"/>
            </xsl:element>
            <xsl:element name="target_system">Provi</xsl:element>
            <xsl:element name="create_reference_ind">Y</xsl:element>
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_customer_order_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">SERVICE_CHAR_CODE</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="$ServiceCharCode"/></xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">SERVICE_CHAR_VALUE</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id"><xsl:value-of select="$FindServCharValueForServCharCmdId"/></xsl:element>
                  <xsl:element name="field_name">characteristic_value</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">SERVICE_TICKET_POSITION_ID</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="$ServiceTicketPositionId"/></xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">USAGE_MODE</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_service_ticket_position_1</xsl:element>
                  <xsl:element name="field_name">usage_mode_value_rd</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">STATE_RD</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_service_ticket_position_1</xsl:element>
                  <xsl:element name="field_name">state_rd</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">REASON_RD</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_service_ticket_position_1</xsl:element>
                  <xsl:element name="field_name">reason_rd</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">STATE_DATE</xsl:element>
                <xsl:element name="parameter_value_ref">                    
                  <xsl:choose>
                    <xsl:when test="$ServiceCharCode = 'V0583'">
                      <xsl:element name="command_id">findEndleitungsbauCharV0585</xsl:element>
                      <xsl:element name="field_name">characteristic_value</xsl:element>                        
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:element name="command_id">find_service_ticket_position_1</xsl:element>
                      <xsl:element name="field_name">state_date</xsl:element>
                    </xsl:otherwise>
                  </xsl:choose>                    
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">PRODUCT_COMMITMENT_NUMBER</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_service_subscription_1</xsl:element>
                  <xsl:element name="field_name">product_commitment_number</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CUSTOMER_TRACKING_ID</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_customer_order_1</xsl:element>
                  <xsl:element name="field_name">customer_tracking_id</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">PROVIDER_TRACKING_NUMBER</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_customer_order_1</xsl:element>
                  <xsl:element name="field_name">provider_tracking_number</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">SALES_ORGANIZATION_NUMBER</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_customer_order_1</xsl:element>
                  <xsl:element name="field_name">sales_organization_id</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">SERVICE_SUBSCRIPTION_ID</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:choose>
                    <xsl:when test="$ServiceCharCode = 'V0583'">
                      <xsl:element name="command_id">find_main_access_service</xsl:element>
                      <xsl:element name="field_name">service_subscription_id</xsl:element>                        
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:element name="command_id">find_service_subscription_1</xsl:element>
                      <xsl:element name="field_name">service_subscription_id</xsl:element>                        
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:element>
              </xsl:element>
              <xsl:if test="$ServiceCharCode = 'V0583'">
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">LINE_CODE_NUMBER</xsl:element>
                  <xsl:element name="parameter_value_ref">
                    <xsl:element name="command_id">findEndleitungsbauCharV0586</xsl:element>
                    <xsl:element name="field_name">characteristic_value</xsl:element>                        
                  </xsl:element>
                </xsl:element>
              </xsl:if>
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>	
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">map_sales_org_number_empty</xsl:element>
              <xsl:element name="field_name">output_string_empty</xsl:element>								
            </xsl:element>
          </xsl:element>
        </xsl:element>
        <xsl:element name="CcmFifCreatePermNotificationCmd">
          <xsl:element name="command_id">
            <xsl:value-of select="$CreatePermNotificationCmdId"/>
          </xsl:element>
          <xsl:element name="CcmFifCreatePermNotificationInCont">
            <xsl:element name="status">Released</xsl:element>
            <xsl:element name="action_name">
              <xsl:value-of select="$actionName"/>
            </xsl:element>
            <xsl:element name="target_system">Provi</xsl:element>
            <xsl:element name="create_reference_ind">Y</xsl:element>
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_customer_order_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">SERVICE_CHAR_CODE</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="$ServiceCharCode"/></xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">SERVICE_CHAR_VALUE</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id"><xsl:value-of select="$FindServCharValueForServCharCmdId"/></xsl:element>
                  <xsl:element name="field_name">characteristic_value</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">SERVICE_TICKET_POSITION_ID</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="$ServiceTicketPositionId"/></xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">USAGE_MODE</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_service_ticket_position_1</xsl:element>
                  <xsl:element name="field_name">usage_mode_value_rd</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">STATE_RD</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_service_ticket_position_1</xsl:element>
                  <xsl:element name="field_name">state_rd</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">REASON_RD</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_service_ticket_position_1</xsl:element>
                  <xsl:element name="field_name">reason_rd</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">STATE_DATE</xsl:element>
                <xsl:element name="parameter_value_ref">                    
                  <xsl:choose>
                    <xsl:when test="$ServiceCharCode = 'V0583'">
                      <xsl:element name="command_id">findEndleitungsbauCharV0585</xsl:element>
                      <xsl:element name="field_name">characteristic_value</xsl:element>                        
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:element name="command_id">find_service_ticket_position_1</xsl:element>
                      <xsl:element name="field_name">state_date</xsl:element>
                    </xsl:otherwise>
                  </xsl:choose>                    
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">PRODUCT_COMMITMENT_NUMBER</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_service_subscription_1</xsl:element>
                  <xsl:element name="field_name">product_commitment_number</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CUSTOMER_TRACKING_ID</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_customer_order_1</xsl:element>
                  <xsl:element name="field_name">customer_tracking_id</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">PROVIDER_TRACKING_NUMBER</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">find_customer_order_1</xsl:element>
                  <xsl:element name="field_name">provider_tracking_number</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">SERVICE_SUBSCRIPTION_ID</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:choose>
                    <xsl:when test="$ServiceCharCode = 'V0583'">
                      <xsl:element name="command_id">find_main_access_service</xsl:element>
                      <xsl:element name="field_name">service_subscription_id</xsl:element>                        
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:element name="command_id">find_service_subscription_1</xsl:element>
                      <xsl:element name="field_name">service_subscription_id</xsl:element>                        
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:element>
              </xsl:element>
              <xsl:if test="$ServiceCharCode = 'V0583'">
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">LINE_CODE_NUMBER</xsl:element>
                  <xsl:element name="parameter_value_ref">
                    <xsl:element name="command_id">findEndleitungsbauCharV0586</xsl:element>
                    <xsl:element name="field_name">characteristic_value</xsl:element>                        
                  </xsl:element>
                </xsl:element>
              </xsl:if>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>	
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">map_sales_org_number_empty</xsl:element>
              <xsl:element name="field_name">output_string_empty</xsl:element>								
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
      </xsl:for-each>

      </xsl:element>
  </xsl:template>
</xsl:stylesheet>
