<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
	<!--
		XSLT file for creating a FIF request for ordering a Arcor Mobile sim card
		@author banania 
	-->
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
	<xsl:element name="Command_List">
	
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
		
		<!-- Create Order Form-->
		<xsl:element name="CcmFifCreateOrderFormCmd">
			<xsl:element name="command_id">create_mobile_contract</xsl:element>
			<xsl:element name="CcmFifCreateOrderFormInCont">
				<xsl:element name="customer_number">
					<xsl:value-of select="request-param[@name='customerNumber']"/>
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
				<xsl:element name="doc_template_name">Vertrag</xsl:element>
				<xsl:element name="assoc_skeleton_cont_num">
					<xsl:value-of select="request-param[@name='assocSkeletonContNum']"/>
				</xsl:element>
				<!--<xsl:element name="auto_extent_period_value">
					<xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>
				</xsl:element>                         
				<xsl:element name="auto_extent_period_unit">
					<xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>
				</xsl:element>                         
				<xsl:element name="auto_extension_ind">
					<xsl:value-of select="request-param[@name='autoExtensionInd']"/>
				</xsl:element>-->
			</xsl:element>
		</xsl:element>		
		
		<xsl:element name="CcmFifAddProductCommitCmd">
			<xsl:element name="command_id">add_mobile_product_commitment</xsl:element>
			<xsl:element name="CcmFifAddProductCommitInCont">
				<xsl:element name="customer_number">
					<xsl:value-of select="request-param[@name='customerNumber']"/>
				</xsl:element>
				<xsl:element name="contract_number_ref">
					<xsl:element name="command_id">create_mobile_contract</xsl:element>
					<xsl:element name="field_name">contract_number</xsl:element>
				</xsl:element>
				<xsl:element name="product_code">V8000</xsl:element>
				<xsl:element name="pricing_structure_code">
					<xsl:value-of select="request-param[@name='tariff']"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
		
		<xsl:element name="CcmFifSignOrderFormCmd">
			<xsl:element name="command_id">populate_sign_date</xsl:element>
			<xsl:element name="CcmFifSignOrderFormInCont">
				<xsl:element name="contract_number_ref">
					<xsl:element name="command_id">create_mobile_contract</xsl:element>
					<xsl:element name="field_name">contract_number</xsl:element>
				</xsl:element>
				<xsl:element name="board_sign_name">ARCOR</xsl:element>							
				<xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
				<xsl:element name="sign_ind">N</xsl:element>
			</xsl:element>
		</xsl:element>					
		
		<xsl:element name="CcmFifAddProductSubsCmd">
			<xsl:element name="command_id">add_mobile_ps</xsl:element>
			<xsl:element name="CcmFifAddProductSubsInCont">
				<xsl:element name="customer_number">
					<xsl:value-of select="request-param[@name='customerNumber']"/>
				</xsl:element>
				<xsl:element name="product_commitment_number_ref">
					<xsl:element name="command_id">add_mobile_product_commitment</xsl:element>
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
				<xsl:element name="desired_schedule_type">ASAP</xsl:element>
				<xsl:element name="reason_rd">CREATE_MOBILE</xsl:element>        
				<xsl:element name="account_number">
					<xsl:value-of select="request-param[@name='accountNumber']"/>
				</xsl:element>
				<xsl:element name="service_characteristic_list">
					<!-- Artikelnummer -->
					<xsl:element name="CcmFifConfiguredValueCont">
						<xsl:element name="service_char_code">V0178</xsl:element>
						<xsl:element name="data_type">STRING</xsl:element>
						<xsl:element name="configured_value">
							<xsl:value-of select="request-param[@name='articleNumber']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
		
		<!-- Create Customer Order for new services  -->
		<xsl:element name="CcmFifCreateCustOrderCmd">
			<xsl:element name="command_id">create_mobile_co</xsl:element>
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
				<xsl:element name="provider_tracking_no_ref">
					<xsl:element name="command_id">get_ptn</xsl:element>
					<xsl:element name="field_name">provider_tracking_number</xsl:element>
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
					<!-- V8000 -->
					<xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">add_mobile_service</xsl:element>
						<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
					</xsl:element>
				</xsl:element>
				<xsl:element name="generate_customer_tracking_id">Y</xsl:element>
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
	
		<!-- add the new bundle item of type MOBILE_SERVICE --> 
		<xsl:element name="CcmFifModifyBundleItemCmd">
			<xsl:element name="command_id">add_mobile_bundle_item</xsl:element>
			<xsl:element name="CcmFifModifyBundleItemInCont">
				<xsl:element name="bundle_id_ref">
					<xsl:element name="command_id">read_bundle_id</xsl:element>
					<xsl:element name="field_name">parameter_value</xsl:element>
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
	
	<!--  Create external notification for internal purposes -->
	<xsl:element name="CcmFifCreateExternalNotificationCmd">
		<xsl:element name="command_id">create_mobile_service_notif</xsl:element>
		<xsl:element name="CcmFifCreateExternalNotificationInCont">
			<xsl:element name="effective_date">
				<xsl:value-of select="$today"/>
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
						<xsl:element name="command_id">add_mobile_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
				</xsl:element>							
				<xsl:element name="CcmFifParameterValueCont">
					<xsl:element name="parameter_name">
						<xsl:value-of select="request-param[@name='functionID']"/>
						<xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
					</xsl:element>
					<xsl:element name="parameter_value_ref">
						<xsl:element name="command_id">create_mobile_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:element>

	<xsl:element name="CcmFifCreateContactCmd">
		<xsl:element name="command_id">create_contact_1</xsl:element>
		<xsl:element name="CcmFifCreateContactInCont">
			<xsl:element name="customer_number">
				<xsl:value-of select="request-param[@name='customerNumber']"/>
			</xsl:element>
			<xsl:element name="contact_type_rd">CREATE_MOBILE</xsl:element>
			<xsl:element name="short_description">SIM-Karte bestellt</xsl:element>
			<xsl:element name="description_text_list">
				<xsl:element name="CcmFifPassingValueCont">
					<xsl:element name="contact_text">
						<xsl:text>Mobilfunkvertrag erstellt.&#xA;Vertragsnummer: </xsl:text>
					</xsl:element>
				</xsl:element>
				<xsl:element name="CcmFifCommandRefCont">
					<xsl:element name="command_id">create_mobile_contract</xsl:element>
					<xsl:element name="field_name">contract_number</xsl:element>       
				</xsl:element>
				<xsl:element name="CcmFifPassingValueCont">
					<xsl:element name="contact_text">  
						<xsl:text>&#xA;SIM Artikelnummer:  </xsl:text>
						<xsl:value-of select="request-param[@name='articleNumber']"/>	
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
		
		
	</xsl:element>
</xsl:template>
</xsl:stylesheet>
