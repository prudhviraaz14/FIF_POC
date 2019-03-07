<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--
  XSLT file for creating a FIF request for creating a full customer. It creates following:
  Entity, Address, Mailing, Account and Customer

  @author banania
-->
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
			
			<!-- Get contact role entity -->
			<xsl:if test="request-param[@name='contactRoleEntityIdReference'] != ''
				and request-param[@name='contactRoleEntityId'] = ''
				and request-param[@name='requestListId'] != ''">
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_contact_role_entity</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="parameter_name">
							<xsl:value-of select="request-param[@name='contactRoleEntityIdReference']"/>
							<xsl:text>_CONTACT_ROLE_ENTITY</xsl:text>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>			
						
			<xsl:if test="request-param[@name='supportedObjectId'] = ''">
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_supported_object</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="parameter_name">
							<xsl:choose>
								<xsl:when test="request-param[@name='supportedObjectTypeRd'] = 'CUSTOMER'">CUSTOMER_NUMBER</xsl:when>
								<xsl:when test="request-param[@name='supportedObjectTypeRd'] = 'SERVICE_SUBS'">
									<xsl:value-of select="request-param[@name='parentSomElementID']"/>
									<xsl:value-of select="request-param[@name='type']"/>
									<xsl:text>_SERVICE_SUBSCRIPTION_ID</xsl:text>
								</xsl:when>
								<xsl:when test="request-param[@name='supportedObjectTypeRd'] = 'SERVDLVRY'">
									<xsl:value-of select="request-param[@name='parentSomElementID']"/>
									<xsl:text>_SERVICE_DELIVERY_CONTRACT_NUMBER</xsl:text>
								</xsl:when>
								<xsl:when test="request-param[@name='supportedObjectTypeRd'] = 'SKELCNTR'">
									<xsl:value-of select="request-param[@name='parentSomElementID']"/>
									<xsl:text>_SKELETON_CONTRACT_NUMBER</xsl:text>
								</xsl:when>
								<xsl:when test="request-param[@name='supportedObjectTypeRd'] = 'ONE_GROUP'">
									<xsl:value-of select="request-param[@name='parentSomElementID']"/>
									<xsl:text>_ONE_GROUP</xsl:text>
								</xsl:when>
							</xsl:choose>							
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Create Contact Role-->
			<xsl:element name="CcmFifCreateContactRoleCmd">
				<xsl:element name="command_id">create_contact_role_1</xsl:element>
				<xsl:element name="CcmFifCreateContactRoleInCont">
					<xsl:element name="customer_number"/>
					<xsl:choose>
						<xsl:when test="request-param[@name='contactRoleEntityId'] != ''">
							<xsl:element name="contact_role_entity_id">
								<xsl:value-of select="request-param[@name='contactRoleEntityId']"/>
							</xsl:element>
						</xsl:when>
						<xsl:otherwise>							
							<xsl:element name="contact_role_entity_id_ref">
								<xsl:element name="command_id">read_contact_role_entity</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="request-param[@name='supportedObjectId'] != ''">
							<xsl:element name="supported_object_id">
								<xsl:value-of select="request-param[@name='supportedObjectId']"/>
							</xsl:element>							
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="supported_object_id_ref">
								<xsl:element name="command_id">read_supported_object</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:element name="supported_object_type_rd">
						<xsl:value-of select="request-param[@name='supportedObjectTypeRd']"/>						
					</xsl:element>
					<xsl:element name="contact_role_type_rd">
						<xsl:value-of select="request-param[@name='contactRoleTypeRd']"/>						
					</xsl:element>
					<xsl:element name="clone_legacy_contact_role">
						<xsl:value-of select="request-param[@name='cloneLegacyContactRole']"/>						
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
				<xsl:element name="CcmFifConcatStringsCmd">
					<xsl:element name="command_id">relatedSomElementID</xsl:element>
					<xsl:element name="CcmFifConcatStringsInCont">
						<xsl:element name="input_string_list">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">
									<xsl:value-of select="request-param[@name='parentSomElementID']"/>
								</xsl:element>							
							</xsl:element>                
						</xsl:element>
					</xsl:element>
				</xsl:element>              
			</xsl:if>
			
			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
			
