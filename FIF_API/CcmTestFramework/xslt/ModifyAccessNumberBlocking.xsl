<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated Modify Access Number FIF request

  @author goethalo
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
    <xsl:element name="client_name">KBA</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">
      <!-- Find Service Subscription -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="access_number">
            <xsl:value-of select="request-param[@name='accessNumber']"/>
          </xsl:element>
          <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
          <xsl:element name="technical_service_code">VOICE</xsl:element>
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

      <!-- Validate no uncomplete STPs -->
      <xsl:element name="CcmFifValidateNoUncompleteStpCmd">
        <xsl:element name="command_id">validate_no_uncomplete_stp_1</xsl:element>
        <xsl:element name="CcmFifValidateNoUncompleteStpInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="allow_future_dated_term_ind">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Validate premium numbers parameter -->
      <xsl:if test="request-param[@name='premiumNumbers'] != 'block' 
					and request-param[@name='premiumNumbers'] != 'allow' 
					and request-param[@name='premiumNumbers'] != 'unchanged'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">premium_blocking_parameter_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">
              Invalid value for parameter 'premiumNumbers' (Value: '<xsl:value-of select="request-param[@name='premiumNumbers']"/>'). Allowed values are 'block', 'allow', and 'unchanged'.
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Validate international numbers parameter -->
      <xsl:if test="request-param[@name='internationalNumbers'] != 'block'
                    and request-param[@name='internationalNumbers'] != 'allow'
                    and request-param[@name='internationalNumbers'] != 'unchanged'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">international_blocking_parameter_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">
              Invalid value for parameter 'internationalNumbers' (Value: '<xsl:value-of select="request-param[@name='internationalNumbers']"/>'). Allowed values are 'block', 'allow', and 'unchanged'.
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Validate nonEuropean numbers parameter -->
      <xsl:if test="request-param[@name='nonEuropeanNumbers'] != 'block'
                    and request-param[@name='nonEuropeanNumbers'] != 'allow'
                    and request-param[@name='nonEuropeanNumbers'] != 'unchanged'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">non_european_blocking_parameter_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">
              Invalid value for parameter 'nonEuropeanNumbers' (value: '<xsl:value-of select="request-param[@name='nonEuropeanNumbers']"/>'). Allowed values are 'block', 'allow', and 'unchanged'.
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Validate international number blocking -->
      <xsl:if test="(request-param[@name='internationalNumbers'] = 'block' and request-param[@name='nonEuropeanNumbers'] = 'allow')
					or (request-param[@name='internationalNumbers'] = 'allow' and request-param[@name='nonEuropeanNumbers'] = 'block')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">international_european_number_blocking_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">
              Invalid combination of parameters 'internationalNumber' and 'nonEuropeanNumbers'. Passed in value for 'internationalNumbers'='<xsl:value-of select="request-param[@name='internationalNumbers']"/>'. Passed in value for 'nonEuropeanNumbers'='<xsl:value-of select="request-param[@name='nonEuropeanNumbers']"/>'.
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Reconfigure Service Subscription -->
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
          <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
          <xsl:element name="reason_rd">MODIFY_NUM_BLOCK</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Bemerkung -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0008</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Rufnummernsperre-Änderung</xsl:element>
            </xsl:element>
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
				  <!-- Convert the desired date to OPM format -->
				  <xsl:if test="request-param[@name='desiredDate'] = ''">
					<xsl:variable name="today" select="dateutils:getCurrentDate()"/>      		
					<xsl:value-of select="dateutils:createOPMDate($today)"/>
				  </xsl:if>
				  <xsl:if test="request-param[@name='desiredDate'] != ''">
					<xsl:value-of select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
				  </xsl:if>
              </xsl:element>
            </xsl:element>
            <!-- Grund der Neukonfiguration -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0943</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Rufnummernsperre-Änderung</xsl:element>
            </xsl:element>
            <!-- Bearbeitungsart -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0971</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">TAL</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:if test="request-param[@name='internationalNumbers'] != 'unchanged' or
      	            request-param[@name='nonEuropeanNumbers'] != 'unchanged' or 
                    request-param[@name='premiumNumbers'] = 'allow'">      	
      <!-- Terminate Old Blocking Services -->
      <xsl:element name="CcmFifTerminateChildServiceSubsCmd">
        <xsl:element name="command_id">terminate_services_1</xsl:element>
        <xsl:element name="CcmFifTerminateChildServiceSubsInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="no_child_error_ind">N</xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
          <xsl:element name="reason_rd">MODIFY_NUM_BLOCK</xsl:element>
          <xsl:element name="service_code_list">
            <!-- International Numbers -->
            <xsl:if test="request-param[@name='internationalNumbers'] = 'allow' or request-param[@name='nonEuropeanNumbers'] = 'block'">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0025</xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Non-European Numbers -->
            <xsl:if test="request-param[@name='nonEuropeanNumbers'] = 'allow' or request-param[@name='internationalNumbers'] = 'block'">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0026</xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- Premium Numbers -->
            <xsl:if test="request-param[@name='premiumNumbers'] = 'allow'">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">V0027</xsl:element>
              </xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>
      
      <!-- Add New Blocking Service for International Numbers -->
      <xsl:if test="request-param[@name='internationalNumbers'] = 'block'">
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_1</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
			<xsl:element name="service_code">V0025</xsl:element>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
            <xsl:element name="reason_rd">MODIFY_NUM_BLOCK</xsl:element>
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
            <xsl:element name="service_characteristic_list"/>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      <!-- Add New Blocking Service for Non-European Numbers -->
      <xsl:if test="request-param[@name='nonEuropeanNumbers'] = 'block'
					and request-param[@name='internationalNumbers'] != 'block'">
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_2</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
			<xsl:element name="service_code">V0026</xsl:element>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
            <xsl:element name="reason_rd">MODIFY_NUM_BLOCK</xsl:element>
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
            <xsl:element name="service_characteristic_list"/>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      <!-- Add New Blocking Service for Premium Numbers -->
      <xsl:if test="request-param[@name='premiumNumbers'] = 'block'">
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_3</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
			<xsl:element name="service_code">V0027</xsl:element>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
            <xsl:element name="reason_rd">MODIFY_NUM_BLOCK</xsl:element>
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
            <xsl:element name="service_characteristic_list"/>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Create Customer Order contaning all the changes -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_customer_order_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
		  <xsl:element name="cust_order_description">Rufnummernsperre-Änderung</xsl:element>
          <xsl:element name="customer_tracking_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>		  
          <xsl:element name="provider_tracking_no">001</xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconf_serv_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='internationalNumbers'] != 'unchanged' or
                          request-param[@name='nonEuropeanNumbers'] != 'unchanged' or 
                          request-param[@name='premiumNumbers'] = 'allow'">      	
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">terminate_services_1</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_2</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_3</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Release the Customer Order -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Contact for the blocking -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">MODIFY_NUM_BLOCK</xsl:element>
          <xsl:element name="short_description">Änderung Rufnummernsperre</xsl:element>
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
