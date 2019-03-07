<xsl:element name="CcmFifCommandList">
    <xsl:element name="transaction_id">
        <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="client_name">OPM</xsl:element>
    <xsl:variable name="TopAction" select="//request/action-name"/>
    <xsl:element name="action_name">
        <xsl:value-of select="concat($TopAction, '_DM')"/>
    </xsl:element>   
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="decision_maker_list">Y</xsl:element>
    <xsl:element name="Command_List">
        <!-- Find Service Subscription -->
        <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
                <xsl:element name="service_ticket_position_id">
                    <xsl:value-of select="request-param[@name='SERVICE_TICKET_POSITION_ID']"/>
                </xsl:element>
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
                        <xsl:element name="value">I1210</xsl:element>
                        <xsl:element name="target_action_ending">_NGN</xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">V0003</xsl:element>
                        <xsl:element name="target_action_ending">_ISDN</xsl:element>
                    </xsl:element> 
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">V0010</xsl:element>
                        <xsl:element name="target_action_ending">_ISDN</xsl:element>
                    </xsl:element> 
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">V0011</xsl:element>
                        <xsl:element name="target_action_ending">_ISDN</xsl:element>
                    </xsl:element> 
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">I1213</xsl:element>
                        <xsl:element name="target_action_ending">_BitStream</xsl:element>
                    </xsl:element>   
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">I1215</xsl:element>
                        <xsl:element name="target_action_ending">_BusinessDSL</xsl:element>
                    </xsl:element>   
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">I1216</xsl:element>
                        <xsl:element name="target_action_ending">_BusinessDSL</xsl:element>
                    </xsl:element>   
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">I1043</xsl:element>
                        <xsl:element name="target_action_ending">_DSLR</xsl:element>
                    </xsl:element> 
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">I104A</xsl:element>
                        <xsl:element name="target_action_ending">_DSLR</xsl:element>
                    </xsl:element> 
                </xsl:element>    			
            </xsl:element>
        </xsl:element>

    </xsl:element> 
</xsl:element>
