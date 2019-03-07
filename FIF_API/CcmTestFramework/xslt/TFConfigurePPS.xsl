<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--
  XSLT file for creating a FIF request for creating a Customer Message

  @author banania
-->
    <xsl:output method="xml" indent="yes" encoding="ISO-8859-1"
        doctype-system="fif_transaction.dtd"/>
    <xsl:template match="/">
        <xsl:element name="CcmFifCommandList">
            <xsl:apply-templates select="request/request-params"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="request-params">
        <!-- Copy over transaction ID,action name & override_system_date -->
        <xsl:element name="transaction_id">
            <xsl:value-of select="request-param[@name='transactionID']"/>
        </xsl:element>
        <xsl:element name="action_name">
            <xsl:value-of select="//request/action-name"/>
        </xsl:element>
        <xsl:element name="override_system_date">
            <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
        </xsl:element>
        <xsl:element name="Command_List">
            <xsl:element name="CcmFifConfigurePPSCmd">
                <xsl:element name="command_id">configure_pps_1</xsl:element>
                <xsl:element name="CcmFifConfigurePPSInCont">
                    <xsl:element name="product_subscription_id">
                        <xsl:value-of
                            select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"
                        />
                    </xsl:element>
                    <xsl:element name="price_plan_code">
                        <xsl:value-of
                            select="request-param[@name='PRICE_PLAN_CODE']"/>
                    </xsl:element>
                    <xsl:element name="account_number">
                        <xsl:value-of
                            select="request-param[@name='ACCOUNT_NUMBER']"/>
                    </xsl:element>
                    <xsl:element name="pps_option_value">
                        <xsl:value-of
                            select="request-param[@name='PPS_OPTION_VALUE']"/>
                    </xsl:element>
                    <xsl:element name="selected_destinations_list">
                        <!-- Pass in the list of selected_destinations -->
                        <xsl:element name="CcmFifSelectedDestCont">
                            <xsl:element name="begin_number">
                                <xsl:value-of
                                    select="request-param[@name='BEGIN_NUMBER']"
                                />
                            </xsl:element>
                            <xsl:element name="end_number">
                                <xsl:value-of
                                    select="request-param[@name='END_NUMBER']"/>
                            </xsl:element>
                            <xsl:element name="start_date">
                                <xsl:value-of
                                    select="request-param[@name='START_DATE']"/>
                            </xsl:element>
                            <xsl:element name="stop_date">
                                <xsl:value-of
                                    select="request-param[@name='STOP_DATE']"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
