<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for changing selected destinations

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
		
		
		<xsl:variable name="action">
		   <xsl:value-of select="request-param[@name='Action']"/>		
		</xsl:variable>

		<xsl:variable name="terminationDate">
		   <xsl:if test="request-param[@name='DateTime'] != ''">			
			   <xsl:value-of select="request-param[@name='DateTime']"/>		
		   </xsl:if>
		   <xsl:if test="request-param[@name='DateTime'] = ''">			
			   <xsl:value-of select="$today"/>		
		   </xsl:if>		   
		</xsl:variable>
		
		<xsl:variable name="noticePeriodStartDate">
			<xsl:text/>
			<xsl:value-of select="$today"/>
		</xsl:variable>
	
		
		
<!-- Find service by service code I5678-->	

			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_WebTT_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CustomerNumber']"/>
					</xsl:element>
					<xsl:element name="product_code">I5120</xsl:element>					
					<xsl:element name="service_code">I5678</xsl:element> 				
					<xsl:element name="no_service_error">N</xsl:element>
					<xsl:element name="target_state">SUBSCRIBED</xsl:element>
				</xsl:element>
			</xsl:element>

<xsl:if test="$action = 'ADD' or $action = 'Create'">
<!-- Create Order Form-->
		    <xsl:element name="CcmFifCreateOrderFormCmd">
			<xsl:element name="command_id">create_WebTT_contract</xsl:element>
			<xsl:element name="CcmFifCreateOrderFormInCont">
				<xsl:element name="customer_number">
					<xsl:value-of select="request-param[@name='CustomerNumber']"/>
				</xsl:element>
				<xsl:element name="min_per_dur_value">0</xsl:element>
				<xsl:element name="min_per_dur_unit">MONTH</xsl:element>
				<xsl:element name="sales_org_num_value">97000015</xsl:element>
            <xsl:element name="doc_template_name">Vertrag</xsl:element>
				<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_WebTT_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>		
				<xsl:element name="auto_extent_period_value">0</xsl:element>
				<xsl:element name="auto_extent_period_unit">MONTH</xsl:element>
				<xsl:element name="auto_extension_ind">N</xsl:element>
				<xsl:element name="name">WebTicket 2.0 kostenfrei</xsl:element>
				</xsl:element>
			</xsl:element>
		
<!-- Add Order Form Product Commitment -->		
		<xsl:element name="CcmFifAddProductCommitCmd">
				<xsl:element name="command_id">add_product_commitment</xsl:element>
				<xsl:element name="CcmFifAddProductCommitInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CustomerNumber']"/>
					</xsl:element>
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">create_WebTT_contract</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
					<xsl:element name="product_code">I5120</xsl:element>
					<xsl:element name="pricing_structure_code">I5002</xsl:element>					
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_WebTT_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>					
				</xsl:element>
			</xsl:element>
<!-- Sign Order Form  -->				
		<xsl:element name="CcmFifSignOrderFormCmd">
			<xsl:element name="command_id">populate_sign_date</xsl:element>
			<xsl:element name="CcmFifSignOrderFormInCont">
				<xsl:element name="contract_number_ref">
					<xsl:element name="command_id">create_WebTT_contract</xsl:element>
					<xsl:element name="field_name">contract_number</xsl:element>
				</xsl:element>
				<xsl:element name="board_sign_name">Vodafone</xsl:element>							
				<xsl:element name="primary_cust_sign_name">WebTicket 2.0 kostenfrei</xsl:element>
				<xsl:element name="primary_cust_sign_date">
								<xsl:value-of select="request-param[@name='primaryCustSignDate']"/>
							</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_WebTT_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>	
			</xsl:element>
			</xsl:element>
			
<!-- Add Product Subscription  -->	
<xsl:element name="CcmFifAddProductSubsCmd">
			<xsl:element name="command_id">add_WebTT_ps</xsl:element>
			<xsl:element name="CcmFifAddProductSubsInCont">
				<xsl:element name="customer_number">
					<xsl:value-of select="request-param[@name='CustomerNumber']"/>
				</xsl:element>
				<xsl:element name="product_commitment_number_ref">
					<xsl:element name="command_id">add_product_commitment</xsl:element>
					<xsl:element name="field_name">product_commitment_number</xsl:element>
				</xsl:element>	
				<xsl:element name="process_ind_ref">
				<xsl:element name="command_id">find_WebTT_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>	
			</xsl:element>
		</xsl:element>
		
<!-- get customer data to retrieve customer category-->
			<xsl:element name="CcmFifGetCustomerDataCmd">
				<xsl:element name="command_id">get_customer_data</xsl:element>
				<xsl:element name="CcmFifGetCustomerDataInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CustomerNumber']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- look for the parent's voice account -->
			<xsl:element name="CcmFifFindAccountCmd">
				<xsl:element name="command_id">find_account</xsl:element>
				<xsl:element name="CcmFifFindAccountInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CustomerNumber']"/>
					</xsl:element>
					<xsl:element name="no_account_error">Y</xsl:element>
				</xsl:element>
			</xsl:element>	

<!-- Add WebTT main Service I5678 -->
		<xsl:element name="CcmFifAddServiceSubsCmd">
			<xsl:element name="command_id">add_webTT_service</xsl:element>
			<xsl:element name="CcmFifAddServiceSubsInCont">
				<xsl:element name="product_subscription_ref">
					<xsl:element name="command_id">add_WebTT_ps</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="service_code">I5678</xsl:element>
				<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
				<xsl:element name="desired_schedule_type">ASAP</xsl:element>
			<!--	<xsl:element name="reason_rd">CREATE_WEBTT</xsl:element>  -->      
				<xsl:element name="account_number_ref">
				<xsl:element name="command_id">find_account</xsl:element>
				<xsl:element name="field_name">account_number</xsl:element>
					</xsl:element>	
						<xsl:element name="process_ind_ref">
<xsl:element name="command_id">find_WebTT_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
				<xsl:element name="service_characteristic_list"/>			
							
										
			</xsl:element>
		</xsl:element>	
<!-- Add SLA Basic Service S5017 -->
		<xsl:element name="CcmFifAddServiceSubsCmd">
			<xsl:element name="command_id">add_SLA_BASIC_service</xsl:element>
			<xsl:element name="CcmFifAddServiceSubsInCont">
				<xsl:element name="product_subscription_ref">
					<xsl:element name="command_id">add_WebTT_ps</xsl:element>
					<xsl:element name="field_name">product_subscription_id</xsl:element>
				</xsl:element>				
				<xsl:element name="service_code">S5017</xsl:element>
				<xsl:element name="parent_service_subs_ref">
					<xsl:element name="command_id">add_webTT_service</xsl:element>
					<xsl:element name="field_name">service_subscription_id</xsl:element>
				</xsl:element>
				<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
				<xsl:element name="desired_schedule_type">ASAP</xsl:element>
				<!--<xsl:element name="reason_rd">CREATE_WEBTT</xsl:element> -->       
				<xsl:element name="account_number_ref">
				<xsl:element name="command_id">find_account</xsl:element>
				<xsl:element name="field_name">account_number</xsl:element>
					</xsl:element>	
						<xsl:element name="process_ind_ref">
<xsl:element name="command_id">find_WebTT_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
					<xsl:element name="service_characteristic_list"/>
							
										
			</xsl:element>
		</xsl:element>	
<!-- Create Customer Order for new services  -->
		<xsl:element name="CcmFifCreateCustOrderCmd">
			<xsl:element name="command_id">create_WebTT_co</xsl:element>
			<xsl:element name="CcmFifCreateCustOrderInCont">
				<xsl:element name="customer_number">
					<xsl:value-of select="request-param[@name='CustomerNumber']"/>
				</xsl:element>					
				<xsl:element name="service_ticket_pos_list">					
					<xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">add_webTT_service</xsl:element>
						<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
					</xsl:element>
					<xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">add_SLA_BASIC_service</xsl:element>
						<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
					</xsl:element>
				</xsl:element>
				
<xsl:element name="process_ind_ref">				
				<xsl:element name="command_id">find_WebTT_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
<xsl:element name="processing_status">completedOPM</xsl:element>					
			</xsl:element>
			
		</xsl:element>
		
<!-- Release customer Order --> 
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">release_WebTT_co</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CustomerNumber']"/>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_WebTT_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
					<xsl:element name="command_id">find_WebTT_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>							
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>	
				</xsl:element>
			</xsl:element>
				
<!-- Create Contact for Service Addition -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CustomerNumber']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">CONTRACT</xsl:element>
					<xsl:element name="short_description">Webticketvertrag erstellt</xsl:element>
					<xsl:element name="description_text_list">
					   <xsl:element name="CcmFifPassingValueCont">
					      <xsl:element name="contact_text">
					         <xsl:text>TransactionID: </xsl:text>
						      <xsl:value-of select="request-param[@name='transactionID']"/>
                        <xsl:text>,&#xA;Webticketvertrag wurde über BUS erstellt</xsl:text>
                        <xsl:text>,&#xA;Vertragsnummer:</xsl:text>
					      </xsl:element>
					   </xsl:element>
                  <xsl:element name="CcmFifCommandRefCont">
					 	    <xsl:element name="command_id">create_WebTT_contract</xsl:element>
							 <xsl:element name="field_name">contract_number</xsl:element>
					   </xsl:element>	
					   <xsl:element name="CcmFifPassingValueCont">
					      <xsl:element name="contact_text">
   				         <xsl:text>,&#xA;onboarderFirstName:</xsl:text>
				            <xsl:value-of select="request-param[@name='OnboarderFirstName']"/>
				            <xsl:text>,&#xA;onboarderLastName:</xsl:text>
				            <xsl:value-of select="request-param[@name='OnboarderLastName']"/>		
					      </xsl:element>
					   </xsl:element>
					</xsl:element>	
				   <xsl:element name="process_ind_ref">
				      <xsl:element name="command_id">find_WebTT_service</xsl:element>
						   <xsl:element name="field_name">service_found</xsl:element>							
				   </xsl:element>
   				<xsl:element name="required_process_ind">N</xsl:element>					
				</xsl:element>	
			</xsl:element>
			
</xsl:if>

<xsl:if test="$action = 'REMOVE'  or $action = 'Cancel'">			
	<!-- Terminate Order Form -->
	  
	  <xsl:element name="CcmFifTerminateOrderFormCmd">
				<xsl:element name="command_id">terminate_WebTT_contract</xsl:element>
				<xsl:element name="CcmFifTerminateOrderFormInCont">
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">find_WebTT_service</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
					<xsl:element name="termination_date">
						<xsl:value-of select="$terminationDate"/>
					</xsl:element>
					<xsl:element name="notice_per_start_date">
						<xsl:value-of select="$noticePeriodStartDate"/>
					</xsl:element>
					<xsl:element name="override_restriction">Y</xsl:element>
					<xsl:element name="termination_reason_rd">APV</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_WebTT_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
	<!-- Terminate Product Subscription -->
			<xsl:element name="CcmFifTerminateProductSubsCmd">
				<xsl:element name="command_id">terminate_WebTT_product</xsl:element>
				<xsl:element name="CcmFifTerminateProductSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_WebTT_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">2017.06.23 00:00:00</xsl:element>
					<xsl:element name="desired_schedule_type">END_BEFORE</xsl:element>
					<xsl:element name="reason_rd">TERMINATION</xsl:element>
					<xsl:element name="auto_customer_order">N</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_WebTT_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
		<!-- Create Customer Order for terminate service  -->
		<xsl:element name="CcmFifCreateCustOrderCmd">
			<xsl:element name="command_id">create_WebTT_Term_co</xsl:element>
			<xsl:element name="CcmFifCreateCustOrderInCont">
				<xsl:element name="customer_number">
					<xsl:value-of select="request-param[@name='CustomerNumber']"/>
				</xsl:element>					
				<xsl:element name="service_ticket_pos_list">					
					<xsl:element name="CcmFifCommandRefCont">
						<xsl:element name="command_id">terminate_WebTT_product</xsl:element>
						<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
					</xsl:element>
				</xsl:element>
						
				<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_WebTT_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
					<xsl:element name="processing_status">completedOPM</xsl:element>
			</xsl:element>
			
		</xsl:element>
		
		<!-- Release Customer Order for Termination -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">release_WebTT_co</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CustomerNumber']"/>
					</xsl:element>		
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_WebTT_Term_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
					<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_WebTT_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
		
		<!-- Create Contact for Service Termination -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CustomerNumber']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">CONTRACT</xsl:element>
					<xsl:element name="short_description">Webticketvertrag beendet</xsl:element>
					<xsl:element name="description_text_list">
					   <xsl:element name="CcmFifPassingValueCont">
					      <xsl:element name="contact_text">
					         <xsl:text>TransactionID: </xsl:text>
						      <xsl:value-of select="request-param[@name='transactionID']"/>
                        <xsl:text>,&#xA;Webticketvertrag wurde über BUS beendet</xsl:text>
                        <xsl:text>,&#xA;Vertragsnummer:</xsl:text>
					      </xsl:element>
					   </xsl:element>
                  <xsl:element name="CcmFifCommandRefCont">
					 	    <xsl:element name="command_id">find_WebTT_service</xsl:element>
							 <xsl:element name="field_name">contract_number</xsl:element>
					   </xsl:element>	
					   <xsl:element name="CcmFifPassingValueCont">
					      <xsl:element name="contact_text">
   				         <xsl:text>,&#xA;onboarderFirstName:</xsl:text>
				            <xsl:value-of select="request-param[@name='OnboarderFirstName']"/>
				            <xsl:text>,&#xA;onboarderLastName:</xsl:text>
				            <xsl:value-of select="request-param[@name='OnboarderLastName']"/>		
					      </xsl:element>
					   </xsl:element>
					</xsl:element>	
				   <xsl:element name="process_ind_ref">
				      <xsl:element name="command_id">find_WebTT_service</xsl:element>
						   <xsl:element name="field_name">service_found</xsl:element>							
				   </xsl:element>
   				<xsl:element name="required_process_ind">Y</xsl:element>					
				</xsl:element>	
			</xsl:element>

   </xsl:if>	

   </xsl:element>
  </xsl:template>
</xsl:stylesheet>					
