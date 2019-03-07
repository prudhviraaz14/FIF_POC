<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for creating a MicrosoftOnlineSuite contract

  @author schwarje
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
		
		<!-- Calculate today and one day before the desired date -->
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
		<!-- Convert the desired date to OPM format -->
		<xsl:variable name="desiredDateOPM"
				select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>

		<xsl:variable name="accountNumber">
			<xsl:value-of select="request-param[@name='accountNumber']"/>
		</xsl:variable>
						
		<xsl:element name="Command_List">

			<!--Get Customer Number if not provided-->
			<xsl:if test="request-param[@name='customerNumber'] = ''">
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_customer_number</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>

			<!-- Get account Number if not provided -->
			<xsl:if test="$accountNumber = ''">
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_account_number</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
						<xsl:element name="ignore_empty_result">Y</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="request-param[@name='customerNumber'] != ''">
				<xsl:element name="CcmFifFindServiceSubsCmd">
					<xsl:element name="command_id">find_existing_bpos_service</xsl:element>
					<xsl:element name="CcmFifFindServiceSubsInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="service_code">I4001</xsl:element>
						<xsl:element name="no_service_error">N</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- raise error avoid processing of existing customers in POS -->      
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">raise_error</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">BPOS_Nachbestellung</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">find_existing_bpos_service</xsl:element>
							<xsl:element name="field_name">service_found</xsl:element>								
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>	
					</xsl:element>
				</xsl:element>     				
			</xsl:if>			
			
			<!-- Create Order Form-->
			<xsl:if test="request-param[@name='productCommitmentNumber'] = ''">
				<xsl:element name="CcmFifCreateOrderFormCmd">
					<xsl:element name="command_id">create_order_form</xsl:element>
					<xsl:element name="CcmFifCreateOrderFormInCont">
						<xsl:if test="request-param[@name='customerNumber'] = ''">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">read_customer_number</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='customerNumber'] != ''">
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
						<xsl:element name="termination_restriction">
							<xsl:value-of select="request-param[@name='terminationRestriction']"/>
						</xsl:element>
						<xsl:element name="doc_template_name">Vertrag</xsl:element>
						<xsl:element name="assoc_skeleton_cont_num">
							<xsl:value-of select="request-param[@name='assocSkeletonContNum']"/>
						</xsl:element>
						<xsl:if test="request-param[@name='customerNumber'] != ''">							
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">find_existing_bpos_service</xsl:element>
								<xsl:element name="field_name">service_found</xsl:element>								
							</xsl:element>
							<xsl:element name="required_process_ind">N</xsl:element>	
						</xsl:if>				
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
						<xsl:if test="request-param[@name='customerNumber'] = ''">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">read_customer_number</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='customerNumber'] != ''">
							<xsl:element name="customer_number">
								<xsl:value-of select="request-param[@name='customerNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="contract_number_ref">
							<xsl:element name="command_id">create_order_form</xsl:element>
							<xsl:element name="field_name">contract_number</xsl:element>
						</xsl:element>
						<xsl:element name="product_code">I4001</xsl:element>
						<xsl:element name="pricing_structure_code">
							<xsl:value-of select="request-param[@name='tariff']"/>
						</xsl:element>
						<xsl:if test="request-param[@name='customerNumber'] != ''">							
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">find_existing_bpos_service</xsl:element>
								<xsl:element name="field_name">service_found</xsl:element>								
							</xsl:element>
							<xsl:element name="required_process_ind">N</xsl:element>	
						</xsl:if>				
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
						<xsl:if test="request-param[@name='customerNumber'] != ''">							
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">find_existing_bpos_service</xsl:element>
								<xsl:element name="field_name">service_found</xsl:element>								
							</xsl:element>
							<xsl:element name="required_process_ind">N</xsl:element>	
						</xsl:if>				
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Validate the product commitment type-->
			<xsl:if test="request-param[@name='productCommitmentNumber'] != ''">
				<xsl:element name="CcmFifValidateProductCommitmentTypeCmd">
					<xsl:element name="command_id">validate_pc_type</xsl:element>
					<xsl:element name="CcmFifValidateProductCommitmentTypeInCont">
						<xsl:element name="product_commitment_number">
							<xsl:value-of select="request-param[@name='productCommitmentNumber']"/>
						</xsl:element>
						<xsl:element name="product_commitment_type">OF</xsl:element>
						<xsl:if test="request-param[@name='customerNumber'] = ''">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">read_customer_number</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='customerNumber'] != ''">
							<xsl:element name="customer_number">
								<xsl:value-of select="request-param[@name='customerNumber']"/>
							</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Add Product Subscription -->
			<xsl:element name="CcmFifAddProductSubsCmd">
				<xsl:element name="command_id">add_product_subscription</xsl:element>
				<xsl:element name="CcmFifAddProductSubsInCont">
					<xsl:if test="request-param[@name='customerNumber'] = ''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_customer_number</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber'] != ''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
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
					<xsl:if test="request-param[@name='customerNumber'] != ''">							
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">find_existing_bpos_service</xsl:element>
							<xsl:element name="field_name">service_found</xsl:element>								
						</xsl:element>
						<xsl:element name="required_process_ind">N</xsl:element>	
					</xsl:if>				
				</xsl:element>
			</xsl:element>
			
			<!-- Add Main Service -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_main_service</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">I4001</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">CREATE_MOS</xsl:element>
					<xsl:if test="$accountNumber = ''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_account_number</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$accountNumber != ''">
						<xsl:element name="account_number">
							<xsl:value-of select="$accountNumber"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber'] != ''">							
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">find_existing_bpos_service</xsl:element>
							<xsl:element name="field_name">service_found</xsl:element>								
						</xsl:element>
						<xsl:element name="required_process_ind">N</xsl:element>	
					</xsl:if>				
					<xsl:element name="service_characteristic_list">
						<!-- Aktivierungsdatum -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4003</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$desiredDateOPM"/>
							</xsl:element>
						</xsl:element>
						<!-- administrator email -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4000</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='administratorEmail']"/>
							</xsl:element>
						</xsl:element>
						<!-- prefered language -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4001</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='preferedLanguage']"/>
							</xsl:element>
						</xsl:element>
						<!-- Einwilligungserklärung Telefon -->
						<xsl:if test="request-param[@name='marketingPhoneIndicator'] != ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">I4017</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='marketingPhoneIndicator']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Einwilligungserklärung Mail -->
						<xsl:if test="request-param[@name='marketingMailIndicator'] != ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">I4016</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='marketingMailIndicator']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Telefonnummer -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4018</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='contactPhoneNumber']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_bpos_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:if test="request-param[@name='customerNumber'] = ''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_customer_number</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber'] != ''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_code">I4001</xsl:element>
				</xsl:element>
			</xsl:element>			
			
			<xsl:for-each select="request-param-list[@name='featureList']/request-param-list-item">	
				<xsl:variable name="mosVersion">
					<xsl:choose>
						<xsl:when test="
							request-param[@name='featureServiceCode'] = 'I4014' or
							request-param[@name='featureServiceCode'] = 'I4015' or
							request-param[@name='featureServiceCode'] = 'I4016' or
							request-param[@name='featureServiceCode'] = 'I4017' or
							request-param[@name='featureServiceCode'] = 'I4018' or
							request-param[@name='featureServiceCode'] = 'I4019' or
							request-param[@name='featureServiceCode'] = 'I4020' or
							request-param[@name='featureServiceCode'] = 'I4021'">12</xsl:when>
						<xsl:otherwise>14</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="parentForExchangeOnlineArchiving">
					<xsl:choose>
						<xsl:when test="
							request-param[@name='featureServiceCode'] = 'I402K' or
							request-param[@name='featureServiceCode'] = 'I402H' or
							request-param[@name='featureServiceCode'] = 'I402D' or
							request-param[@name='featureServiceCode'] = 'I402E' or
							request-param[@name='featureServiceCode'] = 'I402B' or
							request-param[@name='featureServiceCode'] = 'I402C'">Y</xsl:when>
						<xsl:otherwise>N</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:if test="request-param[@name='featureServiceCode'] = 'I4014'">
					<xsl:element name="CcmFifFindServiceTicketPositionCmd">
						<xsl:element name="command_id">find_trial_stp</xsl:element>
						<xsl:element name="CcmFifFindServiceTicketPositionInCont">
							<xsl:element name="contract_number_ref">
								<xsl:element name="command_id">find_bpos_service</xsl:element>
								<xsl:element name="field_name">contract_number</xsl:element>
							</xsl:element>
							<xsl:element name="no_stp_error">N</xsl:element>
							<xsl:element name="find_stp_parameters">
								<xsl:element name="CcmFifFindStpParameterCont">
									<xsl:element name="service_code">I4013</xsl:element>
									<xsl:element name="usage_mode_value_rd">1</xsl:element>
									<xsl:element name="customer_order_state">FINAL</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					
					<!-- get Opco Subscription Id, if a trial service exists -->
					<xsl:element name="CcmFifFindServCharValueForServCharCmd">
						<xsl:element name="command_id">get_trial_id</xsl:element>
						<xsl:element name="CcmFifFindServCharValueForServCharInCont">
							<xsl:element name="service_ticket_position_id_ref">
								<xsl:element name="command_id">find_trial_stp</xsl:element>
								<xsl:element name="field_name">service_ticket_position_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_char_code">I4006</xsl:element>
							<xsl:element name="no_csc_error">Y</xsl:element>
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">find_trial_stp</xsl:element>
								<xsl:element name="field_name">stp_found</xsl:element>							
							</xsl:element>
							<xsl:element name="required_process_ind">Y</xsl:element>
						</xsl:element>
					</xsl:element>				
				</xsl:if>
				
				<!-- Add feature -->
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">
						<xsl:text>add_feature_service_</xsl:text>
						<xsl:value-of select="position()"/>
					</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">find_bpos_service</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:value-of select="request-param[@name='featureServiceCode']"/>						
						</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">find_bpos_service</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:element name="reason_rd">CREATE_MOS</xsl:element>
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">find_bpos_service</xsl:element>
							<xsl:element name="field_name">account_number</xsl:element>
						</xsl:element>
						<xsl:element name="service_characteristic_list">
							<!-- Anzahl -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">I4005</xsl:element>
								<xsl:element name="data_type">INTEGER</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='numberOfLicenses']"/>
								</xsl:element>
							</xsl:element>						
							<!-- OpcoSubscriptionId_trial -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">I4007</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value_ref">
									<xsl:element name="command_id">get_trial_id</xsl:element>
									<xsl:element name="field_name">characteristic_value</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- add storage upgrade for Exchange, if applicable -->
				<xsl:if test="request-param[@name='storageUpgradeExchange'] != '' and $mosVersion = '12'">
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">
							<xsl:text>add_exchange_storage_service_</xsl:text>
							<xsl:value-of select="position()"/>
						</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">find_bpos_service</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">I4022</xsl:element>
							<xsl:element name="parent_service_subs_ref">
								<xsl:element name="command_id">
									<xsl:text>add_feature_service_</xsl:text>
									<xsl:value-of select="position()"/>								
								</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="desired_date">
								<xsl:value-of select="$today"/>
							</xsl:element>
							<xsl:element name="desired_schedule_type">ASAP</xsl:element>
							<xsl:element name="reason_rd">CREATE_MOS</xsl:element>
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_bpos_service</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
							<xsl:element name="service_characteristic_list">
								<!-- Anzahl -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">I4005</xsl:element>
									<xsl:element name="data_type">INTEGER</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='storageUpgradeExchange']"/>
									</xsl:element>
								</xsl:element>						
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>												
				
				<!-- add storage upgrade for Sharepoint, if applicable -->
				<xsl:if test="request-param[@name='storageUpgradeSharepoint'] != ''">
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">
							<xsl:text>add_sharepoint_storage_service_</xsl:text>
							<xsl:value-of select="position()"/>								
						</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">find_bpos_service</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">
								<xsl:choose>
									<xsl:when test="$mosVersion = '12'">I4023</xsl:when>
									<xsl:otherwise>I402X</xsl:otherwise>
								</xsl:choose>								
							</xsl:element>
							<xsl:element name="parent_service_subs_ref">
								<xsl:element name="command_id">
									<xsl:text>add_feature_service_</xsl:text>
									<xsl:value-of select="position()"/>								
								</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="desired_date">
								<xsl:value-of select="$today"/>
							</xsl:element>
							<xsl:element name="desired_schedule_type">ASAP</xsl:element>
							<xsl:element name="reason_rd">CREATE_MOS</xsl:element>
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_bpos_service</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
							<xsl:element name="service_characteristic_list">
								<!-- Anzahl -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">I4005</xsl:element>
									<xsl:element name="data_type">INTEGER</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='storageUpgradeSharepoint']"/>
									</xsl:element>
								</xsl:element>						
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>															
				
				<!-- add HostedBES, if applicable -->
				<xsl:if test="request-param[@name='numberOfLicensesHostedBlackberry'] != ''">
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">
							<xsl:text>add_blackberry_service_</xsl:text>
							<xsl:value-of select="position()"/>								
						</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">find_bpos_service</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">
								<xsl:choose>
									<xsl:when test="$mosVersion = '12'">I4027</xsl:when>
									<xsl:otherwise>I402W</xsl:otherwise>
								</xsl:choose>								
							</xsl:element>
							<xsl:element name="parent_service_subs_ref">
								<xsl:element name="command_id">
									<xsl:text>add_feature_service_</xsl:text>
									<xsl:value-of select="position()"/>								
								</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="desired_date">
								<xsl:value-of select="$today"/>
							</xsl:element>
							<xsl:element name="desired_schedule_type">ASAP</xsl:element>
							<xsl:element name="reason_rd">CREATE_MOS</xsl:element>
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_bpos_service</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
							<xsl:element name="service_characteristic_list">
								<!-- Anzahl -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">I4005</xsl:element>
									<xsl:element name="data_type">INTEGER</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='numberOfLicensesHostedBlackberry']"/>
									</xsl:element>
								</xsl:element>						
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>		
								
				<!-- add PartnerAccess, if applicable -->
				<xsl:if test="request-param[@name='numberOfLicensesPartnerAccess'] != '' and $mosVersion != '12'">
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">
							<xsl:text>add_PartnerAccess_service_</xsl:text>
							<xsl:value-of select="position()"/>								
						</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">find_bpos_service</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">I402Y</xsl:element>
							<xsl:element name="parent_service_subs_ref">
								<xsl:element name="command_id">
									<xsl:text>add_feature_service_</xsl:text>
									<xsl:value-of select="position()"/>								
								</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="desired_date">
								<xsl:value-of select="$today"/>
							</xsl:element>
							<xsl:element name="desired_schedule_type">ASAP</xsl:element>
							<xsl:element name="reason_rd">CREATE_MOS</xsl:element>
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_bpos_service</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
							<xsl:element name="service_characteristic_list">
								<!-- Anzahl -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">I4005</xsl:element>
									<xsl:element name="data_type">INTEGER</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='numberOfLicensesPartnerAccess']"/>
									</xsl:element>
								</xsl:element>						
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>															
				
				<!-- add UnifiedMessaging, if applicable -->
				<xsl:if test="request-param[@name='numberOfLicensesUnifiedMessaging'] != '' and $mosVersion != '12'">
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">
							<xsl:text>add_UnifiedMessaging_service_</xsl:text>
							<xsl:value-of select="position()"/>								
						</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">find_bpos_service</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">I402Z</xsl:element>
							<xsl:element name="parent_service_subs_ref">
								<xsl:element name="command_id">
									<xsl:text>add_feature_service_</xsl:text>
									<xsl:value-of select="position()"/>								
								</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="desired_date">
								<xsl:value-of select="$today"/>
							</xsl:element>
							<xsl:element name="desired_schedule_type">ASAP</xsl:element>
							<xsl:element name="reason_rd">CREATE_MOS</xsl:element>
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_bpos_service</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
							<xsl:element name="service_characteristic_list">
								<!-- Anzahl -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">I4005</xsl:element>
									<xsl:element name="data_type">INTEGER</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='numberOfLicensesUnifiedMessaging']"/>
									</xsl:element>
								</xsl:element>						
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>															
				
				<!-- add LyncOnline, if applicable -->
				<xsl:if test="request-param[@name='numberOfLicensesLyncOnline'] != '' and $mosVersion != '12'">
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">
							<xsl:text>add_LyncOnline_service_</xsl:text>
							<xsl:value-of select="position()"/>								
						</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">find_bpos_service</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">I402a</xsl:element>
							<xsl:element name="parent_service_subs_ref">
								<xsl:element name="command_id">
									<xsl:text>add_feature_service_</xsl:text>
									<xsl:value-of select="position()"/>								
								</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="desired_date">
								<xsl:value-of select="$today"/>
							</xsl:element>
							<xsl:element name="desired_schedule_type">ASAP</xsl:element>
							<xsl:element name="reason_rd">CREATE_MOS</xsl:element>
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_bpos_service</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
							<xsl:element name="service_characteristic_list">
								<!-- Anzahl -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">I4005</xsl:element>
									<xsl:element name="data_type">INTEGER</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='numberOfLicensesLyncOnline']"/>
									</xsl:element>
								</xsl:element>						
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>															

				<!-- add ExchangeOnlineArchiving, if applicable -->
				<xsl:if test="request-param[@name='numberOfLicensesExchangeOnlineArchiving'] != '' and $parentForExchangeOnlineArchiving = 'Y'">
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">
							<xsl:text>add_ExchangeOnlineArchiving_service_</xsl:text>
							<xsl:value-of select="position()"/>								
						</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">find_bpos_service</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">I4038</xsl:element>
							<xsl:element name="parent_service_subs_ref">
								<xsl:element name="command_id">
									<xsl:text>add_feature_service_</xsl:text>
									<xsl:value-of select="position()"/>								
								</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="desired_date">
								<xsl:value-of select="$today"/>
							</xsl:element>
							<xsl:element name="desired_schedule_type">ASAP</xsl:element>
							<xsl:element name="reason_rd">CREATE_MOS</xsl:element>
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_bpos_service</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
							<xsl:element name="service_characteristic_list">
								<!-- Anzahl -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">I4005</xsl:element>
									<xsl:element name="data_type">INTEGER</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='numberOfLicensesExchangeOnlineArchiving']"/>
									</xsl:element>
								</xsl:element>						
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>															
			</xsl:for-each>
			
			<!-- Create Customer Order for new services  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_bpos_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
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
						<xsl:for-each select="request-param-list[@name='featureList']/request-param-list-item">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">
									<xsl:text>add_feature_service_</xsl:text>
									<xsl:value-of select="position()"/>								
								</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
							<xsl:if test="request-param[@name='storageUpgradeExchange'] != ''">
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">
										<xsl:text>add_exchange_storage_service_</xsl:text>
										<xsl:value-of select="position()"/>								
									</xsl:element>
									<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='storageUpgradeSharepoint'] != ''">
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">
										<xsl:text>add_sharepoint_storage_service_</xsl:text>
										<xsl:value-of select="position()"/>								
									</xsl:element>
									<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='numberOfLicensesHostedBlackberry'] != ''">
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">
										<xsl:text>add_blackberry_service_</xsl:text>
										<xsl:value-of select="position()"/>								
									</xsl:element>
									<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='numberOfLicensesPartnerAccess'] != ''">
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">
										<xsl:text>add_PartnerAccess_service_</xsl:text>
										<xsl:value-of select="position()"/>								
									</xsl:element>
									<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='numberOfLicensesUnifiedMessaging'] != ''">
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">
										<xsl:text>add_UnifiedMessaging_service_</xsl:text>
										<xsl:value-of select="position()"/>								
									</xsl:element>
									<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='numberOfLicensesLyncOnline'] != ''">
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">
										<xsl:text>add_LyncOnline_service_</xsl:text>
										<xsl:value-of select="position()"/>								
									</xsl:element>
									<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='numberOfLicensesExchangeOnlineArchiving'] != ''">
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">
										<xsl:text>add_ExchangeOnlineArchiving_service_</xsl:text>
										<xsl:value-of select="position()"/>								
									</xsl:element>
									<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
								</xsl:element>
							</xsl:if>
						</xsl:for-each>
					</xsl:element>
					<!-- TODO wird das gebraucht? -->
					<xsl:element name="e_shop_id">
						<xsl:value-of select="request-param[@name='eShopID']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Release stand alone Customer Order -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_bpos_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>        
				</xsl:element>
			</xsl:element>      
			
			<!-- Create contact  for Service Addition -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_bpos_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="contact_type_rd">CREATE_MOS</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>MOS-Vertrag bestellt</xsl:text>
					</xsl:element>
					<xsl:element name="description_text_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>Microsoft-Online-Suite bestellt.&#xA;Vertragsnummer: </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_bpos_service</xsl:element>
							<xsl:element name="field_name">contract_number</xsl:element>          
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">                								
								<xsl:text>&#xA;Bestellte Features: </xsl:text>
								<xsl:for-each select="request-param-list[@name='featureList']/request-param-list-item">
									<xsl:text>&#xA;</xsl:text>
									<xsl:value-of select="request-param[@name='featureServiceCode']"/>
									<xsl:text>, </xsl:text>
									<xsl:value-of select="request-param[@name='numberOfLicenses']"/>
									<xsl:text> Lizenzen</xsl:text>
								</xsl:for-each>
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

			<!-- Create External notification  if requestListId is  set -->
			<xsl:if test="request-param[@name='requestListId'] != ''">
				<xsl:element name="CcmFifCreateExternalNotificationCmd">
					<xsl:element name="command_id">create_external_notification</xsl:element>
					<xsl:element name="CcmFifCreateExternalNotificationInCont">
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
								<xsl:element name="parameter_name">MOS_SERVICE_SUBSCRIPTION_ID</xsl:element>
								<xsl:element name="parameter_value_ref">
									<xsl:element name="command_id">add_main_service</xsl:element>
									<xsl:element name="field_name">service_subscription_id</xsl:element>
								</xsl:element>
							</xsl:element>						
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
		</xsl:element>

	</xsl:template>
</xsl:stylesheet>
