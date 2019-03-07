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

        <!-- Find Service Subscriptions that are going to blocked for this transaction  -->     
        <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_service_0</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
                <xsl:element name="account_number">
                    <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
                </xsl:element>
                <xsl:element name="service_code_list">
                    <xsl:element name="CcmFifPassingValueCont"><!--DSLR -->
                        <xsl:element name="service_code">I1043</xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifPassingValueCont"><!-- DSLR_Business -->
                        <xsl:element name="service_code">I104A</xsl:element>
                    </xsl:element>                                        
                    <xsl:element name="CcmFifPassingValueCont"><!-- ISDN_Premium -->
                        <xsl:element name="service_code">V0010</xsl:element>
                    </xsl:element>     
                    <xsl:element name="CcmFifPassingValueCont"><!-- ISDN_Basic -->
                        <xsl:element name="service_code">V0003</xsl:element>
                    </xsl:element> 
                    <xsl:element name="CcmFifPassingValueCont"><!-- ISDN_Anlage -->
                        <xsl:element name="service_code">V0011</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- SDSL -->
                        <xsl:element name="service_code">I1215</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- ADSL -->
                        <xsl:element name="service_code">I1216</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- NGN_Online -->
                        <xsl:element name="service_code">I1210</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- NGN_Premium -->
                        <xsl:element name="service_code">VI003</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- NGN_Basic -->
                        <xsl:element name="service_code">VI002</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- InternetLTE -->
                        <xsl:element name="service_code">I1290</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- VoiceBasisLTE -->
                        <xsl:element name="service_code">VI018</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- VoicePremiumLTE -->
                        <xsl:element name="service_code">VI019</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- InternetFTTx -->
                        <xsl:element name="service_code">I121z</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- VoiceBasisFTTx -->
                        <xsl:element name="service_code">VI002</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- VoicePremiumFTTx -->
                        <xsl:element name="service_code">VI003</xsl:element>
                    </xsl:element>                   
                </xsl:element>   
                <xsl:element name="no_service_error">N</xsl:element>          
            </xsl:element>
        </xsl:element> 


        <!-- if one of the services is not allowed for this transaction. Schould be termanate via WITA -->
        <xsl:element name="CcmFifValidateValueCmd">
            <xsl:element name="command_id">validate_product_code_1</xsl:element>
            <xsl:element name="CcmFifValidateValueInCont">
                <xsl:element name="value_ref">
                    <xsl:element name="command_id">find_service_0</xsl:element>
                    <xsl:element name="field_name">service_code</xsl:element>
                </xsl:element>
                <xsl:element name="object_type">terminateService transaction. Termination should be performed via WITA workflow</xsl:element>
                <xsl:element name="value_type">service_code</xsl:element>
                <xsl:element name="allowed_values">
                    <xsl:element name="CcmFifPassingValueCont"><!--DSLR -->
                        <xsl:element name="service_code">I1043</xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifPassingValueCont"><!-- DSLR_Business -->
                        <xsl:element name="service_code">I104A</xsl:element>
                    </xsl:element>                                        
                    <xsl:element name="CcmFifPassingValueCont"><!-- ISDN_Premium -->
                        <xsl:element name="service_code">V0010</xsl:element>
                    </xsl:element>     
                    <xsl:element name="CcmFifPassingValueCont"><!-- ISDN_Basic -->
                        <xsl:element name="service_code">V0003</xsl:element>
                    </xsl:element> 
                    <xsl:element name="CcmFifPassingValueCont"><!-- ISDN_Anlage -->
                        <xsl:element name="service_code">V0011</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- SDSL -->
                        <xsl:element name="service_code">I1215</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- ADSL -->
                        <xsl:element name="service_code">I1216</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- NGN_Online -->
                        <xsl:element name="service_code">I1210</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- NGN_Premium -->
                        <xsl:element name="service_code">VI003</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- NGN_Basic -->
                        <xsl:element name="service_code">VI002</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- InternetLTE -->
                        <xsl:element name="service_code">I1290</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- VoiceBasisLTE -->
                        <xsl:element name="service_code">VI018</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- VoicePremiumLTE -->
                        <xsl:element name="service_code">VI019</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- InternetFTTx -->
                        <xsl:element name="service_code">I121z</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- VoiceBasisFTTx -->
                        <xsl:element name="service_code">VI002</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifPassingValueCont"><!-- VoicePremiumFTTx -->
                        <xsl:element name="service_code">VI003</xsl:element>
                    </xsl:element>                   					
                </xsl:element>
                <xsl:element name="process_ind_ref">
                    <xsl:element name="command_id">find_service_0</xsl:element>
                    <xsl:element name="field_name">service_found</xsl:element>
                </xsl:element>
                <xsl:element name="required_process_ind">Y</xsl:element>
            </xsl:element>
        </xsl:element>			




        <!-- Find Service Subscription  -->     
        <xsl:element name="CcmFifFindServiceSubsCmd">
            <xsl:element name="command_id">find_service_1</xsl:element>
            <xsl:element name="CcmFifFindServiceSubsInCont">
                <xsl:element name="account_number">
                    <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
                </xsl:element>
                <xsl:element name="service_code_list">
                    <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="service_code">V0010</xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="service_code">V0003</xsl:element>
                    </xsl:element>                                        
                    <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="service_code">I1210</xsl:element>
                    </xsl:element>     
                    <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="service_code">I1043</xsl:element>
                    </xsl:element> 
                    <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="service_code">I1213</xsl:element>
                    </xsl:element>  
                </xsl:element>   
                <xsl:element name="no_service_error">N</xsl:element>          
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
                        <xsl:element name="target_action_ending">_NGNDSL</xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">I1043</xsl:element>
                        <xsl:element name="target_action_ending">_Resale</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">V0010</xsl:element>
                        <xsl:element name="target_action_ending">_ISDN</xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">V0003</xsl:element>
                        <xsl:element name="target_action_ending">_ISDN</xsl:element>
                    </xsl:element> 
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">I1213</xsl:element>
                        <xsl:element name="target_action_ending">_BITDSL</xsl:element>
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
