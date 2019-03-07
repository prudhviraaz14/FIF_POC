<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated relocation FIF request

  @author banania
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

      <xsl:variable name="Type">
        <xsl:choose>
          <xsl:when test="request-param[@name='accessNumber'] != ''"/>				
          <xsl:when test="request-param[@name='serviceSubscriptionId'] != ''"/>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='type']"/>
          </xsl:otherwise>				
        </xsl:choose>
      </xsl:variable> 
      
      <xsl:if test="(request-param[@name='serviceSubscriptionId'] = '')
        and (request-param[@name='accessNumber'] = '')
        and ($Type = '')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">type_error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The paramter type has to be set if serviceSubscriptionId and accessNumber are empty!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
       <!--Get Detailed Reason Rd -->     
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_external_notification_3</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">
              <xsl:value-of select="concat($Type, '_DETAILED_REASON_RD')"/>
            </xsl:element>
            <xsl:element name="ignore_empty_result">Y</xsl:element>
          </xsl:element>
        </xsl:element>
  
      
      <xsl:if
        test="(count(request-param-list[@name='oldCountriesServiceCodeList']/request-param-list-item) != 0) or
        (count(request-param-list[@name='newCountriesServiceCodeList']/request-param-list-item) != 0)">
        <!-- Generate Base Command Id for add and terminate service -->
        <xsl:variable name="AddServCommandId">add_ss_</xsl:variable>
        <xsl:variable name="AddContribCommandId">add_ci_</xsl:variable>
        <xsl:variable name="DesiredDate" select="request-param[@name='desiredDate']"/>
        <xsl:variable name="nextDay" select="dateutils:createFIFDateOffset($DesiredDate, 'DATE', '1')"/>
       
        <!-- Find Service Subscription by access number, STP Id or Service Subscription Id-->
        <xsl:if test="$Type = ''">
          <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
              <xsl:if test="((request-param[@name='accessNumber'] != '' ) and (request-param[@name='serviceSubscriptionId'] = ''))">
                <xsl:element name="access_number">
                  <xsl:value-of select="request-param[@name='accessNumber']"/>
                </xsl:element>
                <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
                <xsl:element name="effective_date">
                  <xsl:value-of select="$DesiredDate"/>
                </xsl:element>
                <xsl:element name="customer_number">
                  <xsl:value-of select="request-param[@name='customerNumber']"/>
                </xsl:element>
                <xsl:element name="contract_number">
                  <xsl:value-of select="request-param[@name='contractNumber']"/>
                </xsl:element>
                <xsl:element name="technical_service_code">VOICE</xsl:element>
              </xsl:if>
              <xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
                <xsl:element name="service_subscription_id">
                  <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
                </xsl:element>
              </xsl:if>
            </xsl:element>
          </xsl:element>
        </xsl:if>

        <!-- Take value of serviceSubscriptionId from ccm external notification if accessNumber,serviceTicketPositionId,serviceSubscriptionId not provided -->
        <xsl:if test="$Type != ''">                          
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
        
         <xsl:variable name="SalesOrganisationNumber" select="request-param[@name='salesOrganisationNumber']"/> 
        <xsl:variable name="SalesOrganisationNumberVF" select="request-param[@name='salesOrganisationNumberVF']"/> 
        <!-- Set the new desired countries -->
        <xsl:for-each select="request-param-list[@name='newCountriesServiceCodeList']/request-param-list-item">
          <xsl:variable name="ServiceCode" select="request-param[@name='serviceCode']"/>
          <xsl:variable name="SubOrderId" select="request-param[@name='subOrderId']"/>
          <!-- Add new country discount service -->
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
              <xsl:element name="sales_organisation_number">
                <xsl:value-of select="$SalesOrganisationNumber"/>
              </xsl:element>    
              <xsl:element name="sales_organisation_number_vf">
                <xsl:value-of select="$SalesOrganisationNumberVF"/>
              </xsl:element>    
              <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
              <xsl:element name="reason_rd">MODIFY_DES_CNTRY</xsl:element>
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
              <xsl:element name="service_characteristic_list"> </xsl:element>
              <xsl:element name="sub_order_id">
                <xsl:value-of select="$SubOrderId"/>
              </xsl:element>
              <xsl:element name="detailed_reason_ref">
                  <xsl:element name="command_id">read_external_notification_3</xsl:element>
                  <xsl:element name="field_name">parameter_value</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          
          <!-- Add contributing items -->
          <xsl:element name="CcmFifAddModifyContributingItemCmd">
            <xsl:element name="command_id">
              <xsl:value-of select="concat($AddContribCommandId, $ServiceCode)"/>
            </xsl:element>
            <xsl:element name="CcmFifAddModifyContributingItemInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">
                <xsl:value-of select="$ServiceCode"/>
              </xsl:element>
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
              <xsl:element name="no_price_plan_error">N</xsl:element> 
            </xsl:element>
          </xsl:element>

          <!--  Get Orderform data  --> 
          <xsl:element name="CcmFifGetOrderFormDataCmd">
            <xsl:element name="command_id">get_order_form_data_1</xsl:element>
            <xsl:element name="CcmFifGetOrderFormDataInCont">
              <xsl:element name="contract_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">contract_number</xsl:element>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">
                  <xsl:value-of select="concat($AddContribCommandId, $ServiceCode)"/>
                </xsl:element>
                <xsl:element name="field_name">contributing_item_added</xsl:element>
              </xsl:element>              
              <xsl:element name="target_state">APPROVED</xsl:element> 
              <xsl:element name="required_process_ind">N</xsl:element>               
            </xsl:element>
          </xsl:element>

          <xsl:element name="CcmFifCreateFifRequestCmd">
            <xsl:element name="command_id">create_fif_request_1</xsl:element> 
            <xsl:element name="CcmFifCreateFifRequestInCont">
              <xsl:element name="action_name">createContributingItem</xsl:element> 
              <xsl:element name="due_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element> 
              <xsl:element name="dependent_transaction_id_ref">
                <xsl:element name="command_id">get_order_form_data_1</xsl:element>
                <xsl:element name="field_name">pending_fif_transaction_id</xsl:element>
              </xsl:element>
              <xsl:element name="priority">5</xsl:element>
              <xsl:element name="bypass_command_ref">
                <xsl:element name="command_id">
                  <xsl:value-of select="concat($AddContribCommandId, $ServiceCode)"/>
                </xsl:element>
                <xsl:element name="field_name">contributing_item_added</xsl:element>
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
                  <xsl:element name="parameter_name">SERVICE_SUBSCRIPTION_ID</xsl:element> 
                  <xsl:element name="parameter_value_ref">
                    <xsl:element name="command_id">find_service_1</xsl:element> 
                    <xsl:element name="field_name">service_subscription_id</xsl:element> 
                  </xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">SERVICE_CODE</xsl:element> 
                  <xsl:element name="parameter_value">
                    <xsl:value-of select="$ServiceCode"/>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">CONTRIBUTING_TYPE</xsl:element> 
                  <xsl:element name="parameter_value">SERVICE_SUBSC</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">EFFECTIVE_DATE</xsl:element> 
                  <xsl:element name="parameter_value">
                    <xsl:value-of select="$DesiredDate"/>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifParameterValueCont">
                  <xsl:element name="parameter_name">START_DATE</xsl:element> 
                  <xsl:element name="parameter_value">
                    <xsl:value-of select="$DesiredDate"/>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>

        <!-- Terminate Old Country Discount Services -->
        <xsl:if test="count(request-param-list[@name='oldCountriesServiceCodeList']/request-param-list-item) != 0">
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
              <xsl:element name="reason_rd">MODIFY_DES_CNTRY</xsl:element>
              <xsl:element name="service_code_list">
                <xsl:for-each select="request-param-list[@name='oldCountriesServiceCodeList']/request-param-list-item">
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

        <!-- deactivate the old contributing items -->
        <xsl:for-each select="request-param-list[@name='oldCountriesServiceCodeList']/request-param-list-item">
          <xsl:element name="CcmFifAddModifyContributingItemCmd">
            <xsl:element name="CcmFifAddModifyContributingItemInCont">
              <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_code">
                <xsl:value-of select="request-param[@name='serviceCode']"/>
              </xsl:element>
              <xsl:element name="contributing_item_list">
                <xsl:element name="CcmFifContributingItem">
                  <xsl:element name="supported_object_type_rd">SERVICE_SUBSC</xsl:element>
                  <xsl:element name="stop_date">
                    <xsl:value-of select="$nextDay"/>
                  </xsl:element>
                  <xsl:element name="service_subscription_ref">
                    <xsl:element name="command_id">find_service_1</xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>

        <xsl:if test="$Type != ''">

          <!-- find an open customer order for the main VoIP service -->
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
                <xsl:for-each select="request-param-list[@name='newCountriesServiceCodeList']/request-param-list-item">
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
              <xsl:element name="processing_status">
                <xsl:value-of select="request-param[@name='processingStatus']"/>
              </xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_customer_order_1</xsl:element>
                <xsl:element name="field_name">customer_order_found</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">Y</xsl:element>
            </xsl:element>
          </xsl:element>

          <!-- Create Customer Order for add and terminate discount Services -->
          <xsl:element name="CcmFifCreateCustOrderCmd">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="CcmFifCreateCustOrderInCont">
              <xsl:element name="customer_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">customer_number</xsl:element>
              </xsl:element>
              <xsl:element name="cust_order_description">Wunschländer-Änderung</xsl:element>
              <xsl:element name="customer_tracking_id">
                <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
              </xsl:element>
              <xsl:element name="service_ticket_pos_list">
                <xsl:for-each select="request-param-list[@name='newCountriesServiceCodeList']/request-param-list-item">
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
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_customer_order_1</xsl:element>
                <xsl:element name="field_name">customer_order_found</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">N</xsl:element>
              <xsl:element name="processing_status">
                <xsl:value-of select="request-param[@name='processingStatus']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>

          <!-- Release Customer Order -->
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
        </xsl:if>


        <xsl:if test="(request-param[@name='accessNumber'] != '') 
          or (request-param[@name='serviceSubscriptionId'] != '')">
          
          <!-- find an open customer order for the main access service -->
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
              <xsl:element name="allow_children">N</xsl:element>
              <xsl:element name="usage_mode">1</xsl:element>
            </xsl:element>
          </xsl:element>

          <!-- Create Customer Order for add and terminate discount Services -->
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
              <xsl:element name="cust_order_description">Wunschländer-Änderung</xsl:element>
              <xsl:element name="customer_tracking_id">
                <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
              </xsl:element>
              <xsl:element name="service_ticket_pos_list">
                <xsl:for-each select="request-param-list[@name='newCountriesServiceCodeList']/request-param-list-item">
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
              <xsl:element name="processing_status">
                <xsl:value-of select="request-param[@name='processingStatus']"/>
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
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_customer_order_1</xsl:element>
                <xsl:element name="field_name">customer_order_found</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">N</xsl:element>
            </xsl:element>
          </xsl:element>

          <!-- Release dependent Customer Order for add and terminate discount Services -->
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
              <xsl:element name="required_process_ind">Y</xsl:element>
              <xsl:element name="parent_customer_order_id_ref">
                <xsl:element name="command_id">find_customer_order_1</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>
      </xsl:if>
      <!-- Create Contact for the Service Termination -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">MODIFY_DES_CNTRY</xsl:element>
          <xsl:element name="short_description">Änderung Wunschländer</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;User Name: </xsl:text>
            <xsl:value-of select="request-param[@name='userName']"/>
            <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
            <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
            <xsl:text>&#xA;Added country services : </xsl:text>
            <xsl:for-each select="request-param-list[@name='newCountriesServiceCodeList']/request-param-list-item">
              <xsl:value-of select="request-param[@name='serviceCode']"/>
              <xsl:text> </xsl:text>
            </xsl:for-each>
            <xsl:text>&#xA;Removed country services : </xsl:text>
            <xsl:for-each select="request-param-list[@name='oldCountriesServiceCodeList']/request-param-list-item">
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
                <xsl:element name="parameter_value">DesiredCountries</xsl:element>
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
                  <xsl:text>Änderung Wunschländer über </xsl:text>
                  <xsl:value-of select="request-param[@name='clientName']"/>
                  <xsl:if test="request-param[@name='userName'] != ''">
                    <xsl:text> von </xsl:text>
                    <xsl:value-of select="request-param[@name='userName']"/>
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
                    <xsl:text>)</xsl:text>
                  </xsl:if>
                  <xsl:text>. Gekündigte Länderdienste: </xsl:text>
                  <xsl:variable name="oldCountryCount" select="(count(request-param-list[@name='oldCountriesServiceCodeList']/request-param-list-item))"/>
                  <xsl:for-each select="request-param-list[@name='oldCountriesServiceCodeList']/request-param-list-item">
                    <xsl:value-of select="request-param[@name='serviceCode']"/>
                    <xsl:if test="position() != $oldCountryCount">
                      <xsl:text>, </xsl:text>
                    </xsl:if>
                  </xsl:for-each>
                  <xsl:text>. Neue Länderdienste: </xsl:text>
                  <xsl:variable name="newCountryCount" select="(count(request-param-list[@name='newCountriesServiceCodeList']/request-param-list-item))"/>
                  <xsl:for-each select="request-param-list[@name='newCountriesServiceCodeList']/request-param-list-item">
                    <xsl:value-of select="request-param[@name='serviceCode']"/>
                    <xsl:if test="position() != $newCountryCount">
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
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
