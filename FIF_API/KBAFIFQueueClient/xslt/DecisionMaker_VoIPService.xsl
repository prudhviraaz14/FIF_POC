<xsl:element name="CcmFifCommandList">
    <xsl:element name="transaction_id">
        <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="client_name">
        <xsl:value-of select="request-param[@name='clientName']"/>
    </xsl:element>
    <xsl:variable name="TopAction" select="//request/action-name"/>
    <xsl:if test="$TopAction != 'modifyNgnVoIP'">
	   <xsl:element name="action_name">
		  <xsl:value-of select="concat($TopAction, '_DM')"/>
	    </xsl:element>
	</xsl:if>
	<xsl:if test="$TopAction = 'modifyNgnVoIP'">
	    <xsl:variable name="TopAction1">modifyVoIP</xsl:variable>
	    <xsl:element name="action_name">
		  <xsl:value-of select="concat($TopAction1, '_DM')"/>
	    </xsl:element>
	</xsl:if>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="decision_maker_list">Y</xsl:element>
    <xsl:element name="Command_List">
        <!-- Find Service Subscription by access number or Service Subscription Id-->
		<xsl:if test="(request-param[@name='accessNumber'] != '') or (request-param[@name='serviceSubscriptionId'] != '') or (request-param[@name='serviceTicketPositionId'] != '') or (request-param[@name='productSubscriptionId'] != '')">
            <xsl:element name="CcmFifFindServiceSubsCmd">
                <xsl:element name="command_id">find_service_1</xsl:element>
                <xsl:element name="CcmFifFindServiceSubsInCont">
					<!-- If only service subscription Id  is provided-->
					<xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
						<xsl:element name="service_subscription_id">
							<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
						</xsl:element>
					</xsl:if>
					<!-- If only service ticket position Id  is provided-->
					<xsl:if test="(request-param[@name='serviceTicketPositionId'] != '') and (request-param[@name='serviceSubscriptionId'] = '')">
						<xsl:element name="service_ticket_position_id">
							<xsl:value-of select="request-param[@name='serviceTicketPositionId']"/>
						</xsl:element>
					</xsl:if>
					<!-- If only access number is provided-->
					<xsl:if test="((request-param[@name='accessNumber'] != '' )and (request-param[@name='serviceSubscriptionId'] = '') and (request-param[@name='serviceTicketPositionId'] = ''))">
					  <xsl:element name="access_number">
						<xsl:value-of select="request-param[@name='accessNumber']"/>
				      </xsl:element>
					  <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
					</xsl:if>                
                    <xsl:if test="request-param[@name='customerNumber']!=''">
                        <xsl:element name="customer_number">
                            <xsl:value-of select="request-param[@name='customerNumber']"/>
                        </xsl:element>
                    </xsl:if>			  	
                    <xsl:if test="request-param[@name='contractNumber']!=''">
                        <xsl:element name="contract_number">
                            <xsl:value-of select="request-param[@name='contractNumber']"/>
                        </xsl:element>
                    </xsl:if>
					<xsl:if test="((request-param[@name='productSubscriptionId'] != '' ) and (request-param[@name='accessNumber'] = '') and (request-param[@name='serviceTicketPositionId'] = '')  and (request-param[@name='serviceSubscriptionId'] = ''))">
						<xsl:element name="product_subscription_id">
							<xsl:value-of select="request-param[@name='productSubscriptionId']"/>
						</xsl:element>
					   	<xsl:element name="fetch_main_ss_from_ps_Ind">Y</xsl:element>
					</xsl:if>
                </xsl:element>
            </xsl:element>
        </xsl:if>
        <!-- Take value of serviceSubscriptionId from ccm external notification if accessNumber and serviceSubscriptionId not provided -->
		<xsl:if test="(request-param[@name='accessNumber'] = '') and  (request-param[@name='serviceSubscriptionId'] = '') and (request-param[@name='serviceTicketPositionId'] = '') and (request-param[@name='productSubscriptionId'] = '')">
            <!-- Get Service Subscription ID -->
            <xsl:element name="CcmFifReadExternalNotificationCmd">
                <xsl:element name="command_id">read_external_notification_1</xsl:element>
                <xsl:element name="CcmFifReadExternalNotificationInCont">
                    <xsl:element name="transaction_id">
                        <xsl:value-of select="request-param[@name='requestListId']"/>
                    </xsl:element>
                    <xsl:element name="parameter_name">SERVICE_SUBSCRIPTION_ID</xsl:element>
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
                        <xsl:element name="value">VI002</xsl:element>
                        <xsl:element name="target_action_ending">_NGN</xsl:element>
                    </xsl:element>  
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">VI003</xsl:element>
                        <xsl:element name="target_action_ending">_NGN</xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">VI201</xsl:element>
                        <xsl:element name="target_action_ending">_2ndLine</xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">VI006</xsl:element>
                        <xsl:element name="target_action_ending">_Bitstream</xsl:element>
                    </xsl:element>
                    <xsl:element name="CcmFifDecisionMakerMappingCont">
                        <xsl:element name="value">VI009</xsl:element>
                        <xsl:element name="target_action_ending">_Bitstream</xsl:element>
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
