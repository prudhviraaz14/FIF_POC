<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a terminate condition service FIF request
  
  @author banania
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
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
    <xsl:element name="client_name">
      <xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    
    <xsl:element name="Command_List">
      
      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
      
      
      <xsl:variable name="TerminationReason">  
        <xsl:choose>
          <xsl:when test ="request-param[@name='CONTACT_TEXT'] != ''">
            <xsl:value-of select="request-param[@name='CONTACT_TEXT']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Konditionsdienst mit der ID:</xsl:text>
            <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
            <xsl:text> über SLS gekündigt.</xsl:text>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>
      
      <!-- Find service -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- lock account to avoid concurrency problems -->
      <xsl:element name="CcmFifLockObjectCmd">
        <xsl:element name="CcmFifLockObjectInCont">
          <xsl:element name="object_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>							
          </xsl:element>
          <xsl:element name="object_type">CUSTOMER</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Find terminated STP -->
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
              <xsl:element name="usage_mode_value_rd">4</xsl:element>
              <xsl:element name="customer_order_state">DEFINED</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="usage_mode_value_rd">4</xsl:element>
              <xsl:element name="customer_order_state">RELEASED</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- validate the service code -->
      <xsl:element name="CcmFifValidateGeneralCodeItemCmd">
        <xsl:element name="command_id">validate_service_code_1</xsl:element>
        <xsl:element name="CcmFifValidateGeneralCodeItemInCont">
          <xsl:element name="group_code">TERM_COND</xsl:element>
          <xsl:element name="value_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>							
          </xsl:element>
          <xsl:element name="raise_error_if_invalid">Y</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_stp_1</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- TermSuspReactService service -->
      <xsl:element name="CcmFifTermSuspReactServiceSubsCmd">
        <xsl:element name="command_id">terminate_service_1</xsl:element>
        <xsl:element name="CcmFifTermSuspReactServiceSubsInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="usage_mode">4</xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">TERM_COND_SERV</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_stp_1</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Customer Order -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="provider_tracking_no">002</xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">terminate_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="generate_customer_tracking_id">Y</xsl:element>	
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_stp_1</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Release Customer Order -->
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
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_stp_1</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">TERM_COND_SERV</xsl:element>
          <xsl:element name="short_description">Kündigung Konditonsdienst</xsl:element>
          <xsl:element name="description_text_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="contact_text">
                <xsl:text>Kündigung einer Gutschrift (monatlich/einmalig)&#xA;transactionID: </xsl:text>
                <xsl:value-of select="request-param[@name='transactionID']"/>
                <xsl:text>&#xA;FIF-Client: </xsl:text>
                <xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
                <xsl:text>&#xA;Dienstenutzung: </xsl:text>
                <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
                <xsl:text>&#xA;Kündigungsgrund: </xsl:text>
                <xsl:value-of select="$TerminationReason"/>
              </xsl:element>
            </xsl:element> 
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_stp_1</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>   
      </xsl:element>   
      
      <!-- Create external notification -->
      <xsl:element name="CcmFifCreateExternalNotificationCmd">
        <xsl:element name="command_id">create_external_notification_1</xsl:element>
        <xsl:element name="CcmFifCreateExternalNotificationInCont">
          <xsl:element name="effective_date">						
            <xsl:value-of select="$today"/>					
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
              <xsl:element name="parameter_value">Termination</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">USER_NAME</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='USER_NAME']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element>
              <xsl:element name="parameter_value">CCB</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">WORK_DATE</xsl:element>
              <xsl:element name="parameter_value">								
                <xsl:value-of select="$today"/>																
              </xsl:element>
            </xsl:element>					
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">TEXT</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="$TerminationReason"/>
              </xsl:element>
            </xsl:element>					
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_stp_1</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      
    </xsl:element>
    
  </xsl:template>
</xsl:stylesheet>
