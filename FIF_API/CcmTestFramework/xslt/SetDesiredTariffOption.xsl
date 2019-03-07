<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated relocation FIF request

  @author wlazlow
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
        <!-- the empty text in each variable is a hack to have the variable existing
          even if the original is not defined in one of the FIF clients -->
        <xsl:text/>
        <xsl:value-of select="request-param[@name='type']"/>
      </xsl:variable> 
      <xsl:variable name="accessNumber">
        <xsl:text/>
        <xsl:value-of select="request-param[@name='accessNumber']"/>
      </xsl:variable> 
      <xsl:variable name="productSubscriptionId">
        <xsl:text/>
        <xsl:value-of select="request-param[@name='productSubscriptionId']"/>
      </xsl:variable> 
      <xsl:variable name="serviceSubscriptionId">
        <xsl:text/>
        <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
      </xsl:variable> 

      <xsl:if test="($serviceSubscriptionId = '')
        and ($accessNumber = '')
        and ($productSubscriptionId = '')
        and ($Type = '')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">type_error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The paramter type has to be set if serviceSubscriptionId and accessNumber are empty!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

        <!-- Get Detailed Reason Rd -->     
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
        test="(count(request-param-list[@name='oldTariffOptionServiceCodeList']/request-param-list-item) != 0) or
        (count(request-param-list[@name='newTariffOptionServiceCodeList']/request-param-list-item) != 0)">
        <!-- Generate Base Command Id for add and terminate service -->
        <xsl:variable name="AddServCommandId">add_ss_</xsl:variable>
        <xsl:variable name="AddContribCommandId">add_ci_</xsl:variable>
        <xsl:variable name="DesiredDate" select="request-param[@name='desiredDate']"/>
        <xsl:variable name="nextDay" select="dateutils:createFIFDateOffset($DesiredDate, 'DATE', '1')"/>
       

        <!-- Find Service Subscription by access number, STP Id or Service Subscription Id-->
        <xsl:if test="$accessNumber != '' 
          or $serviceSubscriptionId != ''
          or $productSubscriptionId != ''">
          <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">                        
               <xsl:if test="$accessNumber != '' 
                 and $productSubscriptionId = ''
                 and $serviceSubscriptionId = ''">
                <xsl:element name="access_number">
                  <xsl:value-of select="$accessNumber"/>
                </xsl:element>
                <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
              </xsl:if>
              <xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">              
                <xsl:element name="service_subscription_id">
                  <xsl:value-of select="$serviceSubscriptionId"/>
                </xsl:element>
              </xsl:if>
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
              <xsl:if test="$productSubscriptionId != ''">
                <xsl:element name="product_subscription_id">
                  <xsl:value-of select="$productSubscriptionId"/>
                </xsl:element>
                <xsl:element name="fetch_main_ss_from_ps_Ind">Y</xsl:element>
              </xsl:if>
            </xsl:element>
          </xsl:element>
        </xsl:if>

        <!-- Take value of serviceSubscriptionId from ccm external notification if accessNumber,serviceTicketPositionId,serviceSubscriptionId not provided -->
        <xsl:if test="$accessNumber = ''  
                      and $serviceSubscriptionId = ''
                      and $productSubscriptionId = ''">      
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
          </xsl:if> 
          <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
              <xsl:element name="service_subscription_id_ref">
                <xsl:element name="command_id">read_external_notification_2</xsl:element>
                <xsl:element name="field_name">parameter_value</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>

        <!-- Get PC data to retrieve the current product -->
        <xsl:element name="CcmFifGetProductCommitmentDataCmd">
          <xsl:element name="command_id">get_pc_data</xsl:element>
          <xsl:element name="CcmFifGetProductCommitmentDataInCont">
            <xsl:element name="product_commitment_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_commitment_number</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>        
        <xsl:element name="CcmFifMapStringCmd">
          <xsl:element name="command_id">map_mobile_tariff_change</xsl:element>
          <xsl:element name="CcmFifMapStringInCont">
            <xsl:element name="input_string_type">ProductCode</xsl:element>
            <xsl:element name="input_string_ref">
              <xsl:element name="command_id">get_pc_data</xsl:element>
              <xsl:element name="field_name">product_code</xsl:element>
            </xsl:element>
            <xsl:element name="output_string_type">[Y,N]</xsl:element>
            <xsl:element name="string_mapping_list">
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">V8000</xsl:element>
                <xsl:element name="output_string">Y</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="no_mapping_error">N</xsl:element>
          </xsl:element>
        </xsl:element>        

        <xsl:variable name="SalesOrganisationNumber" select="request-param[@name='salesOrganisationNumber']"/> 
        <xsl:variable name="SalesOrganisationNumberVF" select="request-param[@name='salesOrganisationNumberVF']"/> 
        <!-- Set the new desired tariff options -->
        <xsl:for-each select="request-param-list[@name='newTariffOptionServiceCodeList']/request-param-list-item">
          <xsl:variable name="ServiceCode" select="request-param[@name='serviceCode']"/>
          <xsl:variable name="SubOrderId" select="request-param[@name='subOrderId']"/>          
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
              <xsl:element name="reason_rd">MODIFY_TARIF_OPT</xsl:element>
              <xsl:element name="account_number_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">account_number</xsl:element>
              </xsl:element>
              <xsl:element name="use_current_pc_version_ref">
                <xsl:element name="command_id">map_mobile_tariff_change</xsl:element>
                <xsl:element name="field_name">output_string</xsl:element>
              </xsl:element>
              <xsl:element name="service_characteristic_list"/> 
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

        <!-- Terminate Old TariffOption Services -->
        <xsl:if test="count(request-param-list[@name='oldTariffOptionServiceCodeList']/request-param-list-item) != 0">
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
              <xsl:element name="reason_rd">MODIFY_TARIF_OPT</xsl:element>
              <xsl:element name="service_code_list">
                <xsl:for-each select="request-param-list[@name='oldTariffOptionServiceCodeList']/request-param-list-item">
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
        <xsl:for-each select="request-param-list[@name='oldTariffOptionServiceCodeList']/request-param-list-item">
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
            <xsl:element name="allow_children">Y</xsl:element>
            <xsl:element name="usage_mode">1</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <xsl:if test="$accessNumber = '' 
          and $serviceSubscriptionId = ''
          and $productSubscriptionId = ''">
          <!-- Add STPs to customer order if exists -->
          <xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
            <xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
              <xsl:element name="customer_order_id_ref">
                <xsl:element name="command_id">find_customer_order_1</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_ticket_pos_list">
                <xsl:for-each select="request-param-list[@name='newTariffOptionServiceCodeList']/request-param-list-item">
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
              <xsl:element name="cust_order_description">Tarifoption-Änderung</xsl:element>
              <xsl:element name="customer_tracking_id">
                <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
              </xsl:element>
              <xsl:element name="ignore_empty_list_ind">Y</xsl:element> 
              <xsl:element name="service_ticket_pos_list">
                <xsl:for-each select="request-param-list[@name='newTariffOptionServiceCodeList']/request-param-list-item">
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
               <xsl:element name="ignore_empty_list_ind">Y</xsl:element> 
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">find_customer_order_1</xsl:element>
                <xsl:element name="field_name">customer_order_found</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">N</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>

        <xsl:if test="$accessNumber != '' 
          or $serviceSubscriptionId != ''
          or $productSubscriptionId != ''">
          
          <!-- find the open customer order for the main access service -->
          <xsl:element name="CcmFifFindCustomerOrderCmd">
            <xsl:element name="command_id">find_mobile_customer_order</xsl:element>
            <xsl:element name="CcmFifFindCustomerOrderInCont">
              <xsl:element name="service_subscription_id_ref">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
              <xsl:element name="state_list">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">ASSIGNED</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="allow_children">N</xsl:element>
              <xsl:element name="usage_mode">2</xsl:element>
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">map_mobile_tariff_change</xsl:element>
                <xsl:element name="field_name">output_string</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">Y</xsl:element>
            </xsl:element>
          </xsl:element>
          
          <!-- Add STP to customer order -->
          <xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
            <xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
              <xsl:element name="customer_order_id_ref">
                <xsl:element name="command_id">find_mobile_customer_order</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
              <xsl:element name="service_ticket_pos_list">
                <xsl:for-each select="request-param-list[@name='newTariffOptionServiceCodeList']/request-param-list-item">
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
                <xsl:element name="command_id">map_mobile_tariff_change</xsl:element>
                <xsl:element name="field_name">output_string_found</xsl:element>
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
              <xsl:element name="parent_customer_order_ref">
                <xsl:element name="command_id">find_customer_order_1</xsl:element>
                <xsl:element name="field_name">customer_order_id</xsl:element>
              </xsl:element>
              <xsl:element name="cust_order_description">Tarifoption-Änderung</xsl:element>
              <xsl:element name="customer_tracking_id">
                <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
              </xsl:element>
              <xsl:element name="ignore_empty_list_ind">Y</xsl:element> 
              <xsl:element name="service_ticket_pos_list">
                <xsl:for-each select="request-param-list[@name='newTariffOptionServiceCodeList']/request-param-list-item">
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
                <xsl:element name="command_id">map_mobile_tariff_change</xsl:element>
                <xsl:element name="field_name">output_string_found</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">N</xsl:element>              
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
               <xsl:element name="ignore_empty_list_ind">Y</xsl:element> 
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
      </xsl:if>
      <!-- Create Contact for the Service Termination -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">MODIFY_TARIF_OPT</xsl:element>
          <xsl:element name="short_description">Änderung Tarifoptionen</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;User Name: </xsl:text>
            <xsl:value-of select="request-param[@name='userName']"/>
            <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
            <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
            <xsl:text>&#xA;Added tariff option services : </xsl:text>
            <xsl:for-each select="request-param-list[@name='newTariffOptionServiceCodeList']/request-param-list-item">
              <xsl:value-of select="request-param[@name='serviceCode']"/>
              <xsl:text> </xsl:text>
            </xsl:for-each>
            <xsl:text>&#xA;Removed tariff option services : </xsl:text>
            <xsl:for-each select="request-param-list[@name='oldTariffOptionServiceCodeList']/request-param-list-item">
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
                <xsl:element name="parameter_value">DesiredTariffOption</xsl:element>
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
                  <xsl:text>Änderung Wunschtarifoptionen über </xsl:text>
                  <xsl:value-of select="request-param[@name='clientName']"/>
                  <xsl:if test="request-param[@name='userName'] != ''">
                    <xsl:text> von </xsl:text>
                    <xsl:value-of select="request-param[@name='userName']"/>
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
                    <xsl:text>)</xsl:text>
                  </xsl:if>
                  <xsl:text>. Gekündigte Tarifoptionendienste: </xsl:text>
                  <xsl:variable name="oldTariffOptionCount" select="(count(request-param-list[@name='oldTariffOptionServiceCodeList']/request-param-list-item))"/>
                  <xsl:for-each select="request-param-list[@name='oldTariffOptionServiceCodeList']/request-param-list-item">
                    <xsl:value-of select="request-param[@name='serviceCode']"/>
                    <xsl:if test="position() != $oldTariffOptionCount">
                      <xsl:text>, </xsl:text>
                    </xsl:if>
                  </xsl:for-each>
                  <xsl:text>. Neue Tarifoptionendienste: </xsl:text>
                  <xsl:variable name="newTariffOptionCount" select="(count(request-param-list[@name='newTariffOptionServiceCodeList']/request-param-list-item))"/>
                  <xsl:for-each select="request-param-list[@name='newTariffOptionServiceCodeList']/request-param-list-item">
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
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
