<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
    XSLT file for creating a KBA notification.
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
            <xsl:value-of select="request-param[@name='clientName']"/>
            
        </xsl:element>
        <xsl:element name="action_name">
            <xsl:value-of select="//request/action-name"/>
        </xsl:element>
        <xsl:element name="override_system_date">
            <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
        </xsl:element>
        
        <xsl:variable name="desiredDate" >
            <xsl:choose>
                <xsl:when test="request-param[@name='desiredDate'] != ''">
                    <xsl:value-of select="request-param[@name='desiredDate']"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="dateutils:getCurrentDate()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:element name="Command_List">
            
            <xsl:element name="CcmFifCreateExternalNotificationCmd">
                <xsl:element name="command_id">create_notification</xsl:element>
                <xsl:element name="CcmFifCreateExternalNotificationInCont">
                    <xsl:element name="effective_date">
                        <xsl:value-of select="$desiredDate"/>
                    </xsl:element>
                    <xsl:element name="notification_action_name">createKBANotification</xsl:element>
                    <xsl:element name="target_system">KBA</xsl:element>
                    <xsl:element name="parameter_value_list">
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                            <xsl:element name="parameter_value">
                                <xsl:value-of select="request-param[@name='customerNumber']"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">TYPE</xsl:element>
                            <xsl:element name="parameter_value">
                                <xsl:value-of select="request-param[@name='type']"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">CATEGORY</xsl:element>
                            <xsl:element name="parameter_value">
                                <xsl:value-of select="request-param[@name='category']"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">USER_NAME</xsl:element>
                            <xsl:element name="parameter_value">
                                <xsl:value-of select="request-param[@name='clientName']"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">WORK_DATE</xsl:element>
                            <xsl:element name="parameter_value">
                                <xsl:value-of select="dateutils:getCurrentDate()"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">DESIRED_DATE</xsl:element>
                            <xsl:element name="parameter_value">
                                <xsl:value-of select="request-param[@name='desiredDate']"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">BAR_CODE</xsl:element>
                            <xsl:element name="parameter_value">
                                <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">TEXT</xsl:element>
                            <xsl:element name="parameter_value">
                                <xsl:value-of select="request-param[@name='notificationText']"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>


