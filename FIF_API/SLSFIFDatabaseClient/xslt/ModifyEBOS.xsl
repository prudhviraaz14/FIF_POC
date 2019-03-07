<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for modifying an Ebos object and its associated objects
  
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
    <xsl:element name="transaction_id">
      <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="client_name">SLS</xsl:element>
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
          <xsl:when test ="request-param[@name='EFFECTIVE_DATE'] = ''">
            <xsl:value-of select="$Today"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>
      
      <xsl:variable name="ContactActionType">  
        <xsl:choose>
          <xsl:when test ="request-param[@name='ACTION_TYPE'] = 'ADD'">
            <xsl:text>erstellt </xsl:text>
          </xsl:when>
          <xsl:when test ="request-param[@name='ACTION_TYPE'] = 'REMOVE'">
            <xsl:text>deaktiviert </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>geändert </xsl:text>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>
      
      <!--  Validate parameter "ACTION_TYPE"  --> 
      <xsl:if test="(request-param[@name='ACTION_TYPE'] != 'ADD') 
        and (request-param[@name='ACTION_TYPE'] != 'REMOVE')
        and (request-param[@name='ACTION_TYPE'] != 'REPLACE')">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">raise_error</xsl:element> 
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Allowed values for parameter "ACTION_TYPE": 'ADD', 'REMOVE' and 'REPLACE'.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Get Account Data -->
      <xsl:element name="CcmFifGetAccountDataCmd">
        <xsl:element name="command_id">get_account_data</xsl:element>
        <xsl:element name="CcmFifGetAccountDataInCont">
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element>
        </xsl:element>    
      </xsl:element>   
      
      <!-- Modify Ebos  -->
      <xsl:element name="CcmFifModifyEbosAssociationCmd">
        <xsl:element name="command_id">modify_ebos_1</xsl:element>
        <xsl:element name="CcmFifModifyEbosAssociationInCont">
          <xsl:element name="ebos_id">
            <xsl:value-of select="request-param[@name='EBOS_ID']"/>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element>
          <xsl:element name="action_type">
            <xsl:value-of select="request-param[@name='ACTION_TYPE']"/>
          </xsl:element>
          <xsl:element name="itemized_bill_indicator">
            <xsl:value-of select="request-param[@name='ITEMIZED_BILL_INDICATOR']"/>
          </xsl:element>
          <xsl:element name="paper_invoice_indicator">
            <xsl:value-of select="request-param[@name='PAPER_INVOICE_INDICATOR']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Create Contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">get_account_data</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">ACCOUNT</xsl:element>
          <xsl:element name="short_description">Modify Ebos</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>Das EBOS-Element mit der ID: </xsl:text>
            <xsl:value-of select="request-param[@name='EBOS_ID']"/>
            <xsl:text> wurde von SLS FIF </xsl:text>
            <xsl:value-of select="$ContactActionType"/>
            <xsl:text>&#xA; Rechnungskontonummer: </xsl:text>
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            <xsl:text>&#xA; Desired date: </xsl:text>
            <xsl:value-of select="$DesiredDate"/>
            <xsl:text>&#xA; FIF Client Name: </xsl:text>
            <xsl:value-of select="request-param[@name='clientName']"/>
            <xsl:text>&#xA; TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
