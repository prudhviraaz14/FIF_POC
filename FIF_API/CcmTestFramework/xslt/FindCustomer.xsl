<!--
    XSLT file for converting the results of the find customer XSQL file to an XML file

    @author Olivier Goethals
    @date 2002-02-13
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" />
  <xsl:template match = "/" >
    <xsl:element name="CcmFifCommandList">
      <xsl:element name="Command_List">
        <xsl:element name="CcmFifFindCustomerCmd">
          <xsl:element name="CcmFifFindCustomerCmdOutCont">
            <xsl:for-each select="ROWSET/ROW">
              <xsl:element name="Customer">
	            <xsl:element name="CustomerNumber">
	              <xsl:value-of select="CUSTOMER_NUMBER"/>
	            </xsl:element>
	            <xsl:element name="EffectiveDate">
	              <xsl:value-of select="EFFECTIVE_DATE"/>
	            </xsl:element>
	            <xsl:element name="EffectiveStatus">
	              <xsl:value-of select="EFFECTIVE_STATUS"/>
	            </xsl:element>
			  </xsl:element>
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
