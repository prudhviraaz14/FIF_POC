<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for allocating a cid

  @author schwarje
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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

      <!-- Allocate ccb id-->      
      <xsl:element name="CcmFifAllocateCcbIdCmd">
        <xsl:element name="command_id">allocate_ccb_id_1</xsl:element>
        <xsl:element name="CcmFifAllocateCcbIdInCont">   
          <xsl:element name="type">
            <xsl:value-of select="request-param[@name='type']"/>
          </xsl:element>          
          <xsl:element name="text">
            <xsl:value-of select="request-param[@name='text']"/>
          </xsl:element>   
          <xsl:element name="system_id">
            <xsl:value-of select="request-param[@name='systemID']"/>
          </xsl:element>
          <xsl:element name="system_type">
            <xsl:value-of select="request-param[@name='systemType']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>    
      
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">function_id</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:value-of select="request-param[@name='functionID']"/>
              </xsl:element>							
            </xsl:element>                
          </xsl:element>
        </xsl:element>
      </xsl:element>           
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
