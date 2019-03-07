<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- 
  XSLT file for creating an automated Change Bandwidth FIF request
  
  @author deshpanp
-->
<!DOCTYPE XSL [
<!ENTITY DecisionMaker SYSTEM "OPMDecisionMaker_ChangeDSLBw.xsl">
<!ENTITY ChangeDSLBandwidth_ISDN SYSTEM "OPMChangeDSLBandwidth_ISDN.xsl">
<!ENTITY ChangeDSLBandwidth_NGN SYSTEM "OPMChangeDSLBandwidth_NGN.xsl">
<!ENTITY ChangeDSLBandwidth_BitStream SYSTEM "OPMChangeDSLBandwidth_BitStream.xsl">
<!ENTITY ChangeDSLBandwidth_DSLR SYSTEM "OPMChangeDSLBandwidth_DSLR.xsl">
<!ENTITY ChangeDSLBandwidth_BusinessDSL SYSTEM "OPMChangeDSLBandwidth_BusinessDSL.xsl">
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
    <xsl:element name="transaction_list_client_name">OPM</xsl:element>
    <xsl:element name="intermediate_transaction_list">Y</xsl:element>
    <xsl:element name="transaction_list"> 
      &DecisionMaker; 
      &ChangeDSLBandwidth_ISDN;
      &ChangeDSLBandwidth_NGN; 
      &ChangeDSLBandwidth_BitStream;
      &ChangeDSLBandwidth_DSLR;
      &ChangeDSLBandwidth_BusinessDSL;
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
