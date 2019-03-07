<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated reconfigure mailbox 
  alias FIF request

  @author goethalo
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
    <xsl:element name="client_name">KBA</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    
    <xsl:variable name="today"
      select="dateutils:getCurrentDate()"/>
    <xsl:variable name="tomorrow"
      select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
    <!-- Convert tomorrow to OPM format -->
      <xsl:variable name="tomorrowOPM" select="dateutils:createOPMDate($tomorrow)"/>

    <!-- Convert the desired date to OPM format -->
    <xsl:variable name="desiredDateOPM"
      select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
        
    <xsl:element name="Command_List">
    
      <xsl:variable name="AccessNumber">
        <xsl:value-of select="request-param-list[@name='oldMailboxAliasList']/request-param-list-item/request-param[@name='oldMailboxAlias']"/>
      </xsl:variable>
        
      <!-- Ensure that either accessNumber, serviceTicketPositionId or serviceSubscriptionId are provided -->
      <xsl:if test="(($AccessNumber = '') and
        (request-param[@name='serviceTicketPositionId'] = '')  and
        (request-param[@name='serviceSubscriptionId'] = ''))">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">create_error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">At least one of the following params must be provided:
              accessNumber, serviceTicketPositionId or serviceSubscriptionId.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>     
      
      <!-- Ensure that the number of the elements in the list "oldMailboxAliasList" must be the same as the one in the list "newldMailboxAliasList -->      
      <xsl:variable name="OldMailboxCount" select="(count(request-param-list[@name='oldMailboxAliasList']/request-param-list-item))"/>
      <xsl:variable name="NewMailboxCount" select="(count(request-param-list[@name='newMailboxAliasList']/request-param-list-item))"/>
      
      <xsl:if test="$OldMailboxCount != $NewMailboxCount">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">create_error_2</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The number of the elements in the list "oldMailboxAliasList" must be the same as the one in the list "newMailboxAliasList"</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>  
       
      <!-- Find Service Subscription -->    
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:if test="(($AccessNumber != '') and
            (request-param[@name='serviceTicketPositionId'] = '') and
            (request-param[@name='serviceSubscriptionId'] = ''))">  
            <xsl:element name="access_number">
              <xsl:value-of select="$AccessNumber"/>
            </xsl:element>
            <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
            <xsl:element name="access_number_type">USER_ACCOUNT_NUM</xsl:element>              
          </xsl:if>
          <xsl:if test="(request-param[@name='serviceTicketPositionId'] != '') and
            (request-param[@name='serviceSubscriptionId'] = '')">
            <xsl:element name="service_ticket_position_id">
              <xsl:value-of select="request-param[@name='serviceTicketPositionId']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
            </xsl:element>
          </xsl:if>
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="product_code">
            <xsl:value-of select="request-param[@name='productCode']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>      
      
      <xsl:if test="(request-param[@name='productCode'] != 'VI201') 
        and (request-param[@name='productCode'] != 'VI202')
        and (request-param[@name='productCode'] != 'VI203')">             
       
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
        
        <!-- Validate no uncomplete STPs -->
        <xsl:element name="CcmFifValidateNoUncompleteStpCmd">
          <xsl:element name="command_id">validate_no_uncomplete_stp_1</xsl:element>
          <xsl:element name="CcmFifValidateNoUncompleteStpInCont">
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
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
            <xsl:element name="reason_rd">AEND</xsl:element>
            <xsl:element name="service_characteristic_list">
              <!-- @Call Account Name -->
              <xsl:element name="CcmFifAccessNumberCont">
                <xsl:element name="service_char_code">VI001</xsl:element>
                <xsl:element name="data_type">USER_ACCOUNT_NUM</xsl:element>
                <xsl:element name="network_account">
                  <xsl:value-of select="request-param-list[@name='newMailboxAliasList']/request-param-list-item/request-param[@name='newMailboxAlias']"/>
                </xsl:element>
              </xsl:element>
              <!-- Bearbeitungsart -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">VI002</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">OP</xsl:element>
              </xsl:element>
              <!-- Grund der neukonfiguration -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">VI008</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">reconfigure Mailboxalias</xsl:element>
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
        
        <!-- Create Customer Order for Reconfiguration -->
        <xsl:element name="CcmFifCreateCustOrderCmd">
          <xsl:element name="command_id">create_co_1</xsl:element>
          <xsl:element name="CcmFifCreateCustOrderInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="customer_tracking_id">
              <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
            </xsl:element>
            <xsl:element name="provider_tracking_no">001</xsl:element>
            <xsl:element name="service_ticket_pos_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">reconf_serv_1</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Release Customer Order for Reconfiguration -->
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

      </xsl:if>
      
      <xsl:if test="(request-param[@name='productCode'] = 'VI201') 
        or (request-param[@name='productCode'] = 'VI202')
        or (request-param[@name='productCode'] = 'VI203')">  

        <xsl:variable name="FindServiceCharByValueId">find_ss_char_by_value_</xsl:variable>
                            
        <!-- Lock product subscription  -->
        <xsl:element name="CcmFifLockObjectCmd">
          <xsl:element name="CcmFifLockObjectInCont">
            <xsl:element name="object_id_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="object_type">PROD_SUBS</xsl:element>
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
        
        <!-- Loop through "oldMailboxAliasList" and find the corresponding service characteristic code -->       
        <xsl:for-each select="request-param-list[@name='oldMailboxAliasList']/request-param-list-item">
          <xsl:variable name="OldMailBoxAlias" select="request-param[@name='oldMailboxAlias']"/>
          <xsl:variable name="NodePosition" select="position() mod 10"/>         
          <!-- Find service characteristic code -->
          <xsl:element name="CcmFifFindServiceCharByValueCmd">
            <xsl:element name="command_id">
              <xsl:value-of select="concat($FindServiceCharByValueId, $NodePosition)"/>
            </xsl:element>
            <xsl:element name="CcmFifFindServiceCharByValueInCont">
              <xsl:element name="service_subscription_id_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="characteristic_value">
                <xsl:value-of select="$OldMailBoxAlias"/>
              </xsl:element>
              <xsl:element name="characteristic_type">ACCESS_NUMBER</xsl:element>
            </xsl:element>
          </xsl:element>         
        </xsl:for-each>     
        
        <!-- Reconfigure Service Subscription -->
        <xsl:element name="CcmFifReconfigServiceCmd">
          <xsl:element name="command_id">reconf_serv_1</xsl:element>
          <xsl:element name="CcmFifReconfigServiceInCont">
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
            <xsl:value-of select="$tomorrow"/>	
          </xsl:element>
          <xsl:element name="desired_schedule_type">END_BEFORE</xsl:element>
            <xsl:element name="reason_rd">CHG_MAILBOX</xsl:element>
            <xsl:element name="service_characteristic_list">
              
              <xsl:for-each select="request-param-list[@name='newMailboxAliasList']/request-param-list-item">
                <xsl:variable name="NewMailboxAlias" select="request-param[@name='newMailboxAlias']"/>
                <xsl:variable name="NodePosition" select="position() mod 10"/>  
                <xsl:element name="CcmFifAccessNumberCont">                                
                  <xsl:element name="service_char_code_ref">
                    <xsl:element name="command_id">
                      <xsl:value-of select="concat($FindServiceCharByValueId,$NodePosition)"/>
                    </xsl:element>
                    <xsl:element name="field_name">service_char_code</xsl:element>
                  </xsl:element>
                  <xsl:element name="data_type">USER_ACCOUNT_NUM</xsl:element>
                  <xsl:element name="network_account">
                    <xsl:value-of select="$NewMailboxAlias"/>
                  </xsl:element>
                </xsl:element>     
              </xsl:for-each>
              
              <!-- Bearbeitungsart -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">VI002</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">OP</xsl:element>
              </xsl:element>
              
              <!-- Grund der neukonfiguration -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">VI008</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">reconfigure Mailboxalias</xsl:element>
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
 
        <!-- find an open customer order for the main VoIP service -->
        <xsl:element name="CcmFifFindCustomerOrderCmd">
          <xsl:element name="command_id">find_customer_order_1</xsl:element>
          <xsl:element name="CcmFifFindCustomerOrderInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="reason_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">CHG_MAILBOX</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="state_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">ASSIGNED</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">RELEASED</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="allow_children">N</xsl:element>
          </xsl:element>
        </xsl:element>
               
        <!-- Create Customer Order for Reconfiguration -->
        <xsl:element name="CcmFifCreateCustOrderCmd">
          <xsl:element name="command_id">create_co_1</xsl:element>
          <xsl:element name="CcmFifCreateCustOrderInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="customer_tracking_id">
              <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
            </xsl:element>
            <xsl:element name="provider_tracking_no">001</xsl:element>
            <xsl:element name="ignore_empty_list_ind">Y</xsl:element> 
            <xsl:element name="service_ticket_pos_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">reconf_serv_1</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>             
             
        <!-- Release stand alone Customer Order for reconfigure -->
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="CcmFifReleaseCustOrderInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">create_co_1</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="ignore_empty_list_ind">Y</xsl:element>            
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_customer_order_1</xsl:element>
              <xsl:element name="field_name">customer_order_found</xsl:element>           
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element> 
            <xsl:element name="release_delay_date">
              <xsl:value-of select="$tomorrow"/>	
            </xsl:element>           
          </xsl:element>
        </xsl:element>
        
        <!-- Release dependent Customer Order for reconfigure -->
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="CcmFifReleaseCustOrderInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">create_co_1</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="ignore_empty_list_ind">Y</xsl:element>            
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_customer_order_1</xsl:element>
              <xsl:element name="field_name">customer_order_found</xsl:element>           
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>            
            <xsl:element name="parent_customer_order_id_ref">
              <xsl:element name="command_id">find_customer_order_1</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>              
            </xsl:element>
          </xsl:element>
        </xsl:element>
 
    </xsl:if>
   
      <!-- Create Contact for the Reconfiguration -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">CHANGE_MAILBOX</xsl:element>
          <xsl:element name="short_description">Änderung Mailboxalias</xsl:element>
          <xsl:element name="description_text_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="contact_text">
                <xsl:text>TransactionID: </xsl:text>
                <xsl:value-of select="request-param[@name='transactionID']"/>
                <xsl:text>&#xA;ContractNumber: </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="contact_text">
                <xsl:text>&#xA;ServiceSubscriptionID: </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="contact_text">
                <xsl:text>&#xA;OldMailboxAlias: </xsl:text>
                <xsl:value-of select="request-param-list[@name='oldMailboxAliasList']/request-param-list-item/request-param[@name='oldMailboxAlias']"/>
                <xsl:text>&#xA;NewMailboxAlias: </xsl:text>
                <xsl:value-of select="request-param-list[@name='newMailboxAliasList']/request-param-list-item/request-param[@name='newMailboxAlias']"/>
                <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
                <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
                <xsl:text>&#xA;UserName: </xsl:text>
                <xsl:value-of select="request-param[@name='userName']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
