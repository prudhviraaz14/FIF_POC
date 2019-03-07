<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- 
  XSLT file for creating termination FIF request
  
  @author banania
-->
<!DOCTYPE XSL [


<!ENTITY DecisionMaker SYSTEM "DecisionMaker_TermServByAccount.xsl">
<!ENTITY TerminateServ_ISDN SYSTEM "TerminateServiceByAccount_ISDN.xsl">
<!ENTITY TerminateService_NGNDSL SYSTEM "TerminateServiceByAccount_NGNDSL.xsl">
<!ENTITY TerminateServ_Default SYSTEM "TerminateServiceByAccount_Default.xsl">
<!ENTITY TerminateServ_Resale SYSTEM "TerminateServiceByAccount_DSLResale.xsl">
<!ENTITY TerminateService_NgnVoIP SYSTEM "TerminateServiceByAccount_NGNVoIP.xsl">
<!ENTITY TerminateServ_VoIP SYSTEM "TerminateServiceByAccount_VoIP.xsl">
<!ENTITY TerminateService_Multimedia SYSTEM "OPMTerminateService_Multimedia.xsl">
<!ENTITY TerminateService_Mobile SYSTEM "TerminateService_Mobile.xsl">
<!ENTITY TerminateService_Simple SYSTEM "TerminateServiceByAccount_Simple.xsl">
<!ENTITY TerminateServiceByAccount_MOS SYSTEM "TerminateServiceByAccount_MOS.xsl">
<!ENTITY TerminateServiceByAccount_PCBackup SYSTEM "TerminateServiceByAccount_PCBackup.xsl">
<!ENTITY CheckNoActiveServicesForAccountExists SYSTEM "CheckNoActiveServicesForAccountExists.xsl">
<!ENTITY TerminateService_TVCenter SYSTEM "TerminateServiceByAccount_TVCenter.xsl">
<!ENTITY TerminateService_BITDSL SYSTEM "TerminateServiceByAccount_BITDSL.xsl">
<!ENTITY TerminateService_BITVoIP SYSTEM "TerminateServiceByAccount_BITVoIP.xsl">


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
    
    <!-- Generate a FIF date that is one day before the termination date -->
    <xsl:variable name="oneDayBefore"
      select="dateutils:createFIFDateOffset(request-param[@name='TERMINATION_DATE'], 'DATE', '-1')"/>
    <!-- Convert the termination date to OPM format -->
    <xsl:variable name="terminationDateOPM"
      select="dateutils:createOPMDate(request-param[@name='TERMINATION_DATE'])"/>
    
    <xsl:variable name="Today" select="dateutils:getCurrentDate()"/>
    
    <xsl:variable name="TerminationDate">
      <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
    </xsl:variable> 
    
    <xsl:variable name="NoticePeriodStartDate">
      <xsl:text/>
      <xsl:value-of select="$Today"/>
    </xsl:variable>          
    
    <xsl:variable name="TerminationReason">
      <xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
    </xsl:variable>
    
    <xsl:variable name="OMTSOrderId">
      <xsl:text/>
      <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
    </xsl:variable>
    
    <xsl:variable name="ReasonRd">
      <xsl:value-of select="request-param[@name='REASON_RD']"/>
    </xsl:variable> 
    
    <xsl:variable name="CustomerNumber">
      <xsl:text/>
      <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
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
      &TerminateServ_ISDN;
      &TerminateServ_Resale;
      &TerminateService_NGNDSL; 
      &TerminateService_BITDSL; 
      &TerminateServ_Default;
    </xsl:element> 
        
  </xsl:template>
</xsl:stylesheet>
