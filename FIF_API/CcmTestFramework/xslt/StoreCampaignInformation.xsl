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
            <xsl:element name="CcmFifStoreCampaignInformationCmd">
                <xsl:element name="CcmFifStoreCampaignInformationInCont">
                    <xsl:element name="customer_number">
                        <xsl:value-of select="request-param[@name='customerNumber']"/>
                    </xsl:element>
                    <xsl:element name="campaign_code">
                        <xsl:value-of select="request-param[@name='campaignCode']"/>
                    </xsl:element>
                    <xsl:element name="customer_tracking_id">
                        <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                    </xsl:element>
                    <xsl:element name="contract_number">
                        <xsl:value-of select="request-param[@name='contractNumber']"/>
                    </xsl:element>
                    <xsl:element name="contract_type">
                        <xsl:value-of select="request-param[@name='contractType']"/>
                    </xsl:element>
                    <xsl:element name="pricing_structure_code">
                        <xsl:value-of select="request-param[@name='pricingStructureCode']"/>
                    </xsl:element>
                    <xsl:element name="desired_date">
                        <xsl:value-of select="request-param[@name='desiredDate']"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
