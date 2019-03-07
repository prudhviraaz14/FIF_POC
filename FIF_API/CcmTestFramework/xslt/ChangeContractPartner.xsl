<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a provider change FIF request

  @author schwarje
-->

<!DOCTYPE XSL [

<!ENTITY TerminateService_ISDN SYSTEM "TerminateService_Default.xsl">
<!ENTITY TerminateService_NGN SYSTEM "TerminateService_NGN.xsl">
<!ENTITY TerminateService_BitStream SYSTEM "TerminateService_BitStream.xsl">
<!ENTITY CloneContracts_ISDN SYSTEM "CloneContracts_ISDN.xsl">
<!ENTITY CloneContracts_NGN SYSTEM "CloneContracts_NGN.xsl">
<!ENTITY CloneContracts_BitStream SYSTEM "CloneContracts_BitStream.xsl">
<!ENTITY CloneContracts_CommonTasks SYSTEM "CloneContracts_CommonTasks.xsl">
<!ENTITY HandleMMAccessHardware SYSTEM "HandleMMAccessHardware.xsl">
]>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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


      <!-- Generate a FIF date that is one day before the relocation date -->
      <xsl:variable name="oneDayBefore"
        select="dateutils:createFIFDateOffset(request-param[@name='activationDate'], 'DATE', '-1')"/>

      <!-- Convert the termination date to OPM format -->
      <xsl:variable name="desiredDateOPM"
        select="dateutils:createOPMDate(request-param[@name='activationDate'])"/>

      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>

      <xsl:variable name="terminationDateOPM"
        select="dateutils:createOPMDate(request-param[@name='activationDate'])"/>

      <xsl:variable name="NoticePeriodStartDate">
        <xsl:value-of select="request-param[@name='activationDate']"/>
      </xsl:variable>

      <xsl:variable name="TerminationDate">
        <xsl:value-of select="request-param[@name='activationDate']"/>
      </xsl:variable>

      <xsl:variable name="targetAccountNumber">
        <xsl:value-of select="request-param[@name='targetAccountNumber']"/>
      </xsl:variable>

      <xsl:variable name="targetCustomerNumber">
        <xsl:value-of select="request-param[@name='targetCustomerNumber']"/>
      </xsl:variable>

      <xsl:variable name="scenarioType">TAKEOVER</xsl:variable>
      <xsl:variable name="keepContractConditions">
        <xsl:value-of select="request-param[@name='keepContractConditions']"/>
      </xsl:variable>

      <xsl:variable name="DSLProductCode">I1204</xsl:variable>
      <xsl:variable name="VoIPProductCode">VI202</xsl:variable>
      <xsl:variable name="ISDNProductCode">V0002</xsl:variable>
      <xsl:variable name="BitStreamDSLProductCode">I1203</xsl:variable>
      <xsl:variable name="BitStreamVoIPProductCode">VI203</xsl:variable>

      <xsl:variable name="productTypeBasis">Basis</xsl:variable>
      <xsl:variable name="productTypePremium">Premium</xsl:variable>

      <xsl:variable name="currentProductType">
        <xsl:value-of select="request-param[@name='currentProductType']"/>
      </xsl:variable>

      <xsl:variable name="targetProductType">
        <xsl:value-of select="request-param[@name='targetProductType']"/>
      </xsl:variable>

      <xsl:variable name="isDowngrade">
        <xsl:choose>
          <xsl:when test="$currentProductType = $productTypePremium and
            $targetProductType = $productTypeBasis">Y</xsl:when>
          <xsl:otherwise>N</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="isUpgrade">
        <xsl:choose>
          <xsl:when test="$currentProductType = $productTypeBasis and
            $targetProductType = $productTypePremium">Y</xsl:when>
          <xsl:otherwise>N</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="createDSL">
        <xsl:value-of select="request-param[@name='createDSL']"/>
      </xsl:variable>

      <xsl:variable name="keepAccessNumbers">
        <xsl:value-of select="request-param[@name='keepAccessNumbers']"/>
      </xsl:variable>

      <xsl:variable name="currentProductCode">
        <xsl:if test="request-param[@name='currentTechnology'] = 'NGN'">
          <xsl:value-of select="$DSLProductCode"/>
        </xsl:if>
        <xsl:if test="request-param[@name='currentTechnology'] = 'ISDN'">
          <xsl:value-of select="$ISDNProductCode"/>
        </xsl:if>
        <xsl:if test="request-param[@name='currentTechnology'] = 'BitStream'">
          <xsl:value-of select="$BitStreamDSLProductCode"/>
        </xsl:if>
      </xsl:variable>

      <xsl:variable name="targetProductCode">
        <xsl:if test="request-param[@name='targetTechnology'] = 'NGN'">
          <xsl:value-of select="$DSLProductCode"/>
        </xsl:if>
        <xsl:if test="request-param[@name='targetTechnology'] = 'ISDN'">
          <xsl:value-of select="$ISDNProductCode"/>
        </xsl:if>
        <xsl:if test="request-param[@name='targetTechnology'] = 'BitStream'">
          <xsl:value-of select="$BitStreamDSLProductCode"/>
        </xsl:if>
      </xsl:variable>

      <xsl:variable name="terminationBarcode">
        <xsl:value-of select="request-param[@name='sourceOMTSOrderID']"/>
      </xsl:variable>

      <xsl:variable name="activationBarcode">
        <xsl:value-of select="request-param[@name='targetOMTSOrderID']"/>
      </xsl:variable>

      <xsl:variable name="TerminationReason">VPW</xsl:variable>

      <xsl:variable name="ReasonRd">TAKEOVERCONTRACT</xsl:variable>

      <xsl:variable name="OrderVariant">
        <xsl:value-of select="request-param[@name='orderVariant']"/>
      </xsl:variable>

      <xsl:if test="not($isUpgrade)
        and count(request-param-list[@name='accessNumberList']/request-param-list-item) > 0
        and request-param[@name='numberOfNewAccessNumbers'] != '0'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">change_contract_partner_error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">numberOfNewAccessNumbers must be set to '0' if no new access numbers are ordered!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:if test="$targetProductCode != $ISDNProductCode and
        $targetProductCode != $DSLProductCode and
        $targetProductCode != $BitStreamDSLProductCode">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">change_contract_partner_error_3</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Provider change only allowed for V0002, I1203 and I1204!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:if test="$targetProductCode != $currentProductCode
        or $targetProductType != $targetProductType">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">change_contract_partner_error_6</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Keine Änderungen an Produkt oder Anschlussart erlaubt.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:if test="$currentProductType != $productTypeBasis and $currentProductType != $productTypePremium
        or $targetProductType != $productTypeBasis and $targetProductType != $productTypePremium">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">change_contract_partner_error_7</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Only 'Basis' or 'Premium' are allowed for the parameter currentProductType or targetProductType!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:if test="$keepAccessNumbers = 'N'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">change_contract_partner_error_9</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">keepAccessNumbers muss auf Y gesetzt sein.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:if test="$targetCustomerNumber = ''">
        <!--Get Customer Number if not provided-->
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">find_target_customer</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:if test="$targetAccountNumber = ''">
        <!--Get Customer Number if not provided-->
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">find_target_account</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- get entity for customer -->
      <xsl:element name="CcmFifGetEntityCmd">
        <xsl:element name="command_id">get_entity</xsl:element>
        <xsl:element name="CcmFifGetEntityInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="$targetCustomerNumber"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Location Address -->
      <xsl:element name="CcmFifCreateAddressCmd">
        <xsl:element name="command_id">create_addr_1</xsl:element>
        <xsl:element name="CcmFifCreateAddressInCont">
          <xsl:element name="entity_ref">
            <xsl:element name="command_id">get_entity</xsl:element>
            <xsl:element name="field_name">entity_id</xsl:element>
          </xsl:element>
          <xsl:element name="address_type">LOKA</xsl:element>
          <xsl:element name="street_name">
            <xsl:value-of select="request-param[@name='streetName']"/>
          </xsl:element>
          <xsl:element name="street_number">
            <xsl:value-of select="request-param[@name='streetNumber']"/>
          </xsl:element>
          <xsl:element name="street_number_suffix">
            <xsl:value-of select="request-param[@name='numberSuffix']"/>
          </xsl:element>
          <xsl:element name="postal_code">
            <xsl:value-of select="request-param[@name='postalCode']"/>
          </xsl:element>
          <xsl:element name="city_name">
            <xsl:value-of select="request-param[@name='cityName']"/>
          </xsl:element>
          <xsl:element name="city_suffix_name">
            <xsl:value-of select="request-param[@name='citySuffix']"/>
          </xsl:element>
          <xsl:element name="country_code">
            <xsl:value-of select="request-param[@name='countryCode']"/>
          </xsl:element>
          <xsl:element name="ignore_existing_address">Y</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- use the input, if provided or the value from ext notification,
        used in the child XSLT files -->
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">find_location_address</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">create_addr_1</xsl:element>
              <xsl:element name="field_name">address_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      &CloneContracts_CommonTasks;

      <!-- Evaluate target product code -->
      <xsl:if test="$targetProductCode = $ISDNProductCode">
        &CloneContracts_ISDN;
      </xsl:if>

      <xsl:if test="$targetProductCode = $DSLProductCode">
        &CloneContracts_NGN;
      </xsl:if>

      <xsl:if test="$targetProductCode = $BitStreamDSLProductCode">
        &CloneContracts_BitStream;
      </xsl:if>

      <!-- Write to Provider-Change-Log -->
      <xsl:element name="CcmFifCreateProviderChangeLogCmd">
        <xsl:element name="command_id">create_prov_change_log</xsl:element>
        <xsl:element name="CcmFifCreateProviderChangeLogInCont">
          <xsl:element name="act_customer_order_id_ref">
            <xsl:element name="command_id">create_activation_co</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="term_customer_order_id_ref">
            <xsl:element name="command_id">ts_create_co_2</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>
          </xsl:element>
          <xsl:element name="source_system">
            <xsl:value-of select="request-param[@name='sourceSystem']"/>
          </xsl:element>
          <xsl:element name="creation_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="request-param[@name='activationDate']"/>
          </xsl:element>
          <xsl:element name="reason_rd">
            <xsl:value-of select="$ReasonRd"/>
          </xsl:element>
          <xsl:element name="detailed_reason_ref">
            <xsl:element name="command_id">clone_order_form_1</xsl:element>
            <xsl:element name="field_name">detailed_reason_rd</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- concat text parts for contact text -->
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">contact_text_activation</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text>Neuer </xsl:text>
                <xsl:value-of select="request-param[@name='targetTechnology']"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="request-param[@name='targetProductType']"/>
                <xsl:text>-Vertrag </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_cloned_service</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text> ist Teil eines Vertragspartnerwechsels von &#xA;Kunde </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text> (Barcode: </xsl:text>
                <xsl:value-of select="$terminationBarcode"/>
                <xsl:text>) zu &#xA;Kunde </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_cloned_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text> (Barcode: </xsl:text>
                <xsl:value-of select="$activationBarcode"/>
                <xsl:text>)&#xA;TransactionID: </xsl:text>
                <xsl:value-of select="request-param[@name='transactionID']"/>
                <xsl:text> (FIF-Client: </xsl:text>
                <xsl:value-of select="request-param[@name='clientName']"/>
                <xsl:text>)</xsl:text>
                <xsl:if test="request-param[@name='pricingStructureBillingName'] != ''">
                    <xsl:text>&#xA;Pricing Structure Billing Name: </xsl:text>
                    <xsl:value-of select="request-param[@name='pricingStructureBillingName']"/>
                </xsl:if>                   
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Contact for the technology change -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_cloned_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">VPW_ACT</xsl:element>
          <xsl:element name="short_description">VPW Aktivierung</xsl:element>
          <xsl:element name="description_text_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">contact_text_activation</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- concat text parts for contact text -->
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">contact_text_termination</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text>Kündigung des Vertrags </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text> ist Teil eines Vertragspartnerwechsels von &#xA;Kunde </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text> (Barcode: </xsl:text>
                <xsl:value-of select="$terminationBarcode"/>
                <xsl:text>) zu &#xA;Kunde </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_cloned_service</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text> (Barcode: </xsl:text>
                <xsl:value-of select="$activationBarcode"/>
                <xsl:text>)&#xA;TransactionID: </xsl:text>
                <xsl:value-of select="request-param[@name='transactionID']"/>
                <xsl:text> (FIF-Client: </xsl:text>
                <xsl:value-of select="request-param[@name='clientName']"/>
                <xsl:text>)</xsl:text>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Contact for the technology change -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">VPW_TERM</xsl:element>
          <xsl:element name="short_description">VPW Kündigung</xsl:element>
          <xsl:element name="description_text_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">contact_text_termination</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:if test="request-param[@name='manualRollback'] = 'Y'">
        <xsl:element name="CcmFifConcatStringsCmd">
          <xsl:element name="command_id">serviceSubscriptionId</xsl:element>
          <xsl:element name="CcmFifConcatStringsInCont">
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_cloned_service</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        <xsl:element name="CcmFifGetEntityCmd">
          <xsl:element name="command_id">getEntity</xsl:element>
          <xsl:element name="CcmFifGetEntityInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        <xsl:element name="CcmFifGetCustomerDataCmd">
          <xsl:element name="command_id">getCustomerData</xsl:element>
          <xsl:element name="CcmFifGetCustomerDataInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        <xsl:element name="CcmFifGetContactRoleDataCmd">
          <xsl:element name="command_id">getContactRoleData</xsl:element>
          <xsl:element name="CcmFifGetContactRoleDataInCont">
            <xsl:element name="supported_object_id_ref">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="supported_object_type_rd">CUSTOMER</xsl:element>
            <xsl:element name="contact_role_type_rd">INHABER</xsl:element>
          </xsl:element>
        </xsl:element>
        <xsl:element name="CcmFifGetAddressDataCmd">
          <xsl:element name="command_id">getAddressData</xsl:element>
          <xsl:element name="CcmFifGetAddressDataInCont">
            <xsl:element name="address_id_ref">
              <xsl:element name="command_id">getEntity</xsl:element>
              <xsl:element name="field_name">primary_address_id</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:element name="CcmFifCreateExternalNotificationCmd">
        <xsl:element name="command_id">create_notification</xsl:element>
        <xsl:element name="CcmFifCreateExternalNotificationInCont">
          <xsl:element name="effective_date">
            <xsl:value-of select="dateutils:getCurrentDate()"/>
          </xsl:element>
          <xsl:element name="transaction_id">
            <xsl:value-of select="request-param[@name='requestListId']"/>
          </xsl:element>
          <xsl:element name="processed_indicator">Y</xsl:element>
          <xsl:element name="notification_action_name">
            <xsl:value-of select="//request/action-name"/>
          </xsl:element>
          <xsl:element name="target_system">FIF</xsl:element>
          <xsl:element name="parameter_value_list">            
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">
                <xsl:text>BUNDLE_ID</xsl:text>
              </xsl:element>
              <xsl:element name="parameter_value_ref">
                <xsl:element name="command_id">modify_bundle_1</xsl:element>
                <xsl:element name="field_name">bundle_id</xsl:element>
              </xsl:element>
            </xsl:element>	              
          </xsl:element>          
        </xsl:element>
      </xsl:element>  
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
