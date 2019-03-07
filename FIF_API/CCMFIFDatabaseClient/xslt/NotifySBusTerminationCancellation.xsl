<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for sending service bus notification for link-db
	
	@author wlazlow 
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

            <xsl:if
                test="dateutils:matchPattern('[a-z,A-Z]{3}[0-9]{10}', request-param[@name='OMTSOrderID']) = 'N'">
                <xsl:element name="CcmFifConcatStringsCmd">
                    <xsl:element name="command_id">dummyaction</xsl:element>
                    <xsl:element name="CcmFifConcatStringsInCont">
                        <xsl:element name="input_string_list">
                            <xsl:element name="CcmFifPassingValueCont">
                                <xsl:element name="value">dummyaction</xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:if>

            <xsl:if
                test="dateutils:matchPattern('[a-z,A-Z]{3}[0-9]{10}', request-param[@name='OMTSOrderID']) = 'Y'">
                
                <xsl:element name="CcmFifFindExternalOrderCmd">
                    <xsl:element name="command_id">find_external_order</xsl:element>
                    <xsl:element name="CcmFifFindExternalOrderInCont">
                        <xsl:element name="barcode">
                            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                        </xsl:element>
                        <xsl:element name="double_search_ind">Y</xsl:element>
                    </xsl:element>
                </xsl:element>                    
                
                
                <!-- call the bus for master data update request -->
                <xsl:element name="CcmFifProcessServiceBusRequestCmd">
                    <xsl:element name="command_id">notify_termination_1</xsl:element>
                    <xsl:element name="CcmFifProcessServiceBusRequestInCont">
                        <xsl:element name="package_name">net.arcor.com.epsm_com_001</xsl:element>
                        <xsl:element name="service_name">EmpfangeNotification</xsl:element>
                        <xsl:element name="synch_ind">N</xsl:element>
                        <xsl:element name="external_system_id">
                            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                        </xsl:element>
                        <xsl:element name="parameter_value_list">
                            <xsl:element name="CcmFifParameterValueCont">
                                <xsl:element name="parameter_name">OrderId</xsl:element>
                                <xsl:element name="parameter_value_ref">
                                    <xsl:element name="command_id">find_external_order</xsl:element>
                                    <xsl:element name="field_name">order_id</xsl:element>                                    
                                </xsl:element>
                            </xsl:element>
                            <xsl:element name="CcmFifParameterValueCont">
                                <xsl:element name="parameter_name">NeuerStatus</xsl:element>
                                <xsl:element name="parameter_value">CANCELED</xsl:element>
                            </xsl:element>
                            <xsl:element name="CcmFifParameterValueCont">
                                <xsl:element name="parameter_name">BetroffenesObjekt</xsl:element>
                                <xsl:element name="parameter_value">SERVICE_SUBSCRIPTION</xsl:element>
                            </xsl:element>
                            <xsl:element name="CcmFifParameterValueCont">
                                <xsl:element name="parameter_name">BetroffeneID</xsl:element>
                                <xsl:element name="parameter_value">
                                    <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>

                <!-- create contact  -->
                <xsl:element name="CcmFifCreateContactCmd">
                    <xsl:element name="command_id">create_contact</xsl:element>
                    <xsl:element name="CcmFifCreateContactInCont">
                        <xsl:element name="customer_number">
                            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
                        </xsl:element>
                        <xsl:element name="contact_type_rd">COM</xsl:element>
                        <xsl:element name="short_description">COM Benachrichtigung</xsl:element>
                        <xsl:element name="long_description_text">
                            <xsl:text>Benachrichtigung für Stornierung an COM gesendet für Barcode </xsl:text>
                            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:if>

        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
