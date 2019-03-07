<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for adding the office complete child service.
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
      <xsl:variable name="serviceSubscriptionId">
        <xsl:text/>
        <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
      </xsl:variable> 
      <xsl:variable name="requestListId">
        <xsl:text/>
        <xsl:value-of select="request-param[@name='requestListId']"/>
      </xsl:variable> 
               
      <xsl:variable name="ServiceCode">  
        <xsl:choose>
          <xsl:when test="request-param[@name='tariffModel'] = 'perSeat'">
            <xsl:choose>
              <xsl:when test="request-param[@name='numberOfSeats'] = '2'">V0452</xsl:when>
              <xsl:when test="request-param[@name='numberOfSeats'] = '3'">V0453</xsl:when>
              <xsl:when test="request-param[@name='numberOfSeats'] = '4'">V0454</xsl:when>
              <xsl:when test="request-param[@name='numberOfSeats'] = '5'">V0455</xsl:when>
              <xsl:when test="request-param[@name='numberOfSeats'] = '6'">V0456</xsl:when>
              <xsl:when test="request-param[@name='numberOfSeats'] = '7'">V0457</xsl:when>
              <xsl:otherwise>V0458</xsl:otherwise>
            </xsl:choose>            
          </xsl:when>
          <xsl:otherwise>V0451</xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable> 
      
      <!-- Validate the parameter type -->
      <xsl:if test=" $Type != 'NGNDSL'
        and $Type != 'BitDSL'
        and $Type != 'ISDN'                   
        and $serviceSubscriptionId = ''">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">type_error_2</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The parameter type has to  be set to ISDN, NGNDSL or BitDSL.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
 
      <!-- Validate the parameter tariffModel -->
      <xsl:if test=" request-param[@name='tariffModel'] != 'perSeat'
        and request-param[@name='tariffModel'] != 'aLaCarte'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">type_error_3</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Allowed values for the parameter 'tariffModel' are: perSeat and aLaCarte.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>   
      
      <xsl:if test=" request-param[@name='tariffModel'] = 'perSeat'
        and request-param[@name='numberOfSeats'] = ''">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">type_error_4</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">numberOfSeats can not be empty if the parameter 'tariffModel' is set to 'perSeat'!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>      
       
      <!-- Find the main Service  by Service Subscription Id-->
      <xsl:if test="$serviceSubscriptionId != ''">
        <xsl:element name="CcmFifFindServiceSubsCmd">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="CcmFifFindServiceSubsInCont">
            <xsl:element name="service_subscription_id">
            <xsl:value-of select="$serviceSubscriptionId"/>
          </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Take value of serviceSubscriptionId from ccm external notification if serviceSubscriptionId not provided -->
      <xsl:if test="$serviceSubscriptionId = ''">
       
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

      <!-- Add Service for seats -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">
            <xsl:value-of select="$ServiceCode"/>
          </xsl:element>
          <xsl:element name="sales_organisation_number">
              <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
          </xsl:element>  
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:choose>
            <xsl:when test="$serviceSubscriptionId != ''">
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>                
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            </xsl:otherwise>
          </xsl:choose>           
          <xsl:element name="reason_rd">OFFICECOMPLETE</xsl:element>             
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <!-- Bemerkung -->
          <xsl:element name="service_characteristic_list"/>          
        </xsl:element>
      </xsl:element>
      
      <!-- Add Service V0450 -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_2</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V0450</xsl:element>
          <xsl:element name="sales_organisation_number">
            <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
          </xsl:element>  
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:choose>
            <xsl:when test="$serviceSubscriptionId != ''">
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>                
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            </xsl:otherwise>
          </xsl:choose>           
          <xsl:element name="reason_rd">OFFICECOMPLETE</xsl:element>             
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <!-- Bemerkung -->
          <xsl:element name="service_characteristic_list"/>          
        </xsl:element>
      </xsl:element>
     
      <!-- find an open customer order for the main service  -->
      <xsl:if test="request-param[@name='serviceSubscriptionId'] = ''">
        <!-- find an open customer order for the main service -->
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
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element> 
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_2</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>                                
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_customer_order_1</xsl:element>
              <xsl:element name="field_name">customer_order_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>   
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
        <!-- Create Customer Order -->    
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
            <xsl:element name="lan_path_file_string">
              <xsl:value-of select="request-param[@name='lanPathFileString']"/>
            </xsl:element>
            <xsl:element name="sales_rep_dept">
              <xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
            </xsl:element>
            <xsl:element name="provider_tracking_no">
              <xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
            </xsl:element>
            <xsl:element name="super_customer_tracking_id">
              <xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
            </xsl:element>
            <xsl:element name="scan_date">
              <xsl:value-of select="request-param[@name='scanDate']"/>
            </xsl:element>
            <xsl:element name="order_entry_date">
              <xsl:value-of select="request-param[@name='entryDate']"/>
            </xsl:element>
            <xsl:element name="service_ticket_pos_list">
                <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>  
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_2</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>                                
            </xsl:element>         
          </xsl:element>
        </xsl:element>
        <!--Release customer order-->
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
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Create Contact -->     
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">OFFICECOMPLETE</xsl:element>
          <xsl:element name="short_description">Office Complete hinzugefügt</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>Office Complete hinzugefügt über </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
            <xsl:text>&#xA;Tarifmodell: </xsl:text>
            <xsl:value-of select="request-param[@name='tariffModel']"/>
            <xsl:text>&#xA;TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;Wunschdatum: </xsl:text>
            <xsl:value-of select="$DesiredDate"/>    
            <xsl:text>&#xA;User Name: </xsl:text>
            <xsl:value-of select="request-param[@name='$userName']"/>  
          </xsl:element>
        </xsl:element>
      </xsl:element>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>

