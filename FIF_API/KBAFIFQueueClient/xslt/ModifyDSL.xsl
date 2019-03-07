<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated relocation FIF request

  @author lejam
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
      
    <xsl:if
      test="(count(request-param-list[@name='featureServiceListRemove']/request-param-list-item) != 0) or
      (count(request-param-list[@name='featureServiceListAdd']/request-param-list-item) != 0)">
      <!-- Generate Base Command Id for add and terminate service -->
      <xsl:variable name="AddServCommandId">add_ss_</xsl:variable>
      <xsl:variable name="DesiredDate" select="request-param[@name='desiredDate']"/>
     

      <!-- Find Service Subscription Service Subscription Id-->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">                        
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element>
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>


      <!-- Validate allowed service code -->
      <xsl:element name="CcmFifValidateValueCmd">
        <xsl:element name="command_id">validate_service_code_1</xsl:element>
        <xsl:element name="CcmFifValidateValueInCont">
          <xsl:element name="value_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>
          </xsl:element>
          <xsl:element name="object_type">SERVICED_SUBSCRIPTION</xsl:element>
          <xsl:element name="value_type">SERVICE_CODE</xsl:element>
          <xsl:element name="allowed_values">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">I1213</xsl:element>          	  
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">I1043</xsl:element>          	  
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
      

      <!-- Validate that the accounts are active  -->
      <xsl:element name="CcmFifValidateServiceAccountCmd">
        <xsl:element name="command_id">validate_ss_account_1</xsl:element>
        <xsl:element name="CcmFifValidateServiceAccountInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>     


      <!-- Reconfigure the main access service on desired date BitDSL -->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconf_serv_1</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="reason_rd">MODIFY_FEATURES</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Grund der Neukonfiguration -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0943</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Leistungsänderung</xsl:element>
            </xsl:element>
            <!-- Special-Letter Indicator  -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0216</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Standardbriefe</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">I1213</xsl:element>
        </xsl:element>
      </xsl:element>
      

      <!-- Reconfigure the main access service on desired date DSLR -->
      <xsl:element name="CcmFifReconfigServiceCmd">
      <xsl:element name="command_id">reconf_serv_1</xsl:element>
      <xsl:element name="CcmFifReconfigServiceInCont">
        <xsl:element name="service_subscription_ref">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="field_name">service_subscription_id</xsl:element>
        </xsl:element>
        <xsl:element name="desired_date">
          <xsl:value-of select="$DesiredDate"/>
        </xsl:element>
        <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
        <xsl:element name="reason_rd">MODIFY_FEATURES</xsl:element>
        <xsl:element name="service_characteristic_list">
          <!-- Auftragsvariante -->
          <xsl:element name="CcmFifConfiguredValueCont">
            <xsl:element name="service_char_code">I1011</xsl:element>
            <xsl:element name="data_type">STRING</xsl:element>
            <xsl:element name="configured_value">Leistungsänderung</xsl:element>
          </xsl:element>
        </xsl:element>
        <xsl:element name="process_ind_ref">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="field_name">service_code</xsl:element>
        </xsl:element>
        <xsl:element name="required_process_ind">I1043</xsl:element>
      </xsl:element>
    </xsl:element>

      <xsl:if test="((count(request-param-list[@name='featureServiceListRemove']/request-param-list-item) = 0) and
        (count(request-param-list[@name='featureServiceListAdd']/request-param-list-item) != 0))">
        <xsl:for-each select="request-param-list[@name='featureServiceListAdd']/request-param-list-item">
          <xsl:if test="request-param[@name='serviceCode'] = 'I1045'">
            <xsl:element name="CcmFifReconfigServiceCmd">
              <xsl:element name="command_id">reconf_serv_11</xsl:element>
              <xsl:element name="CcmFifReconfigServiceInCont">
                <xsl:element name="service_subscription_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">service_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="service_ticket_position_id_ref">
                  <xsl:element name="command_id">reconf_serv_1</xsl:element>
                  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                </xsl:element>
                  <xsl:element name="desired_date">
                  <xsl:value-of select="$DesiredDate"/>
                </xsl:element>
                <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
                <xsl:element name="reason_rd">MODIFY_FEATURES</xsl:element>
                <xsl:element name="service_characteristic_list">
                  <!-- Fastpath -->
                  <xsl:element name="CcmFifConfiguredValueCont">
                    <xsl:element name="service_char_code">I1009</xsl:element>
                    <xsl:element name="data_type">STRING</xsl:element>
                    <xsl:element name="configured_value">Ja</xsl:element>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">service_code</xsl:element>
                </xsl:element>
                <xsl:element name="required_process_ind">I1043</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:if>      
        </xsl:for-each>
      </xsl:if>      
      
      <xsl:if test="((count(request-param-list[@name='featureServiceListRemove']/request-param-list-item) != 0) and
        (count(request-param-list[@name='featureServiceListAdd']/request-param-list-item) = 0))">
        <xsl:for-each select="request-param-list[@name='featureServiceListRemove']/request-param-list-item">
          <xsl:if test="request-param[@name='serviceCode'] = 'I1045'">
            <xsl:element name="CcmFifReconfigServiceCmd">
              <xsl:element name="command_id">reconf_serv_12</xsl:element>
              <xsl:element name="CcmFifReconfigServiceInCont">
                <xsl:element name="service_subscription_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">service_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="service_ticket_position_id_ref">
                  <xsl:element name="command_id">reconf_serv_1</xsl:element>
                  <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                </xsl:element>
                <xsl:element name="desired_date">
                  <xsl:value-of select="$DesiredDate"/>
                </xsl:element>
                <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
                <xsl:element name="reason_rd">MODIFY_FEATURES</xsl:element>
                <xsl:element name="service_characteristic_list">
                  <!-- Fastpath -->
                  <xsl:element name="CcmFifConfiguredValueCont">
                    <xsl:element name="service_char_code">I1009</xsl:element>
                    <xsl:element name="data_type">STRING</xsl:element>
                    <xsl:element name="configured_value">Nein</xsl:element>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="process_ind_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">service_code</xsl:element>
                </xsl:element>
                <xsl:element name="required_process_ind">I1043</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:if>      
        </xsl:for-each>
      </xsl:if>      
      
      <xsl:if test="count(request-param-list[@name='featureServiceListAdd']/request-param-list-item) != 0">
        <xsl:variable name="SalesOrganisationNumber" select="request-param[@name='salesOrganisationNumber']"/> 
        <!-- Set the new desired tariff options -->
        <xsl:for-each select="request-param-list[@name='featureServiceListAdd']/request-param-list-item">

          <xsl:variable name="ServiceCode" select="request-param[@name='serviceCode']"/>
          <!-- Add new tariff option service -->
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
              <xsl:if test="($SalesOrganisationNumber!='')">
                <xsl:element name="sales_organisation_number">
                  <xsl:value-of select="$SalesOrganisationNumber"/>
                </xsl:element>    
              </xsl:if>
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">MODIFY_FEATURES</xsl:element>
              <xsl:if test="request-param[@name='accountNumber']=''">
                <xsl:element name="account_number_ref">
                  <xsl:element name="command_id">find_service_1</xsl:element>
                  <xsl:element name="field_name">parameter_value</xsl:element>
                </xsl:element>
              </xsl:if>
              <xsl:if test="request-param[@name='accountNumber']!=''">
                <xsl:element name="account_number">
                  <xsl:value-of select="request-param[@name='accountNumber']"/>
                </xsl:element>
              </xsl:if>
              <xsl:element name="service_characteristic_list"/> 
            </xsl:element>
          </xsl:element>

        </xsl:for-each>
      </xsl:if>
      
      <!-- Terminate Services -->
      <xsl:if test="count(request-param-list[@name='featureServiceListRemove']/request-param-list-item) != 0">
        <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
          <xsl:element name="command_id">term_child_ss_1</xsl:element>
          <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
            <xsl:element name="service_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="no_child_error_ind">N</xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="reason_rd">MODIFY_FEATURES</xsl:element>
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


      <!-- Create Customer Order for add and terminate feature Services -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="parent_customer_order_ref">
            <xsl:element name="command_id">find_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="cust_order_description">Änderung Zusatzdienste</xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="ignore_empty_list_ind">Y</xsl:element> 
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconf_serv_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
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
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">term_child_ss_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Release stand alone Customer Order for add and terminate discount Services -->
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
           <xsl:element name="ignore_empty_list_ind">Y</xsl:element> 
        </xsl:element>
      </xsl:element>


      <!-- Create Contact for the Service Termination -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">MODIFY_FEATURES</xsl:element>
          <xsl:element name="short_description">Änderung Zusatzdienste</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;User Name: </xsl:text>
            <xsl:value-of select="request-param[@name='userName']"/>
            <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
            <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
            <xsl:text>&#xA;Neue Zusatzdienste: </xsl:text>
            <xsl:for-each select="request-param-list[@name='featureServiceListAdd']/request-param-list-item">
              <xsl:value-of select="request-param[@name='serviceCode']"/>
              <xsl:text> </xsl:text>
            </xsl:for-each>
            <xsl:text>&#xA;Gekündigte Zusatzdienste: </xsl:text>
            <xsl:for-each select="request-param-list[@name='featureServiceListRemove']/request-param-list-item">
              <xsl:value-of select="request-param[@name='serviceCode']"/>
              <xsl:text> </xsl:text>
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
  
      <xsl:if test="request-param[@name='clientName'] != 'KBA'">
        <!-- Create KBA notification  -->
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_kba_notification_1</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="effective_date">
              <xsl:if test="request-param[@name='desiredDate'] != ''">
                <xsl:value-of select="request-param[@name='desiredDate']"/>
              </xsl:if>
              <xsl:if test="request-param[@name='desiredDate'] = ''">
                <xsl:value-of select="dateutils:getCurrentDate()"/>
              </xsl:if>
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
                <xsl:element name="parameter_value">ModifyDSL</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">USER_NAME</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='clientName']"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">WORK_DATE</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:if test="request-param[@name='desiredDate'] != ''">
                    <xsl:value-of select="request-param[@name='desiredDate']"/>
                  </xsl:if>
                  <xsl:if test="request-param[@name='desiredDate'] = ''">
                    <xsl:value-of select="dateutils:getCurrentDate()"/>
                  </xsl:if>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TEXT</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:text>Änderung Zusatzdienste über </xsl:text>
                  <xsl:value-of select="request-param[@name='clientName']"/>
                  <xsl:if test="request-param[@name='userName'] != ''">
                    <xsl:text> von </xsl:text>
                    <xsl:value-of select="request-param[@name='userName']"/>
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
                    <xsl:text>)</xsl:text>
                  </xsl:if>
                  <xsl:text>. Gekündigte Zusatzdienste: </xsl:text>
                  <xsl:variable name="oldTariffOptionCount" select="(count(request-param-list[@name='featureServiceListRemove']/request-param-list-item))"/>
                  <xsl:for-each select="request-param-list[@name='featureServiceListRemove']/request-param-list-item">
                    <xsl:value-of select="request-param[@name='serviceCode']"/>
                    <xsl:if test="position() != $oldTariffOptionCount">
                      <xsl:text>, </xsl:text>
                    </xsl:if>
                  </xsl:for-each>
                  <xsl:text>. Neue Zusatzdienste: </xsl:text>
                  <xsl:variable name="newTariffOptionCount" select="(count(request-param-list[@name='featureServiceListAdd']/request-param-list-item))"/>
                  <xsl:for-each select="request-param-list[@name='featureServiceListAdd']/request-param-list-item">
                    <xsl:value-of select="request-param[@name='serviceCode']"/>
                    <xsl:if test="position() != $newTariffOptionCount">
                      <xsl:text>, </xsl:text>
                    </xsl:if>
                  </xsl:for-each>
                  <xsl:text>.</xsl:text>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

    </xsl:if>
      
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
