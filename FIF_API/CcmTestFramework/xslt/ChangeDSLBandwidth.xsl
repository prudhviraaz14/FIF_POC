<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- 
  XSLT file for creating an automated Change Bandwidth FIF request
  
  @author deshpanp
-->
<!DOCTYPE XSL [
<!ENTITY DecisionMaker SYSTEM "DecisionMaker_ChangeDSLBw.xsl">
<!ENTITY ChangeDSLBandwidth_ISDN SYSTEM "ChangeDSLBandwidth_ISDN.xsl">
<!ENTITY ChangeDSLBandwidth_Basis SYSTEM "ChangeDSLBandwidth_Basis.xsl">
<!ENTITY ChangeDSLBandwidth_NGN SYSTEM "ChangeDSLBandwidth_NGN.xsl">
<!ENTITY ChangeDSLBandwidth_BitDSL SYSTEM "ChangeDSLBandwidth_BitDSL.xsl">
<!ENTITY ChangeDSLBandwidth_DSLR SYSTEM "ChangeDSLBandwidth_DSLR.xsl">
<!ENTITY ChangeDSLBandwidth_SDSL SYSTEM "ChangeDSLBandwidth_SDSL.xsl">
<!ENTITY ModifyContractRenegotiate SYSTEM "ModifyContractRenegotiate.xsl">
<!ENTITY ModifyContractSignAndApply SYSTEM "ModifyContractSignAndApply.xsl">
<!ENTITY ChangeDSLBandwidth_FTTx SYSTEM "ChangeDSLBandwidth_FTTx.xsl">
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
    
    <xsl:variable name="newDSLBandwidth">
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V0133'">
        <xsl:text>Standard</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V0116'">
        <xsl:text>Premium</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V0117'">      
        <xsl:text>Gold</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V0118'">
        <xsl:text>DSL 1000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V0174'">
        <xsl:text>DSL 2000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V0175'">
        <xsl:text>DSL 3000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V0176'">
        <xsl:text>DSL 4000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V0177'">
        <xsl:text>DSL 5000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V0178'">
        <xsl:text>DSL 6000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V0179'">
        <xsl:text>DSL 500</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V0180'">
        <xsl:text>DSL 8000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V018A'">
        <xsl:text>DSL 10000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V018B'">
        <xsl:text>DSL 12000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V018C'">
        <xsl:text>DSL 16000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V018D'">
        <xsl:text>DSL 20000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V018G'">
        <xsl:text>DSL 25000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V018H'">
        <xsl:text>DSL 50000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'V018N'">
        <xsl:text>DSL 100000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'Standard'">
        <xsl:text>Standard</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'Premium'">
        <xsl:text>Premium</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'Gold'">      
        <xsl:text>Gold</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 1000'">
        <xsl:text>DSL 1000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 2000'">
        <xsl:text>DSL 2000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 3000'">
        <xsl:text>DSL 3000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 4000'">
        <xsl:text>DSL 4000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 5000'">
        <xsl:text>DSL 5000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 6000'">
        <xsl:text>DSL 6000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 500'">
        <xsl:text>DSL 500</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 8000'">
        <xsl:text>DSL 8000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 10000'">
        <xsl:text>DSL 10000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 12000'">
        <xsl:text>DSL 12000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 16000'">
        <xsl:text>DSL 16000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 20000'">
        <xsl:text>DSL 20000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 25000'">
        <xsl:text>DSL 25000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 50000'">
        <xsl:text>DSL 50000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = 'DSL 100000'">
        <xsl:text>DSL 100000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = '1000'">
        <xsl:text>DSL 1000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = '2000'">
        <xsl:text>DSL 2000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = '3000'">
        <xsl:text>DSL 3000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = '4000'">
        <xsl:text>DSL 4000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = '5000'">
        <xsl:text>DSL 5000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = '6000'">
        <xsl:text>DSL 6000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = '500'">
        <xsl:text>DSL 500</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = '8000'">
        <xsl:text>DSL 8000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = '10000'">
        <xsl:text>DSL 10000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = '12000'">
        <xsl:text>DSL 12000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = '16000'">
        <xsl:text>DSL 16000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = '20000'">
        <xsl:text>DSL 20000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = '25000'">
        <xsl:text>DSL 25000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = '50000'">
        <xsl:text>DSL 50000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newDSLBandwidth'] = '100000'">
        <xsl:text>DSL 100000</xsl:text>
      </xsl:if>
    </xsl:variable>
    
    <xsl:variable name="oldDSLBandwidth">
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V0133'">
        <xsl:text>Standard</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V0116'">
        <xsl:text>Premium</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V0117'">      
        <xsl:text>Gold</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V0118'">
        <xsl:text>DSL 1000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V0174'">
        <xsl:text>DSL 2000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V0175'">
        <xsl:text>DSL 3000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V0176'">
        <xsl:text>DSL 4000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V0177'">
        <xsl:text>DSL 5000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V0178'">
        <xsl:text>DSL 6000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V0179'">
        <xsl:text>DSL 500</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V0180'">
        <xsl:text>DSL 8000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V018A'">
        <xsl:text>DSL 10000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V018B'">
        <xsl:text>DSL 12000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V018C'">
        <xsl:text>DSL 16000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V018D'">
        <xsl:text>DSL 20000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V018G'">
        <xsl:text>DSL 25000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V018H'">
        <xsl:text>DSL 50000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'V018N'">
        <xsl:text>DSL 100000</xsl:text>
      </xsl:if>      
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'Standard'">
        <xsl:text>Standard</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'Premium'">
        <xsl:text>Premium</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'Gold'">      
        <xsl:text>Gold</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'DSL 1000'">
        <xsl:text>DSL 1000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'DSL 2000'">
        <xsl:text>DSL 2000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'DSL 3000'">
        <xsl:text>DSL 3000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'DSL 4000'">
        <xsl:text>DSL 4000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'DSL 5000'">
        <xsl:text>DSL 5000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'DSL 6000'">
        <xsl:text>DSL 6000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'DSL 500'">
        <xsl:text>DSL 500</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'DSL 8000'">
        <xsl:text>DSL 8000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'DSL 10000'">
        <xsl:text>DSL 10000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'DSL 12000'">
        <xsl:text>DSL 12000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'DSL 16000'">
        <xsl:text>DSL 16000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'DSL 20000'">
        <xsl:text>DSL 20000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'DSL 25000'">
        <xsl:text>DSL 25000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'DSL 50000'">
        <xsl:text>DSL 50000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = 'DSL 100000'">
        <xsl:text>DSL 100000</xsl:text>
      </xsl:if>      
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = '1000'">
        <xsl:text>DSL 1000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = '1500'">
        <xsl:text>DSL 1500</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = '2000'">
        <xsl:text>DSL 2000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = '3000'">
        <xsl:text>DSL 3000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = '4000'">
        <xsl:text>DSL 4000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = '5000'">
        <xsl:text>DSL 5000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = '6000'">
        <xsl:text>DSL 6000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = '500'">
        <xsl:text>DSL 500</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = '8000'">
        <xsl:text>DSL 8000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = '10000'">
        <xsl:text>DSL 10000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = '12000'">
        <xsl:text>DSL 12000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = '16000'">
        <xsl:text>DSL 16000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = '20000'">
        <xsl:text>DSL 20000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = '25000'">
        <xsl:text>DSL 25000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = '50000'">
        <xsl:text>DSL 50000</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldDSLBandwidth'] = '100000'">
        <xsl:text>DSL 100000</xsl:text>
      </xsl:if>      
    </xsl:variable>

    <xsl:variable name="newUpstreamBandwidth">
      <xsl:if test="request-param[@name='newUpstreamBandwidth'] = ''">
        <xsl:text>Standard</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newUpstreamBandwidth'] = 'V0197'">      
        <xsl:text>384</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newUpstreamBandwidth'] = 'V0199'">
        <xsl:text>512</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newUpstreamBandwidth'] = 'Standard'">
        <xsl:text>Standard</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newUpstreamBandwidth'] = '384'">
        <xsl:text>384</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='newUpstreamBandwidth'] = '512'">      
        <xsl:text>512</xsl:text>
      </xsl:if>
    </xsl:variable>
    
    <xsl:variable name="oldUpstreamBandwidth">
      <xsl:if test="request-param[@name='oldUpstreamBandwidth'] = ''">
        <xsl:text>Standard</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldUpstreamBandwidth'] = 'V0197'">      
        <xsl:text>384</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldUpstreamBandwidth'] = 'V0199'">
        <xsl:text>512</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldUpstreamBandwidth'] = 'Standard'">
        <xsl:text>Standard</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldUpstreamBandwidth'] = '384'">
        <xsl:text>384</xsl:text>
      </xsl:if>
      <xsl:if test="request-param[@name='oldUpstreamBandwidth'] = '512'">      
        <xsl:text>512</xsl:text>
      </xsl:if>
    </xsl:variable>

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
      &ChangeDSLBandwidth_Basis;
      &ChangeDSLBandwidth_NGN; 
      &ChangeDSLBandwidth_BitDSL;
      &ChangeDSLBandwidth_DSLR;
      &ChangeDSLBandwidth_SDSL;
      &ChangeDSLBandwidth_FTTx;
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
