<!-- Add DSL Einrichtungspreis -->
    <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_dsl_fee_service_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V0134</xsl:element>
            <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
                <xsl:value-of select="$today"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">
                <xsl:value-of select="request-param[@name='reasonRd']"/>
            </xsl:element>
            <xsl:if test="$AccountNumber=''">
                <xsl:element name="account_number_ref">
                    <xsl:element name="command_id">read_external_notification_2</xsl:element>
                    <xsl:element name="field_name">parameter_value</xsl:element>
                </xsl:element>
            </xsl:if>
            <xsl:if test="$AccountNumber!=''">
                <xsl:element name="account_number">
                    <xsl:value-of select="$AccountNumber"/>
                </xsl:element>
            </xsl:if>
            <xsl:element name="service_characteristic_list">                
            </xsl:element>
            <xsl:element name="detailed_reason_rd">
                <xsl:value-of select="$detailedReasonRd"/>
            </xsl:element>
        </xsl:element>
    </xsl:element>

     <!-- Add DSL Service -->
    <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_dsl_service_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="service_code">V0113</xsl:element>
            <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
                <xsl:value-of select="$today"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">
                <xsl:value-of select="request-param[@name='reasonRd']"/>
            </xsl:element> 
            <xsl:if test="$AccountNumber=''">
                <xsl:element name="account_number_ref">
                    <xsl:element name="command_id">read_external_notification_2</xsl:element>
                    <xsl:element name="field_name">parameter_value</xsl:element>
                </xsl:element>
            </xsl:if>
            <xsl:if test="$AccountNumber!=''">
                <xsl:element name="account_number">
                    <xsl:value-of select="$AccountNumber"/>
                </xsl:element>
            </xsl:if>
            <xsl:element name="service_characteristic_list">
                <!-- DSLBandbreite -->
                <xsl:element name="CcmFifConfiguredValueCont">
                    <xsl:element name="service_char_code">V0826</xsl:element>
                    <xsl:element name="data_type">STRING</xsl:element>
                    <xsl:element name="configured_value">
                        <xsl:value-of select="request-param[@name='dslBandwidth']"/>
                    </xsl:element>
                </xsl:element>
                <!-- DSL Upstream Bandbreite -->
                <xsl:element name="CcmFifConfiguredValueCont">
                    <xsl:element name="service_char_code">V0092</xsl:element>
                    <xsl:element name="data_type">STRING</xsl:element>
                    <xsl:element name="configured_value">
                        <xsl:value-of select="request-param[@name='upstreamBandwidth']"/>
                    </xsl:element>
                </xsl:element>
                <!-- Allow Downgrade -->
                <xsl:element name="CcmFifConfiguredValueCont">
                    <xsl:element name="service_char_code">V0875</xsl:element>
                    <xsl:element name="data_type">STRING</xsl:element>
                    <xsl:element name="configured_value">
                        <xsl:value-of select="request-param[@name='allowDowngrade']"/>
                    </xsl:element>
                </xsl:element>
                <!-- Desired Bandwidth -->
                <xsl:element name="CcmFifConfiguredValueCont">
                    <xsl:element name="service_char_code">V0876</xsl:element>
                    <xsl:element name="data_type">STRING</xsl:element>
                    <xsl:element name="configured_value">
                        <xsl:value-of select="request-param[@name='desiredBandwidth']"/>
                    </xsl:element>
                </xsl:element>                                        
            </xsl:element>    
            <xsl:element name="detailed_reason_rd">
                <xsl:value-of select="$detailedReasonRd"/>
            </xsl:element>
        </xsl:element>
    </xsl:element>
    
    <!-- Add DSL Anschluss service -->
    <xsl:element name="CcmFifAddServiceSubsCmd">
        <xsl:element name="command_id">add_bandwidth_service_1</xsl:element>
        <xsl:element name="CcmFifAddServiceSubsInCont">
            <xsl:element name="product_subscription_ref">
                <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                <xsl:element name="field_name">product_subscription_id</xsl:element>
            </xsl:element>
            <xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 500'">
                <xsl:element name="service_code">V0179</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='dslBandwidth'] = 'Premium'">
                <xsl:element name="service_code">V0116</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='dslBandwidth'] = 'Gold'">
                <xsl:element name="service_code">V0117</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 1000'">
                <xsl:element name="service_code">V0118</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 2000'">
                <xsl:element name="service_code">V0174</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 3000'">
                <xsl:element name="service_code">V0175</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 4000'">
                <xsl:element name="service_code">V0176</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 5000'">
                <xsl:element name="service_code">V0177</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 6000'">
                <xsl:element name="service_code">V0178</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 8000'">
                <xsl:element name="service_code">V0180</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 10000'">
                <xsl:element name="service_code">V018A</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 12000'">
                <xsl:element name="service_code">V018B</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 16000'">
                <xsl:element name="service_code">V018C</xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 20000'">
                <xsl:element name="service_code">V018D</xsl:element>
            </xsl:if>
            <xsl:element name="parent_service_subs_ref">
                <xsl:element name="command_id">add_service_1</xsl:element>
                <xsl:element name="field_name">service_subscription_id</xsl:element>
            </xsl:element>
            <xsl:element name="desired_date">
                <xsl:value-of select="$today"/>
            </xsl:element>
            <xsl:element name="desired_schedule_type">ASAP</xsl:element>
            <xsl:element name="reason_rd">
                <xsl:value-of select="request-param[@name='reasonRd']"/>
            </xsl:element> 
            <xsl:if test="$AccountNumber=''">
                <xsl:element name="account_number_ref">
                    <xsl:element name="command_id">read_external_notification_2</xsl:element>
                    <xsl:element name="field_name">parameter_value</xsl:element>
                </xsl:element>
            </xsl:if>
            <xsl:if test="$AccountNumber!=''">
                <xsl:element name="account_number">
                    <xsl:value-of select="$AccountNumber"/>
                </xsl:element>
            </xsl:if>
            <xsl:element name="service_characteristic_list"/>  
            <xsl:element name="detailed_reason_rd">
                <xsl:value-of select="$detailedReasonRd"/>
            </xsl:element>
        </xsl:element>
    </xsl:element>
    <!-- Add Upstream Service, if requested -->
    <xsl:if test="(request-param[@name='upstreamBandwidth'] != 'Standard')">
        <xsl:element name="CcmFifAddServiceSubsCmd">
            <xsl:element name="command_id">add_upstream_service_1</xsl:element>
            <xsl:element name="CcmFifAddServiceSubsInCont">
                <xsl:element name="product_subscription_ref">
                    <xsl:element name="command_id">add_product_subscription_1</xsl:element>
                    <xsl:element name="field_name">product_subscription_id</xsl:element>
                </xsl:element>
                <xsl:if test="(request-param[@name='dslBandwidth'] = 'DSL 1500') and (request-param[@name='upstreamBandwidth'] = '384')">
                    <xsl:element name="service_code">V0197</xsl:element>
                </xsl:if>
                <xsl:if test="(request-param[@name='dslBandwidth'] = 'DSL 2000') and (request-param[@name='upstreamBandwidth'] = '384')">
                    <xsl:element name="service_code">V0198</xsl:element>
                </xsl:if>               
                <xsl:if test="(request-param[@name='dslBandwidth'] = 'DSL 3000') and (request-param[@name='upstreamBandwidth'] = '512')">
                    <xsl:element name="service_code">V0199</xsl:element>
                </xsl:if>
                <xsl:if test="(request-param[@name='dslBandwidth'] = 'DSL 4000') and (request-param[@name='upstreamBandwidth'] = '512')">
                    <xsl:element name="service_code">V0199</xsl:element>
                </xsl:if>
                <xsl:element name="parent_service_subs_ref">
                    <xsl:element name="command_id">add_bandwidth_service_1</xsl:element>
                    <xsl:element name="field_name">service_subscription_id</xsl:element>
                </xsl:element>
                <xsl:element name="desired_date">
                    <xsl:value-of select="$today"/>	
                </xsl:element>
                <xsl:element name="desired_schedule_type">ASAP</xsl:element>
                <xsl:element name="reason_rd">
                    <xsl:value-of select="request-param[@name='reasonRd']"/>
                </xsl:element> 
                <xsl:if test="$AccountNumber=''">
                    <xsl:element name="account_number_ref">
                        <xsl:element name="command_id">read_external_notification_2</xsl:element>
                        <xsl:element name="field_name">parameter_value</xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="$AccountNumber!=''">
                    <xsl:element name="account_number">
                        <xsl:value-of select="$AccountNumber"/>
                    </xsl:element>
                </xsl:if>
                <xsl:element name="service_characteristic_list"/>
                <xsl:element name="detailed_reason_rd">
                    <xsl:value-of select="$detailedReasonRd"/>
                </xsl:element>   
            </xsl:element>
        </xsl:element>
    </xsl:if>        
  
