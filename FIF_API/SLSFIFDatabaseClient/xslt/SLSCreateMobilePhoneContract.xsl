<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a mobile phone contract 

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
			<xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
		</xsl:element>		
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
		</xsl:element>							
		<xsl:element name="Command_List">

			<!-- use today as desired date if not provided -->
			<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
			<xsl:variable name="desiredDate">
				<xsl:if test="request-param[@name='DESIRED_DATE'] = ''">
					<xsl:value-of select="$today"/>
				</xsl:if>
				<xsl:if test="request-param[@name='DESIRED_DATE'] != ''">
					<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
				</xsl:if>				
			</xsl:variable>
			<xsl:variable name="desiredDateOPM" select="dateutils:createOPMDate($desiredDate)"/>
			
			<!-- lock customer to avoid concurrency problems -->
			<xsl:element name="CcmFifLockObjectCmd">
				<xsl:element name="CcmFifLockObjectInCont">
					<xsl:element name="object_id">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="object_type">CUSTOMER</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- find stp -->
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_stp_1</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element>
					<xsl:element name="no_stp_error">N</xsl:element>
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">V0003</xsl:element>
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
							<xsl:element name="customer_order_state">RELEASED</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">V0010</xsl:element>
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
							<xsl:element name="customer_order_state">RELEASED</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">I1210</xsl:element>
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
							<xsl:element name="customer_order_state">RELEASED</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">I1043</xsl:element>
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
							<xsl:element name="customer_order_state">RELEASED</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">V0011</xsl:element>
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
							<xsl:element name="customer_order_state">RELEASED</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">V0003</xsl:element>
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
							<xsl:element name="customer_order_state">FINAL</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">V0010</xsl:element>
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
							<xsl:element name="customer_order_state">FINAL</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">I1210</xsl:element>
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
							<xsl:element name="customer_order_state">FINAL</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">I1043</xsl:element>
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
							<xsl:element name="customer_order_state">FINAL</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">V0011</xsl:element>
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
							<xsl:element name="customer_order_state">FINAL</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- get data from STP -->
			<xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
				<xsl:element name="command_id">get_stp_data_1</xsl:element>
				<xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_stp_1</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_stp_1</xsl:element>
						<xsl:element name="field_name">stp_found</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>							
			
			<!-- get data from customer order -->
			<xsl:element name="CcmFifGetCustomerOrderDataCmd">
				<xsl:element name="command_id">get_co_data_1</xsl:element>
				<xsl:element name="CcmFifGetCustomerOrderDataInCont">
					<xsl:element name="customer_order_id_ref">
						<xsl:element name="command_id">get_stp_data_1</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_stp_1</xsl:element>
						<xsl:element name="field_name">stp_found</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Find service -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_service_1</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">get_stp_data_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_stp_1</xsl:element>
						<xsl:element name="field_name">stp_found</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- concat results of two recent commands for use in process indicator --> 
			<xsl:element name="CcmFifConcatStringsCmd">
				<xsl:element name="command_id">concat_parameters_3</xsl:element>
				<xsl:element name="CcmFifConcatStringsInCont">
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_stp_1</xsl:element>
							<xsl:element name="field_name">stp_found</xsl:element>							
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">_</xsl:element>							
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">service_code</xsl:element>							
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>							
			
			<!-- get access number data -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">get_access_number_data</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_stp_1</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_char_code">V0001</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">concat_parameters_3</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y_V0003</xsl:element>
				</xsl:element>
			</xsl:element>							
			
			<!-- get access number data -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">get_access_number_data</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_stp_1</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_char_code">V0001</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">concat_parameters_3</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y_V0010</xsl:element>
				</xsl:element>
			</xsl:element>							
			
			<!-- get access number data -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">get_access_number_data</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_stp_1</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_char_code">V0002</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">concat_parameters_3</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y_V0011</xsl:element>
				</xsl:element>
			</xsl:element>							
			
			<!-- get access number data -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">get_access_number_data</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_stp_1</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_char_code">V0001</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">concat_parameters_3</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y_I1043</xsl:element>
				</xsl:element>
			</xsl:element>							
			
			<xsl:if test="request-param[@name='TARIFF'] = 'V8004'">
				<!-- check for a service for this tariff for determining the value for characteristic V8001 -->
				<xsl:element name="CcmFifFindServiceSubsCmd">
					<xsl:element name="command_id">find_service_for_tariff</xsl:element>
					<xsl:element name="CcmFifFindServiceSubsInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
						</xsl:element>
						<xsl:element name="product_code">V8000</xsl:element>
						<xsl:element name="pricing_structure_code">V8004</xsl:element>
						<xsl:element name="service_code">V8000</xsl:element>
						<xsl:element name="no_service_error">N</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- if no sales org number is provided, get one from the contract that was found
				and check if it is still valid, otherwise use the default value -->
			<xsl:if test="request-param[@name='SALES_ORG_NUMBER'] = ''">
				<!-- Get PC data for sales org number -->
				<xsl:element name="CcmFifGetCommissioningInformationDataCmd">
					<xsl:element name="command_id">get_sales_org_number_1</xsl:element>
					<xsl:element name="CcmFifGetCommissioningInformationDataInCont">
						<xsl:element name="supported_object_id_ref">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">contract_number</xsl:element>
						</xsl:element>
						<xsl:element name="supported_object_type_rd">O</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="$desiredDate"/>
						</xsl:element>
						<xsl:element name="no_sales_org_number_error">N</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Check, if the value is a valid one -->
			<xsl:element name="CcmFifValidateGeneralCodeItemCmd">
				<xsl:element name="command_id">validate_sales_org_number</xsl:element>
				<xsl:element name="CcmFifValidateGeneralCodeItemInCont">
					<xsl:element name="group_code">SALEORGNUM</xsl:element>
					<xsl:if test="request-param[@name='SALES_ORG_NUMBER'] = ''">
						<xsl:element name="value_ref">
							<xsl:element name="command_id">get_sales_org_number_1</xsl:element>
							<xsl:element name="field_name">sales_org_number</xsl:element>							
						</xsl:element>
					</xsl:if>						
					<xsl:if test="request-param[@name='SALES_ORG_NUMBER'] != ''">
						<xsl:element name="value">
							<xsl:value-of select="request-param[@name='SALES_ORG_NUMBER']"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:element>
			
			<!-- Get OF data for sign date -->
			<xsl:element name="CcmFifGetOrderFormDataCmd">
				<xsl:element name="command_id">get_of_data_1</xsl:element>
				<xsl:element name="CcmFifGetOrderFormDataInCont">
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_stp_1</xsl:element>
						<xsl:element name="field_name">stp_found</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
				
			<!-- Create Order Form-->
			<xsl:element name="CcmFifCreateOrderFormCmd">
				<xsl:element name="command_id">create_order_form_1</xsl:element>
				<xsl:element name="CcmFifCreateOrderFormInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="min_per_dur_value">
						<xsl:value-of select="request-param[@name='MIN_PER_DUR_VALUE']"/>
					</xsl:element>
					<xsl:element name="min_per_dur_unit">
						<xsl:value-of select="request-param[@name='MIN_PER_DUR_UNIT']"/>
					</xsl:element>
					<xsl:if test="request-param[@name='SALES_ORG_NUMBER'] != ''">
						<xsl:element name="sales_org_num_value">
							<xsl:value-of select="request-param[@name='SALES_ORG_NUMBER']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='SALES_ORG_NUMBER'] = ''">
						<xsl:element name="sales_org_num_value_ref">
							<xsl:element name="command_id">get_sales_org_number_1</xsl:element>
							<xsl:element name="field_name">sales_org_number</xsl:element>
						</xsl:element>
					</xsl:if>				
					<xsl:element name="doc_template_name">Vertrag</xsl:element>
					<xsl:element name="assoc_skeleton_cont_num">
						<xsl:value-of select="request-param[@name='ASSOC_SKELETON_CONT_NUM']"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">validate_sales_org_number</xsl:element>
						<xsl:element name="field_name">is_valid</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Order Form-->
			<xsl:element name="CcmFifCreateOrderFormCmd">
				<xsl:element name="command_id">create_order_form_1</xsl:element>
				<xsl:element name="CcmFifCreateOrderFormInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="min_per_dur_value">
						<xsl:value-of select="request-param[@name='MIN_PER_DUR_VALUE']"/>
					</xsl:element>
					<xsl:element name="min_per_dur_unit">
						<xsl:value-of select="request-param[@name='MIN_PER_DUR_UNIT']"/>
					</xsl:element>
					<xsl:element name="sales_org_num_value">97056619</xsl:element>
					<xsl:element name="doc_template_name">Vertrag</xsl:element>
					<xsl:element name="assoc_skeleton_cont_num">
						<xsl:value-of select="request-param[@name='ASSOC_SKELETON_CONT_NUM']"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">validate_sales_org_number</xsl:element>
						<xsl:element name="field_name">is_valid</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Add Order Form Product Commitment -->
			<xsl:element name="CcmFifAddProductCommitCmd">
				<xsl:element name="command_id">add_product_commitment_1</xsl:element>
				<xsl:element name="CcmFifAddProductCommitInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">create_order_form_1</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
					<xsl:element name="product_code">V8000</xsl:element>
					<xsl:element name="pricing_structure_code">
						<xsl:value-of select="request-param[@name='TARIFF']"/>
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
					<xsl:element name="board_sign_name">
						<xsl:value-of select="request-param[@name='BOARD_SIGN_NAME']"/>
					</xsl:element>
					<xsl:element name="board_sign_date">
						<xsl:value-of select="request-param[@name='BOARD_SIGN_DATE']"/>
					</xsl:element>
					<xsl:element name="primary_cust_sign_name">
						<xsl:value-of select="request-param[@name='PRIMARY_CUST_SIGN_NAME']"/>
					</xsl:element>
					<xsl:if test="request-param[@name='PRIMARY_CUST_SIGN_DATE'] = ''">
						<xsl:element name="primary_cust_sign_date_ref">
							<xsl:element name="command_id">get_of_data_1</xsl:element>
							<xsl:element name="field_name">primary_cust_sign_date</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='PRIMARY_CUST_SIGN_DATE'] != ''">
						<xsl:element name="primary_cust_sign_date">
							<xsl:value-of select="request-param[@name='PRIMARY_CUST_SIGN_DATE']"/>
						</xsl:element>
					</xsl:if>
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
				<xsl:element name="command_id">add_mobile_ps</xsl:element>
				<xsl:element name="CcmFifAddProductSubsInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="product_commitment_number_ref">
						<xsl:element name="command_id">add_product_commitment_1</xsl:element>
						<xsl:element name="field_name">product_commitment_number</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Add Mobile Phone main Service V8000 -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_mobile_service</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_mobile_ps</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V8000</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$desiredDate"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">
						<xsl:if test="$desiredDate = $today">ASAP</xsl:if>
						<xsl:if test="$desiredDate != $today">START_BEFORE</xsl:if>
					</xsl:element>
					<xsl:element name="reason_rd">CREATE_MOBILE</xsl:element>        
					<xsl:if test="request-param[@name='ACCOUNT_NUMBER'] != ''">	
						<xsl:element name="account_number">
							<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='ACCOUNT_NUMBER'] = ''">					
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">account_number</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">
						<!-- Rufnummer -->
						<xsl:element name="CcmFifAccessNumberCont">
							<xsl:element name="service_char_code">V0180</xsl:element>
							<xsl:element name="data_type">MOBIL_ACCESS_NUM</xsl:element>
							<xsl:element name="masking_digits_rd_ref">
								<xsl:element name="command_id">get_access_number_data</xsl:element>
								<xsl:element name="field_name">masking_digits_rd</xsl:element>								
							</xsl:element>
							<xsl:element name="retention_period_rd_ref">
								<xsl:element name="command_id">get_access_number_data</xsl:element>
								<xsl:element name="field_name">retention_period_rd</xsl:element>								
							</xsl:element>
							<xsl:element name="storage_masking_digits_rd_ref">
								<xsl:element name="command_id">get_access_number_data</xsl:element>
								<xsl:element name="field_name">storage_masking_digits_rd</xsl:element>								
							</xsl:element>							
							<xsl:element name="validate_duplicate_indicator">Y</xsl:element>
							<xsl:element name="country_code">
								<xsl:value-of select="substring-before(request-param[@name='ACCESS_NUMBER'], ';')"/>
							</xsl:element>
							<xsl:element name="city_code">
								<xsl:value-of select="substring-before(substring-after(request-param[@name='ACCESS_NUMBER'], ';'), ';')"/>
							</xsl:element>
							<xsl:element name="local_number">
								<xsl:value-of select="substring-after(substring-after(request-param[@name='ACCESS_NUMBER'], ';'), ';')"/>
							</xsl:element>
						</xsl:element>										
						<!-- SimId -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0108</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='SIM_ID']"/>
							</xsl:element>
						</xsl:element>
						<!-- Artikelnummer -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0178</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='ARTICLE_NUMBER']"/>
							</xsl:element>
						</xsl:element>
						<!-- PUK -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0179</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='PUK']"/>
							</xsl:element>
						</xsl:element>
						<!-- Aktivierungsdatum-->
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

			<xsl:variable name="addServCommandId">add_option_</xsl:variable>
			<!-- Set the new desired tariff options -->
			<xsl:for-each select="request-param-list[@name='TARIFF_OPTION_SERVICE_CODE_LIST']/request-param-list-item">
				<xsl:variable name="serviceCode" select="request-param[@name='SERVICE_CODE']"/>
				<!-- Add new tariff option service -->
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">
						<xsl:value-of select="concat($addServCommandId, $serviceCode)"/>
					</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_mobile_ps</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:value-of select="$serviceCode"/>
						</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_mobile_service</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$desiredDate"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">
							<xsl:if test="$desiredDate = $today">ASAP</xsl:if>
							<xsl:if test="$desiredDate != $today">START_BEFORE</xsl:if>
						</xsl:element>
						<xsl:element name="reason_rd">CREATE_MOBILE</xsl:element>
						<xsl:if test="request-param[@name='ACCOUNT_NUMBER'] != ''">	
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='ACCOUNT_NUMBER'] = ''">					
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_service_1</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list"/> 
					</xsl:element>
				</xsl:element>
				
				<!-- Add contributing items -->
				<xsl:element name="CcmFifAddModifyContributingItemCmd">
					<xsl:element name="CcmFifAddModifyContributingItemInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_mobile_ps</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:value-of select="$serviceCode"/>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="$desiredDate"/>
						</xsl:element>
						<xsl:element name="contributing_item_list">
							<xsl:element name="CcmFifContributingItem">
								<xsl:element name="supported_object_type_rd">SERVICE_SUBSC</xsl:element>
								<xsl:element name="start_date">
									<xsl:value-of select="$desiredDate"/>
								</xsl:element>
								<xsl:element name="service_subscription_ref">
									<xsl:element name="command_id">add_mobile_service</xsl:element>
									<xsl:element name="field_name">service_subscription_id</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
			
			<!-- add the service for Monatspreis for tariff V8004, if this the first sim card -->						
			<xsl:if test="request-param[@name='TARIFF'] = 'V8004'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_monthly_fee_service</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_mobile_ps</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V8033</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_mobile_service</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$desiredDate"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">
							<xsl:if test="$desiredDate = $today">ASAP</xsl:if>
							<xsl:if test="$desiredDate != $today">START_BEFORE</xsl:if>
						</xsl:element>
						<xsl:element name="reason_rd">CREATE_MOBILE</xsl:element>        
						<xsl:if test="request-param[@name='ACCOUNT_NUMBER'] != ''">	
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='ACCOUNT_NUMBER'] = ''">					
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_service_1</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">find_service_for_tariff</xsl:element>
							<xsl:element name="field_name">service_found</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">N</xsl:element>
						<xsl:element name="service_characteristic_list"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="request-param[@name='TARIFF'] = 'V8000'
				or request-param[@name='TARIFF'] = 'V8002'
				or request-param[@name='TARIFF'] = 'V8003'
				or request-param[@name='TARIFF'] = 'V8004'">
			
				<xsl:element name="CcmFifValidateDateCmd">
					<xsl:element name="command_id">check_sign_date_1</xsl:element>
					<xsl:element name="CcmFifValidateDateInCont">
						<xsl:element name="value_ref">
							<xsl:element name="command_id">get_of_data_1</xsl:element>
							<xsl:element name="field_name">primary_cust_sign_date</xsl:element>
						</xsl:element>
						<xsl:element name="allowed_values">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">2008.04.01 00:00:00</xsl:element>							
							</xsl:element>
						</xsl:element>
						<xsl:element name="operator">GREATER_OR_EQUAL</xsl:element>
						<xsl:element name="raise_error_if_invalid">N</xsl:element>							
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">find_stp_1</xsl:element>
							<xsl:element name="field_name">stp_found</xsl:element>							
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
					</xsl:element>
				</xsl:element>							
				
				<xsl:element name="CcmFifValidateDateCmd">
					<xsl:element name="command_id">check_sign_date_2</xsl:element>
					<xsl:element name="CcmFifValidateDateInCont">
						<xsl:element name="value_ref">
							<xsl:element name="command_id">get_of_data_1</xsl:element>
							<xsl:element name="field_name">primary_cust_sign_date</xsl:element>
						</xsl:element>
						<xsl:element name="allowed_values">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">2008.04.30 00:00:00</xsl:element>							
							</xsl:element>
						</xsl:element>
						<xsl:element name="operator">LESS_OR_EQUAL</xsl:element>
						<xsl:element name="raise_error_if_invalid">N</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">find_stp_1</xsl:element>
							<xsl:element name="field_name">stp_found</xsl:element>							
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
					</xsl:element>
				</xsl:element>							
				
				<xsl:element name="CcmFifConcatStringsCmd">
					<xsl:element name="command_id">concat_sign_date_check</xsl:element>
					<xsl:element name="CcmFifConcatStringsInCont">
						<xsl:element name="input_string_list">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">check_sign_date_1</xsl:element>
								<xsl:element name="field_name">is_valid</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">;</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">check_sign_date_2</xsl:element>
								<xsl:element name="field_name">is_valid</xsl:element>							
							</xsl:element>
							<!--
								<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">;</xsl:element>							
								</xsl:element>
								<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">get_of_data_1</xsl:element>
								<xsl:element name="field_name">version_number</xsl:element>							
								</xsl:element>
							-->
						</xsl:element>
					</xsl:element>
				</xsl:element>							
				
				<xsl:element name="CcmFifMapStringCmd">
					<xsl:element name="command_id">map_sign_date_check</xsl:element>
					<xsl:element name="CcmFifMapStringInCont">
						<xsl:element name="input_string_type">xxx</xsl:element>
						<xsl:element name="input_string_ref">
							<xsl:element name="command_id">concat_sign_date_check</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>
						</xsl:element>
						<xsl:element name="output_string_type">xxx</xsl:element>
						<xsl:element name="string_mapping_list">
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">Y;Y</xsl:element>
								<xsl:element name="output_string">Y</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="no_mapping_error">N</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<xsl:variable name="transactionId">
					<xsl:text>EASTER-</xsl:text>
					<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					<xsl:text>-</xsl:text>
				</xsl:variable>
				
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_sim_card_order_1</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="$transactionId"/>
							<xsl:text>1</xsl:text>
						</xsl:element>
						<xsl:element name="target_system">SLSFIF</xsl:element>
						<xsl:element name="parameter_name">articleNumber</xsl:element>
						<xsl:element name="ignore_empty_result">Y</xsl:element>
					</xsl:element>
				</xsl:element>
				<xsl:element name="CcmFifConcatStringsCmd">
					<xsl:element name="command_id">concat_suitable_notification_1</xsl:element>
					<xsl:element name="CcmFifConcatStringsInCont">
						<xsl:element name="input_string_list">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">read_sim_card_order_1</xsl:element>
								<xsl:element name="field_name">processed_indicator</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">;</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">read_sim_card_order_1</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>							
				<xsl:element name="CcmFifMapStringCmd">
					<xsl:element name="command_id">map_suitable_notification_1</xsl:element>
					<xsl:element name="CcmFifMapStringInCont">
						<xsl:element name="input_string_type">xxx</xsl:element>
						<xsl:element name="input_string_ref">
							<xsl:element name="command_id">concat_suitable_notification_1</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>
						</xsl:element>
						<xsl:element name="output_string_type">xxx</xsl:element>
						<xsl:element name="string_mapping_list">
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">
									<xsl:text>N;</xsl:text>
									<xsl:value-of select="request-param[@name='ARTICLE_NUMBER']"/>
								</xsl:element>
								<xsl:element name="output_string">Y</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="no_mapping_error">N</xsl:element>
					</xsl:element>
				</xsl:element>
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_sim_card_order_2</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="$transactionId"/>
							<xsl:text>2</xsl:text>
						</xsl:element>
						<xsl:element name="target_system">SLSFIF</xsl:element>
						<xsl:element name="parameter_name">articleNumber</xsl:element>
						<xsl:element name="ignore_empty_result">Y</xsl:element>
					</xsl:element>
				</xsl:element>
				<xsl:element name="CcmFifConcatStringsCmd">
					<xsl:element name="command_id">concat_suitable_notification_2</xsl:element>
					<xsl:element name="CcmFifConcatStringsInCont">
						<xsl:element name="input_string_list">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">read_sim_card_order_2</xsl:element>
								<xsl:element name="field_name">processed_indicator</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">;</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">read_sim_card_order_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>							
				<xsl:element name="CcmFifMapStringCmd">
					<xsl:element name="command_id">map_suitable_notification_2</xsl:element>
					<xsl:element name="CcmFifMapStringInCont">
						<xsl:element name="input_string_type">xxx</xsl:element>
						<xsl:element name="input_string_ref">
							<xsl:element name="command_id">concat_suitable_notification_2</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>
						</xsl:element>
						<xsl:element name="output_string_type">xxx</xsl:element>
						<xsl:element name="string_mapping_list">
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">
									<xsl:text>N;</xsl:text>
									<xsl:value-of select="request-param[@name='ARTICLE_NUMBER']"/>
								</xsl:element>
								<xsl:element name="output_string">Y</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="no_mapping_error">N</xsl:element>
					</xsl:element>
				</xsl:element>
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_sim_card_order_3</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="$transactionId"/>
							<xsl:text>3</xsl:text>
						</xsl:element>
						<xsl:element name="target_system">SLSFIF</xsl:element>
						<xsl:element name="parameter_name">articleNumber</xsl:element>
						<xsl:element name="ignore_empty_result">Y</xsl:element>
					</xsl:element>
				</xsl:element>
				<xsl:element name="CcmFifConcatStringsCmd">
					<xsl:element name="command_id">concat_suitable_notification_3</xsl:element>
					<xsl:element name="CcmFifConcatStringsInCont">
						<xsl:element name="input_string_list">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">read_sim_card_order_3</xsl:element>
								<xsl:element name="field_name">processed_indicator</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">;</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">read_sim_card_order_3</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>							
				<xsl:element name="CcmFifMapStringCmd">
					<xsl:element name="command_id">map_suitable_notification_3</xsl:element>
					<xsl:element name="CcmFifMapStringInCont">
						<xsl:element name="input_string_type">xxx</xsl:element>
						<xsl:element name="input_string_ref">
							<xsl:element name="command_id">concat_suitable_notification_3</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>
						</xsl:element>
						<xsl:element name="output_string_type">xxx</xsl:element>
						<xsl:element name="string_mapping_list">
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">
									<xsl:text>N;</xsl:text>
									<xsl:value-of select="request-param[@name='ARTICLE_NUMBER']"/>
								</xsl:element>
								<xsl:element name="output_string">Y</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="no_mapping_error">N</xsl:element>
					</xsl:element>
				</xsl:element>
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_sim_card_order_4</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="$transactionId"/>
							<xsl:text>4</xsl:text>
						</xsl:element>
						<xsl:element name="target_system">SLSFIF</xsl:element>
						<xsl:element name="parameter_name">articleNumber</xsl:element>
						<xsl:element name="ignore_empty_result">Y</xsl:element>
					</xsl:element>
				</xsl:element>
				<xsl:element name="CcmFifConcatStringsCmd">
					<xsl:element name="command_id">concat_suitable_notification_4</xsl:element>
					<xsl:element name="CcmFifConcatStringsInCont">
						<xsl:element name="input_string_list">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">read_sim_card_order_4</xsl:element>
								<xsl:element name="field_name">processed_indicator</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">;</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">read_sim_card_order_4</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>							
				<xsl:element name="CcmFifMapStringCmd">
					<xsl:element name="command_id">map_suitable_notification_4</xsl:element>
					<xsl:element name="CcmFifMapStringInCont">
						<xsl:element name="input_string_type">xxx</xsl:element>
						<xsl:element name="input_string_ref">
							<xsl:element name="command_id">concat_suitable_notification_4</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>
						</xsl:element>
						<xsl:element name="output_string_type">xxx</xsl:element>
						<xsl:element name="string_mapping_list">
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">
									<xsl:text>N;</xsl:text>
									<xsl:value-of select="request-param[@name='ARTICLE_NUMBER']"/>
								</xsl:element>
								<xsl:element name="output_string">Y</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="no_mapping_error">N</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<xsl:element name="CcmFifConcatStringsCmd">
					<xsl:element name="command_id">concat_find_notification_id</xsl:element>
					<xsl:element name="CcmFifConcatStringsInCont">
						<xsl:element name="input_string_list">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">map_suitable_notification_1</xsl:element>
								<xsl:element name="field_name">output_string</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">;</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">map_suitable_notification_2</xsl:element>
								<xsl:element name="field_name">output_string</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">;</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">map_suitable_notification_3</xsl:element>
								<xsl:element name="field_name">output_string</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">;</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">map_suitable_notification_4</xsl:element>
								<xsl:element name="field_name">output_string</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>							
				<xsl:element name="CcmFifMapStringCmd">
					<xsl:element name="command_id">map_find_notification_id</xsl:element>
					<xsl:element name="CcmFifMapStringInCont">
						<xsl:element name="input_string_type">xxx</xsl:element>
						<xsl:element name="input_string_ref">
							<xsl:element name="command_id">concat_find_notification_id</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>
						</xsl:element>
						<xsl:element name="output_string_type">notificationId</xsl:element>
						<xsl:element name="string_mapping_list">
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">Y;;;</xsl:element>
								<xsl:element name="output_string">
									<xsl:value-of select="$transactionId"/>
									<xsl:text>1</xsl:text>									
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">;Y;;</xsl:element>
								<xsl:element name="output_string">
									<xsl:value-of select="$transactionId"/>
									<xsl:text>2</xsl:text>									
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">;;Y;</xsl:element>
								<xsl:element name="output_string">
									<xsl:value-of select="$transactionId"/>
									<xsl:text>3</xsl:text>									
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">;;;Y</xsl:element>
								<xsl:element name="output_string">
									<xsl:value-of select="$transactionId"/>
									<xsl:text>4</xsl:text>									
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">Y;Y;;</xsl:element>
								<xsl:element name="output_string">
									<xsl:value-of select="$transactionId"/>
									<xsl:text>1</xsl:text>									
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">Y;;Y;</xsl:element>
								<xsl:element name="output_string">
									<xsl:value-of select="$transactionId"/>
									<xsl:text>1</xsl:text>									
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">Y;;;Y</xsl:element>
								<xsl:element name="output_string">
									<xsl:value-of select="$transactionId"/>
									<xsl:text>1</xsl:text>									
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">;Y;Y;</xsl:element>
								<xsl:element name="output_string">
									<xsl:value-of select="$transactionId"/>
									<xsl:text>2</xsl:text>									
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">;Y;;Y;</xsl:element>
								<xsl:element name="output_string">
									<xsl:value-of select="$transactionId"/>
									<xsl:text>2</xsl:text>									
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">;;Y;Y</xsl:element>
								<xsl:element name="output_string">
									<xsl:value-of select="$transactionId"/>
									<xsl:text>3</xsl:text>									
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">;Y;Y;Y</xsl:element>
								<xsl:element name="output_string">
									<xsl:value-of select="$transactionId"/>
									<xsl:text>2</xsl:text>									
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">Y;;Y;Y</xsl:element>
								<xsl:element name="output_string">
									<xsl:value-of select="$transactionId"/>
									<xsl:text>1</xsl:text>									
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">Y;Y;;Y</xsl:element>
								<xsl:element name="output_string">
									<xsl:value-of select="$transactionId"/>
									<xsl:text>1</xsl:text>									
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">Y;Y;Y;</xsl:element>
								<xsl:element name="output_string">
									<xsl:value-of select="$transactionId"/>
									<xsl:text>1</xsl:text>									
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">Y;Y;Y;Y</xsl:element>
								<xsl:element name="output_string">
									<xsl:value-of select="$transactionId"/>
									<xsl:text>1</xsl:text>									
								</xsl:element>
							</xsl:element>							
						</xsl:element>
						<xsl:element name="no_mapping_error">N</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<xsl:element name="CcmFifModifyExternalNotificationCmd">
					<xsl:element name="command_id">modify_notification</xsl:element>
					<xsl:element name="CcmFifModifyExternalNotificationInCont">
						<xsl:element name="transaction_id_ref">
							<xsl:element name="command_id">map_find_notification_id</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>							
						</xsl:element>
						<xsl:element name="processed_indicator">Y</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">map_find_notification_id</xsl:element>
							<xsl:element name="field_name">output_string_found</xsl:element>							
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
					</xsl:element>
				</xsl:element>					
				
				<!-- check if notification should be created -->
				<xsl:element name="CcmFifConcatStringsCmd">
					<xsl:element name="command_id">concat_should_we_create_rebate</xsl:element>
					<xsl:element name="CcmFifConcatStringsInCont">
						<xsl:element name="input_string_list">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">find_service_1</xsl:element>
								<xsl:element name="field_name">service_found</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">;</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">check_sign_date_1</xsl:element>
								<xsl:element name="field_name">is_valid</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">;</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">check_sign_date_2</xsl:element>
								<xsl:element name="field_name">is_valid</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">;</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">map_find_notification_id</xsl:element>
								<xsl:element name="field_name">output_string_found</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>							
				<xsl:element name="CcmFifMapStringCmd">
					<xsl:element name="command_id">map_should_we_create_rebate</xsl:element>
					<xsl:element name="CcmFifMapStringInCont">
						<xsl:element name="input_string_type">xxx</xsl:element>
						<xsl:element name="input_string_ref">
							<xsl:element name="command_id">concat_should_we_create_rebate</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>
						</xsl:element>
						<xsl:element name="output_string_type">notificationId</xsl:element>
						<xsl:element name="string_mapping_list">
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">Y;Y;Y;N</xsl:element>
								<xsl:element name="output_string">Y</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">Y;Y;Y;Y</xsl:element>
								<xsl:element name="output_string">Y</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">Y;N;N;Y</xsl:element>
								<xsl:element name="output_string">Y</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">Y;Y;N;Y</xsl:element>
								<xsl:element name="output_string">Y</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">Y;N;Y;Y</xsl:element>
								<xsl:element name="output_string">Y</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="no_mapping_error">N</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<xsl:if test="request-param[@name='TARIFF'] = 'V8004'">
					<!-- check if notification should be created -->
					<xsl:element name="CcmFifConcatStringsCmd">
						<xsl:element name="command_id">concat_create_rebate_V8004</xsl:element>
						<xsl:element name="CcmFifConcatStringsInCont">
							<xsl:element name="input_string_list">
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">map_should_we_create_rebate</xsl:element>
									<xsl:element name="field_name">output_string</xsl:element>							
								</xsl:element>
								<xsl:element name="CcmFifPassingValueCont">
									<xsl:element name="value">;</xsl:element>							
								</xsl:element>
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">find_service_for_tariff</xsl:element>
									<xsl:element name="field_name">service_found</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>							
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">add_condition_service</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">add_mobile_ps</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">V8040</xsl:element>
							<xsl:element name="parent_service_subs_ref">
								<xsl:element name="command_id">add_mobile_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="desired_schedule_type">ASAP</xsl:element>
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_service_1</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">concat_create_rebate_V8004</xsl:element>
								<xsl:element name="field_name">output_string</xsl:element>							
							</xsl:element>
							<xsl:element name="required_process_ind">Y;Y</xsl:element>						
							<xsl:element name="service_characteristic_list"/>
						</xsl:element>
					</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">add_condition_service</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">add_mobile_ps</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">V8036</xsl:element>
							<xsl:element name="parent_service_subs_ref">
								<xsl:element name="command_id">add_mobile_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="desired_schedule_type">ASAP</xsl:element>
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_service_1</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">concat_create_rebate_V8004</xsl:element>
								<xsl:element name="field_name">output_string</xsl:element>							
							</xsl:element>
							<xsl:element name="required_process_ind">Y;N</xsl:element>						
							<xsl:element name="service_characteristic_list"/>
						</xsl:element>
					</xsl:element>					
				</xsl:if>
				
				<xsl:if test="request-param[@name='TARIFF'] != 'V8004'">
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">add_condition_service</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">add_mobile_ps</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">V8036</xsl:element>
							<xsl:element name="parent_service_subs_ref">
								<xsl:element name="command_id">add_mobile_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="desired_schedule_type">ASAP</xsl:element>
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_service_1</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">map_should_we_create_rebate</xsl:element>
								<xsl:element name="field_name">output_string</xsl:element>							
							</xsl:element>
							<xsl:element name="required_process_ind">Y</xsl:element>						
							<xsl:element name="service_characteristic_list"/>
						</xsl:element>
					</xsl:element>
				</xsl:if>
				
			</xsl:if>
			
			<!-- find bundle for service, if exists -->
			<xsl:element name="CcmFifFindBundleCmd">
				<xsl:element name="command_id">find_bundle_1</xsl:element>
				<xsl:element name="CcmFifFindBundleInCont">
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_stp_1</xsl:element>
						<xsl:element name="field_name">stp_found</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- find bundle for customer, if no service was found -->
			<xsl:element name="CcmFifFindBundleCmd">
				<xsl:element name="command_id">find_bundle_1</xsl:element>
				<xsl:element name="CcmFifFindBundleInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_stp_1</xsl:element>
						<xsl:element name="field_name">stp_found</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- concat results of two recent commands for use in process indicator --> 
			<xsl:element name="CcmFifConcatStringsCmd">
				<xsl:element name="command_id">concat_parameters_1</xsl:element>
				<xsl:element name="CcmFifConcatStringsInCont">
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_stp_1</xsl:element>
							<xsl:element name="field_name">stp_found</xsl:element>							
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">_</xsl:element>							
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">service_code</xsl:element>							
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">_</xsl:element>							
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_bundle_1</xsl:element>
							<xsl:element name="field_name">bundle_found</xsl:element>							
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>							
			
			<!-- create bundle, if none is found --> 
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
			
			<!-- add the new bundle item of type --> 
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item_1</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">modify_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd">MOBILE_SERVICE</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">add_mobile_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
				</xsl:element>
			</xsl:element>			
			
			<!-- add the new voice_service bundle item, if the main access service is a V0010 --> 
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item_2</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">modify_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd">VOICE_SERVICE</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">concat_parameters_1</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y_V0003_N</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- add the new voice_service bundle item, if the main access service is a V0010 --> 
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item_2</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">modify_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd">VOICE_SERVICE</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">concat_parameters_1</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y_V0010_N</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- add the new voice_service bundle item, if the main access service is a V0011 --> 
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item_2</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">modify_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd">VOICE_SERVICE</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">concat_parameters_1</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y_V0011_N</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- add a new voice and access bundle item, if the main access service is a I1201 --> 			
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item_2</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">modify_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd">VOICE</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">concat_parameters_1</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y_I1210_N</xsl:element>
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item_3</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">modify_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd">ACCESS</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">concat_parameters_1</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y_I1210_N</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- add a new dslr_service bundle item, if the main access service is a I1043 -->
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item_2</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">modify_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd">DSLR_SERVICE</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">concat_parameters_1</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">Y_I1043_N</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- get the next available PTN -->
			<xsl:element name="CcmFifGetNextAvailableProviderTrackingNumberCmd">
				<xsl:element name="command_id">get_ptn</xsl:element>
				<xsl:element name="CcmFifGetNextAvailableProviderTrackingNumberInCont">
					<xsl:element name="customer_tracking_id_ref">
						<xsl:element name="command_id">get_co_data_1</xsl:element>
						<xsl:element name="field_name">customer_tracking_id</xsl:element>
					</xsl:element>
					<xsl:element name="provider_tracking_number_suffix">m</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Customer Order for new services  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="customer_tracking_id_ref">
						<xsl:element name="command_id">get_co_data_1</xsl:element>
						<xsl:element name="field_name">customer_tracking_id</xsl:element>
					</xsl:element>
					<xsl:element name="provider_tracking_no_ref">
						<xsl:element name="command_id">get_ptn</xsl:element>
						<xsl:element name="field_name">provider_tracking_number</xsl:element>
					</xsl:element>
					<xsl:element name="super_customer_tracking_id">
						<xsl:value-of select="request-param[@name='SUPER_CUST_TRACKING_ID']"/>
					</xsl:element>
					<xsl:element name="scan_date">
						<xsl:value-of select="request-param[@name='SCAN_DATE']"/>
					</xsl:element>
					<xsl:element name="order_entry_date">
						<xsl:value-of select="request-param[@name='ENTRY_DATE']"/>
					</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<!-- V8000 -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_mobile_service</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<!-- fee service for tariff V8004 -->						
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_monthly_fee_service</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<!-- tariff options -->
						<xsl:for-each select="request-param-list[@name='TARIFF_OPTION_SERVICE_CODE_LIST']/request-param-list-item">
							<xsl:variable name="serviceCode" select="request-param[@name='SERVICE_CODE']"/>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">
									<xsl:value-of select="concat($addServCommandId, $serviceCode)"/>
								</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:for-each>		
						<!-- condition service for special offer -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_condition_service</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="generate_customer_tracking_id">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Release Customer Order for Dual Mode Services -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_1</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- concat text parts for contact text --> 
			<xsl:element name="CcmFifConcatStringsCmd">
				<xsl:element name="command_id">concat_contact_text_1</xsl:element>
				<xsl:element name="CcmFifConcatStringsInCont">
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">
								<xsl:text>Mobilfunkvertrag erstellt über </xsl:text>
								<xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
								<xsl:text>&#xA;TransactionID: </xsl:text>
								<xsl:value-of select="request-param[@name='transactionID']"/>
								<xsl:text>&#xA;Vertragsnummer: </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">create_order_form_1</xsl:element>
							<xsl:element name="field_name">contract_number</xsl:element>							
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">
								<xsl:text>&#xA;Username: </xsl:text>
								<xsl:value-of select="request-param[@name='USER_NAME']"/>								
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>							
			
			<!-- Create Contact for Service Addition -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">CREATE_MOBILE</xsl:element>
					<xsl:element name="short_description">Mobilfunkvertrag erstellt</xsl:element>
					<xsl:element name="description_text_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">concat_contact_text_1</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>							
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
							<xsl:element name="parameter_value">CreateMobilePhoneContract</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">USER_NAME</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='USER_NAME']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element>
							<xsl:element name="parameter_value">CCB</xsl:element>
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
								<xsl:text>Mobilfunkvertrag erstellt über </xsl:text>
								<xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
							</xsl:element>
						</xsl:element>					
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
