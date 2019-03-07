<!--
  XSLT file for converting a DatabaseClient ModifyCommissioningInformation request
  to a FIF transaction

  @author goethalo
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
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
    <xsl:element name="client_name">SLS</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>	
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
	
    <xsl:element name="Command_List">
    <xsl:element name="CcmFifModifyCommissionInfoCmd">
      <xsl:element name="CcmFifModifyCommissionInfoInCont">
        <xsl:element name="supported_object_id"><xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/></xsl:element>
        <xsl:element name="supported_object_type_rd"><xsl:value-of select="request-param[@name='CONTRACT_TYPE']"/></xsl:element>
        <xsl:element name="cio_type_rd"><xsl:value-of select="request-param[@name='CIO_TYPE']"/></xsl:element>
        <xsl:element name="cio_data"><xsl:value-of select="request-param[@name='NEW_CIO_DATA']"/></xsl:element>
        <xsl:element name="change_reason_rd"><xsl:value-of select="request-param[@name='CHANGE_REASON_RD']"/></xsl:element>
        <xsl:element name="effective_date"><xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/></xsl:element>
      </xsl:element>
    </xsl:element>
   </xsl:element>
  </xsl:template>
</xsl:stylesheet>
