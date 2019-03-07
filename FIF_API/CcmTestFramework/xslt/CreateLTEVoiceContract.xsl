<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a LTE Voice contract

  @author banania 
-->

<!DOCTYPE XSL [

<!ENTITY CSCMapping SYSTEM "CSCMapping.xsl">
<!ENTITY CSCMapping_LTEVoice SYSTEM "CSCMapping_LTEVoice.xsl">
<!ENTITY CSCMapping_AddressCreation SYSTEM "CSCMapping_AddressCreation.xsl">
<!ENTITY ContractCreation_DataRetrieval SYSTEM "ContractCreation_DataRetrieval.xsl">
<!ENTITY ContractCreation_OutputParameters SYSTEM "ContractCreation_OutputParameters.xsl">
]>

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
				
		<xsl:element name="Command_List">
			
			<xsl:variable name="productCode">VI208</xsl:variable>
			
			<xsl:variable name="AutoExtentPeriodValue">				
				<xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>						   
			</xsl:variable>			
			
			<xsl:variable name="AutoExtentPeriodUnit">					
				<xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>						   
			</xsl:variable>						
			
			<xsl:variable name="AutoExtensionInd">					
				<xsl:value-of select="request-param[@name='autoExtensionInd']"/>						   
			</xsl:variable>		
			
			<xsl:variable name="NoticePeriodDurationValue">					
				<xsl:value-of select="request-param[@name='noticePeriodDurationValue']"/>					   
			</xsl:variable>		
			
			<xsl:variable name="NoticePeriodDurationUnit">					
				<xsl:value-of select="request-param[@name='noticePeriodDurationUnit']"/>					   
			</xsl:variable>		
			
			
			&ContractCreation_DataRetrieval;
			
			<xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
				&CSCMapping_LTEVoice;
				&CSCMapping_AddressCreation;
			</xsl:for-each>
						
			<xsl:variable name="mainAccessServiceCode">
				<xsl:choose>
					<xsl:when test="request-param[@name='serviceType'] = 'Basis'">VI018</xsl:when>
					<xsl:when test="request-param[@name='serviceType'] = 'Premium'">VI019</xsl:when>
					<xsl:otherwise>unknown</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<!-- Add business DSL main service Subscription -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_main_service</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">
						<xsl:value-of select="$mainAccessServiceCode"/>
					</xsl:element>
					<xsl:element name="service_subscription_id">
						<xsl:value-of select="request-param[@name='allocatedServiceSubscriptionId']"/>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reason']"/>
					</xsl:element>
					<xsl:element name="account_number">
						<xsl:value-of select="request-param[@name='accountNumber']"/>
					</xsl:element>
					<xsl:element name="service_characteristic_list">
						<xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
							&CSCMapping_LTEVoice;
							&CSCMapping;
						</xsl:for-each>						
						<!-- Aktivierungsdatum -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0909</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$activationDateOPM" /> 
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_main_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">add_main_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>			
			
			<!-- Add Monthly charge Service V0017 -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_V0017</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0017</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_main_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reason']"/>
					</xsl:element>
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>
					</xsl:element>
					<xsl:element name="service_characteristic_list"/>	
				</xsl:element>
			</xsl:element>	
					
			<!-- add the new  bundle item of type LTEVOICE -->
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">read_bundle_id</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd">LTEVOICE</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">add_main_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
				<xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
					<xsl:element name="customer_order_id_ref">
						<xsl:element name="command_id">read_customer_order</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<!-- main service -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_main_service</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<!-- V0017 -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_V0017</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="processing_status">
						<xsl:value-of select="request-param[@name='processingStatus']"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">read_customer_order</xsl:element>
						<xsl:element name="field_name">value_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>   
				</xsl:element>
			</xsl:element>
			
			<!-- Create Customer Order for new services  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
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
						<!-- main service -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_main_service</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<!-- V0017 -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_V0017</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">read_customer_order</xsl:element>
						<xsl:element name="field_name">value_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>   
					<xsl:element name="e_shop_id">
						<xsl:value-of select="request-param[@name='eShopID']"/>
					</xsl:element>
					<xsl:element name="processing_status">
						<xsl:value-of select="request-param[@name='processingStatus']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact_1</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="contact_type_rd">CREATE_LTEVOICE</xsl:element>
					<xsl:element name="short_description">LTE-Voice erstellt</xsl:element>
					<xsl:element name="description_text_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>LTE-Voice-Vertrag erstellt.&#xA;Vertragsnummer: </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">contract_number</xsl:element>          
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>&#xA;Produktnutzung: </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>          
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">                								
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
			
			&ContractCreation_OutputParameters;
						
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
