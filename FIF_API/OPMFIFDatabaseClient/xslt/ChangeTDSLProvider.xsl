<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for converting an OPM change TDSL Provider request
  to a FIF transaction

  @author makuier
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
    <!-- Transaction ID -->
    <xsl:element name="transaction_id">
      <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="client_name">OPM</xsl:element>
    <!-- Action name -->
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">
      <!-- Convert the termination date to OPM format -->
      <xsl:variable name="activationDateOPM"
        select="dateutils:createOPMDate(request-param[@name='TERMINATION_DATE'])"/>
      <!--  Generate a FIF date that is one day before the relocation date   --> 
      <xsl:variable name="oneDayBefore" 
      	select="dateutils:createFIFDateOffset(request-param[@name='TERMINATION_DATE'], 'DATE', '-1')" /> 

      <!-- Find Service Subscription -->
	  <xsl:element name="CcmFifFindServiceSubsCmd">
	    <xsl:element name="command_id">find_service_1</xsl:element>
	    <xsl:element name="CcmFifFindServiceSubsInCont">
		  <xsl:element name="access_number">
			<xsl:value-of select="request-param[@name='ACCESS_NUMBER']"/>
		  </xsl:element>
		  <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
		  <xsl:element name="technical_service_code">TOC_NONBILL</xsl:element>
		</xsl:element>
	  </xsl:element>

      <!-- Validate Product Subscription Count -->
	  <xsl:element name="CcmFifValidateProdSubsCountCmd">
	    <xsl:element name="command_id">valid_ps_count_1</xsl:element>
	    <xsl:element name="CcmFifValidateProdSubsCountInCont">
          <xsl:element name="contract_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">contract_number</xsl:element>
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
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">TERMINATION</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Auftragsvariante -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">I1011</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='TERMINATION_TYPE']"/>
              </xsl:element>
            </xsl:element>
            <!-- Kündigungsgrund -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0137</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
              </xsl:element>
            </xsl:element>
            <!-- Aktivierungsdatum -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0909</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="$activationDateOPM"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:if test="request-param[@name='TERMINATION_REASON'] = 'ZPWDSLETF'">
        <!-- Add Service Subscription for Termination Fee -->
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_subscription_1</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">I1048</xsl:element>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="$oneDayBefore"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
            <xsl:element name="service_characteristic_list">
              <!-- No mandatory characteristic to configure -->
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Terminate Product Subscription -->
      <xsl:element name="CcmFifTerminateProductSubsCmd">
        <xsl:element name="command_id">terminate_ps_1</xsl:element>
        <xsl:element name="CcmFifTerminateProductSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
          </xsl:element>
          <xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
          <xsl:if test="request-param[@name='TERMINATION_REASON'] = 'ZPWDSLETF'">
             <xsl:element name="reason_rd">NOT_RELEVANT</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='TERMINATION_REASON'] != 'ZPWDSLETF'">
             <xsl:element name="reason_rd">TERMINATION</xsl:element>
          </xsl:if>
          <xsl:element name="auto_customer_order">N</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Customer Order for Recufiguration of Main Access Service -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_customer_order_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">reconf_serv_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:if test="request-param[@name='TERMINATION_REASON'] = 'ZPWDSLETF'">
        <!-- Create Customer Order for Early termination fee service -->
        <xsl:element name="CcmFifCreateCustOrderCmd">
          <xsl:element name="command_id">create_customer_order_2</xsl:element>
          <xsl:element name="CcmFifCreateCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="parent_customer_order_ref">
              <xsl:element name="command_id">create_customer_order_1</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_ticket_pos_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">add_service_subscription_1</xsl:element>
                <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Create Customer Order for Termination of Product Subscription -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_customer_order_3</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="parent_customer_order_ref">
            <xsl:element name="command_id">create_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">terminate_ps_1</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Release Customer Order 1-->
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

      <xsl:if test="request-param[@name='TERMINATION_REASON'] = 'ZPWDSLETF'">
        <!-- Release Customer Order 2-->
        <xsl:element name="CcmFifReleaseCustOrderCmd">
          <xsl:element name="CcmFifReleaseCustOrderInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="customer_order_ref">
              <xsl:element name="command_id">create_customer_order_2</xsl:element>
              <xsl:element name="field_name">customer_order_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Release Customer Order 3-->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_customer_order_3</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Contact for the Service Termination -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
          <xsl:element name="short_description">Automatische Kündigung</xsl:element>
          <xsl:element name="description_text_list">
          	<xsl:element name="CcmFifPassingValueCont">
          		<xsl:element name="contact_text">
                  <xsl:text>GF: Provider Wechsel</xsl:text>
                  <xsl:text>&#xA;ContractNumber: </xsl:text>
          		</xsl:element>
          	</xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
          	<xsl:element name="CcmFifPassingValueCont">
          		<xsl:element name="contact_text">
                  <xsl:text>&#xA;ProductSubscriptionNumber: </xsl:text>
          		</xsl:element>
          	</xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
          	<xsl:element name="CcmFifPassingValueCont">
          		<xsl:element name="contact_text">
                  <xsl:text>&#xA;TerminationReason: </xsl:text>
                  <xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
                  <xsl:text>&#xA;TeminationDate: </xsl:text>
                  <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
          		</xsl:element>
          	</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
