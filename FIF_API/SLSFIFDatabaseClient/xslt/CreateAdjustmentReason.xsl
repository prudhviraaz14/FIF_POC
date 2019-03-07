<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for populating the table ADJUSTMENT_REASON 

  @author banania
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
      <xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
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
          <xsl:when test ="request-param[@name='DESIRED_DATE'] = ''">
            <xsl:value-of select="dateutils:getCurrentDate()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>
      
      
      <!-- Populate the table vis_tracking_position -->      
      <xsl:element name="CcmFifCreateAdjustmentReasonCmd">
        <xsl:element name="command_id">create_adj_reas_1</xsl:element>
        <xsl:element name="CcmFifCreateAdjustmentReasonInCont">          
          <xsl:element name="reason_code">
            <xsl:value-of select="request-param[@name='REASON_CODE']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element> 
          <xsl:element name="description">
            <xsl:value-of select="request-param[@name='DESCRIPTION']"/>
          </xsl:element>
          <xsl:element name="adjustment_type">
            <xsl:value-of select="request-param[@name='ADJUSTMENT_TYPE']"/>
          </xsl:element>
          <xsl:element name="adjustment_category">
            <xsl:value-of select="request-param[@name='ADJUSTMENT_CATEGORY']"/>
          </xsl:element>
          <xsl:element name="condition_type">
            <xsl:value-of select="request-param[@name='CONDITION_TYPE']"/>
          </xsl:element>
          <xsl:element name="external_product_id">
            <xsl:value-of select="request-param[@name='EXTERNAL_PRODUCT_ID']"/>
          </xsl:element>
          <xsl:element name="reason_group">
            <xsl:value-of select="request-param[@name='REASON_GROUP']"/>
          </xsl:element>         
        </xsl:element>
      </xsl:element>    

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
