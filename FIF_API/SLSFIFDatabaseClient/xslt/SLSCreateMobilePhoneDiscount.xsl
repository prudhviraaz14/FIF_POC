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

			<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
			
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
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">V8000</xsl:element>
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
							<xsl:element name="customer_order_state">RELEASED</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">V8000</xsl:element>
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
				</xsl:element>
			</xsl:element>							
			
			<!-- Get PC data for sales org number -->
			<xsl:element name="CcmFifGetCommissioningInformationDataCmd">
				<xsl:element name="command_id">get_sales_org_number_1</xsl:element>
				<xsl:element name="CcmFifGetCommissioningInformationDataInCont">
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">O</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Check, if the value is a valid one -->
			<xsl:element name="CcmFifValidateGeneralCodeItemCmd">
				<xsl:element name="command_id">validate_sales_org_number</xsl:element>
				<xsl:element name="CcmFifValidateGeneralCodeItemInCont">
					<xsl:element name="group_code">SALEORGNUM</xsl:element>
					<xsl:element name="value_ref">
						<xsl:element name="command_id">get_sales_org_number_1</xsl:element>
						<xsl:element name="field_name">sales_org_number</xsl:element>							
					</xsl:element>
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
				</xsl:element>
			</xsl:element>

			<!-- check for a rebate service for this customer -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_rebate_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="product_code">V8900</xsl:element>
					<xsl:element name="service_code">V9001</xsl:element>
					<xsl:element name="no_service_error">N</xsl:element>
				</xsl:element>
			</xsl:element>							
						
			<!-- concat results of two recent commands for use in process indicator --> 
			<xsl:element name="CcmFifConcatStringsCmd">
				<xsl:element name="command_id">concat_parameters_2</xsl:element>
				<xsl:element name="CcmFifConcatStringsInCont">
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">validate_sales_org_number</xsl:element>
							<xsl:element name="field_name">is_valid</xsl:element>							
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">_</xsl:element>							
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_rebate_service</xsl:element>
							<xsl:element name="field_name">service_found</xsl:element>							
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
										
			<!-- Create Order Form-->
			<xsl:element name="CcmFifCreateOrderFormCmd">
				<xsl:element name="command_id">create_rebate_contract</xsl:element>
				<xsl:element name="CcmFifCreateOrderFormInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="sales_org_num_value_ref">
						<xsl:element name="command_id">get_sales_org_number_1</xsl:element>
						<xsl:element name="field_name">sales_org_number</xsl:element>
					</xsl:element>
					<xsl:element name="doc_template_name">Vertrag</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">concat_parameters_2</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y_N</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Order Form-->
			<xsl:element name="CcmFifCreateOrderFormCmd">
				<xsl:element name="command_id">create_rebate_contract</xsl:element>
				<xsl:element name="CcmFifCreateOrderFormInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="sales_org_num_value">97056619</xsl:element>
					<xsl:element name="doc_template_name">Vertrag</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">concat_parameters_2</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N_N</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Add Order Form Product Commitment -->
			<xsl:element name="CcmFifAddProductCommitCmd">
				<xsl:element name="command_id">add_rebate_product_commitment</xsl:element>
				<xsl:element name="CcmFifAddProductCommitInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">create_rebate_contract</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
					<xsl:element name="product_code">V8900</xsl:element>
					<xsl:element name="pricing_structure_code">V8905</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_rebate_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Sign Order Form -->
			<xsl:element name="CcmFifSignOrderFormCmd">
				<xsl:element name="command_id">sign_rebate_contract</xsl:element>
				<xsl:element name="CcmFifSignOrderFormInCont">
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">create_rebate_contract</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
					<xsl:element name="board_sign_name">Arcor</xsl:element>
					<xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_rebate_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Add Product Subscription -->
			<xsl:element name="CcmFifAddProductSubsCmd">
				<xsl:element name="command_id">add_rebate_ps</xsl:element>
				<xsl:element name="CcmFifAddProductSubsInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="product_commitment_number_ref">
						<xsl:element name="command_id">add_rebate_product_commitment</xsl:element>
						<xsl:element name="field_name">product_commitment_number</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_rebate_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Add Mobile Phone main rebate Service -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_rebate_service</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_rebate_ps</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V9001</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">CREATE_MOBILE</xsl:element>        
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_rebate_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
					<xsl:element name="service_characteristic_list"/>
				</xsl:element>
			</xsl:element>
			
			<!-- Add contributing item for account -->
			<xsl:element name="CcmFifAddModifyContributingItemCmd">
				<xsl:element name="command_id">add_rebate_ci</xsl:element>
				<xsl:element name="CcmFifAddModifyContributingItemInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_rebate_ps</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="price_plan_code">V8905</xsl:element>
					<xsl:element name="contributing_item_list">
						<xsl:element name="CcmFifContributingItem">
							<xsl:element name="supported_object_type_rd">ACCOUNT</xsl:element>
							<xsl:element name="start_date">
								<xsl:value-of select="$today"/>
							</xsl:element>
							<xsl:element name="hierarchy_inclusion_indicator">Y</xsl:element>								
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_service_1</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_rebate_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				</xsl:element>
			</xsl:element>				
			
			<!-- find bundle -->
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
			
			<!-- add the new bundle item of type --> 
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item_4</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">find_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd">MOBILE_DISCOUNT</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">add_rebate_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_rebate_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
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
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_rebate_service</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_rebate_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
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
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_rebate_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Contact for Service Addition -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">CREATE_MOBILE</xsl:element>
					<xsl:element name="short_description">Mobilfunkdiscount erstellt</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>Vertrag für Mobilfunkdiscount erstellt über SLS-Clearing.</xsl:text> 
						<xsl:text>TransactionId: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/> 
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create external notification -->
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<xsl:element name="command_id">create_external_notification_1</xsl:element>
				<xsl:element name="CcmFifCreateExternalNotificationInCont">
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
							<xsl:element name="parameter_value">CreateMobilePhoneDiscount</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">USER_NAME</xsl:element>
							<xsl:element name="parameter_value">slsfif</xsl:element>
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
								<xsl:text>Vertrag für Mobilfunkdiscount erstellt über SLS-Clearing.</xsl:text> 
								<xsl:text>TransactionId: </xsl:text>
								<xsl:value-of select="request-param[@name='transactionID']"/> 								
							</xsl:element>
						</xsl:element>					
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
