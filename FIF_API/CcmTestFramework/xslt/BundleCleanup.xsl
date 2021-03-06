<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for bundle cleanup after completion of an order

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

      <!-- find the bundle by ID -->			
      <xsl:element name="CcmFifFindBundleCmd">
        <xsl:element name="command_id">find_bundle</xsl:element>
        <xsl:element name="CcmFifFindBundleInCont">
          <xsl:element name="bundle_id">
            <xsl:value-of select="request-param[@name='bundleId']"/>
          </xsl:element>
          <xsl:element name="allow_emptied_bundles">Y</xsl:element>          
          <xsl:element name="effective_status">ACTIVE</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- If the bundle is found and it's empty, terminate it -->
      <xsl:element name="CcmFifModifyBundleCmd">
        <xsl:element name="command_id">deactivate_bundle</xsl:element>
        <xsl:element name="CcmFifModifyBundleInCont">
          <xsl:element name="bundle_id">
            <xsl:value-of select="request-param[@name='bundleId']"/>
          </xsl:element>
          <xsl:element name="terminate_empty_ind">Y</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_bundle</xsl:element>
            <xsl:element name="field_name">bundle_empty</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">Y</xsl:element>          
        </xsl:element>
      </xsl:element>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
