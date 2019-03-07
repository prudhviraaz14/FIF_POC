<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--
  XSLT file for creating a FIF request for creating a full customer. It creates following:
  Entity, Address, Mailing, Account and Customer

  @author lejam
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
			<xsl:variable name="today" select="dateutils:getCurrentDate()"/>

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
			
			<xsl:if test="$supportedObjectId = ''">
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
							</xsl:choose>							
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Get contact role -->
			<xsl:if test="$supportedObjectId != ''">
				<xsl:element name="CcmFifGetContactRoleDataCmd">
					<xsl:element name="command_id">get_contact_role_data</xsl:element>
					<xsl:element name="CcmFifGetContactRoleDataInCont">
						<xsl:element name="supported_object_id">
							<xsl:value-of select="request-param[@name='supportedObjectId']"/>
						</xsl:element>
						<xsl:element name="supported_object_type_rd">
							<xsl:value-of select="request-param[@name='supportedObjectTypeRd']"/>
						</xsl:element>          
						<xsl:element name="contact_role_type_rd">
							<xsl:value-of select="request-param[@name='contactRoleTypeRd']"/>
						</xsl:element>          
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="$supportedObjectId = ''">
				<xsl:element name="CcmFifGetContactRoleDataCmd">
					<xsl:element name="command_id">get_contact_role_data</xsl:element>
					<xsl:element name="CcmFifGetContactRoleDataInCont">
						<xsl:element name="supported_object_id_ref">
							<xsl:element name="command_id">read_supported_object</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
						<xsl:element name="supported_object_type_rd">
							<xsl:value-of select="request-param[@name='supportedObjectTypeRd']"/>
						</xsl:element>          
						<xsl:element name="contact_role_type_rd">
							<xsl:value-of select="request-param[@name='contactRoleTypeRd']"/>
						</xsl:element>          
					</xsl:element>
				</xsl:element>
			</xsl:if>
			

			<!-- Change Contact Role-->
			<xsl:element name="CcmFifChangeContactRoleCmd">
				<xsl:element name="command_id">create_contact_role_1</xsl:element>
				<xsl:element name="CcmFifChangeContactRoleInCont">
					<xsl:element name="contact_role_id_ref">
						<xsl:element name="command_id">get_contact_role_data</xsl:element>
						<xsl:element name="field_name">contact_role_id</xsl:element>
					</xsl:element>
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="supported_object_id">
						<xsl:value-of select="request-param[@name='supportedObjectId']"/>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">
						<xsl:value-of select="request-param[@name='supportedObjectTypeRd']"/>						
					</xsl:element>
					<xsl:element name="contact_role_type_rd">
						<xsl:value-of select="request-param[@name='contactRoleTypeRd']"/>
					</xsl:element>
					<xsl:element name="contact_role_position_name">
						<xsl:value-of select="request-param[@name='contactRolePositionName']"/>
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
					<xsl:element name="address_type">
						<xsl:value-of select="request-param[@name='addressType']"/>
					</xsl:element>
					<xsl:element name="street_name">
						<xsl:value-of select="request-param[@name='streetName']"/>
					</xsl:element>
					<xsl:element name="street_number">
						<xsl:value-of select="request-param[@name='streetNumber']"/>
					</xsl:element>
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
					<xsl:element name="phone_number">
						<xsl:value-of select="request-param[@name='phoneNumber']"/>
					</xsl:element>
					<xsl:element name="fax_number">
						<xsl:value-of select="request-param[@name='faxNumber']"/>
					</xsl:element>
					<xsl:element name="mobile_number">
						<xsl:value-of select="request-param[@name='mobileNumber']"/>
					</xsl:element>
					<xsl:element name="email_address">
						<xsl:value-of select="request-param[@name='emailAddress']"/>
					</xsl:element>
					<xsl:element name="access_information_type_rd">
						<xsl:value-of select="request-param[@name='accessInformationTypeRd']"/>
						<xsl:value-of select="request-param[@name='accessInformationTyp']"/>							
					</xsl:element>
					<xsl:element name="electronic_contact_indicator">
						<xsl:value-of select="request-param[@name='electronicContactIndicator']"/>
					</xsl:element>
					<xsl:element name="contact_name">
						<xsl:choose>
							<xsl:when test="request-param[@name='contactName'] != ''">
								<xsl:value-of select="request-param[@name='contactName']"/>		
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="varSpace">
									<xsl:if test="(request-param[@name='forename'] != '' and request-param[@name='name'] != '')">
										<xsl:text> </xsl:text>
									</xsl:if>										
								</xsl:variable>
									<xsl:if test="(request-param[@name='forename'] != '' and request-param[@name='name'] != '')
									or (request-param[@name='forename'] != '' and request-param[@name='name'] = '')
									or (request-param[@name='forename'] = '' and request-param[@name='name'] != '')">
										<xsl:value-of select="concat(request-param[@name='forename'],$varSpace,request-param[@name='name'])"/>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>							
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
			
