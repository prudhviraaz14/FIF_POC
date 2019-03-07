<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for cloning an account
  
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
          <xsl:when test ="request-param[@name='desiredDate'] = ''">
            <xsl:value-of select="$Today"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>
      <!-- Get Account Data -->
      <xsl:element name="CcmFifGetAccountDataCmd">
        <xsl:element name="command_id">get_account_data</xsl:element>
        <xsl:element name="CcmFifGetAccountDataInCont">
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='accountNumber']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$DesiredDate"/>
          </xsl:element>
        </xsl:element>    
      </xsl:element>        
      
      <!-- Clone Account -->
      <xsl:element name="CcmFifCloneAccountCmd">
        <xsl:element name="command_id">clone_account</xsl:element>
        <xsl:element name="CcmFifCloneAccountInCont">
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='accountNumber']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$DesiredDate"/>
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
          <xsl:element name="short_description">Clone Account</xsl:element>
          <xsl:element name="description_text_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="contact_text">
                <xsl:text>TransactionID: </xsl:text>
                <xsl:value-of select="request-param[@name='transactionID']"/>
                <xsl:text>&#xA;Original Account Number: </xsl:text>
                <xsl:value-of select="request-param[@name='accountNumber']"/>
                <xsl:text>&#xA;Cloned Account Number: </xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">clone_account</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="contact_text">                                 
                <xsl:text>&#xA;Desired Date: </xsl:text>
                <xsl:value-of select="$DesiredDate"/>
                <xsl:text>&#xA;User: </xsl:text>
                <xsl:value-of select="request-param[@name='clientName']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        </xsl:element>

      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
