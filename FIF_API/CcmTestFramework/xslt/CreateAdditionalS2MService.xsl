<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for adding additional S2M services.
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

    <xsl:variable name="DesiredDate" select="request-param[@name='desiredDate']"/>
    <xsl:variable name="today" select="dateutils:getCurrentDate()"/> 
    
    <xsl:element name="Command_List">
  
     
      
      <xsl:variable name="ServiceCode">        
        <xsl:choose>
          <xsl:when test ="request-param[@name='serviceType'] = 'ADDITIONAL_PRI'">
            <xsl:text>V0015</xsl:text>
          </xsl:when>
          <xsl:when test ="request-param[@name='serviceType'] = 'ADDITIONAL_PRI_FLAT'">
            <xsl:text>V0502</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='serviceCode']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
        
      <xsl:variable name="Type">
        <!-- the empty text in each variable is a hack to have the variable existing
          even if the original is not defined in one of the FIF clients -->
        <xsl:text/>
        <xsl:value-of select="request-param[@name='type']"/>
      </xsl:variable> 
      <xsl:text/>
      <xsl:variable name="serviceSubscriptionId">
        <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
      </xsl:variable> 
      <xsl:variable name="requestListId">
        <xsl:text/>
        <xsl:value-of select="request-param[@name='requestListId']"/>
      </xsl:variable> 

      <!-- Find the main Service  by Service Subscription Id-->
      <xsl:if test="$serviceSubscriptionId != '' ">
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="$serviceSubscriptionId"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Take value of serviceSubscriptionId from ccm external notification if serviceSubscriptionId not provided -->
      <xsl:if test="$serviceSubscriptionId = ''">
        
        <xsl:if test="$Type != ''">
          <xsl:element name="CcmFifReadExternalNotificationCmd">
            <xsl:element name="command_id">read_service_subscription</xsl:element>
            <xsl:element name="CcmFifReadExternalNotificationInCont">
              <xsl:element name="transaction_id">
                <xsl:value-of select="$requestListId"/>
              </xsl:element>
              <xsl:element name="parameter_name">
                <xsl:value-of select="concat($Type, '_SERVICE_SUBSCRIPTION_ID')"/>
              </xsl:element>                        
            </xsl:element>   
          </xsl:element>     
        </xsl:if>

        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">read_service_subscription</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="$DesiredDate"/>
            </xsl:element> 
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Add Service -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">
            <xsl:value-of select="$ServiceCode"/>
          </xsl:element>
          <xsl:element name="sales_organisation_number">
              <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
          </xsl:element>  
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:choose>
            <xsl:when test="$serviceSubscriptionId != ''">
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>                
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            </xsl:otherwise>
          </xsl:choose>       
           <xsl:element name="reason_rd">CUST_REQUEST</xsl:element>             
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Aktionskennung monatlich -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0193</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='monthlyConditionId']"/>
              </xsl:element>
            </xsl:element>	
            <!-- Steuerung über OP -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0018</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">mit OP</xsl:element>
            </xsl:element>	
            <!-- Prov. Minderung -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0149</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">0%</xsl:element>
            </xsl:element>
            <xsl:if test="$ServiceCode = 'V0502'">
              <!-- Monatspreis S2M-Anschlüsse -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0562</xsl:element>
                <xsl:element name="data_type">DECIMAL</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='monthlyCharge']"/>
                </xsl:element>
              </xsl:element>
              <!-- Steuerung Monatspreis S2M-Anschlüsse -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0563</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='monthlyChargeType']"/>
                </xsl:element>
              </xsl:element>
              <!-- Einrichtungspreises für Primärmultiplexanschlüsse -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0573</xsl:element>
                <xsl:element name="data_type">DECIMAL</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='oneTimeCharge']"/>
                </xsl:element>
              </xsl:element>	
              <!-- Steuerung Einrichtungspreis Primärmultiplex -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0574</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='oneTimeChargeType']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
          </xsl:element>          
        </xsl:element>
      </xsl:element>
   
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
          <xsl:element name="usage_mode">1</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Add STPs to customer order if exists -->    
      <xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
        <xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
          <xsl:element name="customer_order_id_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>                                           
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>   
        </xsl:element>
      </xsl:element>
      
      <!-- Create Customer Order for  Service, if no co has been found -->    
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>                                
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>           
        </xsl:element>
      </xsl:element>
      
      <!--Release customer order for service, if no co has been found -->
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
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>             
        </xsl:element>
      </xsl:element>
      
      <!-- Create Contact-->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">CUSTOMER_ORDER</xsl:element>
          <xsl:element name="short_description">
            <xsl:text>Dienst hinzugefügt über </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
          </xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
              <xsl:text>&#xA;Service Code: </xsl:text>
              <xsl:value-of select="$ServiceCode"/>
               <xsl:text>&#xA;Desired Date: </xsl:text>
              <xsl:value-of select="$DesiredDate"/>                            
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>

