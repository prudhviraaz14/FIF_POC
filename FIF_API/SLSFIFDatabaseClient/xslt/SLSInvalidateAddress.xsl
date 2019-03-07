<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a Invalidate Address FIF request

  @author makuier
-->
<xsl:stylesheet version="1.0"
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
  
      <xsl:if test="request-param[@name='MAILING_ID'] = ''">
        <!-- Find Access Information for Document Recipient -->
        <xsl:element name="CcmFifFindAccessInfomationCmd">
          <xsl:element name="command_id">find_access_info_1</xsl:element>
          <xsl:element name="CcmFifFindAccessInfomationInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
            </xsl:element>
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if> 
      
      <xsl:element name="CcmFifInvalidateAddressCmd">
        <xsl:element name="command_id">invalidate_address_1</xsl:element>
        <xsl:element name="CcmFifInvalidateAddressInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="address_id">
            <xsl:value-of select="request-param[@name='ADDRESS_ID']"/>
          </xsl:element>
          <xsl:if test="request-param[@name='MAILING_ID'] != ''">
            <xsl:element name="mailing_id">
              <xsl:value-of select="request-param[@name='MAILING_ID']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='MAILING_ID'] = ''">
            <xsl:element name="mailing_id_ref">
              <xsl:element name="command_id">find_access_info_1</xsl:element>
              <xsl:element name="field_name">mailing_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="action_type">INVALIDATE</xsl:element>
          <xsl:element name="check_printer_dest_rd">
            <xsl:value-of select="request-param[@name='CHECK_PRINTER_DEST_RD']"/>
          </xsl:element>     
          <xsl:element name="append_hash_indicator">
            <xsl:value-of select="request-param[@name='APPEND_HASH_INDICATOR']"/>
          </xsl:element>       
        </xsl:element>
      </xsl:element>      
 
    
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
