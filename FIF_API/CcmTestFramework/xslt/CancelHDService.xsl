<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for cancellation of hardware service FIF request

  @author lejam
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
    <xsl:element name="client_name">OPM</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">
      
      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
      
      <!-- get data from main access STP -->
      <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
        <xsl:element name="command_id">get_main_access_stp_data</xsl:element>
        <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
          <xsl:element name="service_ticket_position_id">
            <xsl:value-of select="request-param[@name='SERVICE_TICKET_POSITION_ID']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Find main access service -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_main_access_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">get_main_access_stp_data</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
  
      <!-- lock account to avoid concurrency problems -->
      <xsl:element name="CcmFifLockObjectCmd">
        <xsl:element name="CcmFifLockObjectInCont">
          <xsl:element name="object_id_ref">
            <xsl:element name="command_id">find_main_access_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>							
          </xsl:element>
          <xsl:element name="object_type">CUSTOMER</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Find HD service -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_hd_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="product_subscription_id_ref">
            <xsl:element name="command_id">find_main_access_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">I1354</xsl:element>
        </xsl:element>
      </xsl:element>
      
      
      <!-- find STP -->
      <xsl:element name="CcmFifFindServiceTicketPositionCmd">
        <xsl:element name="command_id">find_hd_stp_1</xsl:element>
        <xsl:element name="CcmFifFindServiceTicketPositionInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">find_hd_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="usage_mode_value_rd">1</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- cancel HD STP -->     
      <xsl:element name="CcmFifCancelServiceTicketPositionCmd">
        <xsl:element name="command_id">cancel_hardware_service_1</xsl:element>
        <xsl:element name="CcmFifCancelServiceTicketPositionInCont">
          <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_hd_stp_1</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>          	
          </xsl:element>
          <xsl:element name="cancel_reason_rd">
            <xsl:value-of select="request-param[@name='CANCEL_REASON_RD']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_hd_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">AUTO_TERM_CANCEL</xsl:element>
          <xsl:element name="short_description">HD Option storniert - OPM</xsl:element>
          <xsl:element name="description_text_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="contact_text">
                <xsl:text>TransactionID: </xsl:text>
                <xsl:value-of select="request-param[@name='transactionID']"/>
                <xsl:text>&#xA;Der Dienst für die HD Option mit der ID </xsl:text>
                <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
              </xsl:element>
            </xsl:element> 
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_hd_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="contact_text">
                <xsl:text>) wurde am </xsl:text>
                <xsl:value-of select="$today"/>
                <xsl:text> durch OPM storniert.</xsl:text>
              </xsl:element>
            </xsl:element> 
          </xsl:element>
        </xsl:element>   
      </xsl:element>   

            
    </xsl:element>
      
  </xsl:template>
</xsl:stylesheet>
