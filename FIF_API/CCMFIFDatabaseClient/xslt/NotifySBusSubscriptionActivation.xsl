<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for sending service bus notification 
	
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
                test="dateutils:matchPattern('[a-z,A-Z]{3}[0-9]{10}', request-param[@name='OMTSOrderID']) != 'Y'">
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

            <xsl:if test="dateutils:matchPattern('[a-z,A-Z]{3}[0-9]{10}', request-param[@name='OMTSOrderID']) = 'Y'">
                
                <!-- lock customer to avoid concurrency problems -->
                <xsl:element name="CcmFifLockObjectCmd">
                    <xsl:element name="CcmFifLockObjectInCont">
                        <xsl:element name="object_id">
                            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
                        </xsl:element>
                        <xsl:element name="object_type">CUSTOMER</xsl:element>
                    </xsl:element>
                </xsl:element>                      
                                
                <xsl:element name="CcmFifFindExternalOrderCmd">
                    <xsl:element name="command_id">find_external_order</xsl:element>
                    <xsl:element name="CcmFifFindExternalOrderInCont">
                        <xsl:element name="barcode">
                            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                        </xsl:element>
                        <xsl:element name="double_search_ind">Y</xsl:element>
                    </xsl:element>
                </xsl:element>                    
                
                <!-- check if all activation stps are created -->
                <xsl:element name="CcmFifFindServiceTicketPositionCmd">
                    <xsl:element name="command_id">find_open_stp_1</xsl:element>
                    <xsl:element name="CcmFifFindServiceTicketPositionInCont">
                        <xsl:element name="customer_tracking_id">
                            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                        </xsl:element>       
                        <xsl:element name="order_position_number">
                            <xsl:value-of select="request-param[@name='COM_ORDER_POSITION_NUMBER']"/>
                        </xsl:element>   
                        <xsl:element name="no_stp_error">N</xsl:element>
                        <xsl:element name="find_stp_parameters">
                            <xsl:element name="CcmFifFindStpParameterCont">
                                <xsl:element name="customer_order_state">RELEASED</xsl:element>
                            </xsl:element>
                            <xsl:element name="CcmFifFindStpParameterCont">
                                <xsl:element name="customer_order_state">DEFINED</xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>

                <xsl:if test="request-param[@name='REASON_RD'] = 'PROVIDER_CHANGE' or request-param[@name='REASON_RD'] = 'TAKEOVERCONTRACT'">          
                <!-- find termination bar code -->
                <xsl:element name="CcmFifGetProviderChangeLogCmd">
                    <xsl:element name="command_id">get_provider_change_log_1</xsl:element>
                    <xsl:element name="CcmFifGetProviderChangeLogInCont">
                        <xsl:element name="act_bar_code">
                            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                        </xsl:element>                                               
                        <xsl:element name="process_ind_ref">
                            <xsl:element name="command_id">find_open_stp_1</xsl:element>
                            <xsl:element name="field_name">stp_found</xsl:element>
                        </xsl:element>
                        <xsl:element name="required_process_ind">N</xsl:element>
                        <xsl:element name="lock_object">Y</xsl:element>
                    </xsl:element>
                </xsl:element>
 
                <!-- check if all termination stps are activated -->
                <xsl:element name="CcmFifFindServiceTicketPositionCmd">
                    <xsl:element name="command_id">find_open_stp_2</xsl:element>
                    <xsl:element name="CcmFifFindServiceTicketPositionInCont">
                        <xsl:element name="customer_tracking_id_ref">
                            <xsl:element name="command_id">get_provider_change_log_1</xsl:element>
                            <xsl:element name="field_name">term_bar_code</xsl:element>                        
                        </xsl:element>                                     
                        <xsl:element name="no_stp_error">N</xsl:element>
                        <xsl:element name="find_stp_parameters">
                            <xsl:element name="CcmFifFindStpParameterCont">
                                <xsl:element name="customer_order_state">RELEASED</xsl:element>
                            </xsl:element>
                            <xsl:element name="CcmFifFindStpParameterCont">
                                <xsl:element name="customer_order_state">DEFINED</xsl:element>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="process_ind_ref">
                            <xsl:element name="command_id">get_provider_change_log_1</xsl:element>
                            <xsl:element name="field_name">entry_found</xsl:element>
                        </xsl:element>
                        <xsl:element name="required_process_ind">Y</xsl:element>
                    </xsl:element>
                </xsl:element>


                <!-- check if for corresponding barcode notification will be sent -->
                <xsl:element name="CcmFifValidateAnotherCcmFifTransactionExistsCmd">
                        <xsl:element name="command_id">validate_another_ccm_fif_trans_exists_1</xsl:element>
                        <xsl:element name="CcmFifValidateAnotherCcmFifTransactionExistsInCont">
                            <xsl:element name="bar_code_ref">
                                <xsl:element name="command_id">get_provider_change_log_1</xsl:element>
                                <xsl:element name="field_name">term_bar_code</xsl:element>                        
                            </xsl:element>         
                            <xsl:element name="action_name">notifySBusSubscriptionTermination</xsl:element> 
                            <xsl:element name="status">
                                <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>'FAILED','IN_PROGRESS','NOT_STARTED','ON_HOLD'<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>                             
                            </xsl:element>                            
                            <xsl:element name="process_ind_ref">
                                <xsl:element name="command_id">find_open_stp_2</xsl:element>
                                <xsl:element name="field_name">stp_found</xsl:element>
                            </xsl:element>
                            <xsl:element name="required_process_ind">N</xsl:element>
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
                                <xsl:element name="parameter_value">SUCCESS</xsl:element>
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
                            <xsl:if test="request-param[@name='COM_ORDER_POSITION_NUMBER'] != ''"> 
                                <xsl:element name="CcmFifParameterValueCont">
                                    <xsl:element name="parameter_name">AuftragPositionNummer</xsl:element>
                                    <xsl:element name="parameter_value">
                                        <xsl:value-of select="request-param[@name='COM_ORDER_POSITION_NUMBER']"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>     
                        </xsl:element>
                        <xsl:element name="process_ind_ref">
                            <xsl:element name="command_id">validate_another_ccm_fif_trans_exists_1</xsl:element>
                            <xsl:element name="field_name">another_transaction_exists</xsl:element>
                        </xsl:element>
                        <xsl:element name="required_process_ind">N</xsl:element>
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
                        <xsl:element name="short_description">COM Benachrichtigung (Act)</xsl:element>
                        <xsl:element name="long_description_text">
                            <xsl:text>Benachrichtigung an COM gesendet für Barcode </xsl:text>
                            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                            <xsl:text> und für Auftragpositionnummer </xsl:text>
                            <xsl:value-of select="request-param[@name='COM_ORDER_POSITION_NUMBER']"/>
                        </xsl:element>
                        <xsl:element name="process_ind_ref">
                            <xsl:element name="command_id">find_open_stp_2</xsl:element>
                            <xsl:element name="field_name">stp_found</xsl:element>
                        </xsl:element>
                        <xsl:element name="required_process_ind">N</xsl:element>
                    </xsl:element>
                </xsl:element>
                </xsl:if>
                
                <xsl:if test="request-param[@name='REASON_RD'] != 'PROVIDER_CHANGE' and request-param[@name='REASON_RD'] != 'TAKEOVERCONTRACT'">  
                    <!-- Validate Future Dated Apply Exists -->
                    <xsl:element name="CcmFifValidateFutureDatedApplyExistsCmd">
                        <xsl:element name="command_id">validate_future_apply_1</xsl:element>
                        <xsl:element name="CcmFifValidateFutureDatedApplyExistsInCont">
                            <xsl:element name="bar_code">
                                <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                            </xsl:element>
                            <xsl:element name="check_multiple_requests">Y</xsl:element>
                            <xsl:element name="process_ind_ref">
                                <xsl:element name="command_id">find_open_stp_1</xsl:element>
                                <xsl:element name="field_name">stp_found</xsl:element>
                            </xsl:element>
                            <xsl:element name="required_process_ind">N</xsl:element>
                        </xsl:element>
                    </xsl:element>
                    
                    <xsl:element name="CcmFifConcatStringsCmd">
                        <xsl:element name="command_id">concat_validate_sbus_action</xsl:element>
                        <xsl:element name="CcmFifConcatStringsInCont">
                            <xsl:element name="input_string_list">
                                <xsl:element name="CcmFifCommandRefCont">
                                    <xsl:element name="command_id">find_open_stp_1</xsl:element>
                                    <xsl:element name="field_name">stp_found</xsl:element>
                                </xsl:element>
                                <xsl:element name="CcmFifPassingValueCont">
                                    <xsl:element name="value">;</xsl:element>							
                                </xsl:element>
                                <xsl:element name="CcmFifCommandRefCont">
                                    <xsl:element name="command_id">validate_future_apply_1</xsl:element>
                                    <xsl:element name="field_name">future_dated_apply_exists</xsl:element>
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifMapStringCmd">
                        <xsl:element name="command_id">map_validate_sbus_action</xsl:element>
                        <xsl:element name="CcmFifMapStringInCont">
                            <xsl:element name="input_string_type">[Y,N];[Y,N]</xsl:element>
                            <xsl:element name="input_string_ref">
                                <xsl:element name="command_id">concat_validate_sbus_action</xsl:element>
                                <xsl:element name="field_name">output_string</xsl:element>
                            </xsl:element>
                            <xsl:element name="output_string_type">action_performed_ind</xsl:element>
                            <xsl:element name="string_mapping_list">
                                <xsl:element name="CcmFifStringMappingCont">
                                    <xsl:element name="input_string">N;N</xsl:element>
                                    <xsl:element name="output_string">Y</xsl:element>								
                                </xsl:element>
                                
                            </xsl:element>
                            <xsl:element name="no_mapping_error">N</xsl:element>
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
                                <xsl:element name="parameter_value">SUCCESS</xsl:element>
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
                            <xsl:if test="request-param[@name='COM_ORDER_POSITION_NUMBER'] != ''"> 
                                <xsl:element name="CcmFifParameterValueCont">
                                    <xsl:element name="parameter_name">AuftragPositionNummer</xsl:element>
                                    <xsl:element name="parameter_value">
                                        <xsl:value-of select="request-param[@name='COM_ORDER_POSITION_NUMBER']"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>     
                        </xsl:element>
                        <xsl:element name="process_ind_ref">
                            <xsl:element name="command_id">map_validate_sbus_action</xsl:element>
                            <xsl:element name="field_name">output_string</xsl:element>
                        </xsl:element>
                        <xsl:element name="required_process_ind">Y</xsl:element>
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
                        <xsl:element name="short_description">COM Benachrichtigung (Act)</xsl:element>
                        <xsl:element name="long_description_text">
                            <xsl:text>Benachrichtigung an COM gesendet für Barcode </xsl:text>
                            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
                            <xsl:text> und für Auftragpositionnummer </xsl:text>
                            <xsl:value-of select="request-param[@name='COM_ORDER_POSITION_NUMBER']"/>
                        </xsl:element>
                        <xsl:element name="process_ind_ref">
                            <xsl:element name="command_id">map_validate_sbus_action</xsl:element>
                            <xsl:element name="field_name">output_string</xsl:element>
                        </xsl:element>
                        <xsl:element name="required_process_ind">Y</xsl:element>
                    </xsl:element>
                </xsl:element>
                </xsl:if> 
                
            </xsl:if>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
