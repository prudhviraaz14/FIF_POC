<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
    XSLT file for creating contributing item FIF request
    
    @author makuier
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
        <xsl:element name="dependent_transaction_id">
            <xsl:value-of select="request-param[@name='dependentTransactionID']"/>
        </xsl:element>
        <xsl:element name="Command_List">
            <!-- Add contributing items -->
            <xsl:element name="CcmFifAddModifyContributingItemCmd">
                <xsl:element name="CcmFifAddModifyContributingItemInCont">
                    <xsl:element name="product_subscription_id">
                        <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
                    </xsl:element>
                    <xsl:element name="service_code">
                        <xsl:value-of select="request-param[@name='SERVICE_CODE']"/>
                    </xsl:element>
                    <xsl:element name="effective_date">
                        <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
                    </xsl:element>
                    <xsl:element name="contributing_item_list">
                        <xsl:element name="CcmFifContributingItem">
                            <xsl:element name="supported_object_type_rd">
                                <xsl:value-of select="request-param[@name='CONTRIBUTING_TYPE']"/>
                            </xsl:element>
                            <xsl:element name="start_date">
                                <xsl:value-of select="request-param[@name='START_DATE']"/>
                            </xsl:element>
                            <xsl:element name="service_subscription_id">
                                <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
