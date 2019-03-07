<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for adding Business ADSL Service.
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
        
          <xsl:element name="CcmFifReadExternalNotificationCmd">
            <xsl:element name="command_id">read_external_notification_2</xsl:element>
            <xsl:element name="CcmFifReadExternalNotificationInCont">
              <xsl:element name="transaction_id">
                <xsl:value-of select="$requestListId"/>
              </xsl:element>
              <xsl:element name="parameter_name">ONLINE_SERVICE_SUBSCRIPTION_ID</xsl:element>                        
            </xsl:element>
          </xsl:element>
          
          <!--Get Detailed Reason Rd -->     
          <xsl:element name="CcmFifReadExternalNotificationCmd">
            <xsl:element name="command_id">read_external_notification_3</xsl:element>
            <xsl:element name="CcmFifReadExternalNotificationInCont">
              <xsl:element name="transaction_id">
                <xsl:value-of select="request-param[@name='requestListId']"/>
              </xsl:element>
              <xsl:element name="parameter_name">ISDN_DETAILED_REASON_RD</xsl:element>
              <xsl:element name="ignore_empty_result">Y</xsl:element>
            </xsl:element>
          </xsl:element> 

          <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">read_external_notification_2</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="$DesiredDate"/>
            </xsl:element> 
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:if test="request-param[@name='separateOrderInd'] = 'Y'">
        
        <xsl:variable name="desiredDateOPM"
          select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
        
        <!-- Find bundle in that bundle -->
        <xsl:element name="CcmFifFindBundleCmd">
          <xsl:element name="command_id">find_bundle_onl_1</xsl:element>
        <xsl:element name="CcmFifFindBundleInCont">
          <xsl:element name="bundle_item_type_rd">ONLINE_SERVICE</xsl:element>
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
        </xsl:element>
      </xsl:element>
    
        <!-- Find bundle in that bundle -->
        <xsl:element name="CcmFifFindBundleCmd">
          <xsl:element name="command_id">find_bundle_dslonl_1</xsl:element>
          <xsl:element name="CcmFifFindBundleInCont">
            <xsl:element name="bundle_item_type_rd">DSLONL_SERVICE</xsl:element>
            <xsl:element name="supported_object_id_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- look for an Voice service in that bundle -->
        <xsl:element name="CcmFifFindBundleCmd">
          <xsl:element name="command_id">find_bundle_voice_1</xsl:element>
          <xsl:element name="CcmFifFindBundleInCont">
            <xsl:element name="bundle_id_ref">
              <xsl:element name="command_id">find_bundle_onl_1</xsl:element>
              <xsl:element name="field_name">bundle_id</xsl:element>
            </xsl:element>
            <xsl:element name="bundle_item_type_rd">VOICE_SERVICE</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_bundle_onl_1</xsl:element>
              <xsl:element name="field_name">bundle_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element>
 
        <!-- look for an Voice service in that bundle -->
        <xsl:element name="CcmFifFindBundleCmd">
          <xsl:element name="command_id">find_bundle_voice_1</xsl:element>
          <xsl:element name="CcmFifFindBundleInCont">
            <xsl:element name="bundle_id_ref">
              <xsl:element name="command_id">find_bundle_dslonl_1</xsl:element>
              <xsl:element name="field_name">bundle_id</xsl:element>
            </xsl:element>
            <xsl:element name="bundle_item_type_rd">VOICE_SERVICE</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_bundle_dslonl_1</xsl:element>
              <xsl:element name="field_name">bundle_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element>
               
        <!-- Find  Service Subscription by bundled SS id, if a bundle was found -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_voice_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">find_bundle_voice_1</xsl:element>
              <xsl:element name="field_name">supported_object_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
            
        <!-- Reconfigure main access service -->
		<xsl:element name="CcmFifReconfigServiceCmd">
		  <xsl:element name="command_id">reconf_voice_serv_1</xsl:element>
		  <xsl:element name="CcmFifReconfigServiceInCont">
			<xsl:element name="service_subscription_ref">
			  <xsl:element name="command_id">find_service_voice_1</xsl:element>
			  <xsl:element name="field_name">service_subscription_id</xsl:element>
			</xsl:element>
			<xsl:element name="desired_schedule_type">ASAP</xsl:element>
		    <xsl:element name="reason_rd">CREATE_ONL</xsl:element> 
			<xsl:element name="service_characteristic_list">
			  <!-- Grund der Neukonfiguration -->
			  <xsl:element name="CcmFifConfiguredValueCont">
				 <xsl:element name="service_char_code">V0943</xsl:element>
				 <xsl:element name="data_type">STRING</xsl:element>
			    <xsl:element name="configured_value">Business ADSL Änderungen</xsl:element>
			  </xsl:element>
			  <!-- Bearbeitungsart -->
			  <xsl:element name="CcmFifConfiguredValueCont">
				 <xsl:element name="service_char_code">V0971</xsl:element>
				 <xsl:element name="data_type">STRING</xsl:element>
				 <xsl:element name="configured_value">TAL</xsl:element>
			  </xsl:element>
			  <!-- Bemerkung -->
			  <xsl:element name="CcmFifConfiguredValueCont">
				 <xsl:element name="service_char_code">V0008</xsl:element>
				 <xsl:element name="data_type">STRING</xsl:element>
				 <xsl:element name="configured_value">
				   <xsl:value-of select="request-param[@name='userName']"/>
				 </xsl:element>
			  </xsl:element>
			  <!-- Aktivierungsdatum -->
			  <xsl:element name="CcmFifConfiguredValueCont">
				 <xsl:element name="service_char_code">V0909</xsl:element>
				 <xsl:element name="data_type">STRING</xsl:element>
				 <xsl:element name="configured_value">
				   <xsl:value-of select="$desiredDateOPM"/>
				 </xsl:element>
			  </xsl:element>
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
          <xsl:element name="service_code">I104B</xsl:element>
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
          <xsl:element name="reason_rd">CREATE_ONL</xsl:element>    
          <xsl:if test="request-param[@name='accountNumber'] = ''">  
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='accountNumber'] != ''">   
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='accountNumber']"/>
            </xsl:element>
          </xsl:if>         
          <!-- Bemerkung -->
          <xsl:element name="service_characteristic_list">
            <!-- Dial-In account Name -->
            <xsl:element name="CcmFifAccessNumberCont">
              <xsl:element name="service_char_code">I905A</xsl:element>
              <xsl:element name="data_type">USER_ACCOUNT_NUM</xsl:element>
              <xsl:element name="network_account">
                <xsl:value-of select="request-param[@name='dialInAccountName']"/>
              </xsl:element>
            </xsl:element>
            <!--  IP Address -->
            <xsl:element name="CcmFifAccessNumberCont">
              <xsl:element name="service_char_code">I905B</xsl:element>
              <xsl:element name="data_type">IP_NET_ADDRESS</xsl:element>
              <xsl:element name="ip_number">
                <xsl:value-of select="request-param[@name='IPAddress']"/>
              </xsl:element>
            </xsl:element>
            <!-- Network Element Id -->
            <xsl:if test="request-param[@name='networkElementId'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">Z0100</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='networkElementId']"/>
                </xsl:element>
              </xsl:element> 
            </xsl:if>          
          </xsl:element>
          <xsl:element name="sub_order_id">
            <xsl:value-of select="request-param[@name='SubOrderId']"/>
          </xsl:element>
          <xsl:element name="detailed_reason_ref">
            <xsl:element name="command_id">read_external_notification_3</xsl:element>
            <xsl:element name="field_name">parameter_value</xsl:element>
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
      
      <!-- Create Customer Order -->    
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
          <xsl:element name="lan_path_file_string">
            <xsl:value-of select="request-param[@name='lanPathFileString']"/>
          </xsl:element>
          <xsl:element name="sales_rep_dept">
            <xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
          </xsl:element>
          <xsl:if test="request-param[@name='providerTrackingNumber'] = ''" > 
            <xsl:element name="provider_tracking_no">003</xsl:element> 
          </xsl:if>          
          <xsl:if test="request-param[@name='providerTrackingNumber'] != ''">             
            <xsl:element name="provider_tracking_no">
              <xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:element name="super_customer_tracking_id">
            <xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
          </xsl:element>
          <xsl:element name="scan_date">
            <xsl:value-of select="request-param[@name='scanDate']"/>
          </xsl:element>
          <xsl:element name="order_entry_date">
            <xsl:value-of select="request-param[@name='entryDate']"/>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element> 
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconf_voice_serv_1</xsl:element>
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
      
      <!--Release customer order for the condition services -->
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
      
      <!-- Create Contact for the addition of the condition services -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">CREATE_ONL</xsl:element>
          <xsl:element name="short_description">
            <xsl:text>Dienst hinzugefügt über </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
          </xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
              <xsl:text>&#xA;Service Code: I104B</xsl:text>
               <xsl:text>&#xA;Desired Date: </xsl:text>
              <xsl:value-of select="$DesiredDate"/>  
              <xsl:text>&#xA;User name: </xsl:text>
              <xsl:value-of select="request-param[@name='userName']"/>
              <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
              <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
          
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>

