<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an relocate contract FIF request

  @author banania
-->

<!DOCTYPE XSL [
<!ENTITY TerminateService_VoIP SYSTEM "TerminateService_VoIP.xsl">
<!ENTITY TerminateService_TVCenter SYSTEM "TerminateService_TVCenter.xsl">
<!ENTITY CloneContracts_VoIP SYSTEM "CloneContracts_VoIP.xsl">
<!ENTITY CloneContracts_TVCenter SYSTEM "CloneContracts_TVCenter.xsl">

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

      <xsl:variable name="targetAccountNumber">
        <xsl:value-of select="request-param[@name='accountNumber']"/>
      </xsl:variable>

      <xsl:variable name="targetCustomerNumber">
        <xsl:value-of select="request-param[@name='customerNumber']"/>
      </xsl:variable>

      <xsl:variable name="keepContractConditions">
        <xsl:choose>
          <xsl:when test="request-param[@name='minPeriodDurationValue'] != ''">N</xsl:when>
          <xsl:otherwise>Y</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
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

      <xsl:variable name="scenarioType">RELOCATION</xsl:variable>

      <xsl:variable name="ReasonRd">RELOCATION</xsl:variable>

      <xsl:variable name="OrderVariant">
        <xsl:value-of select="request-param[@name='orderVariant']"/>
      </xsl:variable>

      <xsl:variable name="VoIPTermOrderVariant">
        <xsl:value-of select="request-param[@name='orderVariant']"/>
      </xsl:variable>

      <xsl:variable name="TerminationReason">
        <xsl:value-of select="request-param[@name='terminationReason']"/>
      </xsl:variable>

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

      <xsl:variable name="keepAccessNumbers">
        <xsl:value-of select="request-param[@name='keepAccessNumbers']"/>
      </xsl:variable>

      <xsl:variable name="currentProductCode"></xsl:variable>

      <xsl:variable name="targetProductCode"></xsl:variable>

      <xsl:variable name="terminationBarcode">
        <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
      </xsl:variable>

      <xsl:variable name="activationBarcode">
        <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
      </xsl:variable>

      <xsl:if test="request-param[@name='relocationType'] = 'Umzug mit Rufnummernübernahme'
        and request-param[@name='numberOfNewAccessNumbers'] != '0'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">relocate_contract_error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">numberOfNewAccessNumbers must be set to '0' if no new access numbers are ordered!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:if test="request-param[@name='relocationType'] != 'Umzug mit Rufnummernübernahme'
        and request-param[@name='numberOfNewAccessNumbers'] = '0'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">relocate_contract_error_2</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">numberOfNewAccessNumbers can not be set to '0' if the relocationType is not 'Umzug mit Rufnummernübernahme'!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <!-- Find service Subs for given  service subscription id-->
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- look for a bundle (item) of the original contract -->
      <xsl:element name="CcmFifFindBundleCmd">
        <xsl:element name="command_id">find_bundle_1</xsl:element>
        <xsl:element name="CcmFifFindBundleInCont">
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">service_subscription_id</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- get entity for customer -->
      <xsl:element name="CcmFifGetEntityCmd">
        <xsl:element name="command_id">get_entity</xsl:element>
        <xsl:element name="CcmFifGetEntityInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
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

      <!-- read source packet for clone order form -->
      <xsl:element name="CcmFifReadExternalNotificationCmd">
        <xsl:element name="command_id">read_source_packet</xsl:element>
        <xsl:element name="CcmFifReadExternalNotificationInCont">
          <xsl:element name="transaction_id">
            <xsl:value-of select="request-param[@name='requestListId']"/>
          </xsl:element>
          <xsl:element name="parameter_name">SOURCE_PACKET</xsl:element>
          <xsl:element name="ignore_empty_result">Y</xsl:element>
        </xsl:element>
      </xsl:element>                          

      <xsl:choose>
        <xsl:when test="request-param[@name='productCode'] = 'VI201'">
          &CloneContracts_VoIP;
        </xsl:when>
        <xsl:when test="request-param[@name='productCode'] = 'I1305'">
          &CloneContracts_TVCenter;
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">illegal_parameter_combination</xsl:element>
            <xsl:element name="CcmFifRaiseErrorInCont">
              <xsl:element name="error_text">
                <xsl:text>Der folgende Parameterwert ist nicht erlaubt: productCode = </xsl:text>
                <xsl:value-of select="request-param[@name='productCode']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>


      <!-- concat text parts for contact text -->
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">contact_text_activation</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text>Umzug von </xsl:text>
                <xsl:choose>
                  <xsl:when test="request-param[@name='productCode'] = 'VI201'">VoIP-2nd-Line</xsl:when>
                  <xsl:when test="request-param[@name='productCode'] = 'I1305'">TV-Center</xsl:when>
                </xsl:choose>
                <xsl:text>-Vertrag </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_service_1</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text> zu Vertrag </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_cloned_service</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text> &#xA;Barcode: </xsl:text>
                <xsl:value-of select="$activationBarcode"/>
                <xsl:text>&#xA;TransactionID: </xsl:text>
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

      <!-- Create Contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_cloned_service</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">AUTO_RELOCATION</xsl:element>
          <xsl:element name="short_description">Umzug</xsl:element>
          <xsl:element name="description_text_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">contact_text_activation</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

    </xsl:element>

  </xsl:template>
</xsl:stylesheet>
