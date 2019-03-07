<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
    XSLT file for writing to External Notification
    
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
        <xsl:element name="Command_List">
            
    		<xsl:element name="CcmFifValidateGeneralCodeItemCmd">
    			<xsl:element name="command_id">validate_service_code_1</xsl:element>
    			<xsl:element name="CcmFifValidateGeneralCodeItemInCont">
    				<xsl:element name="group_code">SALEORGNUM</xsl:element>
    				<xsl:element name="value">
                    	<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
    				</xsl:element>
    				<xsl:element name="raise_error_if_invalid">Y</xsl:element>
    			</xsl:element>
    		</xsl:element>
    	
            <xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
                <xsl:element name="CcmFifFindServiceSubsCmd">
                    <xsl:element name="command_id">find_service_1</xsl:element>
                    <xsl:element name="CcmFifFindServiceSubsInCont">
                        <xsl:element name="service_subscription_id">
                            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            
            <xsl:if test="request-param[@name='serviceSubscriptionId'] = ''">
                <xsl:element name="CcmFifReadExternalNotificationCmd">
                    <xsl:element name="command_id">read_external_notification_1</xsl:element>
                    <xsl:element name="CcmFifReadExternalNotificationInCont">
                        <xsl:element name="transaction_id">
                            <xsl:value-of select="request-param[@name='requestListId']"/>
                        </xsl:element>
                        <xsl:element name="parameter_name">
                            <xsl:choose>
                                <xsl:when test="request-param[@name='voiceFunctionID'] != ''">
                                    <xsl:value-of select="request-param[@name='voiceFunctionID']"/>
                                    <xsl:text>_SERVICE_SUBSCRIPTION_ID</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>VOICE_SERVICE_SUBSCRIPTION_ID</xsl:otherwise>
                            </xsl:choose>                            
                        </xsl:element>
                    </xsl:element>
                </xsl:element>                

                <xsl:element name="CcmFifFindServiceSubsCmd">
                    <xsl:element name="command_id">find_service_1</xsl:element>
                    <xsl:element name="CcmFifFindServiceSubsInCont">
                        <xsl:element name="service_subscription_id_ref">
                            <xsl:element name="command_id">read_external_notification_1</xsl:element>
                            <xsl:element name="field_name">parameter_value</xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
 
            <xsl:element name="CcmFifFindServiceTicketPositionCmd">
                <xsl:element name="command_id">find_stp_1</xsl:element>
                <xsl:element name="CcmFifFindServiceTicketPositionInCont">
                    <xsl:element name="customer_number_ref">
                        <xsl:element name="command_id">find_service_1</xsl:element>
                        <xsl:element name="field_name">customer_number</xsl:element>
                    </xsl:element>
                    <xsl:element name="service_subscription_id_ref">
                        <xsl:element name="command_id">find_service_1</xsl:element>
                        <xsl:element name="field_name">service_subscription_id</xsl:element>
                    </xsl:element>
                    <xsl:element name="no_stp_error">N</xsl:element>
                    <xsl:element name="find_stp_parameters">
                        <xsl:element name="CcmFifFindStpParameterCont">
                            <xsl:element name="usage_mode_value_rd">2</xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifFindStpParameterCont">
                            <xsl:element name="usage_mode_value_rd">1</xsl:element>
                        </xsl:element>
                    </xsl:element>                    
                </xsl:element>
            </xsl:element>
            
            <xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
                <xsl:element name="command_id">get_stp_data_1</xsl:element>
                <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
                    <xsl:element name="service_ticket_position_id_ref">
                        <xsl:element name="command_id">find_stp_1</xsl:element>
                        <xsl:element name="field_name">service_ticket_position_id</xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            
            <xsl:element name="CcmFifGetCustomerOrderDataCmd">
                <xsl:element name="command_id">get_co_data_1</xsl:element>
                <xsl:element name="CcmFifGetCustomerOrderDataInCont">
                    <xsl:element name="customer_order_id_ref">
                        <xsl:element name="command_id">get_stp_data_1</xsl:element>
                        <xsl:element name="field_name">customer_order_id</xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>                    
            
            <xsl:if test="request-param[@name='clientName'] = 'CODB'">
                <xsl:element name="CcmFifConcatStringsCmd">
                    <xsl:element name="command_id">getPTN</xsl:element>
                    <xsl:element name="CcmFifConcatStringsInCont">
                        <xsl:element name="input_string_list">
                            <xsl:element name="CcmFifPassingValueCont">
                                <xsl:element name="value">003i</xsl:element>							
                            </xsl:element>                
                        </xsl:element>
                    </xsl:element>
                </xsl:element>      
            </xsl:if>
            
            <!-- Create POS notification  -->
            <xsl:element name="CcmFifCreateExternalNotificationCmd">
                <xsl:element name="command_id">create_pos_notification_1</xsl:element>
                <xsl:element name="CcmFifCreateExternalNotificationInCont">
                    <xsl:element name="notification_action_name">CreateOnlineAccount</xsl:element>
                    <xsl:element name="target_system">POS</xsl:element>
                    <xsl:element name="parameter_value_list">
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                            <xsl:element name="parameter_value_ref">
                                <xsl:element name="command_id">find_service_1</xsl:element>
                                <xsl:element name="field_name">customer_number</xsl:element>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">DESIRED_DATE</xsl:element>
                            <xsl:element name="parameter_value">
                                <xsl:value-of select="request-param[@name='dueDate']"/>                            
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">CUSTOMER_ORDER_ID</xsl:element>
                            <xsl:element name="parameter_value_ref">
                                <xsl:element name="command_id">get_stp_data_1</xsl:element>
                                <xsl:element name="field_name">customer_order_id</xsl:element>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">BARCODE</xsl:element>
                            <xsl:if test="request-param[@name='OMTSOrderID'] != ''">
                                <xsl:element name="parameter_value">
                                    <xsl:value-of select="request-param[@name='OMTSOrderID']"/>                            
                                </xsl:element>
                            </xsl:if>
                            <xsl:if test="request-param[@name='OMTSOrderID'] = ''">
                                <xsl:element name="parameter_value_ref">
                                    <xsl:element name="command_id">get_co_data_1</xsl:element>
                                    <xsl:element name="field_name">customer_tracking_id</xsl:element>
                                </xsl:element>
                            </xsl:if>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">SERVICE_SUBSCRIPTION</xsl:element>
                            <xsl:element name="parameter_value_ref">
                                <xsl:element name="command_id">find_service_1</xsl:element>
                                <xsl:element name="field_name">service_subscription_id</xsl:element>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">REASON_RD</xsl:element>
                            <xsl:choose>
                                <xsl:when test="request-param[@name='reasonRd'] != ''">
                                    <xsl:element name="parameter_value">
                                        <xsl:value-of select="request-param[@name='reasonRd']"/>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="request-param[@name='technologyChangeIndicator'] != 'Y'">
                                        <xsl:element name="parameter_value">CREATE_ONL</xsl:element>
                                    </xsl:if>
                                    <xsl:if test="request-param[@name='technologyChangeIndicator'] = 'Y'">
                                        <xsl:element name="parameter_value">CREATE_ONL_TC</xsl:element>
                                    </xsl:if>          
                                </xsl:otherwise>                  
                            </xsl:choose>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">MIN_PERIOD_DUR_VALUE</xsl:element>
                            <xsl:element name="parameter_value">
                                <xsl:value-of select="request-param[@name='minPeriodDurationValue']"/>                            
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">MIN_PERIOD_DUR_UNIT_RD</xsl:element>
                            <xsl:element name="parameter_value">
                                <xsl:value-of select="request-param[@name='minPeriodDurationUnit']"/>                            
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">PRODUCT_CODE</xsl:element>
                            <xsl:element name="parameter_value">
                                <xsl:value-of select="request-param[@name='productCode']"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">PRODUCT_VERSION</xsl:element>
                            <xsl:element name="parameter_value">
                                <xsl:value-of select="request-param[@name='productVersionCode']"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">ONLINE_TARIFF</xsl:element>
                            <xsl:element name="parameter_value">
                                <xsl:value-of select="request-param[@name='tariffOnline']"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">SALES_ORGANISATION_NUMBER</xsl:element>
                            <xsl:element name="parameter_value">
                                <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:if test="request-param[@name='skeletonContractNumber'] != ''">
                            <xsl:element name="CcmFifParameterValueCont">
                                <xsl:element name="parameter_name">SKELETON_CONTRACT_NUMBER</xsl:element>
                                <xsl:element name="parameter_value">
                                    <xsl:value-of select="request-param[@name='skeletonContractNumber']"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:if>
                        <xsl:if test="request-param[@name='salesOrganisationNumberVF'] != ''">
                            <xsl:element name="CcmFifParameterValueCont">
                                <xsl:element name="parameter_name">SALES_ORGANISATION_NUMBER_VF</xsl:element>
                                <xsl:element name="parameter_value">
                                    <xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:if>
                        <!-- noticePeriod is functionally irrelevant, a dummy value is therefore populated -->
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">NOTICE_PERIOD_DUR_VALUE</xsl:element>
                            <xsl:element name="parameter_value">1</xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
