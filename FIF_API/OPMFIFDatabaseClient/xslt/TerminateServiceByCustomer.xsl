<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
	XSLT file for creating a wholesale TAL contract
	
	@author schwarje 
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
    exclude-result-prefixes="dateutils">    
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
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
		<xsl:variable name="tomorrow" select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
		
		<xsl:variable name="TerminationDate">
		   <xsl:if test="request-param[@name='TERMINATION_DATE'] != ''">			
			   <xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>		
		   </xsl:if>
		   <xsl:if test="request-param[@name='TERMINATION_DATE'] = ''">			
			   <xsl:value-of select="$today"/>		
		   </xsl:if>		   
		</xsl:variable>
		
		<xsl:variable name="NoticePeriodStartDate">
			<xsl:text/>
			<xsl:value-of select="$today"/>
		</xsl:variable>
		<xsl:variable name="TerminationReason">
			<xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
		</xsl:variable>
		<xsl:element name="Command_List">
			
			<!-- LTE Internet -->
			<!-- Find service by service code -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_ordered_lte_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>				
					<xsl:element name="service_code">Wh004</xsl:element> 				
					<xsl:element name="no_service_error">N</xsl:element>
					<xsl:element name="target_state">ORDERED</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Ensure that the termination has not been performed before -->
			<xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
				<xsl:element name="command_id">cancel_lte_service</xsl:element>
				<xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_ordered_lte_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="reason_rd">TERMINATION</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_ordered_lte_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Find service by service code -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_subscribed_lte_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="service_code">Wh004</xsl:element> 					
					<xsl:element name="no_service_error">N</xsl:element>
					<xsl:element name="target_state">SUBSCRIBED</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Terminate Product Subscription -->
			<xsl:element name="CcmFifTerminateProductSubsCmd">
				<xsl:element name="command_id">terminate_lte_product</xsl:element>
				<xsl:element name="CcmFifTerminateProductSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_subscribed_lte_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$TerminationDate"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">END_BEFORE</xsl:element>
					<xsl:element name="reason_rd">TERMINATION</xsl:element>
					<xsl:element name="auto_customer_order">N</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_subscribed_lte_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>			
			
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_uninstallation_fee</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_subscribed_lte_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">Wh008</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">TERMINATION</xsl:element>
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_subscribed_lte_service</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>
					</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_subscribed_lte_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
					<xsl:element name="service_characteristic_list"/>
				</xsl:element>
			</xsl:element>										
			
			<!-- Create Customer Order for new services  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_uninstall_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_subscribed_lte_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">003</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_uninstallation_fee</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>						
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_subscribed_lte_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Release stand alone customer Order --> 
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">release_uninstall_co</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_subscribed_lte_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_uninstall_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_subscribed_lte_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Terminate serviceSubscription -->
			<xsl:element name="CcmFifTermSuspReactServiceSubsCmd">
				<xsl:element name="command_id">terminate_uninstallation_fee</xsl:element>
				<xsl:element name="CcmFifTermSuspReactServiceSubsInCont">
					<xsl:element name="service_subscription_ref">
						<xsl:element name="command_id">add_uninstallation_fee</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="usage_mode">4</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$tomorrow"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					<xsl:element name="reason_rd">TERMINATION</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_subscribed_lte_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>                        
			
			<!-- Create Customer Order for new services  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_term_uninstall_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_subscribed_lte_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">004</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_uninstallation_fee</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>						
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_subscribed_lte_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Release stand alone customer Order --> 
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">release_term_uninstall_co</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_subscribed_lte_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_term_uninstall_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_subscribed_lte_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Terminate Order Form -->			
			<xsl:element name="CcmFifTerminateOrderFormCmd">
				<xsl:element name="command_id">terminate_lte_contract</xsl:element>
				<xsl:element name="CcmFifTerminateOrderFormInCont">
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">find_subscribed_lte_service</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
					<xsl:element name="termination_date">
						<xsl:value-of select="$TerminationDate"/>
					</xsl:element>
					<xsl:element name="notice_per_start_date">
						<xsl:value-of select="$NoticePeriodStartDate"/>
					</xsl:element>
					<xsl:element name="override_restriction">Y</xsl:element>
					<xsl:element name="termination_reason_rd">
						<xsl:value-of select="$TerminationReason"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_subscribed_lte_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- TAL -->
			<!-- Find service by service code -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_ordered_tal_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>				
					<xsl:element name="service_code">Wh003</xsl:element> 				
					<xsl:element name="no_service_error">N</xsl:element>
					<xsl:element name="target_state">ORDERED</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Ensure that the termination has not been performed before -->
			<xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
				<xsl:element name="command_id">cancel_tal_service</xsl:element>
				<xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_ordered_tal_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="reason_rd">TERMINATION</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_ordered_tal_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Find service by service code -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_subscribed_tal_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="service_code">Wh003</xsl:element> 					
					<xsl:element name="no_service_error">N</xsl:element>
					<xsl:element name="target_state">SUBSCRIBED</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Terminate Order Form -->
			<xsl:element name="CcmFifTerminateOrderFormCmd">
				<xsl:element name="command_id">terminate_tal_contract</xsl:element>
				<xsl:element name="CcmFifTerminateOrderFormInCont">
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">find_subscribed_tal_service</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
					<xsl:element name="termination_date">
						<xsl:value-of select="$TerminationDate"/>
					</xsl:element>
					<xsl:element name="notice_per_start_date">
						<xsl:value-of select="$NoticePeriodStartDate"/>
					</xsl:element>
					<xsl:element name="override_restriction">Y</xsl:element>
					<xsl:element name="termination_reason_rd">
						<xsl:value-of select="$TerminationReason"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_subscribed_tal_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Terminate Product Subscription -->
			<xsl:element name="CcmFifTerminateProductSubsCmd">
				<xsl:element name="command_id">terminate_tal_product</xsl:element>
				<xsl:element name="CcmFifTerminateProductSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_subscribed_tal_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$TerminationDate"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">END_BEFORE</xsl:element>
					<xsl:element name="reason_rd">TERMINATION</xsl:element>
					<xsl:element name="auto_customer_order">N</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_subscribed_tal_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
									
			<!-- VOICE -->
            <!-- Find service by service code -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_ordered_voice_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>				
					<xsl:element name="service_code">Wh010</xsl:element> 						
					<xsl:element name="no_service_error">N</xsl:element>
					<xsl:element name="target_state">ORDERED</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Ensure that the termination has not been performed before -->
			<xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
				<xsl:element name="command_id">cancel_voice_service</xsl:element>
				<xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_ordered_voice_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="reason_rd">TERMINATION</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_ordered_voice_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Find service by service code -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_subscribed_voice_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="service_code">Wh010</xsl:element> 					
					<xsl:element name="no_service_error">N</xsl:element>
					<xsl:element name="target_state">SUBSCRIBED</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Terminate Order Form -->
			<xsl:element name="CcmFifTerminateOrderFormCmd">
				<xsl:element name="command_id">terminate_voice_contract</xsl:element>
				<xsl:element name="CcmFifTerminateOrderFormInCont">
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">find_subscribed_voice_service</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
					<xsl:element name="termination_date">
						<xsl:value-of select="$TerminationDate"/>
					</xsl:element>
					<xsl:element name="notice_per_start_date">
						<xsl:value-of select="$NoticePeriodStartDate"/>
					</xsl:element>
					<xsl:element name="override_restriction">Y</xsl:element>
					<xsl:element name="termination_reason_rd">
						<xsl:value-of select="$TerminationReason"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_subscribed_voice_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Terminate Product Subscription -->
			<xsl:element name="CcmFifTerminateProductSubsCmd">
				<xsl:element name="command_id">terminate_voice_product</xsl:element>
				<xsl:element name="CcmFifTerminateProductSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_subscribed_voice_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$TerminationDate"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">END_BEFORE</xsl:element>
					<xsl:element name="reason_rd">TERMINATION</xsl:element>
					<xsl:element name="auto_customer_order">N</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_subscribed_voice_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>			
			
			<!-- IPTV -->
			<!-- Find service by service code -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_ordered_iptv_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>				
					<xsl:element name="service_code">Wh020</xsl:element> 						
					<xsl:element name="no_service_error">N</xsl:element>
					<xsl:element name="target_state">ORDERED</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Ensure that the termination has not been performed before -->
			<xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
				<xsl:element name="command_id">cancel_iptv_service</xsl:element>
				<xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_iptv_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="reason_rd">TERMINATION</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_iptv_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Find service by service code -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_subscribed_iptv_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="service_code">Wh020</xsl:element> 					
					<xsl:element name="no_service_error">N</xsl:element>
					<xsl:element name="target_state">SUBSCRIBED</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Terminate Order Form -->
			<xsl:element name="CcmFifTerminateOrderFormCmd">
				<xsl:element name="command_id">terminate_iptv_contract</xsl:element>
				<xsl:element name="CcmFifTerminateOrderFormInCont">
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">find_subscribed_iptv_service</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
					<xsl:element name="termination_date">
						<xsl:value-of select="$TerminationDate"/>
					</xsl:element>
					<xsl:element name="notice_per_start_date">
						<xsl:value-of select="$NoticePeriodStartDate"/>
					</xsl:element>
					<xsl:element name="override_restriction">Y</xsl:element>
					<xsl:element name="termination_reason_rd">
						<xsl:value-of select="$TerminationReason"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_subscribed_iptv_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Terminate Product Subscription -->
			<xsl:element name="CcmFifTerminateProductSubsCmd">
				<xsl:element name="command_id">terminate_iptv_product</xsl:element>
				<xsl:element name="CcmFifTerminateProductSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_subscribed_iptv_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$TerminationDate"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">END_BEFORE</xsl:element>
					<xsl:element name="reason_rd">TERMINATION</xsl:element>
					<xsl:element name="auto_customer_order">N</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_subscribed_iptv_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>		
			
			<!-- Create Customer Order for Termination -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_lte_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>		
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element> 
					<xsl:element name="provider_tracking_no">002</xsl:element>
					<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_lte_product</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
					</xsl:element>	
				</xsl:element>
			</xsl:element>
			
			<!-- Release Customer Order for Termination -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">release_lte_co</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>		
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_lte_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Customer Order for Termination -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_tal_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>		
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element> 
					<xsl:element name="provider_tracking_no">002</xsl:element>
					<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_tal_product</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
					</xsl:element>	
				</xsl:element>
			</xsl:element>
						
			<!-- Release Customer Order for Termination -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">release_tal_co</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>		
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_tal_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Customer Order for Termination -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_voice_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>		
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element> 
					<xsl:element name="provider_tracking_no">002v</xsl:element>
						<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_voice_product</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
					</xsl:element>			
				</xsl:element>
			</xsl:element>
			<!-- Release Customer Order for Termination -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">release_voice_co</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>		
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_voice_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Customer Order for Termination -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_iptv_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>		
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element> 
					<xsl:element name="provider_tracking_no">002h</xsl:element>
					<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_iptv_product</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
					</xsl:element>			
				</xsl:element>
			</xsl:element>
			<!-- Release Customer Order for Termination -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">release_iptv_co</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>		
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_iptv_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>

            <!-- Find owned account -->
			<xsl:element name="CcmFifFindAccountCmd">
				<xsl:element name="command_id">find_own_account</xsl:element>
				<xsl:element name="CcmFifFindAccountInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="no_account_error">N</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Finalize owned account if there is not any customer created -->
			<xsl:element name="CcmFifFinalizeAccountCmd">
				<xsl:element name="command_id">finalize_own_account</xsl:element>
				<xsl:element name="CcmFifFinalizeAccountInCont">
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_own_account</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>
					</xsl:element>
					<xsl:element name="effective_date">
						<xsl:value-of select="$TerminationDate"/>
					</xsl:element>
					<xsl:element name="bypass_command_ref">
						<xsl:element name="command_id">create_voice_co</xsl:element>
						<xsl:element name="field_name">customer_order_created</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>

	
			<!-- concat text parts for contact text -->
			<xsl:element name="CcmFifConcatStringsCmd">
				<xsl:element name="command_id">concat_contact_text</xsl:element>
				<xsl:element name="CcmFifConcatStringsInCont">
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">
								<xsl:text>Wholesale-Kunde gekündigt über </xsl:text>
								<xsl:value-of select="request-param[@name='clientName']"/>
								<xsl:text>&#xA;TransactionID:</xsl:text>
								<xsl:value-of select="request-param[@name='transactionID']"/>								
							</xsl:element>
						</xsl:element>						
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Create contact for Service Addition -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">TERM_WHS_CUST</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>Wholesale-Kunde gekündigt</xsl:text>
					</xsl:element>
					<xsl:element name="description_text_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">concat_contact_text</xsl:element>
							<xsl:element name="field_name">output_string</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
