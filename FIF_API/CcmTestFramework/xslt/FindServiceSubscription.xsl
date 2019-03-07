<!--
  Example XSLT file for converting a Find Service Subscription request
  to a FIF FindServiceSubscriptionCmd XML file

  @author goethalo
  @date 2002-02-18
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1"/>
  <xsl:template match="/">
    <xsl:element name="CcmFifCommandList">
      <xsl:element name="Command_List">
        <xsl:element name="CcmFifFindServiceSubscriptionCmd">
          <xsl:element name="CcmFifFindServiceSubscriptionCmdInCont">
            <xsl:element name="AccessNumber">
              <xsl:value-of select="request/request-params/request-param[@name='accessNumber']"/>
            </xsl:element>
            <xsl:element name="AccessNumberType">
              <xsl:value-of select="request/request-params/request-param[@name='accessNumberType']"/>
            </xsl:element>
            <xsl:element name="CustomerNumber">
              <xsl:value-of select="request/request-params/request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="ContractNumber">
              <xsl:value-of select="request/request-params/request-param[@name='contractNumber']"/>
            </xsl:element>
            <xsl:element name="ProductCode">
              <xsl:value-of select="request/request-params/request-param[@name='productCode']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
