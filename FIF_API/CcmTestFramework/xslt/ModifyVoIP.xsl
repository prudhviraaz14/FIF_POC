<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- 
    XSLT file for creating an automated Change Bandwidth FIF request
    
    @author makuier
-->
<!DOCTYPE XSL [
<!ENTITY DecisionMaker SYSTEM "DecisionMaker_VoIPService.xsl">
<!ENTITY ModifyVoIP_2ndLine SYSTEM "ModifyVoIP_2ndLine.xsl">
<!ENTITY ModifyVoIP_NGN SYSTEM "ModifyVoIP_NGN.xsl">
<!ENTITY ModifyVoIP_Bitstream SYSTEM "ModifyVoIP_Bitstream.xsl">
]>
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
    xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output doctype-system="fif_transaction_list.dtd" encoding="ISO-8859-1" indent="yes"
        method="xml"/>
    <xsl:template match="/">
        <xsl:element name="CcmFifTransactionList">
            <xsl:apply-templates select="request/request-params"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="request-params">
        <!-- Copy over transaction ID and action name -->
        <xsl:element name="transaction_list_id">
            <xsl:value-of select="request-param[@name='transactionID']"/>
        </xsl:element>


        <xsl:variable name="TransactionListName">  
            <xsl:variable name="TopAction" select="//request/action-name"/>
            <xsl:choose>
                <xsl:when test="$TopAction != 'modifyNgnVoIP'">
                    <xsl:value-of select="$TopAction"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>modifyNgnVoIP</xsl:text>
                </xsl:otherwise>
            </xsl:choose>                      
        </xsl:variable>        
        <xsl:element name="transaction_list_name">
            <xsl:value-of select="$TransactionListName"/>
         </xsl:element>

        <xsl:if test="request-param[@name='clientName'] != ''">      
            <xsl:element name="transaction_list_client_name">
                <xsl:value-of select="request-param[@name='clientName']"/>
            </xsl:element>
        </xsl:if>
        <xsl:element name="intermediate_transaction_list">Y</xsl:element>
        <xsl:element name="transaction_list"> 
            &DecisionMaker; 
            &ModifyVoIP_2ndLine; 
            &ModifyVoIP_NGN;
            &ModifyVoIP_Bitstream;
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
