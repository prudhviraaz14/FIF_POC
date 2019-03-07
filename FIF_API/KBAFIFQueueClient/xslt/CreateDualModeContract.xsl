<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a dualmode contract V5000, V5001 and V5002 services 

  @author wlazlow
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
		<xsl:element name="client_name">POS</xsl:element>		
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
		</xsl:element>		
			
		<!-- Calculate today and one day before the desired date -->
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
		
		<xsl:element name="Command_List">

		<!--Get Customer Number if not provided-->
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
					
		<!--Get Account Number if not provided-->
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
					<xsl:if test="request-param[@name='customerNumber'] = ''">					
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:element>							
			<!-- Create Address-->
			<xsl:element name="CcmFifCreateAddressCmd">
				<xsl:element name="command_id">create_address</xsl:element>
				<xsl:element name="CcmFifCreateAddressInCont">
					<xsl:element name="entity_ref">
						<xsl:element name="command_id">get_entity_1</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element>									
					<xsl:element name="address_type">LOKA</xsl:element>
					<xsl:element name="street_name">
						<xsl:value-of select="request-param[@name='streetName']"/>
					</xsl:element>
					<xsl:element name="street_number">
						<xsl:value-of select="request-param[@name='streetNumber']"/>
					</xsl:element>
					<xsl:element name="street_number_suffix">
						<xsl:value-of select="request-param[@name='streetNumberSuffix']"/>
					</xsl:element>
					<xsl:element name="postal_code">
						<xsl:value-of select="request-param[@name='postalCode']"/>
					</xsl:element>
					<xsl:element name="city_name">
						<xsl:value-of select="request-param[@name='cityName']"/>
					</xsl:element>
					<xsl:element name="city_suffix_name">
						<xsl:value-of select="request-param[@name='citySuffixName']"/>
					</xsl:element>
					<xsl:element name="country_code">DE</xsl:element>
					<xsl:element name="address_additional_text">
						<xsl:value-of select="request-param[@name='addressAdditionalText']"/>
					</xsl:element>
					<xsl:element name="set_primary_address">N</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>
		
		<!-- Create Order Form-->
		<xsl:element name="CcmFifCreateOrderFormCmd">
			<xsl:element name="command_id">create_order_form_1</xsl:element>
			<xsl:element name="CcmFifCreateOrderFormInCont">
				<xsl:if test="request-param[@name='customerNumber'] != ''">	
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
				</xsl:if>
				<xsl:if test="request-param[@name='customerNumber'] = ''">					
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">read_external_notification_1</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:element name="notice_per_dur_value">
					<xsl:value-of select="request-param[@name='noticePerDurValue']"/>
				</xsl:element>
				<xsl:element name="notice_per_dur_unit">
					<xsl:value-of select="request-param[@name='noticePerDurUnit']"/>
				</xsl:element>
				<xsl:element name="notice_per_start_date">
					<xsl:value-of select="request-param[@name='noticePerStartDate']"/>
				</xsl:element>
				<xsl:element name="term_dur_value">
					<xsl:value-of select="request-param[@name='termDurValue']"/>
				</xsl:element>
				<xsl:element name="term_dur_unit">
					<xsl:value-of select="request-param[@name='termDurUnit']"/>
				</xsl:element>
				<xsl:element name="term_start_date">
					<xsl:value-of select="request-param[@name='termStartDate']"/>
				</xsl:element>
				<xsl:element name="termination_date">
					<xsl:value-of select="request-param[@name='terminationDate']"/>
				</xsl:element>
				<xsl:element name="min_per_dur_value">
					<xsl:value-of select="request-param[@name='minPerDurValue']"/>
				</xsl:element>
				<xsl:element name="min_per_dur_unit">
					<xsl:value-of select="request-param[@name='minPerDurUnit']"/>
				</xsl:element>
				<xsl:element name="sales_org_num_value">
					<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
				</xsl:element>
				<xsl:element name="doc_template_name">Vertrag</xsl:element>
				<xsl:element name="assoc_skeleton_cont_num">
					<xsl:value-of select="request-param[@name='assocSkeletonContNum']"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
		
		<!-- Add Order Form Product Commitment -->
		<xsl:element name="CcmFifAddProductCommitCmd">
			<xsl:element name="command_id">add_product_commitment_1</xsl:element>
			<xsl:element name="CcmFifAddProductCommitInCont">
				<xsl:if test="request-param[@name='customerNumber'] != ''">	
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
				</xsl:if>
				<xsl:if test="request-param[@name='customerNumber'] = ''">					
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">read_external_notification_1</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:element name="contract_number_ref">
					<xsl:element name="command_id">create_order_form_1</xsl:element>
					<xsl:element name="field_name">contract_number</xsl:element>
				</xsl:element>
				<xsl:element name="product_code">V0008</xsl:element>
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
				<xsl:if test="request-param[@name='boardSignName'] != ''">                
					<xsl:element name="board_sign_name">
						<xsl:value-of select="request-param[@name='boardSignName']"/>
					</xsl:element>
				</xsl:if>
				<xsl:if test="request-param[@name='boardSignName'] = ''">                
					<xsl:element name="board_sign_name">ARCOR</xsl:element>
				</xsl:if>
				<xsl:element name="board_sign_date">
					<xsl:value-of select="request-param[@name='boardSignDate']"/>
				</xsl:element>
				<xsl:if test="request-param[@name='primaryCustSignName'] != ''">                
					<xsl:element name="primary_cust_sign_name">
						<xsl:value-of select="request-param[@name='primaryCustSignName']"/>
					</xsl:element>
				</xsl:if>
				<xsl:if test="request-param[@name='primaryCustSignName'] = ''">                
					<xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
				</xsl:if>
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
				<xsl:if test="request-param[@name='customerNumber'] != ''">	
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
				</xsl:if>
				<xsl:if test="request-param[@name='customerNumber'] = ''">					
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">read_external_notification_1</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:element name="product_commitment_number_ref">
					<xsl:element name="command_id">add_product_commitment_1</xsl:element>
					<xsl:element name="field_name">product_commitment_number</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
		
		<!-- Add Dual Mode main Service V5000 -->
		<xsl:element name="CcmFifAddServiceSubsCmd">
			<xsl:element name="command_id">add_service_1</xsl:element>
			<xsl:element name="CcmFifAddServiceSubsInCont">
				<xsl:element name="product_subscription_ref">
					<xsl:element name="command_id">add_product_subscription_1</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="service_code">V5000</xsl:element>
				<xsl:element name="desired_date">
					<xsl:value-of select="request-param[@name='desiredDate']"/>
				</xsl:element>
				<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
				<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>        
				<xsl:if test="request-param[@name='accountNumber'] != ''">	
					<xsl:element name="account_number">
						<xsl:value-of select="request-param[@name='accountNumber']"/>
					</xsl:element>
				</xsl:if>
				<xsl:if test="request-param[@name='accountNumber'] = ''">					
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">read_external_notification_2</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:element name="service_characteristic_list">
					<!-- Network Element Id -->
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">Z0100</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>
						<xsl:element name="configured_value">
							<xsl:value-of select="request-param[@name='networkElementId']"/>
						</xsl:element>
					</xsl:element>
					<!-- Address -->
					<xsl:element name="CcmFifAddressCharacteristicCont">
						<xsl:element name="service_char_code">V0014</xsl:element>
						<xsl:element name="data_type">ADDRESS</xsl:element>
						<xsl:if test="(request-param[@name='addressId'] = '')">
							<xsl:element name="address_ref">
								<xsl:element name="command_id">create_address</xsl:element>
								<xsl:element name="field_name">address_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="(request-param[@name='addressId'] != '')">
							<xsl:element name="address_id">
								<xsl:value-of select="request-param[@name='addressId']"/>
							</xsl:element>	
						</xsl:if>			
					</xsl:element>
					<!-- Rufnummer -->
					<xsl:element name="CcmFifAccessNumberCont">
						<xsl:element name="service_char_code">V0001</xsl:element>
						<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
						<xsl:element name="masking_digits_rd">1</xsl:element>
						<xsl:element name="country_code">
							<xsl:value-of select="substring-before(request-param[@name='accessNumber'], ';')"/>
						</xsl:element>
						<xsl:element name="city_code">
							<xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber'], ';'), ';')"/>
						</xsl:element>
						<xsl:element name="local_number">
							<xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber'], ';'), ';')"/>
						</xsl:element>
					</xsl:element>										
					<!-- Bearbeitungsart  -->
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">VI002</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>
						<xsl:element name="configured_value">NoOP</xsl:element>
					</xsl:element>										
					<!-- Bemerkung -->
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">V0008</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>
						<xsl:element name="configured_value"></xsl:element>
					</xsl:element>
					<!-- SimId -->
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">V0108</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>
						<xsl:element name="configured_value">
							<xsl:value-of select="request-param[@name='simId']"/>
						</xsl:element>
					</xsl:element>
					<!-- Vodafone Kundennummer -->
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">V0151</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>
						<xsl:element name="configured_value">
							<xsl:value-of select="request-param[@name='vodafoneCustomerNumber']"							/>
						</xsl:element>
					</xsl:element>					
					<!-- Vertriebssegment -->
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">V0105</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>
						<xsl:element name="configured_value">
							<xsl:value-of select="request-param[@name='deliverySegment']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
		
		<!-- Add Dual ModeFeature  Service V5001 if the ShippingCostsSimCard is set to S -->
		<xsl:if test="request-param[@name='shippingCostsSimCard'] = 'S'">
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_2</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V5001</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
					<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
					<xsl:if test="request-param[@name='accountNumber'] != ''">	
						<xsl:element name="account_number">
							<xsl:value-of select="request-param[@name='accountNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='accountNumber'] = ''">					
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>					
					<!-- Bemerkung -->
					<xsl:element name="service_characteristic_list">
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0008</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value"></xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>
		
		<!-- Add Dual ModeFeature  Service V5002  -->
		<xsl:element name="CcmFifAddServiceSubsCmd">
			<xsl:element name="command_id">add_service_3</xsl:element>
			<xsl:element name="CcmFifAddServiceSubsInCont">
				<xsl:element name="product_subscription_ref">
					<xsl:element name="command_id">add_product_subscription_1</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="service_code">V5002</xsl:element>
				<xsl:element name="desired_date">
					<xsl:value-of select="request-param[@name='desiredDate']"/>
				</xsl:element>
				<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
				<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
				<xsl:if test="request-param[@name='accountNumber'] != ''">	
					<xsl:element name="account_number">
						<xsl:value-of select="request-param[@name='accountNumber']"/>
					</xsl:element>
				</xsl:if>
				<xsl:if test="request-param[@name='accountNumber'] = ''">					
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">read_external_notification_2</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
				</xsl:if>				
				<!-- Bemerkung -->
				<xsl:element name="service_characteristic_list">
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">V0008</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>
						<xsl:element name="configured_value"></xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>

		<!-- Add Dual ModeFeature  Service V5003 if the ShippingCostsSimCard is set to E -->
		<xsl:if test="request-param[@name='shippingCostsSimCard'] = 'E'">
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_4</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V5003</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
					<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
					<xsl:if test="request-param[@name='accountNumber'] != ''">	
						<xsl:element name="account_number">
							<xsl:value-of select="request-param[@name='accountNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='accountNumber'] = ''">					
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>					
					<!-- Bemerkung -->
					<xsl:element name="service_characteristic_list">
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0008</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value"></xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>
				
		<!-- Create Customer Order for new services  -->
		<xsl:element name="CcmFifCreateCustOrderCmd">
			<xsl:element name="command_id">create_co_1</xsl:element>
			<xsl:element name="CcmFifCreateCustOrderInCont">
				<xsl:if test="request-param[@name='customerNumber'] != ''">	
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
				</xsl:if>
				<xsl:if test="request-param[@name='customerNumber'] = ''">					
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">read_external_notification_1</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
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
				<xsl:if test="request-param[@name='providerTrackingNumber'] = ''" > 
					<xsl:element name="provider_tracking_no">001</xsl:element> 
				</xsl:if>          
				<xsl:if test="request-param[@name='providerTrackingNumber'] != ''">             
					<xsl:element name="provider_tracking_no">
						<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
					</xsl:element>
				</xsl:if>
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
					<!-- V5000 -->
					<xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
					</xsl:element>
					<!-- V5001 -->
					<xsl:if test="request-param[@name='shippingCostsSimCard'] = 'S'">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_2</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:if>
					<!-- V5002 -->
					<xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">add_service_3</xsl:element>
						<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
					</xsl:element>
					<!-- V5003 -->
					<xsl:if test="request-param[@name='shippingCostsSimCard'] = 'E'">					
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_4</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:if>			
				</xsl:element>
			</xsl:element>
		</xsl:element>
		
		<!-- Release Customer Order for Dual Mode Services -->
		<xsl:element name="CcmFifReleaseCustOrderCmd">
			<xsl:element name="CcmFifReleaseCustOrderInCont">
				<xsl:if test="request-param[@name='customerNumber'] != ''">	
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
				</xsl:if>
				<xsl:if test="request-param[@name='customerNumber'] = ''">					
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">read_external_notification_1</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:element name="customer_order_ref">
					<xsl:element name="command_id">create_co_1</xsl:element>
					<xsl:element name="field_name">customer_order_id</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
		
		<!-- Create Contact for Service Addition -->
		<xsl:element name="CcmFifCreateContactCmd">
			<xsl:element name="CcmFifCreateContactInCont">
				<xsl:if test="request-param[@name='customerNumber'] != ''">	
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
				</xsl:if>
				<xsl:if test="request-param[@name='customerNumber'] = ''">					
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">read_external_notification_1</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:element name="contact_type_rd">STAMM_AEND</xsl:element>
				<xsl:element name="short_description">
					<xsl:text>Dienst hinzugefügt über </xsl:text>
					<xsl:value-of select="request-param[@name='clientName']"/>
				</xsl:element>
				<xsl:element name="long_description_text">
					<xsl:text>TransactionID: </xsl:text>
					<xsl:value-of select="request-param[@name='transactionID']"/>
					<xsl:text>&#xA;Service Code: V5000</xsl:text>
					<xsl:text>&#xA;Desired Date: </xsl:text>
					<xsl:if test="request-param[@name='desiredDate'] != ''">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:if>
					<xsl:if test="request-param[@name='desiredDate'] = ''">
						<xsl:value-of select="$today"/>
					</xsl:if>
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
					<xsl:if test="request-param[@name='desiredDate'] != ''">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:if>
					<xsl:if test="request-param[@name='desiredDate'] = ''">
						<xsl:value-of select="$today"/>
					</xsl:if>
				</xsl:element>
				<xsl:element name="notification_action_name">createKBANotification</xsl:element>
				<xsl:element name="target_system">KBA</xsl:element>                           				
				<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>						
						<xsl:if test="request-param[@name='customerNumber'] != ''">	
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='customerNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='customerNumber'] = ''">	
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">read_external_notification_1</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>												
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TYPE</xsl:element>
							<xsl:element name="parameter_value">CONTACT</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CATEGORY</xsl:element>
							<xsl:element name="parameter_value">CreateDualModeContract</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:if test="request-param[@name='userName'] != ''">              
								<xsl:element name="parameter_name">USER_NAME</xsl:element>
								<xsl:element name="parameter_value">
									<xsl:value-of select="request-param[@name='userName']"/>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='userName'] = ''">              
								<xsl:element name="parameter_name">USER_NAME</xsl:element>
								<xsl:element name="parameter_value">
									<xsl:value-of select="request-param[@name='clientName']"/>
								</xsl:element>
							</xsl:if>            
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element>
							<xsl:element name="parameter_value">POS</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">WORK_DATE</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:if test="request-param[@name='desiredDate'] != ''">
									<xsl:value-of select="request-param[@name='desiredDate']"/>
								</xsl:if>
								<xsl:if test="request-param[@name='desiredDate'] = ''">
									<xsl:value-of select="$today"/>
								</xsl:if>
							</xsl:element>
						</xsl:element>					
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TEXT</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:text>Dual Mode Vertrag über POS angelegt.</xsl:text>
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
					<xsl:element name="effective_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="processed_indicator">Y</xsl:element>
					<xsl:element name="notification_action_name">CreateDualModeContract</xsl:element>
					<xsl:element name="target_system">FIF</xsl:element>
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">SERVICE_SUBSCRIPTION_ID</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">add_service_1</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">DUAL_SERVICE_SUBSCRIPTION_ID</xsl:element>
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
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>
		
	</xsl:element>
	</xsl:template>
</xsl:stylesheet>
