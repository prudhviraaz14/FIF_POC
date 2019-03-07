<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for modifying an account
  
  @author wlazlow
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
    
        <!-- update bank account migration table -->
        <xsl:element name="CcmFifModifyRowForMigrationCmd">
          <xsl:element name="command_id">update_bank_account_migration_1</xsl:element>
          <xsl:element name="CcmFifModifyRowForMigrationInCont">
            <xsl:element name="sql_where">
              <xsl:value-of select="request-param[@name='SQL_WHERE']"/>
            </xsl:element>
            <xsl:element name="row_number_limit">
              <xsl:value-of select="request-param[@name='ROW_NUMBER_LIMIT']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
 
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
