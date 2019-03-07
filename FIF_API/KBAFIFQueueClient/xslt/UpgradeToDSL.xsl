<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated upgrade to DSL FIF request

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
    <xsl:element name="client_name">KBA</xsl:element>
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
        
      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
      
      <!-- Ensure that the upstream bandwidth is correct for DSL 1500 -->
      <xsl:if test="(request-param[@name='DSLBandwidth'] = 'Gold')
                    and (request-param[@name='upstreamBandwidth'] != '384')
                    and (request-param[@name='upstreamBandwidth'] != 'Standard')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">upstream_bandwidth_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Invalid upstream bandwidth value passed in for DSL Gold (DSL 1500). Passed in value: <xsl:value-of select="request-param[@name='upstreamBandwidth']"/>. Allowed values: Standard, 384.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Ensure that the upstream bandwidth is correct for DSL 1000 -->
      <xsl:if test="(request-param[@name='DSLBandwidth'] = 'DSL 1000')
                    and (request-param[@name='upstreamBandwidth'] != 'Standard')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">upstream_bandwidth_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Invalid upstream bandwidth value passed in for DSL 1000. Passed in value: <xsl:value-of select="request-param[@name='upstreamBandwidth']"/>. Allowed values: Standard.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:if test="(request-param[@name='DSLBandwidth'] = 'DSL 2000')
                    and (request-param[@name='upstreamBandwidth'] != '384')
                    and (request-param[@name='upstreamBandwidth'] != 'Standard')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">upstream_bandwidth_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Invalid upstream bandwidth value passed in for DSL 2000. Passed in value: <xsl:value-of select="request-param[@name='upstreamBandwidth']"/>. Allowed values: Standard, 384.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Ensure that the upstream bandwidth is correct for DSL 3000 -->
      <xsl:if test="(request-param[@name='DSLBandwidth'] = 'DSL 3000')
                    and (request-param[@name='upstreamBandwidth'] != '512')
                    and (request-param[@name='upstreamBandwidth'] != 'Standard')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">upstream_bandwidth_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Invalid upstream bandwidth value passed in for DSL 3000. Passed in value: <xsl:value-of select="request-param[@name='upstreamBandwidth']"/>. Allowed values: Standard, 512.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Ensure that the upstream bandwidth is correct for DSL 4000 -->
      <xsl:if test="(request-param[@name='DSLBandwidth'] = 'DSL 4000')
                    and (request-param[@name='upstreamBandwidth'] != '512')
                    and (request-param[@name='upstreamBandwidth'] != 'Standard')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">upstream_bandwidth_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Invalid upstream bandwidth value passed in for DSL 4000. Passed in value: <xsl:value-of select="request-param[@name='upstreamBandwidth']"/>. Allowed values: Standard, 512.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Ensure that the upstream bandwidth is correct for DSL 5000 until 20000-->
      <xsl:if test="((request-param[@name='DSLBandwidth'] = 'DSL 5000') or
                    (request-param[@name='DSLBandwidth'] = 'DSL 6000') or
                    (request-param[@name='DSLBandwidth'] = 'DSL 8000') or
                    (request-param[@name='DSLBandwidth'] = 'DSL 10000') or
                    (request-param[@name='DSLBandwidth'] = 'DSL 12000') or
                    (request-param[@name='DSLBandwidth'] = 'DSL 16000') or
                    (request-param[@name='DSLBandwidth'] = 'DSL 20000'))
                    and (request-param[@name='upstreamBandwidth'] != 'Standard')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">upstream_bandwidth_error</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Invalid upstream bandwidth value passed in for <xsl:value-of select="request-param[@name='DSLBandwidth']"/>. Passed in value: <xsl:value-of select="request-param[@name='upstreamBandwidth']"/>. Allowed values: Standard.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Add PassBack containers -->
      <xsl:element name="CcmFifPassBackValueCmd">
        <xsl:element name="command_id">passback_1</xsl:element>
        <xsl:element name="CcmFifPassBackValueInCont">
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">newOnlineTariff</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='newOnlineTariff']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:element name="CcmFifPassBackValueCmd">
        <xsl:element name="command_id">passback_2</xsl:element>
        <xsl:element name="CcmFifPassBackValueInCont">
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">newMinPeriodDurationValue</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='newMinPeriodDurationValue']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    
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
        </xsl:element>
      </xsl:element>

      <!-- Validate no service subscription for DSL service -->
      <xsl:element name="CcmFifValidateNoServiceSubsCmd">
        <xsl:element name="command_id">validate_no_ss_1</xsl:element>
        <xsl:element name="CcmFifValidateNoServiceSubsInCont">
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

      <!-- Validate that the accounts are active  -->
      <xsl:element name="CcmFifValidateServiceAccountCmd">
        <xsl:element name="command_id">validate_ss_account_1</xsl:element>
        <xsl:element name="CcmFifValidateServiceAccountInCont">
          <xsl:element name="service_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
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
            <xsl:value-of select="$today"/>	
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">DSL_MIGRATION</xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- DSL -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0090</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">Y</xsl:element>
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
              <xsl:element name="configured_value">DSL-Migration</xsl:element>
            </xsl:element>
            <!-- DSL Bandbreite -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0093</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='DSLBandwidth']"/>
              </xsl:element>
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
              <xsl:element name="configured_value">DSL-Migration</xsl:element>
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
            <!-- set ACS  -->
            <xsl:if test="request-param[@name='setACSIndicator'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0196</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='setACSIndicator']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:element>
      </xsl:element>

   
      <!-- Add Modem, if requested -->
      <xsl:if test="request-param[@name='modemType'] != ''">
        
        <!-- Check customer classification -->
        <xsl:element name="CcmFifGetCustomerDataCmd">
          <xsl:element name="command_id">get_customer_data</xsl:element>
          <xsl:element name="CcmFifGetCustomerDataInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Concat the result of recent command to create promary value of cross reference  --> 
        <xsl:element name="CcmFifConcatStringsCmd">
          <xsl:element name="command_id">concat_primary_value</xsl:element>
          <xsl:element name="CcmFifConcatStringsInCont">
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">V0088_</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">get_customer_data</xsl:element>
                <xsl:element name="field_name">classification_rd</xsl:element>							
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>							
        
        <!-- Get service code value for given customer classification from reference data -->
        <xsl:element name="CcmFifGetCrossRefSecondaryValueCmd">
          <xsl:element name="command_id">get_cross_ref_data</xsl:element>
          <xsl:element name="CcmFifGetCrossRefSecondaryValueInCont">
            <xsl:element name="group_code">SCCLASSDEF</xsl:element>
            <xsl:element name="primary_value_ref">
              <xsl:element name="command_id">concat_primary_value</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="ignore_empty_result">Y</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_2</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V0114</xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="$today"/>	
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">DSL_MIGRATION</xsl:element>
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
            <xsl:element name="service_characteristic_list">
              <!-- Liefername -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0110</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='hardwareDeliverySalutation']"/>
                  <xsl:text>;</xsl:text>
                  <xsl:value-of select="request-param[@name='hardwareDeliverySurname']"/>
                  <xsl:text>;</xsl:text>
                  <xsl:value-of select="request-param[@name='hardwareDeliveryForename']"/>
                </xsl:element>
              </xsl:element>
              <!-- Lieferanschrift -->
              <xsl:element name="CcmFifAddressCharacteristicCont">
                <xsl:element name="service_char_code">V0111</xsl:element>
                <xsl:element name="data_type">ADDRESS</xsl:element>
                <xsl:element name="address_id">
                  <xsl:value-of select="request-param[@name='hardwareDeliveryAddressID']"/>
                </xsl:element>
              </xsl:element>
              <!-- Artikelnummer -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0112</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='modemArticleNumber']"/>
                </xsl:element>
              </xsl:element>
              <!-- Subventionierungskennzeichen -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0114</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='modemSubventionIndicator']"/>
                </xsl:element>
              </xsl:element>
              <!-- Artikelbezeichnung -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0116</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='modemType']"/>
                </xsl:element>
              </xsl:element>
              <!-- Zahlungsoption -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0119</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">RG</xsl:element>
              </xsl:element>
              <!-- Service Provider -->
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0088</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value_ref">
                  <xsl:element name="command_id">get_cross_ref_data</xsl:element>
                  <xsl:element name="field_name">secondary_value</xsl:element>          	
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      

      <!-- Add Technikermontage, if requested -->
      <xsl:if test="request-param[@name='mountedByTechnician'] = 'Y'">
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_2</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V0111</xsl:element>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="$today"/>	
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">DSL_MIGRATION</xsl:element>
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
            <xsl:element name="service_characteristic_list"/>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- DSL Service -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_3</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="service_code">V0113</xsl:element>
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$today"/>	
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">DSL_MIGRATION</xsl:element>
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="service_characteristic_list">
            <!-- DSLBandbreite -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0826</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='DSLBandwidth']"/>
              </xsl:element>
            </xsl:element>
            <!-- DSL Upstream Bandbreite -->
            <xsl:element name="CcmFifConfiguredValueCont">
              <xsl:element name="service_char_code">V0092</xsl:element>
              <xsl:element name="data_type">STRING</xsl:element>
              <xsl:element name="configured_value">
                <xsl:value-of select="request-param[@name='upstreamBandwidth']"/>
              </xsl:element>
            </xsl:element>
            <!-- Allow Downgrade -->
            <xsl:if test="request-param[@name='allowDowngrade'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0875</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='allowDowngrade']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- desired bandwidth -->
            <xsl:if test="request-param[@name='desiredBandwidth'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0876</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='desiredBandwidth']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>
            <!-- change To UR2 -->
            <xsl:if test="request-param[@name='changeToUR2'] != ''">
              <xsl:element name="CcmFifConfiguredValueCont">
                <xsl:element name="service_char_code">V0878</xsl:element>
                <xsl:element name="data_type">STRING</xsl:element>
                <xsl:element name="configured_value">
                  <xsl:value-of select="request-param[@name='changeToUR2']"/>
                </xsl:element>
              </xsl:element>
            </xsl:if>            
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Add DSL Anschluss 500, if requested -->
      <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_service_4</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
          <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 500'">
            <xsl:element name="service_code">V0179</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='DSLBandwidth'] = 'Premium'">
            <xsl:element name="service_code">V0116</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='DSLBandwidth'] = 'Gold'">
            <xsl:element name="service_code">V0117</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 1000'">
            <xsl:element name="service_code">V0118</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 2000'">
            <xsl:element name="service_code">V0174</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 3000'">
            <xsl:element name="service_code">V0175</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 4000'">
            <xsl:element name="service_code">V0176</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 5000'">
            <xsl:element name="service_code">V0177</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 6000'">
            <xsl:element name="service_code">V0178</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 8000'">
            <xsl:element name="service_code">V0180</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 10000'">
            <xsl:element name="service_code">V018A</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 12000'">
            <xsl:element name="service_code">V018B</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 16000'">
            <xsl:element name="service_code">V018C</xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='DSLBandwidth'] = 'DSL 20000'">
            <xsl:element name="service_code">V018D</xsl:element>
          </xsl:if>
          <xsl:element name="parent_service_subs_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$today"/>	
          </xsl:element>
          <xsl:element name="desired_schedule_type">ASAP</xsl:element>
          <xsl:element name="reason_rd">DSL_MIGRATION</xsl:element>
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:element name="service_characteristic_list"/>
        </xsl:element>
      </xsl:element>

      <!-- Add Upstream Service, if requested -->
      <xsl:if test="(request-param[@name='upstreamBandwidth'] != 'Standard')">
        <xsl:element name="CcmFifAddServiceSubsCmd">
          <xsl:element name="command_id">add_service_5</xsl:element>
          <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:if test="(request-param[@name='DSLBandwidth'] = 'Gold') and (request-param[@name='upstreamBandwidth'] = '384')">
              <xsl:element name="service_code">V0197</xsl:element>
            </xsl:if>
            <xsl:if test="(request-param[@name='DSLBandwidth'] = 'DSL 2000') and (request-param[@name='upstreamBandwidth'] = '384')">
              <xsl:element name="service_code">V0198</xsl:element>
            </xsl:if>
            <xsl:if test="(request-param[@name='DSLBandwidth'] = 'DSL 3000') and (request-param[@name='upstreamBandwidth'] = '512')">
              <xsl:element name="service_code">V0199</xsl:element>
            </xsl:if>
            <xsl:if test="(request-param[@name='DSLBandwidth'] = 'DSL 4000') and (request-param[@name='upstreamBandwidth'] = '512')">
              <xsl:element name="service_code">V0199</xsl:element>
            </xsl:if>
            <xsl:element name="parent_service_subs_ref">
              <xsl:element name="command_id">add_service_4</xsl:element>
              <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
              <xsl:value-of select="$today"/>	
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">DSL_MIGRATION</xsl:element>
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
            <xsl:element name="service_characteristic_list"/>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- look for a voice bundle (item) -->
      <xsl:element name="CcmFifFindBundleCmd">
        <xsl:element name="command_id">find_bundle_1</xsl:element>
        <xsl:element name="CcmFifFindBundleInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="bundle_item_type_rd">VOICE_SERVICE</xsl:element>
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
        </xsl:element>
      </xsl:element>
           
      <!-- add the new voice bundle -->
      <xsl:element name="CcmFifModifyBundleCmd">
        <xsl:element name="command_id">modify_bundle_1</xsl:element>
        <xsl:element name="CcmFifModifyBundleInCont">
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>           
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>          
          <xsl:element name="bundle_found_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>         
        </xsl:element>
      </xsl:element>
            
      <!-- add the new voice bundle item -->
      <xsl:element name="CcmFifModifyBundleItemCmd">
        <xsl:element name="command_id">modify_bundle_item_1</xsl:element>
        <xsl:element name="CcmFifModifyBundleItemInCont">
          <xsl:element name="bundle_item_id_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_item_id</xsl:element>
          </xsl:element>          
          <xsl:element name="bundle_id_ref">
            <xsl:element name="command_id">modify_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_id</xsl:element>
          </xsl:element>
          <xsl:element name="bundle_item_type_rd">VOICE_SERVICE</xsl:element>
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
          <xsl:element name="bundle_found_ref">
            <xsl:element name="command_id">find_bundle_1</xsl:element>
            <xsl:element name="field_name">bundle_found</xsl:element>
          </xsl:element>        
          <xsl:element name="action_name">ADD</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Customer Order -->
      <xsl:element name="CcmFifCreateCustOrderCmd">
        <xsl:element name="command_id">create_co_1</xsl:element>
        <xsl:element name="CcmFifCreateCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="cust_order_description">DSL-Migration</xsl:element>
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
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_4</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">add_service_5</xsl:element>
              <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
            </xsl:element>
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
        </xsl:element>
      </xsl:element>

      <!-- Create Contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">DSL_MIGRATION</xsl:element>
          <xsl:element name="short_description">DSL-Migration</xsl:element>
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
