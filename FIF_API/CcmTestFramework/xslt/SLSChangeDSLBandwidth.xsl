<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- 
  XSLT file for creating an automated Change Bandwidth FIF request
  
  @author deshpanp
-->
<!DOCTYPE XSL [
<!ENTITY DecisionMaker SYSTEM "SLSDecisionMaker_ChangeDSLBw.xsl">
<!ENTITY ChangeDSLBandwidth_ISDN SYSTEM "SLSChangeDSLBandwidth_ISDN.xsl">
<!ENTITY ChangeDSLBandwidth_NGN SYSTEM "SLSChangeDSLBandwidth_NGN.xsl">
]>
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output doctype-system="fif_transaction_list.dtd" encoding="ISO-8859-1" indent="yes"
    method="xml"/>
  <xsl:template match="/">
    <xsl:element name="CcmFifTransactionList">
      <xsl:apply-templates select="request/request-params"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="request-params">
    <!-- Copy over transaction ID and action name -->
    <xsl:element name="transaction_list_id">
      <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="transaction_list_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:if test="request-param[@name='clientName'] != ''">      
      <xsl:element name="transaction_list_client_name">
        <xsl:value-of select="request-param[@name='clientName']"/>
      </xsl:element>
    </xsl:if>
    <xsl:element name="intermediate_transaction_list">Y</xsl:element>
    <xsl:element name="transaction_list"> 
      &DecisionMaker; 
      &ChangeDSLBandwidth_ISDN;
      &ChangeDSLBandwidth_NGN; 
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
