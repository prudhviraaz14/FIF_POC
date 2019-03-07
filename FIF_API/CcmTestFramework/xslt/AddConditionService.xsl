<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for adding child services.
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
    
    <xsl:element name="Command_List">
      
      <xsl:variable name="Type">
        <!-- the empty text in each variable is a hack to have the variable existing
          even if the original is not defined in one of the FIF clients -->
        <xsl:text/>
        <xsl:value-of select="request-param[@name='type']"/>
      </xsl:variable> 
      <xsl:variable name="productSubscriptionId">
        <xsl:text/>
        <xsl:value-of select="request-param[@name='productSubscriptionId']"/>
      </xsl:variable> 
      <xsl:variable name="serviceSubscriptionId">
        <xsl:text/>
        <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
      </xsl:variable> 
      <xsl:variable name="requestListId">
        <xsl:text/>
        <xsl:value-of select="request-param[@name='requestListId']"/>
      </xsl:variable> 
      <xsl:variable name="SalesOrganisationNumberVF" select="request-param[@name='salesOrganisationNumberVF']"/> 
      
      <!-- Validate the parameter type -->
      <xsl:if test="$Type != ''
        and ($serviceSubscriptionId != ''
        or $productSubscriptionId != '')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">type_error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The parameter 'type' can be set only if the main access service can not be determined!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
               
      <!-- Find the main Service by Service Subscription Id-->
      <xsl:if test="$serviceSubscriptionId != '' or $productSubscriptionId != ''">
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:if test="($serviceSubscriptionId != '')">
              <xsl:element name="service_subscription_id">
              <xsl:value-of select="$serviceSubscriptionId"/>
            </xsl:element>
              </xsl:if>
            <xsl:if test="$productSubscriptionId != ''">
              <xsl:element name="product_subscription_id">
                <xsl:value-of select="$productSubscriptionId"/>
              </xsl:element>
              <xsl:element name="fetch_main_ss_from_ps_Ind">Y</xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Take value of serviceSubscriptionId from ccm external notification if serviceSubscriptionId not provided -->
      <xsl:if test="$serviceSubscriptionId = '' and $productSubscriptionId = ''">
       
        <xsl:if test="$Type != ''">
          <xsl:element name="CcmFifReadExternalNotificationCmd">
            <xsl:element name="command_id">read_external_notification_2</xsl:element>
            <xsl:element name="CcmFifReadExternalNotificationInCont">
              <xsl:element name="transaction_id">
                <xsl:value-of select="$requestListId"/>
              </xsl:element>
              <xsl:element name="parameter_name">
                <xsl:value-of select="concat($Type, '_SERVICE_SUBSCRIPTION_ID')"/>
              </xsl:element>                        
            </xsl:element>
          </xsl:element>
          
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
        </xsl:if>

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

      <!-- V0045 Kondition einmalig -->
      <xsl:if test="request-param[@name='oneTimeCondition'] != ''">
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_1</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V0045</xsl:element>
            <xsl:element name="sales_organisation_number">
                <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
            </xsl:element>  
            <xsl:element name="sales_organisation_number_vf">
              <xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
            </xsl:element>   
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:choose>
              <xsl:when test="$serviceSubscriptionId != '' or $productSubscriptionId != ''">
                <xsl:element name="desired_date">
                  <xsl:value-of select="$DesiredDate"/>
                </xsl:element>
                <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>                
              </xsl:when>
              <xsl:otherwise>
                <xsl:element name="desired_schedule_type">ASAP</xsl:element>
              </xsl:otherwise>
            </xsl:choose>           
             <xsl:element name="reason_rd">MODIFY_CONDITION</xsl:element>             
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
            <!-- Bemerkung -->
            <xsl:element name="service_characteristic_list">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0095</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='oneTimeCondition']"/>
                </xsl:element>
              </xsl:element>                
                <!--   V0160 Kondition einmalig ID -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">V0160</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">
                    <xsl:value-of select="request-param[@name='oneTimeConditionId']"/>
                  </xsl:element>
                </xsl:element>         
            </xsl:element>
            <xsl:element name="detailed_reason_ref">
              <xsl:element name="command_id">read_external_notification_3</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>            
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- V0046 Kondition monatlich  -->
      <xsl:if test="request-param[@name='monthlyCondition'] != ''">
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_2</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V0046</xsl:element>
            <xsl:element name="sales_organisation_number">
                <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
            </xsl:element>  
            <xsl:element name="sales_organisation_number_vf">
              <xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
            </xsl:element>   
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:choose>
              <xsl:when test="$serviceSubscriptionId != '' or $productSubscriptionId != ''">
                <xsl:element name="desired_date">
                  <xsl:value-of select="$DesiredDate"/>
                </xsl:element>
                <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>                
              </xsl:when>
              <xsl:otherwise>
                <xsl:element name="desired_schedule_type">ASAP</xsl:element>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:element name="reason_rd">MODIFY_CONDITION</xsl:element>
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
            <!-- Bemerkung -->
            <xsl:element name="service_characteristic_list">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0096</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='monthlyCondition']"/>
                </xsl:element>
              </xsl:element>                
                <!--   V0161 Kondition einmalig ID -->
                <xsl:element name="CcmFifConfiguredValueCont">
                  <xsl:element name="service_char_code">V0161</xsl:element>
                  <xsl:element name="data_type">STRING</xsl:element>
                  <xsl:element name="configured_value">
                    <xsl:value-of select="request-param[@name='monthlyConditionId']"/>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            <xsl:element name="detailed_reason_ref">
              <xsl:element name="command_id">read_external_notification_3</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>            
            </xsl:element>
          </xsl:element>
      </xsl:if>
 
      <!-- V004A Special Bonus  -->
      <xsl:if test="request-param[@name='specialBonus'] != ''">
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_3</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V004A</xsl:element>
            <xsl:element name="sales_organisation_number">
              <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
            </xsl:element>  
            <xsl:element name="sales_organisation_number_vf">
              <xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
            </xsl:element>   
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:choose>
              <xsl:when test="$serviceSubscriptionId != '' or $productSubscriptionId != ''">
                <xsl:element name="desired_date">
                  <xsl:value-of select="$DesiredDate"/>
                </xsl:element>
                <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>                
              </xsl:when>
              <xsl:otherwise>
                <xsl:element name="desired_schedule_type">ASAP</xsl:element>
              </xsl:otherwise>
            </xsl:choose>
             <xsl:element name="reason_rd">MODIFY_CONDITION</xsl:element>
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
            <xsl:element name="service_characteristic_list">
              <!-- Sonderprämie -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0113</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='specialBonus']"/>
                </xsl:element>
              </xsl:element>   
              <!-- Sonderprämie Gutscheincode -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0210</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='specialBonusCode']"/>
                </xsl:element>
              </xsl:element>   
              <!--  Sonderprämie ID -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0209</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='specialBonusCodeId']"/>
                </xsl:element>
              </xsl:element>           
            </xsl:element>
            <xsl:element name="detailed_reason_ref">
              <xsl:element name="command_id">read_external_notification_3</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>            
          </xsl:element>
        </xsl:element>
      </xsl:if>
       
      <!-- find an open customer order for the main service,
        search for a subscribe STP, if no input was provided, e.g. during tech change, NGN creation
        search for a reconfigure STP, if a service was provided, e.g. during BBW -->
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
          <xsl:element name="usage_mode">
            <xsl:choose>
              <xsl:when test="$serviceSubscriptionId = '' and $productSubscriptionId = ''">
                <xsl:text>1</xsl:text>                  
              </xsl:when>
              <xsl:otherwise>2</xsl:otherwise>
            </xsl:choose>
          </xsl:element>
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
            <xsl:if test="request-param[@name='oneTimeCondition'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='monthlyCondition'] != ''">            
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_2</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element> 
            </xsl:if>  
            <xsl:if test="request-param[@name='specialBonus'] != ''">            
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_3</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element> 
            </xsl:if>                                  
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
      
      <!-- Create Customer Order for condition Services -->    
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
          <xsl:element name="service_ticket_pos_list">
            <xsl:if test="request-param[@name='oneTimeCondition'] != ''">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='monthlyCondition'] != ''">            
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_2</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element> 
            </xsl:if> 
            <xsl:if test="request-param[@name='specialBonus'] != ''">            
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_3</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element> 
            </xsl:if>                       
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
      
      <!--Release customer order for hardware service-->
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
          <xsl:element name="contact_type_rd">ADD_COND_SERV</xsl:element>
          <xsl:element name="short_description">
            <xsl:text>Dienst hinzugefügt über </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
          </xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:if test="request-param[@name='oneTimeCondition'] != ''">
              <xsl:text>&#xA;Service Code: V0045</xsl:text>
              <xsl:text>&#xA;Wunschdatum: </xsl:text>
              <xsl:value-of select="$DesiredDate"/>
            </xsl:if>
            <xsl:if test="request-param[@name='monthlyCondition'] != ''">
              <xsl:text>&#xA;Service Code: V0046</xsl:text>
              <xsl:text>&#xA;Wunschdatum: </xsl:text>
              <xsl:value-of select="$DesiredDate"/>
            </xsl:if>
            <xsl:if test="request-param[@name='specialBonus'] != ''">
              <xsl:text>&#xA;Service Code: V004A</xsl:text>
              <xsl:text>&#xA;Wunschdatum: </xsl:text>
              <xsl:value-of select="$DesiredDate"/>
            </xsl:if>                            
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
                  
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>

