<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for Modifying mailings, document recipients and / or document patterns

  @author Naveen
-->
<!DOCTYPE XSL [

<!ENTITY GenericDocumentPattern SYSTEM "GenericDocumentPattern.xsl">
]>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" exclude-result-prefixes="dateutils" version="1.0">
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
		<xsl:element name="Command_List">
			<xsl:variable name="today" select="dateutils:getCurrentDate(false)"/>
			<xsl:variable name="desiredDate">
				<xsl:choose>
					<xsl:when test="request-param[@name='desiredDate'] = '' or dateutils:compareString(request-param[@name='desiredDate'], $today) = '-1' or dateutils:compareString(request-param[@name='desiredDate'], $today) = '0'">
						<xsl:value-of select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="customer_Number">
				<xsl:value-of select="request-param[@name='customerNumber']"/>
			</xsl:variable>
			<!-- Finds mailing information based on MailingName and CustomerNumber -->
			<xsl:element name="CcmFifGetMailingDataCmd">
				<xsl:element name="command_id">Find_mailing_1</xsl:element>
				<xsl:element name="CcmFifGetMailingDataInCont">
					<xsl:element name="mailing_name">
						<xsl:value-of select="request-param[@name='mailingName']"/>
					</xsl:element>
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- validate the presence of mailing_id -->
			<xsl:element name ="CcmFifValidateValueCmd">
				<xsl:element name ="command_id">validate_mailing_id_1</xsl:element>
				<xsl:element name = "CcmFifValidateValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">Find_mailing_1</xsl:element>
						<xsl:element name="field_name">mailing_id</xsl:element>
					</xsl:element>
					<xsl:element name="object_type">mailing_id</xsl:element>
					<xsl:element name="value_type">mailing_id_type</xsl:element>
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value"></xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="ignore_failure_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Creates entity,Address and accessInformation if createDeviatingDocumentRecipient is set to Y -->
			<xsl:if test="request-param[@name='createDeviatingDocumentRecipient'] = 'Y'">
				<!-- Create Entity -->
				<xsl:element name="CcmFifCreateEntityCmd">
					<xsl:element name="command_id">create_entity_1</xsl:element>
					<xsl:element name="CcmFifCreateEntityInCont">
						<xsl:element name="entity_type">
							<xsl:value-of select="request-param[@name='entityType']"/>
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
							<xsl:value-of select="request-param[@name='surnamePrefixDescription']"/>
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
						<xsl:element name="effective_date">
							<xsl:value-of select="$desiredDate"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				<xsl:element name="CcmFifCreateAddressCmd">
					<xsl:element name="command_id">create_address_1</xsl:element>
					<xsl:element name="CcmFifCreateAddressInCont">
						<xsl:element name="entity_ref">
							<xsl:element name="command_id">create_entity_1</xsl:element>
							<xsl:element name="field_name">entity_id</xsl:element>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="$desiredDate"/>
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
							<xsl:value-of select="request-param[@name='numberSuffix']"/>
						</xsl:element>
						<xsl:element name="postal_code">
							<xsl:value-of select="request-param[@name='postalCode']"/>
						</xsl:element>
						<xsl:element name="city_name">
							<xsl:value-of select="request-param[@name='cityName']"/>
						</xsl:element>
						<xsl:element name="city_suffix_name">
							<xsl:value-of select="request-param[@name='citySuffix']"/>
						</xsl:element>
						<xsl:element name="country_code">
							<xsl:value-of select="request-param[@name='countryCode']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				<xsl:element name="CcmFifUpdateAccessInformCmd">
					<xsl:element name="command_id">create_access_information_1</xsl:element>
					<xsl:element name="CcmFifUpdateAccessInformInCont">
						<xsl:element name="entity_ref">
							<xsl:element name="command_id">create_entity_1</xsl:element>
							<xsl:element name="field_name">entity_id</xsl:element>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="$desiredDate"/>
						</xsl:element>
						<xsl:element name="access_information_type_rd">
							<xsl:value-of select="request-param[@name='accessInformationTyp']"/>
						</xsl:element>
						<xsl:element name="contact_name">
							<xsl:value-of select="request-param[@name='name']"/>
						</xsl:element>
						<xsl:element name="phone_number">
							<xsl:value-of select="request-param[@name='phoneNumber']"/>
						</xsl:element>
						<xsl:element name="mobile_number">
							<xsl:value-of select="request-param[@name='mobileNumber']"/>
						</xsl:element>
						<xsl:element name="fax_number">
							<xsl:value-of select="request-param[@name='faxNumber']"/>
						</xsl:element>
						<xsl:element name="email_address">
							<xsl:value-of select="request-param[@name='emailAddress']"/>
						</xsl:element>
						<xsl:element name="email_validation_indicator">
							<xsl:value-of select="request-param[@name='emailValidationIndicator']"/>
						</xsl:element>
						<xsl:element name="electronic_contact_indicator">
							<xsl:value-of select="request-param[@name='electronicContactIndicator']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				<!-- modifies mailing with new entity, address and access info if 
				     createDeviatingDocumentRecipient is set to Y   -->
				<xsl:element name="CcmFifModifyMailingCmd">
					<xsl:element name="command_id">modify_mailing_information_1</xsl:element>
					<xsl:element name="CcmFifModifyMailingInCont">
						<xsl:element name="mailing_id_ref">
							<xsl:element name="command_id">Find_mailing_1</xsl:element>
							<xsl:element name="field_name">mailing_id</xsl:element>
						</xsl:element>
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="$desiredDate"/>
						</xsl:element>
						<xsl:element name="document_type_rd">
							<xsl:value-of select="request-param[@name='documentType']"/>
						</xsl:element>
						<xsl:element name="name">
							<xsl:value-of select="request-param[@name='mailingName']"/>
						</xsl:element>
						<xsl:element name="table_of_contents_indicator">
							<xsl:value-of select="request-param[@name='tableOfContentsIndicator']"/>
						</xsl:element>
						<xsl:element name="marketing_information_ind">
							<xsl:value-of select="request-param[@name='marketingInformationIndicator']"/>
						</xsl:element>
						<xsl:element name="printer_destination_rd">
							<xsl:value-of select="request-param[@name='printerDestination']"/>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">validate_mailing_id_1</xsl:element>
							<xsl:element name="field_name">success_ind</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">N</xsl:element>
					</xsl:element>
				</xsl:element>
				<!-- creates mailing with new entity, address and access info if 
				     createDeviatingDocumentRecipient is set to Y and no mailing present   -->
				<xsl:element name="CcmFifCreateMailingCmd">
					<xsl:element name="command_id">create_mailing_information</xsl:element>
					<xsl:element name="CcmFifCreateMailingInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="mailing_id_ref">
							<xsl:element name="command_id">Find_mailing_1</xsl:element>
							<xsl:element name="field_name">mailing_id</xsl:element>
						</xsl:element>
						<xsl:element name="address_ref">
							<xsl:element name="command_id">create_address_1</xsl:element>
							<xsl:element name="field_name">address_id</xsl:element>
						</xsl:element>
						<xsl:element name="entity_ref">
							<xsl:element name="command_id">create_entity_1</xsl:element>
							<xsl:element name="field_name">entity_id</xsl:element>
						</xsl:element>
						<xsl:element name="access_information_ref">
							<xsl:element name="command_id">create_access_information</xsl:element>
							<xsl:element name="field_name">access_information_id</xsl:element>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="$desiredDate"/>
						</xsl:element>
						<xsl:element name="mailing_name">
							<xsl:value-of select="request-param[@name='mailingName']"/>
						</xsl:element>
						<xsl:element name="document_type_rd">
							<xsl:value-of select="request-param[@name='documentType']"/>
						</xsl:element>
						<xsl:element name="marketing_information_ind">
							<xsl:value-of select="request-param[@name='marketingInformationIndicator']"/>
						</xsl:element>
						<xsl:element name="table_of_contents_ind">
							<xsl:value-of select="request-param[@name='tableOfContentsIndicator']"/>
						</xsl:element>
						<xsl:element name="printer_destination_rd">
							<xsl:value-of select="request-param[@name='printerDestination']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- If createDeviatingDocumentRecipient = N, retrieves customer information -->
			<xsl:if test= "request-param[@name='createDeviatingDocumentRecipient'] = 'N'">
				<xsl:element name="CcmFifGetEntityCmd">
					<xsl:element name="command_id">Get_CustomerInfo_1</xsl:element>
					<xsl:element name="CcmFifGetEntityInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				<!-- creates mailing with old entity, address and access info if 
			         createDeviatingDocumentRecipient is set to N and no mailing present   -->
				<xsl:element name="CcmFifCreateMailingCmd">
					<xsl:element name="command_id">create_mailing_information</xsl:element>
					<xsl:element name="CcmFifCreateMailingInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="address_ref">
							<xsl:element name="command_id">Get_CustomerInfo_1</xsl:element>
							<xsl:element name="field_name">address_id</xsl:element>
						</xsl:element>
						<xsl:element name="entity_ref">
							<xsl:element name="command_id">Get_CustomerInfo_1</xsl:element>
							<xsl:element name="field_name">entity_id</xsl:element>
						</xsl:element>
						<xsl:element name="access_information_ref">
							<xsl:element name="command_id">Get_CustomerInfo_1</xsl:element>
							<xsl:element name="field_name">access_information_id</xsl:element>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="$desiredDate"/>
						</xsl:element>
						<xsl:element name="mailing_name">
							<xsl:value-of select="request-param[@name='mailingName']"/>
						</xsl:element>
						<xsl:element name="document_type_rd">
							<xsl:value-of select="request-param[@name='documentType']"/>
						</xsl:element>
						<xsl:element name="marketing_information_ind">
							<xsl:value-of select="request-param[@name='marketingInformationIndicator']"/>
						</xsl:element>
						<xsl:element name="table_of_contents_ind">
							<xsl:value-of select="request-param[@name='tableOfContentsIndicator']"/>
						</xsl:element>
						<xsl:element name="printer_destination_rd">
							<xsl:value-of select="request-param[@name='printerDestination']"/>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">validate_mailing_id_1</xsl:element>
							<xsl:element name="field_name">success_ind</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
					</xsl:element>
				</xsl:element>
				<!-- modifies mailing with old entity, address and access info if 
				     createDeviatingDocumentRecipient is set to N -->
				<xsl:element name="CcmFifModifyMailingCmd">
					<xsl:element name="command_id">modify_mailing_information_2</xsl:element>
					<xsl:element name="CcmFifModifyMailingInCont">
						<xsl:element name="mailing_id_ref">
							<xsl:element name="command_id">Find_mailing_1</xsl:element>
							<xsl:element name="field_name">mailing_id</xsl:element>
						</xsl:element>
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="$desiredDate"/>
						</xsl:element>
						<xsl:element name="document_type_rd">
							<xsl:value-of select="request-param[@name='documentType']"/>
						</xsl:element>
						<xsl:element name="name">
							<xsl:value-of select="request-param[@name='mailingName']"/>
						</xsl:element>
						<xsl:element name="table_of_contents_indicator">
							<xsl:value-of select="request-param[@name='tableOfContentsIndicator']"/>
						</xsl:element>
						<xsl:element name="marketing_information_ind">
							<xsl:value-of select="request-param[@name='marketingInformationIndicator']"/>
						</xsl:element>
						<xsl:element name="printer_destination_rd">
							<xsl:value-of select="request-param[@name='printerDestination']"/>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">validate_mailing_id_1</xsl:element>
							<xsl:element name="field_name">success_ind</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">N</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- If documentPatternAction = REMOVE, find an existing document pattern and stop it -->
			<xsl:choose>
				<xsl:when test="count(request-param-list[@name='documentPatternList']/request-param-list-item) != 0">
					<xsl:for-each select="request-param-list[@name='documentPatternList']/request-param-list-item">
				&GenericDocumentPattern;
			</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
				&GenericDocumentPattern;
			</xsl:otherwise>
			</xsl:choose>
			<!-- if createContact = Y Creates a contact for customer -->
			<xsl:if test ="request-param[@name='createContact'] = 'Y'">
				<xsl:element name="CcmFifCreateContactCmd">
					<xsl:element name="CcmFifCreateContactInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="contact_type_rd">
							<xsl:value-of select="request-param[@name='contactType']"/>
						</xsl:element>
						<xsl:element name="short_description">
							<xsl:value-of select="request-param[@name='shortDescription']"/>
						</xsl:element>
						<xsl:element name="description_text_list">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="contact_text">
									<xsl:text>&#xA;TransactionID: </xsl:text>
									<xsl:value-of select="request-param[@name='transactionID']"/>
									<xsl:text> (</xsl:text>
									<xsl:value-of select="request-param[@name='clientName']"/>
									<xsl:text>): </xsl:text>
									<xsl:value-of select="request-param[@name='longDescription']"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
