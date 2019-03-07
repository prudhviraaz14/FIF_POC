<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a service delivery contract

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
		<!-- Convert the desired date to OPM format -->
		<xsl:variable name="desiredDateOPM"
			select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>

		<!-- Calculate today and one day before the desired date -->
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
		<xsl:element name="Command_List">
			
			<!-- Get Customer number if not provided-->
			<xsl:if test="request-param[@name='customerNumber'] = ''">
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_customer_number</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Get Customer number if not provided-->
			<xsl:if test="request-param[@name='assocSkeletonContNum'] = ''
				and request-param[@name='useSkeletonContract'] = 'Y'">
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_skeleton_contract</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="parameter_name">
							<xsl:value-of select="request-param[@name='parentSomElementID']"/>
							<xsl:text>_SKELETON_CONTRACT_NUMBER</xsl:text>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<xsl:element name="CcmFifCreateServiceDelivContCmd">
				<xsl:element name="command_id">create_sdc</xsl:element>
				<xsl:element name="CcmFifCreateServiceDelivContInCont">
					<xsl:if test="request-param[@name='customerNumber'] = ''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_customer_number</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber'] != ''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="language_rd">
						<xsl:value-of select="request-param[@name='languageRd']"/>
					</xsl:element>
					<xsl:element name="loi_indicator">
						<xsl:value-of select="request-param[@name='loiIndicator']"/>
					</xsl:element>											
					<xsl:element name="doc_template_name">Vertrag</xsl:element>		
					<xsl:if test="request-param[@name='useSkeletonContract'] = 'Y'">			
						<xsl:if test="request-param[@name='assocSkeletonContNum'] != ''">
							<xsl:element name="assoc_skeleton_cont_num">
								<xsl:value-of select="request-param[@name='assocSkeletonContNum']"/>
							</xsl:element>						
						</xsl:if>
						<xsl:if test="request-param[@name='assocSkeletonContNum'] = ''">
							<xsl:element name="assoc_skeleton_cont_num_ref">
								<xsl:element name="command_id">read_skeleton_contract</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>							
							</xsl:element>												
						</xsl:if>						
					</xsl:if>
					<xsl:element name="name">
						<xsl:value-of select="request-param[@name='name']"/>
					</xsl:element>
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
								<xsl:text>_SERVICE_DELIVERY_CONTRACT_NUMBER</xsl:text>
							</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">create_sdc</xsl:element>
								<xsl:element name="field_name">contract_number</xsl:element>
							</xsl:element>
						</xsl:element>	
					</xsl:element>          
				</xsl:element>
			</xsl:element>  
			
			<xsl:if test="request-param[@name='somElementID'] != ''">
				<xsl:element name="CcmFifConcatStringsCmd">
					<xsl:element name="command_id">somElementID</xsl:element>
					<xsl:element name="CcmFifConcatStringsInCont">
						<xsl:element name="input_string_list">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">
									<xsl:value-of select="request-param[@name='somElementID']"/>
								</xsl:element>							
							</xsl:element>                
						</xsl:element>
					</xsl:element>
				</xsl:element>              
			</xsl:if>
			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
