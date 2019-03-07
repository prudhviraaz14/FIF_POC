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
            <xsl:element name="CcmFifAddCcmParameterMapCmd">
                <xsl:element name="CcmFifAddCcmParameterMapInCont">
                    <xsl:element name="supported_object_id">
                        <xsl:value-of select="request-param[@name='supportedObjectId']"/>
                    </xsl:element>
                    <xsl:element name="supported_object_type_rd">
                        <xsl:value-of select="request-param[@name='supportedObjectTypeRd']"/>
                    </xsl:element>
                    <xsl:element name="param_action">
                        <xsl:value-of select="request-param[@name='paramAction']"/>
                    </xsl:element>
                    <xsl:element name="param_name_rd">
                        <xsl:value-of select="request-param[@name='paramNameRd']"/>
                    </xsl:element>
                    <xsl:element name="param_value">
                        <xsl:value-of select="request-param[@name='paramValue']"/>
                    </xsl:element>
                    <xsl:element name="effective_date">
                        <xsl:value-of select="request-param[@name='effectiveDate']"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
