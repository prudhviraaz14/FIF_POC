<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--
  IT-16586 Migration Preselect to VoIP
  @author banania
-->
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
	<xsl:template match="/">
		<xsl:element name="CcmFifCommandList">
			<xsl:apply-templates select="request/request-params"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="request-params">
		
		<!-- Copy over transaction ID, client name, override system date and action name -->
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
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
		<xsl:element name="Command_List">
			
			<!-- Find Service Subscription by Service Subscription Id (DSL-R) -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_service_1</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">	
					<xsl:element name="access_number">
						<xsl:value-of select="request-param[@name='accessNumber']"/>
					</xsl:element>				
					<xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>					
					<xsl:element name="technical_service_code">TOC_NONBILL</xsl:element>					
				</xsl:element>
			</xsl:element>
			
			<!-- Lock the Customer -->
			<xsl:element name="CcmFifLockObjectCmd">
				<xsl:element name="command_id">lock_customer_1</xsl:element>
				<xsl:element name="CcmFifLockObjectInCont">
					<xsl:element name="object_id">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="object_type">CUSTOMER</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- validate that customer does not have an order form for the product VI201 -->
			<xsl:element name="CcmFifValidateOrderFormProductCodeCmd">
				<xsl:element name="command_id">validate_OF</xsl:element>
				<xsl:element name="CcmFifValidateOrderFormProductCodeInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="product_code">VI201</xsl:element>
				</xsl:element>
			</xsl:element>

			<xsl:if test="request-param[@name='addressId'] = ''">
				<!-- Get Entity Information -->
				<xsl:element name="CcmFifGetEntityCmd">
					<xsl:element name="command_id">get_entity_1</xsl:element>
					<xsl:element name="CcmFifGetEntityInCont">
						<xsl:if test="request-param[@name='customerNumber'] != ''">
							<xsl:element name="customer_number">
								<xsl:value-of select="request-param[@name='customerNumber']"/>
							</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:element>
				<!--Create new  address-->
				<xsl:element name="CcmFifCreateAddressCmd">
					<xsl:element name="command_id">create_addr_1</xsl:element>
					<xsl:element name="CcmFifCreateAddressInCont">
						<xsl:element name="entity_ref">
							<xsl:element name="command_id">get_entity_1</xsl:element>
							<xsl:element name="field_name">entity_id</xsl:element>
						</xsl:element>
						<xsl:element name="address_type">LOKA</xsl:element>
						<xsl:element name="street_name">
							<xsl:value-of select="request-param[@name='street']"/>
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
						<xsl:element name="country_code">DE</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
						
      		<!-- Normalize Address  if the address id is provided. -->
     		<xsl:if test="request-param[@name='addressId'] != ''">
				<xsl:element name="CcmFifNormalizeAddressCmd">
					<xsl:element name="command_id">normalize_address_1</xsl:element>
					<xsl:element name="CcmFifNormalizeAddressInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="address_id">
							<xsl:value-of select="request-param[@name='addressId']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
 		    </xsl:if>

			<!-- Reconfigure DSL-R Service Subscription -->
			<xsl:element name="CcmFifReconfigServiceCmd">
				<xsl:element name="command_id">reconf_serv_1</xsl:element>
				<xsl:element name="CcmFifReconfigServiceInCont">
					<xsl:element name="service_subscription_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>	
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">MIG_PRE_ZU_VOIP</xsl:element>
					<xsl:element name="service_characteristic_list">
						<!-- Auftragsvariante -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I1011</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">Upgrade DSL-R VoIP</xsl:element>
						</xsl:element>
						<!-- Aktivierungsdatum -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0909</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$desiredDateOPM"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Check customer classification -->
			<xsl:element name="CcmFifGetCustomerDataCmd">
				<xsl:element name="command_id">get_customer_data</xsl:element>
				<xsl:element name="CcmFifGetCustomerDataInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
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
			
			<!-- Add hardware service V011A to the DSL-R -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_1</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>					
					<xsl:element name="service_code">V011A</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>				
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>	
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">MIG_PRE_ZU_VOIP</xsl:element>
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>
					</xsl:element>
					<xsl:element name="service_characteristic_list">
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0110</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of
									select="request-param[@name='hardwareDeliverySalutation']"/>
								<xsl:text>;</xsl:text>
								<xsl:value-of
									select="request-param[@name='hardwareDeliverySurname']"/>
								<xsl:text>;</xsl:text>
								<xsl:value-of
									select="request-param[@name='hardwareDeliveryForename']"/>
							</xsl:element>
						</xsl:element>
						<!-- Lieferanschrift -->
						<xsl:element name="CcmFifAddressCharacteristicCont">
							<xsl:element name="service_char_code">V0111</xsl:element>
							<xsl:element name="data_type">ADDRESS</xsl:element>
							<xsl:if	 test="request-param[@name='addressId'] != ''">
								<xsl:element name="address_id">
									<xsl:value-of select="request-param[@name='addressId']"/>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='addressId'] = ''">
								<xsl:element name="address_ref">
									<xsl:element name="command_id">create_addr_1</xsl:element>
									<xsl:element name="field_name">address_id</xsl:element>
								</xsl:element>
							</xsl:if>
						</xsl:element>
						<!-- Artikelnumber -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0112</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='articleNumber']"/>
							</xsl:element>
						</xsl:element>
						<!-- Subventionierungskennzeichen -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0114</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of
									select="request-param[@name='subventionIndicator']"/>
							</xsl:element>
						</xsl:element>
						<!-- Artikelbezeichnung -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0116</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='articleName']"/>
							</xsl:element>
						</xsl:element>
						<!-- Zahlungsoption -->
						<xsl:if test="request-param[@name='shippingCosts'] != ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0119</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='shippingCosts']"/>
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
					</xsl:element>
				</xsl:element>
			</xsl:element>
				
			<!-- Create Order Form  -->
			<xsl:element name="CcmFifCreateOrderFormCmd">
				<xsl:element name="command_id">create_order_form_1</xsl:element>
				<xsl:element name="CcmFifCreateOrderFormInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="sales_org_num_value">
						<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
					</xsl:element>
					<xsl:element name="doc_template_name">Vertrag</xsl:element>
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
			<!-- Add Product Commitment -->
			<xsl:element name="CcmFifAddProductCommitCmd">
				<xsl:element name="command_id">add_product_commit_1</xsl:element>
				<xsl:element name="CcmFifAddProductCommitInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">create_order_form_1</xsl:element>
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
				<xsl:element name="command_id">sign_order_form_1</xsl:element>
				<xsl:element name="CcmFifSignOrderFormInCont">
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">create_order_form_1</xsl:element>
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
			
			<!-- Add Product Subscription -->
			<xsl:element name="CcmFifAddProductSubsCmd">
				<xsl:element name="command_id">add_product_subscription_1</xsl:element>
				<xsl:element name="CcmFifAddProductSubsInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="product_commitment_number_ref">
						<xsl:element name="command_id">add_product_commit_1</xsl:element>
						<xsl:element name="field_name">product_commitment_number</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>						
			
			<!-- Add Service Subscription VI201 -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_2</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">VI201</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>	
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">UPGRADE_VOIP</xsl:element>  

					<xsl:element name="account_number">
						<xsl:value-of select="request-param[@name='accountNumber']"/>
					</xsl:element>
					<xsl:element name="service_characteristic_list">
						<!-- V0014 -->
						<xsl:element name="CcmFifAddressCharacteristicCont">
							<xsl:element name="service_char_code">V0014</xsl:element>
							<xsl:element name="data_type">ADDRESS</xsl:element>
							<xsl:if test="request-param[@name='addressId'] != ''">
								<xsl:element name="address_id">
									<xsl:value-of select="request-param[@name='addressId']"/>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='addressId'] = ''">
								<xsl:element name="address_ref">
									<xsl:element name="command_id">create_addr_1</xsl:element>
									<xsl:element name="field_name">address_id</xsl:element>
								</xsl:element>
							</xsl:if>
						</xsl:element>
						<!-- Anzahl der neue Rufnummern -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0936</xsl:element>
							<xsl:element name="data_type">INTEGER</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='accessNumberCount']"/>
							</xsl:element>
						</xsl:element>
						<!-- Bearbeitungsart -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">VI002</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">OP</xsl:element>
						</xsl:element>
						<!-- Bundle Kennzeichen -->
						<xsl:if test="request-param[@name='bundleMark'] != ''">            
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">VI047</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='bundleMark']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>            
						<!-- Aktivierungsdatum -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0909</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$desiredDateOPM"/>
							</xsl:element>
						</xsl:element>
						<!-- Rabatt -->
						<xsl:if test="request-param[@name='rabatt'] != ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0097</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='rabatt']"/>                  
								</xsl:element>
							</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- look for a voice bundle (item) -->
			<xsl:element name="CcmFifFindBundleCmd">
				<xsl:element name="command_id">find_bundle_1</xsl:element>
				<xsl:element name="CcmFifFindBundleInCont">
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create a new bundle if no one has been found -->
			<xsl:element name="CcmFifModifyBundleCmd">
				<xsl:element name="command_id">modify_bundle_1</xsl:element>
				<xsl:element name="CcmFifModifyBundleInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">find_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="bundle_found_ref">
						<xsl:element name="command_id">find_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Get bundle item type rd from reference data -->
			<xsl:element name="CcmFifGetCrossRefSecondaryValueCmd">
				<xsl:element name="command_id">get_ref_data_1</xsl:element>
				<xsl:element name="CcmFifGetCrossRefSecondaryValueInCont">
					<xsl:element name="group_code">SERV_BLD</xsl:element>
					<xsl:element name="primary_value_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_code</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- add the new bundle item if a bundle is found -->
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item_1</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">find_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd">VOIP_SERVICE</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">add_service_2</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>   
				</xsl:element>
			</xsl:element>
			
			<!-- add a new bundle item for the given service subscription id -->
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item_2</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">modify_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd_ref">
						<xsl:element name="command_id">get_ref_data_1</xsl:element>
						<xsl:element name="field_name">secondary_value</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>   
				</xsl:element>
			</xsl:element>
			
			<!-- add the new  bundle item to the new bundle if created only -->
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item_3</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">modify_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd">VOIP_SERVICE</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">add_service_2</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>            
				</xsl:element>
			</xsl:element>

			<!-- Find Service Subscription -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_service_2</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
				<xsl:element name="product_subscription_id">
					<xsl:value-of select="request-param[@name='productSubscriptionId']"/>
				</xsl:element>
				<xsl:element name="fetch_main_ss_from_ps_Ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Get PC Data -->
			<xsl:element name="CcmFifGetProductCommitmentDataCmd">
				<xsl:element name="command_id">get_prod_comm_data_1</xsl:element>
				<xsl:element name="CcmFifGetProductCommitmentDataInCont">
					<xsl:element name="product_commitment_number_ref">
						<xsl:element name="command_id">find_service_2</xsl:element>
						<xsl:element name="field_name">product_commitment_number</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Validate PC product pode belongs to a Preselect product -->
			<xsl:element name="CcmFifValidateValueCmd">
				<xsl:element name="command_id">validate_product_code_1</xsl:element>
				<xsl:element name="CcmFifValidateValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">get_prod_comm_data_1</xsl:element>
						<xsl:element name="field_name">product_code</xsl:element>
					</xsl:element>
					<xsl:element name="object_type">ORDER_FORM_PRODUCT_COMMIT</xsl:element>
					<xsl:element name="value_type">PRODUCT_CODE</xsl:element>
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">V0001</xsl:element>
						</xsl:element>						
					</xsl:element>
				</xsl:element>
			</xsl:element>			
															
			<!-- Terminate Preselect Product Subscription -->
			<xsl:element name="CcmFifTerminateProductSubsCmd">
				<xsl:element name="command_id">terminate_ps_1</xsl:element>
				<xsl:element name="CcmFifTerminateProductSubsInCont">
					<xsl:element name="product_subscription_id">
						<xsl:value-of select="request-param[@name='productSubscriptionId']"/>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">MIG_PRE_ZU_VOIP</xsl:element>
					<xsl:element name="auto_customer_order">N</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create  Customer Order for new services  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="cust_order_description">Preselect Migration To DSL-R</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">003v</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_2</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>																		
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Create Customer Order for Termination -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_2</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="cust_order_description">Preselect Migration To DSL-R</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">002</xsl:element>
					<xsl:element name="service_ticket_pos_list_ref">
						<xsl:element name="command_id">terminate_ps_1</xsl:element>
						<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create  Customer Order for reconfiguration of DSL-R + Hardware -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_3</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="cust_order_description">Preselect Migration To DSL-R</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">001</xsl:element> 
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">reconf_serv_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>	
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>	
					</xsl:element>
				</xsl:element>
			</xsl:element>
						
			<!-- Release delayed CO if the param requestListId is populated -->    
			<xsl:if test="request-param[@name='requestListId'] != ''">                 
				<xsl:element name="CcmFifReleaseCustOrderCmd">
					<xsl:element name="CcmFifReleaseCustOrderInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="customer_order_ref">
							<xsl:element name="command_id">create_co_1</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>
						</xsl:element>
						<xsl:element name="release_delay_date">
							<xsl:value-of select="$today"/>	
						</xsl:element>           
					</xsl:element>
				</xsl:element>                
			</xsl:if>
			
			<!-- Release stand alone Customer Order for VoIP Services -->
			<xsl:if test="request-param[@name='requestListId'] = ''">  
				<xsl:element name="CcmFifReleaseCustOrderCmd">
					<xsl:element name="CcmFifReleaseCustOrderInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="customer_order_ref">
							<xsl:element name="command_id">create_co_1</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>
						</xsl:element>        
					</xsl:element>
				</xsl:element>     
			</xsl:if>     
									
			<!-- Release Customer Order for Termination -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_2</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="parent_customer_order_id_ref">
						<xsl:element name="command_id">create_co_1</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			
			<!-- Release Customer Order for reconfiguration of DSL-R + Hardware -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_3</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
						
			<!-- Create Contact for Migration  -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:if test="request-param[@name='customerNumber'] != ''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="contact_type_rd">INFO</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>IT-16586 Migration</xsl:text>
						<xsl:value-of select="request-param[@name='clientName']"/>
					</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>&#xA;IT-16586 Migration Preselect VoIP</xsl:text>						
						<xsl:text>TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
						<xsl:text>&#xA;User name: </xsl:text>
						<xsl:value-of select="request-param[@name='userName']"/>
						<xsl:text>&#xA;Rollenbezeichnung: </xsl:text>
						<xsl:value-of select="request-param[@name='rollenBezeichnung']"/>
					</xsl:element>				
				</xsl:element>
			</xsl:element>
			
			<!-- Create external notification -->
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<xsl:element name="command_id">create_external_notification_1</xsl:element>
				<xsl:element name="CcmFifCreateExternalNotificationInCont">
					<xsl:element name="effective_date">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
					<xsl:element name="notification_action_name">createKBANotification</xsl:element>
					<xsl:element name="target_system">KBA</xsl:element>
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">customerNumber</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='customerNumber']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TYPE</xsl:element>
							<xsl:element name="parameter_value">CONTACT</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CATEGORY</xsl:element>
							<xsl:element name="parameter_value">Migration</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">USER_NAME</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='clientName']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='clientName']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">WORK_DATE</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="$today"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TEXT</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:text>IT-16586 Upgrade from Preselect to VoIP.</xsl:text>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create External notification  if requestListId is set -->
			<xsl:if test="request-param[@name='requestListId'] != ''">
				<xsl:element name="CcmFifCreateExternalNotificationCmd">
					<xsl:element name="command_id">create_external_notification_2</xsl:element>
					<xsl:element name="CcmFifCreateExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="notification_action_name">UpgradeToVoIP</xsl:element>
						<xsl:element name="target_system">FIF</xsl:element>
						<xsl:element name="parameter_value_list">
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">VOICE_SERVICE_SUBSCRIPTION_ID</xsl:element> 
								<xsl:element name="parameter_value_ref">
									<xsl:element name="command_id">add_service_2</xsl:element> 
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
