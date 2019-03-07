<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for modifying an adjustment

  @author banania
-->
<xsl:stylesheet 
  exclude-result-prefixes="dateutils" 
  version="1.0"
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
      
      <xsl:variable name="Today" select="dateutils:getCurrentDate()"/>
      <xsl:variable name="DesiredDate">  
        <xsl:choose>
          <xsl:when test ="request-param[@name='DESIRED_DATE'] = ''">
            <xsl:value-of select="$Today"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>

      <!-- Modify Adjustment -->
      <xsl:element name="CcmFifChangeAdjustmentStateCmd">
        <xsl:element name="command_id">cancel_adjustment_1</xsl:element>
        <xsl:element name="CcmFifChangeAdjustmentStateInCont">
          <xsl:element name="adjustment_id">
            <xsl:value-of select="request-param[@name='ADJUSTMENT_ID']"/>
          </xsl:element>
          <xsl:element name="state_rd">PROCESSED</xsl:element>   
          <xsl:element name="effective_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element>                 
        </xsl:element>
      </xsl:element>

      <!-- Create Contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element> 
          <xsl:element name="contact_type_rd">ADJUSTMENT</xsl:element>
          <xsl:element name="short_description">Adjustment prozessiert</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>Die Gutschrift/Lastschrift mit der ID: </xsl:text>
            <xsl:value-of select="request-param[@name='ADJUSTMENT_ID']"/>
            <xsl:text> wurde von SAP prozessiert.</xsl:text>
            <xsl:text>&#xA;Client Name: </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
            <xsl:text>&#xA;TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>&#xA;Benutzer: </xsl:text>
            <xsl:value-of select="request-param[@name='USER_NAME']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
            
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
