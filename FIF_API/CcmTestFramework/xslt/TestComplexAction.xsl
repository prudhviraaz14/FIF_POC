<!--
  Test XSLT file for a simple action

  @author goethalo
  @date 2002-02-18
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1"/>
  <xsl:key name="param" match="/request/request-params/request-param" use="@name"/>
  <xsl:key name="param-list" match="/request/request-params/request-param-list" use="@name"/>
  <xsl:key name="param-list-param" match="/request/request-params/request-param-list/request-param" use="@name"/>
  <xsl:template match="/">
    <xsl:element name="CcmFifCommandList">
      <xsl:element name="Command_List">
        <xsl:element name="CcmFifSimpleTestCmd">
          <xsl:element name="CcmFifSimpleTestCmdInCont">
            <xsl:element name="FirstParameter">
              <xsl:value-of select="key('param','firstParameter')"/>
            </xsl:element>
            <xsl:element name="SecondParameter">
              <xsl:value-of select="key('param-list','secondParameter')"/>
              <xsl:element name="SubParam1">
                <xsl:value-of select="key('param-list-param','subParam1')"/>
              </xsl:element>  
              <xsl:element name="SubParam2">
                <xsl:value-of select="key('param-list-param','subParam2')"/>
              </xsl:element>  
              <xsl:element name="SubParam3">
                <xsl:value-of select="key('param-list-param','subParam3')"/>
              </xsl:element>  
            </xsl:element>
            <xsl:element name="ThirdParameter">
              <xsl:value-of select="key('param','thirdParameter')"/>
            </xsl:element>            
            <xsl:element name="FourthParameter">
              <xsl:value-of select="key('param-list','fourthParameter')"/>
              <xsl:element name="SubParam1">
                <xsl:value-of select="key('param-list-param','subParam1')"/>
              </xsl:element>  
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
