<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for terminating a Hansanet product subscription
	
	@author banania
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
	exclude-result-prefixes="dateutils">
	
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
		<xsl:element name="client_name">OPM</xsl:element>
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
		</xsl:element>		
		<xsl:element name="Command_List">
			
			<xsl:variable name="today"
				select="dateutils:getCurrentDate()"/>
			
			<xsl:variable name="DesiredDate">  
				<xsl:choose>
					<xsl:when test ="request-param[@name='DESIRED_DATE'] = $today">
						<xsl:value-of select="$today"/>
					</xsl:when>
					<xsl:when test ="request-param[@name='DESIRED_DATE'] = ''">
						<xsl:value-of select="$today"/>
					</xsl:when>					
					<xsl:when test ="request-param[@name='DESIRED_DATE'] &lt; $today">
						<xsl:value-of select="$today"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
					</xsl:otherwise>
				</xsl:choose>                      
			</xsl:variable>

			<!-- Find Service Subscription by SERVICE_SUBSCRIPTION or TECH_SERVICE_ID -->  
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_service_1</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:if test="request-param[@name='TECH_SERVICE_ID'] != '' and
						request-param[@name='SERVICE_SUBSCRIPTION_ID'] = ''">  
						<xsl:element name="access_number">
							<xsl:value-of select="request-param[@name='TECH_SERVICE_ID']"/>
						</xsl:element>
						<xsl:element name="access_number_type">TECH_SERVICE_ID</xsl:element>              
					</xsl:if>
					<xsl:if test="request-param[@name='SERVICE_SUBSCRIPTION_ID'] != ''">
						<xsl:element name="service_subscription_id">
							<xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:element>  

			<!-- Lock product commitment  -->
			<xsl:element name="CcmFifLockObjectCmd">
				<xsl:element name="CcmFifLockObjectInCont">    
					<xsl:element name="object_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">product_commitment_number</xsl:element>
					</xsl:element> 
					<xsl:element name="object_type">SDC_PROD_COMM</xsl:element>
				</xsl:element>
			</xsl:element>
			  
			<!-- Ensure that the termination has not been performed before -->
			<xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
				<xsl:element name="command_id">cancel_stp_1</xsl:element>
				<xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="reason_rd">TERMINATION</xsl:element> 
				</xsl:element>
			</xsl:element>

			<!-- Terminate the online Product Subscription -->
			<xsl:element name="CcmFifTerminateProductSubsCmd">
				<xsl:element name="command_id">terminate_ps_1</xsl:element>
				<xsl:element name="CcmFifTerminateProductSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:if test="$DesiredDate = $today">											
						<xsl:element name="desired_date">
							<xsl:value-of select="$DesiredDate"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					</xsl:if>	
					<xsl:if test="$DesiredDate != $today">											
						<xsl:element name="desired_date">
							<xsl:value-of select="$DesiredDate"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
					</xsl:if>
					<xsl:element name="reason_rd">TERMINATION</xsl:element> 
					<xsl:element name="auto_customer_order">N</xsl:element>
				</xsl:element>
			</xsl:element>
	
			<!-- Create Customer Order for Termination of the hansanet product -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">002</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_ps_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
					</xsl:element>				
				</xsl:element>
			</xsl:element>

			<!-- Release Customer Order for Termination of the PS-->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_1</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>          
				</xsl:element>
			</xsl:element>  					


		</xsl:element>
	</xsl:template>
</xsl:stylesheet>

