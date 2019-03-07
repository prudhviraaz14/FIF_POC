<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for creating a FIF request for creating a full CUSTOMER. It creates following:
	Entity, Address, Mailing, Account and Customer
	
	@author wlazlow
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
		<!-- Copy over transaction ID,action name & override_system_date -->
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
						
			<!-- TODO Fehlermeldung fuer newServiceProvider -->
			
						
						
			<!-- ContactRole? (no, only mass market) -->
			<xsl:variable name="customerClassification">
				<xsl:choose>
					<xsl:when test="request-param[@name='newServiceProvider'] = 'VODAFONE'">
						<xsl:if test="request-param[@name='customerCategory'] = 'RESIDENTIAL'">VE</xsl:if>
						<xsl:if test="request-param[@name='customerCategory'] = 'BUSINESS'">VC</xsl:if>
					</xsl:when>
				</xsl:choose>				
			</xsl:variable>
			
			<xsl:variable name="customerGroup">
				<xsl:choose>
					<xsl:when test="request-param[@name='newServiceProvider'] = 'VODAFONE'">
						<xsl:if test="request-param[@name='customerCategory'] = 'RESIDENTIAL'">81</xsl:if>
						<xsl:if test="request-param[@name='customerCategory'] = 'BUSINESS'">81</xsl:if>
					</xsl:when>
				</xsl:choose>				
			</xsl:variable>
			
			<xsl:variable name="affinityGroup">
				<xsl:choose>
					<xsl:when test="request-param[@name='newServiceProvider'] = 'VODAFONE'">VODAFONE_RESALE</xsl:when>
				</xsl:choose>				
			</xsl:variable>
			
			<xsl:variable name="invoiceTemplateName">
				<xsl:choose>
					<xsl:when test="request-param[@name='newServiceProvider'] = 'VODAFONE'">
						<xsl:if test="request-param[@name='customerCategory'] = 'RESIDENTIAL'">Vodafone PK-Rechnung</xsl:if>
						<xsl:if test="request-param[@name='customerCategory'] = 'BUSINESS'">VF Rechnung</xsl:if>
					</xsl:when>
				</xsl:choose>				
			</xsl:variable>
			
			<xsl:element name="CcmFifCloneCustomerCmd">
				<xsl:element name="command_id">clone_customer</xsl:element>
				<xsl:element name="CcmFifCloneCustomerInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='sourceCustomerNumber']"/>
					</xsl:element>
					<xsl:element name="target_customer_number">
						<xsl:value-of select="request-param[@name='targetCustomerNumber']"/>
					</xsl:element>
					<xsl:element name="classification_rd">
						<xsl:value-of select="$customerClassification"/>
					</xsl:element>
					<xsl:element name="customer_group_rd">
						<xsl:value-of select="$customerGroup"/>
					</xsl:element>
					<xsl:element name="invoice_template_name">
						<xsl:value-of select="$invoiceTemplateName"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="CcmFifChangeCustomerCmd">
				<xsl:element name="command_id">change_customer</xsl:element>
				<xsl:element name="CcmFifChangeCustomerInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">clone_customer</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>						
					</xsl:element>		
					<xsl:element name="customer_internal_ref_number">**NULL**</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="CcmFifAddAffinityGroupCmd">
				<xsl:element name="command_id">add_affinity_group</xsl:element>
				<xsl:element name="CcmFifAddAffinityGroupInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">clone_customer</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="affinity_group_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">
								<xsl:value-of select="$affinityGroup"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- clone location address -->
			
			<!-- write new customer number to ExtNot -->
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<xsl:element name="command_id">create_ext_notification</xsl:element>
				<xsl:element name="CcmFifCreateExternalNotificationInCont">
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="notification_action_name">cloneCustomer</xsl:element>
					<xsl:element name="target_system">FIF</xsl:element>
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">clone_customer</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">clone_customer</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">ADDRESS_ID</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">clone_customer</xsl:element>
								<xsl:element name="field_name">address_id</xsl:element>
							</xsl:element>
						</xsl:element>							
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
