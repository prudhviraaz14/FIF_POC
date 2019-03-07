<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating GSM-Retention special offer Service Subscription FIF request

  @author banania
-->
<xsl:stylesheet 
    exclude-result-prefixes="dateutils" 
    version="1.0"
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

      <xsl:variable name="Today" select="dateutils:getCurrentDate()"/>
      
      <xsl:variable name="DesiredDate">  
        <xsl:choose>
          <xsl:when test ="request-param[@name='DESIRED_DATE'] = ''">
            <xsl:value-of select="$Today"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>
 
      <xsl:variable name="SelecteDestinationDate">  
        <xsl:choose>
          <xsl:when test ="request-param[@name='DESIRED_DATE'] = ''">
            <xsl:value-of select="dateutils:createFIFDateOffset($Today, 'DATE', '1')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>
            
      <xsl:variable name="DesiredScheduleType">  
        <xsl:choose>
          <xsl:when test ="request-param[@name='DESIRED_DATE'] != ''">
            <xsl:text>START_AFTER</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>ASAP</xsl:text>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>
      
      <xsl:if test="request-param[@name='ACCESS_NUMBER_1'] = ''
        and request-param[@name='ACCESS_NUMBER_2'] = ''
        and request-param[@name='ACCESS_NUMBER_3'] = ''
        and request-param[@name='ACCESS_NUMBER_4'] = ''
        and request-param[@name='ACCESS_NUMBER_5'] = ''">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">type_error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Al least one of the paramters ACCESS_NUMBER_1..5 must be set!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Find main access service -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">          
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Find SIM Only service -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_sim_only_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="product_subscription_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V0321</xsl:element>
          <xsl:element name="no_service_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
           
      <!-- lock product to avoid concurrency problems -->
      <xsl:element name="CcmFifLockObjectCmd">
        <xsl:element name="CcmFifLockObjectInCont">
          <xsl:element name="object_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>							
          </xsl:element>
          <xsl:element name="object_type">PROD_SUBS</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Add Feature Service -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V0321</xsl:element>
          <xsl:element name="parent_service_subs_id">
            <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">
            <xsl:value-of select="$DesiredScheduleType"/>
          </xsl:element>
          <xsl:element name="reason_rd">SIM_ONLY_SERV</xsl:element>
          <xsl:if test="request-param[@name='ACCOUNT_NUMBER'] = ''">
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='ACCOUNT_NUMBER'] != ''">
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:element>
          </xsl:if>  
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_sim_only_service_1</xsl:element>
            <xsl:element name="field_name">service_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>          
          <xsl:element name="service_characteristic_list">
          </xsl:element>                    
        </xsl:element>
      </xsl:element>

      <!-- Add contributing items -->
      <xsl:element name="CcmFifAddModifyContributingItemCmd">
        <xsl:element name="CcmFifAddModifyContributingItemInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V0321</xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element>
          <xsl:element name="contributing_item_list">
            <xsl:element name="CcmFifContributingItem">
              <xsl:element name="supported_object_type_rd">SERVICE_SUBSC</xsl:element>
              <xsl:element name="start_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="service_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
       <!--  <xsl:element name="no_price_plan_error">N</xsl:element>
          <xsl:element name="ignore_contributing_item_ind">Y</xsl:element>-->
        </xsl:element>
      </xsl:element>
 
      <!-- Find Price Plan -->      
      <xsl:element name="CcmFifFindPricePlanSubsCmd">
        <xsl:element name="command_id">find_pps_1</xsl:element>
        <xsl:element name="CcmFifFindPricePlanSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="price_plan_code">V3247</xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element>                  
          <xsl:element name="selected_destination_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>


      <!-- Deactivate first existing Selected destinations -->
      <xsl:element name="CcmFifDeactSelectedDestForPpsCmd">
        <xsl:element name="command_id">deact_sd_1</xsl:element>
        <xsl:element name="CcmFifDeactSelectedDestForPpsInCont">
          <xsl:element name="price_plan_subs_list_ref">
            <xsl:element name="command_id">find_pps_1</xsl:element>
            <xsl:element name="field_name">price_plan_subs_list</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$SelecteDestinationDate"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

            
      <!-- Create Selected Destinations --> 
      <xsl:if
        test="request-param[@name='ACCESS_NUMBER_1'] != ''">       
      <xsl:element name="CcmFifConfigurePPSCmd">
        <xsl:element name="command_id">config_pps_1</xsl:element>
        <xsl:element name="CcmFifConfigurePPSInCont">
          <xsl:element name="price_plan_subs_list_ref">
            <xsl:element name="command_id">find_pps_1</xsl:element>
            <xsl:element name="field_name">price_plan_subs_list</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$SelecteDestinationDate"/>
          </xsl:element>
          <xsl:element name="selected_destinations_list">
            <xsl:element name="CcmFifSelectedDestCont">
              <xsl:element name="begin_number">
                <xsl:choose>
                  <xsl:when test="starts-with(request-param[@name='ACCESS_NUMBER_1'], '0')">
                    <xsl:text>49</xsl:text>
                    <xsl:value-of select="substring(request-param[@name='ACCESS_NUMBER_1'], 2)"/>                        
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="request-param[@name='ACCESS_NUMBER_1']"/>    
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:element>
              <xsl:element name="start_date">
                <xsl:value-of select="$SelecteDestinationDate"/>
              </xsl:element>
            </xsl:element>    
          </xsl:element>       
        </xsl:element>
      </xsl:element>
      </xsl:if> 

      <!-- Create Selected Destinations --> 
      <xsl:if
        test="request-param[@name='ACCESS_NUMBER_2'] != ''">       
        <xsl:element name="CcmFifConfigurePPSCmd">
          <xsl:element name="command_id">config_pps_1</xsl:element>
          <xsl:element name="CcmFifConfigurePPSInCont">
            <xsl:element name="price_plan_subs_list_ref">
              <xsl:element name="command_id">find_pps_1</xsl:element>
              <xsl:element name="field_name">price_plan_subs_list</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="$SelecteDestinationDate"/>
            </xsl:element>
            <xsl:element name="selected_destinations_list">
              <xsl:element name="CcmFifSelectedDestCont">
                <xsl:element name="begin_number">
                  <xsl:choose>
                    <xsl:when test="starts-with(request-param[@name='ACCESS_NUMBER_2'], '0')">
                      <xsl:text>49</xsl:text>
                      <xsl:value-of select="substring(request-param[@name='ACCESS_NUMBER_2'], 2)"/>                        
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="request-param[@name='ACCESS_NUMBER_2']"/>    
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:element>
                <xsl:element name="start_date">
                  <xsl:value-of select="$SelecteDestinationDate"/>
                </xsl:element>
              </xsl:element>    
            </xsl:element>       
          </xsl:element>
        </xsl:element>
      </xsl:if> 

      <!-- Create Selected Destinations --> 
      <xsl:if
        test="request-param[@name='ACCESS_NUMBER_3'] != ''">       
        <xsl:element name="CcmFifConfigurePPSCmd">
          <xsl:element name="command_id">config_pps_1</xsl:element>
          <xsl:element name="CcmFifConfigurePPSInCont">
            <xsl:element name="price_plan_subs_list_ref">
              <xsl:element name="command_id">find_pps_1</xsl:element>
              <xsl:element name="field_name">price_plan_subs_list</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="$SelecteDestinationDate"/>
            </xsl:element>
            <xsl:element name="selected_destinations_list">
              <xsl:element name="CcmFifSelectedDestCont">
                <xsl:element name="begin_number">
                  <xsl:choose>
                    <xsl:when test="starts-with(request-param[@name='ACCESS_NUMBER_3'], '0')">
                      <xsl:text>49</xsl:text>
                      <xsl:value-of select="substring(request-param[@name='ACCESS_NUMBER_3'], 2)"/>                        
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="request-param[@name='ACCESS_NUMBER_3']"/>    
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:element>
                <xsl:element name="start_date">
                  <xsl:value-of select="$SelecteDestinationDate"/>
                </xsl:element>
              </xsl:element>    
            </xsl:element>      
          </xsl:element>
        </xsl:element>
      </xsl:if>      
      
      <!-- Create Selected Destinations --> 
      <xsl:if
        test="request-param[@name='ACCESS_NUMBER_4'] != ''">       
        <xsl:element name="CcmFifConfigurePPSCmd">
          <xsl:element name="command_id">config_pps_1</xsl:element>
          <xsl:element name="CcmFifConfigurePPSInCont">
            <xsl:element name="price_plan_subs_list_ref">
              <xsl:element name="command_id">find_pps_1</xsl:element>
              <xsl:element name="field_name">price_plan_subs_list</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="$SelecteDestinationDate"/>
            </xsl:element>
            <xsl:element name="selected_destinations_list">
              <xsl:element name="CcmFifSelectedDestCont">
                <xsl:element name="begin_number">
                  <xsl:choose>
                    <xsl:when test="starts-with(request-param[@name='ACCESS_NUMBER_4'], '0')">
                      <xsl:text>49</xsl:text>
                      <xsl:value-of select="substring(request-param[@name='ACCESS_NUMBER_4'], 2)"/>                        
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="request-param[@name='ACCESS_NUMBER_4']"/>    
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:element>
                <xsl:element name="start_date">
                  <xsl:value-of select="$SelecteDestinationDate"/>
                </xsl:element>
              </xsl:element>    
            </xsl:element>      
          </xsl:element>
        </xsl:element>
      </xsl:if> 
      
      <!-- Create Selected Destinations --> 
      <xsl:if
        test="request-param[@name='ACCESS_NUMBER_5'] != ''">       
        <xsl:element name="CcmFifConfigurePPSCmd">
          <xsl:element name="command_id">config_pps_1</xsl:element>
          <xsl:element name="CcmFifConfigurePPSInCont">
            <xsl:element name="price_plan_subs_list_ref">
              <xsl:element name="command_id">find_pps_1</xsl:element>
              <xsl:element name="field_name">price_plan_subs_list</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="$SelecteDestinationDate"/>
            </xsl:element>
            <xsl:element name="selected_destinations_list">
              <xsl:element name="CcmFifSelectedDestCont">
              <xsl:element name="begin_number">
                <xsl:choose>
                  <xsl:when test="starts-with(request-param[@name='ACCESS_NUMBER_5'], '0')">
                    <xsl:text>49</xsl:text>
                    <xsl:value-of select="substring(request-param[@name='ACCESS_NUMBER_5'], 2)"/>                        
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="request-param[@name='ACCESS_NUMBER_5']"/>    
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:element>
              <xsl:element name="start_date">
                <xsl:value-of select="$SelecteDestinationDate"/>
              </xsl:element>
              </xsl:element>    
            </xsl:element>     
          </xsl:element>
        </xsl:element>
      </xsl:if> 
      
      <!-- Create Customer Order -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Release Customer Order -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="ignore_empty_list_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Contact -->     
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">SIM_ONLY_SERV</xsl:element>
          <xsl:element name="short_description">SIM Only Dienst hinzugefügt</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>SIM Only Dienst hinzugefügt über </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
            <xsl:text>&#xA;TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;Service Code: V0321</xsl:text>
            <xsl:text>&#xA;Wunschdatum: </xsl:text>
            <xsl:value-of select="$DesiredDate"/>    
          </xsl:element> 
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_sim_only_service_1</xsl:element>
            <xsl:element name="field_name">service_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>          
        </xsl:element>
      </xsl:element>
  
      <!-- Create Contact -->     
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">SIM_ONLY_SERV</xsl:element>
          <xsl:element name="short_description">SIM Only Dienst hinzugefügt</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>Rabattierte Zielrufnummern und Elemente hinzugefügt über </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
            <xsl:text>&#xA;TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;Wunschdatum: </xsl:text>
            <xsl:value-of select="$DesiredDate"/>    
          </xsl:element> 
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_sim_only_service_1</xsl:element>
            <xsl:element name="field_name">service_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>          
        </xsl:element>         
      </xsl:element>
          
        <!-- Create KBA notification  -->
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <!-- Get today's date -->
          <xsl:variable name="today" select="dateutils:getCurrentDate()"/> 
          <xsl:element name="command_id">create_kba_notification_1</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="effective_date">        
              <xsl:value-of select="$DesiredDate"/>                          
            </xsl:element>                
            <xsl:element name="notification_action_name">createKBANotification</xsl:element>
            <xsl:element name="target_system">KBA</xsl:element>
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                  <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/></xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">TYPE</xsl:element>
                  <xsl:element name="parameter_value">CONTACT</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">CATEGORY</xsl:element>
                  <xsl:element name="parameter_value">AddSIMOnlyService</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">USER_NAME</xsl:element>
                  <xsl:element name="parameter_value">SLS</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">WORK_DATE</xsl:element>
                  <xsl:element name="parameter_value">
                    <xsl:value-of select="$DesiredDate"/>                         
                  </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TEXT</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:text>SIM Only / Rabattierte Zielrufnummern und Elemente hinzugefügt über </xsl:text>
                  <xsl:value-of select="request-param[@name='clientName']"/>
                  <xsl:text>&#xA;TransactionID: </xsl:text>
                  <xsl:value-of select="request-param[@name='transactionID']"/>
                  <xsl:text>&#xA;Wunschdatum: </xsl:text>
                  <xsl:value-of select="$DesiredDate"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>     
          </xsl:element>
        </xsl:element>


    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
