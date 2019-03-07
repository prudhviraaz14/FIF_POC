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
        <xsl:value-of select="request-param[@name='overrideSystemDate']"/>
    </xsl:element>
    <xsl:element name="decision_maker_list">Y</xsl:element>
    <xsl:element name="Command_List">

    	<xsl:element name="CcmFifFindServiceSubsCmd">
    		<xsl:element name="command_id">find_service_1</xsl:element>
    		<xsl:element name="CcmFifFindServiceSubsInCont">    			
    			<xsl:element name="service_subscription_id">
    				<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
    			</xsl:element>
    		</xsl:element>
    	</xsl:element>

    	<!-- Find Product Code from Product Commitment -->
    	<xsl:element name="CcmFifGetProductCommitmentDataCmd">
    		<xsl:element name="command_id">get_pc_data_1</xsl:element>
    		<xsl:element name="CcmFifGetProductCommitmentDataInCont">
    			<xsl:element name="product_commitment_number_ref">
    				<xsl:element name="command_id">find_service_1</xsl:element>
    				<xsl:element name="field_name">product_commitment_number</xsl:element>
    			</xsl:element>
    		</xsl:element>
    	</xsl:element>

    	<!-- Validate moveNumbersToTarget -->
    	<xsl:if test="(request-param[@name='moveNumbersToTarget'] = 'Y')">
    		
    		<!-- Validate Customer Order State -->
    		<xsl:element name="CcmFifValidateValueCmd">
    			<xsl:element name="command_id">validate_product_code_1</xsl:element>
    			<xsl:element name="CcmFifValidateValueInCont">
    				<xsl:element name="value_ref">
    					<xsl:element name="command_id">get_pc_data_1</xsl:element>
    					<xsl:element name="field_name">product_code</xsl:element>
    				</xsl:element>
    				<xsl:element name="object_type">PRODUCT_COMMITMENT</xsl:element>
    				<xsl:element name="value_type">PRODUCT_CODE</xsl:element>
    				<xsl:element name="allowed_values">
    					<xsl:element name="CcmFifPassingValueCont">
    						<xsl:element name="value">VI201</xsl:element>          	  
    					</xsl:element>
    				</xsl:element>
    				<xsl:element name="ignore_failure_ind">Y</xsl:element>
    			</xsl:element>
    		</xsl:element>
    		
    		<xsl:element name="CcmFifRaiseErrorCmd">
    			<xsl:element name="command_id">raise_error</xsl:element>
    			<xsl:element name="CcmFifRaiseErrorInCont">
    				<xsl:element name="error_text">Parameter moveNumbersToTarget is only allowed for 2nd-Line numbers.</xsl:element>
    				<xsl:element name="process_ind_ref">
    					<xsl:element name="command_id">validate_product_code_1</xsl:element>
    					<xsl:element name="field_name">success_ind</xsl:element>
    				</xsl:element>
    				<xsl:element name="required_process_ind">N</xsl:element>
    			</xsl:element>
    		</xsl:element>
    		
    		<xsl:if test="(request-param[@name='moveNumbersMode'] != 'ADD'
    			and request-param[@name='moveNumbersMode'] != 'REPLACE')">
    			<xsl:element name="CcmFifRaiseErrorCmd">
    				<xsl:element name="command_id">old_dsl_bandwidth_error</xsl:element>
    				<xsl:element name="CcmFifRaiseErrorInCont">
    					<xsl:element name="error_text">Parameter moveNumbersMode must have value ADD or REPLACE.</xsl:element>
    				</xsl:element>
    			</xsl:element>
    		</xsl:if>
    		
    		<xsl:if test="(request-param[@name='customerOrderID'] = '')">
    			<xsl:element name="CcmFifRaiseErrorCmd">
    				<xsl:element name="command_id">old_dsl_bandwidth_error</xsl:element>
    				<xsl:element name="CcmFifRaiseErrorInCont">
    					<xsl:element name="error_text">Parameter moveNumbersToTarget is only allowed when VI006 or VI009 target is indicated via customerOrderId.</xsl:element>
    				</xsl:element>
    			</xsl:element>
    		</xsl:if>
    		
    	</xsl:if>

    	<!-- Choose action based on Product Code -->
    	<xsl:element name="CcmFifDecisionMakerCmd">
    		<xsl:element name="command_id">decision_maker</xsl:element>
    		<xsl:element name="CcmFifDecisionMakerInCont">
    			<xsl:element name="value_ref">
    				<xsl:element name="command_id">get_pc_data_1</xsl:element>
    				<xsl:element name="field_name">product_code</xsl:element>
    			</xsl:element>
    			<xsl:element name="decision_maker_mapping_list">
    				<xsl:element name="CcmFifDecisionMakerMappingCont">
    					<xsl:element name="value">VI001</xsl:element>
    					<xsl:element name="target_action_ending">_Call</xsl:element>
    				</xsl:element>
    				<xsl:element name="CcmFifDecisionMakerMappingCont">
    					<xsl:element name="value">I1201</xsl:element>
    					<xsl:element name="target_action_ending">_DSLResale</xsl:element>
    				</xsl:element>
    				<xsl:element name="CcmFifDecisionMakerMappingCont">
    					<xsl:element name="value">I1204</xsl:element>
    					<xsl:element name="target_action_ending">_NgnDsl</xsl:element>
    				</xsl:element>
    				<xsl:element name="CcmFifDecisionMakerMappingCont">
    					<xsl:element name="value">VI202</xsl:element>
    					<xsl:element name="target_action_ending">_NgnVoIP</xsl:element>
    				</xsl:element>
    				<xsl:element name="CcmFifDecisionMakerMappingCont">
    					<xsl:element name="value">VI201</xsl:element>
    					<xsl:element name="target_action_ending">_VoIP</xsl:element>
    				</xsl:element>
    				<xsl:element name="CcmFifDecisionMakerMappingCont">
	    				<xsl:element name="value"></xsl:element>
    					<xsl:element name="target_action_ending">_Default</xsl:element>
    				</xsl:element>    		
    				<xsl:element name="CcmFifDecisionMakerMappingCont">
    					<xsl:element name="value">I1203</xsl:element>
    					<xsl:element name="target_action_ending">_BitDsl</xsl:element>
    				</xsl:element>
    				<xsl:element name="CcmFifDecisionMakerMappingCont">
    					<xsl:element name="value">VI203</xsl:element>
    					<xsl:element name="target_action_ending">_BitVoIP</xsl:element>
    				</xsl:element>	
    				<xsl:element name="CcmFifDecisionMakerMappingCont">
    					<xsl:element name="value">V8000</xsl:element>
    					<xsl:element name="target_action_ending">_Mobile</xsl:element>
    				</xsl:element>
    				<xsl:element name="CcmFifDecisionMakerMappingCont">
    					<xsl:element name="value">I1302</xsl:element>
    					<xsl:element name="target_action_ending">_Multimedia</xsl:element>
    				</xsl:element>
    				<xsl:element name="CcmFifDecisionMakerMappingCont">
    					<xsl:element name="value">I1304</xsl:element>
    					<xsl:element name="target_action_ending">_Multimedia</xsl:element>
    				</xsl:element>
    				<xsl:element name="CcmFifDecisionMakerMappingCont">
    					<xsl:element name="value">I4000</xsl:element>
    					<xsl:element name="target_action_ending">_PCBackup</xsl:element>
    				</xsl:element>
    				<xsl:element name="CcmFifDecisionMakerMappingCont">
    					<xsl:element name="value">I4001</xsl:element>
    					<xsl:element name="target_action_ending">_MOS</xsl:element>
    				</xsl:element>
    				<xsl:element name="CcmFifDecisionMakerMappingCont">
    					<xsl:element name="value">I1305</xsl:element>
    					<xsl:element name="target_action_ending">_TVCenter</xsl:element>
    				</xsl:element>
    				<xsl:element name="CcmFifDecisionMakerMappingCont">
    					<xsl:element name="value">I1306</xsl:element>
    					<xsl:element name="target_action_ending">_TVCenter</xsl:element>
    				</xsl:element>
    			</xsl:element>    			
    		</xsl:element>
    	</xsl:element>
    </xsl:element> 
</xsl:element>
