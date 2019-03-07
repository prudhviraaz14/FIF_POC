<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating selected destinations

  @author banania
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  exclude-result-prefixes="dateutils">
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

      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>     
      <xsl:variable name="Type" select="request-param[@name='type']"/> 
      <xsl:variable name="DesiredDate" select="request-param[@name='desiredDate']"/> 
            
      <xsl:if test="request-param[@name='serviceSubscriptionId'] = ''
        and $Type = ''">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">type_error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The paramter type has to be set if serviceSubscriptionId is empty!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Validate the parameter type -->
      <xsl:if test="(($Type != '')
        and ($Type != 'VoIP')
        and ($Type != 'NGNVoIP')
        and ($Type != 'ISDN')      
        and ($Type != 'ONLINE')   
        and (request-param[@name='serviceSubscriptionId'] = ''))">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">type_error_2</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The parameter type has to  be set to ISDN, ONLINE, VoIP or NGNVoIP!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Find the main Service by Service Subscription Id-->
      <xsl:if test="request-param[@name='serviceSubscriptionId']!= '' ">
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
  
      <!--Get Customer Number if not provided-->
      <xsl:if test="(request-param[@name='customerNumber'] = '')">
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_external_notification_1</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Take value of serviceSubscriptionId from ccm external notification if serviceSubscriptionId not provided -->
      <xsl:if test="request-param[@name='serviceSubscriptionId']= '' ">        
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_external_notification_2</xsl:element>
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
              <xsl:element name="command_id">read_external_notification_2</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="$DesiredDate"/>
            </xsl:element> 
          </xsl:element>
        </xsl:element>
      </xsl:if>
           
      <!-- Find Price Plan -->      
      <xsl:element name="CcmFifFindPricePlanSubsCmd">
        <xsl:element name="command_id">find_pps_1</xsl:element>
        <xsl:element name="CcmFifFindPricePlanSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element>                  
          <xsl:element name="selected_destination_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Configure Price Plan -->
      <xsl:element name="CcmFifConfigurePPSCmd">
        <xsl:element name="command_id">config_pps_1</xsl:element>
        <xsl:element name="CcmFifConfigurePPSInCont">
          <xsl:element name="price_plan_subs_list_ref">
            <xsl:element name="command_id">find_pps_1</xsl:element>
            <xsl:element name="field_name">price_plan_subs_list</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element>
          <xsl:if
            test="count(request-param-list[@name='selectedDestinationsList']/request-param-list-item) != 0">
            <xsl:element name="selected_destinations_list">
              <!-- Selected Destinations -->
              <xsl:for-each
                select="request-param-list[@name='selectedDestinationsList']/request-param-list-item">
                <xsl:element name="CcmFifSelectedDestCont">
                  <xsl:element name="begin_number">
                    <xsl:value-of select="request-param[@name='beginNumber']"/>
                  </xsl:element>
                  <xsl:element name="start_date">
                    <xsl:value-of select="$DesiredDate"/>
                  </xsl:element>
                </xsl:element>
              </xsl:for-each>
            </xsl:element>
          </xsl:if>          
        </xsl:element>
      </xsl:element>

      <!-- Create Contact-->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="command_id">create_contact_1</xsl:element>
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:if test="request-param[@name='customerNumber'] != ''">	
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='customerNumber'] = ''">					
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="contact_type_rd">INFO</xsl:element>
          <xsl:element name="caller_name">SYSTEM</xsl:element>
          <xsl:element name="caller_phone_number">SYSTEM</xsl:element>
          <xsl:element name="author_name">
            <xsl:value-of select="request-param[@name='userName']"/>
          </xsl:element>
          <xsl:element name="short_description">Create Selected Destinations</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>Rabattierte Zielrufnummern hinzugefügt:</xsl:text>
              <xsl:text>&#xA;TransactionID: </xsl:text>
              <xsl:value-of select="request-param[@name='transactionID']"/>
              <xsl:text>&#xA;Desired Date: </xsl:text>
              <xsl:value-of select="$DesiredDate"/>
              <xsl:text>&#xA;User name: </xsl:text>
              <xsl:value-of select="request-param[@name='userName']"/>
              <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
              <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
          </xsl:element>         
        </xsl:element>
      </xsl:element>

      <xsl:if test="request-param[@name='clientName'] != 'KBA'">
        <!-- Create KBA notification  -->
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_kba_notification_1</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='startDate']"/>
            </xsl:element>
            <xsl:element name="notification_action_name">createKBANotification</xsl:element>
            <xsl:element name="target_system">KBA</xsl:element>            
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>						
                <xsl:if test="request-param[@name='customerNumber'] != ''">	
                  <xsl:element name="parameter_value">
                    <xsl:value-of select="request-param[@name='customerNumber']"/>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='customerNumber'] = ''">	
                  <xsl:element name="parameter_value_ref">
                    <xsl:element name="command_id">read_external_notification_1</xsl:element>
                    <xsl:element name="field_name">parameter_value</xsl:element>
                  </xsl:element>
                </xsl:if>												
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TYPE</xsl:element>
                <xsl:element name="parameter_value">CONTACT</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CATEGORY</xsl:element>
                <xsl:element name="parameter_value">Rabattierte Zielrufnummern</xsl:element>
              </xsl:element>
              <xsl:if test="request-param[@name='userName'] != ''">              
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">USER_NAME</xsl:element>
                  <xsl:element name="parameter_value">
                    <xsl:value-of select="request-param[@name='userName']"/>
                  </xsl:element>
                </xsl:element>
              </xsl:if>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">WORK_DATE</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="$today"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TEXT</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:text>Rabattierte Zielrufnummern wurden geändert</xsl:text>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
