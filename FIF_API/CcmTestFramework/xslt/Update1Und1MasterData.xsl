<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for requesting a master data update from 1und1
	
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
		
		<xsl:element name="Command_List">
				
			<!-- get customer data to retrieve the customer's status -->
			<xsl:element name="CcmFifGetCustomerDataCmd">
				<xsl:element name="command_id">get_customer_data</xsl:element>
				<xsl:element name="CcmFifGetCustomerDataInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- check for termination/cancelation -->
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_termination</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="no_stp_error">N</xsl:element>
					<xsl:element name="allow_terminated_services">Y</xsl:element>					
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">Wh010</xsl:element>
							<xsl:element name="usage_mode_value_rd">4</xsl:element>
							<xsl:element name="customer_order_state">FINAL</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">Wh010</xsl:element>
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
							<xsl:element name="customer_order_state">CANCELED</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>			
			
			<xsl:element name="CcmFifMapStringCmd">
				<xsl:element name="command_id">continue_masterdataupdate</xsl:element>
				<xsl:element name="CcmFifMapStringInCont">
					<xsl:element name="input_string_type">Kundenstatus</xsl:element>
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">get_customer_data</xsl:element>
							<xsl:element name="field_name">state_rd</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">;</xsl:element>							
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_termination</xsl:element>
							<xsl:element name="field_name">stp_found</xsl:element>							
						</xsl:element>
					</xsl:element>
					<xsl:element name="output_string_type">Stammdatenupdate fortsetzen</xsl:element>
					<xsl:element name="string_mapping_list">
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">ACTIVATED;Y</xsl:element>
							<xsl:element name="output_string">N</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">SUSPENDED;Y</xsl:element>
							<xsl:element name="output_string">N</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">TERMINATED;Y</xsl:element>
							<xsl:element name="output_string">N</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">ACTIVATED;N</xsl:element>
							<xsl:element name="output_string">Y</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">SUSPENDED;N</xsl:element>
							<xsl:element name="output_string">Y</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifStringMappingCont">
							<xsl:element name="input_string">TERMINATED;N</xsl:element>
							<xsl:element name="output_string">N</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="no_mapping_error">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
				
			<!-- find main access stp in case of hw service -->
			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
				<xsl:element name="command_id">find_wholesale_voice_stp</xsl:element>
				<xsl:element name="CcmFifFindServiceTicketPositionInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="no_stp_error">Y</xsl:element>
					<xsl:element name="find_stp_parameters">
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">Wh010</xsl:element>
							<xsl:element name="usage_mode_value_rd">2</xsl:element>
							<xsl:element name="customer_order_state">RELEASED</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">Wh010</xsl:element>
							<xsl:element name="usage_mode_value_rd">2</xsl:element>
							<xsl:element name="customer_order_state">FINAL</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">Wh010</xsl:element>
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
							<xsl:element name="customer_order_state">RELEASED</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifFindStpParameterCont">
							<xsl:element name="service_code">Wh010</xsl:element>
							<xsl:element name="usage_mode_value_rd">1</xsl:element>
							<xsl:element name="customer_order_state">FINAL</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">continue_masterdataupdate</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>					
				</xsl:element>
			</xsl:element>
			
			<!-- get access number data -->
			<xsl:element name="CcmFifFindServCharValueForServCharCmd">
				<xsl:element name="command_id">get_access_number_data</xsl:element>
				<xsl:element name="CcmFifFindServCharValueForServCharInCont">
					<xsl:element name="service_ticket_position_id_ref">
						<xsl:element name="command_id">find_wholesale_voice_stp</xsl:element>
						<xsl:element name="field_name">service_ticket_position_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_char_code">V0001</xsl:element>
					<xsl:element name="no_csc_error">N</xsl:element>
					<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">continue_masterdataupdate</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>										
				</xsl:element>
			</xsl:element>							
			
			<xsl:variable name="today"
				select="dateutils:getCurrentDate()"/>
			<xsl:variable name="nextMasterdataUpdate">
				<xsl:value-of select="dateutils:createFIFDateOffset($today, 'DATE', '7')"/>
			</xsl:variable>			
			
			<!-- request the next update -->
			<xsl:element name="CcmFifCreateFifRequestCmd">
				<xsl:element name="command_id">update_master_data</xsl:element> 
				<xsl:element name="CcmFifCreateFifRequestInCont">
					<xsl:element name="action_name">update1Und1MasterData</xsl:element> 
					<xsl:element name="due_date">
						<xsl:value-of select="$nextMasterdataUpdate"/>
					</xsl:element> 
					<xsl:element name="dependent_transaction_id">dummy</xsl:element>
					<xsl:element name="priority">4</xsl:element>
					<xsl:element name="bypass_command">N</xsl:element>
					<xsl:element name="external_system_id">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>                  
					<xsl:element name="request_param_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">customerNumber</xsl:element> 
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='customerNumber']"/>
							</xsl:element>                  
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">get_access_number_data</xsl:element>
						<xsl:element name="field_name">value_empty</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>										
				</xsl:element>
			</xsl:element>						
			
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">MASTERDATAUPDATE</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>Masterdataupdate beauftragt</xsl:text>
					</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>Masterdataupdate verschoben, da keine Rufnummer gefunden werden konnte.</xsl:text> 
						<xsl:text>&#xA;Nächster Versuch: </xsl:text>
						<xsl:value-of select="$nextMasterdataUpdate"/>
						<xsl:text>&#xA;CCM-FIF-TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">get_access_number_data</xsl:element>
						<xsl:element name="field_name">value_empty</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>			
			
			<!-- call the bus for master data update request -->
			<xsl:element name="CcmFifProcessServiceBusRequestCmd">
				<xsl:element name="command_id">request_master_data_update</xsl:element>
				<xsl:element name="CcmFifProcessServiceBusRequestInCont">
					<xsl:element name="package_name">net.arcor.cfm.epsm_cfm_whseue_001</xsl:element>
					<xsl:element name="service_name">AktualisiereEueKundendaten</xsl:element>
					<xsl:element name="synch_ind">N</xsl:element>
					<xsl:element name="external_system_id">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>							
					<xsl:element name="priority">2</xsl:element>			
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">GetExternalIDByPhonenumber;Phonenumber;InternationalAreaCode</xsl:element>
							<xsl:element name="parameter_value">49</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">GetExternalIDByPhonenumber;Phonenumber;Prefix</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">get_access_number_data</xsl:element>
								<xsl:element name="field_name">city_code</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">GetExternalIDByPhonenumber;Phonenumber;Number</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">get_access_number_data</xsl:element>
								<xsl:element name="field_name">local_number</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">GetExternalIDByPhonenumber;Tnb</xsl:element>
							<xsl:element name="parameter_value">D009</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">GetExternalIDByPhonenumber;ValidAt</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="dateutils:create1Und1Date(dateutils:getCurrentDate())"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">get_access_number_data</xsl:element>
						<xsl:element name="field_name">value_empty</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>					
				</xsl:element>
			</xsl:element>
						
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">MASTERDATAUPDATE</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>Masterdataupdate beauftragt</xsl:text>
					</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>Masterdataupdate beauftragt bei 1und1 über </xsl:text>
						<xsl:value-of select="request-param[@name='clientName']"/>
						<xsl:text>&#xA;CCM-FIF-TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">get_access_number_data</xsl:element>
						<xsl:element name="field_name">value_empty</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>					
				</xsl:element>
			</xsl:element>			
			
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">MASTERDATAUPDATE</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>Masterdataupdate beendet</xsl:text>
					</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>Masterdataupdate beendet, Kunde ist bereits deaktiviert</xsl:text>				
						<xsl:text>&#xA;CCM-FIF-TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">continue_masterdataupdate</xsl:element>
						<xsl:element name="field_name">output_string</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>					
				</xsl:element>
			</xsl:element>			
			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
