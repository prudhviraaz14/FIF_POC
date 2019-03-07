<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for updating simID for Instant Access

  @author schwarje
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
    
      <xsl:variable name="simID">
        <xsl:value-of select="request-param[@name='simID']"/>        
        <xsl:value-of select="request-param[@name='SIM_ID']"/>        
      </xsl:variable>
      
      <xsl:variable name="serviceSubscriptionId">
        <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>        
        <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>        
      </xsl:variable>
      
      <!-- Find Service Subscription by Service Subscription Id-->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_sim_service</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="$serviceSubscriptionId"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>          
      
      <xsl:variable name="cleanupAction">
        <xsl:choose>
          <xsl:when test="request-param[@name='CLEANUP_ACTION'] = 'ADD'">ADD</xsl:when>
          <xsl:when test="request-param[@name='CLEANUP_ACTION'] = 'REMOVE'">REMOVE</xsl:when>
          <xsl:otherwise>UNKNOWN</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:choose>
        <xsl:when test="$simID != 'unknown' or $cleanupAction = 'REMOVE'">
          
          <xsl:choose>
            <xsl:when test="$cleanupAction = 'ADD'">
              <xsl:element name="CcmFifAddServiceSubsCmd">
                <xsl:element name="command_id">cleanup_action</xsl:element>
                <xsl:element name="CcmFifAddServiceSubsInCont">
                  <xsl:element name="product_subscription_ref">
                    <xsl:element name="command_id">find_sim_service</xsl:element>
                    <xsl:element name="field_name">product_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="service_code">V8042</xsl:element>
                  <xsl:element name="parent_service_subs_ref">
                    <xsl:element name="command_id">find_sim_service</xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                  <xsl:element name="reason_rd">UPDATE_SIM</xsl:element>
                  <xsl:element name="account_number_ref">
                    <xsl:element name="command_id">find_sim_service</xsl:element>
                    <xsl:element name="field_name">account_number</xsl:element>
                  </xsl:element>
                  <xsl:element name="service_characteristic_list">
                    <xsl:element name="CcmFifConfiguredValueCont">
                      <xsl:element name="service_char_code">V0108</xsl:element>
                      <xsl:element name="data_type">STRING</xsl:element>
                      <xsl:element name="configured_value">
                        <xsl:value-of select="$simID"/>
                      </xsl:element>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>          
            </xsl:when>
            
            <xsl:when test="$cleanupAction = 'REMOVE'">
              <!-- TermSuspReactService service -->
              <xsl:element name="CcmFifTermSuspReactServiceSubsCmd">
                <xsl:element name="command_id">cleanup_action</xsl:element>
                <xsl:element name="CcmFifTermSuspReactServiceSubsInCont">
                  <xsl:element name="service_subscription_ref">
                    <xsl:element name="command_id">find_sim_service</xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="usage_mode">4</xsl:element>
                  <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                  <xsl:element name="reason_rd">UPDATE_SIM</xsl:element>
                </xsl:element>
              </xsl:element>          
            </xsl:when>
            
            <xsl:otherwise>
              <!-- reconfigure service subscription -->
              <xsl:element name="CcmFifReconfigServiceCmd">
                <xsl:element name="command_id">reconfigure_serv_charact</xsl:element>
                <xsl:element name="CcmFifReconfigServiceInCont">
                  <xsl:element name="service_subscription_ref">
                    <xsl:element name="command_id">find_sim_service</xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
                  <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                  <xsl:element name="reason_rd">UPDATE_SIM</xsl:element>
                  <xsl:element name="service_characteristic_list">
                    <xsl:element name="CcmFifConfiguredValueCont">
                      <xsl:element name="service_char_code">V0108</xsl:element>
                      <xsl:element name="data_type">STRING</xsl:element>
                      <xsl:element name="configured_value">
                        <xsl:value-of select="$simID"/>
                      </xsl:element>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:otherwise>
          </xsl:choose>
          
          <!-- create customer order -->
          <xsl:element name="CcmFifCreateCustOrderCmd">
            <xsl:element name="command_id">create_co</xsl:element>
            <xsl:element name="CcmFifCreateCustOrderInCont">
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_sim_service</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
              <xsl:element name="service_ticket_pos_list">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:choose>
                    <xsl:when test="$cleanupAction = 'REMOVE'">
                      <xsl:element name="command_id">cleanup_action</xsl:element>
                      <xsl:element name="field_name">service_ticket_pos_list</xsl:element>                      
                    </xsl:when>
                    <xsl:when test="$cleanupAction = 'ADD'">
                      <xsl:element name="command_id">cleanup_action</xsl:element>
                      <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                    </xsl:when>
                    <xsl:when test="$cleanupAction = 'UNKNOWN'">
                      <xsl:element name="command_id">reconfigure_serv_charact</xsl:element>
                      <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                    </xsl:when>
                  </xsl:choose>
                </xsl:element>                
              </xsl:element>
            </xsl:element>
          </xsl:element>
          
          <!-- release customer order -->
          <xsl:element name="CcmFifReleaseCustOrderCmd">
            <xsl:element name="command_id">release_co</xsl:element>
            <xsl:element name="CcmFifReleaseCustOrderInCont">
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_sim_service</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
              <xsl:element name="customer_order_ref">
                <xsl:element name="command_id">create_co</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          
          <xsl:choose>
            <xsl:when test="$cleanupAction = 'UNKNOWN' or $cleanupAction = 'ADD'">
              <xsl:element name="CcmFifCreateContactCmd">
                <xsl:element name="command_id">create_contact</xsl:element>
                <xsl:element name="CcmFifCreateContactInCont">
                  <xsl:element name="customer_number_ref">
                    <xsl:element name="command_id">find_sim_service</xsl:element>
                    <xsl:element name="field_name">customer_number</xsl:element>
                  </xsl:element>
                  <xsl:element name="contact_type_rd">UPDATE_SIM</xsl:element>
                  <xsl:element name="short_description">Aktualisierung Sim-ID</xsl:element>
                  <xsl:element name="description_text_list">
                    <xsl:element name="CcmFifPassingValueCont">
                      <xsl:element name="contact_text">
                        <xsl:text>Sim-ID des Dienstes </xsl:text>
                        <xsl:value-of select="$serviceSubscriptionId"/>
                        <xsl:text> wurde auf </xsl:text>
                        <xsl:value-of select="$simID"/>
                        <xsl:text> geändert.&#xA;TransactionID: </xsl:text>
                        <xsl:value-of select="request-param[@name='transactionID']"/>
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="request-param[@name='clientName']"/>
                        <xsl:text>)</xsl:text>                        
                      </xsl:element>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>     
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="CcmFifCreateContactCmd">
                <xsl:element name="command_id">create_contact</xsl:element>
                <xsl:element name="CcmFifCreateContactInCont">
                  <xsl:element name="customer_number_ref">
                    <xsl:element name="command_id">find_sim_service</xsl:element>
                    <xsl:element name="field_name">customer_number</xsl:element>
                  </xsl:element>
                  <xsl:element name="contact_type_rd">UPDATE_SIM</xsl:element>
                  <xsl:element name="short_description">Löschung Sim-ID</xsl:element>
                  <xsl:element name="description_text_list">
                    <xsl:element name="CcmFifPassingValueCont">
                      <xsl:element name="contact_text">
                        <xsl:text>Sim-ID des Dienstes </xsl:text>
                        <xsl:value-of select="$serviceSubscriptionId"/>
                        <xsl:text> wurde auf entfernt.&#xA;TransactionID: </xsl:text>
                        <xsl:value-of select="request-param[@name='transactionID']"/>
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="request-param[@name='clientName']"/>
                        <xsl:text>)</xsl:text>                                                
                      </xsl:element>
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>                   
            </xsl:otherwise>
          </xsl:choose>          
        </xsl:when>
            
        <xsl:otherwise>          
          <xsl:element name="CcmFifCreateContactCmd">
            <xsl:element name="command_id">create_contact</xsl:element>
            <xsl:element name="CcmFifCreateContactInCont">
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_sim_service</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
              <xsl:element name="contact_type_rd">UPDATE_SIM</xsl:element>
              <xsl:element name="short_description">Fehler bei Akt. Sim-ID</xsl:element>
              <xsl:element name="description_text_list">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="contact_text">
                    <xsl:text>Sim-ID des Dienstes </xsl:text>
                    <xsl:value-of select="$serviceSubscriptionId"/>
                    <xsl:text> konnte nicht geändert werden. Zusätzliche Information des externen Dienstleisters:&#xA;</xsl:text>
                    <xsl:value-of select="request-param[@name='COMMENT']"/>
                    <xsl:text>&#xA;TransactionID: </xsl:text>
                    <xsl:value-of select="request-param[@name='transactionID']"/>
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="request-param[@name='clientName']"/>
                    <xsl:text>)</xsl:text>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>                    
          
          <!-- Create KBA notification  -->
          <xsl:element name="CcmFifCreateExternalNotificationCmd">
            <!-- Get today's date -->
            <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
            <xsl:element name="command_id">create_kba_notification_1</xsl:element>
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
                    <xsl:element name="command_id">find_sim_service</xsl:element>
                    <xsl:element name="field_name">customer_number</xsl:element>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">TYPE</xsl:element>
                  <xsl:element name="parameter_value">PROCESS</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">CATEGORY</xsl:element>
                  <xsl:element name="parameter_value">UpdateSIM</xsl:element>
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
                    <xsl:value-of select="$today"/>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">TEXT</xsl:element>
                  <xsl:element name="parameter_value">
                    <xsl:value-of select="request-param[@name='COMMENT']"/>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
      
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
