<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for writing to External Notification
  
  @author Vinit Sawalkar
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
            
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_ticket_position_id">
            <xsl:value-of select="request-param[@name='SERVICE_TICKET_POSITION_ID']"/>
          </xsl:element>
          <xsl:element name="ignore_guiding_rule">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
        <xsl:element name="command_id">get_stp_data_1</xsl:element>
        <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
          <xsl:element name="service_ticket_position_id">
            <xsl:value-of select="request-param[@name='SERVICE_TICKET_POSITION_ID']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifFindCustomerOrderCmd">
        <xsl:element name="command_id">find_co_1</xsl:element>
        <xsl:element name="CcmFifFindCustomerOrderInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">get_stp_data_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="state_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">CANCELED</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="allow_children">Y</xsl:element>
          <xsl:element name="usage_mode">1</xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:element name="CcmFifGetCustomerOrderDataCmd">
        <xsl:element name="command_id">get_co_data_1</xsl:element>
        <xsl:element name="CcmFifGetCustomerOrderDataInCont">
          <xsl:element name="customer_order_id_ref">
            <xsl:element name="command_id">find_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_found</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Provi notification  -->
      <xsl:element name="CcmFifCreatePermNotificationCmd">
        <xsl:element name="command_id">create_pos_notification_1</xsl:element>
        <xsl:element name="CcmFifCreatePermNotificationInCont">
          <xsl:element name="status">Released</xsl:element>
          <xsl:element name="action_name">
            <xsl:value-of select="request-param[@name='NOTIFICATION_ACTION_NAME']"/>
          </xsl:element>
          <xsl:element name="target_system">Provi</xsl:element>
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">get_co_data_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">STATE_DATE</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_stp_data_1</xsl:element>
                <xsl:element name="field_name">state_date</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SERVICE_SUBSCRIPTION_ID</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">PROVIDER_TRACKING_NUMBER</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_co_data_1</xsl:element>
                <xsl:element name="field_name">provider_tracking_number</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SALES_ORGANIZATION_ID</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_co_data_1</xsl:element>
                <xsl:element name="field_name">sales_organization_id</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CUSTOMER_TRACKING_ID</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_co_data_1</xsl:element>
                <xsl:element name="field_name">customer_tracking_id</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">PRODUCT_SUBSCRIPTION_ID</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">PRODUCT_COMMITMENT_NUMBER</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">product_commitment_number</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SYSTEMQUELLE</xsl:element>
              <xsl:element name="parameter_value">CCM</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CANCEL_REASON_RD</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_co_data_1</xsl:element>
                <xsl:element name="field_name">cancel_reason_rd</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_found</xsl:element>          	
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Provi notification  -->
      <xsl:element name="CcmFifCreatePermNotificationCmd">
        <xsl:element name="command_id">create_pos_notification_1</xsl:element>
        <xsl:element name="CcmFifCreatePermNotificationInCont">
          <xsl:element name="status">Released</xsl:element>
          <xsl:element name="action_name">
            <xsl:value-of select="request-param[@name='NOTIFICATION_ACTION_NAME']"/>
          </xsl:element>
          <xsl:element name="target_system">Provi</xsl:element>
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">STATE_DATE</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_stp_data_1</xsl:element>
                <xsl:element name="field_name">state_date</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SERVICE_SUBSCRIPTION_ID</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">PRODUCT_SUBSCRIPTION_ID</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">PRODUCT_COMMITMENT_NUMBER</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">product_commitment_number</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SYSTEMQUELLE</xsl:element>
              <xsl:element name="parameter_value">CCM</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">CANCEL_REASON_RD</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">get_stp_data_1</xsl:element>
                <xsl:element name="field_name">cancel_reason_rd</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_found</xsl:element>          	
          </xsl:element>
        </xsl:element>
      </xsl:element>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
