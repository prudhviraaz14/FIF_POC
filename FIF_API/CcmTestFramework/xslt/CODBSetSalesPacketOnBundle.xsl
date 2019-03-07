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
            
            <!-- Get bundle id -->     
            <xsl:element name="CcmFifReadExternalNotificationCmd">
                <xsl:element name="command_id">read_bundle_id</xsl:element>
                <xsl:element name="CcmFifReadExternalNotificationInCont">
                    <xsl:element name="transaction_id">
                        <xsl:value-of select="request-param[@name='requestListId']"/>
                    </xsl:element>
                    <xsl:element name="parameter_name">
                        <xsl:text>BUNDLE_ID</xsl:text>
                    </xsl:element>
                    <xsl:element name="ignore_empty_result">Y</xsl:element>
                </xsl:element>
            </xsl:element>
            <!-- Set sales packet id -->         
            <xsl:element name="CcmFifSetSalesPacketOnBundleCmd">
                <xsl:element name="CcmFifSetSalesPacketOnBundleInCont">
                    <xsl:element name="bundle_id_ref">
                        <xsl:element name="command_id">read_bundle_id</xsl:element>
                        <xsl:element name="field_name">parameter_value</xsl:element>
                    </xsl:element>
                    <xsl:element name="omts_order_id">
                        <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                    </xsl:element>
                    <xsl:element name="suppress_error">Y</xsl:element>
                    <xsl:element name="process_ind_ref">
                        <xsl:element name="command_id">read_bundle_id</xsl:element>
                        <xsl:element name="field_name">value_found</xsl:element>
                    </xsl:element>
                    <xsl:element name="required_process_ind">Y</xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        
    </xsl:template>
</xsl:stylesheet>
