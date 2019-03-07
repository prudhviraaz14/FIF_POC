<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for reseting the registration key. IT-15592 Arcor Sicherheitspaket.

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
      <xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    
    <xsl:variable name="DesiredDate" select="request-param[@name='DESIRED_DATE']"/>
    <!-- Convert the termination date to OPM format -->
    <xsl:variable name="PortingDateOPM"
      select="dateutils:createOPMDate($DesiredDate)"/>
    <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
    
    <xsl:element name="Command_List">
      
      <!-- look for the service subscription -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
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
   
   
      <!-- Find Product Code from Product Commitment -->
      <xsl:element name="CcmFifGetProductCommitmentDataCmd">
        <xsl:element name="command_id">get_pc_data_1</xsl:element>
        <xsl:element name="CcmFifGetProductCommitmentDataInCont">
          <xsl:element name="product_commitment_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_commitment_number</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Find service characteristic code -->
      <xsl:element name="CcmFifGetNextAvailableAccessNumberCharCmd">
        <xsl:element name="command_id">find_available_an_1</xsl:element>
        <xsl:element name="CcmFifGetNextAvailableAccessNumberCharInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_char_code_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_char_code">V0070</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_char_code">V0071</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_char_code">V0072</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_char_code">V0073</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_char_code">V0074</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_char_code">V0075</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_char_code">V0076</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_char_code">V0077</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_char_code">V0078</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element> 
      
      <!-- Reconfigure Service Subscription -->
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
          <xsl:element name="desired_schedule_type">
            <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="request-param[@name='REASON_RD']"/>
          </xsl:element>
          <xsl:element name="service_characteristic_list">
            <!--  Rufnummer -->							
            <xsl:element name="CcmFifAccessNumberCont">
              <xsl:element name="service_char_code_ref">
                <xsl:element name="command_id">find_available_an_1</xsl:element>
                <xsl:element name="field_name">service_char_code</xsl:element>
              </xsl:element>
              <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
              <xsl:element name="country_code">
                <xsl:value-of select="request-param[@name='COUNTRY_CODE']"/>
              </xsl:element>
              <xsl:element name="city_code">
                <xsl:value-of select="request-param[@name='AREA_CODE']"/>
              </xsl:element>
              <xsl:element name="local_number">
                <xsl:value-of select="request-param[@name='LOCAL_NUMBER']"/>
              </xsl:element>
            </xsl:element>
            <!-- Anzahl der neue Rufnummern -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0936</xsl:element>
              <xsl:element name="data_type">INTEGER</xsl:element>
              <xsl:element name="configured_value">0</xsl:element>
            </xsl:element>    
            <xsl:if test="request-param[@name='OLD_TNB'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0060</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='OLD_TNB']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Aktivierungsdatum-->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$PortingDateOPM"/>
              </xsl:element>
            </xsl:element>
            <!-- Auftragsvariante  -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0810</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>  
              <xsl:element name="configured_value">Echte Neuanschaltung</xsl:element>                                  
            </xsl:element>
            <!-- Grund der Neukonfiguration -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0943</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Rufnummernänderung</xsl:element>
            </xsl:element> 
            <!-- Kündigungsgrund -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0137</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">SON</xsl:element>
            </xsl:element>
            <!-- Bearbeitungsart for ISDN only-->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0971</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">TAL</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">get_pc_data_1</xsl:element>
            <xsl:element name="field_name">product_code</xsl:element>							
          </xsl:element>          
          <xsl:element name="required_process_ind">V0002</xsl:element>
        </xsl:element>
      </xsl:element>
  
      <!-- Reconfigure Service Subscription -->
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
          <xsl:element name="desired_schedule_type">
            <xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="request-param[@name='REASON_RD']"/>
          </xsl:element>
          <xsl:element name="service_characteristic_list">
            <!--  Rufnummer -->							
            <xsl:element name="CcmFifAccessNumberCont">
              <xsl:element name="service_char_code_ref">
                <xsl:element name="command_id">find_available_an_1</xsl:element>
                <xsl:element name="field_name">service_char_code</xsl:element>
              </xsl:element>
              <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
              <xsl:element name="country_code">
                <xsl:value-of select="request-param[@name='COUNTRY_CODE']"/>
              </xsl:element>
              <xsl:element name="city_code">
                <xsl:value-of select="request-param[@name='AREA_CODE']"/>
              </xsl:element>
              <xsl:element name="local_number">
                <xsl:value-of select="request-param[@name='LOCAL_NUMBER']"/>
              </xsl:element>
            </xsl:element>
            <!-- Anzahl der neue Rufnummern -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0936</xsl:element>
              <xsl:element name="data_type">INTEGER</xsl:element>
              <xsl:element name="configured_value">0</xsl:element>
            </xsl:element>    
            <xsl:if test="request-param[@name='OLD_TNB'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0062</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='OLD_TNB']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Aktivierungsdatum-->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$PortingDateOPM"/>
              </xsl:element>
            </xsl:element>
            <!-- Auftragsvariante  -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0810</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>  
              <xsl:element name="configured_value">Echte Neuanschaltung</xsl:element>                                  
            </xsl:element>
            <!-- Grund der Neukonfiguration -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">VI008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Rufnummernänderung</xsl:element>
            </xsl:element> 
            <!-- Kündigungsgrund -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0137</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">SON</xsl:element>
            </xsl:element>
            <!-- Bearbeitungsart for NGN only-->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">VI002</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">OP</xsl:element>
            </xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">get_pc_data_1</xsl:element>
              <xsl:element name="field_name">product_code</xsl:element>							
            </xsl:element>          
            <xsl:element name="required_process_ind">VI202</xsl:element>
        </xsl:element>
      </xsl:element>
          
      <!-- Create Customer Order  -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
          </xsl:element>
          <xsl:element name="provider_tracking_no">001</xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconf_serv_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>           
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Release stand alone Customer Order  -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_co_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Contact  -->
        <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
            </xsl:element>
            <xsl:element name="contact_type_rd">PORT_ACCESS_NUM</xsl:element>
            <xsl:element name="short_description">
              <xsl:text>Rufnummer importiert über: </xsl:text>
              <xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
            </xsl:element>
            <xsl:element name="long_description_text">
              <xsl:text>TransactionID: </xsl:text>
              <xsl:value-of select="request-param[@name='transactionID']"/>
              <xsl:text>&#xA;User name: </xsl:text>
              <xsl:value-of select="request-param[@name='USER_NAME']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
  
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
