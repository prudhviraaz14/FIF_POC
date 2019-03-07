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
        <xsl:value-of select="request-param[@name='accountNumber']"/>
      </xsl:variable>

      <xsl:variable name="targetCustomerNumber">
        <xsl:value-of select="request-param[@name='customerNumber']"/>
      </xsl:variable>

      <xsl:variable name="scenarioType">PRODUCT_CHANGE</xsl:variable>
      <xsl:variable name="keepContractConditions">
        <xsl:choose>
          <xsl:when test="request-param[@name='minPeriodDurationValue'] != ''">N</xsl:when>
          <xsl:otherwise>Y</xsl:otherwise>
        </xsl:choose>
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
        <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
      </xsl:variable>

      <xsl:variable name="activationBarcode">
        <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
      </xsl:variable>

      <xsl:variable name="TerminationReason">
        <xsl:value-of select="request-param[@name='terminationReason']"/>
      </xsl:variable>

      <xsl:variable name="ReasonRd">
        <xsl:choose>
          <xsl:when test="$isUpgrade = 'Y'">PRODCHANGE_PREM</xsl:when>
          <xsl:when test="$isDowngrade = 'Y'">PRODCHANGE_BAS</xsl:when>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="OrderVariant">
        <xsl:value-of select="request-param[@name='orderVariant']"/>
      </xsl:variable>

      <xsl:if test="not($isUpgrade)
        and count(request-param-list[@name='accessNumberList']/request-param-list-item) > 0
        and request-param[@name='numberOfNewAccessNumbers'] != '0'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">product_change_error_1</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">numberOfNewAccessNumbers must be set to '0' if no new access numbers are ordered!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:if test="$targetProductCode != $ISDNProductCode and
        $targetProductCode != $DSLProductCode and
        $targetProductCode != $BitStreamDSLProductCode">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">product_change_error_3</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Anschlussartwechsel nur erlaubt für V0002, I1204 und I1203!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:if test="$targetProductCode = $ISDNProductCode
        and $targetProductType = $productTypeBasis
        and $createDSL != 'Y'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">product_change_error_6</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">The parameter 'createDSL' musst be set to 'Y' if the target product type is Basis!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:if test="$keepAccessNumbers = 'N'
        and request-param[@name='numberOfNewAccessNumbers'] = '0'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">product_change_error_9</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">keepAccessNumbers must be set, if populated numberOfNewAccessNumbers is set to '0'!</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>

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

      <!-- concat text parts for contact text -->
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">contact_text_activation</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text>Anschlussartwechsel von </xsl:text>
                <xsl:value-of select="request-param[@name='currentProductType']"/>
                <xsl:text> zu </xsl:text>
                <xsl:value-of select="request-param[@name='targetProductType']"/>
                <xsl:text> von Vertrag </xsl:text>
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
                <xsl:text>&#xA;Barcode: </xsl:text>
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
          <xsl:element name="contact_type_rd">PROD_CHANGE</xsl:element>
          <xsl:element name="short_description">Anschlussartwechsel</xsl:element>
          <xsl:element name="description_text_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">contact_text_activation</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>

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

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
