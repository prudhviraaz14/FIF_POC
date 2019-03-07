<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for migrating the contracts of an ISIS customer

  @author goethalo
-->
<xsl:stylesheet exclude-result-prefixes="isisutils" version="1.0"
    xmlns:isisutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.ISISUtils"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1"
        indent="yes" method="xml"/>

    <xsl:template match="/">
        <xsl:element name="CcmFifCommandList">
            <!-- Clear the time offset -->
            <xsl:value-of select="isisutils:clearOffSets()"/>
            <!-- Transaction ID -->
            <xsl:element name="transaction_id">
              <xsl:value-of select="//ROWSET/ROW[1]/TRANSACTION_ID"/>
            </xsl:element>
            <!-- Action name -->
            <xsl:element name="action_name">MigrateContracts</xsl:element>
            <!-- Disable the warnings -->
            <xsl:element name="disable_warning">Y</xsl:element>
            <!-- Command List -->
            <xsl:element name="Command_List">
                <xsl:for-each select="//ROWSET/ROW">
                    <xsl:apply-templates select="CREATE_ORDER_FORM"/>
                    <xsl:apply-templates select="CREATE_COMMENT"/>
                    <xsl:apply-templates select="ADD_PROD_COMM"/>
                    <xsl:apply-templates select="ADD_PROD_SUBSCR"/>
                    <xsl:apply-templates select="ADD_SERV_SUBSCR"/>
                    <xsl:apply-templates select="CONFIG_PRICE_PLAN"/>
                    <xsl:apply-templates select="SET_STATE_SERV_SUBSCR"/>
                    <xsl:apply-templates select="RECONFIG_SERV_SUBSCR"/>
                    <xsl:apply-templates select="SIGN_ORDER_FORM"/>
                    <xsl:apply-templates select="RENEGOTIATE_ORDER_FORM"/>
                    <xsl:apply-templates select="TERMINATE_ORDER_FORM"/>
                </xsl:for-each>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Create Order Form -->
    <xsl:template match="CREATE_ORDER_FORM/*">
        <xsl:value-of select="isisutils:setLastStepID('CREATE_ORDER_FORM', STEPID)"/>
        <xsl:element name="CcmFifCreateOrderFormCmd">
            <xsl:element name="command_id">
                <xsl:text>create_order_form_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifCreateOrderFormInCont">
                <xsl:element name="customer_number">
                    <xsl:value-of select="../../CUSTOMER_NUMBER"/>
                </xsl:element>
                <xsl:element name="contract_number">
                    <xsl:value-of select="../../CONTRACT_NUMBER"/>
                </xsl:element>
                <xsl:element name="currency_rd">EUR</xsl:element>
                <xsl:element name="language_rd">ger</xsl:element>
                <xsl:element name="loi_indicator">
                    <xsl:value-of select="LOI_INDICATOR"/>
                </xsl:element>
                <xsl:element name="on_hold_indicator">
                    <xsl:value-of select="ON_HOLD_INDICATOR"/>
                </xsl:element>
                <xsl:element name="grace_per_dur_value">
                    <xsl:value-of select="GRACE_PERIOD_DUR_VALUE"/>
                </xsl:element>
                <xsl:element name="grace_per_dur_unit">
                    <xsl:value-of select="GRACE_PERIOD_DUR_UNIT_RD"/>
                </xsl:element>
                <xsl:element name="notice_per_dur_value">
                    <xsl:value-of select="NOTICE_PERIOD_DUR_VALUE"/>
                </xsl:element>
                <xsl:element name="notice_per_dur_unit">
                    <xsl:value-of select="NOTICE_PERIOD_DUR_UNIT_RD"/>
                </xsl:element>
                <xsl:element name="notice_per_start_date">
                    <xsl:value-of select="NOTICE_PERIOD_START_DATE"/>
                </xsl:element>
                <xsl:element name="term_dur_value">
                    <xsl:value-of select="TERM_DUR_VALUE"/>
                </xsl:element>
                <xsl:element name="term_dur_unit">
                    <xsl:value-of select="TERM_DUR_UNIT_RD"/>
                </xsl:element>
                <xsl:element name="term_start_date">
                    <xsl:value-of select="TERM_START_DATE"/>
                </xsl:element>
                <xsl:element name="termination_date">
                    <xsl:value-of select="TERMINATION_DATE"/>
                </xsl:element>
                <xsl:element name="min_per_dur_value">
                    <xsl:value-of select="MIN_PERIOD_DUR_VALUE"/>
                </xsl:element>
                <xsl:element name="min_per_dur_unit">
                    <xsl:value-of select="MIN_PERIOD_DUR_UNIT_RD"/>
                </xsl:element>
                <xsl:element name="sales_org_num_value">
                    <xsl:value-of select="SALES_ORG_NUMBER_VALUE"/>
                </xsl:element>
                <xsl:element name="sales_org_date">
                    <xsl:value-of select="SALES_ORG_DATE"/>
                </xsl:element>
                <xsl:element name="monthly_order_entry_amount">
                    <xsl:value-of select="MONTHLY_ORDER_ENTRY_AMOUNT"/>
                </xsl:element>
                <xsl:element name="termination_restriction">
                    <xsl:value-of select="TERMINATION_RESTRICTION"/>
                </xsl:element>
                <xsl:element name="doc_template_name">Vertrag</xsl:element>
                <xsl:element name="assoc_skeleton_cont_num">
                    <xsl:value-of select="ASSOC_SKELETON_CONTRACT_NUMBER"/>
                </xsl:element>
                <xsl:element name="override_restriction">Y</xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Create Comment -->
    <xsl:template match="CREATE_COMMENT/*">
        <xsl:value-of select="isisutils:setLastStepID('CREATE_COMMENT', STEPID)"/>
        <xsl:element name="CcmFifCreateCommentCmd">
            <xsl:element name="command_id">
                <xsl:text>create_comment_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifCreateCommentInCont">
                <xsl:element name="comment_id">
                    <xsl:text>OF_</xsl:text><xsl:value-of select="../../CONTRACT_NUMBER"/>
                </xsl:element>
                <xsl:element name="comment_type_rd">ISIS Migration</xsl:element>
                <xsl:element name="short_description">
                    <xsl:value-of select="SHORT_DESCRIPTION"/>
                </xsl:element>
                <xsl:element name="long_description_text">
                    <xsl:value-of select="LONG_DESCRIPTION_TEXT"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Add Product Commitment -->
    <xsl:template match="ADD_PROD_COMM/*">
        <xsl:value-of select="isisutils:setLastStepID('ADD_PROD_COMM', STEPID)"/>
        <xsl:element name="CcmFifAddProductCommitCmd">
            <xsl:element name="command_id">
                <xsl:text>add_prod_comm_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifAddProductCommitInCont">
                <xsl:element name="customer_number">
                    <xsl:value-of select="../../CUSTOMER_NUMBER"/>
                </xsl:element>
                <xsl:element name="contract_number">
                    <xsl:value-of select="../../CONTRACT_NUMBER"/>
                </xsl:element>
                <xsl:element name="product_code">
                    <xsl:value-of select="PRODUCT_CODE"/>
                </xsl:element>
                <xsl:element name="pricing_structure_code">
                    <xsl:value-of select="PRICING_STRUCTURE_CODE"/>
                </xsl:element>
                <xsl:element name="override_restriction">Y</xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Add Product Subscription -->
    <xsl:template match="ADD_PROD_SUBSCR/*">
        <xsl:value-of select="isisutils:setLastStepID('ADD_PROD_SUBSCR', STEPID)"/>
        <!-- Add Product Subscription Group, if needed -->
        <xsl:if test="(PRODUCT_GROUP_NAME != '') and (PRODUCT_GROUP_DESCRIPTION != '')">
            <!-- Get the root customer number -->
            <xsl:element name="CcmFifGetRootCustomerCmd">
                <xsl:element name="command_id">
                    <xsl:text>get_root_cust_</xsl:text><xsl:value-of select="STEPID"/>
                </xsl:element>
                <xsl:element name="override_system_date">
                    <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
                </xsl:element>
                <xsl:element name="CcmFifGetRootCustomerInCont">
                    <xsl:element name="customer_number">
                        <xsl:value-of select="../../CUSTOMER_NUMBER"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            <xsl:value-of select="isisutils:setLastStepID('ADD_PROD_SUBSCR_GRP', STEPID)"/>
            <!-- Add the product subscription group at the root customer level -->
            <xsl:element name="CcmFifCreateProdSubsGroupCmd">
                <xsl:element name="command_id">
                    <xsl:text>create_ps_group_</xsl:text><xsl:value-of select="STEPID"/>
                </xsl:element>
                <xsl:element name="override_system_date">
                    <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
                </xsl:element>
                <xsl:element name="CcmFifCreateProdSubsGroupInCont">
                    <xsl:element name="customer_number_ref">
                        <xsl:element name="command_id">
                            <xsl:text>get_root_cust_</xsl:text><xsl:value-of select="STEPID"/>
                        </xsl:element>
                        <xsl:element name="field_name">root_customer_number</xsl:element>
                    </xsl:element>
                    <xsl:element name="product_sub_group_name">
                        <xsl:value-of select="PRODUCT_GROUP_NAME"/>
                    </xsl:element>
                    <xsl:element name="product_sub_group_description">
                        <xsl:value-of select="PRODUCT_GROUP_DESCRIPTION"/>
                    </xsl:element>
                    <xsl:element name="effective_date">
                        <xsl:value-of select="EFFECTIVE_DATE"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:if>
        <!-- Lock the customer to avoid concurrent updates -->
        <xsl:element name="CcmFifLockCustomerCmd">
            <xsl:element name="command_id">
                <xsl:text>lock_customer_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifLockCustomerInCont">
                <xsl:element name="customer_number">
                    <xsl:value-of select="../../CUSTOMER_NUMBER"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        <!-- Add the product subscription -->
        <xsl:element name="CcmFifAddProductSubsCmd">
            <xsl:element name="command_id">
                <xsl:text>add_prod_subs_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifAddProductSubsInCont">
                <xsl:element name="customer_number">
                    <xsl:value-of select="../../CUSTOMER_NUMBER"/>
                </xsl:element>
                <xsl:element name="product_commitment_number_ref">
                    <xsl:element name="command_id">
                        <xsl:text>add_prod_comm_step_</xsl:text><xsl:value-of select="isisutils:getLastStepID('ADD_PROD_COMM')"/>
                    </xsl:element>
                    <xsl:element name="field_name">product_commitment_number</xsl:element>
                </xsl:element>
                <xsl:if test="(PRODUCT_GROUP_NAME != '') and (PRODUCT_GROUP_DESCRIPTION != '')">
                    <xsl:element name="product_subs_group_ref">
                        <xsl:element name="command_id">
                            <xsl:text>create_ps_group_</xsl:text><xsl:value-of select="isisutils:getLastStepID('ADD_PROD_SUBSCR_GRP')"/>
                        </xsl:element>
                        <xsl:element name="field_name">product_subs_group_id</xsl:element>
                    </xsl:element>
                </xsl:if>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Add Service Subscription -->
    <xsl:template match="ADD_SERV_SUBSCR/*">
        <xsl:value-of select="isisutils:setLastStepID('ADD_SERV_SUBSCR', STEPID)"/>
        <xsl:element name="CcmFifAddServiceSubsCmd">
            <xsl:element name="command_id">
                <xsl:text>add_serv_subs_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
                <xsl:element name="product_subscription_ref">
                    <xsl:element name="command_id">
                        <xsl:text>add_prod_subs_step_</xsl:text><xsl:value-of select="isisutils:getLastStepID('ADD_PROD_SUBSCR')"/>
                    </xsl:element>
                    <xsl:element name="field_name">product_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="service_code">
                    <xsl:value-of select="SERVICE_CODE"/>
                </xsl:element>
                <xsl:if test="PARENT_SERV_SUBSCR_STEPID != ''">
                    <xsl:element name="parent_service_subs_ref">
                        <xsl:element name="command_id">
                            <xsl:text>add_serv_subs_step_</xsl:text><xsl:value-of select="PARENT_SERV_SUBSCR_STEPID"/>
                        </xsl:element>
                        <xsl:element name="field_name">service_subscription_id</xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:element name="desired_date">
                    <xsl:value-of select="DESIRED_DATE"/>
                </xsl:element>
                <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                <xsl:element name="account_number">
                    <xsl:value-of select="../../ACCOUNT_NUMBER"/>
                </xsl:element>
                <xsl:element name="service_characteristic_list">
                    <xsl:if test="ACCESS_NUMBERS_USED = 'Y'">
                        <!-- Access Numbers -->
                        <xsl:for-each select="ACCESS_NUMBER/ACCESS_NUMBER_ROW">
                            <xsl:element name="CcmFifAccessNumberCont">
                                <xsl:element name="service_char_code">
                                    <xsl:value-of select="SERVICE_CHARACTERISTIC_CODE"/>
                                </xsl:element>
                                <xsl:element name="data_type">
                                    <xsl:value-of select="DATA_TYPE_RD"/>
                                </xsl:element>
                                <xsl:element name="masking_digits_rd">
                                    <xsl:value-of select="MASKING_DIGITS_RD"/>
                                </xsl:element>
                                <xsl:element name="retention_period_rd">
                                    <xsl:value-of select="RETENTION_PERIOD_RD"/>
                                </xsl:element>
                                <xsl:if test="DATA_TYPE_RD = 'MAIN_ACCESS_NUM'">
                                    <!-- Main Access -->
                                    <xsl:element name="country_code">49</xsl:element>
                                    <xsl:element name="city_code">
                                        <xsl:value-of select="CITY_CODE"/>
                                    </xsl:element>
                                    <xsl:element name="local_number">
                                        <xsl:value-of select="LOCAL_NUMBER"/>
                                    </xsl:element>
                                </xsl:if>
                                <xsl:if test="DATA_TYPE_RD = 'ACC_NUM_RANGE'">
                                    <!-- Access Number Range -->
                                    <xsl:element name="country_code">49</xsl:element>
                                    <xsl:element name="city_code">
                                        <xsl:value-of select="CITY_CODE"/>
                                    </xsl:element>
                                    <xsl:element name="local_number">
                                        <xsl:value-of select="LOCAL_NUMBER"/>
                                    </xsl:element>
                                    <xsl:element name="from_ext_num">
                                        <xsl:value-of select="FROM_EXT_NUMBER"/>
                                    </xsl:element>
                                    <xsl:element name="to_ext_num">
                                        <xsl:value-of select="TO_EXT_NUMBER"/>
                                    </xsl:element>
                                </xsl:if>
                                <xsl:if test="DATA_TYPE_RD = 'IP_NET_ADDRESS'">
                                    <!-- IP Address -->
                                    <xsl:element name="ip_number">
                                        <xsl:value-of select="ACCESS_NUMBER"/>
                                    </xsl:element>
                                </xsl:if>
                                <xsl:if test="DATA_TYPE_RD = 'USER_ACCOUNT_NUM'">
                                    <!-- User account -->
                                    <xsl:element name="network_account">
                                        <xsl:value-of select="ACCESS_NUMBER"/>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:if>

                    <xsl:if test="SERVICE_LOCATIONS_USED = 'Y'">
                        <!-- Service Locations -->
                        <xsl:for-each select="SERVICE_LOCATION/SERVICE_LOCATION_ROW">
                            <xsl:element name="CcmFifServiceLocationCont">
                                <xsl:element name="service_char_code">
                                    <xsl:value-of select="SERVICE_CHARACTERISTIC_CODE"/>
                                </xsl:element>
                                <xsl:element name="data_type">SERVICE_LOCATION</xsl:element>
                                <xsl:element name="floor">
                                    <xsl:value-of select="FLOOR"/>
                                </xsl:element>
                                <xsl:element name="room_number">
                                    <xsl:value-of select="ROOM_NUMBER"/>
                                </xsl:element>
                                <xsl:element name="jack_location">
                                    <xsl:value-of select="JACK_LOCATION"/>
                                </xsl:element>
                                <xsl:element name="desk_number">
                                    <xsl:value-of select="DESK_NUMBER"/>
                                </xsl:element>
                                <xsl:element name="additional_location_info">
                                    <xsl:value-of select="ADDITIONAL_LOCATION_INFO"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:if>

                    <xsl:if test="CONFIGURED_VALUES_USED = 'Y'">
                        <!-- Configured Values -->
                        <xsl:for-each select="CONFIGURED_VALUE/CONFIGURED_VALUE_ROW">
                            <xsl:element name="CcmFifConfiguredValueCont">
                                <xsl:element name="service_char_code">
                                    <xsl:value-of select="SERVICE_CHARACTERISTIC_CODE"/>
                                </xsl:element>
                                <xsl:element name="data_type">
                                    <xsl:value-of select="DATA_TYPE_RD"/>
                                </xsl:element>
                                <xsl:element name="configured_value">
                                    <xsl:value-of select="CONFIGURED_VALUE"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:if>

                    <xsl:if test="DIRECTORY_ENTRIES_USED = 'Y'">
                        <!-- Directory Entries -->
                        <xsl:for-each select="DIRECTORY_ENTRY/DIRECTORY_ENTRY_ROW">
                            <xsl:element name="CcmFifDirectoryEntryCont">
                                <xsl:element name="service_char_code">
                                    <xsl:value-of select="SERVICE_CHARACTERISTIC_CODE"/>
                                </xsl:element>
                                <xsl:element name="data_type">DIRECTORY_ENTRY</xsl:element>
                                <xsl:element name="type">
                                    <xsl:value-of select="TYPE_RD"/>
                                </xsl:element>
                                <xsl:element name="access_number">
                                    <xsl:value-of select="ACCESS_NUMBER"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:if>

                    <xsl:if test="ADDRESSES_USED = 'Y'">
                        <!-- Addresses -->
                        <xsl:for-each select="ADDRESS/ADDRESS_ROW">
                            <xsl:element name="CcmFifAddressCharacteristicCont">
                                <xsl:element name="service_char_code">
                                    <xsl:value-of select="SERVICE_CHARACTERISTIC_CODE"/>
                                </xsl:element>
                                <xsl:element name="data_type">ADDRESS</xsl:element>
                                <xsl:element name="address_id">
                                    <xsl:value-of select="../../../../ADDRESS_ID"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:element>
            </xsl:element>
        </xsl:element>

        <!-- Create the CO -->
        <xsl:element name="CcmFifCreateCustOrderCmd">
            <xsl:value-of select="isisutils:setLastStepID('CREATE_CO', STEPID)"/>
            <xsl:element name="command_id">
                <xsl:text>create_co_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifCreateCustOrderInCont">
                <xsl:element name="customer_number">
                    <xsl:value-of select="../../CUSTOMER_NUMBER"/>
                </xsl:element>
                <xsl:element name="service_ticket_pos_list">
                    <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">
                            <xsl:text>add_serv_subs_step_</xsl:text><xsl:value-of select="isisutils:getLastStepID('ADD_SERV_SUBSCR')"/>
                        </xsl:element>
                        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                    </xsl:element>
                </xsl:element>

            </xsl:element>
        </xsl:element>

        <!-- Check if we have to release the CO -->
        <xsl:if test="RELEASE_CUSTOMER_ORDER = 'Y'">
            <xsl:element name="CcmFifReleaseCustOrderCmd">
                <xsl:element name="command_id">
                    <xsl:text>release_co_step_</xsl:text><xsl:value-of select="STEPID"/>
                </xsl:element>
                <xsl:element name="override_system_date">
                    <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
                </xsl:element>
                <xsl:element name="CcmFifReleaseCustOrderInCont">
                    <xsl:element name="customer_number">
                        <xsl:value-of select="../../CUSTOMER_NUMBER"/>
                    </xsl:element>
                    <xsl:element name="customer_order_ref">
                        <xsl:element name="command_id">
                            <xsl:text>create_co_step_</xsl:text><xsl:value-of select="isisutils:getLastStepID('CREATE_CO')"/>
                        </xsl:element>
                        <xsl:element name="field_name">customer_order_id</xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:if>

    </xsl:template>

    <!-- Configure Price Plan -->
    <xsl:template match="CONFIG_PRICE_PLAN/*">
        <xsl:value-of select="isisutils:setLastStepID('CONFIG_PRICE_PLAN', STEPID)"/>
        <xsl:element name="CcmFifConfigurePPSCmd">
            <xsl:element name="command_id">
                <xsl:text>config_price_plan_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifConfigurePPSInCont">
                <xsl:element name="product_subscription_ref">
                    <xsl:element name="command_id">
                        <xsl:text>add_prod_subs_step_</xsl:text><xsl:value-of select="isisutils:getLastStepID('ADD_PROD_SUBSCR')"/>
                    </xsl:element>
                    <xsl:element name="field_name">product_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="price_plan_code">
                    <xsl:value-of select="PRICE_PLAN_CODE"/>
                </xsl:element>
                <xsl:element name="account_number">
                    <xsl:value-of select="../../ACCOUNT_NUMBER"/>
                </xsl:element>
                <xsl:element name="pps_option_value">
                    <xsl:value-of select="OPTION_VALUE_NAME"/>
                </xsl:element>
                <xsl:if test="count(SELECTED_DESTINATION/SELECTED_DESTINATION_ROW) != 0">
                    <xsl:element name="selected_destinations_list">
                        <!-- Selected Destinations -->
                        <xsl:for-each select="SELECTED_DESTINATION/SELECTED_DESTINATION_ROW">
                            <xsl:element name="CcmFifSelectedDestCont">
                                <xsl:element name="begin_number">
                                    <xsl:value-of select="BEGIN_NUMBER"/>
                                </xsl:element>
                                <xsl:element name="end_number">
                                    <xsl:value-of select="END_NUMBER"/>
                                </xsl:element>
                                <xsl:element name="start_date">
                                    <xsl:value-of select="START_DATE"/>
                                </xsl:element>
                                <xsl:element name="stop_date">
                                    <xsl:value-of select="STOP_DATE"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:if>
            </xsl:element>
        </xsl:element>

        <!-- Contributing Items -->
        <xsl:if test="count(CONTRIBUTING_ITEM/CONTRIBUTING_ITEM_ROW) != 0">
            <xsl:element name="CcmFifAddModifyContributingItemCmd">
                <xsl:element name="command_id">
                    <xsl:text>add_ci_for_pp</xsl:text><xsl:value-of select="STEPID"/>
                </xsl:element>
                <xsl:element name="override_system_date">
                    <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
                </xsl:element>
                <xsl:element name="CcmFifAddModifyContributingItemInCont">
                    <xsl:element name="product_subscription_ref">
                        <xsl:element name="command_id">
                            <xsl:text>add_prod_subs_step_</xsl:text><xsl:value-of select="isisutils:getLastStepID('ADD_PROD_SUBSCR')"/>
                        </xsl:element>
                        <xsl:element name="field_name">product_subscription_id</xsl:element>
                    </xsl:element>
                    <xsl:element name="price_plan_code">
                        <xsl:value-of select="PRICE_PLAN_CODE"/>
                    </xsl:element>
                    <xsl:element name="contributing_item_list">
                        <xsl:for-each select="CONTRIBUTING_ITEM/CONTRIBUTING_ITEM_ROW">
                            <xsl:element name="CcmFifContributingItem">
                                <xsl:if test="TYPE_RD = 'ACCOUNT'">
                                    <xsl:element name="supported_object_type_rd">ACCOUNT</xsl:element>
                                    <xsl:element name="start_date">
                                        <xsl:value-of select="START_DATE"/>
                                    </xsl:element>
                                    <xsl:element name="stop_date">
                                        <xsl:value-of select="STOP_DATE"/>
                                    </xsl:element>
                                    <xsl:element name="hierarchy_inclusion_indicator">
                                        <xsl:value-of select="HIERARCHY_INDICATOR"/>
                                    </xsl:element>
                                    <xsl:element name="account_number">
                                        <xsl:value-of select="CONTRIBUTING_ITEM_ID"/>
                                    </xsl:element>
                                </xsl:if>
                                <xsl:if test="TYPE_RD = 'CUSTOMER'">
                                    <xsl:element name="supported_object_type_rd">CUSTOMER</xsl:element>
                                    <xsl:element name="start_date">
                                        <xsl:value-of select="START_DATE"/>
                                    </xsl:element>
                                    <xsl:element name="stop_date">
                                        <xsl:value-of select="STOP_DATE"/>
                                    </xsl:element>
                                    <xsl:element name="hierarchy_inclusion_indicator">
                                        <xsl:value-of select="HIERARCHY_INDICATOR"/>
                                    </xsl:element>
                                    <xsl:element name="customer_number">
                                        <xsl:value-of select="CONTRIBUTING_ITEM_ID"/>
                                    </xsl:element>
                                </xsl:if>
                                <xsl:if test="TYPE_RD = 'PROD_GROUP'">
                                    <xsl:element name="supported_object_type_rd">PROD_GROUP</xsl:element>
                                    <xsl:element name="start_date">
                                        <xsl:value-of select="START_DATE"/>
                                    </xsl:element>
                                    <xsl:element name="stop_date">
                                        <xsl:value-of select="STOP_DATE"/>
                                    </xsl:element>
                                    <xsl:element name="hierarchy_inclusion_indicator">
                                        <xsl:value-of select="HIERARCHY_INDICATOR"/>
                                    </xsl:element>
                                    <xsl:element name="product_group_rd">
                                        <xsl:value-of select="CONTRIBUTING_ITEM_ID"/>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- Set state one service subscription -->
    <xsl:template match="SET_STATE_SERV_SUBSCR/*">
        <xsl:value-of select="isisutils:setLastStepID('SET_STATE_SERV_SUBSCR', STEPID)"/>
        <xsl:element name="CcmFifTermSuspReactServiceSubsCmd">
            <xsl:element name="command_id">
                <xsl:text>set_state_ss_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifTermSuspReactServiceSubsInCont">
            	<xsl:element name="service_subscription_ref">
            		<xsl:element name="command_id">
            			<xsl:text>add_serv_subs_step_</xsl:text><xsl:value-of select="PARENT_SERV_SUBSCR_STEPID"/>
            		</xsl:element>
            		<xsl:element name="field_name">service_subscription_id</xsl:element>
            	</xsl:element>
                <xsl:element name="usage_mode">
                    <xsl:value-of select="USAGE_MODE_VALUE_RD"/>
                </xsl:element>
                <xsl:element name="desired_date">
                    <xsl:value-of select="DESIRED_DATE"/>
                </xsl:element>
                <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                <xsl:element name="reason_rd">ISIS_MIGRATION</xsl:element>
            </xsl:element>
        </xsl:element>
        <!-- Create the CO -->
        <xsl:element name="CcmFifCreateCustOrderCmd">
            <xsl:element name="command_id">
            	<xsl:text>create_co_for_ssss_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifCreateCustOrderInCont">
                <xsl:element name="customer_number">
                    <xsl:value-of select="../../CUSTOMER_NUMBER"/>
                </xsl:element>
                <xsl:element name="service_ticket_pos_list_ref">
                    <xsl:element name="command_id">
                        <xsl:text>set_state_ss_step_</xsl:text><xsl:value-of select="STEPID"/>
                    </xsl:element>
                    <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        <!-- Release the CO -->
        <xsl:element name="CcmFifReleaseCustOrderCmd">
            <xsl:element name="command_id">
                <xsl:text>release_co_for_ssss_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifReleaseCustOrderInCont">
                <xsl:element name="customer_number">
                    <xsl:value-of select="../../CUSTOMER_NUMBER"/>
                </xsl:element>
                <xsl:element name="customer_order_ref">
                    <xsl:element name="command_id">
                        <xsl:text>create_co_for_ssss_step_</xsl:text><xsl:value-of select="STEPID"/>
                    </xsl:element>
                    <xsl:element name="field_name">customer_order_id</xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Reconfigure service subscription -->
    <xsl:template match="RECONFIG_SERV_SUBSCR/*">
        <xsl:value-of select="isisutils:setLastStepID('RECONFIG_SERV_SUBSCR', STEPID)"/>
        <xsl:element name="CcmFifReconfigServiceCmd">
            <xsl:element name="command_id">
                <xsl:text>reconf_serv_subs_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifReconfigServiceInCont">
                <xsl:element name="service_subscription_id">
                    <xsl:element name="command_id">
                        <xsl:text>add_serv_subs_step_</xsl:text><xsl:value-of select="isisutils:getLastStepID('ADD_SERV_SUBSCR')"/>
                    </xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="desired_date">
                    <xsl:value-of select="DESIRED_DATE"/>
                </xsl:element>
                <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                <xsl:element name="reason_rd">ISIS_MIGRATION</xsl:element>
                <xsl:element name="service_characteristic_list">
                    <xsl:if test="ACCESS_NUMBERS_USED = 'Y'">
                        <!-- Access Numbers -->
                        <xsl:for-each select="ACCESS_NUMBER/ACCESS_NUMBER_ROW">
                            <xsl:element name="CcmFifAccessNumberCont">
                                <xsl:element name="service_char_code">
                                    <xsl:value-of select="SERVICE_CHARACTERISTIC_CODE"/>
                                </xsl:element>
                                <xsl:element name="data_type">
                                    <xsl:value-of select="DATA_TYPE_RD"/>
                                </xsl:element>
                                <xsl:element name="masking_digits_rd">
                                    <xsl:value-of select="MASKING_DIGITS_RD"/>
                                </xsl:element>
                                <xsl:element name="retention_period_rd">
                                    <xsl:value-of select="RETENTION_PERIOD_RD"/>
                                </xsl:element>
                                <xsl:if test="DATA_TYPE_RD = 'MAIN_ACCESS_NUM'">
                                    <!-- Main Access -->
                                    <xsl:element name="country_code">49</xsl:element>
                                    <xsl:element name="city_code">
                                        <xsl:value-of select="CITY_CODE"/>
                                    </xsl:element>
                                    <xsl:element name="local_number">
                                        <xsl:value-of select="LOCAL_NUMBER"/>
                                    </xsl:element>
                                </xsl:if>
                                <xsl:if test="DATA_TYPE_RD = 'ACC_NUM_RANGE'">
                                    <!-- Access Number Range -->
                                    <xsl:element name="country_code">49</xsl:element>
                                    <xsl:element name="city_code">
                                        <xsl:value-of select="CITY_CODE"/>
                                    </xsl:element>
                                    <xsl:element name="local_number">
                                        <xsl:value-of select="LOCAL_NUMBER"/>
                                    </xsl:element>
                                    <xsl:element name="from_ext_num">
                                        <xsl:value-of select="FROM_EXT_NUMBER"/>
                                    </xsl:element>
                                    <xsl:element name="to_ext_num">
                                        <xsl:value-of select="TO_EXT_NUMBER"/>
                                    </xsl:element>
                                </xsl:if>
                                <xsl:if test="DATA_TYPE_RD = 'IP_NET_ADDRESS'">
                                    <!-- IP Address -->
                                    <xsl:element name="ip_number">
                                        <xsl:value-of select="ACCESS_NUMBER"/>
                                    </xsl:element>
                                </xsl:if>
                                <xsl:if test="DATA_TYPE_RD = 'USER_ACCOUNT_NUM'">
                                    <!-- User account -->
                                    <xsl:element name="network_account">
                                        <xsl:value-of select="ACCESS_NUMBER"/>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:if>

                    <xsl:if test="SERVICE_LOCATIONS_USED = 'Y'">
                        <!-- Service Locations -->
                        <xsl:for-each select="SERVICE_LOCATION/SERVICE_LOCATION_ROW">
                            <xsl:element name="CcmFifServiceLocationCont">
                                <xsl:element name="service_char_code">
                                    <xsl:value-of select="SERVICE_CHARACTERISTIC_CODE"/>
                                </xsl:element>
                                <xsl:element name="data_type">SERVICE_LOCATION</xsl:element>
                                <xsl:element name="floor">
                                    <xsl:value-of select="FLOOR"/>
                                </xsl:element>
                                <xsl:element name="room_number">
                                    <xsl:value-of select="ROOM_NUMBER"/>
                                </xsl:element>
                                <xsl:element name="jack_location">
                                    <xsl:value-of select="JACK_LOCATION"/>
                                </xsl:element>
                                <xsl:element name="desk_number">
                                    <xsl:value-of select="DESK_NUMBER"/>
                                </xsl:element>
                                <xsl:element name="additional_location_info">
                                    <xsl:value-of select="ADDITIONAL_LOCATION_INFO"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:if>

                    <xsl:if test="CONFIGURED_VALUES_USED = 'Y'">
                        <!-- Configured Values -->
                        <xsl:for-each select="CONFIGURED_VALUE/CONFIGURED_VALUE_ROW">
                            <xsl:element name="CcmFifConfiguredValueCont">
                                <xsl:element name="service_char_code">
                                    <xsl:value-of select="SERVICE_CHARACTERISTIC_CODE"/>
                                </xsl:element>
                                <xsl:element name="data_type">
                                    <xsl:value-of select="DATA_TYPE_RD"/>
                                </xsl:element>
                                <xsl:element name="configured_value">
                                    <xsl:value-of select="CONFIGURED_VALUE"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:if>

                    <xsl:if test="DIRECTORY_ENTRIES_USED = 'Y'">
                        <!-- Directory Entries -->
                        <xsl:for-each select="DIRECTORY_ENTRY/DIRECTORY_ENTRY_ROW">
                            <xsl:element name="CcmFifDirectoryEntryCont">
                                <xsl:element name="service_char_code">
                                    <xsl:value-of select="SERVICE_CHARACTERISTIC_CODE"/>
                                </xsl:element>
                                <xsl:element name="data_type">DIRECTORY_ENTRY</xsl:element>
                                <xsl:element name="type">
                                    <xsl:value-of select="TYPE_RD"/>
                                </xsl:element>
                                <xsl:element name="access_number">
                                    <xsl:value-of select="ACCESS_NUMBER"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:if>

                    <xsl:if test="ADDRESSES_USED = 'Y'">
                        <!-- Addresses -->
                        <xsl:for-each select="ADDRESS/ADDRESS_ROW">
                            <xsl:element name="CcmFifAddressCharacteristicCont">
                                <xsl:element name="service_char_code">
                                    <xsl:value-of select="SERVICE_CHARACTERISTIC_CODE"/>
                                </xsl:element>
                                <xsl:element name="data_type">ADDRESS</xsl:element>
                                <xsl:element name="address_id">
                                    <xsl:value-of select="../../../../ADDRESS_ID"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:element>
            </xsl:element>
        </xsl:element>

        <!-- Create the CO -->
        <xsl:element name="CcmFifCreateCustOrderCmd">
            <xsl:value-of select="isisutils:setLastStepID('CREATE_CO_RECONF_SERV_SUBSCR', STEPID)"/>
            <xsl:element name="command_id">
                <xsl:text>create_co_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifCreateCustOrderInCont">
                <xsl:element name="customer_number">
                    <xsl:value-of select="../../CUSTOMER_NUMBER"/>
                </xsl:element>
                <xsl:element name="service_ticket_pos_list">
                    <xsl:element name="CcmFifCommandRefCont">
                        <xsl:element name="command_id">
                            <xsl:text>reconf_serv_subs_step_</xsl:text><xsl:value-of select="isisutils:getLastStepID('RECONFIG_SERV_SUBSCR')"/>
                        </xsl:element>
                        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>

        <!-- Check if we have to release the CO -->
        <xsl:if test="RELEASE_CUSTOMER_ORDER = 'Y'">
            <xsl:element name="CcmFifReleaseCustOrderCmd">
                <xsl:element name="command_id">
                    <xsl:text>release_co_step_</xsl:text><xsl:value-of select="STEPID"/>
                </xsl:element>
                <xsl:element name="override_system_date">
                    <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
                </xsl:element>
                <xsl:element name="CcmFifReleaseCustOrderInCont">
                    <xsl:element name="customer_number">
                        <xsl:value-of select="../../CUSTOMER_NUMBER"/>
                    </xsl:element>
                    <xsl:element name="customer_order_ref">
                        <xsl:element name="command_id">
                            <xsl:text>create_co_step_</xsl:text><xsl:value-of select="isisutils:getLastStepID('CREATE_CO_RECONF_SERV_SUBSCR')"/>
                        </xsl:element>
                        <xsl:element name="field_name">customer_order_id</xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- Renegotiate Order Form  -->
    <xsl:template match="RENEGOTIATE_ORDER_FORM/*">
        <xsl:element name="CcmFifRenegotiateOrderFormCmd">
            <xsl:element name="command_id">
                <xsl:text>renegotiate_order_form_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifRenegotiateOrderFormInCont">
                <xsl:element name="contract_number">
                    <xsl:value-of select="../../CONTRACT_NUMBER"/>
                </xsl:element>
                <xsl:element name="currency_rd">EUR</xsl:element>
                <xsl:element name="language_rd">ger</xsl:element>
                <xsl:element name="loi_indicator">
                    <xsl:value-of select="LOI_INDICATOR"/>
                </xsl:element>
                <xsl:element name="notice_per_dur_value">
                    <xsl:value-of select="NOTICE_PERIOD_DUR_VALUE"/>
                </xsl:element>
                <xsl:element name="notice_per_dur_unit">
                    <xsl:value-of select="NOTICE_PERIOD_DUR_UNIT_RD"/>
                </xsl:element>
                <xsl:element name="min_per_dur_value">
                    <xsl:value-of select="MIN_PERIOD_DUR_VALUE"/>
                </xsl:element>
                <xsl:element name="min_per_dur_unit">
                    <xsl:value-of select="MIN_PERIOD_DUR_UNIT_RD"/>
                </xsl:element>
                <xsl:element name="monthly_order_entry_amount">
                    <xsl:value-of select="MONTHLY_ORDER_ENTRY_AMOUNT"/>
                </xsl:element>
                <xsl:element name="termination_restriction">
                    <xsl:value-of select="TERMINATION_RESTRICTION"/>
                </xsl:element>
                <xsl:element name="doc_template_name">Vertrag</xsl:element>
                <xsl:element name="assoc_skeleton_cont_num">
                    <xsl:value-of select="ASSOC_SKELETON_CONTRACT_NUMBER"/>
                </xsl:element>
                <xsl:element name="override_restriction">Y</xsl:element>
                <xsl:element name="product_commit_list">
                    <xsl:element name="CcmFifProductCommitCont">
                        <xsl:element name="old_product_code">
                            <xsl:value-of select="OLD_PRODUCT_CODE_1"/>
                        </xsl:element>
                        <xsl:element name="old_pricing_structure_code">
                            <xsl:value-of select="OLD_PRICING_STRUCT_CODE_1"/>
                        </xsl:element>
                        <xsl:element name="new_product_code">
                            <xsl:value-of select="NEW_PRODUCT_CODE_1"/>
                        </xsl:element>
                        <xsl:element name="new_pricing_structure_code">
                            <xsl:value-of select="NEW_PRICING_STRUCT_CODE_1"/>
                        </xsl:element>
                    </xsl:element>
                    <xsl:if test="OLD_PRODUCT_CODE_2 != ''">
                        <xsl:element name="CcmFifProductCommitCont">
                            <xsl:element name="old_product_code">
                                <xsl:value-of select="OLD_PRODUCT_CODE_2"/>
                            </xsl:element>
                            <xsl:element name="old_pricing_structure_code">
                                <xsl:value-of select="OLD_PRICING_STRUCT_CODE_2"/>
                            </xsl:element>
                            <xsl:element name="new_product_code">
                                <xsl:value-of select="NEW_PRODUCT_CODE_2"/>
                            </xsl:element>
                            <xsl:element name="new_pricing_structure_code">
                                <xsl:value-of select="NEW_PRICING_STRUCT_CODE_2"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="OLD_PRODUCT_CODE_3 != ''">
                        <xsl:element name="CcmFifProductCommitCont">
                            <xsl:element name="old_product_code">
                                <xsl:value-of select="OLD_PRODUCT_CODE_3"/>
                            </xsl:element>
                            <xsl:element name="old_pricing_structure_code">
                                <xsl:value-of select="OLD_PRICING_STRUCT_CODE_3"/>
                            </xsl:element>
                            <xsl:element name="new_product_code">
                                <xsl:value-of select="NEW_PRODUCT_CODE_3"/>
                            </xsl:element>
                            <xsl:element name="new_pricing_structure_code">
                                <xsl:value-of select="NEW_PRICING_STRUCT_CODE_3"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="OLD_PRODUCT_CODE_4 != ''">
                        <xsl:element name="CcmFifProductCommitCont">
                            <xsl:element name="old_product_code">
                                <xsl:value-of select="OLD_PRODUCT_CODE_4"/>
                            </xsl:element>
                            <xsl:element name="old_pricing_structure_code">
                                <xsl:value-of select="OLD_PRICING_STRUCT_CODE_4"/>
                            </xsl:element>
                            <xsl:element name="new_product_code">
                                <xsl:value-of select="NEW_PRODUCT_CODE_4"/>
                            </xsl:element>
                            <xsl:element name="new_pricing_structure_code">
                                <xsl:value-of select="NEW_PRICING_STRUCT_CODE_4"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="OLD_PRODUCT_CODE_5 != ''">
                        <xsl:element name="CcmFifProductCommitCont">
                            <xsl:element name="old_product_code">
                                <xsl:value-of select="OLD_PRODUCT_CODE_5"/>
                            </xsl:element>
                            <xsl:element name="old_pricing_structure_code">
                                <xsl:value-of select="OLD_PRICING_STRUCT_CODE_5"/>
                            </xsl:element>
                            <xsl:element name="new_product_code">
                                <xsl:value-of select="NEW_PRODUCT_CODE_5"/>
                            </xsl:element>
                            <xsl:element name="new_pricing_structure_code">
                                <xsl:value-of select="NEW_PRICING_STRUCT_CODE_5"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        <!-- Modify the commissioning information -->
        <xsl:element name="CcmFifModifyCommissionInfoCmd">
            <xsl:element name="command_id">
                <xsl:text>modify_comm_info_step</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifModifyCommissionInfoInCont">
                <xsl:element name="supported_object_id">
                    <xsl:value-of select="../../CONTRACT_NUMBER"/>
                </xsl:element>
                <xsl:element name="supported_object_type_rd">O</xsl:element>
                <xsl:element name="cio_type_rd">Initial CIO</xsl:element>
                <xsl:element name="cio_data">
                    <xsl:value-of select="SALES_ORG_NUMBER_VALUE"/>
                </xsl:element>
                <xsl:element name="change_reason_rd">Correction</xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Sign Order Form -->
    <xsl:template match="SIGN_ORDER_FORM/*">
        <xsl:element name="CcmFifSignOrderFormCmd">
            <xsl:element name="command_id">
                <xsl:text>sign_order_form_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifSignOrderFormInCont">
                <xsl:element name="contract_number">
                    <xsl:value-of select="../../CONTRACT_NUMBER"/>
                </xsl:element>
                <xsl:element name="board_sign_name">
                    <xsl:value-of select="BOARD_SIGN_NAME"/>
                </xsl:element>
                <xsl:element name="board_sign_date">
                    <xsl:value-of select="BOARD_SIGN_DATE"/>
                </xsl:element>
                <xsl:element name="primary_cust_sign_name">
                    <xsl:value-of select="PRIMARY_CUST_SIGN_NAME"/>
                </xsl:element>
                <xsl:element name="primary_cust_sign_date">
                    <xsl:value-of select="PRIMARY_CUST_SIGN_DATE"/>
                </xsl:element>
                <xsl:element name="secondary_cust_sign_name">
                    <xsl:value-of select="SECONDARY_CUST_SIGN_NAME"/>
                </xsl:element>
                <xsl:element name="secondary_cust_sign_date">
                    <xsl:value-of select="SECONDARY_CUST_SIGN_DATE"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        <!-- Apply the new pricing structures -->
        <xsl:element name="CcmFifApplyNewPricingStructCmd">
            <xsl:element name="command_id">
                <xsl:text>apply_new_ps_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifApplyNewPricingStructInCont">
                <xsl:element name="supported_object_id">
                    <xsl:value-of select="../../CONTRACT_NUMBER"/>
                </xsl:element>
                <xsl:element name="supported_object_type_rd">O</xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Terminate Order Form -->
    <xsl:template match="TERMINATE_ORDER_FORM/*">
        <!-- Set the termination date -->
        <xsl:element name="CcmFifTerminateOrderFormCmd">
            <xsl:element name="command_id">
                <xsl:text>terminate_order_form_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifTerminateOrderFormInCont">
                <xsl:element name="contract_number">
                    <xsl:value-of select="../../CONTRACT_NUMBER"/>
                </xsl:element>
                <xsl:element name="termination_date">
                    <xsl:value-of select="EFFECTIVE_DATE"/>
                </xsl:element>
                <xsl:element name="override_restriction">Y</xsl:element>
            </xsl:element>
        </xsl:element>
        <!-- Batch terminate it -->
        <xsl:element name="CcmFifTermOrderFormTransCmd">
            <xsl:element name="command_id">
                <xsl:text>batch_terminate_order_form_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifTermOrderFormTransInCont">
                <xsl:element name="contract_number">
                    <xsl:value-of select="../../CONTRACT_NUMBER"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        <!-- Terminate the Price Plans -->
        <xsl:element name="CcmFifTermPricePlansForContractCmd">
			<xsl:element name="command_id">
                <xsl:text>term_price_plan_for_contract_step_</xsl:text><xsl:value-of select="STEPID"/>
            </xsl:element>	
            <xsl:element name="override_system_date">
                <xsl:value-of select="isisutils:getOffSetDate(EFFECTIVE_DATE)"/>
            </xsl:element>
            <xsl:element name="CcmFifTermPricePlansForContractInCont">
                <xsl:element name="contract_number">
                    <xsl:value-of select="../../CONTRACT_NUMBER"/>
                </xsl:element>
            </xsl:element>            
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>    
