<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
    XSLT file for  adding selected destination FIF request
    
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

            <!-- Find Price Plan -->      
            <xsl:element name="CcmFifFindPricePlanSubsCmd">
                <xsl:element name="command_id">find_pps_1</xsl:element>
                <xsl:element name="CcmFifFindPricePlanSubsInCont">
                    <xsl:element name="product_subscription_id">
                        <xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
                    </xsl:element>  
                    <xsl:element name="effective_date">
                        <xsl:value-of select="request-param[@name='START_DATE']"/>
                    </xsl:element>                  
                    <xsl:element name="selected_destination_ind">Y</xsl:element>
                </xsl:element>
            </xsl:element>
                      
            <!-- Configure Price Plan -->
            <xsl:element name="CcmFifConfigurePPSCmd">
                <xsl:element name="command_id">config_pps_1</xsl:element>
                <xsl:element name="CcmFifConfigurePPSInCont">
                    <xsl:element name="price_plan_subs_list_ref">
                        <xsl:element name="command_id">find_pps_1</xsl:element>
                        <xsl:element name="field_name">price_plan_subs_list</xsl:element>
                    </xsl:element>
                    <xsl:variable name="StartDate" select="request-param[@name='START_DATE']"/>
                    <xsl:if
                        test="count(request-param-list[@name='SELECTED_DESTINATIONS_LIST']/request-param-list-item) != 0">
                        <xsl:element name="selected_destinations_list">
                            <!-- Selected Destinations -->
                            <xsl:for-each
                                select="request-param-list[@name='SELECTED_DESTINATIONS_LIST']/request-param-list-item">
                                <xsl:element name="CcmFifSelectedDestCont">
                                    <xsl:element name="begin_number">
                                        <xsl:value-of select="request-param[@name='BEGIN_NUMBER']"/>
                                    </xsl:element>
                                    <xsl:element name="start_date">
                                        <xsl:value-of select="$StartDate"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:for-each>
                        </xsl:element>
                    </xsl:if>
                </xsl:element>
            </xsl:element>
  
            <!-- Create Contact-->
            <xsl:element name="CcmFifCreateContactCmd">
                <xsl:element name="command_id">create_contact_1</xsl:element>
                <xsl:element name="CcmFifCreateContactInCont">
                    <xsl:element name="customer_number">
                        <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
                    </xsl:element>
                    <xsl:element name="contact_type_rd">INFO</xsl:element>
                    <xsl:element name="caller_name">SYSTEM</xsl:element>
                    <xsl:element name="caller_phone_number">SYSTEM</xsl:element>
                    <xsl:element name="author_name">
                        <xsl:value-of select="request-param[@name='USER_NAME']"/>
                    </xsl:element>
                    <xsl:element name="short_description">Changing selected dest.</xsl:element>
                    <xsl:element name="long_description_text">Changing selected destinations.</xsl:element>           
                </xsl:element>
            </xsl:element>
                      
                                  
            
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
