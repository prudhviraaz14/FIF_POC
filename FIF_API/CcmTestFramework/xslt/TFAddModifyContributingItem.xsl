<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!--
  XSLT file for creating a FIF request for creating a Customer Message

  @author banania
-->
    <xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1"
        indent="yes" method="xml"/>
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
        <xsl:element name="override-system-date">
            <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
        </xsl:element>
        <xsl:element name="Command_List">
            <xsl:element name="CcmFifAddModifyContributingItemCmd">
                <xsl:element name="command_id">add_modify_contributing_item_1</xsl:element>
                <xsl:element name="CcmFifAddModifyContributingItemInCont">
                    <xsl:element name="product_subscription_id">
                        <xsl:value-of
                            select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"
                        />
                    </xsl:element>
                    <xsl:element name="price_plan_code">
                        <xsl:value-of
                            select="request-param[@name='PRICE_PLAN_CODE']"/>
                    </xsl:element>
                    <xsl:element name="contributing_item_list">
                        <!-- Pass in the list of Contributing Items -->
                        <xsl:element name="CcmFifContributingItem">
                            <xsl:element name="supported_object_type_rd">
                                <xsl:value-of
                                    select="request-param[@name='SUPPORTED_OBJECT_TYPE_RD']"
                                />
                            </xsl:element>
                            <xsl:element name="start_date">
                                <xsl:value-of
                                    select="request-param[@name='START_DATE']"/>
                            </xsl:element>
                            <xsl:element name="hierarchy_inclusion_indicator">
                                <xsl:value-of
                                    select="request-param[@name='HIERARCHY_INCLUSION_INDICATOR']"
                                />
                            </xsl:element>
                            <xsl:element name="account_number">
                                <xsl:value-of
                                    select="request-param[@name='ACCOUNT_NUMBER']"
                                />
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
