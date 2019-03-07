<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for populating the table VIS_CCB_PRODUCT_MAP 

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

      <xsl:variable name="today" select="dateutils:getCurrentDate()"/>
      
      <!-- Populate the table vis_tracking_position -->      
      <xsl:element name="CcmFifCreateProdAndTariffMappingCmd">
        <xsl:element name="command_id">create_prod_and_tariff_map_1</xsl:element>
        <xsl:element name="CcmFifCreateProdAndTariffMappingInCont">          
          <xsl:element name="product_code">
            <xsl:value-of select="request-param[@name='CCB_PRODUCT_CODE']"/>
          </xsl:element>
          <xsl:element name="vis_product">
            <xsl:value-of select="request-param[@name='VIS_PRODUCT']"/>
          </xsl:element>
          <xsl:element name="desired_date">
            <xsl:value-of select="$today"/>
          </xsl:element>          
        </xsl:element>
      </xsl:element>    

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
