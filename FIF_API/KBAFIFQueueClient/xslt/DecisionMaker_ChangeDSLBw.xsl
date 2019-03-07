<xsl:element name="CcmFifCommandList">
    <xsl:element name="transaction_id">
        <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="client_name">
        <xsl:value-of select="request-param[@name='clientName']"/>
    </xsl:element>
    <xsl:variable name="TopAction" select="//request/action-name"/>
    <xsl:element name="action_name">
        <xsl:value-of select="concat($TopAction, '_DM')"/>
    </xsl:element>   
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="decision_maker_list">Y</xsl:element>
    <xsl:element name="Command_List">
        <!-- Find Service Subscription by access number,or service_subscription id  -->     
        <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
                <xsl:if test="request-param[@name='accessNumber'] != '' 
                    and request-param[@name='serviceSubscriptionId'] = ''">
                    <xsl:element name="access_number">
                        <xsl:value-of select="request-param[@name='accessNumber']"/>
                    </xsl:element>
                    <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
                    <xsl:element name="service_subscription_id">
                        <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
                    </xsl:element>
                </xsl:if>
                <xsl:element name="effective_date">
                    <xsl:value-of select="request-param[@name='desiredDate']"/>
                </xsl:element>
                <xsl:element name="customer_number">
                    <xsl:value-of select="request-param[@name='customerNumber']"/>
                </xsl:element>
                <xsl:element name="contract_number">
                    <xsl:value-of select="request-param[@name='contractNumber']"/>
                </xsl:element>  
                <xsl:if test="request-param[@name='productSubscriptionId'] != ''">
                    <xsl:element name="product_subscription_id">
                        <xsl:value-of select="request-param[@name='productSubscriptionId']"/>
                    </xsl:element>
                    <xsl:element name="fetch_main_ss_from_ps_Ind">Y</xsl:element>
                </xsl:if>
            </xsl:element>
        </xsl:element> 
        
        <xsl:element name="CcmFifDecisionMakerCmd">
            <xsl:element name="command_id">decision_maker</xsl:element>
            <xsl:element name="CcmFifDecisionMakerInCont">
                <xsl:element name="value_ref">
                    <xsl:element name="command_id">find_service_1</xsl:element>
                    <xsl:element name="field_name">service_code</xsl:element>
                </xsl:element>
                <xsl:element name="decision_maker_mapping_list">
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">I1043</xsl:element>
                        <xsl:element name="target_action_ending">_DSLR</xsl:element>
                    </xsl:element> 
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">I1213</xsl:element>
                        <xsl:element name="target_action_ending">_BitDSL</xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">I1210</xsl:element>
                        <xsl:element name="target_action_ending">_NGN</xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">I121z</xsl:element>
                        <xsl:element name="target_action_ending">_FTTx</xsl:element>
                    </xsl:element>                    
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">I1215</xsl:element>
                        <xsl:element name="target_action_ending">_SDSL</xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">V0003</xsl:element>
                        <xsl:element name="target_action_ending">_basis</xsl:element>
                    </xsl:element> 
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value"></xsl:element>
                        <xsl:element name="target_action_ending">_default</xsl:element>
                    </xsl:element>    			
                </xsl:element>    			
            </xsl:element>
        </xsl:element>

    </xsl:element> 
</xsl:element>
