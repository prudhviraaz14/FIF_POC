<!-- Create Order Form-->
<xsl:if test="request-param[@name='productCommitmentNumber']=''">
	<xsl:element name="CcmFifCreateOrderFormCmd">
		<xsl:element name="command_id">create_order_form_1</xsl:element>
		<xsl:element name="CcmFifCreateOrderFormInCont">
			<xsl:if test="request-param[@name='customerNumber']=''">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">read_cust_num_from_ext_noti</xsl:element>
					<xsl:element name="field_name">parameter_value</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="request-param[@name='customerNumber']!=''">
				<xsl:element name="customer_number">
					<xsl:value-of select="request-param[@name='customerNumber']"/>
				</xsl:element>
			</xsl:if>
			<xsl:element name="min_per_dur_value">
				<xsl:value-of select="request-param[@name='minPeriodDurationValue']"/>
			</xsl:element>
			<xsl:element name="min_per_dur_unit">
				<xsl:value-of select="request-param[@name='minPeriodDurationUnit']"/>
			</xsl:element>
			<xsl:element name="sales_org_num_value">
				<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
			</xsl:element>												
			<xsl:element name="sales_org_num_value_vf">
				<xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
			</xsl:element>				
			<xsl:element name="doc_template_name">Vertrag</xsl:element>
			<xsl:element name="assoc_skeleton_cont_num">
				<xsl:value-of select="request-param[@name='assocSkeletonContNum']"/>
			</xsl:element>
			<xsl:element name="auto_extent_period_value">
				<xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>
			</xsl:element>                         
			<xsl:element name="auto_extent_period_unit">
				<xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>
			</xsl:element>                         
			<xsl:element name="auto_extension_ind">
				<xsl:value-of select="request-param[@name='autoExtensionInd']"/>
			</xsl:element>
		    <xsl:element name="name">
		        <xsl:value-of select="$contractName"/>
		    </xsl:element>
		</xsl:element>				
	</xsl:element>
	
	<!-- Add Order Form Product Commitment -->
	<xsl:element name="CcmFifAddProductCommitCmd">
		<xsl:element name="command_id">add_product_commitment_1</xsl:element>
		<xsl:element name="CcmFifAddProductCommitInCont">
			<xsl:if test="request-param[@name='customerNumber']=''">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">read_cust_num_from_ext_noti</xsl:element>
					<xsl:element name="field_name">parameter_value</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="request-param[@name='customerNumber']!=''">
				<xsl:element name="customer_number">
					<xsl:value-of select="request-param[@name='customerNumber']"/>
				</xsl:element>
			</xsl:if>
			<xsl:element name="contract_number_ref">
				<xsl:element name="command_id">create_order_form_1</xsl:element>
				<xsl:element name="field_name">contract_number</xsl:element>
			</xsl:element>
			<xsl:element name="product_code">
				<xsl:value-of select="request-param[@name='productCode']"/>
			</xsl:element>
			<xsl:element name="pricing_structure_code">
				<xsl:value-of select="request-param[@name='tariff']"/>
			</xsl:element>
		</xsl:element>
	</xsl:element>

	<!-- Sign Order Form -->
	<xsl:element name="CcmFifSignOrderFormCmd">
		<xsl:element name="command_id">sign_of_1</xsl:element>
		<xsl:element name="CcmFifSignOrderFormInCont">
			<xsl:element name="contract_number_ref">
				<xsl:element name="command_id">create_order_form_1</xsl:element>
				<xsl:element name="field_name">contract_number</xsl:element>
			</xsl:element>
			<xsl:element name="board_sign_name">ARCOR</xsl:element>
			<xsl:element name="primary_cust_sign_name">ARC</xsl:element>
			<xsl:element name="primary_cust_sign_date">
				<xsl:value-of select="request-param[@name='primaryCustSignDate']"/>
			</xsl:element>
		</xsl:element>
	</xsl:element>
</xsl:if>

<!-- Add Product Subscription -->
<xsl:element name="CcmFifAddProductSubsCmd">
	<xsl:element name="command_id">add_product_subscription_1</xsl:element>
	<xsl:element name="CcmFifAddProductSubsInCont">
		<xsl:if test="request-param[@name='customerNumber']=''">
			<xsl:element name="customer_number_ref">
				<xsl:element name="command_id">read_cust_num_from_ext_noti</xsl:element>
				<xsl:element name="field_name">parameter_value</xsl:element>
			</xsl:element>
		</xsl:if>
		<xsl:if test="request-param[@name='customerNumber']!=''">
			<xsl:element name="customer_number">
				<xsl:value-of select="request-param[@name='customerNumber']"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="request-param[@name='productCommitmentNumber']!=''">
			<xsl:element name="product_commitment_number">
				<xsl:value-of select="request-param[@name='productCommitmentNumber']"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="request-param[@name='productCommitmentNumber']=''">
			<xsl:element name="product_commitment_number_ref">
				<xsl:element name="command_id">add_product_commitment_1</xsl:element>
				<xsl:element name="field_name">product_commitment_number</xsl:element>
			</xsl:element>
		</xsl:if>
		<xsl:element name="vis_tracking_position">
			<xsl:value-of select="request-param[@name='VISTrackingPosition']"/>
		</xsl:element>					
	</xsl:element>
</xsl:element>

