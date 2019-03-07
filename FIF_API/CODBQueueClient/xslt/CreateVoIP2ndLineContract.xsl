<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a IPCSEAT contract

  @author schwarje 
-->

<!DOCTYPE XSL [

<!ENTITY CSCMapping SYSTEM "CSCMapping.xsl">
<!ENTITY CSCMapping_VoIP2ndLine SYSTEM "CSCMapping_VoIP2ndLine.xsl">
<!ENTITY CSCMapping_AddressCreation SYSTEM "CSCMapping_AddressCreation.xsl">
]>

<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1" indent="yes" method="xml"/>
	<xsl:template match="/">
		<xsl:element name="CcmFifCommandList">
			<xsl:apply-templates select="request/request-params"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="request-params">
		<!-- Copy over transaction ID and action name -->
		<xsl:element name="transaction_id">
			<xsl:value-of select="request-param[@name='transactionID']"/>
		</xsl:element>
		<xsl:element name="client_name">
			<xsl:value-of select="request-param[@name='clientName']"/>
		</xsl:element>
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
		</xsl:element>
		
		<!-- variable for indicating that this is not a reconfiguration -->
		<xsl:variable name="isReconfiguration">N</xsl:variable>
		
		<!-- Calculate today and one day before the desired date -->
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
		
		<xsl:variable name="desiredDate">
			<xsl:choose>
				<xsl:when test="request-param[@name='desiredDate'] = 'today'">
					<xsl:value-of select="$today"/>
				</xsl:when>
				<xsl:when test="request-param[@name='desiredDate'] != ''">
					<xsl:value-of select="request-param[@name='desiredDate']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$today"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Convert the desired date to OPM format -->
		<xsl:variable name="activationDateOPM"
			select="dateutils:createOPMDate(request-param[@name='activationDate'])"/>
		
		<xsl:element name="Command_List">
			
			<!-- Get Entity Information -->   
			<xsl:element name="CcmFifGetEntityCmd">
				<xsl:element name="command_id">get_entity</xsl:element>
				<xsl:element name="CcmFifGetEntityInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
				&CSCMapping_VoIP2ndLine;
				&CSCMapping_AddressCreation;
			</xsl:for-each>
			
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
						</xsl:element>
					</xsl:element>					
				</xsl:when>
				<xsl:otherwise>					
					<xsl:choose>
						<xsl:when test="request-param[@name='serviceDeliveryContractNumber'] != ''">
							<!-- add SDCPC -->
							<xsl:element name="CcmFifAddSDCProdCommitCmd">
								<xsl:element name="command_id">add_product_commitment</xsl:element>
								<xsl:element name="CcmFifAddSDCProdCommitInCont">
									<xsl:element name="contract_number">
										<xsl:value-of select="request-param[@name='serviceDeliveryContractNumber']"/>
									</xsl:element>
									<xsl:element name="product_code">VI201</xsl:element>
									<xsl:element name="pricing_structure_code">
										<xsl:value-of select="request-param[@name='tariff']"/>
									</xsl:element>
									<xsl:element name="notice_per_dur_value">
										<xsl:value-of select="request-param[@name='noticePeriodDurationValue']"/>
									</xsl:element>
									<xsl:element name="notice_per_dur_unit">
										<xsl:value-of select="request-param[@name='noticePeriodDurationUnit']"/>
									</xsl:element>
									<xsl:element name="term_start_date">
										<xsl:value-of select="request-param[@name='termStartDate']"/>
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
										<xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>
									</xsl:element>                         
									<xsl:element name="auto_extent_period_unit">
										<xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>
									</xsl:element>                         
									<xsl:element name="auto_extension_ind">
										<xsl:value-of select="request-param[@name='autoExtensionInd']"/>
									</xsl:element>						
									<xsl:element name="special_termination_right">
										<xsl:value-of select="request-param[@name='specialTerminationRight']"/>
									</xsl:element>						
								</xsl:element>
							</xsl:element>
							
							<!-- sign SDC, if it is not signed yet server code -->
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
											<xsl:value-of select="request-param[@name='noticePeriodDurationValue']"/>
										</xsl:element>
										<xsl:element name="notice_per_dur_unit">
											<xsl:value-of select="request-param[@name='noticePeriodDurationUnit']"/>
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
											<xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>
										</xsl:element>                         
										<xsl:element name="auto_extent_period_unit">
											<xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>
										</xsl:element>                         
										<xsl:element name="auto_extension_ind">
											<xsl:value-of select="request-param[@name='autoExtensionInd']"/>
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
										<xsl:element name="product_code">VI201</xsl:element>
										<xsl:element name="pricing_structure_code">
											<xsl:value-of select="request-param[@name='tariff']"/>
										</xsl:element>
									</xsl:element>
								</xsl:element>
								
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
						</xsl:element>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- Add IP-Centrex Seat main service Subscription -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_main_service</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">VI201</xsl:element>
					<xsl:element name="service_subscription_id">
						<xsl:value-of select="request-param[@name='allocatedServiceSubscriptionId']"/>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reason']"/>
					</xsl:element>
					<xsl:element name="account_number">
						<xsl:value-of select="request-param[@name='accountNumber']"/>
					</xsl:element>
					<xsl:element name="service_characteristic_list">
						<xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
							&CSCMapping_VoIP2ndLine;
							&CSCMapping;
						</xsl:for-each>
						<!-- Aktivierungsdatum -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0909</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$activationDateOPM" /> 
							</xsl:element>
						</xsl:element>						
					</xsl:element>
				</xsl:element>				
			</xsl:element>						
			
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_monthly_charge</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">VI220</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_main_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$desiredDate"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reason']"/>
					</xsl:element>
					<xsl:element name="account_number">
						<xsl:value-of select="request-param[@name='accountNumber']"/>
					</xsl:element>
					<xsl:element name="service_characteristic_list"/>					
				</xsl:element>				
			</xsl:element>
						
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
			
			<!-- add the new  bundle item of type IPCENTREX_SEAT -->
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">read_bundle_id</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd">VOIP_SERVICE</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">add_main_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Customer Order for new services  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>					
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
					</xsl:element>
					<xsl:element name="lan_path_file_string">
						<xsl:value-of select="request-param[@name='lanPathFileString']"/>
					</xsl:element>
					<xsl:element name="sales_rep_dept">
						<xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">
						<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
					</xsl:element>
					<xsl:element name="super_customer_tracking_id">
						<xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
					</xsl:element>
					<xsl:element name="scan_date">
						<xsl:value-of select="request-param[@name='scanDate']"/>
					</xsl:element>
					<xsl:element name="order_entry_date">
						<xsl:value-of select="request-param[@name='entryDate']"/>
					</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_main_service</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_monthly_charge</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="e_shop_id">
						<xsl:value-of select="request-param[@name='eShopID']"/>
					</xsl:element>
					<xsl:element name="processing_status">
						<xsl:value-of select="request-param[@name='processingStatus']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
						
			<xsl:if test="request-param[@name='processingStatus'] = ''">
				<xsl:element name="CcmFifReleaseCustOrderCmd">
					<xsl:element name="CcmFifReleaseCustOrderInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>					
						<xsl:element name="customer_order_ref">
							<xsl:element name="command_id">create_co</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>        
			</xsl:if>
						
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_main_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">add_main_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>			
			
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact_1</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">VOIP_CONTRACT</xsl:element>
					<xsl:element name="short_description">VoIP-2ndLine erstellt</xsl:element>
					<xsl:element name="description_text_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>VoIP-2ndLine-Vertrag (</xsl:text>
								<xsl:value-of select="request-param[@name='seatType']"/>
								<xsl:text>) erstellt.&#xA;Vertragsnummer: </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">contract_number</xsl:element>          
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>&#xA;Produktnutzung: </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_product_subscription</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>          
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">                								
								<xsl:text>&#xA;TransactionID: </xsl:text>
								<xsl:value-of select="request-param[@name='transactionID']"/>
								<xsl:text> (</xsl:text>
								<xsl:value-of select="request-param[@name='clientName']"/>
								<xsl:text>)</xsl:text>
							</xsl:element>
						</xsl:element>
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
								<xsl:value-of select="request-param[@name='reason']"/>
							</xsl:element>
						</xsl:element>							
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">
								<xsl:value-of select="request-param[@name='functionID']"/>
								<xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
							</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">create_co</xsl:element>
								<xsl:element name="field_name">customer_order_id</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create external notification -->
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<xsl:element name="command_id">create_external_notification_1</xsl:element>
				<xsl:element name="CcmFifCreateExternalNotificationInCont">
					<xsl:element name="effective_date">
						<xsl:value-of select="$desiredDate"/>
					</xsl:element>
					<xsl:element name="notification_action_name">createPOSNotification</xsl:element>
					<xsl:element name="target_system">POS</xsl:element>
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='customerNumber']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TYPE</xsl:element>
							<xsl:element name="parameter_value">CONTACT</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">USER_NAME</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='clientName']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">WORK_DATE</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="$desiredDate"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">BARCODE</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
							<xsl:element name="parameter_value"> 
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">SERVICE_SUBSCRIPTION_ID</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CONTRACT_NUMBER</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">contract_number</xsl:element>
							</xsl:element>
						</xsl:element> 
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CUSTOMER_ORDER</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">create_co</xsl:element>
								<xsl:element name="field_name">customer_order_id</xsl:element>
							</xsl:element>
						</xsl:element> 
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">SALES_ORGANISATION_NUMBER</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">BOARD_SIGN_DATE</xsl:element>
							<xsl:if test="request-param[@name='boardSignName'] != ''"> 
								<xsl:element name="parameter_value"> 
									<xsl:value-of select="request-param[@name='boardSignDate']"/>
								</xsl:element>
							</xsl:if> 
							<xsl:if test="request-param[@name='boardSignName'] = ''"> 
								<xsl:element name="parameter_value"> 
									<xsl:value-of select="$today"/>
								</xsl:element>
							</xsl:if>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">BOARD_SIGN_NAME</xsl:element>
							<xsl:element name="parameter_value">             
								<xsl:value-of select="request-param[@name='boardSignName']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">PRIMARY_CUST_SIGN_DATE</xsl:element>
							<xsl:if test="request-param[@name='primaryCustSignDate'] != ''"> 
								<xsl:element name="parameter_value"> 
									<xsl:value-of select="request-param[@name='primaryCustSignDate']"/>
								</xsl:element>
							</xsl:if> 
							<xsl:if test="request-param[@name='primaryCustSignDate'] = ''"> 
								<xsl:element name="parameter_value"> 
									<xsl:value-of select="$today"/>
								</xsl:element>
							</xsl:if>                 
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">PRIMARY_CUST_SIGN_NAME</xsl:element>
							<xsl:element name="parameter_value">              
								<xsl:value-of select="request-param[@name='primaryCustSignName']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">PRODUCT_CODE</xsl:element>
							<xsl:element name="parameter_value">VI201</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TARIFF_CODE</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='tariff']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TEXT</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:text>VoIP Second Line</xsl:text>
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
			
			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
