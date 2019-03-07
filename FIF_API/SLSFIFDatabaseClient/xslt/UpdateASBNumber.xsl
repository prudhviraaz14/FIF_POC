<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for setting ASB
  
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
    <xsl:element name="client_name">SLS</xsl:element>
    <!-- Action name -->
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">

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
            <!-- Anschlußbereich-Kennzeichen -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0934</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='ASB']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
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
          		  <xsl:text>SLS: Anschlußbereich-Kennzeichen Änderung: </xsl:text>
          		  <xsl:value-of select="request-param[@name='ASB']"/>
          		  <xsl:text>&#xA;Dienstenutzung: </xsl:text>
          		</xsl:element>
          	</xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Reconfigure the Bit DSL -->
      <!-- Find bundle for the Bit VOIP service attached to the Bit-DSL service -->
      <xsl:element name="CcmFifFindBundleCmd"> 
        <xsl:element name="command_id">find_bundle_1</xsl:element> 
        <xsl:element name="CcmFifFindBundleInCont">
          <xsl:element name="bundle_item_type_rd">BITVOIP</xsl:element> 
          <xsl:element name="supported_object_id_ref"> 
            <xsl:element name="command_id">find_service_1</xsl:element> 
            <xsl:element name="field_name">service_subscription_id</xsl:element> 
          </xsl:element>     
        </xsl:element>         
      </xsl:element> 
      
      <!-- Find  the Bit DSL service -->	
      <xsl:element name="CcmFifFindBundleCmd">
        <xsl:element name="command_id">find_bundle_2</xsl:element>
        <xsl:element name="CcmFifFindBundleInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>
          <xsl:element name="bundle_item_type_rd">BITACCESS</xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
        </xsl:element>	
      </xsl:element>	
      <!--Find service subscription for Bit VOIP to get contract number-->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_dsl_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id_ref">
            <xsl:element name="command_id">find_bundle_2</xsl:element>
            <xsl:element name="field_name">supported_object_id</xsl:element>	
          </xsl:element>	
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
        </xsl:element>	
      </xsl:element>	
      
      <!-- Reconfigure Service Subscription -->
      <xsl:element name="CcmFifReconfigServiceCmd">
        <xsl:element name="command_id">reconf_serv_1</xsl:element>
        <xsl:element name="CcmFifReconfigServiceInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_dsl_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">AEND</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- Anschlußbereich-Kennzeichen -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0934</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='ASB']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Customer Order for Reconfiguration of Main Access Service -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_customer_order_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_dsl_1</xsl:element>
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
      
      <!-- Release Customer Order -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_dsl_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="customer_order_ref">
            <xsl:element name="command_id">create_customer_order_1</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Contact for the change -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_dsl_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">INFO</xsl:element>
          <xsl:element name="short_description">Information</xsl:element>
          <xsl:element name="description_text_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="contact_text">
                <xsl:text>SLS: Anschlußbereich-Kennzeichen Änderung: </xsl:text>
                <xsl:value-of select="request-param[@name='ASB']"/>
                <xsl:text>&#xA;Dienstenutzung: </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_dsl_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
