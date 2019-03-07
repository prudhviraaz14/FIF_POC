<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
XSLT file for asynchronously terminating a tariff option

  @author schwarje
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
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
		
		<xsl:variable name="todayContact"  select="dateutils:createOPMDate(dateutils:getCurrentDate())"/>
		<xsl:variable name="tomorrowCCB" select="dateutils:createFIFDateOffset(dateutils:getCurrentDate(), 'DATE', '1')"/>
		<xsl:variable name="terminationDate"  select="dateutils:createOPMDate(request-param[@name='terminationDate'])"/>

		<xsl:element name="CcmFifFindServiceSubsCmd">
			<xsl:element name="command_id">find_service</xsl:element>
			<xsl:element name="CcmFifFindServiceSubsInCont">
				<xsl:element name="service_subscription_id">
					<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
				</xsl:element>
				<xsl:element name="no_service_error">N</xsl:element>
				<xsl:element name="target_state">SUBSCRIBED</xsl:element>
			</xsl:element>
		</xsl:element>
				
		<!-- contact if service couldn't be found --> 
		<xsl:element name="CcmFifCreateContactCmd">
			<xsl:element name="command_id">contact_text</xsl:element>
			<xsl:element name="CcmFifCreateContactInCont">
				<xsl:element name="customer_number">
					<xsl:value-of select="request-param[@name='customerNumber']"/>
				</xsl:element>
				<xsl:element name="contact_type_rd">ADD_FEATURE_SERV</xsl:element>
				<xsl:element name="short_description">Tarifoption gekündigt</xsl:element>
				<xsl:element name="long_description_text">
					<xsl:text>Tarifoption </xsl:text>
					<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
					<xsl:text> wurde nicht zum gewünschten Kündigungsdatum </xsl:text>
					<xsl:value-of select="$terminationDate"/>
					<xsl:text> beendet, da die Dienstenutzung nicht mehr gefunden werden konnte.</xsl:text>
					<xsl:text>&#xA;TransactionID: </xsl:text>
					<xsl:value-of select="request-param[@name='transactionID']"/>
				</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">find_service</xsl:element>
					<xsl:element name="field_name">service_found</xsl:element>          	
				</xsl:element>
				<xsl:element name="required_process_ind">N</xsl:element>
			</xsl:element>
		</xsl:element>      

		<!-- find latest STP -->
		<xsl:element name="CcmFifFindServiceTicketPositionCmd">
			<xsl:element name="command_id">find_stp</xsl:element>
			<xsl:element name="CcmFifFindServiceTicketPositionInCont">
				<xsl:element name="service_subscription_id">
					<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
				</xsl:element>
				<xsl:element name="no_stp_error">Y</xsl:element>
				<xsl:element name="find_stp_parameters">
					<xsl:element name="CcmFifFindStpParameterCont">
						<xsl:element name="usage_mode_value_rd">2</xsl:element>
						<xsl:element name="customer_order_state">FINAL</xsl:element>
					</xsl:element>
					<xsl:element name="CcmFifFindStpParameterCont">
						<xsl:element name="usage_mode_value_rd">1</xsl:element>
						<xsl:element name="customer_order_state">FINAL</xsl:element>
					</xsl:element>
				</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">find_service</xsl:element>
					<xsl:element name="field_name">service_found</xsl:element>          	
				</xsl:element>
				<xsl:element name="required_process_ind">Y</xsl:element>
			</xsl:element>
		</xsl:element>

		<!-- find the service, which is supposed to be terminated -->
		<xsl:element name="CcmFifFindServCharValueForServCharCmd">
			<xsl:element name="command_id">find_termination_date</xsl:element>
			<xsl:element name="CcmFifFindServCharValueForServCharInCont">
				<xsl:element name="service_ticket_position_id_ref">
					<xsl:element name="command_id">find_stp</xsl:element>
					<xsl:element name="field_name">service_ticket_position_id</xsl:element>
				</xsl:element>
				<xsl:element name="service_char_code">V0232</xsl:element>				
				<xsl:element name="no_csc_error">N</xsl:element>
				<xsl:element name="retrieve_all_characteristics">Y</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">find_stp</xsl:element>
					<xsl:element name="field_name">stp_found</xsl:element>          	
				</xsl:element>
				<xsl:element name="required_process_ind">Y</xsl:element>
			</xsl:element>
		</xsl:element>

		<xsl:element name="CcmFifValidateValueCmd">
			<xsl:element name="command_id">check_termination_date</xsl:element>
			<xsl:element name="CcmFifValidateValueInCont">
				<xsl:element name="value_ref">
					<xsl:element name="command_id">find_termination_date</xsl:element>
					<xsl:element name="field_name">characteristic_value</xsl:element>
				</xsl:element>
				<xsl:element name="allowed_values">
					<xsl:element name="CcmFifPassingValueCont">
						<xsl:element name="value">
							<xsl:value-of select="$terminationDate"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				<xsl:element name="ignore_failure_ind">Y</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">find_stp</xsl:element>
					<xsl:element name="field_name">stp_found</xsl:element>          	
				</xsl:element>
				<xsl:element name="required_process_ind">Y</xsl:element>
			</xsl:element>
		</xsl:element>
				
		<!-- contact if termination date from request doesn't the one from CSC --> 
		<xsl:element name="CcmFifCreateContactCmd">
			<xsl:element name="command_id">contact_text</xsl:element>
			<xsl:element name="CcmFifCreateContactInCont">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">find_service</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>
				</xsl:element>
				<xsl:element name="contact_type_rd">ADD_FEATURE_SERV</xsl:element>
				<xsl:element name="short_description">Tarifoption gekündigt</xsl:element>
				<xsl:element name="long_description_text">
					<xsl:text>Tarifoption </xsl:text>
					<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
					<xsl:text> wurde nicht zum gewünschten Kündigungsdatum </xsl:text>
					<xsl:value-of select="$terminationDate"/>
					<xsl:text> beendet, da es nicht mit dem gespeicherten Kündigungsdatum übereinstimmt.</xsl:text>
					<xsl:text>&#xA;TransactionID: </xsl:text>
					<xsl:value-of select="request-param[@name='transactionID']"/>
				</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">check_termination_date</xsl:element>
					<xsl:element name="field_name">success_ind</xsl:element>          	
				</xsl:element>
				<xsl:element name="required_process_ind">N</xsl:element>
			</xsl:element>
		</xsl:element>      

		<!-- find terminate STP, which could be cancelled -->
		<xsl:element name="CcmFifFindServiceTicketPositionCmd">
			<xsl:element name="command_id">find_open_stp</xsl:element>
			<xsl:element name="CcmFifFindServiceTicketPositionInCont">
				<xsl:element name="service_subscription_id">
					<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
				</xsl:element>
				<xsl:element name="usage_mode_value_rd">4</xsl:element>
				<xsl:element name="no_stp_error">N</xsl:element>
				<xsl:element name="find_stp_parameters">
					<xsl:element name="CcmFifFindStpParameterCont">
						<xsl:element name="service_ticket_position_state">UNASSIGNED</xsl:element>                                            
					</xsl:element>
					<xsl:element name="CcmFifFindStpParameterCont">
						<xsl:element name="service_ticket_position_state">ASSIGNED</xsl:element>                                            
					</xsl:element>
				</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">check_termination_date</xsl:element>
					<xsl:element name="field_name">success_ind</xsl:element>          	
				</xsl:element>
				<xsl:element name="required_process_ind">Y</xsl:element>
			</xsl:element>
		</xsl:element>

		<!-- cancel the ASSIGNED or UNASSIGNED STP -->
		<xsl:element name="CcmFifCancelServiceTicketPositionCmd">
			<xsl:element name="command_id">cancel_open_stp</xsl:element>
			<xsl:element name="CcmFifCancelServiceTicketPositionInCont">
				<xsl:element name="service_ticket_position_id_ref">
					<xsl:element name="command_id">find_open_stp</xsl:element>
					<xsl:element name="field_name">service_ticket_position_id</xsl:element>	
				</xsl:element>
				<xsl:element name="cancel_reason_rd">CUST_REQUEST</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">find_open_stp</xsl:element>
					<xsl:element name="field_name">stp_found</xsl:element>	
				</xsl:element>
				<xsl:element name="required_process_ind">Y</xsl:element>
			</xsl:element>
		</xsl:element>      

		<!-- find terminate STP, which cannot be cancelled -->
		<xsl:element name="CcmFifFindServiceTicketPositionCmd">
			<xsl:element name="command_id">find_released_stp</xsl:element>
			<xsl:element name="CcmFifFindServiceTicketPositionInCont">
				<xsl:element name="service_subscription_id">
					<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
				</xsl:element>
				<xsl:element name="usage_mode_value_rd">4</xsl:element>
				<xsl:element name="no_stp_error">N</xsl:element>
				<xsl:element name="find_stp_parameters">
					<xsl:element name="CcmFifFindStpParameterCont">
						<xsl:element name="service_ticket_position_state">RELEASED</xsl:element>                                            
					</xsl:element>
					<xsl:element name="CcmFifFindStpParameterCont">
						<xsl:element name="service_ticket_position_state">PROVISIONED</xsl:element>                                            
					</xsl:element>
					<xsl:element name="CcmFifFindStpParameterCont">
						<xsl:element name="service_ticket_position_state">INSTALLED</xsl:element>                                            
					</xsl:element>
				</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">check_termination_date</xsl:element>
					<xsl:element name="field_name">success_ind</xsl:element>          	
				</xsl:element>
				<xsl:element name="required_process_ind">Y</xsl:element>
			</xsl:element>
		</xsl:element>
		
		<!-- contact if released termination STP already exists --> 
		<xsl:element name="CcmFifCreateContactCmd">
			<xsl:element name="command_id">contact_text</xsl:element>
			<xsl:element name="CcmFifCreateContactInCont">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">find_service</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>
				</xsl:element>
				<xsl:element name="contact_type_rd">ADD_FEATURE_SERV</xsl:element>
				<xsl:element name="short_description">Tarifoption gekündigt</xsl:element>
				<xsl:element name="long_description_text">
					<xsl:text>Tarifoption </xsl:text>
					<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
					<xsl:text> wurde nicht zum gewünschten Kündigungsdatum </xsl:text>
					<xsl:value-of select="$terminationDate"/>
					<xsl:text> beendet, da ein offener Kündigungsauftrag besteht.</xsl:text>
					<xsl:text>&#xA;TransactionID: </xsl:text>
					<xsl:value-of select="request-param[@name='transactionID']"/>
				</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">find_released_stp</xsl:element>
					<xsl:element name="field_name">stp_found</xsl:element>          	
				</xsl:element>
				<xsl:element name="required_process_ind">Y</xsl:element>
			</xsl:element>
		</xsl:element>      
       
		<!-- create the termination STP -->
		<xsl:element name="CcmFifTermSuspReactServiceSubsCmd">
			<xsl:element name="command_id">terminate_service</xsl:element>
			<xsl:element name="CcmFifTermSuspReactServiceSubsInCont">
				<xsl:element name="service_subscription_ref">
					<xsl:element name="command_id">find_service</xsl:element>
					<xsl:element name="field_name">service_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="usage_mode">4</xsl:element>
				<xsl:element name="desired_schedule_type">ASAP</xsl:element>
				<xsl:element name="reason_rd">MODIFY_FEATURES</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">find_released_stp</xsl:element>
					<xsl:element name="field_name">stp_found</xsl:element>          	
				</xsl:element>
				<xsl:element name="required_process_ind">N</xsl:element>
			</xsl:element>
		</xsl:element>
      
		<!-- Create Customer Order -->
		<xsl:element name="CcmFifCreateCustOrderCmd">
			<xsl:element name="command_id">create_co</xsl:element>
			<xsl:element name="CcmFifCreateCustOrderInCont">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">find_service</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>
				</xsl:element>
				<xsl:element name="customer_tracking_id">
					<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
				</xsl:element>
				<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
				<xsl:element name="service_ticket_pos_list">
					<xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">terminate_service</xsl:element>
						<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
					</xsl:element>
				</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">find_released_stp</xsl:element>
					<xsl:element name="field_name">stp_found</xsl:element>          	
				</xsl:element>
				<xsl:element name="required_process_ind">N</xsl:element>
				<xsl:element name="processing_status">completedOPM</xsl:element>
			</xsl:element>
		</xsl:element>
		
		<!-- stop contributing item, if requested -->
		<xsl:if test="request-param[@name='handleContributingItem'] = 'Y'">
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_main_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="product_subscription_id_ref">
						<xsl:element name="command_id">find_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="fetch_main_ss_from_ps_Ind">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_released_stp</xsl:element>
						<xsl:element name="field_name">stp_found</xsl:element>	
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				</xsl:element>
			</xsl:element>

			<xsl:element name="CcmFifAddModifyContributingItemCmd">
				<xsl:element name="command_id">stop_contributing_item</xsl:element>
				<xsl:element name="CcmFifAddModifyContributingItemInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">
						<xsl:value-of select="request-param[@name='serviceCode']"/>
					</xsl:element>
					<xsl:element name="contributing_item_list">
						<xsl:element name="CcmFifContributingItem">
							<xsl:element name="supported_object_type_rd">SERVICE_SUBSC</xsl:element>
							<xsl:element name="stop_date">
								<xsl:value-of select="$tomorrowCCB"/>
							</xsl:element>
							<xsl:element name="service_subscription_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_released_stp</xsl:element>
						<xsl:element name="field_name">stp_found</xsl:element>	
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>
      
		<xsl:element name="CcmFifReleaseCustOrderCmd">
			<xsl:element name="command_id">activate_co</xsl:element>
			<xsl:element name="CcmFifReleaseCustOrderInCont">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">find_service</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>
				</xsl:element>
				<xsl:element name="customer_order_ref">
					<xsl:element name="command_id">create_co</xsl:element>
					<xsl:element name="field_name">customer_order_id</xsl:element>
				</xsl:element>
				<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">find_released_stp</xsl:element>
					<xsl:element name="field_name">stp_found</xsl:element>          	
				</xsl:element>
				<xsl:element name="required_process_ind">N</xsl:element>
			</xsl:element>
		</xsl:element>
		
		<!-- contact for successful trx --> 
		<xsl:element name="CcmFifCreateContactCmd">
			<xsl:element name="command_id">contact_text</xsl:element>
			<xsl:element name="CcmFifCreateContactInCont">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">find_service</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>
				</xsl:element>
				<xsl:element name="contact_type_rd">ADD_FEATURE_SERV</xsl:element>
				<xsl:element name="short_description">Tarifoption gekündigt</xsl:element>
				<xsl:element name="long_description_text">
					<xsl:text>Tarifoption </xsl:text>
					<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
					<xsl:text> wurde am </xsl:text>
					<xsl:value-of select="$todayContact"/>
					<xsl:text> beendet (gewünschtes Kündigungsdatum </xsl:text>
					<xsl:value-of select="$terminationDate"/>
					<xsl:text>).</xsl:text>
					<xsl:text>&#xA;TransactionID: </xsl:text>
					<xsl:value-of select="request-param[@name='transactionID']"/>
				</xsl:element>
				<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">create_co</xsl:element>
					<xsl:element name="field_name">customer_order_created</xsl:element>          	
				</xsl:element>
				<xsl:element name="required_process_ind">Y</xsl:element>
			</xsl:element>
		</xsl:element>      
				
	</xsl:element>

</xsl:template>
</xsl:stylesheet>
