<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1" indent="yes" method="xml"/>
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

      <xsl:variable name="startDate">
        <xsl:choose>
          <xsl:when test="request-param[@name='minPeriodDurationStartDate'] = 'today'">
            <xsl:value-of select="dateutils:getCurrentDate()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='minPeriodDurationStartDate']"/>
          </xsl:otherwise>          
        </xsl:choose>
      </xsl:variable>
      
      <xsl:element name="CcmFifGetContractDatesCmd">
        <xsl:element name="command_id">getContractDates</xsl:element>
        <xsl:element name="CcmFifGetContractDatesInCont">
          <xsl:element name="min_period_dur_value">
            <xsl:value-of select="request-param[@name='minPeriodDurationValue']"/>
          </xsl:element>
          <xsl:element name="min_period_dur_unit_rd">
            <xsl:value-of select="request-param[@name='minPeriodDurationUnit']"/>
          </xsl:element>
          <xsl:element name="min_period_start_date">
            <xsl:value-of select="$startDate"/>
          </xsl:element>
          <xsl:element name="auto_extent_dur_value">
            <xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>
          </xsl:element>
          <xsl:element name="auto_extent_dur_unit_rd">
            <xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>
          </xsl:element>
          <xsl:element name="auto_extension_ind">
            <xsl:value-of select="request-param[@name='autoExtensionInd']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>      
            
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">functionID</xsl:element>
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
