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
			<xsl:variable name="supportedObjectId">
				<xsl:if test="request-param[@name='supportedObjectTypeRd'] = 'CUSTOMER' and 
					request-param[@name='customerNumber'] != ''">
					<xsl:value-of select="request-param[@name='customerNumber']"/>
				</xsl:if>
				<xsl:if test="request-param[@name='supportedObjectTypeRd'] = 'CUSTOMER' and 
					request-param[@name='customerNumber'] = ''">
					<xsl:value-of select="request-param[@name='supportedObjectId']"/>
				</xsl:if>
				<xsl:if test="request-param[@name='supportedObjectTypeRd'] != 'CUSTOMER'">
					<xsl:value-of select="request-param[@name='supportedObjectId']"/>
				</xsl:if>				
			</xsl:variable>			

			<!--Get Customer Number if not provided-->
			<xsl:if test="request-param[@name='customerNumber'] = ''
				and request-param[@name='requestListId'] != ''">
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

			<!-- Get contact role entity -->
			<xsl:if test="request-param[@name='contactRoleEntityIdReference'] != ''
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
						<xsl:element name="ignore_empty_result">Y</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>			
						
			<!-- Validate address details -->		
			<xsl:if test="request-param[@name='contactRoleEntityId'] = ''
				and request-param[@name='createAddress'] = 'Y'
				and (request-param[@name='streetName'] = '' and request-param[@name='postOfficeBox'] = ''
				or request-param[@name='streetNumber'] = '' and request-param[@name='postOfficeBox'] = ''
				or request-param[@name='postalCode'] = '' 
				or request-param[@name='cityName'] = '' )">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">address_field_error</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">All address details must be provided.</xsl:element>
						<xsl:if test="request-param[@name='contactRoleEntityIdReference'] != ''">
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">read_contact_role_entity</xsl:element>
								<xsl:element name="field_name">value_found</xsl:element>
							</xsl:element>
							<xsl:element name="required_process_ind">N</xsl:element>						
						</xsl:if>						
					</xsl:element>
				</xsl:element>
			</xsl:if>		
			
			<xsl:if test="$supportedObjectId = '' and request-param[@name='supportedObjectTypeRd'] != ''">
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
			
			<!-- Create Entity-->
			<xsl:if test="request-param[@name='contactRoleEntityId'] = '' and request-param[@name='name'] != ''">
				<xsl:element name="CcmFifCreateEntityCmd">
					<xsl:element name="command_id">create_entity_1</xsl:element>
					<xsl:element name="CcmFifCreateEntityInCont">
						<xsl:element name="entity_type">
							<xsl:choose>
								<xsl:when test="request-param[@name='organizationType'] != ''">O</xsl:when>
								<xsl:otherwise>I</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="salutation_description">
							<xsl:value-of select="request-param[@name='salutationDescription']"/>
						</xsl:element>
						<xsl:element name="title_description">
							<xsl:value-of select="request-param[@name='titleDescription']"/>
						</xsl:element>
						<xsl:element name="nobility_prefix_description">
							<xsl:value-of select="request-param[@name='nobilityPrefixDescription']"/>
						</xsl:element>					
						<xsl:element name="forename">
							<xsl:value-of select="request-param[@name='forename']"/>
						</xsl:element>
						<xsl:element name="surname_prefix_description">
							<xsl:value-of select="request-param[@name='surnamePrefix']"/>
						</xsl:element>
						<xsl:element name="name">
							<xsl:value-of select="request-param[@name='name']"/>
						</xsl:element>
						<xsl:element name="birth_date">
							<xsl:value-of select="request-param[@name='birthDate']"/>
						</xsl:element>
						<xsl:element name="organization_type_rd">
							<xsl:value-of select="request-param[@name='organizationType']"/>
						</xsl:element>	
						<xsl:element name="organization_suffix_name">
							<xsl:value-of select="request-param[@name='organizationSuffixName']"/>
						</xsl:element>
						<xsl:element name="incorporation_number_id">
							<xsl:value-of select="request-param[@name='incorporationNumber']"/>
						</xsl:element>	
						<xsl:element name="incorporation_type_rd">
							<xsl:value-of select="request-param[@name='incorporationType']"/>
						</xsl:element>	
						<xsl:element name="incorporation_city_name">
							<xsl:value-of select="request-param[@name='incorporationCityName']"/>
						</xsl:element>		
						<xsl:if test="request-param[@name='contactRoleEntityIdReference'] != ''">
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">read_contact_role_entity</xsl:element>
								<xsl:element name="field_name">value_found</xsl:element>
							</xsl:element>
							<xsl:element name="required_process_ind">N</xsl:element>						
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Create Access Information -->
			<xsl:if test="request-param[@name='contactRoleEntityId'] = '' and request-param[@name='createAccessInformation'] = 'Y'">
				<xsl:element name="CcmFifUpdateAccessInformCmd">
					<xsl:element name="command_id">create_access_information_1</xsl:element>
					<xsl:element name="CcmFifUpdateAccessInformInCont">
						<xsl:element name="entity_ref">
							<xsl:element name="command_id">create_entity_1</xsl:element>
							<xsl:element name="field_name">entity_id</xsl:element>
						</xsl:element>
						<xsl:element name="access_information_type_rd">
							<xsl:value-of select="request-param[@name='accessInformationTypeRd']"/>
							<xsl:value-of select="request-param[@name='accessInformationTyp']"/>							
						</xsl:element>
						<xsl:element name="contact_name">
							<xsl:choose>
								<xsl:when test="request-param[@name='contactName'] != ''">
									<xsl:value-of select="request-param[@name='contactName']"/>		
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat(request-param[@name='forename'],' ',request-param[@name='name'])"/>		
								</xsl:otherwise>
							</xsl:choose>							
						</xsl:element>
						<xsl:element name="phone_number">
							<xsl:value-of select="request-param[@name='phoneNumber']"/>
						</xsl:element>
						<xsl:element name="mobile_number">
							<xsl:choose>
								<xsl:when test="starts-with(request-param[@name='mobileNumber'], '0049')">
									<xsl:text>0</xsl:text>
									<xsl:value-of select="substring-after(request-param[@name='mobileNumber'], '0049')"/>
								</xsl:when>
								<xsl:when test="starts-with(request-param[@name='mobileNumber'], '+49')">
									<xsl:text>0</xsl:text>
									<xsl:value-of select="substring-after(request-param[@name='mobileNumber'], '+49')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="request-param[@name='mobileNumber']"/>
								</xsl:otherwise>
							</xsl:choose>							
						</xsl:element>
						<xsl:element name="fax_number">
							<xsl:value-of select="request-param[@name='faxNumber']"/>
						</xsl:element>
						<xsl:element name="email_address">
							<xsl:value-of select="request-param[@name='emailAddress']"/>
						</xsl:element>
						<xsl:element name="electronic_contact_indicator">
							<xsl:value-of select="request-param[@name='electronicContactIndicator']"/>
						</xsl:element>
						<xsl:if test="request-param[@name='contactRoleEntityIdReference'] != ''">
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">read_contact_role_entity</xsl:element>
								<xsl:element name="field_name">value_found</xsl:element>
							</xsl:element>
							<xsl:element name="required_process_ind">N</xsl:element>						
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Create Address-->
			<xsl:if test="request-param[@name='contactRoleEntityId'] = '' and request-param[@name='createAddress'] = 'Y'">
				<xsl:element name="CcmFifCreateAddressCmd">
					<xsl:element name="command_id">create_address_1</xsl:element>
					<xsl:element name="CcmFifCreateAddressInCont">
						<xsl:element name="entity_ref">
							<xsl:element name="command_id">create_entity_1</xsl:element>
							<xsl:element name="field_name">entity_id</xsl:element>
						</xsl:element>
						<xsl:element name="address_type">
							<xsl:value-of select="request-param[@name='addressType']"/>
						</xsl:element>
						<xsl:choose>
							<xsl:when test="request-param[@name='streetName'] != ''">
								<xsl:element name="street_name">
									<xsl:value-of select="request-param[@name='streetName']"/>
								</xsl:element>
								<xsl:element name="street_number">
									<xsl:value-of select="request-param[@name='streetNumber']"/>
								</xsl:element>							
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="post_office_box">
									<xsl:value-of select="request-param[@name='postOfficeBox']"/>
								</xsl:element>														
							</xsl:otherwise>
						</xsl:choose>
						<xsl:element name="street_number_suffix">
							<xsl:value-of select="request-param[@name='streetNumberSuffix']"/>
							<xsl:value-of select="request-param[@name='numberSuffix']"/>							
						</xsl:element>
						<xsl:element name="postal_code">
							<xsl:value-of select="request-param[@name='postalCode']"/>
						</xsl:element>
						<xsl:element name="city_name">
							<xsl:value-of select="request-param[@name='cityName']"/>
						</xsl:element>
						<xsl:element name="city_suffix_name">
							<xsl:value-of select="request-param[@name='citySuffixName']"/>
							<xsl:value-of select="request-param[@name='citySuffix']"/>
						</xsl:element>
						<xsl:element name="country_code">
							<xsl:value-of select="request-param[@name='countryCode']"/>
						</xsl:element>
						<xsl:element name="set_primary_address">Y</xsl:element>
						<xsl:if test="request-param[@name='contactRoleEntityIdReference'] != ''">
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">read_contact_role_entity</xsl:element>
								<xsl:element name="field_name">value_found</xsl:element>
							</xsl:element>
							<xsl:element name="required_process_ind">N</xsl:element>						
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="request-param[@name='name'] != ''">				
				<!-- Create Contact Role-->
				<xsl:element name="CcmFifCreateContactRoleCmd">
					<xsl:element name="command_id">create_contact_role_1</xsl:element>
					<xsl:element name="CcmFifCreateContactRoleInCont">
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
						<xsl:if test="request-param[@name='contactRoleEntityId'] = ''">
							<xsl:element name="entity_id_ref">
								<xsl:element name="command_id">create_entity_1</xsl:element>
								<xsl:element name="field_name">entity_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:element name="supported_object_id"/>
						<xsl:if test="request-param[@name='contactRoleEntityId'] = ''">
							<xsl:if test="request-param[@name='createAddress'] = 'Y'">
								<xsl:element name="address_id_ref">
									<xsl:element name="command_id">create_address_1</xsl:element>
									<xsl:element name="field_name">address_id</xsl:element>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='createAddress'] != 'Y'">
								<xsl:element name="address_id">
									<xsl:value-of select="request-param[@name='addressId']"/>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='createAccessInformation'] = 'Y'">
								<xsl:element name="access_information_ref">
									<xsl:element name="command_id">create_access_information_1</xsl:element>
									<xsl:element name="field_name">access_information_id</xsl:element>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='createAccessInformation'] != 'Y'">
								<xsl:element name="access_information_id">
									<xsl:value-of select="request-param[@name='accessInformationId']"/>
								</xsl:element>
							</xsl:if>
						</xsl:if>
						<xsl:element name="supported_object_type_rd"/>
						<xsl:element name="contact_role_type_rd">
							<xsl:value-of select="request-param[@name='contactRoleTypeRd']"/>
						</xsl:element>
						<xsl:element name="contact_role_position_name">
							<xsl:value-of select="request-param[@name='contactRolePositionName']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>

			<xsl:if test="request-param[@name='supportedObjectTypeRd'] != ''">
				<xsl:element name="CcmFifCreateContactRoleCmd">
					<xsl:element name="command_id">create_contact_role_link</xsl:element>
					<xsl:element name="CcmFifCreateContactRoleInCont">
						<xsl:element name="customer_number"/>
						<!--
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
						-->
						<xsl:choose>
							<xsl:when test="request-param[@name='contactRoleEntityId'] != ''">
								<xsl:element name="contact_role_entity_id">
									<xsl:value-of select="request-param[@name='contactRoleEntityId']"/>
								</xsl:element>
							</xsl:when>
							<xsl:when test="request-param[@name='name'] != ''">
								<xsl:element name="contact_role_entity_id_ref">
									<xsl:element name="command_id">create_contact_role_1</xsl:element>
									<xsl:element name="field_name">contact_role_entity_id</xsl:element>
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
						<xsl:element name="contact_role_type_rd"/>
					</xsl:element>
				</xsl:element>	
			</xsl:if>		
			
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
			
			<xsl:if test="request-param[@name='contactRoleEntityIdReference'] != ''">
				<xsl:element name="CcmFifCreateExternalNotificationCmd">
					<xsl:element name="command_id">create_standalone_co_notification</xsl:element>
					<xsl:element name="CcmFifCreateExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="notification_action_name">
							<xsl:value-of select="//request/action-name"/>
						</xsl:element>
						<xsl:element name="target_system">FIF</xsl:element>
						<xsl:element name="parameter_value_list">
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">
									<xsl:value-of select="request-param[@name='contactRoleEntityIdReference']"/>
									<xsl:text>_CONTACT_ROLE_ENTITY</xsl:text>
								</xsl:element>
								<xsl:element name="parameter_value_ref">
									<xsl:element name="command_id">create_contact_role_1</xsl:element>
									<xsl:element name="field_name">contact_role_entity_id</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">read_contact_role_entity</xsl:element>
							<xsl:element name="field_name">value_found</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">N</xsl:element>							
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			
			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
			
