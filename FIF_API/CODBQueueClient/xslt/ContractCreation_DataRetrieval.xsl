			<!-- Calculate today and one day before the desired date -->
			<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
			
			<xsl:variable name="desiredDate">
				<xsl:choose>
					<xsl:when test="request-param[@name='desiredDate'] != ''">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$today"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="termStartDate">
				<xsl:choose>
					<xsl:when test="request-param[@name='termStartDate'] != ''
						and dateutils:compareString(request-param[@name='termStartDate'], $today) != '1'">
		              <xsl:value-of select="request-param[@name='termStartDate']"/>
	          		</xsl:when>
					<xsl:when test="request-param[@name='termStartDate'] != ''
						and dateutils:compareString(request-param[@name='termStartDate'], $today) = '1'">
		              <xsl:value-of select="$today"/>
	          		</xsl:when>												
					<xsl:when test="request-param[@name='termStartDate'] = 'today'">
						<xsl:value-of select="$today"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$today"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<!-- variable for indicating that this is not a reconfiguration -->
			<xsl:variable name="isReconfiguration">N</xsl:variable>
			
			<!-- Convert the desired date to OPM format -->
			<xsl:variable name="activationDateOPM"
				select="dateutils:createOPMDate(request-param[@name='activationDate'])"/>
			
			<!-- Get bundle id -->     
			<xsl:element name="CcmFifReadExternalNotificationCmd">
				<xsl:element name="command_id">read_bundle_id</xsl:element>
				<xsl:element name="CcmFifReadExternalNotificationInCont">
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="parameter_name">
						<xsl:text>BUNDLE_ID</xsl:text>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="CcmFifReadExternalNotificationCmd">
				<xsl:element name="command_id">read_customer_order</xsl:element>
				<xsl:element name="CcmFifReadExternalNotificationInCont">
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="parameter_name">
						<xsl:value-of select="request-param[@name='functionID']"/>
						<xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
					</xsl:element>
					<xsl:element name="ignore_empty_result">Y</xsl:element>
				</xsl:element>
			</xsl:element>                          
									
			<xsl:choose>
				<xsl:when test="request-param[@name='existingServiceSubscriptionId'] != ''">
					<xsl:element name="CcmFifFindServiceSubsCmd">
						<xsl:element name="command_id">find_existing_service</xsl:element>
						<xsl:element name="CcmFifFindServiceSubsInCont">
							<xsl:element name="service_subscription_id">
								<xsl:value-of select="request-param[@name='existingServiceSubscriptionId']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>			
					
					<!-- Add Product Subscription -->
					<xsl:element name="CcmFifAddProductSubsCmd">
						<xsl:element name="command_id">add_product_subscription</xsl:element>
						<xsl:element name="CcmFifAddProductSubsInCont">
							<xsl:element name="customer_number">
								<xsl:value-of select="request-param[@name='customerNumber']"/>
							</xsl:element>
							<xsl:element name="product_commitment_number_ref">
								<xsl:element name="command_id">find_existing_service</xsl:element>
								<xsl:element name="field_name">product_commitment_number</xsl:element>
							</xsl:element>
							<xsl:element name="vis_tracking_position">
								<xsl:value-of select="request-param[@name='VISTrackingPosition']"/>
							</xsl:element>					
							<xsl:element name="suppress_billing_activation">
								<xsl:value-of select="request-param[@name='suppressBillingActivation']"/>
							</xsl:element>	
						</xsl:element>
					</xsl:element>					
				</xsl:when>
				<xsl:otherwise>					
					<xsl:choose>
						<xsl:when test="request-param[@name='serviceDeliveryContractNumber'] != ''
							and request-param[@name='productCommitmentNumber'] = ''">
							<!-- add SDCPC -->
							<xsl:element name="CcmFifAddSDCProdCommitCmd">
								<xsl:element name="command_id">add_product_commitment</xsl:element>
								<xsl:element name="CcmFifAddSDCProdCommitInCont">
									<xsl:element name="contract_number">
										<xsl:value-of select="request-param[@name='serviceDeliveryContractNumber']"/>
									</xsl:element>
									<xsl:element name="product_code">
										<xsl:value-of select="$productCode"/>										
									</xsl:element>
									<xsl:element name="pricing_structure_code">
										<xsl:value-of select="request-param[@name='tariff']"/>
									</xsl:element>
									<xsl:element name="notice_per_dur_value">
										<xsl:value-of select="$NoticePeriodDurationValue"/>
									</xsl:element>
									<xsl:element name="notice_per_dur_unit">
										<xsl:value-of select="$NoticePeriodDurationUnit"/>
									</xsl:element>
									<xsl:element name="term_start_date">
										<xsl:value-of select="$termStartDate"/>
									</xsl:element>
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
									<xsl:element name="termination_restriction">
										<xsl:value-of select="request-param[@name='terminationRestriction']"/>
									</xsl:element>
									<xsl:element name="doc_template_name">Vertrag</xsl:element>
									<xsl:element name="assoc_skeleton_cont_num">
										<xsl:value-of select="request-param[@name='assocSkeletonContNum']"/>
									</xsl:element>
									<xsl:element name="auto_extent_period_value">
										<xsl:value-of select="$AutoExtentPeriodValue"/>									
									</xsl:element>                         
									<xsl:element name="auto_extent_period_unit">
										<xsl:value-of select="$AutoExtentPeriodUnit"/>
									</xsl:element>                         
									<xsl:element name="auto_extension_ind">
										<xsl:value-of select="$AutoExtensionInd"/>
									</xsl:element>						
									<xsl:element name="special_termination_right">
										<xsl:value-of select="request-param[@name='specialTerminationRight']"/>
									</xsl:element>						
								</xsl:element>
							</xsl:element>
							
							<!-- sign SDC, if it is not signed yet TODO server code -->
							<xsl:element name="CcmFifSignServiceDelivContCmd">
								<xsl:element name="command_id">sign_sdc</xsl:element>
								<xsl:element name="CcmFifSignServiceDelivContInCont">
									<xsl:element name="contract_number">
										<xsl:value-of select="request-param[@name='serviceDeliveryContractNumber']"/>
									</xsl:element>
									<xsl:element name="board_sign_name">
										<xsl:value-of select="request-param[@name='boardSignName']"/>
									</xsl:element>
									<xsl:element name="board_sign_date">
										<xsl:value-of select="request-param[@name='boardSignDate']"/>
									</xsl:element>
									<xsl:element name="primary_cust_sign_name">
										<xsl:value-of select="request-param[@name='primaryCustSignName']"/>
									</xsl:element>
									<xsl:element name="primary_cust_sign_date">
										<xsl:value-of select="request-param[@name='primaryCustSignDate']"/>
									</xsl:element>
									<xsl:element name="secondary_cust_sign_name">
										<xsl:value-of select="request-param[@name='secondaryCustSignName']"/>
									</xsl:element>
									<xsl:element name="secondary_cust_sign_date">
										<xsl:value-of select="request-param[@name='secondaryCustSignDate']"/>
									</xsl:element>
									<xsl:element name="ignore_if_signed">Y</xsl:element>	
								</xsl:element>					
							</xsl:element>					
							
							<xsl:if test="request-param[@name='signProductCommitment'] != 'N'">								
								<!-- sign the newly created SDCPC -->
								<xsl:element name="CcmFifSignSDCProductCommitmentCmd">
									<xsl:element name="command_id">sign_sdc_1</xsl:element>
									<xsl:element name="CcmFifSignSDCProductCommitmentInCont">
										<xsl:element name="product_commitment_number_ref">
											<xsl:element name="command_id">add_product_commitment</xsl:element>
											<xsl:element name="field_name">product_commitment_number</xsl:element>
										</xsl:element>
										<xsl:element name="board_sign_name">
											<xsl:value-of select="request-param[@name='boardSignName']"/>
										</xsl:element>
										<xsl:element name="board_sign_date">
											<xsl:value-of select="request-param[@name='boardSignDate']"/>
										</xsl:element>
										<xsl:element name="primary_cust_sign_name">
											<xsl:value-of select="request-param[@name='primaryCustSignName']"/>
										</xsl:element>
										<xsl:element name="primary_cust_sign_date">
											<xsl:value-of select="request-param[@name='primaryCustSignDate']"/>
										</xsl:element>
										<xsl:element name="secondary_cust_sign_name">
											<xsl:value-of select="request-param[@name='secondaryCustSignName']"/>
										</xsl:element>
										<xsl:element name="secondary_cust_sign_date">
											<xsl:value-of select="request-param[@name='secondaryCustSignDate']"/>
										</xsl:element>
									</xsl:element>
								</xsl:element>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<!-- Create Order Form-->
							<xsl:if test="request-param[@name='productCommitmentNumber'] = ''">
								<xsl:element name="CcmFifCreateOrderFormCmd">
									<xsl:element name="command_id">create_order_form</xsl:element>
									<xsl:element name="CcmFifCreateOrderFormInCont">
										<xsl:element name="customer_number">
											<xsl:value-of select="request-param[@name='customerNumber']"/>
										</xsl:element>
										<xsl:element name="notice_per_dur_value">
											<xsl:value-of select="$NoticePeriodDurationValue"/>
										</xsl:element>
										<xsl:element name="notice_per_dur_unit">
											<xsl:value-of select="$NoticePeriodDurationUnit"/>
										</xsl:element>
										<xsl:element name="term_start_date">
											<xsl:value-of select="$termStartDate"/>
										</xsl:element>
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
										<xsl:element name="termination_restriction">
											<xsl:value-of select="request-param[@name='terminationRestriction']"/>
										</xsl:element>
										<xsl:element name="doc_template_name">Vertrag</xsl:element>
										<xsl:element name="assoc_skeleton_cont_num">
											<xsl:value-of select="request-param[@name='assocSkeletonContNum']"/>
										</xsl:element>
										<xsl:element name="auto_extent_period_value">
											<xsl:value-of select="$AutoExtentPeriodValue"/>
										</xsl:element>                         
										<xsl:element name="auto_extent_period_unit">
											<xsl:value-of select="$AutoExtentPeriodUnit"/>
										</xsl:element>                         
										<xsl:element name="auto_extension_ind">
											<xsl:value-of select="$AutoExtensionInd"/>
										</xsl:element>	
										<xsl:element name="name">
											<xsl:value-of select="$contractName"/>
											<xsl:text>-Vertrag</xsl:text>
										</xsl:element>											
									</xsl:element>
								</xsl:element>
								
								<!-- Add Order Form Product Commitment -->
								<xsl:element name="CcmFifAddProductCommitCmd">
									<xsl:element name="command_id">add_product_commitment</xsl:element>
									<xsl:element name="CcmFifAddProductCommitInCont">
										<xsl:element name="customer_number">
											<xsl:value-of select="request-param[@name='customerNumber']"/>
										</xsl:element>
										<xsl:element name="contract_number_ref">
											<xsl:element name="command_id">create_order_form</xsl:element>
											<xsl:element name="field_name">contract_number</xsl:element>
										</xsl:element>
										<xsl:element name="product_code">
											<xsl:value-of select="$productCode"/>
										</xsl:element>
										<xsl:element name="pricing_structure_code">
											<xsl:value-of select="request-param[@name='tariff']"/>
										</xsl:element>
									</xsl:element>
								</xsl:element>
								
								<xsl:if test="request-param[@name='signProductCommitment'] != 'N'">
									<!-- Sign Order Form -->
									<xsl:element name="CcmFifSignOrderFormCmd">
										<xsl:element name="command_id">sign_of</xsl:element>
										<xsl:element name="CcmFifSignOrderFormInCont">
											<xsl:element name="contract_number_ref">
												<xsl:element name="command_id">create_order_form</xsl:element>
												<xsl:element name="field_name">contract_number</xsl:element>
											</xsl:element>
											<xsl:element name="board_sign_name">
												<xsl:value-of select="request-param[@name='boardSignName']"/>
											</xsl:element>
											<xsl:element name="board_sign_date">
												<xsl:value-of select="request-param[@name='boardSignDate']"/>
											</xsl:element>
											<xsl:element name="primary_cust_sign_name">
												<xsl:value-of select="request-param[@name='primaryCustSignName']"/>
											</xsl:element>
											<xsl:element name="primary_cust_sign_date">
												<xsl:value-of select="request-param[@name='primaryCustSignDate']"/>
											</xsl:element>
											<xsl:element name="secondary_cust_sign_name">
												<xsl:value-of select="request-param[@name='secondaryCustSignName']"/>
											</xsl:element>
											<xsl:element name="secondary_cust_sign_date">
												<xsl:value-of select="request-param[@name='secondaryCustSignDate']"/>
											</xsl:element>
										</xsl:element>
									</xsl:element>
								</xsl:if>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
					
					<!-- Add Product Subscription -->
					<xsl:element name="CcmFifAddProductSubsCmd">
						<xsl:element name="command_id">add_product_subscription</xsl:element>
						<xsl:element name="CcmFifAddProductSubsInCont">
							<xsl:element name="customer_number">
								<xsl:value-of select="request-param[@name='customerNumber']"/>
							</xsl:element>
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
							<xsl:element name="vis_tracking_position">
								<xsl:value-of select="request-param[@name='VISTrackingPosition']"/>
							</xsl:element>	
							<xsl:element name="suppress_billing_activation">
								<xsl:value-of select="request-param[@name='suppressBillingActivation']"/>
							</xsl:element>	
						</xsl:element>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>

			<!-- Get Entity Information -->   
			<xsl:element name="CcmFifGetEntityCmd">
				<xsl:element name="command_id">get_entity</xsl:element>
				<xsl:element name="CcmFifGetEntityInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
