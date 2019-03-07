<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
<!--
  XSLT file for creating a FIF request for Adding Hardware Service
  @author wlazlow
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
		<xsl:variable name="AddServCommandId">add_ss_</xsl:variable>
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>	
		<xsl:variable name="desiredDateOPM"
			select="dateutils:createOPMDate(request-param[@name='DESIRED_DATE'])"/>
		
		<xsl:element name="Command_List">
			
			<!-- Find Service Subscription by Service Subscription Id-->
				<xsl:element name="CcmFifFindServiceSubsCmd">
					<xsl:element name="command_id">find_service_1</xsl:element>
					<xsl:element name="CcmFifFindServiceSubsInCont">
					
						<xsl:if test="request-param[@name='SERVICE_SUBSCRIPTION_ID'] != ''">
							<xsl:element name="service_subscription_id">
								<xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="effective_date">
							<xsl:value-of select="$today"/>						
						</xsl:element>
						<xsl:if test="request-param[@name='CUSTOMER_NUMBER'] != ''">
							<xsl:element name="customer_number">
								<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
							</xsl:element>
						</xsl:if>												
					</xsl:element>
				</xsl:element>
	

			<!-- Lock the Customer -->
			<xsl:element name="CcmFifLockObjectCmd">
				<xsl:element name="command_id">lock_customer_1</xsl:element>
				<xsl:element name="CcmFifLockObjectInCont">
					<xsl:element name="object_id">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="object_type">CUSTOMER</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- validate that customer does not have an order form for the product V9008 -->
			<xsl:element name="CcmFifValidateOrderFormProductCodeCmd">
				<xsl:element name="command_id">validate_OF</xsl:element>
				<xsl:element name="CcmFifValidateOrderFormProductCodeInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="product_code">VI201</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Order Form  -->
			<xsl:element name="CcmFifCreateOrderFormCmd">
				<xsl:element name="command_id">create_order_form_1</xsl:element>
				<xsl:element name="CcmFifCreateOrderFormInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>					
					<xsl:element name="min_per_dur_value">
						<xsl:value-of select="request-param[@name='MIN_PERIOD_DUR_VALUE']"/>
					</xsl:element>	
					<xsl:element name="min_per_dur_unit">
						<xsl:value-of select="request-param[@name='MIN_PERIOD_DUR_UNIT_RD']"/>
					</xsl:element>																					
					<xsl:element name="sales_org_num_value">
						<xsl:value-of select="request-param[@name='SALES_ORGANISATION_NUMBER']"/>
					</xsl:element>
					<xsl:element name="doc_template_name">Vertrag</xsl:element>					
					<xsl:element name="assoc_skeleton_cont_num">
						<xsl:value-of select="request-param[@name='ASSOC_SKELETON_CONTRACT_NUMBER']"/>
					</xsl:element>	
				</xsl:element>
			</xsl:element>
					
			
			<!-- Add Product Commitment -->
			<xsl:element name="CcmFifAddProductCommitCmd">
				<xsl:element name="command_id">add_product_commit_1</xsl:element>
				<xsl:element name="CcmFifAddProductCommitInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">create_order_form_1</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
					<xsl:element name="product_code">VI201</xsl:element>
					<xsl:element name="pricing_structure_code">
					   <xsl:value-of select="request-param[@name='PRICING_STRUCTURE_CODE']"/>
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
						<xsl:value-of select="request-param[@name='BOARD_SIGN_NAME']"/>
					</xsl:element>
					<xsl:element name="board_sign_date">
						<xsl:value-of select="request-param[@name='BOARD_SIGN_DATE']"/>
					</xsl:element>
					<xsl:element name="primary_cust_sign_name">
						<xsl:value-of select="request-param[@name='PRIMARY_CUST_SIGN_NAME']"/>
					</xsl:element>
					<xsl:element name="primary_cust_sign_date">
						<xsl:value-of select="request-param[@name='PRIMARY_CUST_SIGN_DATE']"/>
					</xsl:element>
					<xsl:element name="secondary_cust_sign_name">
						<xsl:value-of select="request-param[@name='SECONDARY_CUST_SIGN_NAME']"/>
					</xsl:element>
					<xsl:element name="secondary_cust_sign_date">
						<xsl:value-of select="request-param[@name='SECONDARY_CUST_SIGN_DATE']"/>
					</xsl:element>					
				</xsl:element>
			</xsl:element>
			
			<!-- Add Product Subscription -->
			<xsl:element name="CcmFifAddProductSubsCmd">
				<xsl:element name="command_id">add_product_subscription_1</xsl:element>
				<xsl:element name="CcmFifAddProductSubsInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="product_commitment_number_ref">
						<xsl:element name="command_id">add_product_commit_1</xsl:element>
						<xsl:element name="field_name">product_commitment_number</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:if test="request-param[@name='ADDRESS_ID'] = ''">
				<!-- Get Entity Information -->
				<xsl:element name="CcmFifGetEntityCmd">
					<xsl:element name="command_id">get_entity_1</xsl:element>
					<xsl:element name="CcmFifGetEntityInCont">
						<xsl:if test="request-param[@name='CUSTOMER_NUMBER'] != ''">
							<xsl:element name="customer_number">
								<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
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
							<xsl:value-of select="request-param[@name='STREET']"/>
						</xsl:element>
						<xsl:element name="street_number">
							<xsl:value-of select="request-param[@name='STREET_NUMBER']"/>
						</xsl:element>
						<xsl:element name="street_number_suffix">
							<xsl:value-of select="request-param[@name='NUMBER_SUFFIX']"/>
						</xsl:element>
						<xsl:element name="postal_code">
							<xsl:value-of select="request-param[@name='POSTAL_CODE']"/>
						</xsl:element>
						<xsl:element name="city_name">
							<xsl:value-of select="request-param[@name='CITY']"/>
						</xsl:element>
						<xsl:element name="city_suffix_name">
							<xsl:value-of select="request-param[@name='CITY_SUFFIX']"/>
						</xsl:element>
						<xsl:element name="country_code">DE</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
						
               
		
			
			<xsl:if test="(request-param[@name='DEVIATION_STREET'] != '')
				and (request-param[@name='DEVIATION_STREET_NUMBER'] != '')
				and (request-param[@name='DEVIATION_POSTAL_CODE'] != '')
				and (request-param[@name='DEVIATION_CITY'] != '')">
				
				<!-- Get Entity Information -->
				<xsl:element name="CcmFifGetEntityCmd">
					<xsl:element name="command_id">get_entity_2</xsl:element>
					<xsl:element name="CcmFifGetEntityInCont">
						<xsl:if test="request-param[@name='CUSTOMER_NUMBER'] != ''">
							<xsl:element name="customer_number">
								<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
							</xsl:element>
						</xsl:if>						
					</xsl:element>
				</xsl:element>
               											
				<!--Create new deviation address-->
				<xsl:element name="CcmFifCreateAddressCmd">
					<xsl:element name="command_id">create_addr_2</xsl:element>
					<xsl:element name="CcmFifCreateAddressInCont">
						<xsl:element name="entity_ref">
							<xsl:element name="command_id">get_entity_2</xsl:element>
							<xsl:element name="field_name">entity_id</xsl:element>
						</xsl:element>
						<xsl:element name="address_type">VERS</xsl:element>
						<xsl:element name="street_name">
							<xsl:value-of select="request-param[@name='DEVIATION_STREET']"/>
						</xsl:element>
						<xsl:element name="street_number">
							<xsl:value-of select="request-param[@name='DEVIATION_STREET_NUMBER']"/>
						</xsl:element>
						<xsl:element name="street_number_suffix">
							<xsl:value-of select="request-param[@name='DEVIATION_NUMBER_SUFFIX']"/>
						</xsl:element>
						<xsl:element name="postal_code">
							<xsl:value-of select="request-param[@name='DEVIATION_POSTAL_CODE']"/>
						</xsl:element>
						<xsl:element name="city_name">
							<xsl:value-of select="request-param[@name='DEVIATION_CITY']"/>
						</xsl:element>
						<xsl:element name="city_suffix_name">
							<xsl:value-of select="request-param[@name='DEVIATION_CITY_SUFFIX']"/>
						</xsl:element>
						<xsl:element name="country_code">DE</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>						
						
						
			<!-- Add Service Subscription VI201 -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_1</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">VI201</xsl:element>
					<!--	<xsl:element name="desired_date">
						<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
					</xsl:element> -->
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='REASON_RD']"/>
					</xsl:element>
					<xsl:element name="account_number">
						<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
					</xsl:element>
					<xsl:element name="service_characteristic_list">	
						<!-- V0014 -->				
						<xsl:element name="CcmFifAddressCharacteristicCont">
							<xsl:element name="service_char_code">V0014</xsl:element>
							<xsl:element name="data_type">ADDRESS</xsl:element>
							<xsl:if test="request-param[@name='ADDRESS_ID'] != ''">
								<xsl:element name="address_id">
									<xsl:value-of select="request-param[@name='ADDRESS_ID']"/>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='ADDRESS_ID'] = ''">
								<xsl:element name="address_ref">
									<xsl:element name="command_id">create_addr_1</xsl:element>
									<xsl:element name="field_name">address_id</xsl:element>
								</xsl:element>
							</xsl:if>
						</xsl:element>	
						<!-- V0936 -->		
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0936</xsl:element>
							<xsl:element name="data_type">INTEGER</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='ACCESS_NUMBER_COUNT']"/>
							</xsl:element>
						</xsl:element>								
						<!-- V0097 -->			
						<xsl:if test="request-param[@name='RABATT_INDICATOR'] = 'Y'">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0097</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
								     <xsl:value-of select="request-param[@name='RABATT']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- VI047 -->			
						<xsl:if test="request-param[@name='BUNDLE_MARK'] = 'Y'">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">VI047</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">DSLR</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- VI002 -->			
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">VI002</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">OP</xsl:element>
						</xsl:element>	
						<!-- V0909 -->			
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0909</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$desiredDateOPM"/>
							</xsl:element>
						</xsl:element>		
						<!-- VI052 -->			
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">VI052</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='DEVIATION_ADDRESS_INDICATOR']"/>
							</xsl:element>
						</xsl:element>
						
						
						<xsl:if test="(request-param[@name='DEVIATION_STREET'] != '')
							and (request-param[@name='DEVIATION_STREET_NUMBER'] != '')
							and (request-param[@name='DEVIATION_POSTAL_CODE'] != '')
							and (request-param[@name='DEVIATION_CITY'] != '')">
						
						    <!-- VI053 -->				
						    <xsl:element name="CcmFifAddressCharacteristicCont">
							   <xsl:element name="service_char_code">VI053</xsl:element>
							   <xsl:element name="data_type">ADDRESS</xsl:element>														
								  <xsl:element name="address_ref">
									<xsl:element name="command_id">create_addr_2</xsl:element>
									<xsl:element name="field_name">address_id</xsl:element>
								  </xsl:element>						
						    </xsl:element>	
						</xsl:if>	
						
						<!-- VI054 -->			
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">VI054</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='DEVIATION_FIRST_LINE']"/>
							</xsl:element>
						</xsl:element>
						
						<!-- VI055 -->			
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">VI055</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='DEVIATION_SECOND_LINE']"/>
							</xsl:element>
						</xsl:element>
						
					</xsl:element>
				</xsl:element>
			</xsl:element>


			<!-- Add Service Subscription V0099 -->
			<xsl:if test="(request-param[@name='BONUSS_INDICATOR']='Y')">
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_2</xsl:element>
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
						<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='REASON_RD']"/>
					</xsl:element>
					<xsl:element name="account_number">
						<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
					</xsl:element>
					<xsl:element name="service_characteristic_list"></xsl:element>
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
				<!--	<xsl:element name="desired_date">
						<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
					</xsl:element> --> 
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='REASON_RD']"/>
					</xsl:element>
					<xsl:element name="service_characteristic_list">
						<!-- Auftragsvariante -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I1011</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">Upgrade DSL-R VoIP</xsl:element>							                 
							<!--<xsl:element name="configured_value">NoOP</xsl:element> --> 
							
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
			
			<!-- Add hardware service V011A to the DSL-R -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_3</xsl:element>
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
				<!--	<xsl:element name="desired_date">
						<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
					</xsl:element> -->
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='REASON_RD']"/>
					</xsl:element>
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
									select="request-param[@name='HARDWARE_DELIVERY_SALUTATION']"/>
								<xsl:text>;</xsl:text>
								<xsl:value-of
									select="request-param[@name='HARDWARE_DELIVERY_SURNAME']"/>
								<xsl:text>;</xsl:text>
								<xsl:value-of
									select="request-param[@name='HARDWARE_DELIVERY_FORENAME']"/>
							</xsl:element>
						</xsl:element>
						<!-- Lieferanschrift -->
						<xsl:element name="CcmFifAddressCharacteristicCont">
							<xsl:element name="service_char_code">V0111</xsl:element>
							<xsl:element name="data_type">ADDRESS</xsl:element>
							<xsl:if	 test="request-param[@name='ADDRESS_ID'] != ''">
								<xsl:element name="address_id">
									<xsl:value-of select="request-param[@name='ADDRESS_ID']"/>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='ADDRESS_ID'] = ''">
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
								<xsl:value-of select="request-param[@name='ARTICLE_NUMBER']"/>
							</xsl:element>
						</xsl:element>
						<!-- Subventionierungskennzeichen -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0114</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of
									select="request-param[@name='SUBVENTION_INDICATOR']"/>
							</xsl:element>
						</xsl:element>
						<!-- Artikelbezeichnung -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0116</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='ARTICLE_NAME']"/>
							</xsl:element>
						</xsl:element>
						<!-- Zahlungsoption -->
						<xsl:if test="request-param[@name='SHIPPING_COSTS'] != ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0119</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='SHIPPING_COSTS']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- Bestellgrund -->
						<xsl:if test="request-param[@name='ORDER_REASON'] != ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0989</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='ORDER_REASON']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:element>		

			
			<!-- Set the new desired country 1 -->						
			<xsl:if test="(request-param[@name='DESIRED_COUNTRY_1']!='')">	
				<!-- Add new country discount service -->
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_desired_country_1</xsl:element>
						
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:value-of select="request-param[@name='DESIRED_COUNTRY_1']"/>
						</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
						<xsl:element name="reason_rd">
						      <xsl:value-of select="request-param[@name='REASON_RD']"/>
						</xsl:element>
						<xsl:element name="account_number">
							<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
						</xsl:element>
						<xsl:element name="service_characteristic_list"> </xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- Add contributing items -->
				<xsl:element name="CcmFifAddModifyContributingItemCmd">
					<xsl:element name="CcmFifAddModifyContributingItemInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:value-of select="request-param[@name='DESIRED_COUNTRY_1']"/>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
						</xsl:element>
						<xsl:element name="contributing_item_list">
							<xsl:element name="CcmFifContributingItem">
								<xsl:element name="supported_object_type_rd">SERVICE_SUBSC</xsl:element>
								<xsl:element name="start_date">
									<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
								</xsl:element>
								<xsl:element name="service_subscription_ref">
									<xsl:element name="command_id">add_service_1</xsl:element>
									<xsl:element name="field_name">service_subscription_id</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Set the new desired country 2 -->						
			<xsl:if test="(request-param[@name='DESIRED_COUNTRY_2']!='')">	
				<!-- Add new country discount service -->
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_desired_country_2</xsl:element>
					
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:value-of select="request-param[@name='DESIRED_COUNTRY_2']"/>
						</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
						<xsl:element name="reason_rd">
							<xsl:value-of select="request-param[@name='REASON_RD']"/>
						</xsl:element>
						<xsl:element name="account_number">
							<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
						</xsl:element>
						<xsl:element name="service_characteristic_list"> </xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- Add contributing items -->
				<xsl:element name="CcmFifAddModifyContributingItemCmd">
					<xsl:element name="CcmFifAddModifyContributingItemInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:value-of select="request-param[@name='DESIRED_COUNTRY_2']"/>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
						</xsl:element>
						<xsl:element name="contributing_item_list">
							<xsl:element name="CcmFifContributingItem">
								<xsl:element name="supported_object_type_rd">SERVICE_SUBSC</xsl:element>
								<xsl:element name="start_date">
									<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
								</xsl:element>
								<xsl:element name="service_subscription_ref">
									<xsl:element name="command_id">add_service_1</xsl:element>
									<xsl:element name="field_name">service_subscription_id</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Set the new desired country 3 -->						
			<xsl:if test="(request-param[@name='DESIRED_COUNTRY_3']!='')">	
				<!-- Add new country discount service -->
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_desired_country_3</xsl:element>
					
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:value-of select="request-param[@name='DESIRED_COUNTRY_3']"/>
						</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
						<xsl:element name="reason_rd">
							<xsl:value-of select="request-param[@name='REASON_RD']"/>
						</xsl:element>
						<xsl:element name="account_number">
							<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
						</xsl:element>
						<xsl:element name="service_characteristic_list"> </xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- Add contributing items -->
				<xsl:element name="CcmFifAddModifyContributingItemCmd">
					<xsl:element name="CcmFifAddModifyContributingItemInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:value-of select="request-param[@name='DESIRED_COUNTRY_3']"/>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
						</xsl:element>
						<xsl:element name="contributing_item_list">
							<xsl:element name="CcmFifContributingItem">
								<xsl:element name="supported_object_type_rd">SERVICE_SUBSC</xsl:element>
								<xsl:element name="start_date">
									<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
								</xsl:element>
								<xsl:element name="service_subscription_ref">
									<xsl:element name="command_id">add_service_1</xsl:element>
									<xsl:element name="field_name">service_subscription_id</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			
			
			<!-- look for a  bundle -->
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
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
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
						<xsl:element name="command_id">add_service_1</xsl:element>
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
						<xsl:element name="command_id">add_service_1</xsl:element>
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
			

			<!-- Terminate Preselect Product  Subscription -->
			<xsl:element name="CcmFifTerminateProductSubsCmd">
				<xsl:element name="command_id">terminate_ps_1</xsl:element>
				<xsl:element name="CcmFifTerminateProductSubsInCont">
					<xsl:element name="product_subscription_id">
						<xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='REASON_RD']"/>
					</xsl:element>
					<xsl:element name="auto_customer_order">N</xsl:element>
				</xsl:element>
			</xsl:element>   


			<!-- Create stand alone Customer Order for new service  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:if test="request-param[@name='CUSTOMER_NUMBER'] != ''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
						</xsl:element>
					</xsl:if>					
					<xsl:element name="cust_order_description">Preselect Migration IT-16447</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element>
					<xsl:element name="lan_path_file_string">
						<xsl:value-of select="request-param[@name='LAN_PATH_FILE_STRING']"/>
					</xsl:element>
					<xsl:element name="sales_rep_dept">
						<xsl:value-of select="request-param[@name='SALES_REP_DEPT']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">001v</xsl:element>					
					<xsl:element name="super_customer_tracking_id">
						<xsl:value-of select="request-param[@name='SUPER_CUSTOMER_TRACKING_ID']"/>
					</xsl:element>
					<xsl:element name="scan_date">
						<xsl:value-of select="request-param[@name='SCAN_DATE']"/>
					</xsl:element>
					<xsl:element name="order_entry_date">
						<xsl:value-of select="request-param[@name='ORDER_ENTRY_DATE']"/>
					</xsl:element>					
				    <xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
						    <xsl:element name="command_id">add_service_2</xsl:element>
						    <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
				    	<xsl:element name="CcmFifCommandRefCont">
				    		<xsl:element name="command_id">add_desired_country_1</xsl:element>
				    		<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
				    	</xsl:element>
				    	<xsl:element name="CcmFifCommandRefCont">
				    		<xsl:element name="command_id">add_desired_country_2</xsl:element>
				    		<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
				    	</xsl:element>
				    	<xsl:element name="CcmFifCommandRefCont">
				    		<xsl:element name="command_id">add_desired_country_3</xsl:element>
				    		<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
				    	</xsl:element>							
					</xsl:element>
				</xsl:element>
			</xsl:element>
					
			
			<!--Release customer order -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:if test="request-param[@name='CUSTOMER_NUMBER'] != ''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
						</xsl:element>
					</xsl:if>				
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_1</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>



			<!-- Create Customer Order for Termination -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_2</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>					
					<xsl:element name="cust_order_description">Preselect Migration IT-16447</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element>
					<xsl:element name="lan_path_file_string">
						<xsl:value-of select="request-param[@name='LAN_PATH_FILE_STRING']"/>
					</xsl:element>
					<xsl:element name="sales_rep_dept">
						<xsl:value-of select="request-param[@name='SALES_REP_DEPT']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">002</xsl:element>					
					<xsl:element name="super_customer_tracking_id">
						<xsl:value-of select="request-param[@name='SUPER_CUSTOMER_TRACKING_ID']"/>
					</xsl:element>
					<xsl:element name="scan_date">
						<xsl:value-of select="request-param[@name='SCAN_DATE']"/>
					</xsl:element>
					<xsl:element name="order_entry_date">
						<xsl:value-of select="request-param[@name='ORDER_ENTRY_DATE']"/>
					</xsl:element>															
					<xsl:element name="service_ticket_pos_list_ref">
						<xsl:element name="command_id">terminate_ps_1</xsl:element>
						<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>  
			
			<!-- Release Customer Order for Termination -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
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


			<!-- Create  Customer Order for reconfiguration of DSL-R + Hardware -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_3</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="cust_order_description">Preselect Migration To DSL-R</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">001</xsl:element> 
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">reconf_serv_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>	
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_3</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>	
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Release Customer Order for reconfiguration of DSL-R + Hardware -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
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
					<xsl:if test="request-param[@name='CUSTOMER_NUMBER'] != ''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
						</xsl:element>
					</xsl:if>				
					<xsl:element name="contact_type_rd">INFO</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>IT-16447 Migration über</xsl:text>
						<xsl:value-of select="request-param[@name='clientName']"/>
					</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>TransactionID:</xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
						<xsl:text>&#xA;IT-16447 Migration Preselect VoIP</xsl:text>
						<xsl:if test="request-param[@name='BONUSS_INDICATOR']='Y'">
							<xsl:text> mit Bonus,</xsl:text>
						</xsl:if>
						<xsl:if test="request-param[@name='RABATT_INDICATOR']='Y'">
							<xsl:text> mit Rabatt</xsl:text>
						</xsl:if>												
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Create external notification -->
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<xsl:element name="command_id">create_external_notification_1</xsl:element>
				<xsl:element name="CcmFifCreateExternalNotificationInCont">
					<xsl:element name="effective_date">						
							<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>					
					</xsl:element>
					<xsl:element name="notification_action_name">createKBANotification</xsl:element>
					<xsl:element name="target_system">KBA</xsl:element>                           				
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>											
							<xsl:element name="parameter_value">
									<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
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
							<xsl:element name="parameter_value">SLS</xsl:element>
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
								<xsl:text>IT-16447 Migration Preselect VoIP.</xsl:text>
							</xsl:element>
						</xsl:element>					
					</xsl:element>
				</xsl:element>
			</xsl:element>
			

			
			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
