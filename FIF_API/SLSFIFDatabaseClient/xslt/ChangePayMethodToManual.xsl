<?xml version="1.0" encoding="ISO-8859-1"?>
<!--

  @author 
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
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>

    <xsl:element name="Command_List">

       <xsl:element name="CcmFifChangePayMethodCmd">
         <xsl:element name="command_id">terminate_service_subs</xsl:element>
         <xsl:element name="CcmFifChangePayMethodInCont">
           <xsl:element name="customer_number">
             <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
           </xsl:element>
           <xsl:element name="account_number">
             <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
           </xsl:element>
           <xsl:element name="effective_date">
             <xsl:value-of select="dateutils:getCurrentDate(true)"/>
           </xsl:element>
           <xsl:element name="CcmFifManualCont"/>
         </xsl:element>
       </xsl:element>

    </xsl:element>		
  </xsl:template>
</xsl:stylesheet>
