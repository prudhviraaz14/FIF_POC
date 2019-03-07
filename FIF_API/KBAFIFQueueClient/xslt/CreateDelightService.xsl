<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a delight service.

  @author banania
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

      <xsl:variable name="DesiredDate" select="request-param[@name='desiredDate']"/>
         
      <xsl:if test="request-param[@name='productSubscriptionId'] != ''">   
        <!-- Look for the ISDN/DSL-R or NGN service -->
        <xsl:element name="CcmFifFindServiceSubsForProductCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsForProductInCont">
            <xsl:element name="product_subscription_id">
              <xsl:value-of select="request-param[@name='productSubscriptionId']"/>
            </xsl:element>
            <xsl:element name="service_code_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0010</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0003</xsl:element>
              </xsl:element>            
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">I1043</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="service_code">I104A</xsl:element>
                </xsl:element>            
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">I1210</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">I1213</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">I1213</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0001</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0004</xsl:element>
              </xsl:element>  
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">I1305</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">I1306</xsl:element>
              </xsl:element>            
            </xsl:element>
          </xsl:element>
        </xsl:element>
     </xsl:if>
      
      <!-- Look for the ISDN service in the external notification if productSubscriptionId is not provided --> 
      <xsl:if test="request-param[@name='productSubscriptionId'] = ''">  
                
        <xsl:variable name="Type">
          <xsl:value-of select="request-param[@name='type']"/>
        </xsl:variable> 
                       
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_external_notification_1</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">   
              <xsl:value-of select="concat($Type, '_SERVICE_SUBSCRIPTION_ID')"/>  
            </xsl:element>                 
          </xsl:element>
        </xsl:element>
        
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="$DesiredDate"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
       
      <!-- Find existing delight service-->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_delight_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:if test="request-param[@name='productSubscriptionId'] != ''">  
            <xsl:element name="product_subscription_id">
              <xsl:value-of select="request-param[@name='productSubscriptionId']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='productSubscriptionId'] = ''">  
            <xsl:element name="product_subscription_id_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">V0303</xsl:element>   
          <xsl:element name="no_service_error">N</xsl:element>        
          </xsl:element>
      </xsl:element>
  
      <!-- Terminate delight service, if any -->
      <xsl:element name="CcmFifTermSuspReactServiceSubsCmd">
        <xsl:element name="command_id">terminate_delight_service_1</xsl:element>
        <xsl:element name="CcmFifTermSuspReactServiceSubsInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_delight_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="usage_mode">4</xsl:element>
          <xsl:choose>
            <xsl:when test="request-param[@name='productSubscriptionId'] != ''">
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>                
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:element name="reason_rd">TERM_DELIGHT</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_delight_service_1</xsl:element>
            <xsl:element name="field_name">service_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Add service V0303 -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:if test="request-param[@name='productSubscriptionId'] != ''">  
            <xsl:element name="product_subscription_id">
              <xsl:value-of select="request-param[@name='productSubscriptionId']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='productSubscriptionId'] = ''">  
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="service_code">V0303</xsl:element>
          <xsl:element name="sales_organisation_number">
            <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
          </xsl:element> 
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="reason_rd">CREATE_DELIGHT</xsl:element>
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Delight code -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0211</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='delightCode']"/>
                </xsl:element>
              </xsl:element>
            <!-- Delight description-->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0212</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='delightDescription']"/>
                </xsl:element>
              </xsl:element>
            <!--  Delight enddate -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0213</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='endDate']"/>
                </xsl:element>
              </xsl:element>  
            <!--  Bemerkung -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Create delight service</xsl:element>
            </xsl:element>              
          </xsl:element>
        </xsl:element>
      </xsl:element>

   
      <!-- Create Customer Order for new service  -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="provider_tracking_no">003de</xsl:element>                
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">terminate_delight_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Release stand alone Customer Order  -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Contact for the addition of security service -->
        <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="contact_type_rd">CREATE_DELIGHT</xsl:element>
            <xsl:element name="short_description">
              <xsl:text>Dienst hinzugefügt über </xsl:text>
              <xsl:value-of select="request-param[@name='clientName']"/>
            </xsl:element>
            <xsl:element name="long_description_text">
              <xsl:text>TransactionID: </xsl:text>
              <xsl:value-of select="request-param[@name='transactionID']"/>
              <xsl:text>&#xA;Service Code: V0303</xsl:text>
              <xsl:text>&#xA;Desired Date: </xsl:text>
              <xsl:value-of select="$DesiredDate"/>
              <xsl:text>&#xA;User name: </xsl:text>
              <xsl:value-of select="request-param[@name='userName']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
  
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
