<!--  Find contract or product commitment properties -->
<xsl:choose>
  <xsl:when test="request-param[@name='existingServiceSubscriptionId'] != ''">
  	<!-- get contract data -->
		<xsl:element name="CcmFifGetProductCommitmentDataCmd">
      <xsl:element name="command_id">get_contract_data</xsl:element>
      <xsl:element name="CcmFifGetProductCommitmentDataInCont">
        <xsl:element name="product_commitment_number_ref">
          <xsl:element name="command_id">find_existing_service</xsl:element>
          <xsl:element name="field_name">product_commitment_number</xsl:element>
        </xsl:element>
        <xsl:if test="request-param[@name='signProductCommitment'] != 'N'">
          <xsl:element name="retrieve_signed_version">Y</xsl:element>
        </xsl:if>
        <xsl:element name="contract_type_rd_ref">
          <xsl:element name="command_id">find_existing_service</xsl:element>
          <xsl:element name="field_name">contract_type_rd</xsl:element>
        </xsl:element>
      </xsl:element>
		</xsl:element>
	</xsl:when>
  <xsl:otherwise>
  	<!-- get contract data -->
		<xsl:element name="CcmFifGetProductCommitmentDataCmd">
      <xsl:element name="command_id">get_contract_data</xsl:element>
      <xsl:element name="CcmFifGetProductCommitmentDataInCont">
		  <xsl:if test="request-param[@name='productCommitmentNumber'] != ''">
			  <xsl:element name="product_commitment_number">
				  <xsl:value-of select="request-param[@name='productCommitmentNumber']"/>
			  </xsl:element>
		  </xsl:if>
		  <xsl:if test="request-param[@name='productCommitmentNumber'] = ''">
           <xsl:element name="product_commitment_number_ref">
             <xsl:element name="command_id">add_product_commitment</xsl:element>
             <xsl:element name="field_name">product_commitment_number</xsl:element>
           </xsl:element>
		  </xsl:if>
        <xsl:if test="request-param[@name='signProductCommitment'] != 'N'">
          <xsl:element name="retrieve_signed_version">Y</xsl:element>
        </xsl:if>
        <xsl:choose>
        	<xsl:when test="request-param[@name='serviceDeliveryContractNumber'] != ''
        		and request-param[@name='productCommitmentNumber'] = ''">
            <xsl:element name="contract_type_rd">S</xsl:element>
        	</xsl:when>
          <xsl:otherwise>
            <xsl:element name="contract_type_rd">O</xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
		</xsl:element>
  </xsl:otherwise>
</xsl:choose>

<xsl:element name="CcmFifGetContractDatesCmd">
	<xsl:element name="command_id">getContractDates</xsl:element>
	<xsl:element name="CcmFifGetContractDatesInCont">
		<xsl:element name="min_period_dur_value">
			<xsl:value-of select="request-param[@name='minPeriodDurationValue']"/>
		</xsl:element>
		<xsl:element name="min_period_dur_unit_rd">
			<xsl:value-of select="request-param[@name='minPeriodDurationUnit']"/>
		</xsl:element>
		<xsl:element name="min_period_start_date_ref">
			<xsl:element name="command_id">get_contract_data</xsl:element>
			<xsl:element name="field_name">min_period_start_date</xsl:element>
		</xsl:element>
		<xsl:element name="auto_extent_dur_value">
			<xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>
		</xsl:element>
		<xsl:element name="auto_extent_dur_unit_rd">
			<xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>
		</xsl:element>
		<xsl:element name="auto_extension_ind">
			<xsl:value-of select="request-param[@name='autoExtensionInd']"/>
		</xsl:element>
	</xsl:element>
</xsl:element>      

<!--  Create external notification for internal purposes -->
<xsl:element name="CcmFifCreateExternalNotificationCmd">
	<xsl:element name="command_id">create_notification_1</xsl:element>
	<xsl:element name="CcmFifCreateExternalNotificationInCont">
		<xsl:element name="effective_date">
			<xsl:value-of select="$desiredDate"/>
		</xsl:element>
		<xsl:element name="transaction_id">
			<xsl:value-of select="request-param[@name='requestListId']"/>
		</xsl:element>
		<xsl:element name="processed_indicator">Y</xsl:element>
		<xsl:element name="notification_action_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:element name="target_system">FIF</xsl:element>
		<xsl:element name="parameter_value_list">
			<xsl:element name="CcmFifParameterValueCont">
				<xsl:element name="parameter_name">
					<xsl:value-of select="request-param[@name='functionID']"/>
					<xsl:text>_SERVICE_SUBSCRIPTION_ID</xsl:text>
				</xsl:element>
				<xsl:element name="parameter_value_ref">
					<xsl:element name="command_id">add_main_service</xsl:element>
					<xsl:element name="field_name">service_subscription_id</xsl:element>
				</xsl:element>
			</xsl:element>							
			<xsl:element name="CcmFifParameterValueCont">
				<xsl:element name="parameter_name">
					<xsl:value-of select="request-param[@name='functionID']"/>
					<xsl:text>_DETAILED_REASON_RD</xsl:text>
				</xsl:element>
				<xsl:element name="parameter_value">
					<xsl:choose>
						<xsl:when test="request-param[@name='detailedReason'] != ''">
							<xsl:value-of select="request-param[@name='detailedReason']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$reasonRd"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:element>							
		</xsl:element>
	</xsl:element>
</xsl:element>

<!--  Create external notification for internal purposes -->
<xsl:element name="CcmFifCreateExternalNotificationCmd">
	<xsl:element name="command_id">create_notification_2</xsl:element>
	<xsl:element name="CcmFifCreateExternalNotificationInCont">
		<xsl:element name="effective_date">
			<xsl:value-of select="$desiredDate"/>
		</xsl:element>
		<xsl:element name="transaction_id">
			<xsl:value-of select="request-param[@name='requestListId']"/>
		</xsl:element>
		<xsl:element name="processed_indicator">Y</xsl:element>
		<xsl:element name="notification_action_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:element name="target_system">FIF</xsl:element>
		<xsl:element name="parameter_value_list">
			<xsl:element name="CcmFifParameterValueCont">
				<xsl:element name="parameter_name">
					<xsl:value-of select="request-param[@name='functionID']"/>
					<xsl:if test="request-param[@name='processingStatus'] = ''">_OP</xsl:if>
					<xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
				</xsl:element>
				<xsl:element name="parameter_value_ref">
					<xsl:element name="command_id">create_co</xsl:element>
					<xsl:element name="field_name">customer_order_id</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
		<xsl:element name="process_ind_ref">
			<xsl:element name="command_id">create_co</xsl:element>
			<xsl:element name="field_name">customer_order_created</xsl:element>
		</xsl:element>
		<xsl:element name="required_process_ind">Y</xsl:element>   
	</xsl:element>
</xsl:element>

<xsl:element name="CcmFifConcatStringsCmd">
	<xsl:element name="command_id">ccbId</xsl:element>
	<xsl:element name="CcmFifConcatStringsInCont">
		<xsl:element name="input_string_list">
			<xsl:element name="CcmFifPassingValueCont">
				<xsl:element name="value">
					<xsl:value-of select="request-param[@name='allocatedServiceSubscriptionId']"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:element>
</xsl:element>

<xsl:element name="CcmFifConcatStringsCmd">
	<xsl:element name="command_id">functionStatus</xsl:element>
	<xsl:element name="CcmFifConcatStringsInCont">
		<xsl:element name="input_string_list">
			<xsl:element name="CcmFifPassingValueCont">
				<xsl:element name="value">
					<xsl:choose>
						<xsl:when test="request-param[@name='processingStatus'] = 'completedOPM'">SUCCESS</xsl:when>
						<xsl:otherwise>ACKNOWLEDGED</xsl:otherwise>                  
					</xsl:choose>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:element>
</xsl:element>

<xsl:element name="CcmFifConcatStringsCmd">
	<xsl:element name="command_id">functionID</xsl:element>
	<xsl:element name="CcmFifConcatStringsInCont">
		<xsl:element name="input_string_list">
			<xsl:element name="CcmFifPassingValueCont">
				<xsl:element name="value">
					<xsl:value-of select="request-param[@name='functionID']"/>
				</xsl:element>							
			</xsl:element>                
		</xsl:element>
	</xsl:element>
</xsl:element>              
