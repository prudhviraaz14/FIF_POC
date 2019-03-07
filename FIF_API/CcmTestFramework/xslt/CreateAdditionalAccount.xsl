<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
    XSLT file for creating address, access information, bank account, mailing & account.
    
    @author banania
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
    xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1"
        indent="yes" method="xml"/>
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
            
            <!--Get Customer Number if not provided-->
            <xsl:if test="(request-param[@name='customerNumber'] = '')
                and (request-param[@name='requestListId'] != '')">
                <xsl:element name="CcmFifReadExternalNotificationCmd">
                    <xsl:element name="command_id">read_external_notification_1</xsl:element>
                    <xsl:element name="CcmFifReadExternalNotificationInCont">
                        <xsl:element name="transaction_id">
                            <xsl:value-of select="request-param[@name='requestListId']"/>
                        </xsl:element>
                        <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
                                 
                                 
                                 
            <!--Get Entity, Address and Access info if not provided-->
            <xsl:if test="request-param[@name='name'] = ''">
                <!-- get entity for customer -->        
                <xsl:element name="CcmFifGetEntityCmd">
                    <xsl:element name="command_id">get_entity</xsl:element>
                    <xsl:element name="CcmFifGetEntityInCont">
                        <xsl:choose>
                            <xsl:when test="request-param[@name='customerNumber'] = ''">
                                <xsl:element name="customer_number_ref">
                                    <xsl:element name="command_id">read_external_notification_1</xsl:element>
                                    <xsl:element name="field_name">parameter_value</xsl:element>
                                </xsl:element>        
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element name="customer_number">
                                    <xsl:value-of select="request-param[@name='customerNumber']"/>
                                </xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>                            
                    </xsl:element>
                </xsl:element>                                                
            </xsl:if>                                 
                                 
            <!-- Create Entity-->
            <xsl:if test="request-param[@name='name'] != ''">
            <xsl:element name="CcmFifCreateEntityCmd">
                <xsl:element name="command_id">create_entity_1</xsl:element>
                <xsl:element name="CcmFifCreateEntityInCont">
                    <xsl:if test="request-param[@name='organizationType'] != ''">					
                        <xsl:element name="entity_type">O</xsl:element>
                    </xsl:if>
                    <xsl:if test="request-param[@name='organizationType'] = ''">					
                        <xsl:element name="entity_type">I</xsl:element>
                    </xsl:if>					
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
                    <xsl:if test="(request-param[@name='addressType'] != '')">			
                        <xsl:element name="address_type">
                            <xsl:value-of select="request-param[@name='addressType']"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="(request-param[@name='addressType'] = '')">			
                        <xsl:element name="address_type">VERS</xsl:element>
                    </xsl:if>
                    <xsl:if test="(request-param[@name='postOfficeBox'] = '')">	
                        <xsl:element name="street_name">
                            <xsl:value-of select="request-param[@name='streetName']"/>
                        </xsl:element>
                        <xsl:element name="street_number">
                            <xsl:value-of select="request-param[@name='streetNumber']"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="(request-param[@name='postOfficeBox'] != '')">	                    
                        <xsl:element name="post_office_box">
                            <xsl:value-of select="request-param[@name='postOfficeBox']"/>
                        </xsl:element>    
                    </xsl:if>                
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

                <xsl:variable name="contactNameTemp">
                    <xsl:choose>
                        <xsl:when test="request-param[@name='contactName'] != ''">
                            <xsl:value-of select="request-param[@name='contactName']"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="request-param[@name='forename']"/>
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="request-param[@name='name']"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:variable name="contactName">
                    <xsl:value-of select="substring($contactNameTemp, 1, 60)"/>
                </xsl:variable>                

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
            </xsl:if>    
            
            <xsl:if test="(request-param[@name='paymentMethod'] = 'DIRECT_DEBIT')">				
                <!-- Create bank account -->
                <xsl:element name="CcmFifCreateBankAccountCmd">
                    <xsl:element name="command_id">create_bank_account_1</xsl:element>
                    <xsl:element name="CcmFifCreateBankAccountInCont">
                        <xsl:if test="request-param[@name='customerNumber'] != ''">	
                            <xsl:element name="customer_number">
                                <xsl:value-of select="request-param[@name='customerNumber']"/>
                            </xsl:element>
                        </xsl:if>
                        <xsl:if test="request-param[@name='customerNumber'] = ''">					
                            <xsl:element name="customer_number_ref">
                                <xsl:element name="command_id">read_external_notification_1</xsl:element>
                                <xsl:element name="field_name">parameter_value</xsl:element>
                            </xsl:element>
                        </xsl:if>
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
                        <xsl:element name="sepa_check_functional_error_ind">
                            <xsl:value-of select="request-param[@name='sepaCheckFunctionalErrorInd']"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            
            <!-- Create mailing-->
            <xsl:element name="CcmFifCreateMailingCmd">
                <xsl:element name="command_id">create_mailing_1</xsl:element>
                <xsl:element name="CcmFifCreateMailingInCont">
                    <xsl:if test="request-param[@name='customerNumber'] != ''">	
                        <xsl:element name="customer_number">
                           <xsl:value-of select="request-param[@name='customerNumber']"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="request-param[@name='customerNumber'] = ''">					
                        <xsl:element name="customer_number_ref">
                            <xsl:element name="command_id">read_external_notification_1</xsl:element>
                            <xsl:element name="field_name">parameter_value</xsl:element>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="request-param[@name='name'] != ''">	
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
                    </xsl:if>   
                    <xsl:if test="request-param[@name='name'] = ''">	    
                        <xsl:element name="address_ref">
                            <xsl:element name="command_id">get_entity</xsl:element>
                            <xsl:element name="field_name">primary_address_id</xsl:element>
                        </xsl:element>
                        <xsl:element name="entity_ref">
                            <xsl:element name="command_id">get_entity</xsl:element>
                            <xsl:element name="field_name">entity_id</xsl:element>
                        </xsl:element>
                        <xsl:element name="access_information_ref">
                            <xsl:element name="command_id">get_entity</xsl:element>
                            <xsl:element name="field_name">primary_access_info_id</xsl:element>
                        </xsl:element>                    
                    </xsl:if>  
                    
                    <xsl:if test="(request-param[@name='mailingName'] != '')">
                        <xsl:element name="mailing_name">
                        <xsl:value-of select="request-param[@name='mailingName']"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="(request-param[@name='mailingName'] = '')">
                        <xsl:element name="mailing_name">Rechnung</xsl:element>
                    </xsl:if>
                    <xsl:if test="(request-param[@name='mailingDocumentType'] != '')">
                        <xsl:element name="document_type_rd">					
                            <xsl:value-of select="request-param[@name='mailingDocumentType']"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="(request-param[@name='mailingDocumentType'] = '')">
                        <xsl:element name="document_type_rd">BILL</xsl:element>		
                    </xsl:if>	
                    <xsl:element name="printer_destination_rd">
                        <xsl:value-of select="request-param[@name='mailingPrinterDestination']"/>
                    </xsl:element>							
                </xsl:element>
            </xsl:element>

            
            <!-- Create account-->            
            <xsl:element name="CcmFifCreateAccountCmd">
                <xsl:element name="command_id">create_account_1</xsl:element>
                <xsl:element name="CcmFifCreateAccountInCont">
                    <xsl:if test="request-param[@name='customerNumber'] != ''">	
                        <xsl:element name="customer_number">
                            <xsl:value-of select="request-param[@name='customerNumber']"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="request-param[@name='customerNumber'] = ''">					
                        <xsl:element name="customer_number_ref">
                            <xsl:element name="command_id">read_external_notification_1</xsl:element>
                            <xsl:element name="field_name">parameter_value</xsl:element>
                        </xsl:element>
                    </xsl:if>
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
                        <xsl:value-of select="request-param[@name='docTemplateName']"/>
                    </xsl:element>
                    <xsl:element name="method_of_payment">
                        <xsl:value-of select="request-param[@name='paymentMethod']"/>
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
                        <xsl:value-of select="request-param[@name='cycleName']"/>
                    </xsl:element>
                    <xsl:if test="(request-param[@name='paymentTerm'] != '')">
                        <xsl:element name="payment_term_rd">
                            <xsl:value-of select="request-param[@name='paymentTerm']"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="(request-param[@name='paymentTerm'] = '')">
                        <xsl:element name="payment_term_rd">14</xsl:element>
                    </xsl:if>
                    <xsl:element name="zero_charge_ind">
                        <xsl:value-of select="request-param[@name='zeroChargeInd']"/>
                    </xsl:element>
                    <xsl:if test="request-param[@name='usageLimit'] != ''">
                        <xsl:element name="usage_limit">
                            <xsl:value-of select="request-param[@name='usageLimit']"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="request-param[@name='usageLimit'] = ''">
                        <xsl:element name="usage_limit">99999999.99</xsl:element>
                    </xsl:if>
                    <xsl:element name="customer_account_id">
                        <xsl:value-of select="request-param[@name='customerAccountId']"/>
                    </xsl:element>
                    <xsl:element name="output_device_rd">
                        <xsl:value-of select="request-param[@name='accountOutputDevice']"/>
                    </xsl:element>
                    <xsl:element name="direct_debit_authoriz_date">
                        <xsl:value-of select="request-param[@name='directDebitAuthorizDate']"/>
                    </xsl:element>
                    <xsl:element name="activate_account_indicator">Y</xsl:element>	 
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
                        <xsl:if test="//request-param[@name='customerNumber'] != ''">	
                            <xsl:element name="customer_number">
                                <xsl:value-of select="//request-param[@name='customerNumber']"/>
                            </xsl:element>
                        </xsl:if>
                        <xsl:if test="//request-param[@name='customerNumber'] = ''">					
                            <xsl:element name="customer_number_ref">
                                <xsl:element name="command_id">read_external_notification_1</xsl:element>
                                <xsl:element name="field_name">parameter_value</xsl:element>
                            </xsl:element>
                        </xsl:if>				
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
                            <xsl:value-of select="//request-param[@name='cycleName']"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>


            <!-- get account data to retrieve cycle name -->
            <xsl:element name="CcmFifGetAccountDataCmd">
                <xsl:element name="command_id">get_account_for_cycle</xsl:element>
                <xsl:element name="CcmFifGetAccountDataInCont">
                    <xsl:element name="account_number_ref">
                        <xsl:element name="command_id">create_account_1</xsl:element>
                        <xsl:element name="field_name">account_number</xsl:element>
                    </xsl:element>
                    <xsl:element name="effective_date">
                        <xsl:value-of select="dateutils:getCurrentDate()"/>
                    </xsl:element>
                </xsl:element>    
            </xsl:element>
            
            <!-- get cycle due date, if it will be used -->      
            <xsl:element name="CcmFifGetCycleCmd">
                <xsl:element name="command_id">get_cycle</xsl:element>
                <xsl:element name="CcmFifGetCycleInCont">
                    <xsl:element name="cycle_name_ref">
                        <xsl:element name="command_id">get_account_for_cycle</xsl:element>
                        <xsl:element name="field_name">cycle_name</xsl:element>
                    </xsl:element>
                </xsl:element>    
            </xsl:element>
        
            <!-- Create Contact  -->
            <xsl:element name="CcmFifCreateContactCmd">
                <xsl:element name="CcmFifCreateContactInCont">
                    <xsl:if test="request-param[@name='customerNumber'] != ''">	
                        <xsl:element name="customer_number">
                            <xsl:value-of select="request-param[@name='customerNumber']"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="request-param[@name='customerNumber'] = ''">					
                        <xsl:element name="customer_number_ref">
                            <xsl:element name="command_id">read_external_notification_1</xsl:element>
                            <xsl:element name="field_name">parameter_value</xsl:element>
                        </xsl:element>
                    </xsl:if>
                    <xsl:element name="contact_type_rd">ADR</xsl:element>
                    <xsl:element name="short_description">Änderung Rechnungsadresse</xsl:element>
                    <xsl:element name="description_text_list">
                        <xsl:element name="CcmFifPassingValueCont">
                            <xsl:element name="contact_text">
                                <xsl:text>TransactionID: </xsl:text>
                                <xsl:value-of select="request-param[@name='transactionID']"/>
                                <xsl:text>&#xA;AccountNumber: </xsl:text>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifCommandRefCont">
                            <xsl:element name="command_id">create_account_1</xsl:element>
                            <xsl:element name="field_name">account_number</xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifPassingValueCont">
                            <xsl:element name="contact_text">
                                <xsl:text>&#xA;AddressId: </xsl:text>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifCommandRefCont">
                            <xsl:element name="command_id">create_address_1</xsl:element>
                            <xsl:element name="field_name">address_id</xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifPassingValueCont">
                            <xsl:element name="contact_text">                                 
                                <xsl:text>&#xA;UserName: </xsl:text>
                                <xsl:if test="request-param[@name='userName'] != ''">
                                    <xsl:value-of select="request-param[@name='userName']"/>
                                </xsl:if>
                                <xsl:if test="request-param[@name='userName'] = ''">
                                    <xsl:value-of select="request-param[@name='clientName']"/>
                                </xsl:if> 
                            </xsl:element>
                        </xsl:element>
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
                        <xsl:element name="notification_action_name">CreateAdditionalAccount</xsl:element>
                        <xsl:element name="target_system">FIF</xsl:element>
                        <xsl:element name="parameter_value_list">											
                            <xsl:if test="request-param[@name='somElementID'] != ''">
                                <xsl:element name="CcmFifParameterValueCont">                            
                                    <xsl:element name="parameter_name">
                                        <xsl:value-of select="request-param[@name='somElementID']"/>
                                        <xsl:text>_ACCOUNT_NUMBER</xsl:text>
                                    </xsl:element>
                                    <xsl:element name="parameter_value_ref">
                                        <xsl:element name="command_id">create_account_1</xsl:element>
                                        <xsl:element name="field_name">account_number</xsl:element>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>
                            <xsl:element name="CcmFifParameterValueCont">                            
                                <xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
                                <xsl:element name="parameter_value_ref">
                                    <xsl:element name="command_id">create_account_1</xsl:element>
                                    <xsl:element name="field_name">account_number</xsl:element>
                                </xsl:element>
                            </xsl:element>
                            <xsl:if test="request-param[@name='somElementID'] != ''">
                                <xsl:element name="CcmFifParameterValueCont">                            
                                    <xsl:element name="parameter_name">
                                        <xsl:value-of select="request-param[@name='somElementID']"/>
                                        <xsl:text>_SEPA_FUNCTIONAL_ERROR</xsl:text>
                                    </xsl:element>
                                    <xsl:element name="parameter_value_ref">
                                        <xsl:element name="command_id">create_bank_account_1</xsl:element>
                                        <xsl:element name="field_name">sepa_functional_error_occured</xsl:element>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>
                            <xsl:element name="CcmFifParameterValueCont">                            
                                <xsl:element name="parameter_name">SEPA_FUNCTIONAL_ERROR</xsl:element>
                                <xsl:element name="parameter_value_ref">
                                    <xsl:element name="command_id">create_bank_account_1</xsl:element>
                                    <xsl:element name="field_name">sepa_functional_error_occured</xsl:element>
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            
            
        <!-- Create KBA notification  -->
            <xsl:element name="CcmFifCreateExternalNotificationCmd">
                <xsl:element name="command_id">create_ext_notification_2</xsl:element>
                <xsl:element name="CcmFifCreateExternalNotificationInCont">
                    <xsl:element name="notification_action_name">createKBANotification</xsl:element>
                    <xsl:element name="target_system">KBA</xsl:element>
                    <xsl:element name="parameter_value_list">
                        
                        <xsl:element name="CcmFifParameterValueCont">                            
                            <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                            <xsl:choose>
                                <xsl:when test="request-param[@name='customerNumber'] = ''">
                                    <xsl:element name="parameter_value_ref">
                                        <xsl:element name="command_id">read_external_notification_1</xsl:element>
                                        <xsl:element name="field_name">parameter_value</xsl:element>
                                    </xsl:element>        
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:element name="parameter_value">
                                       <xsl:value-of select="request-param[@name='customerNumber']"/>
                                    </xsl:element>
                                </xsl:otherwise>
                            </xsl:choose>                            
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
