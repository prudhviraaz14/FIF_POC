<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
    XSLT file for a change packet request
    
    @author banania
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
        <xsl:element name="client_name">KBA</xsl:element>
        <xsl:element name="action_name">
            <xsl:value-of select="//request/action-name"/>
        </xsl:element>
        <xsl:element name="override_system_date">
            <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
        </xsl:element>
        <xsl:element name="Command_List">  
                    
            <xsl:variable name="PacketName" select="request-param[@name='packetName']"/>  
            <xsl:variable name="DesiredDate" select="request-param[@name='desiredDate']"/> 
            
            <xsl:element name="CcmFifCreateContactCmd">
                <xsl:element name="CcmFifCreateContactInCont">
                    <xsl:element name="customer_number">
                        <xsl:value-of select="request-param[@name='customerNumber']"/>
                    </xsl:element>
                    <xsl:element name="contact_type_rd">PACKET_CHANGE</xsl:element>
                    <xsl:element name="short_description">Packetwechsel</xsl:element>
                    <xsl:element name="long_description_text">
                        <xsl:text>Transaction ID: </xsl:text>
                        <xsl:value-of select="request-param[@name='transactionID']"/>
                        <xsl:if test="(request-param[@name='userName'] != '')">
                            <xsl:text>&#xA;UserName: </xsl:text>
                            <xsl:value-of select="request-param[@name='userName']"/>
                        </xsl:if>
                        <xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
                        <xsl:value-of select="request-param[@name='rollenBezeichnung']"/>                        
                        <xsl:text>&#xA;</xsl:text>
                       <xsl:value-of select="concat('Paketwechsel bestellt zu Paket ' , $PacketName, ' mit dem Wunschdatum: ',$DesiredDate)"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
