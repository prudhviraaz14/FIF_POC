<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
    XSLT file for a change packet request
    
    @author lejam
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
    xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1" indent="yes" method="xml"/>
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
            <xsl:element name="CcmFifSetSalesPacketOnBundleCmd">
                <xsl:element name="CcmFifSetSalesPacketOnBundleInCont">
                    <xsl:element name="bundle_id">
                        <xsl:value-of select="request-param[@name='BUNDLE_ID']"/>
                    </xsl:element>
                    <xsl:element name="omts_order_id">
                        <xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
