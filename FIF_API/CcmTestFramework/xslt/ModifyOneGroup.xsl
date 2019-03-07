<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for modifying a OneGroup object
	
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
		
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>	
		
		<xsl:element name="Command_List">
			
			<!-- Get Customer Number if not provided -->
			<xsl:if test="request-param[@name='customerNumber'] = ''">
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_customer_number</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
						<xsl:element name="ignore_empty_result">Y</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Get Customer Number if not provided -->
			<xsl:if test="request-param[@name='skeletonContractNumber'] = '' 
				and request-param[@name='skeletonContractID'] != ''">
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_skeleton_contract_number</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="parameter_name">
							<xsl:value-of select="request-param[@name='skeletonContractID']"/>
							<xsl:text>_SKELETON_CONTRACT_NUMBER</xsl:text>							
						</xsl:element>
						<xsl:element name="ignore_empty_result">Y</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Modify OneGroup -->
			<xsl:element name="CcmFifModifyOneGroupCmd">
				<xsl:element name="command_id">modify_one_group</xsl:element>
				<xsl:element name="CcmFifModifyOneGroupInCont">
					<xsl:element name="one_group_id">
						<xsl:value-of select="request-param[@name='oneGroupID']"/>
					</xsl:element>
					<xsl:if test="request-param[@name='customerNumber'] != ''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>		
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber'] = ''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_customer_number</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>		
					</xsl:if>
					<xsl:element name="status_rd">
						<xsl:value-of select="request-param[@name='status']"/>
					</xsl:element>										
					<xsl:element name="name">
						<xsl:value-of select="request-param[@name='name']"/>
					</xsl:element>		
					<xsl:if test="request-param[@name='skeletonContractNumber'] != ''">
						<xsl:element name="on_skc_number">
							<xsl:value-of select="request-param[@name='skeletonContractNumber']"/>
						</xsl:element>		
					</xsl:if>
					<xsl:if test="request-param[@name='skeletonContractNumber'] = ''">
						<xsl:element name="on_skc_number_ref">
							<xsl:element name="command_id">read_skeleton_contract_number</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>		
					</xsl:if>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<xsl:element name="command_id">create_notification_1</xsl:element>
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
								<xsl:value-of select="request-param[@name='somElementID']"/>								
								<xsl:text>_ONE_GROUP</xsl:text>
							</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='oneGroupID']"/>
							</xsl:element>
						</xsl:element>	
					</xsl:element>          
				</xsl:element>
			</xsl:element>  			
			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
