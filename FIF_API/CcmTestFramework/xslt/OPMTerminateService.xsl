<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating an automated termination FIF request

  @author goethalo
-->

<!DOCTYPE XSL [
<!ENTITY TerminateService_Simple SYSTEM "OPMTerminateService_Simple.xsl">
<!ENTITY TerminateService_SOM SYSTEM "TerminateService_SOM.xsl">
]>
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
      <xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
      
      <xsl:variable name="Today" select="dateutils:getCurrentDate()"/>
      
      <xsl:variable name="TerminationDate">
          <xsl:choose>
              <xsl:when test ="dateutils:compareString(request-param[@name='TERMINATION_DATE'], $Today) = '-1'">
                  <xsl:value-of select="$Today"/>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
              </xsl:otherwise>
          </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="OMTSOrderId">
          <xsl:text/>
          <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
      </xsl:variable>
      
      <xsl:variable name="CustomerNumber">
          <xsl:text/>
          <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
      </xsl:variable> 
      
      <xsl:variable name="ReasonRd">
          <xsl:value-of select="request-param[@name='REASON_RD']"/>
      </xsl:variable> 
      
      <xsl:variable name="NoticePeriodStartDate">
          <xsl:text/>
          <xsl:value-of select="request-param[@name='NOTICE_PERIOD_START_DATE']"/>
      </xsl:variable>          
      
      <xsl:variable name="TerminationReason">
          <xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
      </xsl:variable>
    <!--
       SIMPLE TERMINATION
      -->

    <xsl:if test="request-param[@name='TERMINATION_TYPE'] = 'Simple'">
        &TerminateService_Simple;
    </xsl:if>

    <!--
       COMPLEX TERMINATION
      -->
    <xsl:if test="request-param[@name='TERMINATION_TYPE'] = 'Complex'">
        &TerminateService_SOM;
    </xsl:if>
      
  </xsl:template>
</xsl:stylesheet>
