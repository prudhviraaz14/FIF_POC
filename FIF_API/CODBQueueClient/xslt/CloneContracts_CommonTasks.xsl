<!-- Find service Subs for given  service subscription id-->
<xsl:element name="CcmFifFindServiceSubsCmd">
    <xsl:element name="command_id">find_service_1</xsl:element>
    <xsl:element name="CcmFifFindServiceSubsInCont">          
        <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
        </xsl:element>
    </xsl:element>
</xsl:element>

<!-- Remove DEACT record for purchased services if any -->
<xsl:element name="CcmFifRemoveDeactCSCsForPurchasedServiceCmd">
    <xsl:element name="command_id">remove_deact_cscs_1</xsl:element>
    <xsl:element name="CcmFifRemoveDeactCSCsForPurchasedServiceInCont">
        <xsl:element name="product_subscription_id_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
        </xsl:element>
    </xsl:element>
</xsl:element>

<!-- find directory entry stp -->
<xsl:element name="CcmFifFindServiceTicketPositionCmd">
    <xsl:element name="command_id">find_directory_entry</xsl:element>
    <xsl:element name="CcmFifFindServiceTicketPositionInCont">
        <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
        </xsl:element>
        <xsl:element name="no_stp_error">N</xsl:element>
        <xsl:element name="find_stp_parameters">
            <xsl:element name="CcmFifFindStpParameterCont">
                <xsl:element name="service_code">V0100</xsl:element>
                <xsl:element name="usage_mode_value_rd">1</xsl:element>
                <xsl:element name="customer_order_state">RELEASED</xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:element>
</xsl:element>

<!-- get data from STP -->
<xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
    <xsl:element name="command_id">get_directory_entry_stp_data</xsl:element>
    <xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
        <xsl:element name="service_ticket_position_id_ref">
            <xsl:element name="command_id">find_directory_entry</xsl:element>
            <xsl:element name="field_name">service_ticket_position_id</xsl:element>
        </xsl:element>
        <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_directory_entry</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>							
        </xsl:element>
        <xsl:element name="required_process_ind">Y</xsl:element>
    </xsl:element>
</xsl:element>							

<!-- cancel the service in OPM -->
<xsl:element name="CcmFifCancelCustomerOrderCmd">
    <xsl:element name="command_id">cancel_directory_entry</xsl:element>
    <xsl:element name="CcmFifCancelCustomerOrderInCont">
        <xsl:element name="customer_order_id_ref">
            <xsl:element name="command_id">get_directory_entry_stp_data</xsl:element>
            <xsl:element name="field_name">customer_order_id</xsl:element>            
        </xsl:element>
        <xsl:element name="cancel_reason_rd">UMZ</xsl:element>
        <xsl:element name="cancel_opm_order_ind">Y</xsl:element>
        <xsl:element name="skip_already_processed">Y</xsl:element>
        <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_directory_entry</xsl:element>
            <xsl:element name="field_name">stp_found</xsl:element>							
        </xsl:element>          
        <xsl:element name="required_process_ind">Y</xsl:element>
    </xsl:element>
</xsl:element>

<!-- do not raise an error if no relased STP found or if OPM order does not exists but OP internal order has been successfully rejected -->
<xsl:element name="CcmFifMapStringCmd">
    <xsl:element name="command_id">map_raise_error</xsl:element>
    <xsl:element name="CcmFifMapStringInCont">
        <xsl:element name="input_string_type">[Y,N]_[Y,N,]</xsl:element>
        <xsl:element name="input_string_list">
            <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">find_directory_entry</xsl:element>
                <xsl:element name="field_name">stp_found</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">_</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">cancel_directory_entry</xsl:element>
                <xsl:element name="field_name">op_order_rejected_ind</xsl:element>							
            </xsl:element>
        </xsl:element>
        <xsl:element name="output_string_type">[Y,N]</xsl:element>
        <xsl:element name="string_mapping_list">
            <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">Y_N</xsl:element>
                <xsl:element name="output_string">Y</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">Y_</xsl:element>
                <xsl:element name="output_string">Y</xsl:element>
            </xsl:element>
        </xsl:element>
        <xsl:element name="no_mapping_error">N</xsl:element>
    </xsl:element>
</xsl:element>

<!-- raise error to initiate functional recycling -->      
<xsl:element name="CcmFifRaiseErrorCmd">
    <xsl:element name="command_id">raise_error_func_recycle</xsl:element>
    <xsl:element name="CcmFifRaiseErrorInCont">
        <xsl:element name="error_text">IT-22324: TBE-Stornierung in Arbeit, Request muss morgen wieder ausgeführt werden.</xsl:element>
        <xsl:element name="ccm_error_code">146131</xsl:element>
        <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">map_raise_error</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>							
        </xsl:element>          
        <xsl:element name="required_process_ind">Y</xsl:element>          
    </xsl:element>
</xsl:element>     

<!-- Ensure that the relocation has not been performed before -->
<xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
    <xsl:element name="command_id">find_cancel_stp_1</xsl:element>
    <xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
        <xsl:element name="product_subscription_ref">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="field_name">product_subscription_id</xsl:element>
        </xsl:element>
        <xsl:element name="reason_rd">RELOCATION</xsl:element>
    </xsl:element>
</xsl:element>

<xsl:element name="CcmFifConcatStringsCmd">
    <xsl:element name="command_id">orderId</xsl:element>
    <xsl:element name="CcmFifConcatStringsInCont">
        <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">
                    <xsl:value-of select="$terminationBarcode"/>
                </xsl:element>							
            </xsl:element>                
        </xsl:element>
    </xsl:element>
</xsl:element>                   
