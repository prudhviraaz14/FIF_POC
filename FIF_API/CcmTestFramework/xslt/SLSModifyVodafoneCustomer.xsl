<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
    XSLT file for setting the Vodafone customer number 
    
    @author schwarje
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
            <xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
        </xsl:element>		
        <xsl:element name="action_name">
            <xsl:value-of select="//request/action-name"/>
        </xsl:element>
        <xsl:element name="override_system_date">
            <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
        </xsl:element>							
        <xsl:element name="Command_List">
            
            <xsl:if test="request-param[@name='TYPE'] != 'DRN'
                and request-param[@name='TYPE'] != 'DRM'
                and request-param[@name='TYPE'] != 'DRD'">
                <xsl:element name="CcmFifRaiseErrorCmd">
                    <xsl:element name="CcmFifRaiseErrorInCont">
                        <xsl:element name="error_text">
                            <xsl:text>Illegal transaction type. Allowed values are DRN, DRM or DRD</xsl:text>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            
            <!-- Create Contact for Service Addition -->
            <xsl:element name="CcmFifChangeCustomerCmd">
                <xsl:element name="CcmFifChangeCustomerInCont">
                    <xsl:element name="customer_number">
                        <xsl:value-of select="request-param[@name='ARCOR_CUSTOMER']"/>
                    </xsl:element>
                    <xsl:element name="customer_internal_ref_number">
                        <xsl:if test="request-param[@name='VODAFONE_CUSTOMER'] != '         '">
                            <xsl:value-of select="request-param[@name='VODAFONE_CUSTOMER']"/>
                        </xsl:if>
                        <xsl:if test="request-param[@name='VODAFONE_CUSTOMER'] = '         '">
                            <xsl:text>**NULL**</xsl:text>
                        </xsl:if>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            
            <!-- Create Contact for Service Addition -->
            <xsl:element name="CcmFifCreateContactCmd">
                <xsl:element name="CcmFifCreateContactInCont">
                    <xsl:element name="customer_number">
                        <xsl:value-of select="request-param[@name='ARCOR_CUSTOMER']"/>
                    </xsl:element>
                    <xsl:element name="contact_type_rd">CUSTOMER</xsl:element>
                    <xsl:element name="short_description">Vodafone Kundennummer gesetzt</xsl:element>
                    <xsl:element name="long_description_text">
                        <xsl:text>Vodafone Kundennummer über </xsl:text>
                        <xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
                        <xsl:text> gesetzt.&#xA;TransactionID: </xsl:text>
                        <xsl:value-of select="request-param[@name='transactionID']"/>
                        <xsl:text> &#xA;</xsl:text>                        
                        <xsl:if test="request-param[@name='TYPE'] = 'DRN'">Neuer</xsl:if>
                        <xsl:if test="request-param[@name='TYPE'] = 'DRM'">Geänderter</xsl:if>
                        <xsl:if test="request-param[@name='TYPE'] = 'DRD'">Bei Vodafone gelöschter</xsl:if>
                        <xsl:text> Kunde&#xA;Vodafone Kundennummer: </xsl:text>
                        <xsl:if test="request-param[@name='VODAFONE_CUSTOMER'] = '         '">
                            <xsl:text>keine</xsl:text>
                        </xsl:if>
                        <xsl:if test="request-param[@name='VODAFONE_CUSTOMER'] != '         '">
                            <xsl:value-of select="request-param[@name='VODAFONE_CUSTOMER']"/>
                        </xsl:if>                        
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>            
