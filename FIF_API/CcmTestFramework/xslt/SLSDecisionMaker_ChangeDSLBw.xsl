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
                <xsl:if test="((request-param[@name='ACCESS_NUMBER'] != '' )and ((request-param[@name='SERVICE_SUBSCRIPTION_ID'] = '')))">
                    <xsl:element name="access_number">
                        <xsl:value-of select="request-param[@name='ACCESS_NUMBER']"/>
                    </xsl:element>
                    <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='SERVICE_SUBSCRIPTION_ID'] != ''">
                    <xsl:element name="service_subscription_id">
                        <xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
                    </xsl:element>
                </xsl:if>
                <xsl:element name="effective_date">
                    <xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
                </xsl:element>
                <xsl:element name="customer_number">
                    <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
                </xsl:element>
                <xsl:element name="contract_number">
                    <xsl:value-of select="request-param[@name='CONTRACT_NUMBER']"/>
                </xsl:element>    
            </xsl:element>
        </xsl:element> 
        <xsl:element name="CcmFifChooseActionByServiceCodeCmd">
            <xsl:element name="command_id">choose_action_1</xsl:element>
            <xsl:element name="CcmFifChooseActionByServiceCodeInCont">
                <xsl:element name="service_code_ref">
                    <xsl:element name="command_id">find_service_1</xsl:element>
                    <xsl:element name="field_name">service_code</xsl:element>
                </xsl:element>
                <xsl:element name="service_code_list">
                    <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="service_code">I1210</xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element> 
        </xsl:element> 
    </xsl:element> 
</xsl:element>
