<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a BIT DSL contract

  @author pranjali 
-->
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
		<!-- Convert the desired date to OPM format -->
		<xsl:variable name="desiredDateOPM"
			select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
		<xsl:variable name="bandwidthCheckDate"
			select="dateutils:createOPMDate(request-param[@name='bandwidthCheckDate'])"/>
		<xsl:variable name="bandwidthCheckSourceDate"
			select="dateutils:createOPMDate(request-param[@name='bandwidthCheckSourceDate'])"/>
		
		<!-- Calculate today and one day before the desired date -->
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
		<xsl:element name="Command_List">
			<!-- Get Customer number if not provided-->
			<xsl:if test="(request-param[@name='customerNumber'] = '')">
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_external_notification_1</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Get Account number if not provided -->
			<xsl:if test="(request-param[@name='accountNumber'] = '')">
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_external_notification_2</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Get Entity Information -->   
			<xsl:element name="CcmFifGetEntityCmd">
				<xsl:element name="command_id">get_entity_1</xsl:element>
				<xsl:element name="CcmFifGetEntityInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:element>
			<!-- Create Address if not provided -->
			<xsl:if test="request-param[@name='addressId'] = ''">
			
				<!-- Create Address-->
				<xsl:element name="CcmFifCreateAddressCmd">
					<xsl:element name="command_id">create_address</xsl:element>
					<xsl:element name="CcmFifCreateAddressInCont">
						<xsl:element name="entity_ref">
							<xsl:element name="command_id">get_entity_1</xsl:element>
							<xsl:element name="field_name">entity_id</xsl:element>
						</xsl:element>
						<xsl:element name="address_type">STD</xsl:element>
						<xsl:element name="street_name">
							<xsl:value-of select="request-param[@name='streetName']"/>
						</xsl:element>
						<xsl:element name="street_number">
							<xsl:value-of select="request-param[@name='streetNumber']"/>
						</xsl:element>
						<xsl:element name="street_number_suffix">
							<xsl:value-of select="request-param[@name='numberSuffix']"/>
						</xsl:element>
						<xsl:element name="postal_code">
							<xsl:value-of select="request-param[@name='postalCode']"/>
						</xsl:element>
						<xsl:element name="city_name">
							<xsl:value-of select="request-param[@name='city']"/>
						</xsl:element>
						<xsl:element name="city_suffix_name">
							<xsl:value-of select="request-param[@name='citySuffix']"/>
						</xsl:element>
						<xsl:if test="request-param[@name='country']!=''">
							<xsl:element name="country_code">
								<xsl:value-of select="request-param[@name='country']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='country']=''">
							<xsl:element name="country_code">DE</xsl:element>
						</xsl:if>
						<xsl:element name="address_additional_text">
							<xsl:value-of select="request-param[@name='additionalText']"/>
						</xsl:element>
						<xsl:element name="set_primary_address">N</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
    		 <!-- Get sales oranisation numbers from previous contract-->	
			<xsl:if test="request-param[@name='salesRepresentativeDept'] != ''   and
			                   ( request-param[@name='reasonRd'] = 'MIG_PRE_BIT'  or request-param[@name='reasonRd'] = 'MIG_VOIP_BIT' )"> 
					
                <!-- Get PC data to retrievecontract number-->
                <xsl:element name="CcmFifGetProductCommitmentDataCmd">
                    <xsl:element name="command_id">get_old_contr_num</xsl:element>
                    <xsl:element name="CcmFifGetProductCommitmentDataInCont">
                            <xsl:element name="product_commitment_number">
                                <xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
                            </xsl:element>                       
                       <xsl:element name="retrieve_signed_version">Y</xsl:element>
                    </xsl:element>
                </xsl:element>			
			
                <!-- Get the sales org number  -->
                <xsl:element name="CcmFifGetCommissioningInformationDataCmd">
                    <xsl:element name="command_id">get_sales_org_number</xsl:element>
                    <xsl:element name="CcmFifGetCommissioningInformationDataInCont">
                       <xsl:element name="supported_object_id_ref">
                           <xsl:element name="command_id">get_old_contr_num</xsl:element>
                           <xsl:element name="field_name">contract_number</xsl:element>
                       </xsl:element>
                       <xsl:element name="supported_object_type_rd">O</xsl:element>
                       <xsl:element name="no_sales_org_number_error">Y</xsl:element>
                       <xsl:element name="cio_type_rd">Initial CIO</xsl:element>
                    </xsl:element>
                </xsl:element>
                
                   <!-- Get the sales org number VF  -->
                <xsl:element name="CcmFifGetCommissioningInformationDataCmd">
                    <xsl:element name="command_id">get_sales_org_number_vf</xsl:element>
                    <xsl:element name="CcmFifGetCommissioningInformationDataInCont">
                       <xsl:element name="supported_object_id_ref">
                           <xsl:element name="command_id">get_old_contr_num</xsl:element>
                           <xsl:element name="field_name">contract_number</xsl:element>
                       </xsl:element>
                       <xsl:element name="supported_object_type_rd">O</xsl:element>
                         <xsl:element name="no_sales_org_number_error">N</xsl:element>
                       <xsl:element name="cio_type_rd">VODAFONE</xsl:element>
                    </xsl:element>
                </xsl:element>
                
			</xsl:if>
			

			<xsl:if test="request-param[@name='productCommitmentNumber']= ''">
			    <!-- Create Order Form-->
				<xsl:element name="CcmFifCreateOrderFormCmd">
					<xsl:element name="command_id">create_order_form_1</xsl:element>
					<xsl:element name="CcmFifCreateOrderFormInCont">
						<xsl:if test="request-param[@name='customerNumber']=''">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">read_external_notification_1</xsl:element>
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
				        <xsl:choose>
					        <xsl:when test="request-param[@name='salesRepresentativeDept'] != ''   and
			                                ( request-param[@name='reasonRd'] = 'MIG_PRE_BIT'  or request-param[@name='reasonRd'] = 'MIG_VOIP_BIT' )"> 
					              <xsl:element name="sales_org_num_value_ref">
                                    <xsl:element name="command_id">get_sales_org_number</xsl:element>
                                    <xsl:element name="field_name">sales_org_number</xsl:element>
                                </xsl:element>
                                <xsl:element name="sales_org_num_value_vf_ref">
                                    <xsl:element name="command_id">get_sales_org_number_vf</xsl:element>
                                    <xsl:element name="field_name">sales_org_number</xsl:element>
                                </xsl:element>
					        </xsl:when>  										       
					        <xsl:otherwise>
					             <xsl:element name="sales_org_num_value">
						   	         <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
						        </xsl:element>												
						        <xsl:element name="sales_org_num_value_vf">
							        <xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
						        </xsl:element>
					        </xsl:otherwise>					        
				        </xsl:choose>				
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
						<xsl:element name="name">Bitstrom-DSL Vertrag</xsl:element>
					</xsl:element>
				</xsl:element>

			    <!-- Add Order Form Product Commitment -->
				<xsl:element name="CcmFifAddProductCommitCmd">
					<xsl:element name="command_id">add_product_commitment_1</xsl:element>
					<xsl:element name="CcmFifAddProductCommitInCont">
						<xsl:if test="request-param[@name='customerNumber']=''">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">read_external_notification_1</xsl:element>
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
						<xsl:element name="product_code">I1203</xsl:element>
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
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
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

			<!-- Check customer classification -->
			<xsl:element name="CcmFifGetCustomerDataCmd">
				<xsl:element name="command_id">get_customer_data</xsl:element>
				<xsl:element name="CcmFifGetCustomerDataInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:element>
			
			<!-- Concat the result of recent command to create promary value of cross reference  --> 
			<xsl:element name="CcmFifConcatStringsCmd">
				<xsl:element name="command_id">concat_primary_value</xsl:element>
				<xsl:element name="CcmFifConcatStringsInCont">
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">V0088_</xsl:element>							
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">get_customer_data</xsl:element>
							<xsl:element name="field_name">classification_rd</xsl:element>							
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>							
			
			<!-- Get service code value for given customer classification from reference data -->
			<xsl:element name="CcmFifGetCrossRefSecondaryValueCmd">
				<xsl:element name="command_id">get_cross_ref_data</xsl:element>
				<xsl:element name="CcmFifGetCrossRefSecondaryValueInCont">
					<xsl:element name="group_code">SCCLASSDEF</xsl:element>
					<xsl:element name="primary_value_ref">
						<xsl:element name="command_id">concat_primary_value</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>
					</xsl:element>
					<xsl:element name="ignore_empty_result">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Add Bit Main Service Subscription for  I1213 -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_1</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">I1213</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:if test="request-param[@name='reasonRd'] != ''">
						<xsl:element name="reason_rd">
							<xsl:value-of select="request-param[@name='reasonRd']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='reasonRd'] = ''">
						<xsl:element name="reason_rd">CREATE_BIT_DSL</xsl:element>
					</xsl:if>

					<xsl:if test="request-param[@name='accountNumber']=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='accountNumber']!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="request-param[@name='accountNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">
						<!-- Standort  Addresse -->
						<xsl:if test="request-param[@name='addressId']=''">
							<xsl:element name="CcmFifAddressCharacteristicCont">
								<xsl:element name="service_char_code">V0014</xsl:element>
								<xsl:element name="data_type">ADDRESS</xsl:element>
								<xsl:element name="address_ref">
									<xsl:element name="command_id">create_address</xsl:element>
									<xsl:element name="field_name">address_id</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='addressId']!=''">
							<xsl:element name="CcmFifAddressCharacteristicCont">
								<xsl:element name="service_char_code">V0014</xsl:element>
								<xsl:element name="data_type">ADDRESS</xsl:element>
								<xsl:element name="address_id">
									<xsl:value-of select="request-param[@name='addressId']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Activation Date -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0909</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$desiredDateOPM" /> 
							</xsl:element>
						</xsl:element>

						<!-- Dial-In Account Name -->
						<xsl:element name="CcmFifAccessNumberCont">
							<xsl:element name="service_char_code">I9058</xsl:element>
							<xsl:element name="data_type">USER_ACCOUNT_NUM</xsl:element>
							<xsl:element name="network_account"/>
						</xsl:element>

						<!-- Quelle der BB Info -->
						<xsl:if test="request-param[@name='bandwidthCheckProcedure']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">I1016</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='bandwidthCheckProcedure']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Datum BB Ermittlung -->
						<xsl:if test="request-param[@name='bandwidthCheckDate'] != ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">I1017</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="$bandwidthCheckDate"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Genauigkeit BB Info -->
						<xsl:if test="request-param[@name='bandwidthCheckAccuracy']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">I1018</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='bandwidthCheckAccuracy']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Datum VFP Abfrage Frontend -->
						<xsl:if test="request-param[@name='bandwidthCheckSourceDate'] != ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">I1019</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="$bandwidthCheckSourceDate"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
								
						<!-- DSLBandbreite -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0826</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:if test="request-param[@name='dslBandwidth']!= ''">
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='dslBandwidth']"/>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='dslBandwidth']= ''">
								<xsl:element name="configured_value">DSL 16000</xsl:element>
							</xsl:if>
						</xsl:element>
						<!-- Upstream Bandbreite -->
						<xsl:if test="request-param[@name='upstreamBandwidth']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0092</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='upstreamBandwidth']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Project Order Indicator -->
						<xsl:if test="request-param[@name='projectOrderIndicator']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0104</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='projectOrderIndicator']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Sales Segment -->
						<xsl:if test="request-param[@name='salesSegment']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0105</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='salesSegment']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Location TAE -->
						<xsl:if test="request-param[@name='locationTAE']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0123</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='locationTAE']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Kondition/Rabatt -->
						<xsl:if test="request-param[@name='rabatt']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0097</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='rabatt']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Kondition/Rabatt Indicator -->
						<xsl:if test="request-param[@name='rabattIndicator']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0162</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='rabattIndicator']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Special Time Window -->
						<xsl:if test="request-param[@name='specialTimeWindow']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0139</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='specialTimeWindow']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Fixed Order date -->
						<xsl:if test="request-param[@name='fixedOrderDateIndicator']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0140</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='fixedOrderDateIndicator']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Special-Letter Indicator  -->
						<xsl:if test="request-param[@name='reasonRd'] = 'BIT_TO_BITVDSL'">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0216</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">BK-Wechsel auf BIT-VDSL</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Automatic Mailing  -->
						<xsl:if test="request-param[@name='automaticMailingIndicator']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0131</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='automaticMailingIndicator']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- ASB -->
						<xsl:if test="request-param[@name='ASB']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0934</xsl:element>
								<xsl:element name="data_type">INTEGER</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='ASB']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Carrier -->
						<xsl:if test="request-param[@name='carrier']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0081</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='carrier']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- ONKZ -->
						<xsl:if test="request-param[@name='ONKZ']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0124</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='ONKZ']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- V0094 -->
						<xsl:if test="request-param[@name='oldAccess']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0094</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='oldAccess']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>						
						<!-- IT16902 :  Allow Bandwidth Downgrade V0875 -->
						<xsl:if test="request-param[@name='allowDowngrade']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0875</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='allowDowngrade']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						
						<!-- IT16902: Desired Original Bandwidth V0876 -->
						<xsl:if test="request-param[@name='desiredBandwidth']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0876</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='desiredBandwidth']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>	
						<!-- Service Provider -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0088</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">get_cross_ref_data</xsl:element>
								<xsl:element name="field_name">secondary_value</xsl:element>          	
							</xsl:element>
						</xsl:element>	
						<!-- Dial-In Account Name -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I9058</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='dialInAccountName']"/>
							</xsl:element>
						</xsl:element>											
						
                       <!-- V0144 -->
						<xsl:if test="request-param[@name='lineId']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0144</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='lineId']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>						
						 <!-- V0152 -->
						<xsl:if test="request-param[@name='technicalServiceId']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0152</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='technicalServiceId']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>						
						 <!-- V0153 -->
						<xsl:if test="request-param[@name='IADPin']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0153</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='IADPin']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>						
						 <!-- Z0100 -->
						<xsl:if test="request-param[@name='networkElementId']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">Z0100</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='networkElementId']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>																			
						<!-- Instant Access -->
						<xsl:if test="request-param[@name='instantAccess']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V8003</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='instantAccess']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>				
						<!-- Port Type-->
						<xsl:if test="request-param[@name='VDSLPort'] = 'Y'">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V009C</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">VDSL</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='VDSLPort'] != 'Y'">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V009C</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">ADSL</xsl:element>
							</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Add Feature  Service V0083  -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_2</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0083</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:if test="request-param[@name='reasonRd'] != ''">
						<xsl:element name="reason_rd">
							<xsl:value-of select="request-param[@name='reasonRd']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='reasonRd'] = ''">
						<xsl:element name="reason_rd">CREATE_BIT_DSL</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='accountNumber']=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='accountNumber']!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="request-param[@name='accountNumber']"/>
						</xsl:element>
					</xsl:if>					
					<xsl:element name="service_characteristic_list"/>										
				</xsl:element>
			</xsl:element>

			<!-- Add Feature  Service V0017 Monthly Charge  -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_3</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0017</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:if test="request-param[@name='reasonRd'] != ''">
						<xsl:element name="reason_rd">
							<xsl:value-of select="request-param[@name='reasonRd']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='reasonRd'] = ''">
						<xsl:element name="reason_rd">CREATE_BIT_DSL</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='accountNumber']=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='accountNumber']!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="request-param[@name='accountNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list"/>
				</xsl:element>
			</xsl:element>
			<!-- Add Feature  Service V0099 Bonus My Company  if bonusIndicator  is  set -->
			<xsl:if test="request-param[@name='bonusIndicator'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_4</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0099</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_DSL</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Add Feature  Service V0118 DSL Anschluss 1000  if dslBandwidth is  DSL 1000   -->
			<xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 1000'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_6</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0118</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_DSL</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Add Feature  Service V0174 DSL Anschluss 2000  if dslBandwidth is DSL 2000   -->
			<xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 2000'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_7</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0174</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_DSL</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Add Feature  Service V0178 DSL Anschluss 6000  if dslBandwidth6000  is  set -->
			<xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 6000'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_8</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0178</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_DSL</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Add Feature  Service V018C  DSL Anschluss 16000   if dslBandwidth16000  is  set -->
			<xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 16000'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_9</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V018C</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_DSL</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Add Feature  Service V018G  DSL Anschluss 25000   if dslBandwidth25000  is  set -->
			<xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 25000'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_10</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V018G</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_DSL</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Add Feature  Service V018H  DSL Anschluss 50000   if dslBandwidth50000  is  set -->
			<xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 50000'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_10</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V018H</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_DSL</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Add service level Service -->
			<xsl:if test="request-param[@name='serviceLevel'] != ''">
				<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_11</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">
						<xsl:if test="request-param[@name='serviceLevel'] = 'classic'">
							<xsl:text>S0106</xsl:text>
						</xsl:if>
						<xsl:if test="request-param[@name='serviceLevel'] = 'classicPlus'">
							<xsl:text>S0144</xsl:text>
						</xsl:if>	
					    <xsl:if test="request-param[@name='serviceLevel'] = 'premium'">
					        <xsl:text>V0459</xsl:text>
					    </xsl:if>
					    <xsl:if test="request-param[@name='serviceLevel'] = 'comfort'">
					        <xsl:text>V0461</xsl:text>
					    </xsl:if>
					</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:if test="request-param[@name='reasonRd'] != ''">
						<xsl:element name="reason_rd">
							<xsl:value-of select="request-param[@name='reasonRd']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='reasonRd'] = ''">
						<xsl:element name="reason_rd">CREATE_BIT_DSL</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='accountNumber']=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='accountNumber']!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="request-param[@name='accountNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list"/>
				</xsl:element>
			</xsl:element>
			</xsl:if>
			

	        <!-- Add Feature  Service I1045   FastPath  is  set -->
			<xsl:if test="request-param[@name='fastPathIndicator'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_12</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">I1045</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_DSL</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>

			<!-- Add Upstream Service, if requested -->
			<xsl:if test="((request-param[@name='upstreamBandwidth'] = '384')
				and (request-param[@name='dslBandwidth'] = 'DSL 2000'))">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_13</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0198</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_7</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="request-param[@name='$today']"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:element name="reason_rd">CREATE_BIT_DSL</xsl:element>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>

			<!-- check for existing bundle if bundleId id was provided -->
			<xsl:if test="request-param[@name='bundleId'] != ''">			
				<xsl:element name="CcmFifFindBundleCmd">
					<xsl:element name="command_id">find_bundle_1</xsl:element>
					<xsl:element name="CcmFifFindBundleInCont">
						<xsl:element name="bundle_id">
							<xsl:value-of select="request-param[@name='bundleId']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- create new bundle for BIT DSL contracts-->
			<xsl:element name="CcmFifModifyBundleCmd">
				<xsl:element name="command_id">modify_bundle_1</xsl:element>
				<xsl:element name="CcmFifModifyBundleInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">find_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>	
					<xsl:element name="bundle_found_ref">
						<xsl:element name="command_id">find_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>							
					</xsl:element>		
				</xsl:element>
			</xsl:element>
	
			<!-- Set ao_status on bundle -->
			<xsl:element name="CcmFifModifyBundleCmd">
				<xsl:element name="command_id">set_ao_status_on_bundle</xsl:element>
				<xsl:element name="CcmFifModifyBundleInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">modify_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="ao_status">
						<xsl:value-of select="request-param[@name='aoMastered']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- add the new  bundle item of type ACCESS -->
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item_1</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">modify_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd">BITACCESS</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- add the new  bundle item of type ONLINE -->
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item_2</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">modify_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd">BITONLINE</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Create Customer Order for new services  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
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
						<!-- I1210-->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<!-- V0083 -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_2</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<!-- V0017 -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_3</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<!-- V0099 -->
						<xsl:if test="request-param[@name='bonusIndicator'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_4</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- V0118 -->
						<xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 1000'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_6</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- V0174 -->
						<xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 2000'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_7</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- V0178 -->
						<xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 6000'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_8</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- V018C -->
						<xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 16000'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_9</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- V018G or V018H -->
						<xsl:if test="(request-param[@name='dslBandwidth'] = 'DSL 25000'
							or request-param[@name='dslBandwidth'] = 'DSL 50000')">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_10</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- service level -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_11</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<!-- I1045 -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_12</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
                        <!-- V0198 -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_13</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>						
					</xsl:element>
					<xsl:element name="e_shop_id">
						<xsl:value-of select="request-param[@name='eShopID']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Release stand alone customer Order --> 
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">release_co_1</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_1</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
				</xsl:element>
				</xsl:element>


			<!-- Create contact  for Service Addition -->
		    <xsl:if test="request-param[@name='productCommitmentNumber']=''">
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact_1</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="contact_type_rd">CUSTOMER_ORDER</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>BIT DSL contract created.</xsl:text>
					</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
						<xsl:text>&#xA;BIT DSL Contract has been created on:</xsl:text>
						<xsl:if test="request-param[@name='desiredDate']!=''">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:if>
						<xsl:if test="request-param[@name='desiredDate'] = ''">
							<xsl:value-of select="$today"/>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			</xsl:if>
            
            <!-- Create contact  for Service Addition -->
		    <xsl:if test="request-param[@name='productCommitmentNumber']!=''">
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact_1_ps</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="contact_type_rd">CUSTOMER_ORDER</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>BIT DSL Product subscription.</xsl:text>
					</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
						<xsl:text>&#xA;BIT DSL Product subscription has been added on:</xsl:text>
						<xsl:if test="request-param[@name='desiredDate']!=''">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:if>
						<xsl:if test="request-param[@name='desiredDate'] = ''">
							<xsl:value-of select="$today"/>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			</xsl:if>

			
			<!--  Create  external notification if the requestListId is set  -->
			<xsl:if test="request-param[@name='requestListId'] != ''">
				<xsl:element name="CcmFifCreateExternalNotificationCmd">
					<xsl:element name="command_id">create_notification_1</xsl:element>
					<xsl:element name="CcmFifCreateExternalNotificationInCont">
						<xsl:element name="effective_date">
							<xsl:if test="request-param[@name='desiredDate'] != ''">
								<xsl:value-of select="request-param[@name='desiredDate']"/>
							</xsl:if>
							<xsl:if test="request-param[@name='desiredDate'] = ''">
								<xsl:value-of select="$today"/>
							</xsl:if>
						</xsl:element>
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="processed_indicator">Y</xsl:element>
						<xsl:element name="notification_action_name">CreateBitDslContract</xsl:element>
						<xsl:element name="target_system">FIF</xsl:element>
						<xsl:element name="parameter_value_list">
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">BitDSL_SERVICE_SUBSCRIPTION_ID</xsl:element>
								<xsl:element name="parameter_value_ref">
									<xsl:element name="command_id">add_service_1</xsl:element>
									<xsl:element name="field_name">service_subscription_id</xsl:element>
								</xsl:element>
							</xsl:element>							
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">CUSTOMER_ORDER_ID</xsl:element>
								<xsl:element name="parameter_value_ref">
									<xsl:element name="command_id">create_co_1</xsl:element>
									<xsl:element name="field_name">customer_order_id</xsl:element>
								</xsl:element>
							</xsl:element>
							<xsl:if test="request-param[@name='reasonRd'] != ''">
						    	<xsl:element name="CcmFifParameterValueCont">
	                				<xsl:element name="parameter_name">BitDSL_DETAILED_REASON_RD</xsl:element>
	                				<xsl:element name="parameter_value">
										<xsl:value-of select="request-param[@name='reasonRd']"/>
	                				</xsl:element>
	              				</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='reasonRd'] = ''">
						    	<xsl:element name="CcmFifParameterValueCont">
	                				<xsl:element name="parameter_name">BitDSL_DETAILED_REASON_RD</xsl:element>
	                				<xsl:element name="parameter_value">CREATE_BIT_DSL</xsl:element>
	              				</xsl:element>
							</xsl:if>
						
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
	
           
		</xsl:element>

	</xsl:template>
</xsl:stylesheet>
