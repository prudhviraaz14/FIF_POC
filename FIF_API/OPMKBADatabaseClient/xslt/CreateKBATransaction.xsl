<!--
  XSLT file for converting a KBA request
  to a KBA transaction XML file

  @author goethalo
  @date 2002-04-16
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:Kba="http://arcor.net/kba/inchannel.dtd" version="1.0">
<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" />
<xsl:template match="/">
<xsl:text disable-output-escaping="yes">
&lt;!DOCTYPE Kba:Transaction
  [
  &lt;!ELEMENT Kba:Transaction (Text)&gt;
  &lt;!ATTLIST Kba:Transaction version                       CDATA #FIXED "1.0"&gt;
  &lt;!ATTLIST Kba:Transaction xmlns:Kba                     CDATA #REQUIRED&gt;
  &lt;!ATTLIST Kba:Transaction customerNumber                CDATA #REQUIRED&gt;
  &lt;!ATTLIST Kba:Transaction reference                     CDATA #IMPLIED&gt;
  &lt;!ATTLIST Kba:Transaction type                          CDATA #REQUIRED&gt;
  &lt;!ATTLIST Kba:Transaction inputChannel                  (OPM) "OPM"&gt;
  &lt;!-- more channels may be added later --&gt;

  &lt;!ELEMENT Text (#PCDATA)&gt;
  ]
&gt;

</xsl:text>
<xsl:element name="Kba:Transaction">
    <xsl:attribute name="customerNumber">
        <xsl:value-of select="request/request-params/request-param[@name='CUSTOMER_NUMBER']"/>
    </xsl:attribute>
    <xsl:if test="request/request-params/request-param[@name='REFERENCE'] != ''">
        <xsl:attribute name="reference">
            <xsl:value-of select="request/request-params/request-param[@name='REFERENCE']"/>
        </xsl:attribute>
    </xsl:if>
    <xsl:attribute name="type">
        <xsl:value-of select="request/request-params/request-param[@name='TYPE']"/>
    </xsl:attribute>
    <xsl:attribute name="inputChannel">
        <xsl:value-of select="request/request-params/request-param[@name='INPUT_CHANNEL']"/>
    </xsl:attribute>
    <xsl:element name="Text">
        <xsl:value-of select="request/request-params/request-param[@name='TEXT']"/>
    </xsl:element>
</xsl:element>

</xsl:template>
</xsl:stylesheet>
