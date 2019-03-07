<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for modifiying a multi media contract. IT-17690 - IPTV.

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
    <xsl:element name="client_name">KBA</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    
    <!-- Convert the desired date to OPM format -->
    <xsl:variable name="desiredDateOPM"
      select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
      
    <!-- Calculate today and one day before the desired date -->
    <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
    
    <xsl:variable name="AddServCommandId">add_ss_</xsl:variable>
    
    <xsl:element name="Command_List">
 
      <!-- Ensure that the paramter multimediaProduct is set correctly -->
      <xsl:if test="(request-param[@name='FSKLevel'] = '')
        and count(request-param-list[@name='featureServiceListAdd']/request-param-list-item)= 0
        and count(request-param-list[@name='featureServiceListRemove']/request-param-list-item) = 0">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Invalid scenario! The lists of the feature services can not be empty if FSKLevel is not set.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>   
         
        <!-- Look for the Multimedia service -->    
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:element>           
          </xsl:element>
        </xsl:element>

      <!-- Ensure, that the service  belongs to an IP-TV (I1302) or VOD-Basic (I1303) service -->
      <xsl:element name="CcmFifValidateValueCmd">
        <xsl:element name="command_id">validate_value_1</xsl:element>
        <xsl:element name="CcmFifValidateValueInCont">
          <xsl:element name="value_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>
          </xsl:element>
          <xsl:element name="object_type">SERVICE_SUBSCRIPTION</xsl:element>
          <xsl:element name="value_type">SERVICE_CODE</xsl:element>
          <xsl:element name="allowed_values">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">I1302</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">I1303</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Validate the service subscription state -->
      <xsl:element name="CcmFifValidateServiceSubsStateCmd">
        <xsl:element name="command_id">validate_ss_state_1</xsl:element>
        <xsl:element name="CcmFifValidateServiceSubsStateInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_state">SUBSCRIBED</xsl:element>
        </xsl:element>
      </xsl:element>
                    
   
        <!-- Reconfigure Service Subscription -->
        <xsl:element name="CcmFifReconfigServiceCmd">
          <xsl:element name="command_id">reconf_serv_1</xsl:element>
          <xsl:element name="CcmFifReconfigServiceInCont">
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
            <xsl:element name="service_characteristic_list">
              <!-- Reason for reconfiguration -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">I1312</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:if test="request-param[@name='FSKLevel'] != ''">  
                    <xsl:element name="configured_value">FSK-Feature ändern</xsl:element>
                  </xsl:if>
                  <xsl:if test="request-param[@name='FSKLevel'] = ''">  
                    <xsl:element name="configured_value">Feature ändern</xsl:element>
                  </xsl:if>                  
                </xsl:element>
              <!-- FSKLevel -->
              <xsl:if test="request-param[@name='FSKLevel'] != ''">
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">I1314</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">
                    <xsl:value-of select="request-param[@name='FSKLevel']"/>
                  </xsl:element>
                </xsl:element>
              </xsl:if>              
              <!-- Aktivierungsdatum -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0909</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="$desiredDateOPM"/>
                </xsl:element>
              </xsl:element>
              <!-- Comment -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0008</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">Änderung Multimedia-Vertrag</xsl:element>
              </xsl:element>              						
            </xsl:element>
          </xsl:element>
        </xsl:element>        


      <!-- Terminate Old Multimedia Services -->
      <xsl:if test="count(request-param-list[@name='featureServiceListRemove']/request-param-list-item) != 0">
        <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
          <xsl:element name="command_id">term_child_ss_1</xsl:element>
          <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="no_child_error_ind">N</xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
            <xsl:element name="service_code_list">
              <xsl:for-each select="request-param-list[@name='featureServiceListRemove']/request-param-list-item">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="service_code">
                    <xsl:value-of select="request-param[@name='serviceCode']"/>
                  </xsl:element>
                </xsl:element>
              </xsl:for-each>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

       
      <!-- Create Multimedia Services Services -->          
      <xsl:if
        test="count(request-param-list[@name='featureServiceListAdd']/request-param-list-item) != 0">
       
        <xsl:for-each select="request-param-list[@name='featureServiceListAdd']/request-param-list-item">
          <xsl:variable name="ServiceCode" select="request-param[@name='serviceCode']"/>
          <xsl:element name="CcmFifAddServiceSubsCmd">
            <xsl:element name="command_id">
              <xsl:value-of select="concat($AddServCommandId, $ServiceCode)"/>
            </xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">
                <xsl:value-of select="$ServiceCode"/>
              </xsl:element>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_schedule_type">ASAP</xsl:element>
              <xsl:element name="reason_rd">CUST_REQUEST</xsl:element>              
              <xsl:element name="account_number">
                 <xsl:value-of select="request-param[@name='accountNumber']"/>
              </xsl:element>
              <xsl:element name="service_characteristic_list"> </xsl:element>
            </xsl:element>
          </xsl:element>
         </xsl:for-each>
        </xsl:if>

      <!-- Create Customer Order for reconfigurtion, termination of old services and adding of new services  -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>                  
          <xsl:element name="provider_tracking_no">001h</xsl:element> 
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconf_serv_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>  
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">term_child_ss_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
            <xsl:for-each select="request-param-list[@name='featureServiceListAdd']/request-param-list-item">
              <xsl:variable name="ServiceCode" select="request-param[@name='serviceCode']"/>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">
                  <xsl:value-of select="concat($AddServCommandId, $ServiceCode)"/>
                </xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:for-each>
          </xsl:element>                               
        </xsl:element>
      </xsl:element>
                
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
      
      <!-- Create Contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>        
            <xsl:element name="contact_type_rd">MODIFY_MM</xsl:element>      
          <xsl:element name="short_description">Modify Multimedia</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;Desired Date: </xsl:text>
            <xsl:value-of select="request-param[@name='desiredDate']"/>
            <xsl:text>&#xA;User Name: </xsl:text>
            <xsl:value-of select="request-param[@name='userName']"/>
            <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
            <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
