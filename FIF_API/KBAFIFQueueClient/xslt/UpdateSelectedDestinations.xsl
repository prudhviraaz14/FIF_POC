<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for changing selected destinations

  @author iarizova
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

      <xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">      
        <!-- Find Service Subscription by service_subscription id  -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>      
      <xsl:if test="request-param[@name='serviceSubscriptionId'] = ''">      
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
          </xsl:element>
        </xsl:element>
      </xsl:if>      
      
      <!-- Take value of serviceSubscriptionId from ccm external notification if accessNumber,serviceTicketPositionId,serviceSubscriptionId not provided -->
      <xsl:if test="(request-param[@name='accessNumber'] = '') and
        (request-param[@name='productSubscriptionId'] = '')">

        <xsl:if test="$Type != ''">                          
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
        </xsl:if> 
       
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id_ref">
              <xsl:element name="command_id">read_external_notification_1</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
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
          <xsl:if test="request-param[@name='pricePlanCode'] != '' ">
            <xsl:element name="price_plan_code">
              <xsl:value-of select="request-param[@name='pricePlanCode']"/>
            </xsl:element>
          </xsl:if>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='startDate']"/>
          </xsl:element>                  
          <xsl:element name="selected_destination_ind">Y</xsl:element>
          <xsl:element name="no_price_plan_error">
          	<xsl:choose>
          		<xsl:when test="request-param[@name='workflowType'] = 'COM-OPM-FIF'">Y</xsl:when>
	          	<xsl:otherwise>N</xsl:otherwise>
          	</xsl:choose>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:if test="request-param[@name='workflowType'] != 'COM-OPM-FIF'">
	      <!--  Get Orderform data  --> 
	      <xsl:element name="CcmFifGetOrderFormDataCmd">
	        <xsl:element name="command_id">get_order_form_data_1</xsl:element>
	        <xsl:element name="CcmFifGetOrderFormDataInCont">
	          <xsl:element name="contract_number_ref">
	            <xsl:element name="command_id">find_service_1</xsl:element>
	            <xsl:element name="field_name">contract_number</xsl:element>
	          </xsl:element>           
	          <xsl:element name="process_ind_ref">
	            <xsl:element name="command_id">find_pps_1</xsl:element>
	            <xsl:element name="field_name">price_plan_found</xsl:element>
	          </xsl:element>
	          <xsl:element name="target_state">APPROVED</xsl:element>  
	          <xsl:element name="required_process_ind">N</xsl:element>       
	        </xsl:element>
	      </xsl:element>
	      
	      <xsl:element name="CcmFifCreateFifRequestCmd">
	        <xsl:element name="command_id">create_fif_request_1</xsl:element> 
	        <xsl:element name="CcmFifCreateFifRequestInCont">
	          <xsl:element name="action_name">createSelectedDestination</xsl:element> 
	          <xsl:element name="due_date">
	            <xsl:value-of select="request-param[@name='startDate']"/>
	          </xsl:element> 
	          <xsl:element name="dependent_transaction_id_ref">
	            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
	            <xsl:element name="field_name">pending_fif_transaction_id</xsl:element>
	          </xsl:element>
	          <xsl:element name="bypass_command_ref">
	            <xsl:element name="command_id">find_pps_1</xsl:element>
	            <xsl:element name="field_name">price_plan_found</xsl:element>
	          </xsl:element>              
	          <xsl:element name="request_param_list">
	            <xsl:element name="CcmFifParameterValueCont">
	              <xsl:element name="parameter_name">PRODUCT_SUBSCRIPTION_ID</xsl:element> 
	              <xsl:element name="parameter_value_ref">
	                <xsl:element name="command_id">find_service_1</xsl:element> 
	                <xsl:element name="field_name">product_subscription_id</xsl:element> 
	              </xsl:element>
	            </xsl:element>
	            <xsl:element name="CcmFifParameterValueCont">
	              <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
	              <xsl:element name="parameter_value_ref">
	                <xsl:element name="command_id">find_service_1</xsl:element> 
	                <xsl:element name="field_name">customer_number</xsl:element> 
	              </xsl:element>
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
	              <xsl:element name="parameter_name">START_DATE</xsl:element> 
	              <xsl:element name="parameter_value">
	                <xsl:value-of select="request-param[@name='startDate']"/>
	              </xsl:element>
	            </xsl:element>                 
	          </xsl:element>
	          <xsl:element name="additional_param_list_name">SELECTED_DESTINATIONS_LIST</xsl:element>            
	          <xsl:element name="additional_param_list">           
	            <xsl:for-each
	              select="request-param-list[@name='selectedDestinationsList']/request-param-list-item">
	              <xsl:element name="CcmFifParameterValueCont">
	                <xsl:element name="parameter_name">BEGIN_NUMBER</xsl:element> 
	                <xsl:element name="parameter_value">
	                  <xsl:value-of select="request-param[@name='beginNumber']"/>
	                </xsl:element>
	              </xsl:element>                 
	            </xsl:for-each>      
	          </xsl:element>          
	        </xsl:element>
	      </xsl:element>
      </xsl:if>
      
      <!-- Deactivate Selected destinations -->
      <xsl:element name="CcmFifDeactSelectedDestForPpsCmd">
        <xsl:element name="command_id">deact_sd_1</xsl:element>
        <xsl:element name="CcmFifDeactSelectedDestForPpsInCont">
          <xsl:element name="price_plan_subs_list_ref">
            <xsl:element name="command_id">find_pps_1</xsl:element>
            <xsl:element name="field_name">price_plan_subs_list</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='startDate']"/>
          </xsl:element>
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
            <xsl:value-of select="request-param[@name='startDate']"/>
          </xsl:element>
          <xsl:variable name="StartDate" select="request-param[@name='startDate']"/>
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
                    <xsl:value-of select="$StartDate"/>
                  </xsl:element>
                </xsl:element>
              </xsl:for-each>
            </xsl:element>
          </xsl:if>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_pps_1</xsl:element>
            <xsl:element name="field_name">price_plan_found</xsl:element>
          </xsl:element>           
        </xsl:element>
      </xsl:element>

      <!-- Create Contact-->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="command_id">create_contact_1</xsl:element>
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element> 
            <xsl:element name="field_name">customer_number</xsl:element> 
          </xsl:element>
          <xsl:element name="contact_type_rd">INFO</xsl:element>
          <xsl:element name="caller_name">SYSTEM</xsl:element>
          <xsl:element name="caller_phone_number">SYSTEM</xsl:element>
          <xsl:element name="author_name">
            <xsl:value-of select="request-param[@name='userName']"/>
          </xsl:element>
          <xsl:element name="short_description">Changing selected dest.</xsl:element>
          <xsl:element name="long_description_text">Changing selected destinations.</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_pps_1</xsl:element>
            <xsl:element name="field_name">price_plan_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>           
        </xsl:element>
      </xsl:element>

      <xsl:if test="request-param[@name='clientName'] != 'CODB'">
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
