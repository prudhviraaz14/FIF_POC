<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for finalizing a customer order in state COMPLETE.
  @author schwarje
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1" indent="yes" method="xml"/>
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
      <xsl:value-of select="request-param[@name='clientName']"/>

    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    
    <xsl:element name="Command_List">
           
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_main_service</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- find co -->
      <xsl:element name="CcmFifFindServiceTicketPositionCmd">
        <xsl:element name="command_id">find_main_stp</xsl:element>
        <xsl:element name="CcmFifFindServiceTicketPositionInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_main_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
          </xsl:element>
          <xsl:element name="no_stp_error">N</xsl:element>
          <xsl:element name="find_stp_parameters">
            <xsl:element name="CcmFifFindStpParameterCont">
              <xsl:element name="usage_mode_value_rd">1</xsl:element>
              <xsl:element name="customer_order_state">COMPLETED</xsl:element>                                            
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifRaiseErrorCmd">
        <xsl:element name="command_id">raiseError</xsl:element>
        <xsl:element name="CcmFifRaiseErrorInCont">
          <xsl:element name="error_text">
            <xsl:text>No COMPLETE customerOrder could be found for creating serviceSubscription '</xsl:text>
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
            <xsl:text>'. Cannot finalize customerOrder for enabling billing.</xsl:text>
          </xsl:element>							
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_main_stp</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>          
        </xsl:element>
      </xsl:element>
      
      <!-- get details for the STP -->
      <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
        <xsl:element name="command_id">get_stp_data</xsl:element>
        <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_main_stp</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifFinalizeCustomerOrderCmd">
        <xsl:element name="command_id">finalize_co</xsl:element>
        <xsl:element name="CcmFifFinalizeCustomerOrderInCont">
          <xsl:element name="customer_order_id_ref">
            <xsl:element name="command_id">get_stp_data</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>      
                  
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
        <xsl:element name="command_id">ccbId</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">functionStatus</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">SUCCESS</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>

