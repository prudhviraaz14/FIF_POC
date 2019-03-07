<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for modifying access information

  @author iarizova
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  exclude-result-prefixes="dateutils">
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

      <xsl:variable name="DesiredDate">  
        <xsl:choose>
          <xsl:when test ="request-param[@name='effectiveDate'] = ''">
            <xsl:value-of select="dateutils:getCurrentDate()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='validFrom']"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>
      
      <!-- Terminate Existing Access Information -->
      <xsl:if test="request-param[@name='accessInformationId'] = ''">
        <xsl:element name="CcmFifTerminateAccessInformationCmd">
          <xsl:element name="command_id">terminate_access_inf</xsl:element>
          <xsl:element name="CcmFifTerminateAccessInformationInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="access_information_type_rd">
              <xsl:value-of select="request-param[@name='accessInformationType']"/>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="$DesiredDate"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
    
      <!-- Update Access Information -->
      <xsl:element name="CcmFifUpdateAccessInformCmd">
        <xsl:element name="command_id">update_access_inf_1</xsl:element>
        <xsl:element name="CcmFifUpdateAccessInformInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="access_information_id">
            <xsl:value-of select="request-param[@name='accessInformationId']"/>
          </xsl:element>          
          <xsl:element name="effective_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element>
          <xsl:element name="access_information_type_rd">
            <xsl:value-of select="request-param[@name='accessInformationType']"/>
          </xsl:element>
          <xsl:element name="contact_name">
            <xsl:value-of select="request-param[@name='contactName']"/>
          </xsl:element>
          <xsl:element name="phone_number">
            <xsl:value-of select="request-param[@name='contactPhoneNumber']"/>
          </xsl:element>
          <xsl:element name="mobile_number">
            <xsl:value-of select="request-param[@name='contactMobileNumber']"/>
          </xsl:element>
          <xsl:element name="fax_number">
            <xsl:value-of select="request-param[@name='contactFaxNumber']"/>
          </xsl:element>
          <xsl:element name="email_address">
            <xsl:value-of select="request-param[@name='contactEmailAddress']"/>
          </xsl:element>
          <xsl:element name="email_validation_indicator">
            <xsl:value-of select="request-param[@name='emailValidationIndicator']"/>
          </xsl:element>
          <xsl:element name="electronic_contact_indicator">
            <xsl:value-of select="request-param[@name='contactElectronicContactIndicator']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
            
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
