<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--
		XSLT file for creating a FIF request for creating a full customer. It creates following:
		Entity, Address, Mailing, Account and Customer
		
		@author banania
	-->
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
	<xsl:template match="/">
		<xsl:element name="CcmFifCommandList">
			<xsl:apply-templates select="request/request-params"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="request-params">
		<!-- Copy over transaction ID,action name & override_system_date -->
		<xsl:element name="transaction_id">
			<xsl:value-of select="request-param[@name='transactionID']"/>
		</xsl:element>
		<xsl:element name="client_name">TF</xsl:element>
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
		</xsl:element>
		<xsl:element name="Command_List">
			<!-- Create Entity-->
			<xsl:element name="CcmFifCreateEntityCmd">
				<xsl:element name="command_id">create_entity_1</xsl:element>
				<xsl:element name="CcmFifCreateEntityInCont">
					<xsl:element name="entity_type">
						<xsl:value-of select="request-param[@name='ENTITY_TYPE']"/>
					</xsl:element>
					<xsl:element name="salutation_description">
						<xsl:value-of select="request-param[@name='SALUTATION_DESCRIPTION']"/>
					</xsl:element>
					<xsl:element name="title_description">
						<xsl:value-of select="request-param[@name='TITLE_DESCRIPTION']"/>
					</xsl:element>
					<xsl:element name="nobility_prefix_description">
						<xsl:value-of select="request-param[@name='NOBILITY_PREFIX_DESCRIPTION']"/>
					</xsl:element>
					<xsl:element name="forename">
						<xsl:value-of select="request-param[@name='FORENAME']"/>
					</xsl:element>
					<xsl:element name="name">
						<xsl:value-of select="request-param[@name='NAME']"/>
					</xsl:element>
					<xsl:element name="birth_date">
						<xsl:value-of select="request-param[@name='BIRTH_DATE']"/>
					</xsl:element>
					<xsl:element name="organization_type_rd">
						<xsl:value-of select="request-param[@name='ORGANIZATION_TYPE_RD']"/>
					</xsl:element>					
				</xsl:element>
			</xsl:element>
			<!-- Create Access Information -->
			<xsl:if test="request-param[@name='CREATE_ACCESS_INFORMATION'] = 'Y'">
				<xsl:element name="CcmFifUpdateAccessInformCmd">
					<xsl:element name="command_id">create_access_information_1</xsl:element>
					<xsl:element name="CcmFifUpdateAccessInformInCont">
						<xsl:element name="entity_ref">
							<xsl:element name="command_id">create_entity_1</xsl:element>
							<xsl:element name="field_name">entity_id</xsl:element>
						</xsl:element>
						<xsl:element name="access_information_type_rd">
							<xsl:value-of select="request-param[@name='ACCESS_INFORMATION_TYPE']"/>
						</xsl:element>
						<xsl:element name="contact_name">
							<xsl:value-of select="concat(request-param[@name='FORENAME'],request-param[@name='NAME'])"/>
						</xsl:element>
						<xsl:element name="phone_number">
							<xsl:value-of select="request-param[@name='PHONE_NUMBER']"/>
						</xsl:element>
						<xsl:element name="mobile_number">
							<xsl:value-of select="request-param[@name='MOBILE_NUMBER']"/>
						</xsl:element>
						<xsl:element name="fax_number">
							<xsl:value-of select="request-param[@name='FAX_NUMBER']"/>
						</xsl:element>
						<xsl:element name="email_address">
							<xsl:value-of select="request-param[@name='EMAIL_ADDRESS']"/>
						</xsl:element>
						<xsl:element name="electronic_contact_indicator">
							<xsl:value-of select="request-param[@name='ELECTRONIC_CONTACT_INDICATOR']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Create Address-->
			<xsl:element name="CcmFifCreateAddressCmd">
				<xsl:element name="command_id">create_address_1</xsl:element>
				<xsl:element name="CcmFifCreateAddressInCont">
					<xsl:element name="entity_ref">
						<xsl:element name="command_id">create_entity_1</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element>
					<xsl:element name="address_type">
						<xsl:value-of select="request-param[@name='ADDRESS_TYPE']"/>
					</xsl:element>
					<xsl:element name="street_name">
						<xsl:value-of select="request-param[@name='STREET_NAME']"/>
					</xsl:element>
					<xsl:element name="street_number">
						<xsl:value-of select="request-param[@name='STREET_NUMBER']"/>
					</xsl:element>
					<xsl:element name="postal_code">
						<xsl:value-of select="request-param[@name='POSTAL_CODE']"/>
					</xsl:element>
					<xsl:element name="city_name">
						<xsl:value-of select="request-param[@name='CITY_NAME']"/>
					</xsl:element>
					<xsl:element name="country_code">
						<xsl:value-of select="request-param[@name='COUNTRY_CODE']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Create Customer-->
			<xsl:element name="CcmFifCreateCustomerCmd">
				<xsl:element name="command_id">create_customer_1</xsl:element>
				<xsl:element name="CcmFifCreateCustomerInCont">
					<xsl:element name="entity_ref">
						<xsl:element name="command_id">create_entity_1</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element>
					<xsl:element name="address_ref">
						<xsl:element name="command_id">create_address_1</xsl:element>
						<xsl:element name="field_name">address_id</xsl:element>
					</xsl:element>
					<xsl:element name="user_password">
						<xsl:value-of select="request-param[@name='USER_PASSWORD']"/>
					</xsl:element>
					<xsl:element name="match_code_id">
						<xsl:value-of select="request-param[@name='MATCH_CODE_ID']"/>
					</xsl:element>
					<xsl:element name="customer_group_rd">
						<xsl:value-of select="request-param[@name='CUSTOMER_GROUP_RD']"/>
					</xsl:element>
					<xsl:element name="category_rd">
						<xsl:value-of select="request-param[@name='CATEGORY_RD']"/>
					</xsl:element>
					<xsl:element name="classification_rd">
						<xsl:value-of select="request-param[@name='CLASSIFICATION_RD']"/>
					</xsl:element>
					<xsl:element name="masking_digits_rd">
						<xsl:value-of select="request-param[@name='MASKING_DIGITS_RD']"/>
					</xsl:element>
					<xsl:element name="payment_method_rd">
						<xsl:value-of select="request-param[@name='PAYMENT_METHOD_RD']"/>
					</xsl:element>
					<xsl:element name="payment_term_rd">
						<xsl:value-of select="request-param[@name='PAYMENT_TERM_RD']"/>
					</xsl:element>
					<xsl:element name="cycle_name">
						<xsl:value-of select="request-param[@name='CYCLE_NAME']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			
			<xsl:if test="request-param[@name='WHOLESALE_PARTNER'] != ''">
				<!-- get reference data (parent customer number) -->				
				<xsl:element name="CcmFifGetCrossRefSecondaryValueCmd">
					<xsl:element name="command_id">get_parent_customer</xsl:element>
					<xsl:element name="CcmFifGetCrossRefSecondaryValueInCont">
						<xsl:element name="group_code">WHS_CUST</xsl:element>
						<xsl:element name="primary_value">
							<xsl:value-of select="request-param[@name='WHOLESALE_PARTNER']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- Add customer to hierarchy-->
				<xsl:element name="CcmFifAddCustomerToHierarchyCmd">
					<xsl:element name="command_id">add_customer_to_hierarchy_1</xsl:element>
					<xsl:element name="CcmFifAddCustomerToHierarchyInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">create_customer_1</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="parent_customer_number_ref">
							<xsl:element name="command_id">get_parent_customer</xsl:element>
							<xsl:element name="field_name">secondary_value</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="request-param[@name='PARENT_CUSTOMER_NUMBER'] != ''
				and request-param[@name='WHOLESALE_PARTNER'] = ''">				
				<!-- Add customer to hierarchy-->
				<xsl:element name="CcmFifAddCustomerToHierarchyCmd">
					<xsl:element name="command_id">add_customer_to_hierarchy_1</xsl:element>
					<xsl:element name="CcmFifAddCustomerToHierarchyInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">create_customer_1</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="parent_customer_number">
							<xsl:value-of select="request-param[@name='PARENT_CUSTOMER_NUMBER']"/>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="request-param[@name='CREATE_ACCOUNT'] = 'Y'">
				<!-- Create bank account -->
				<xsl:if test="request-param[@name='BIC'] != ''
					and request-param[@name='IBAN'] != ''">
					<xsl:element name="CcmFifCreateBankAccountCmd">
						<xsl:element name="command_id">create_bank_account_1</xsl:element>
						<xsl:element name="CcmFifCreateBankAccountInCont">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">create_customer_1</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
							<xsl:element name="bank_account_number">
								<xsl:value-of select="request-param[@name='BANK_ACCOUNT_NUMBER']"/>
							</xsl:element>
							
							<xsl:element name="owner_full_name">
								<xsl:value-of select="request-param[@name='OWNER_FULL_NAME']"/>
							</xsl:element>
							<xsl:element name="bank_clearing_code">
								<xsl:value-of select="request-param[@name='BANK_CLEARING_CODE']"/>
							</xsl:element>
							<xsl:element name="bank_identifier_code">
								<xsl:value-of select="request-param[@name='BIC']"/>
							</xsl:element>
							<xsl:element name="internat_bank_account_number">
								<xsl:value-of select="request-param[@name='IBAN']"/>
							</xsl:element>
							<xsl:element name="bank_name">
								<xsl:value-of select="request-param[@name='BANK_NAME']"/>
							</xsl:element> 
						</xsl:element>
					</xsl:element>
				</xsl:if>
				<!-- Create mailing-->
				<xsl:element name="CcmFifCreateMailingCmd">
					<xsl:element name="command_id">create_mailing_1</xsl:element>
					<xsl:element name="CcmFifCreateMailingInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">create_customer_1</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="address_ref">
							<xsl:element name="command_id">create_address_1</xsl:element>
							<xsl:element name="field_name">address_id</xsl:element>
						</xsl:element>
						<xsl:element name="access_information_ref">
							<xsl:element name="command_id">create_access_information_1</xsl:element>
							<xsl:element name="field_name">access_information_id</xsl:element>
						</xsl:element>			
						<xsl:element name="mailing_name">
							<xsl:value-of select="request-param[@name='MAILING_NAME']"/>
						</xsl:element>
						<xsl:element name="printer_destination_rd">
							<xsl:value-of select="request-param[@name='PRINTER_DESTINATION_RD']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				<!-- Create account-->
				<xsl:element name="CcmFifCreateAccountCmd">
					<xsl:element name="command_id">create_account_1</xsl:element>
					<xsl:element name="CcmFifCreateAccountInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">create_customer_1</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="bank_account_id_ref">
							<xsl:element name="command_id">create_bank_account_1</xsl:element>
							<xsl:element name="field_name">bank_account_id</xsl:element>
						</xsl:element>
						<xsl:if test="request/request-params/request-param[@name='BANK_ACCOUNT_ID']
							= ''">
							<xsl:element name="credit_card_id">
								<xsl:value-of select="request-param[@name='CREDIT_CARD_ID']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="mailing_id_ref">
							<xsl:element name="command_id">create_mailing_1</xsl:element>
							<xsl:element name="field_name">mailing_id</xsl:element>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
						</xsl:element>
						<xsl:element name="doc_template_name">
							<xsl:value-of select="request-param[@name='DOC_TEMPLATE_NAME']"/>
						</xsl:element>
						<xsl:element name="method_of_payment">
							<xsl:value-of select="request-param[@name='METHOD_OF_PAYMENT']"/>
						</xsl:element>
						<xsl:element name="manual_suspend_ind">
							<xsl:value-of select="request-param[@name='MANUAL_SUSPEND_IND']"/>
						</xsl:element>
						<xsl:element name="language_rd">
							<xsl:value-of select="request-param[@name='LANGUAGE_RD']"/>
						</xsl:element>
						<xsl:element name="currency_rd">
							<xsl:value-of select="request-param[@name='CURRENCY_RD']"/>
						</xsl:element>
						<xsl:element name="cycle_name">
							<xsl:value-of select="request-param[@name='CYCLE_NAME']"/>
						</xsl:element>
						<xsl:element name="payment_term_rd">
							<xsl:value-of select="request-param[@name='PAYMENT_TERM_RD']"/>
						</xsl:element>
						<xsl:element name="zero_charge_ind">
							<xsl:value-of select="request-param[@name='ZERO_CHARGE_IND']"/>
						</xsl:element>
						<xsl:element name="usage_limit">
							<xsl:value-of select="request-param[@name='USAGE_LIMIT']"/>
						</xsl:element>
						<xsl:element name="customer_account_id">
							<xsl:value-of select="request-param[@name='CUSTOMER_ACCOUNT_ID']"/>
						</xsl:element>
						<xsl:element name="output_device_rd">
							<xsl:value-of select="request-param[@name='OUTPUT_DEVICE_RD']"/>
						</xsl:element>
						<xsl:element name="direct_debit_authoriz_date">
							<xsl:value-of select="request-param[@name='DIRECT_DEBIT_AUTHORIZ_DATE']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<xsl:element name="CcmFifAddAffinityGroupCmd">
				<xsl:element name="command_id">add_affinity_group_1</xsl:element>
				<xsl:element name="CcmFifAddAffinityGroupInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">create_customer_1</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="affinity_group_list">
						<xsl:for-each select="request-param-list[@name='AFFINITY_GROUP_LIST']/request-param-list-item">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">
									<xsl:value-of select="request-param[@name='AFFINITY_GROUP']"/>
								</xsl:element>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			
			</xsl:element>
	</xsl:template>
</xsl:stylesheet>
