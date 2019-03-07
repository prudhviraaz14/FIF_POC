<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for setting DTAG completion date

  @author lejam
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
      <!-- Convert the completion date to OPM format -->
      <xsl:variable name="completionDateOPM"
        select="request-param[@name='COMPLETION_DATE']"/>
      <xsl:variable name="chargeDateOPM"
        select="request-param[@name='CHARGE_DATE']"/>

      <!-- Ensure that either COMPLETION_DATE or  CHARGE_DATE are provided -->
      <xsl:if test="(request-param[@name='COMPLETION_DATE'] = '') and
        (request-param[@name='CHARGE_DATE'] = '')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">input_dates_param_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">At least one of the following params must be provided:
              COMPLETION_DATE or CHARGE_DATE.
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Ensure that either ACCESS_NUMBER or  SERVICE_SUBSCRIPTION_ID are provided -->
      <xsl:if test="(request-param[@name='ACCESS_NUMBER'] = '') and
        (request-param[@name='SERVICE_SUBSCRIPTION_ID'] = '')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">create_find_ss_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">At least one of the following params must be provided:
              ACCESS_NUMBER or SERVICE_SUBSCRIPTION_ID.
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      <!-- Find Service Subscription by SERVICE_SUBSCRIPTION_ID or ACCESS_NUMBER -->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:if test="request-param[@name='SERVICE_SUBSCRIPTION_ID'] != ''">
            <xsl:element name="service_subscription_id">
              <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="((request-param[@name='ACCESS_NUMBER'] != '' )and
            (request-param[@name='SERVICE_SUBSCRIPTION_ID'] = ''))">
            <xsl:element name="access_number">
              <xsl:value-of select="request-param[@name='ACCESS_NUMBER']"/>
            </xsl:element>
            <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
          </xsl:if>
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_val_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="product_subscription_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_code</xsl:element>
          </xsl:element>
          <xsl:element name="no_service_error">N</xsl:element>
          <xsl:element name="target_state">TERMINATED</xsl:element>
        </xsl:element>
      </xsl:element>
      <!-- Create Contact for the change -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">INFO</xsl:element>
          <xsl:element name="short_description">Information</xsl:element>
          <xsl:element name="description_text_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="contact_text">
                <xsl:text>Die Transaktion setTComCompletionDate wurde nicht ausgeführt, weil Dienstenutzung (</xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="contact_text">
                <xsl:text>) bereits gekündigt wurde.&#xA;</xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='COMPLETION_DATE'] != '' ">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="contact_text">
                  <xsl:text>OPM: Datum der DTAG Erledigungsmeldung Änderung: </xsl:text>
                  <xsl:value-of select="$completionDateOPM"/>
                  <xsl:text>&#xA;</xsl:text>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='CHARGE_DATE'] != '' ">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="contact_text">
                  <xsl:text>OPM: Datum der DTAG Entgeltmeldung Änderung: </xsl:text>
                  <xsl:value-of select="$chargeDateOPM"/>
                  <xsl:text>&#xA;</xsl:text>
                </xsl:element>
              </xsl:element>
            </xsl:if>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service_val_1</xsl:element>
            <xsl:element name="field_name">service_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>										
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
          <xsl:element name="reason_rd">AEND</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Datum der DTAG Erledigungsmeldung -->
			<xsl:if test="request-param[@name='COMPLETION_DATE'] != '' ">
				<xsl:element name="CcmFifConfiguredValueCont">
				  <xsl:element name="service_char_code">VI062</xsl:element>
				  <xsl:element name="data_type">STRING</xsl:element>
				  <xsl:element name="configured_value">
					<xsl:value-of select="$completionDateOPM"/>
				  </xsl:element>
            </xsl:element>
			</xsl:if>
			<xsl:if test="request-param[@name='CHARGE_DATE'] != '' ">
				<xsl:element name="CcmFifConfiguredValueCont">
				  <xsl:element name="service_char_code">I1327</xsl:element>
				  <xsl:element name="data_type">STRING</xsl:element>
				  <xsl:element name="configured_value">
					<xsl:value-of select="$chargeDateOPM"/>
				  </xsl:element>
				</xsl:element>
			</xsl:if>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service_val_1</xsl:element>
            <xsl:element name="field_name">service_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>										
        </xsl:element>
      </xsl:element>

      <!-- Create Customer Order for Reconfiguration of Main Access Service -->
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
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service_val_1</xsl:element>
            <xsl:element name="field_name">service_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>										
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
            <xsl:element name="command_id">create_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service_val_1</xsl:element>
            <xsl:element name="field_name">service_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>										
        </xsl:element>
      </xsl:element>

      <!-- Create Contact for the change -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">INFO</xsl:element>
          <xsl:element name="short_description">Information</xsl:element>
          <xsl:element name="description_text_list">
			<xsl:if test="request-param[@name='COMPLETION_DATE'] != '' ">
				<xsl:element name="CcmFifPassingValueCont">
					<xsl:element name="contact_text">
					  <xsl:text>OPM: Datum der DTAG Erledigungsmeldung Änderung: </xsl:text>
					  <xsl:value-of select="$completionDateOPM"/>
					  <xsl:text>&#xA;</xsl:text>
					</xsl:element>
				</xsl:element>
          	</xsl:if>
			<xsl:if test="request-param[@name='CHARGE_DATE'] != '' ">
				<xsl:element name="CcmFifPassingValueCont">
					<xsl:element name="contact_text">
					  <xsl:text>OPM: Datum der DTAG Entgeltmeldung Änderung: </xsl:text>
					  <xsl:value-of select="$chargeDateOPM"/>
					  <xsl:text>&#xA;</xsl:text>
					</xsl:element>
				</xsl:element>
          	</xsl:if>
			<xsl:element name="CcmFifPassingValueCont">
				<xsl:element name="contact_text">
				  <xsl:text>Dienstenutzung: </xsl:text>
				</xsl:element>
			</xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_service_val_1</xsl:element>
            <xsl:element name="field_name">service_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>										
        </xsl:element>
      </xsl:element>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
