<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a terminate directory entry service FIF request

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
      <xsl:value-of select="request-param[@name='clientName']"/>
    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">

      
      <xsl:variable name="TerminationReason">  
        <xsl:choose>
          <xsl:when test ="request-param[@name='contactText'] != ''">
            <xsl:value-of select="request-param[@name='contactText']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Telefonbucheintrag mit der ID:</xsl:text>
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
            <xsl:text> über </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
            <xsl:text> gekündigt.</xsl:text>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>
      
      <!-- Find service -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='terminationDate']"/>
          </xsl:element> 
        </xsl:element>
      </xsl:element>
     
      <!-- Validate the service code-->
      <xsl:element name="CcmFifValidateValueCmd">
        <xsl:element name="command_id">validate_service_code</xsl:element>
        <xsl:element name="CcmFifValidateValueInCont">
          <xsl:element name="value_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>          
            <xsl:element name="field_name">service_code</xsl:element>            
          </xsl:element>      
          <xsl:element name="allowed_values">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">V0100</xsl:element>
            </xsl:element>                    
          </xsl:element>
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
            <xsl:value-of select="request-param[@name='terminationDate']"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="reason_rd">TERM_DIR_SERV</xsl:element>
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
        </xsl:element>
      </xsl:element>
      
      <!-- Create contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">TERM_DIR_SERV</xsl:element>
          <xsl:element name="short_description">Kündigung Telefonbucheintrag</xsl:element>
          <xsl:element name="description_text_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="contact_text">
                <xsl:text>TransactionID: </xsl:text>
                <xsl:value-of select="request-param[@name='transactionID']"/>
                <xsl:text>&#xA;Service Subscription ID: </xsl:text>
                <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
                <xsl:text>&#xA;User name: </xsl:text>
                <xsl:value-of select="request-param[@name='userName']"/>
                <xsl:text>&#xA;TerminationReason: </xsl:text>
                <xsl:value-of select="$TerminationReason"/>
              </xsl:element>
            </xsl:element> 
          </xsl:element>
        </xsl:element>   
      </xsl:element>   
     
            
    </xsl:element>
      
  </xsl:template>
</xsl:stylesheet>
