<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!--
        XSLT file for creating a FIF request for cloning a product subscription and releasing customer order

  @author banania
-->
    <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
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
            <!-- Add Service Subscription-->
            <xsl:element name="CcmFifCloneProductSubsCmd">
                <xsl:element name="command_id">clone_product_subscription_1</xsl:element>
                <xsl:element name="CcmFifCloneProductSubsInCont">
                    <xsl:element name="product_subscription_id">
                        <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
                    </xsl:element>
                    <xsl:element name="effective_date">
                        <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
                    </xsl:element>
                    <xsl:element name="service_code_list">
                        <xsl:for-each
                            select="request-param-list[@name='SERVICE_CODE_LIST']/request-param-list-item">
                            <xsl:element name="CcmFifPassingValueCont">
                                <xsl:element name="service_code">
                                    <xsl:value-of select="request-param[@name='SERVICE_CODE']"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:element>
                    <xsl:element name="service_characteristic_list">
                        <!-- Access Numbers -->
                        <xsl:for-each
                            select="request-param-list[@name='CSCs']/request-param-list-item/request-param-list[@name='ACCESS_NUMBERS']/request-param-list-item">
                            <xsl:if test="request-param[@name='DATA_TYPE'] =
                                'MAIN_ACCESS'">
                                <xsl:element name="CcmFifAccessNumberCont">
                                    <xsl:element name="service_char_code">
                                        <xsl:value-of
                                            select="request-param[@name='SERVICE_CHAR_CODE']"/>
                                    </xsl:element>
                                    <xsl:element name="data_type">MAIN_ACCESS</xsl:element>
                                    <xsl:element name="masking_digits_rd">
                                        <xsl:value-of
                                            select="request-param[@name='MASKING_DIGITS_RD']"/>
                                    </xsl:element>
                                    <xsl:element name="country_code">
                                        <xsl:value-of select="request-param[@name='COUNTRY_CODE']"/>
                                    </xsl:element>
                                    <xsl:element name="city_code">
                                        <xsl:value-of select="request-param[@name='CITY_CODE']"/>
                                    </xsl:element>
                                    <xsl:element name="local_number">
                                        <xsl:value-of select="request-param[@name='LOCAL_NUMBER']"/>
                                    </xsl:element>
                                    <xsl:element name="from_ext_num">
                                        <xsl:value-of select="request-param[@name='FROM_EXT_NUM']"/>
                                    </xsl:element>
                                    <xsl:element name="to_ext_num">
                                        <xsl:value-of select="request-param[@name='TO_EXT_NUM']"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>
                            <xsl:if test="request-param[@name='DATA_TYPE'] =
                                'ACC_NUM_RANGE'">
                                <xsl:element name="CcmFifAccessNumberCont">
                                    <xsl:element name="service_char_code">
                                        <xsl:value-of
                                            select="request-param[@name='SERVICE_CHAR_CODE']"/>
                                    </xsl:element>
                                    <xsl:element name="data_type">ACC_NUM_RANGE</xsl:element>
                                    <xsl:element name="masking_digits_rd">
                                        <xsl:value-of
                                            select="request-param[@name='MASKING_DIGITS_RD']"/>
                                    </xsl:element>
                                    <xsl:element name="retention_period_rd">
                                        <xsl:value-of
                                            select="request-param[@name='RETENTION_PERIOD_RD']"/>
                                    </xsl:element>
                                    <xsl:element name="country_code">
                                        <xsl:value-of select="request-param[@name='COUNTRY_CODE']"/>
                                    </xsl:element>
                                    <xsl:element name="city_code">
                                        <xsl:value-of select="request-param[@name='CITY_CODE']"/>
                                    </xsl:element>
                                    <xsl:element name="local_number">
                                        <xsl:value-of select="request-param[@name='LOCAL_NUMBER']"/>
                                    </xsl:element>
                                    <xsl:element name="from_ext_num">
                                        <xsl:value-of select="request-param[@name='FROM_EXT_NUM']"/>
                                    </xsl:element>
                                    <xsl:element name="to_ext_num">
                                        <xsl:value-of select="request-param[@name='TO_EXT_NUM']"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>
                            <xsl:if test="request-param[@name='DATA_TYPE'] =
                                'MAIN_ACCESS_NUM'">
                                <xsl:element name="CcmFifAccessNumberCont">
                                    <xsl:element name="service_char_code">
                                        <xsl:value-of
                                            select="request-param[@name='SERVICE_CHAR_CODE']"/>
                                    </xsl:element>
                                    <xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
                                    <xsl:element name="country_code">
                                        <xsl:value-of select="request-param[@name='COUNTRY_CODE']"/>
                                    </xsl:element>
                                    <xsl:element name="city_code">
                                        <xsl:value-of select="request-param[@name='CITY_CODE']"/>
                                    </xsl:element>
                                    <xsl:element name="local_number">
                                        <xsl:value-of select="request-param[@name='LOCAL_NUMBER']"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>
                        </xsl:for-each>
                        <!-- Configured Values -->
                        <xsl:for-each
                            select="request-param-list[@name='CSCs']/request-param-list-item/request-param-list[@name='CONFIGURED_VALUES']/request-param-list-item">
                            <xsl:element name="CcmFifConfiguredValueCont">
                                <xsl:element name="service_char_code">
                                    <xsl:value-of select="request-param[@name='SERVICE_CHAR_CODE']"
                                    />
                                </xsl:element>
                                <xsl:element name="data_type">
                                    <xsl:value-of select="request-param[@name='DATA_TYPE']"/>
                                </xsl:element>
                                <xsl:element name="configured_value">
                                    <xsl:value-of select="request-param[@name='CONFIGURED_VALUE']"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                        <!-- Address -->
                        <xsl:for-each
                            select="request-param-list[@name='CSCs']/request-param-list-item/request-param-list[@name='ADDRESS']/request-param-list-item">
                            <xsl:element name="CcmFifAddressCharacteristicCont">
                                <xsl:element name="service_char_code">
                                    <xsl:value-of select="request-param[@name='SERVICE_CHAR_CODE']"
                                    />
                                </xsl:element>
                                <xsl:element name="data_type">
                                    <xsl:value-of select="request-param[@name='DATA_TYPE']"/>
                                </xsl:element>
                                <xsl:element name="address_id">
                                    <xsl:value-of select="request-param[@name='ADDRESS_ID']"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            <!-- Create Customer Order for cloning -->
            <xsl:element name="CcmFifCreateCustOrderCmd">
                <xsl:element name="command_id">create_co_1</xsl:element>
                <xsl:element name="CcmFifCreateCustOrderInCont">
                    <xsl:element name="customer_number">
                        <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
                    </xsl:element>
                    <xsl:element name="provider_tracking_no">002</xsl:element>
                    <xsl:element name="service_ticket_pos_list_ref">
                        <xsl:element name="command_id">clone_product_subscription_1</xsl:element>
                        <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            <!-- Release Customer Order for cloning -->
            <xsl:element name="CcmFifReleaseCustOrderCmd">
                <xsl:element name="command_id">release_co_1</xsl:element>
                <xsl:element name="CcmFifReleaseCustOrderInCont">
                    <xsl:element name="customer_number">
                        <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
                    </xsl:element>
                    <xsl:element name="customer_order_ref">
                        <xsl:element name="command_id">create_co_1</xsl:element>
                        <xsl:element name="field_name">customer_order_id</xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
