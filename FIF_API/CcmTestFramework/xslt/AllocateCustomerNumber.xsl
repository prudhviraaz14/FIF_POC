<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for allocating a customer number

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

      <xsl:if test="request-param[@name='forename'] = '' and request-param[@name='name'] = ''">
        <xsl:element name="CcmFifGetEntityCmd">
          <xsl:element name="command_id">get_entity</xsl:element>
          <xsl:element name="CcmFifGetEntityInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='systemID']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- concat results of two recent commands for use in process indicator --> 
        <xsl:element name="CcmFifConcatStringsCmd">
          <xsl:element name="command_id">concat_name</xsl:element>
          <xsl:element name="CcmFifConcatStringsInCont">
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">get_entity</xsl:element>
                <xsl:element name="field_name">forename</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">
                  <xsl:text> </xsl:text>
                </xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">get_entity</xsl:element>
                <xsl:element name="field_name">surname</xsl:element>							
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>        
      </xsl:if>

      <!-- Allocate customer number-->      
      <xsl:element name="CcmFifAllocateCustomerNumberCmd">
        <xsl:element name="command_id">allocate_customer_number_1</xsl:element>
        <xsl:element name="CcmFifAllocateCustomerNumberInCont">
          <xsl:choose>
            <xsl:when test="request-param[@name='forename'] = '' and request-param[@name='name'] = ''">
              <xsl:element name="customer_name_ref">
                <xsl:element name="command_id">concat_name</xsl:element>
                <xsl:element name="field_name">output_string</xsl:element>							
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="customer_name">
                <xsl:value-of select="concat(request-param[@name='forename'], ' ', request-param[@name='name'])"/>
              </xsl:element>              
            </xsl:otherwise>
          </xsl:choose>       
          <xsl:element name="system_id">
            <xsl:value-of select="request-param[@name='systemID']"/>
          </xsl:element>
          <xsl:element name="system_type">
            <xsl:value-of select="request-param[@name='systemType']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>    
      
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
