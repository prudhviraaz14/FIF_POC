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
		<xsl:variable name="today" 
			select="dateutils:getCurrentDate()"/>
		<xsl:variable name="tomorrow"
			select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
		
		<xsl:element name="Command_List">

			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_main_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="service_subscription_id">
						<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>			
			
			<!-- check for open orders -->
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_open_orders</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>          
					</xsl:element>
					<xsl:element name="no_stp_error">N</xsl:element>
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="customer_order_state">DEFINED</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="customer_order_state">RELEASED</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="customer_order_state">COMPLETE</xsl:element>
						</xsl:element>
					</xsl:element>					
				</xsl:element>
			</xsl:element>
			
			<!-- raise error in case of an open order -->      
			<xsl:element name="CcmFifRaiseErrorCmd">
				<xsl:element name="command_id">raise_error</xsl:element>
				<xsl:element name="CcmFifRaiseErrorInCont">
					<xsl:element name="error_text">Der zu migrierende MOS-Vertrag enthält noch offene Aufträge</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_open_orders</xsl:element>
						<xsl:element name="field_name">stp_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>	
				</xsl:element>
			</xsl:element>     				
			
			<!-- change to new tariff -->
			<xsl:element name="CcmFifRenegotiateOrderFormCmd">
				<xsl:element name="command_id">renegotiate</xsl:element>
				<xsl:element name="CcmFifRenegotiateOrderFormInCont">
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
					<xsl:element name="product_commit_list">
						<xsl:element name="CcmFifProductCommitCont">
							<xsl:element name="new_pricing_structure_code">I4001</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
						
			<!-- Sign Order Form And Apply New Pricing Structure -->
			<xsl:element name="CcmFifSignAndApplyNewPricingStructCmd">
				<xsl:element name="command_id">sign_apply</xsl:element>
				<xsl:element name="CcmFifSignAndApplyNewPricingStructInCont">
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">O</xsl:element>
					<xsl:element name="apply_swap_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
					<xsl:element name="board_sign_name">Vodafone</xsl:element>
					<xsl:element name="primary_cust_sign_name">Kunde</xsl:element>
				</xsl:element>
			</xsl:element>			
			
			<!--			
				I4014 BPOS Suite							-> I402D Union Enterprise C
				I4015 Exchange Online						-> I402K Exchange Online Standard
				I4016 Sharepoint Online						-> I402M Sharepoint Online Standard
				I4017 Exchange Online Deskless Worker		-> I402H Exchange Online Deskless Worker
				I4018 Sharepoint Online Deskless Worker		-> noch offen
				I4019 Deskless Online Worker				-> I402B Union Enterprise A
				I4020 Office Communications Online			-> I402S Office Communicator Online
				I4021 Office Livemeeting					-> I402U Livemeeting Standard
				I4027 Hosted Blackberry						-> I402W Hosted Blackberry Enterprise Server
				I4022 Exchange Speicherplatzerweiterung		-> wird nicht migriert
				I4023 Sharepoint Speicherplatzerweiterung	-> I402X Speicherplatzerweiterung SharePoint
			-->			
			
			<!-- ********************************************************* -->			
			<!-- ***************** migrate I4014 to I402D **************** -->
			<!-- ********************************************************* -->			
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_I4014_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="product_subscription_id_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_code">I4014</xsl:element>
					<xsl:element name="no_service_error">N</xsl:element>
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_I4014_stp</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_I4014_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">2</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
						</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>
			<!-- retrieve all relevant CSCs of the old MOS service -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4005_for_I4014</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4005</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4006_for_I4014</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4006</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4008_for_I4014</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4008</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4009_for_I4014</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4009</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4010_for_I4014</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4010</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4011_for_I4014</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4011</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4012_for_I4014</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4012</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<!-- creating the new MOS service -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_I402D</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">I402D</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">MOS_MIGRATION</xsl:element> 
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>          
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>					
					<xsl:element name="service_characteristic_list">
						<!-- Steuerung ueber OP -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I0030</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">ohne OP</xsl:element>
						</xsl:element>
						<!-- Anzahl -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4005</xsl:element>
							<xsl:element name="data_type">INTEGER</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4005_for_I4014</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- OpcoSubscriptionId -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4006</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4006_for_I4014</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- domain -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4008</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4008_for_I4014</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminUserName -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4009</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4009_for_I4014</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminPassword -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4010</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4010_for_I4014</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerStartEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4011</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4011_for_I4014</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerEndEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4012</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4012_for_I4014</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- clone HostedBES for I4014 -->
			<xsl:element name="CcmFifFindExclusiveChildServSubsCmd">
				<xsl:element name="command_id">find_I4014_HostedBES_service</xsl:element>
				<xsl:element name="CcmFifFindExclusiveChildServSubsInCont">
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">find_I4014_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_code_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="service_code">I4027</xsl:element>
						</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_I4014_HostedBES_stp</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_I4014_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">2</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
						</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>
			<!-- retrieve all relevant CSCs of the old MOS service -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4005_for_I4014_HostedBES</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_HostedBES_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4005</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4006_for_I4014_HostedBES</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_HostedBES_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4006</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4008_for_I4014_HostedBES</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_HostedBES_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4008</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4009_for_I4014_HostedBES</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_HostedBES_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4009</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4010_for_I4014_HostedBES</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_HostedBES_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4010</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4011_for_I4014_HostedBES</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_HostedBES_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4011</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4012_for_I4014_HostedBES</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_HostedBES_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4012</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<!-- creating the new HostedBES service -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_I402W_for_I402D</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">I402W</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_I402D</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">MOS_MIGRATION</xsl:element> 
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>          
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>					
					<xsl:element name="service_characteristic_list">
						<!-- Steuerung ueber OP -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I0030</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">ohne OP</xsl:element>
						</xsl:element>
						<!-- Anzahl -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4005</xsl:element>
							<xsl:element name="data_type">INTEGER</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4005_for_I4014_HostedBES</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- OpcoSubscriptionId -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4006</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4006_for_I4014_HostedBES</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- domain -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4008</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4008_for_I4014_HostedBES</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminUserName -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4009</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4009_for_I4014_HostedBES</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminPassword -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4010</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4010_for_I4014_HostedBES</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerStartEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4011</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4011_for_I4014_HostedBES</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerEndEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4012</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4012_for_I4014_HostedBES</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- clone SharepointExt for I4014 -->
			<xsl:element name="CcmFifFindExclusiveChildServSubsCmd">
				<xsl:element name="command_id">find_I4014_SharepointExt_service</xsl:element>
				<xsl:element name="CcmFifFindExclusiveChildServSubsInCont">
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">find_I4014_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_code_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="service_code">I4023</xsl:element>
						</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_I4014_SharepointExt_stp</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_I4014_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">2</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
						</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>
			<!-- retrieve all relevant CSCs of the old MOS service -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4005_for_I4014_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4005</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4006_for_I4014_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4006</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4008_for_I4014_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4008</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4009_for_I4014_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4009</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4010_for_I4014_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4010</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4011_for_I4014_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4011</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4012_for_I4014_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4014_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4012</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<!-- creating the new SharepointExt service -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_I402X_for_I402D</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">I402X</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_I402D</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">MOS_MIGRATION</xsl:element> 
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>          
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4014_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>					
					<xsl:element name="service_characteristic_list">
						<!-- Steuerung ueber OP -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I0030</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">ohne OP</xsl:element>
						</xsl:element>
						<!-- Anzahl -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4005</xsl:element>
							<xsl:element name="data_type">INTEGER</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4005_for_I4014_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- OpcoSubscriptionId -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4006</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4006_for_I4014_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- domain -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4008</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4008_for_I4014_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminUserName -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4009</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4009_for_I4014_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminPassword -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4010</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4010_for_I4014_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerStartEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4011</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4011_for_I4014_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerEndEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4012</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4012_for_I4014_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
						
			<!-- ********************************************************* -->			
			<!-- ***************** migrate I4015 to I402K **************** -->
			<!-- ********************************************************* -->			
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_I4015_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="product_subscription_id_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_code">I4015</xsl:element>
					<xsl:element name="no_service_error">N</xsl:element>
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_I4015_stp</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_I4015_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">2</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
						</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>
			<!-- retrieve all relevant CSCs of the old MOS service -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4005_for_I4015</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4015_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4005</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4006_for_I4015</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4015_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4006</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4008_for_I4015</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4015_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4008</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4009_for_I4015</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4015_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4009</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4010_for_I4015</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4015_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4010</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4011_for_I4015</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4015_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4011</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4012_for_I4015</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4015_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4012</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<!-- creating the new MOS service -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_I402K</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">I402K</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">MOS_MIGRATION</xsl:element> 
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>          
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>					
					<xsl:element name="service_characteristic_list">
						<!-- Steuerung ueber OP -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I0030</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">ohne OP</xsl:element>
						</xsl:element>
						<!-- Anzahl -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4005</xsl:element>
							<xsl:element name="data_type">INTEGER</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4005_for_I4015</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- OpcoSubscriptionId -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4006</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4006_for_I4015</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- domain -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4008</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4008_for_I4015</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminUserName -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4009</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4009_for_I4015</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminPassword -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4010</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4010_for_I4015</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerStartEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4011</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4011_for_I4015</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerEndEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4012</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4012_for_I4015</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- clone HostedBES for I4015 -->
			<xsl:element name="CcmFifFindExclusiveChildServSubsCmd">
				<xsl:element name="command_id">find_I4015_HostedBES_service</xsl:element>
				<xsl:element name="CcmFifFindExclusiveChildServSubsInCont">
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">find_I4015_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_code_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="service_code">I4027</xsl:element>
						</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_I4015_HostedBES_stp</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_I4015_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">2</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
						</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>
			<!-- retrieve all relevant CSCs of the old MOS service -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4005_for_I4015_HostedBES</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4015_HostedBES_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4005</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4006_for_I4015_HostedBES</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4015_HostedBES_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4006</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4008_for_I4015_HostedBES</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4015_HostedBES_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4008</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4009_for_I4015_HostedBES</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4015_HostedBES_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4009</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4010_for_I4015_HostedBES</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4015_HostedBES_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4010</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4011_for_I4015_HostedBES</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4015_HostedBES_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4011</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4012_for_I4015_HostedBES</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4015_HostedBES_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4012</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<!-- creating the new HostedBES service -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_I402W_for_I402K</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">I402W</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_I402K</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">MOS_MIGRATION</xsl:element> 
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>          
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4015_HostedBES_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>					
					<xsl:element name="service_characteristic_list">
						<!-- Steuerung ueber OP -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I0030</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">ohne OP</xsl:element>
						</xsl:element>
						<!-- Anzahl -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4005</xsl:element>
							<xsl:element name="data_type">INTEGER</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4005_for_I4015_HostedBES</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- OpcoSubscriptionId -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4006</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4006_for_I4015_HostedBES</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- domain -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4008</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4008_for_I4015_HostedBES</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminUserName -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4009</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4009_for_I4015_HostedBES</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminPassword -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4010</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4010_for_I4015_HostedBES</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerStartEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4011</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4011_for_I4015_HostedBES</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerEndEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4012</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4012_for_I4015_HostedBES</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
												
																		
			<!-- ********************************************************* -->			
			<!-- ***************** migrate I4016 to I402M **************** -->
			<!-- ********************************************************* -->			
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_I4016_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="product_subscription_id_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_code">I4016</xsl:element>
					<xsl:element name="no_service_error">N</xsl:element>
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_I4016_stp</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_I4016_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">2</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
						</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>
			<!-- retrieve all relevant CSCs of the old MOS service -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4005_for_I4016</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4016_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4005</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4006_for_I4016</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4016_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4006</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4008_for_I4016</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4016_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4008</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4009_for_I4016</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4016_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4009</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4010_for_I4016</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4016_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4010</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4011_for_I4016</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4016_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4011</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4012_for_I4016</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4016_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4012</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<!-- creating the new MOS service -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_I402M</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">I402M</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">MOS_MIGRATION</xsl:element> 
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>          
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>					
					<xsl:element name="service_characteristic_list">
						<!-- Steuerung ueber OP -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I0030</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">ohne OP</xsl:element>
						</xsl:element>
						<!-- Anzahl -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4005</xsl:element>
							<xsl:element name="data_type">INTEGER</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4005_for_I4016</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- OpcoSubscriptionId -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4006</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4006_for_I4016</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- domain -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4008</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4008_for_I4016</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminUserName -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4009</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4009_for_I4016</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminPassword -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4010</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4010_for_I4016</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerStartEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4011</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4011_for_I4016</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerEndEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4012</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4012_for_I4016</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- clone SharepointExt for I4016 -->
			<xsl:element name="CcmFifFindExclusiveChildServSubsCmd">
				<xsl:element name="command_id">find_I4016_SharepointExt_service</xsl:element>
				<xsl:element name="CcmFifFindExclusiveChildServSubsInCont">
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">find_I4016_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_code_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="service_code">I4023</xsl:element>
						</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_I4016_SharepointExt_stp</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_I4016_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">2</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
						</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>
			<!-- retrieve all relevant CSCs of the old MOS service -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4005_for_I4016_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4016_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4005</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4006_for_I4016_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4016_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4006</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4008_for_I4016_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4016_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4008</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4009_for_I4016_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4016_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4009</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4010_for_I4016_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4016_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4010</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4011_for_I4016_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4016_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4011</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4012_for_I4016_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4016_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4012</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<!-- creating the new SharepointExt service -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_I402X_for_I402M</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">I402X</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_I402M</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">MOS_MIGRATION</xsl:element> 
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>          
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4016_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>					
					<xsl:element name="service_characteristic_list">
						<!-- Steuerung ueber OP -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I0030</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">ohne OP</xsl:element>
						</xsl:element>
						<!-- Anzahl -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4005</xsl:element>
							<xsl:element name="data_type">INTEGER</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4005_for_I4016_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- OpcoSubscriptionId -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4006</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4006_for_I4016_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- domain -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4008</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4008_for_I4016_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminUserName -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4009</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4009_for_I4016_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminPassword -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4010</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4010_for_I4016_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerStartEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4011</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4011_for_I4016_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerEndEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4012</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4012_for_I4016_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>			
			
			
			<!-- ********************************************************* -->			
			<!-- ***************** migrate I4017 to I402H **************** -->
			<!-- ********************************************************* -->			
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_I4017_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="product_subscription_id_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_code">I4017</xsl:element>
					<xsl:element name="no_service_error">N</xsl:element>
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_I4017_stp</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_I4017_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">2</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
						</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4017_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>
			<!-- retrieve all relevant CSCs of the old MOS service -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4005_for_I4017</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4017_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4005</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4017_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4006_for_I4017</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4017_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4006</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4017_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4008_for_I4017</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4017_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4008</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4017_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4009_for_I4017</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4017_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4009</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4017_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4010_for_I4017</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4017_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4010</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4017_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4011_for_I4017</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4017_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4011</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4017_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4012_for_I4017</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4017_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4012</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4017_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<!-- creating the new MOS service -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_I402H</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">I402H</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">MOS_MIGRATION</xsl:element> 
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>          
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4017_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>					
					<xsl:element name="service_characteristic_list">
						<!-- Steuerung ueber OP -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I0030</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">ohne OP</xsl:element>
						</xsl:element>
						<!-- Anzahl -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4005</xsl:element>
							<xsl:element name="data_type">INTEGER</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4005_for_I4017</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- OpcoSubscriptionId -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4006</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4006_for_I4017</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- domain -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4008</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4008_for_I4017</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminUserName -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4009</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4009_for_I4017</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminPassword -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4010</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4010_for_I4017</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerStartEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4011</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4011_for_I4017</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerEndEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4012</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4012_for_I4017</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
							
			<!-- ********************************************************* -->			
			<!-- ***************** migrate I4019 to I402B **************** -->
			<!-- ********************************************************* -->			
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_I4019_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="product_subscription_id_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_code">I4019</xsl:element>
					<xsl:element name="no_service_error">N</xsl:element>
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_I4019_stp</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_I4019_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">2</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
						</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>
			<!-- retrieve all relevant CSCs of the old MOS service -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4005_for_I4019</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4019_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4005</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4006_for_I4019</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4019_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4006</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4008_for_I4019</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4019_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4008</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4009_for_I4019</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4019_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4009</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4010_for_I4019</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4019_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4010</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4011_for_I4019</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4019_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4011</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4012_for_I4019</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4019_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4012</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<!-- creating the new MOS service -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_I402B</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">I402B</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">MOS_MIGRATION</xsl:element> 
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>          
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>					
					<xsl:element name="service_characteristic_list">
						<!-- Steuerung ueber OP -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I0030</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">ohne OP</xsl:element>
						</xsl:element>
						<!-- Anzahl -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4005</xsl:element>
							<xsl:element name="data_type">INTEGER</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4005_for_I4019</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- OpcoSubscriptionId -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4006</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4006_for_I4019</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- domain -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4008</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4008_for_I4019</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminUserName -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4009</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4009_for_I4019</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminPassword -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4010</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4010_for_I4019</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerStartEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4011</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4011_for_I4019</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerEndEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4012</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4012_for_I4019</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			
			<!-- clone SharepointExt for I4019 -->
			<xsl:element name="CcmFifFindExclusiveChildServSubsCmd">
				<xsl:element name="command_id">find_I4019_SharepointExt_service</xsl:element>
				<xsl:element name="CcmFifFindExclusiveChildServSubsInCont">
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">find_I4019_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_code_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="service_code">I4023</xsl:element>
						</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_I4019_SharepointExt_stp</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_I4019_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">2</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
						</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>
			<!-- retrieve all relevant CSCs of the old MOS service -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4005_for_I4019_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4019_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4005</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4006_for_I4019_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4019_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4006</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4008_for_I4019_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4019_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4008</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4009_for_I4019_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4019_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4009</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4010_for_I4019_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4019_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4010</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4011_for_I4019_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4019_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4011</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4012_for_I4019_SharepointExt</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4019_SharepointExt_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4012</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<!-- creating the new SharepointExt service -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_I402X_for_I402B</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">I402X</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_I402B</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">MOS_MIGRATION</xsl:element> 
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>          
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4019_SharepointExt_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>					
					<xsl:element name="service_characteristic_list">
						<!-- Steuerung ueber OP -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I0030</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">ohne OP</xsl:element>
						</xsl:element>
						<!-- Anzahl -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4005</xsl:element>
							<xsl:element name="data_type">INTEGER</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4005_for_I4019_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- OpcoSubscriptionId -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4006</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4006_for_I4019_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- domain -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4008</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4008_for_I4019_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminUserName -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4009</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4009_for_I4019_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminPassword -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4010</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4010_for_I4019_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerStartEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4011</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4011_for_I4019_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerEndEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4012</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4012_for_I4019_SharepointExt</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
											
			<!-- ********************************************************* -->			
			<!-- ***************** migrate I4020 to I402S **************** -->
			<!-- ********************************************************* -->			
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_I4020_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="product_subscription_id_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_code">I4020</xsl:element>
					<xsl:element name="no_service_error">N</xsl:element>
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_I4020_stp</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_I4020_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">2</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
						</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4020_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>
			<!-- retrieve all relevant CSCs of the old MOS service -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4005_for_I4020</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4020_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4005</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4020_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4006_for_I4020</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4020_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4006</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4020_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4008_for_I4020</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4020_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4008</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4020_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4009_for_I4020</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4020_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4009</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4020_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4010_for_I4020</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4020_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4010</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4020_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4011_for_I4020</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4020_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4011</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4020_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4012_for_I4020</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4020_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4012</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4020_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<!-- creating the new MOS service -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_I402S</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">I402S</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">MOS_MIGRATION</xsl:element> 
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>          
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4020_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>					
					<xsl:element name="service_characteristic_list">
						<!-- Steuerung ueber OP -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I0030</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">ohne OP</xsl:element>
						</xsl:element>
						<!-- Anzahl -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4005</xsl:element>
							<xsl:element name="data_type">INTEGER</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4005_for_I4020</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- OpcoSubscriptionId -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4006</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4006_for_I4020</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- domain -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4008</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4008_for_I4020</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminUserName -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4009</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4009_for_I4020</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminPassword -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4010</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4010_for_I4020</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerStartEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4011</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4011_for_I4020</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerEndEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4012</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4012_for_I4020</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
				
			<!-- ********************************************************* -->			
			<!-- ***************** migrate I4021 to I402U **************** -->
			<!-- ********************************************************* -->			
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_I4021_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="product_subscription_id_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_code">I4021</xsl:element>
					<xsl:element name="no_service_error">N</xsl:element>
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_I4021_stp</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_I4021_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>          
					</xsl:element>
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">2</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
						</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4021_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>
			<!-- retrieve all relevant CSCs of the old MOS service -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4005_for_I4021</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4021_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4005</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4021_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4006_for_I4021</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4021_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4006</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4021_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4008_for_I4021</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4021_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4008</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4021_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4009_for_I4021</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4021_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4009</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4021_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4010_for_I4021</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4021_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4010</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4021_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4011_for_I4021</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4021_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4011</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4021_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">find_I4012_for_I4021</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_I4021_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>          
					</xsl:element>
					<xsl:element name="service_char_code">I4012</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4021_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>						
				</xsl:element>
			</xsl:element>			
			<!-- creating the new MOS service -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_I402U</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">I402U</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">MOS_MIGRATION</xsl:element> 
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>          
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_I4021_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>								
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>					
					<xsl:element name="service_characteristic_list">
						<!-- Steuerung ueber OP -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I0030</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">ohne OP</xsl:element>
						</xsl:element>
						<!-- Anzahl -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4005</xsl:element>
							<xsl:element name="data_type">INTEGER</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4005_for_I4021</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- OpcoSubscriptionId -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4006</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4006_for_I4021</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- domain -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4008</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4008_for_I4021</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminUserName -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4009</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4009_for_I4021</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- AdminPassword -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4010</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4010_for_I4021</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerStartEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4011</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4011_for_I4021</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
						<!-- PartnerEndEffectiveDate -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">I4012</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value_ref">
								<xsl:element name="command_id">find_I4012_for_I4021</xsl:element>
								<xsl:element name="field_name">characteristic_value</xsl:element>							
							</xsl:element>
						</xsl:element>
					</xsl:element>
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
					<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_I4013</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_I4014</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_I4015</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_I4016</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_I4017</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_I4018</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_I4019</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_I4020</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_I4021</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_I402D</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_I402W_for_I402D</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>						
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_I402X_for_I402D</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>												
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_I402K</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_I402W_for_I402K</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_I402M</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_I402X_for_I402M</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>												
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_I402H</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_I402B</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_I402X_for_I402B</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>												
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_I402S</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_I402U</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_I402W</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="processing_status">completedOPM</xsl:element>
				</xsl:element>
			</xsl:element>

			<!--
			<xsl:element name="CcmFifActivateCustomerOrderCmd">
				<xsl:element name="command_id">activate_co</xsl:element>
				<xsl:element name="CcmFifActivateCustomerOrderInCont">
					<xsl:element name="customer_order_id_ref">
						<xsl:element name="command_id">create_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			-->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element> 
					<xsl:element name="release_delay_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>      
			
			<!-- Create contact -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="contact_type_rd">CREATE_MOS</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>MOS-Vertrag migriert</xsl:text>
					</xsl:element>
					<xsl:element name="description_text_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>Microsoft-Online-Suite migriert.&#xA;Vertragsnummer: </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">contract_number</xsl:element>          
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
		</xsl:element>

	</xsl:template>
</xsl:stylesheet>
