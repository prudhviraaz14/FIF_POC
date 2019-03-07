<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a NGN DSL contract

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

		<!-- Calculate today and one day before the desired date -->
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
		<xsl:element name="Command_List">			
			<xsl:variable name="detailedReasonRd">
				<xsl:choose>
					<xsl:when test="request-param[@name='serviceProvider'] != request-param[@name='oldServiceProvider'] and
						request-param[@name='oldServiceProvider'] != ''">
						<xsl:choose>
							<xsl:when test="request-param[@name='oldVoiceServiceCode'] = 'VI003' and
								request-param[@name='VoIPServiceType'] = 'Premium'">PV_NP-NP</xsl:when>
							<xsl:when test="request-param[@name='oldVoiceServiceCode'] = 'VI003' and
								request-param[@name='VoIPServiceType'] = 'Basis'">PV_PC_NP-NB</xsl:when>					
							<xsl:when test="request-param[@name='oldVoiceServiceCode'] = 'VI002' and
								request-param[@name='VoIPServiceType'] = 'Premium'">PV_PC_NB-NP</xsl:when>
							<xsl:when test="request-param[@name='oldVoiceServiceCode'] = 'VI002' and
								request-param[@name='VoIPServiceType'] = 'Basis'">PV_NB-NB</xsl:when>					
							<xsl:when test="request-param[@name='oldVoiceServiceCode'] = 'V0010' and
								request-param[@name='VoIPServiceType'] = 'Premium'">PV_TC_IP-NP</xsl:when>
							<xsl:when test="request-param[@name='oldVoiceServiceCode'] = 'V0010' and
								request-param[@name='VoIPServiceType'] = 'Basis'">PV_TC_PC_IP-NB</xsl:when>					
							<xsl:when test="request-param[@name='oldVoiceServiceCode'] = 'V0003' and
								request-param[@name='VoIPServiceType'] = 'Premium'">PV_TC_PC_IB-NP</xsl:when>	
							<xsl:when test="request-param[@name='oldVoiceServiceCode'] = 'V0003' and
								request-param[@name='VoIPServiceType'] = 'Basis'">PV_TC_IB-NB</xsl:when>
							<xsl:otherwise></xsl:otherwise>
						</xsl:choose>	
					</xsl:when>	
					<xsl:otherwise></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>	
			
			<xsl:variable name="OnlineServiceCode">
				<xsl:choose>
					<xsl:when test="request-param[@name='lineType'] = 'FTTx'">I121z</xsl:when>					
					<xsl:otherwise>I1210</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="DSLServiceCode">
				<xsl:choose>
					<xsl:when test="request-param[@name='dslBandwidth'] = 'DSL 1000'">V0118</xsl:when>
					<xsl:when test="request-param[@name='dslBandwidth'] = 'DSL 2000'">V0174</xsl:when>
					<xsl:when test="request-param[@name='dslBandwidth'] = 'DSL 6000'">V0178</xsl:when>
					<xsl:when test="request-param[@name='dslBandwidth'] = 'DSL 16000'">V018C</xsl:when>
					<xsl:when test="request-param[@name='dslBandwidth'] = 'DSL 25000'">V018G</xsl:when>
					<xsl:when test="request-param[@name='dslBandwidth'] = 'DSL 50000'">V018H</xsl:when>
					<xsl:when test="request-param[@name='dslBandwidth'] = 'DSL 100000'">V018N</xsl:when>					
					<xsl:otherwise>unknown</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
		
		
			<!-- Ensure that the  bandwidth DSL 100 000 is used for FTTx only -->
			<xsl:if test="request-param[@name='dslBandwidth'] = 'DSL 100000'
				and request-param[@name='Linetyp'] != 'FTTx'">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">dsl_bandwidth_error</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">DSL 100 000 can be used for FTTx only!</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
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
			<!-- Create Order Form-->
			<xsl:if test="request-param[@name='productCommitmentNumber']= ''">
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
						<xsl:element name="product_code">I1204</xsl:element>
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
			
			<xsl:if test="request-param[@name='serviceProvider'] = ''">
				<!-- Concat the result of recent command to create primary value of cross reference  --> 
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
			</xsl:if>
			<!-- Add NGN Main Service Subscription -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_1</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">
						<xsl:value-of select="$OnlineServiceCode"/>
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
						<xsl:element name="reason_rd">CREATE_NGN_DSL</xsl:element>
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
						<!-- Order Variant -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0810</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of
									select="request-param[@name='orderVariant']"/>
							</xsl:element>
						</xsl:element>
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
						<!-- Kondition/Rabatt ID -->
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
						<xsl:if test="request-param[@name='serviceProvider'] = ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0088</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value_ref">
									<xsl:element name="command_id">get_cross_ref_data</xsl:element>
									<xsl:element name="field_name">secondary_value</xsl:element>          	
								</xsl:element>
							</xsl:element>	
						</xsl:if>
						<xsl:if test="request-param[@name='serviceProvider'] != ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0088</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='serviceProvider']"/>
								</xsl:element>								
							</xsl:element>	
						</xsl:if>
						<!-- Multimedia-VC -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I1323</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='multimediaProduct']"/>
							</xsl:element>
						</xsl:element>	
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
						<xsl:if test="request-param[@name='oldCustomerNumber'] != ''">
							<!--  Provider change -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0945</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='oldCustomerNumber']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>																															
						<!-- Port Type-->
						<xsl:if test="request-param[@name='VDSLPort'] = 'Y'
							and request-param[@name='portType'] = ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V009C</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">VDSL</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='VDSLPort'] != 'Y'
							and request-param[@name='portType'] = ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V009C</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">ADSL</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- portType-->
						<xsl:if test="request-param[@name='portType'] != ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V009C</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='portType']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>	
						<!-- Leitungstyp -->
						<xsl:if test="request-param[@name='lineType'] = 'FTTx'">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0138</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">FTTx</xsl:element>
							</xsl:element>
							<!-- Bearbeitungsart 
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0971</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">FTTx</xsl:element>
								</xsl:element> -->
						</xsl:if>
					</xsl:element>
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
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
						<xsl:element name="reason_rd">CREATE_NGN_DSL</xsl:element>
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
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>									
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
						<xsl:element name="reason_rd">CREATE_NGN_DSL</xsl:element>
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
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
					</xsl:element>
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
							<xsl:element name="reason_rd">CREATE_NGN_DSL</xsl:element>
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
						<xsl:element name="detailed_reason_rd">
							<xsl:value-of select="$detailedReasonRd"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Add DSL service if dslBandwidth is  set -->
			<xsl:if test="request-param[@name='dslBandwidth'] != ''">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_dsl</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:value-of select="$DSLServiceCode"/>
							
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
							<xsl:element name="reason_rd">CREATE_NGN_DSL</xsl:element>
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
						<xsl:element name="detailed_reason_rd">
							<xsl:value-of select="$detailedReasonRd"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>


			<!-- Add service level Service -->
			<xsl:if test="request-param[@name='serviceLevel'] != ''">
				<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_service_level</xsl:element>
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
							<xsl:text>V0070</xsl:text>
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
						<xsl:element name="reason_rd">CREATE_NGN_DSL</xsl:element>
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
					<xsl:element name="detailed_reason_rd">
						<xsl:value-of select="$detailedReasonRd"/>
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
			
			<!-- create new bundle for NGN DSL contracts-->
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
					<xsl:element name="bundle_item_type_rd">ACCESS</xsl:element>
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
					<xsl:element name="bundle_item_type_rd">ONLINE</xsl:element>
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
						<!-- DSL Service -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_dsl</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<!-- service level -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_service_level</xsl:element>
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
			<xsl:if test="request-param[@name='serviceProvider'] != request-param[@name='oldServiceProvider'] and
				request-param[@name='oldServiceProvider'] != ''">					
				<!-- Create contact provider change -->
				<xsl:element name="CcmFifCreateContactCmd">
					<xsl:element name="command_id">create_contact_prov_change_1</xsl:element>
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
						
						<xsl:element name="contact_type_rd">PROV_CHG_ACT</xsl:element>
						<xsl:element name="short_description">
							<xsl:text>Provider-Change Activation</xsl:text>
						</xsl:element>
						<xsl:element name="long_description_text">
							<xsl:text>TransactionID: </xsl:text>
							<xsl:value-of select="request-param[@name='transactionID']"/>
							<xsl:text>&#xA;New ISDN contract is part of Provider Change from customer: </xsl:text>
							<xsl:value-of select="request-param[@name='oldCustomerNumber']"/>	
							<xsl:text>&#xA;Parent-Barcode: </xsl:text>
							<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
							<xsl:text>&#xA;Parent-PTN: </xsl:text>
							<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>	
							<xsl:text>&#xA;Desired date: </xsl:text>						
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
			
			<xsl:if test="request-param[@name='serviceProvider'] = request-param[@name='oldServiceProvider']">	
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
							<xsl:text>NGN DSL contract created.</xsl:text>
						</xsl:element>
						<xsl:element name="long_description_text">
							<xsl:text>TransactionID: </xsl:text>
							<xsl:value-of select="request-param[@name='transactionID']"/>
							<xsl:text>&#xA;NGN DSL Contract has been created on:</xsl:text>
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
							<xsl:text>NGN DSL Product subscription.</xsl:text>
						</xsl:element>
						<xsl:element name="long_description_text">
							<xsl:text>TransactionID: </xsl:text>
							<xsl:value-of select="request-param[@name='transactionID']"/>
							<xsl:text>&#xA;NGN DSL Product subscription has been added on:</xsl:text>
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
						<xsl:element name="notification_action_name">CreateNgnDslContract</xsl:element>
						<xsl:element name="target_system">FIF</xsl:element>
						<xsl:element name="parameter_value_list">
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">NGNDSL_SERVICE_SUBSCRIPTION_ID</xsl:element>
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
	                				<xsl:element name="parameter_name">NGNDSL_DETAILED_REASON_RD</xsl:element>
	                				<xsl:element name="parameter_value">
										<xsl:value-of select="request-param[@name='reasonRd']"/>
	                				</xsl:element>
	              				</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='reasonRd'] = ''">
						    	<xsl:element name="CcmFifParameterValueCont">
	                				<xsl:element name="parameter_name">NGNDSL_DETAILED_REASON_RD</xsl:element>
	                				<xsl:element name="parameter_value">CREATE_NGN_DSL</xsl:element>
	              				</xsl:element>
							</xsl:if>
						
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
	
           
		</xsl:element>

	</xsl:template>
</xsl:stylesheet>
