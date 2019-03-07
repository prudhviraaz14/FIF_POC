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
		
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>	
		
		<xsl:element name="Command_List">
			
			<xsl:variable name="entityType">
				<xsl:choose>
					<xsl:when test="request-param[@name='organizationType'] != ''">O</xsl:when>
					<xsl:when test="request-param[@name='organizationType'] = ''">I</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="request-param[@name='PERSON.Name'] != '' and 
								request-param[@name='ORGANISATION.Name'] = ''">I</xsl:when>
							<xsl:when test="request-param[@name='ORGANISATION.Name'] != ''">O</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:variable>			
			
			<xsl:variable name="organizationType">
				<xsl:choose>
					<xsl:when test="request-param[@name='organizationType'] != ''">
						<xsl:value-of select="request-param[@name='organizationType']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="$entityType = 'O'">BLANK</xsl:if>						
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="incorporationType">
				<xsl:choose>
					<xsl:when test="request-param[@name='incorporationType'] != ''">
						<xsl:value-of select="request-param[@name='incorporationType']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="$entityType = 'O'">UNREGISTERED</xsl:if>						
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="name">
				<xsl:choose>
					<xsl:when test="$entityType = 'I'">
						<xsl:value-of select="request-param[@name='name']"/>
						<xsl:value-of select="request-param[@name='PERSON.Name']"/>
					</xsl:when>
					<xsl:when test="$entityType = 'O'">
						<xsl:value-of select="request-param[@name='name']"/>
						<xsl:value-of select="request-param[@name='ORGANISATION.Name']"/>
					</xsl:when>
				</xsl:choose>				
			</xsl:variable>
			
			<xsl:variable name="forename">
				<xsl:value-of select="request-param[@name='PERSON.Forename']"/>
				<xsl:value-of select="request-param[@name='forename']"/>
			</xsl:variable>
			
			<xsl:variable name="salutationDescription">
				<xsl:choose>
					<xsl:when test="request-param[@name='salutationDescription'] != ''">
						<xsl:value-of select="request-param[@name='salutationDescription']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="$entityType = 'I'">
							<xsl:choose>
								<xsl:when test="request-param[@name='PERSON.SalutationDescription'] != ''">
									<xsl:value-of select="request-param[@name='PERSON.SalutationDescription']"/>	
								</xsl:when>
								<xsl:otherwise>Herr</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="$entityType = 'O'">Firma</xsl:if>						
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="birthDate">
				<xsl:choose>
					<xsl:when test="request-param[@name='birthDate'] != ''">
						<xsl:value-of select="request-param[@name='birthDate']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="$entityType = 'I'">1920.01.01 00:00:00</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="contactNameTemp">
				<xsl:choose>
					<xsl:when test="request-param[@name='contactName'] != ''">
						<xsl:value-of select="request-param[@name='contactName']"/>
					</xsl:when>
					<xsl:when test="request-param[@name='ORGANISATION.ContactName'] != ''">
						<xsl:value-of select="request-param[@name='ORGANISATION.ContactName']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='PERSON.Forename']"/>
						<xsl:value-of select="request-param[@name='forename']"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="request-param[@name='PERSON.Name']"/>
						<xsl:value-of select="request-param[@name='name']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="contactName">
				<xsl:value-of select="substring($contactNameTemp, 1, 60)"/>
			</xsl:variable>
			
			<xsl:variable name="matchCode">
				<xsl:choose>
					<xsl:when test="request-param[@name='matchCodeId'] != ''">
						<xsl:value-of select="request-param[@name='matchCodeId']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring(translate(dateutils:toUpperCase($name),'ÖÄÜß -_',''),1,20)"/>
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:variable>
			
			<xsl:variable name="customerInternalRefNumber">
				<xsl:value-of select="request-param[@name='CUSTOMER.CustomerInternalRefNumber']"/>
				<xsl:value-of select="request-param[@name='customerInternalRefNumber']"/>
			</xsl:variable>			
			
			<xsl:variable name="customerCategoryRd">
				<xsl:choose>
					<xsl:when test="request-param[@name='WHOLESALE_PARTNER'] = 'EINSUNDEINS'">
						<xsl:if test="$entityType = 'O'">BUSINESS</xsl:if>
						<xsl:if test="$entityType = 'I'">RESIDENTIAL</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='customerCategory']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="customerClassificationRd">
				<xsl:choose>
					<xsl:when test="request-param[@name='WHOLESALE_PARTNER'] = 'EINSUNDEINS'">
						<xsl:if test="$entityType = 'O'">R1C</xsl:if>
						<xsl:if test="$entityType = 'I'">R1E</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='customerClassification']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="customerGroupRd">
				<xsl:choose>
					<xsl:when test="request-param[@name='WHOLESALE_PARTNER'] = 'EINSUNDEINS'">WA</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='customerGroup']"/>
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:variable>
						
			<xsl:variable name="affinityGroup">
				<xsl:choose>
					<xsl:when test="request-param[@name='WHOLESALE_PARTNER'] = 'EINSUNDEINS'">1UN1_RESALE</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='affinityGroup']"/>
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:variable>
			
			<xsl:variable name="invoiceTemplateName">
				<xsl:choose>
					<xsl:when test="request-param[@name='WHOLESALE_PARTNER'] = 'EINSUNDEINS'">1und1 Rechnung</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='docTemplateName']"/>
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:variable>
			
			<xsl:variable name="mailingPrinterDestination">
				<xsl:choose>
					<xsl:when test="request-param[@name='WHOLESALE_PARTNER'] = 'EINSUNDEINS'">MDV</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='mailingPrinterDestination']"/>
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:variable>
			
			<xsl:variable name="mailingName">
				<xsl:choose>
					<xsl:when test="request-param[@name='WHOLESALE_PARTNER'] = 'EINSUNDEINS'">Rechnung</xsl:when>
					<xsl:when test="request-param[@name='mailingName'] != ''">
						<xsl:value-of select="request-param[@name='mailingName']"/>
					</xsl:when>
					<xsl:otherwise>Rechnung</xsl:otherwise>
				</xsl:choose>				
			</xsl:variable>
			
			<xsl:variable name="mailingDocumentType">
				<xsl:choose>
					<xsl:when test="request-param[@name='mailingDocumentType'] != ''">
						<xsl:value-of select="request-param[@name='mailingDocumentType']"/>
					</xsl:when>
					<xsl:otherwise>BILL</xsl:otherwise>
				</xsl:choose>				
			</xsl:variable>
			
			<xsl:variable name="userPassword">
				<xsl:choose>
					<xsl:when test="request-param[@name='userPassword'] != ''">
						<xsl:value-of select="request-param[@name='userPassword']"/>
					</xsl:when>
					<xsl:otherwise>NONE</xsl:otherwise>
				</xsl:choose>				
			</xsl:variable>			
									
			<xsl:variable name="cycleName">
				<xsl:value-of select="request-param[@name='cycleName']"/>
			</xsl:variable>			
			
			<xsl:variable name="paymentMethod">
				<xsl:choose>
					<xsl:when test="request-param[@name='WHOLESALE_PARTNER'] = 'EINSUNDEINS'">MANUAL</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='paymentMethod']"/>
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:variable>
						
			<xsl:variable name="paymentTerm">
				<xsl:choose>
					<xsl:when test="request-param[@name='paymentTerm'] != ''">
						<xsl:value-of select="request-param[@name='paymentTerm']"/>
					</xsl:when>
					<xsl:otherwise>14</xsl:otherwise>
				</xsl:choose>				
			</xsl:variable>			
			
			<xsl:variable name="addressType">
				<xsl:choose>
				<xsl:when test="request-param[@name='addressType'] != ''
					and request-param[@name='clientName'] != 'OPM'">
					<xsl:value-of select="request-param[@name='addressType']"/>
				</xsl:when>
				<xsl:when test="request-param[@name='clientName'] = 'OPM'">
					<xsl:text>STD</xsl:text>
				</xsl:when>
				<xsl:otherwise>KUND</xsl:otherwise>
			</xsl:choose>
			</xsl:variable>			
			
			<!-- Ensure that the parameter docPatternOutputDevice either contains PRINTER or WEBBILL -->
			<xsl:for-each select="request-param-list[@name='patternDocTemplateNameList']/request-param-list-item">
				<xsl:variable name="DocPatternOutputDevice">
					<xsl:value-of select="request-param[@name='docPatternOutputDevice']"/>
				</xsl:variable>      
				<xsl:if test="($DocPatternOutputDevice != 'PRINTER')
					and ($DocPatternOutputDevice != 'WEBBILL')">	
					<xsl:element name="CcmFifRaiseErrorCmd">
						<xsl:element name="command_id">create_error_1</xsl:element>
						<xsl:element name="CcmFifRaiseErrorInCont">
							<xsl:element name="error_text">Allowed values for parameter docPatternOutputDevice : PRINTER or WEBBILL "</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
			</xsl:for-each>
			
			<!-- Create Entity-->
			<xsl:element name="CcmFifCreateEntityCmd">
				<xsl:element name="command_id">create_entity_1</xsl:element>
				<xsl:element name="CcmFifCreateEntityInCont">
					<xsl:element name="entity_type">
						<xsl:value-of select="$entityType"/>
					</xsl:element>
					<xsl:element name="salutation_description">
						<xsl:value-of select="$salutationDescription"/>
					</xsl:element>
					<xsl:element name="title_description">
						<xsl:value-of select="request-param[@name='titleDescription']"/>
						<xsl:value-of select="request-param[@name='PERSON.TitleDescription']"/>						
					</xsl:element>
					<xsl:element name="nobility_prefix_description">
						<xsl:value-of select="request-param[@name='nobilityPrefixDescription']"/>
					</xsl:element>					
					<xsl:element name="forename">
						<xsl:value-of select="$forename"/>
					</xsl:element>
					<xsl:element name="surname_prefix_description">
						<xsl:value-of select="request-param[@name='surnamePrefix']"/>
					</xsl:element>
					<xsl:element name="name">
						<xsl:value-of select="$name"/>
					</xsl:element>
					<xsl:element name="birth_date">
						<xsl:value-of select="$birthDate"/>
					</xsl:element>
					<xsl:element name="organization_type_rd">
						<xsl:value-of select="$organizationType"/>
					</xsl:element>	
					<xsl:element name="organization_suffix_name">
						<xsl:value-of select="request-param[@name='organizationSuffixName']"/>
					</xsl:element>
					<xsl:element name="incorporation_number_id">
						<xsl:value-of select="request-param[@name='incorporationNumber']"/>
					</xsl:element>	
					<xsl:element name="incorporation_type_rd">
						<xsl:value-of select="$incorporationType"/>
					</xsl:element>	
					<xsl:element name="incorporation_city_name">
						<xsl:value-of select="request-param[@name='incorporationCityName']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Address-->
			<xsl:element name="CcmFifCreateAddressCmd">
				<xsl:element name="command_id">create_address_1</xsl:element>
				<xsl:element name="CcmFifCreateAddressInCont">
					<xsl:element name="entity_ref">
						<xsl:element name="command_id">create_entity_1</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element>	
					<xsl:element name="address_type">		
						<xsl:value-of select="$addressType"/>
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
					<xsl:element name="country_code">DE</xsl:element>
					<xsl:element name="address_additional_text">
						<xsl:value-of select="request-param[@name='additionalText']"/>
					</xsl:element>					
					<xsl:if test="request-param[@name='validationTypeRd'] != ''">
						<xsl:element name="validation_type_rd">
							<xsl:value-of select="request-param[@name='validationTypeRd']"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:element>			
						
			<xsl:variable name="maskingDigits">
				<xsl:choose>
					<xsl:when test="request-param[@name='cdrEgnFormat'] = 'NO_EGN'">0</xsl:when>
					<xsl:when test="request-param[@name='cdrEgnFormat'] = 'ABBREVIATED_EGN'">20</xsl:when>
					<xsl:when test="request-param[@name='cdrEgnFormat'] = 'FULL_EGN'">-1</xsl:when>
					<xsl:when test="request-param[@name='cdrEgnFormat'] = 'NORMAL_EGN'">-1</xsl:when>
				</xsl:choose>
				
			</xsl:variable>
			
			<xsl:variable name="storageMaskingDigits">
				<xsl:choose>
					<xsl:when test="request-param[@name='cdrStorageFormat'] = 'IMMEDIATE_DELETION'">0</xsl:when>
					<xsl:when test="request-param[@name='cdrStorageFormat'] = 'ABBREVIATED_STORAGE'">20</xsl:when>
					<xsl:when test="request-param[@name='cdrStorageFormat'] = 'FULL_STORAGE'">-1</xsl:when>
					<xsl:when test="request-param[@name='cdrStorageFormat'] = 'NORMAL_STORAGE'">-1</xsl:when>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="retentionPeriod">				
				<xsl:choose>
					<xsl:when test="request-param[@name='cdrEgnFormat'] = 'NO_EGN'">80NODT</xsl:when>
					<xsl:when test="request-param[@name='cdrEgnFormat'] = 'ABBREVIATED_EGN'">80DETL</xsl:when>
					<xsl:when test="request-param[@name='cdrEgnFormat'] = 'FULL_EGN'">80DETL</xsl:when>
					<xsl:when test="request-param[@name='cdrEgnFormat'] = 'NORMAL_EGN'">80DETL</xsl:when>						
				</xsl:choose>
			</xsl:variable>
			
			<xsl:if test="(request-param[@name='marketingPhoneIndicator'] != '' 
				or request-param[@name='marketingMailIndicator'] != ''
				or request-param[@name='marketingFaxIndicator'] != ''
				or request-param[@name='marketingCoopIndicator'] != ''
				or request-param[@name='marketingUseDataIndicator'] != '') 
				and
				(request-param[@name='personalDataIndicator'] != ''
				or request-param[@name='customerDataIndicator'] != '')">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">raise_error_marketing</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">Only either the obsolete indicators for marketing information or the new indicators can be provided.</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<xsl:variable name="marketingPhoneIndicator">
				<xsl:value-of select="request-param[@name='marketingPhoneIndicator']"/>
			</xsl:variable>
			
			<xsl:variable name="marketingMailIndicator">
				<xsl:value-of select="request-param[@name='marketingMailIndicator']"/>
				<xsl:value-of select="request-param[@name='customerDataIndicator']"/>				
			</xsl:variable>
			
			<xsl:variable name="marketingFaxIndicator">
				<xsl:value-of select="request-param[@name='marketingFaxIndicator']"/>
			</xsl:variable>
			
			<xsl:variable name="marketingCoopIndicator">
				<xsl:value-of select="request-param[@name='marketingCoopIndicator']"/>
			</xsl:variable>
			
			<xsl:variable name="marketingUseDataIndicator">
				<xsl:value-of select="request-param[@name='marketingUseDataIndicator']"/>
				<xsl:value-of select="request-param[@name='personalDataIndicator']"/>
			</xsl:variable>
			
			<xsl:variable name="marketingAuthorizationDate">
				<xsl:if test="request-param[@name='marketingAuthorizationDate'] != ''">
					<xsl:value-of select="request-param[@name='marketingAuthorizationDate']"/>
				</xsl:if>
				<xsl:if test="request-param[@name='marketingAuthorizationDate'] = ''">
					<xsl:value-of select="dateutils:getCurrentDate()"/>
				</xsl:if>
			</xsl:variable>
			
			<!-- Create Customer-->
			<xsl:element name="CcmFifCreateCustomerCmd">
				<xsl:element name="command_id">create_customer_1</xsl:element>
				<xsl:element name="CcmFifCreateCustomerInCont">
					<xsl:element name="entity_ref">
						<xsl:element name="command_id">create_entity_1</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element>
					<xsl:element name="address_ref">
						<xsl:element name="command_id">create_address_1</xsl:element>
						<xsl:element name="field_name">address_id</xsl:element>
					</xsl:element>
					<xsl:element name="user_password">
						<xsl:value-of select="$userPassword"/>
					</xsl:element>
					<xsl:element name="match_code_id">
						<xsl:value-of select="$matchCode"/>
					</xsl:element>
					<xsl:element name="customer_group_rd">
						<xsl:value-of select="$customerGroupRd"/>
					</xsl:element>
					<xsl:element name="category_rd">
						<xsl:value-of select="$customerCategoryRd"/>
					</xsl:element>
					<xsl:element name="classification_rd">
						<xsl:value-of select="$customerClassificationRd"/>
					</xsl:element>
					<xsl:element name="customer_internal_ref_number">
						<xsl:value-of select="$customerInternalRefNumber"/>
					</xsl:element>						
					<xsl:if test="$customerClassificationRd = 'VC' or $customerClassificationRd = 'VE'">
						<xsl:element name="security_customer_group_string">
							<xsl:value-of select="$customerClassificationRd"/>
						</xsl:element>
					</xsl:if>

					<xsl:element name="masking_digits_rd">
						<xsl:value-of select="$maskingDigits"/>
					</xsl:element>						
					<xsl:element name="retention_period_rd">
						<xsl:value-of select="$retentionPeriod"/>
					</xsl:element>
					<xsl:element name="storage_masking_digits_rd">
						<xsl:value-of select="$storageMaskingDigits"/>
					</xsl:element>
					<xsl:element name="payment_method_rd">
						<xsl:value-of select="$paymentMethod"/>
					</xsl:element>
						<xsl:element name="payment_term_rd">
						<xsl:value-of select="$paymentTerm"/>
					</xsl:element>							
					<xsl:element name="cycle_name">
        				<xsl:value-of select="$cycleName"/>
        			</xsl:element>
					<xsl:element name="risk_category_rd">
						<xsl:value-of select="request-param[@name='riskCategory']"/>
					</xsl:element>	
					<xsl:if test="$organizationType = ''">					
						<xsl:element name="post_ident_indicator">
							<xsl:value-of select="request-param[@name='postIdentIndicator']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="marketing_use_data_indicator">
						<xsl:value-of select="$marketingUseDataIndicator"/>
					</xsl:element>
					<xsl:element name="marketing_phone_indicator">
						<xsl:value-of select="$marketingPhoneIndicator"/>
					</xsl:element>
					<xsl:element name="marketing_mail_indicator">
						<xsl:value-of select="$marketingMailIndicator"/>
					</xsl:element>
					<xsl:element name="marketing_fax_indicator">
						<xsl:value-of select="$marketingFaxIndicator"/>
					</xsl:element>
					<xsl:element name="marketing_coop_indicator">
						<xsl:value-of select="$marketingCoopIndicator"/>
					</xsl:element>
					<xsl:element name="marketing_authorization_date">
						<xsl:value-of select="$marketingAuthorizationDate"/>
					</xsl:element>	
					<xsl:element name="allocated_customer_number">
						<xsl:value-of select="request-param[@name='allocatedCustomerNumber']"/>
					</xsl:element>		
					<xsl:element name="billing_account_number">
						<xsl:value-of select="request-param[@name='billingAccountNumber']"/>
					</xsl:element>	
					<xsl:element name="source_system_id">
						<xsl:value-of select="request-param[@name='sourceSystemId']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Add affinity group -->
			<xsl:element name="CcmFifAddAffinityGroupCmd">
				<xsl:element name="command_id">add_affinity_group_1</xsl:element>
				<xsl:element name="CcmFifAddAffinityGroupInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">create_customer_1</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="affinity_group_list">
						<xsl:for-each select="request-param-list[@name='affinityGroupList']/request-param-list-item">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">
									<xsl:value-of select="request-param[@name='affinityGroup']"/>
								</xsl:element>
							</xsl:element>
						</xsl:for-each>
						<xsl:if test="$affinityGroup != ''">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">
									<xsl:value-of select="$affinityGroup"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			 
			<!-- Create Access Information -->
			<xsl:element name="CcmFifUpdateAccessInformCmd">
				<xsl:element name="command_id">create_access_information_1</xsl:element>
				<xsl:element name="CcmFifUpdateAccessInformInCont">					
					<xsl:element name="entity_ref">
						<xsl:element name="command_id">create_entity_1</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element>
					<xsl:element name="access_information_type_rd">
						<xsl:value-of select="request-param[@name='accessInformationTyp']"/>
					</xsl:element>
					<xsl:element name="contact_name">
						<xsl:value-of select="$contactName"/>
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
		            <xsl:element name="email_validation_indicator">
		                <xsl:value-of select="request-param[@name='emailValidationIndicator']"/>
		            </xsl:element>
					<xsl:if test="(request-param[@name='electronicContactIndicator'] != '')">					
						<xsl:element name="electronic_contact_indicator">
							<xsl:value-of select="request-param[@name='electronicContactIndicator']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="(request-param[@name='electronicContactIndicator'] = '')">					
						<xsl:element name="electronic_contact_indicator">N</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Access Information -->
			<xsl:if test="request-param[@name='vodafoneMobileNumber'] != ''
				and (request-param[@name='customerClassification'] = 'VC'
				or request-param[@name='customerClassification'] = 'VE')">
				<xsl:element name="CcmFifUpdateAccessInformCmd">
					<xsl:element name="command_id">create_vf_mobile_number</xsl:element>
					<xsl:element name="CcmFifUpdateAccessInformInCont">					
						<xsl:element name="entity_ref">
							<xsl:element name="command_id">create_entity_1</xsl:element>
							<xsl:element name="field_name">entity_id</xsl:element>
						</xsl:element>
						<xsl:element name="access_information_type_rd">MSISDN</xsl:element>
						<xsl:element name="contact_name">
							<xsl:value-of select="$contactName"/>
						</xsl:element>
						<xsl:element name="mobile_number">
							<xsl:value-of select="request-param[@name='vodafoneMobileNumber']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="request-param[@name='parentCustomerNumber'] != ''">				
				<!-- Add customer to hierarchy-->
				<xsl:element name="CcmFifAddCustomerToHierarchyCmd">
					<xsl:element name="command_id">add_customer_to_hierarchy_1</xsl:element>
					<xsl:element name="CcmFifAddCustomerToHierarchyInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">create_customer_1</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="parent_customer_number">
							<xsl:value-of select="request-param[@name='parentCustomerNumber']"/>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="request-param[@name='WHOLESALE_PARTNER'] != ''">
				<!-- get reference data (parent customer number) -->				
				<xsl:element name="CcmFifGetCrossRefSecondaryValueCmd">
					<xsl:element name="command_id">get_parent_customer</xsl:element>
					<xsl:element name="CcmFifGetCrossRefSecondaryValueInCont">
						<xsl:element name="group_code">WHS_CUST</xsl:element>
						<xsl:element name="primary_value">
							<xsl:value-of select="request-param[@name='WHOLESALE_PARTNER']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- Add customer to hierarchy-->
				<xsl:element name="CcmFifAddCustomerToHierarchyCmd">
					<xsl:element name="command_id">add_customer_to_hierarchy_1</xsl:element>
					<xsl:element name="CcmFifAddCustomerToHierarchyInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">create_customer_1</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="parent_customer_number_ref">
							<xsl:element name="command_id">get_parent_customer</xsl:element>
							<xsl:element name="field_name">secondary_value</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="request-param[@name='createAccountIndicator'] != 'N'">	
				
				
			<!-- Validate the parameter type -->
				<xsl:if test="$mailingPrinterDestination = ''
					or request-param[@name='docTemplateName'] = ''
					or request-param[@name='accountOutputDevice'] = ''	">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">type_error_1</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">The parameter paymentMethod, mailingPrinterDestination, docTemplateName and accountOutputDevice has to be set for the creation of an account!</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
							
				<xsl:if test="request-param[@name='paymentMethod'] = 'DIRECT_DEBIT'">				
				<!-- Create bank account -->
					<xsl:element name="CcmFifCreateBankAccountCmd">
						<xsl:element name="command_id">create_bank_account_1</xsl:element>
						<xsl:element name="CcmFifCreateBankAccountInCont">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">create_customer_1</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
							<xsl:element name="bank_account_number">
								<xsl:value-of select="request-param[@name='bankAccountNumber']"/>
							</xsl:element>
							<xsl:element name="owner_full_name">
								<xsl:value-of select="request-param[@name='ownerFullName']"/>
							</xsl:element>
							<xsl:element name="bank_clearing_code">
								<xsl:value-of select="request-param[@name='bankClearingCode']"/>
							</xsl:element>
							<xsl:element name="bank_identifier_code">
								<xsl:value-of select="request-param[@name='bic']"/>
							</xsl:element>
							<xsl:element name="internat_bank_account_number">
								<xsl:value-of select="request-param[@name='iban']"/>
							</xsl:element>                                  
							<xsl:element name="sepa_check_functional_error_ind">Y</xsl:element>
						</xsl:element>
					</xsl:element>
					
				</xsl:if>
				
				<!-- Create mailing-->
				<xsl:element name="CcmFifCreateMailingCmd">					
					<xsl:element name="command_id">create_mailing_1</xsl:element>
					<xsl:element name="CcmFifCreateMailingInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">create_customer_1</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
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
							<xsl:element name="command_id">create_access_information_1</xsl:element>
							<xsl:element name="field_name">access_information_id</xsl:element>
						</xsl:element>			
						<xsl:element name="mailing_name">
							<xsl:value-of select="$mailingName"/>
						</xsl:element>
						<xsl:element name="document_type_rd">					
							<xsl:value-of select="$mailingDocumentType"/>
						</xsl:element>
						<xsl:element name="printer_destination_rd">
							<xsl:value-of select="$mailingPrinterDestination"/>
						</xsl:element>												
					</xsl:element>
				</xsl:element>
				
				<!-- Create account-->
				<xsl:element name="CcmFifCreateAccountCmd">
					<xsl:element name="command_id">create_account_1</xsl:element>
					<xsl:element name="CcmFifCreateAccountInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">create_customer_1</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:if test="(request-param[@name='paymentMethod'] = 'DIRECT_DEBIT')">							
							<xsl:element name="bank_account_id_ref">
								<xsl:element name="command_id">create_bank_account_1</xsl:element>
								<xsl:element name="field_name">bank_account_id</xsl:element>
							</xsl:element>							
						</xsl:if>
						<xsl:element name="mailing_id_ref">
							<xsl:element name="command_id">create_mailing_1</xsl:element>
							<xsl:element name="field_name">mailing_id</xsl:element>
						</xsl:element>
						<xsl:element name="doc_template_name">
							<xsl:value-of select="$invoiceTemplateName"/>
						</xsl:element>
						<xsl:element name="method_of_payment">
							<xsl:value-of select="$paymentMethod"/>
						</xsl:element>
						<xsl:element name="manual_suspend_ind">
							<xsl:value-of select="request-param[@name='manualSuspendInd']"/>
						</xsl:element>
						<xsl:element name="language_rd">
							<xsl:value-of select="request-param[@name='languageRd']"/>
						</xsl:element>
						<xsl:element name="currency_rd">
							<xsl:value-of select="request-param[@name='currencyRd']"/>
						</xsl:element>
						<xsl:element name="cycle_name">
							<xsl:value-of select="$cycleName"/>
						</xsl:element>
						<xsl:element name="payment_term_rd">
							<xsl:value-of select="$paymentTerm"/>
						</xsl:element> 
						<xsl:element name="zero_charge_ind">
							<xsl:value-of select="request-param[@name='zeroChargeInd']"/>
						</xsl:element>
						<xsl:element name="usage_limit">
							<xsl:choose>
								<xsl:when test="request-param[@name='usageLimit'] != ''">
									<xsl:value-of select="request-param[@name='usageLimit']"/>								
								</xsl:when>
								<xsl:otherwise>99999999.99</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="customer_account_id">
							<xsl:value-of select="request-param[@name='customerAccountId']"/>
						</xsl:element>
						<xsl:element name="output_device_rd">
							<xsl:value-of select="request-param[@name='accountOutputDevice']"/>
						</xsl:element>
						<xsl:element name="direct_debit_authoriz_date">
							<xsl:value-of select="request-param[@name='directDebitAuthorizDate']"/>
						</xsl:element>
			            <xsl:element name="activate_account_indicator">
				            <xsl:choose>
					            <xsl:when test="request-param[@name='WHOLESALE_PARTNER'] = 'EINSUNDEINS'">N</xsl:when>  					
					            <xsl:otherwise>Y</xsl:otherwise>
				            </xsl:choose>				
			            </xsl:element>			
						<xsl:if test="(request-param[@name='paymentMethod'] = 'DIRECT_DEBIT')">														
							<xsl:element name="force_manual_payment_ind_ref">
								<xsl:element name="command_id">create_bank_account_1</xsl:element>
								<xsl:element name="field_name">sepa_functional_error_occured</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:element name="mandate_signature_date">
							<xsl:value-of select="request-param[@name='signatureDate']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>

				<!-- Create Document Pattern -->
				<xsl:for-each select="request-param-list[@name='patternDocTemplateNameList']/request-param-list-item">
					<xsl:variable name="NodePosition" select="position()"/> 
					<xsl:variable name="DocTemplateName" select="request-param[@name='patternDocTemplateName']"/> 
					<xsl:element name="CcmFifCreateDocumentPatternCmd">
						<xsl:element name="command_id">
							<xsl:value-of select="concat('create_doc_pattern_', $NodePosition)"/>
						</xsl:element>
						<xsl:element name="CcmFifCreateDocumentPatternInCont">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">create_customer_1</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>				
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">create_account_1</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
							<xsl:element name="mailing_id_ref">
								<xsl:element name="command_id">create_mailing_1</xsl:element>
								<xsl:element name="field_name">mailing_id</xsl:element>
							</xsl:element>
							<xsl:element name="output_device_rd">
								<xsl:value-of select="request-param[@name='docPatternOutputDevice']"/>
							</xsl:element>
							<xsl:element name="doc_template_name">
								<xsl:value-of select="$DocTemplateName"/>
							</xsl:element>
							<xsl:element name="cycle_name">
								<xsl:value-of select="$cycleName"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>

			</xsl:if>
	
			<xsl:if test="request-param[@name='championId'] != ''">
				<xsl:element name="CcmFifAddCcmParameterMapCmd">
					<xsl:element name="CcmFifAddCcmParameterMapInCont">
						<xsl:element name="supported_object_id_ref">
							<xsl:element name="command_id">create_customer_1</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>						
						</xsl:element>
						<xsl:element name="supported_object_type_rd">CUST_NUMB</xsl:element>
						<xsl:element name="param_name_rd">CHAMPION_ID</xsl:element>
						<xsl:element name="param_value">
							<xsl:value-of select="request-param[@name='championId']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>				
			</xsl:if>
			
			<!-- Create Contact -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">create_customer_1</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="contact_type_rd">CUSTOMER</xsl:element>
					<xsl:element name="short_description">Kunde erstellt</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>Kunde erstellt von</xsl:text>
						<xsl:text>&#xA;Benutzer: </xsl:text>
						<xsl:choose>
							<xsl:when test="request-param[@name='userName'] != ''">
								<xsl:value-of select="request-param[@name='userName']"/>								
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="request-param[@name='clientName']"/>	
							</xsl:otherwise>
						</xsl:choose>
						<xsl:text>&#xA;TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create External notification  -->
			<xsl:if test="request-param[@name='requestListId'] != ''">
				<xsl:element name="CcmFifCreateExternalNotificationCmd">
					<xsl:element name="command_id">create_ext_notification_1</xsl:element>
					<xsl:element name="CcmFifCreateExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="notification_action_name">CreateResidentialCustomer</xsl:element>
						<xsl:element name="target_system">FIF</xsl:element>
						<xsl:element name="parameter_value_list">
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
								<xsl:element name="parameter_value_ref">
									<xsl:element name="command_id">create_customer_1</xsl:element>
									<xsl:element name="field_name">customer_number</xsl:element>
								</xsl:element>
							</xsl:element>							
							<xsl:if test="(request-param[@name='createAccountIndicator'] != 'N')">												
								<xsl:element name="CcmFifParameterValueCont">
									<xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
									<xsl:element name="parameter_value_ref">
										<xsl:element name="command_id">create_account_1</xsl:element>
										<xsl:element name="field_name">account_number</xsl:element>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">ADDRESS_ID</xsl:element>
								<xsl:element name="parameter_value_ref">
									<xsl:element name="command_id">create_address_1</xsl:element>
									<xsl:element name="field_name">address_id</xsl:element>
								</xsl:element>
							</xsl:element>		
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">ENTITY_ID</xsl:element>
								<xsl:element name="parameter_value_ref">
									<xsl:element name="command_id">create_entity_1</xsl:element>
									<xsl:element name="field_name">entity_id</xsl:element>
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">ACCESS_INFORMATION_ID</xsl:element>
								<xsl:element name="parameter_value_ref">
									<xsl:element name="command_id">create_access_information_1</xsl:element>
									<xsl:element name="field_name">access_information_id</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			
				<!-- Create KBA notification  -->
				<xsl:if test="request-param[@name='createAccountIndicator'] != 'N' ">
					<xsl:element name="CcmFifCreateExternalNotificationCmd">
						<xsl:element name="command_id">create_ext_notification_2</xsl:element>
						<xsl:element name="CcmFifCreateExternalNotificationInCont">
							<xsl:element name="notification_action_name">createKBANotification</xsl:element>
							<xsl:element name="target_system">KBA</xsl:element>
							<xsl:element name="parameter_value_list">
								
                <xsl:element name="CcmFifParameterValueCont">                            
                    <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
    								<xsl:element name="parameter_value_ref">
    									<xsl:element name="command_id">create_customer_1</xsl:element>
    									<xsl:element name="field_name">customer_number</xsl:element>
    								</xsl:element>
                </xsl:element>

								<xsl:element name="CcmFifParameterValueCont">
									<xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
									<xsl:element name="parameter_value_ref">
										<xsl:element name="command_id">create_account_1</xsl:element>
										<xsl:element name="field_name">account_number</xsl:element>
									</xsl:element>
								</xsl:element>
								
								<xsl:element name="CcmFifParameterValueCont">
									<xsl:element name="parameter_name">TYPE</xsl:element>
									<xsl:element name="parameter_value">PROCESS</xsl:element>
								</xsl:element>
								<xsl:element name="CcmFifParameterValueCont">
									<xsl:element name="parameter_name">CATEGORY</xsl:element>
									<xsl:element name="parameter_value">SepaHubFunctionalError</xsl:element>
								</xsl:element>
								<xsl:element name="CcmFifParameterValueCont">
									<xsl:element name="parameter_name">USER_NAME</xsl:element>
									<xsl:element name="parameter_value">
										<xsl:value-of select="request-param[@name='clientName']"/>
									</xsl:element>
								</xsl:element>
								
								<xsl:element name="CcmFifParameterValueCont">
									<xsl:element name="parameter_name">TEXT</xsl:element>
									<xsl:element name="parameter_value">									   	
										<xsl:text>Bitte anhand der Kontonummer und Bankleitzahl die IBAN und BIC ermitteln und die payment method auf debit ändern: BLZ </xsl:text>
										<xsl:value-of select="request-param[@name='bankClearingCode']"/>
										<xsl:text> Konto-Nr  </xsl:text>
										<xsl:value-of select="request-param[@name='bankAccountNumber']"/>
									</xsl:element>
								</xsl:element>
							</xsl:element>	
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">create_bank_account_1</xsl:element>
								<xsl:element name="field_name">sepa_functional_error_occured</xsl:element>
							</xsl:element>
							<xsl:element name="required_process_ind">Y</xsl:element>
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
			
			<xsl:variable name="terminationOffset">
				<xsl:choose>
					<xsl:when test="request-param[@name='terminationOffset'] != ''">
						<xsl:value-of select="request-param[@name='terminationOffset']"/>	
					</xsl:when>
					<xsl:otherwise>180</xsl:otherwise>
				</xsl:choose>
			</xsl:variable> 
			
			<xsl:variable name="customerDeactivationDate" select="dateutils:createFIFDateOffset($today, 'DATE', $terminationOffset)"/>
			
			<!-- request to deactivate Customer in 6 months -->
			<xsl:element name="CcmFifCreateFifRequestCmd">
				<xsl:element name="command_id">create_fif_request_for_cust_deactivation_1</xsl:element> 
				<xsl:element name="CcmFifCreateFifRequestInCont">
					<xsl:element name="action_name">deactivateCustomer</xsl:element> 
					<xsl:element name="due_date">
						<xsl:value-of select="$customerDeactivationDate"/>
					</xsl:element> 
					<xsl:element name="dependent_transaction_id">dummy</xsl:element>
					<xsl:element name="priority">4</xsl:element>
					<xsl:element name="bypass_command">N</xsl:element>
					<xsl:element name="external_system_id_ref">						
						<xsl:element name="command_id">create_customer_1</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>						
					</xsl:element>                  
					<xsl:element name="request_param_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element> 
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">create_customer_1</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>           
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">MAX_ATTEMPTS</xsl:element> 
							<xsl:element name="parameter_value">3</xsl:element>                  
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element> 
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='clientName']"/>
							</xsl:element>                  
						</xsl:element>
					</xsl:element>														
				</xsl:element>
			</xsl:element>			
			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
