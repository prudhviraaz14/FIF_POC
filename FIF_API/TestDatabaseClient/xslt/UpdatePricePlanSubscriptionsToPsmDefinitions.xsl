<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a FIF request that updates the price plan subscriptions
  to the PSM definition

  @author goethalo
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
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>

    <xsl:element name="Command_List">
      <xsl:element name="CcmFifUpdatePpsToPsmDefsCmd">
        <xsl:element name="command_id">update_pps_to_psm_def_1</xsl:element>
        <xsl:element name="CcmFifUpdatePpsToPsmDefsInCont">
          <xsl:element name="product_commitment_number">
            <xsl:value-of select="request-param[@name='PRODUCT_COMMITMENT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="product_commitment_type">
            <xsl:value-of select="request-param[@name='PRODUCT_COMMITMENT_TYPE']"/>
          </xsl:element>
          <xsl:element name="service_code_list">
            <xsl:for-each select="request-param-list[@name='SERVICE_CODE_LIST']/request-param-list-item">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="service_code">
                  <xsl:value-of select="request-param[@name='SERVICE_CODE']"/>
                </xsl:element>
              </xsl:element>
            </xsl:for-each>
          </xsl:element>          
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
