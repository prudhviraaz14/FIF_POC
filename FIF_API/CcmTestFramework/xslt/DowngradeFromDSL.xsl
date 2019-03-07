<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated downgrade from DSL FIF request

  @author goethalo
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
    exclude-result-prefixes="dateutils">

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
      <!-- Convert the desired date to OPM format -->
      <xsl:variable name="desiredDateOPM"
        select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>

      <!-- Find Service Subscription -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="access_number">
            <xsl:value-of select="request-param[@name='accessNumber']"/>
          </xsl:element>
          <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='contractNumber']"/>
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
          <xsl:element name="service_code_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0088</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0113</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Validate that there is maximum one service -->
      <xsl:element name="CcmFifValidateOneOrNoServSubscCmd">
        <xsl:element name="command_id">validate_max_one_ss_1</xsl:element>
        <xsl:element name="CcmFifValidateOneOrNoServSubscInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0088</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0113</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Validate no uncomplete STPs -->
      <xsl:element name="CcmFifValidateNoUncompleteStpCmd">
        <xsl:element name="command_id">validate_no_uncomplete_stp_1</xsl:element>
        <xsl:element name="CcmFifValidateNoUncompleteStpInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0088</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0113</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Reconfigure the main access service -->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconf_serv_1</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
          <xsl:element name="reason_rd">DSL_REMIGRATION</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- DSL -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0090</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">N</xsl:element>
            </xsl:element>
            <!-- Alter Anschluss -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0094</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">digital</xsl:element>
            </xsl:element>
            <!-- Anzahl neuer Rufnummern -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0936</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">0</xsl:element>
            </xsl:element>
            <!-- Automatische Versand -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0131</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">J</xsl:element>
            </xsl:element>
            <!-- Bemerkung -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">DSL-Remigration</xsl:element>
            </xsl:element>
            <!-- DSL Bandbreite -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0093</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value"></xsl:element>
            </xsl:element>
            <!-- ONKZ -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0124</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <!-- Get the area code from the access number and add a leading zero -->
                <xsl:value-of select="concat('0',substring-before(substring-after(request-param[@name='accessNumber'], ';'), ';'))"/>
              </xsl:element>
            </xsl:element>
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$desiredDateOPM"/>
              </xsl:element>
            </xsl:element>
            <!-- Grund der Neukonfiguration -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0943</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Nur DSL-Kündigung</xsl:element>
            </xsl:element>
            <!-- Bearbeitungsart -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0971</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">TAL</xsl:element>
            </xsl:element>
            <!-- Sonderzeitfenster -->
            <xsl:element name="CcmFifConfiguredValueCont">
               <xsl:element name="service_char_code">V0139</xsl:element>
               <xsl:element name="data_type">STRING</xsl:element>
               <xsl:element name="configured_value">NZF</xsl:element>
            </xsl:element>
            <!-- Fixer Bestelltermin -->
            <xsl:element name="CcmFifConfiguredValueCont">
               <xsl:element name="service_char_code">V0140</xsl:element>
               <xsl:element name="data_type">STRING</xsl:element>
               <xsl:element name="configured_value">Nein</xsl:element>
            </xsl:element>
            <!-- DTAG-Freitext -->
            <xsl:element name="CcmFifConfiguredValueCont">
               <xsl:element name="service_char_code">V0141</xsl:element>
               <xsl:element name="data_type">STRING</xsl:element>
               <xsl:element name="configured_value"></xsl:element>
            </xsl:element>
            <!-- Aktivierungszeit -->
            <xsl:element name="CcmFifConfiguredValueCont">
               <xsl:element name="service_char_code">V0940</xsl:element>
               <xsl:element name="data_type">STRING</xsl:element>
               <xsl:element name="configured_value">12</xsl:element>
            </xsl:element>            
            <!-- ACS  -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0196</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Nein</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Terminate DSL Services -->
      <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
        <xsl:element name="command_id">term_ss_1</xsl:element>
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
          <xsl:element name="reason_rd">DSL_REMIGRATION</xsl:element>
          <xsl:element name="service_code_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0074</xsl:element>
            </xsl:element>          	
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0088</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0112</xsl:element>
            </xsl:element>                        
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0113</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0115</xsl:element>
            </xsl:element>            
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0116</xsl:element>
            </xsl:element>            
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0117</xsl:element>
            </xsl:element>            
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0118</xsl:element>
            </xsl:element>                                    
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0133</xsl:element>
            </xsl:element>    
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0134</xsl:element>
            </xsl:element>  			
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0174</xsl:element>
            </xsl:element>    
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0175</xsl:element>
            </xsl:element>    
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0176</xsl:element>
            </xsl:element>    
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0177</xsl:element>
            </xsl:element>    
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0178</xsl:element>
            </xsl:element>    
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0179</xsl:element>
            </xsl:element>    
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V0180</xsl:element>
            </xsl:element>    
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V018A</xsl:element>
            </xsl:element>    
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V018B</xsl:element>
            </xsl:element>    
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V018C</xsl:element>
            </xsl:element>    
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="service_code">V018D</xsl:element>
            </xsl:element>    
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Customer Order -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="cust_order_description">DSL-Remigration</xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>
          <xsl:element name="provider_tracking_no">001</xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconf_serv_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">term_ss_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- find an open customer order for the main access service -->
      <xsl:element name="CcmFifFindCustomerOrderCmd">
        <xsl:element name="command_id">find_customer_order_1</xsl:element>
        <xsl:element name="CcmFifFindCustomerOrderInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="reason_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">RELOCATION</xsl:element>
            </xsl:element>
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
        </xsl:element>
      </xsl:element>

      <!-- get default release delay dates -->
      <xsl:variable name="releaseDelayDate"
        select="dateutils:createFIFDateOffset(request-param[@name='desiredDate'], 'DATE', request-param[@name='releaseDelayOffsetDowngrade'])"/>

      <!-- Release Customer Order -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
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
          <xsl:element name="release_delay_date">
            <xsl:value-of select="$releaseDelayDate"/>	
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Release Customer Order -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
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

      <!-- Create Contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">DSL_REMIGRATION</xsl:element>
          <xsl:element name="short_description">DSL-Remigration</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;User name: </xsl:text>
            <xsl:value-of select="request-param[@name='userName']"/>
            <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
            <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
