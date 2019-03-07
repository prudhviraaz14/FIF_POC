<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for adding the office complete service.
  @author schwarje
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

    <xsl:variable name="terminationDate" select="dateutils:createFIFDateOffset(request-param[@name='desiredDate'], 'DATE', '-1')"/>
    
    <xsl:element name="Command_List">
      
      <xsl:variable name="serviceCode">  
        <xsl:choose>
          <xsl:when test="request-param[@name='numberOfSeats'] = '2'">V0452</xsl:when>
          <xsl:when test="request-param[@name='numberOfSeats'] = '3'">V0453</xsl:when>
          <xsl:when test="request-param[@name='numberOfSeats'] = '4'">V0454</xsl:when>
          <xsl:when test="request-param[@name='numberOfSeats'] = '5'">V0455</xsl:when>
          <xsl:when test="request-param[@name='numberOfSeats'] = '6'">V0456</xsl:when>
          <xsl:when test="request-param[@name='numberOfSeats'] = '7'">V0457</xsl:when>
          <xsl:otherwise>V0458</xsl:otherwise>
        </xsl:choose>            
      </xsl:variable> 
      
      <!-- Find the main Service  by Service Subscription Id-->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Find the DSL service to check, if there is a open customer order for ISDN-->
      <xsl:element name="CcmFifFindExclusiveChildServSubsCmd">
        <xsl:element name="command_id">find_seat_service</xsl:element>
        <xsl:element name="CcmFifFindExclusiveChildServSubsInCont">
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0452</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0453</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0454</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0455</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0456</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0457</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0458</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- terminate the old one -->
      <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
        <xsl:element name="command_id">term_service</xsl:element>
        <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="no_child_error_ind">Y</xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$terminationDate"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="reason_rd">OFFICECOMPLETE</xsl:element>
          <xsl:element name="service_code_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0452</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0453</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0454</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0455</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0456</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0457</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0458</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Find the main Service by Service Subscription Id-->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">get_seat_service_info</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">find_seat_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>            
          </xsl:element>
        </xsl:element>
      </xsl:element>      
                  
      <!-- Add Service -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">
            <xsl:value-of select="$serviceCode"/>
          </xsl:element>
          <xsl:element name="sales_organisation_number">
              <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
          </xsl:element>  
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>                
          <xsl:element name="reason_rd">OFFICECOMPLETE</xsl:element>             
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="service_characteristic_list"/>          
        </xsl:element>
      </xsl:element>
           
      <!-- Create Customer Order -->    
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
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
          <xsl:element name="provider_tracking_no">001o</xsl:element>
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
              <xsl:element name="command_id">add_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>                                  
          </xsl:element>         
        </xsl:element>
      </xsl:element>
      
      <!--Release customer order-->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>            
        </xsl:element>
      </xsl:element>
      
      <!-- Create Customer Order -->    
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_2</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
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
          <xsl:element name="provider_tracking_no">002o</xsl:element>
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
              <xsl:element name="command_id">term_service</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>                                  
          </xsl:element>         
        </xsl:element>
      </xsl:element>
      
      <!--Release customer order-->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_2</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>            
        </xsl:element>
      </xsl:element>
      
      <!-- Create Contact -->     
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">OFFICECOMPLETE</xsl:element>
          <xsl:element name="short_description">Office Complete geändert</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>Office Complete geändert über </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
            <xsl:text>&#xA;Tarifmodell: perSeat&#xA;Anzahl Seats: </xsl:text>
            <xsl:value-of select="request-param[@name='numberOfSeats']"/>
            <xsl:text>&#xA;TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;Wunschdatum: </xsl:text>
            <xsl:value-of select="request-param[@name='desiredDate']"/>    
            <xsl:text>&#xA;User Name: </xsl:text>
            <xsl:value-of select="request-param[@name='userName']"/>  
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- map number of seats -->
      <xsl:element name="CcmFifMapStringCmd">
        <xsl:element name="command_id">map_seats</xsl:element>
        <xsl:element name="CcmFifMapStringInCont">
          <xsl:element name="input_string_type">serviceCode</xsl:element>
          <xsl:element name="input_string_ref">
            <xsl:element name="command_id">get_seat_service_info</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>
          </xsl:element>
          <xsl:element name="output_string_type">numberOfSeats</xsl:element>
          <xsl:element name="string_mapping_list">
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">V0452</xsl:element>
              <xsl:element name="output_string">2</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">V0453</xsl:element>
              <xsl:element name="output_string">3</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">V0454</xsl:element>
              <xsl:element name="output_string">4</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">V0455</xsl:element>
              <xsl:element name="output_string">5</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">V0456</xsl:element>
              <xsl:element name="output_string">6</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">V0457</xsl:element>
              <xsl:element name="output_string">7</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">V0458</xsl:element>
              <xsl:element name="output_string">8</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="no_mapping_error">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create External Notification -->
      <xsl:element name="CcmFifCreatePermNotificationCmd">
        <xsl:element name="command_id">vts_notification</xsl:element>
        <xsl:element name="CcmFifCreatePermNotificationInCont">
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
          </xsl:element>
          <xsl:element name="product_commitment_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
          <xsl:element name="status">Released</xsl:element>
          <xsl:element name="action_name">SeatChangeOrdered</xsl:element>
          <xsl:element name="target_system">Provi</xsl:element>
          <xsl:element name="create_reference_ind">Y</xsl:element>
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">serviceSubscriptionId</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>                
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">oldNumberOfSeats</xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">map_seats</xsl:element>
                <xsl:element name="field_name">output_string</xsl:element>                
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">newNumberOfSeats</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='numberOfSeats']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>

