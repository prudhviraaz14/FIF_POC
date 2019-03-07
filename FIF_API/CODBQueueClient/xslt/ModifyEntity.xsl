<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for modifying entities and related objects
  @author schwarje
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
      <xsl:variable name="tomorrow" select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>

      <xsl:variable name="minimumDesiredDate">
        <xsl:choose>
          <xsl:when test="request-param[@name='minimumDesiredDate'] = 'today'">
            <xsl:value-of select="$today"/>
          </xsl:when>
          <xsl:when test="request-param[@name='minimumDesiredDate'] = 'tomorrow'">
            <xsl:value-of select="$tomorrow"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="desiredDateHelper">
        <xsl:choose>
          <xsl:when test="request-param[@name='desiredDate'] = 'today'
            or request-param[@name='desiredDate'] = ''">
            <xsl:value-of select="$today"/>
          </xsl:when>
          <xsl:when test="request-param[@name='desiredDate'] = 'tomorrow'">
            <xsl:value-of select="$tomorrow"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="desiredDate">
        <xsl:choose>
          <xsl:when test="dateutils:compareString($desiredDateHelper, $minimumDesiredDate) = '1'">
            <xsl:value-of select="$desiredDateHelper"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$minimumDesiredDate"/>
          </xsl:otherwise>
        </xsl:choose>        
      </xsl:variable>
      
      <xsl:variable name="mobileNumber">
        <xsl:choose>
          <xsl:when test="starts-with(request-param[@name='mobileNumber'], '0049')">
            <xsl:text>0</xsl:text>
            <xsl:value-of select="substring-after(request-param[@name='mobileNumber'], '0049')"/>
          </xsl:when>
          <xsl:when test="starts-with(request-param[@name='mobileNumber'], '+49')">
            <xsl:text>0</xsl:text>
            <xsl:value-of select="substring-after(request-param[@name='mobileNumber'], '+49')"/>
          </xsl:when>
          <xsl:when test="starts-with(request-param[@name='mobileNumber'], '49')">
            <xsl:text>0</xsl:text>
            <xsl:value-of select="substring-after(request-param[@name='mobileNumber'], '49')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='mobileNumber']"/>
          </xsl:otherwise>
        </xsl:choose>        
      </xsl:variable>
      
      <xsl:if test="
        request-param[@name='relatedObjectId'] = '' and 
        request-param[@name='relatedObjectType'] != 'ACCOUNT'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">raiseError_relatedObjectId</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">
              <xsl:text>Die folgende Kombination ist nicht erlaubt: relatedObjectType = </xsl:text>
              <xsl:value-of select="request-param[@name='relatedObjectType']"/>
              <xsl:text>, relatedObjectId = </xsl:text>
              <xsl:value-of select="request-param[@name='relatedObjectId']"/>
              <xsl:text>, entityChangeType = </xsl:text>
              <xsl:value-of select="request-param[@name='entityChangeType']"/>
              <xsl:text>, addressChangeType = </xsl:text>
              <xsl:value-of select="request-param[@name='addressChangeType']"/>
              <xsl:text>, accessInformationChangeType = </xsl:text>
              <xsl:value-of select="request-param[@name='accessInformationChangeType']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>        
      </xsl:if>
      
      <xsl:if test="request-param[@name='relatedObjectType'] = 'CONTACT_ROLE'">
      <xsl:choose>
        <xsl:when test="request-param[@name='entityChangeType'] = 'ADD' or 
          request-param[@name='entityChangeType'] = 'CHANGE'">
          <!-- Change Contact Role-->
          <xsl:element name="CcmFifChangeContactRoleCmd">
            <xsl:element name="command_id">create_contact_role</xsl:element>
            <xsl:element name="CcmFifChangeContactRoleInCont">
              <xsl:element name="contact_role_id">
                <xsl:value-of select="request-param[@name='relatedObjectId']"/>
              </xsl:element>
              <xsl:element name="salutation_description">
                <xsl:value-of select="request-param[@name='salutationDescription']"/>
              </xsl:element>
              <xsl:element name="title_description">
                <xsl:value-of select="request-param[@name='titleDescription']"/>
                <xsl:if test="request-param[@name='titleDescription'] = ''">**NULL**</xsl:if>
              </xsl:element>
              <xsl:element name="nobility_prefix_description">
                <xsl:value-of select="request-param[@name='nobilityPrefixDescription']"/>
                <xsl:if test="request-param[@name='nobilityPrefixDescription'] = ''">**NULL**</xsl:if>
              </xsl:element>					
              <xsl:element name="forename">
                <xsl:value-of select="request-param[@name='forename']"/>
                <xsl:if test="request-param[@name='forename'] = ''">**NULL**</xsl:if>
              </xsl:element>
              <xsl:element name="surname_prefix_description">
                <xsl:value-of select="request-param[@name='surnamePrefix']"/>
                <xsl:if test="request-param[@name='surnamePrefix'] = ''">**NULL**</xsl:if>
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
                <xsl:if test="request-param[@name='organizationSuffixName'] = ''">**NULL**</xsl:if>
              </xsl:element>
              <xsl:element name="incorporation_number_id">
                <xsl:value-of select="request-param[@name='incorporationNumber']"/>
                <xsl:if test="request-param[@name='incorporationNumber'] = ''">**NULL**</xsl:if>
              </xsl:element>	
              <xsl:element name="incorporation_type_rd">
                <xsl:value-of select="request-param[@name='incorporationType']"/>
                <xsl:if test="request-param[@name='incorporationType'] = ''">**NULL**</xsl:if>
              </xsl:element>	
              <xsl:element name="incorporation_city_name">
                <xsl:value-of select="request-param[@name='incorporationCityName']"/>
                <xsl:if test="request-param[@name='incorporationCityName'] = ''">**NULL**</xsl:if>
              </xsl:element>					
              <xsl:element name="address_type">
                <xsl:value-of select="request-param[@name='addressType']"/>
              </xsl:element>
              <xsl:element name="street_name">
                <xsl:value-of select="request-param[@name='streetName']"/>
                <xsl:if test="request-param[@name='streetName'] = ''">**NULL**</xsl:if>
              </xsl:element>
              <xsl:element name="street_number">
                <xsl:value-of select="request-param[@name='streetNumber']"/>
                <xsl:if test="request-param[@name='streetNumber'] = ''">**NULL**</xsl:if>
              </xsl:element>
              <xsl:element name="street_number_suffix">
                <xsl:value-of select="request-param[@name='numberSuffix']"/>			
                <xsl:if test="request-param[@name='numberSuffix'] = ''">**NULL**</xsl:if>				
              </xsl:element>
              <xsl:element name="post_office_box">
                <xsl:value-of select="request-param[@name='postOfficeBox']"/>
                <xsl:if test="request-param[@name='postOfficeBox'] = ''">**NULL**</xsl:if>
              </xsl:element>
              <xsl:element name="postal_code">
                <xsl:value-of select="request-param[@name='postalCode']"/>               
              </xsl:element>
              <xsl:element name="city_name">
                <xsl:value-of select="request-param[@name='cityName']"/>
              </xsl:element>
              <xsl:element name="city_suffix_name">
                <xsl:value-of select="request-param[@name='citySuffix']"/>
                <xsl:if test="request-param[@name='citySuffix'] = ''">**NULL**</xsl:if>
              </xsl:element>
	      <xsl:if test="request-param[@name='countryCode'] != ''">
              <xsl:element name="country_code">
                <xsl:value-of select="request-param[@name='countryCode']"/>
              </xsl:element>
	      </xsl:if>
	      <xsl:if test="request-param[@name='countryCode'] = ''">
	         <xsl:element name="country_code">DE</xsl:element>
	      </xsl:if>
              <xsl:element name="phone_number">
                <xsl:value-of select="request-param[@name='phoneNumber']"/>
                <xsl:if test="request-param[@name='phoneNumber'] = ''">**NULL**</xsl:if>
              </xsl:element>
              <xsl:element name="fax_number">
                <xsl:value-of select="request-param[@name='faxNumber']"/>
                <xsl:if test="request-param[@name='faxNumber'] = ''">**NULL**</xsl:if>
              </xsl:element>
              <xsl:element name="mobile_number">
                <xsl:value-of select="$mobileNumber"/>
                <xsl:if test="$mobileNumber = ''">**NULL**</xsl:if>
              </xsl:element>
              <xsl:element name="email_address">
                <xsl:value-of select="request-param[@name='emailAddress']"/>
                <xsl:if test="request-param[@name='emailAddress'] = ''">**NULL**</xsl:if>
              </xsl:element>
              <xsl:element name="access_information_type_rd">
                <xsl:value-of select="request-param[@name='accessInformationTyp']"/>							
              </xsl:element>
              <xsl:element name="electronic_contact_indicator">
                <xsl:value-of select="request-param[@name='electronicContactIndicator']"/>
              </xsl:element>
              <xsl:element name="contact_name">
                <xsl:value-of select="request-param[@name='contactName']"/>		
              </xsl:element>
              <xsl:element name="is_legacy_contact_role">
                <xsl:value-of select="request-param[@name='isLegacyContactRole']"/>
              </xsl:element>              
            </xsl:element>
          </xsl:element>        
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">illegal_parameter_combination</xsl:element>
            <xsl:element name="CcmFifRaiseErrorInCont">
              <xsl:element name="error_text">
                <xsl:text>Die folgende Kombination ist nicht erlaubt: relatedObjectType = </xsl:text>
                <xsl:value-of select="request-param[@name='relatedObjectType']"/>
                <xsl:text>, entityChangeType = </xsl:text>
                <xsl:value-of select="request-param[@name='entityChangeType']"/>
                <xsl:text>, addressChangeType = </xsl:text>
                <xsl:value-of select="request-param[@name='addressChangeType']"/>
                <xsl:text>, accessInformationChangeType = </xsl:text>
                <xsl:value-of select="request-param[@name='accessInformationChangeType']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>          
        </xsl:otherwise>        
      </xsl:choose>
      </xsl:if>
      
      <xsl:if test="request-param[@name='relatedObjectType'] = 'ACCOUNT'">        
        
        <xsl:if test="request-param[@name='relatedObjectId'] = ''">
          <xsl:element name="CcmFifReadExternalNotificationCmd">
            <xsl:element name="command_id">read_account_number</xsl:element>
            <xsl:element name="CcmFifReadExternalNotificationInCont">
              <xsl:element name="transaction_id">
                <xsl:value-of select="request-param[@name='requestListId']"/>
              </xsl:element>
              <xsl:element name="parameter_name">
                <xsl:text>ACCOUNT_NUMBER</xsl:text>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>
        
        <xsl:choose>
          <xsl:when test="
            (request-param[@name='addressChangeType'] = 'INVALIDATE' 
             or request-param[@name='addressChangeType'] = 'VALIDATE')
            and request-param[@name='entityChangeType'] = 'IGNORE'
            and request-param[@name='accessInformationChangeType'] = 'IGNORE'">                        
            <xsl:element name="CcmFifGetAccountDataCmd">
              <xsl:element name="command_id">get_account_data</xsl:element>
              <xsl:element name="CcmFifGetAccountDataInCont">
                <xsl:choose>
                  <xsl:when test="request-param[@name='relatedObjectId'] != ''">
                    <xsl:element name="account_number">
                      <xsl:value-of select="request-param[@name='relatedObjectId']"/>
                    </xsl:element>                    
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:element name="account_number_ref">
                      <xsl:element name="command_id">read_account_number</xsl:element>
                      <xsl:element name="field_name">parameter_value</xsl:element>
                    </xsl:element>                    
                  </xsl:otherwise>  
                </xsl:choose>                
                <xsl:element name="effective_date">
                  <xsl:value-of select="$desiredDate"/>
                </xsl:element>
              </xsl:element>    
            </xsl:element>        

            <xsl:element name="CcmFifGetDocumentRecipientInfoCmd">
              <xsl:element name="command_id">get_document_recipient</xsl:element>
              <xsl:element name="CcmFifGetDocumentRecipientInfoInCont">
                <xsl:element name="customer_number_ref">
                  <xsl:element name="command_id">get_account_data</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
                </xsl:element>
                <xsl:choose>
                  <xsl:when test="request-param[@name='relatedObjectId'] != ''">
                    <xsl:element name="account_number">
                      <xsl:value-of select="request-param[@name='relatedObjectId']"/>
                    </xsl:element>                    
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:element name="account_number_ref">
                      <xsl:element name="command_id">read_account_number</xsl:element>
                      <xsl:element name="field_name">parameter_value</xsl:element>
                    </xsl:element>                    
                  </xsl:otherwise>  
                </xsl:choose>                
              </xsl:element>
            </xsl:element>
                        
            <xsl:element name="CcmFifInvalidateAddressCmd">
              <xsl:element name="command_id">invalidate_address</xsl:element>
              <xsl:element name="CcmFifInvalidateAddressInCont">
                <xsl:element name="customer_number_ref">
                  <xsl:element name="command_id">get_account_data</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
                </xsl:element>
                <xsl:element name="address_ref">
                  <xsl:element name="command_id">get_document_recipient</xsl:element>
                  <xsl:element name="field_name">address_id</xsl:element>
                </xsl:element>
                <xsl:element name="mailing_id_ref">
                  <xsl:element name="command_id">get_account_data</xsl:element>
                  <xsl:element name="field_name">mailing_id</xsl:element>
                </xsl:element>
                <xsl:element name="action_type">
                  <xsl:value-of select="request-param[@name='addressChangeType']"/>
                </xsl:element>
                <xsl:element name="check_printer_dest_rd">Y</xsl:element>                
              </xsl:element>
            </xsl:element>                  
          </xsl:when>
          <xsl:when test="request-param[@name='entityChangeType'] = 'ADD' or request-param[@name='entityChangeType'] = 'CHANGE'">
            <xsl:element name="CcmFifGetAccountDataCmd">
              <xsl:element name="command_id">get_account_data</xsl:element>
              <xsl:element name="CcmFifGetAccountDataInCont">
                <xsl:choose>
                  <xsl:when test="request-param[@name='relatedObjectId'] != ''">
                    <xsl:element name="account_number">
                      <xsl:value-of select="request-param[@name='relatedObjectId']"/>
                    </xsl:element>                    
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:element name="account_number_ref">
                      <xsl:element name="command_id">read_account_number</xsl:element>
                      <xsl:element name="field_name">parameter_value</xsl:element>
                    </xsl:element>                    
                  </xsl:otherwise>  
                </xsl:choose>                
                <xsl:element name="effective_date">
                  <xsl:value-of select="$desiredDate"/>
                </xsl:element>
              </xsl:element>    
            </xsl:element>        
            
            <xsl:element name="CcmFifGetDocumentRecipientInfoCmd">
              <xsl:element name="command_id">get_document_recipient</xsl:element>
              <xsl:element name="CcmFifGetDocumentRecipientInfoInCont">
                <xsl:element name="customer_number_ref">
                  <xsl:element name="command_id">get_account_data</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
                </xsl:element>
                <xsl:choose>
                  <xsl:when test="request-param[@name='relatedObjectId'] != ''">
                    <xsl:element name="account_number">
                      <xsl:value-of select="request-param[@name='relatedObjectId']"/>
                    </xsl:element>                    
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:element name="account_number_ref">
                      <xsl:element name="command_id">read_account_number</xsl:element>
                      <xsl:element name="field_name">parameter_value</xsl:element>
                    </xsl:element>                    
                  </xsl:otherwise>  
                </xsl:choose>                
              </xsl:element>
            </xsl:element>
            
            <xsl:element name="CcmFifCreateEntityCmd">
              <xsl:element name="command_id">create_entity</xsl:element>
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
            
            <!-- Create Address -->
            <xsl:element name="CcmFifCreateAddressCmd">
              <xsl:element name="command_id">create_address</xsl:element>
              <xsl:element name="CcmFifCreateAddressInCont">
                <xsl:element name="entity_ref">
                  <xsl:element name="command_id">create_entity</xsl:element>
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
                <xsl:if test="request-param[@name='countryCode'] != ''">
                <xsl:element name="country_code">
                  <xsl:value-of select="request-param[@name='countryCode']"/>
                </xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='countryCode'] = ''">
		<xsl:element name="country_code">DE</xsl:element>
		</xsl:if>
                <xsl:element name="set_primary_address">Y</xsl:element>
                <xsl:if test="request-param[@name='validationTypeRd'] != ''">
                  <xsl:element name="validation_type_rd">
                    <xsl:value-of select="request-param[@name='validationTypeRd']"/>
                  </xsl:element>
                </xsl:if>
              </xsl:element>
            </xsl:element>
            
            <xsl:element name="CcmFifUpdateAccessInformCmd">
              <xsl:element name="command_id">create_access_information</xsl:element>
              <xsl:element name="CcmFifUpdateAccessInformInCont">
                <xsl:element name="entity_ref">
                  <xsl:element name="command_id">create_entity</xsl:element>
                  <xsl:element name="field_name">entity_id</xsl:element>
                </xsl:element>              
                <xsl:element name="effective_date">
                  <xsl:value-of select="$desiredDate"/>
                </xsl:element>
                <xsl:element name="access_information_type_rd">
                  <xsl:value-of select="request-param[@name='accessInformationTyp']"/>
                </xsl:element>
                <xsl:element name="contact_name">
                  <xsl:choose>
                    <xsl:when test="request-param[@name='contactName'] != ''">
                      <xsl:value-of select="request-param[@name='contactName']"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="request-param[@name='name']"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:element>
                <xsl:element name="phone_number">
                  <xsl:value-of select="request-param[@name='phoneNumber']"/>
                  <xsl:if test="request-param[@name='phoneNumber'] = ''">**NULL**</xsl:if>
                </xsl:element>
                <xsl:element name="mobile_number">
                  <xsl:value-of select="$mobileNumber"/>
                  <xsl:if test="$mobileNumber = ''">**NULL**</xsl:if>
                </xsl:element>
                <xsl:element name="fax_number">
                  <xsl:value-of select="request-param[@name='faxNumber']"/>
                  <xsl:if test="request-param[@name='faxNumber'] = ''">**NULL**</xsl:if>
                </xsl:element>
                <xsl:element name="email_address">
                  <xsl:value-of select="request-param[@name='emailAddress']"/>
                  <xsl:if test="request-param[@name='emailAddress'] = ''">**NULL**</xsl:if>
                </xsl:element>
                <xsl:element name="email_validation_indicator">
                  <xsl:value-of select="request-param[@name='emailValidationIndicator']"/>
                </xsl:element>
                <xsl:element name="electronic_contact_indicator">
                  <xsl:value-of select="request-param[@name='electronicContactIndicator']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            
            <!-- Modify Document Recipient -->
            <xsl:element name="CcmFifModifyDocumentRecipientCmd">
              <xsl:element name="command_id">modify_document_recipient</xsl:element>
              <xsl:element name="CcmFifModifyDocumentRecipientInCont">
                <xsl:element name="document_recipient_ref">
                  <xsl:element name="command_id">get_document_recipient</xsl:element>
                  <xsl:element name="field_name">document_recipient_id</xsl:element>
                </xsl:element>
                <xsl:element name="effective_date">
                  <xsl:value-of select="$desiredDate"/>
                </xsl:element>
                <xsl:element name="entity_ref">
                  <xsl:element name="command_id">create_entity</xsl:element>
                  <xsl:element name="field_name">entity_id</xsl:element>
                </xsl:element>
                <xsl:element name="access_information_ref">
                  <xsl:element name="command_id">create_access_information</xsl:element>
                  <xsl:element name="field_name">access_information_id</xsl:element>
                </xsl:element>
                <xsl:element name="address_ref">
                  <xsl:element name="command_id">create_address</xsl:element>
                  <xsl:element name="field_name">address_id</xsl:element>
                </xsl:element>
                <xsl:element name="delete_future_dated_entries">
                  <xsl:value-of select="request-param[@name='deleteFutureDatedEntries']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="CcmFifRaiseErrorCmd">
              <xsl:element name="command_id">illegal_parameter_combination</xsl:element>
              <xsl:element name="CcmFifRaiseErrorInCont">
                <xsl:element name="error_text">
                  <xsl:text>Die folgende Kombination ist nicht erlaubt: relatedObjectType = </xsl:text>
                  <xsl:value-of select="request-param[@name='relatedObjectType']"/>
                  <xsl:text>, entityChangeType = </xsl:text>
                  <xsl:value-of select="request-param[@name='entityChangeType']"/>
                  <xsl:text>, addressChangeType = </xsl:text>
                  <xsl:value-of select="request-param[@name='addressChangeType']"/>
                  <xsl:text>, accessInformationChangeType = </xsl:text>
                  <xsl:value-of select="request-param[@name='accessInformationChangeType']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>            
          </xsl:otherwise>
        </xsl:choose>        
      </xsl:if>
      
      <xsl:if test="request-param[@name='relatedObjectType'] = 'CUSTOMER'">

        <xsl:if test="request-param[@name='addressChangeType'] = 'ADD' or
          request-param[@name='addressChangeType'] = 'CHANGE' or 
          request-param[@name='accessInformationChangeType'] = 'ADD' or
          request-param[@name='accessInformationChangeType'] = 'CHANGE'">
          <xsl:element name="CcmFifGetEntityCmd">
            <xsl:element name="command_id">get_entity</xsl:element>
            <xsl:element name="CcmFifGetEntityInCont">
              <xsl:element name="customer_number">
                <xsl:value-of select="request-param[@name='relatedObjectId']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element>          
        </xsl:if>
        <xsl:choose>
          <xsl:when test="request-param[@name='addressChangeType'] = 'CHANGE'">
            <xsl:element name="CcmFifModifyAddressCmd">
              <xsl:element name="command_id">modify_address</xsl:element>
              <xsl:element name="CcmFifModifyAddressInCont">
                <xsl:element name="customer_number">
                  <xsl:value-of select="request-param[@name='relatedObjectId']"/>
                </xsl:element>
                <xsl:element name="effective_date">
                  <xsl:value-of select="$desiredDate"/>
                </xsl:element>            
                <xsl:element name="address_ref">
                  <xsl:element name="command_id">get_entity</xsl:element>
                  <xsl:element name="field_name">primary_address_id</xsl:element>
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
                  <xsl:value-of select="request-param[@name='numberSuffix']"/>
                </xsl:element>
                <xsl:element name="post_office_box">
                  <xsl:value-of select="request-param[@name='postOfficeBox']"/>
                </xsl:element>                
                <xsl:element name="postal_code">
                  <xsl:value-of select="request-param[@name='postalCode']"/>
                </xsl:element>
                <xsl:element name="city_name">
                  <xsl:value-of select="request-param[@name='cityName']"/>
                </xsl:element>
                <xsl:if test="request-param[@name='countryCode'] != ''">
                <xsl:element name="country">
                  <xsl:value-of select="request-param[@name='countryCode']"/>
                </xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='countryCode'] = ''">
		  <xsl:element name="country">DE</xsl:element>
		</xsl:if>
                <xsl:element name="ignore_if_object_exists">N</xsl:element>
                <xsl:if test="request-param[@name='validationTypeRd'] != ''">
                  <xsl:element name="validation_type_rd">
                    <xsl:value-of select="request-param[@name='validationTypeRd']"/>
                  </xsl:element>
                </xsl:if>
                <xsl:element name="delete_future_dated_entries">
                  <xsl:value-of select="request-param[@name='deleteFutureDatedEntries']"/>
                </xsl:element>                
              </xsl:element>
            </xsl:element>
          </xsl:when>
          <xsl:when test="request-param[@name='addressChangeType'] = 'IGNORE'"/>
          <xsl:otherwise>
            <xsl:element name="CcmFifRaiseErrorCmd">
              <xsl:element name="command_id">illegal_parameter_combination</xsl:element>
              <xsl:element name="CcmFifRaiseErrorInCont">
                <xsl:element name="error_text">
                  <xsl:text>Die folgende Kombination ist nicht erlaubt: relatedObjectType = </xsl:text>
                  <xsl:value-of select="request-param[@name='relatedObjectType']"/>
                  <xsl:text>, entityChangeType = </xsl:text>
                  <xsl:value-of select="request-param[@name='entityChangeType']"/>
                  <xsl:text>, addressChangeType = </xsl:text>
                  <xsl:value-of select="request-param[@name='addressChangeType']"/>
                  <xsl:text>, accessInformationChangeType = </xsl:text>
                  <xsl:value-of select="request-param[@name='accessInformationChangeType']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
        
        <xsl:choose>
          <xsl:when test="request-param[@name='accessInformationChangeType'] = 'CHANGE'">
            <xsl:element name="CcmFifUpdateAccessInformCmd">
              <xsl:element name="command_id">update_acc_inf</xsl:element>
              <xsl:element name="CcmFifUpdateAccessInformInCont">
                <xsl:element name="entity_ref">
                  <xsl:element name="command_id">get_entity</xsl:element>
                  <xsl:element name="field_name">entity_id</xsl:element>
                </xsl:element>              
                <xsl:element name="access_information_ref">
                  <xsl:element name="command_id">get_entity</xsl:element>
                  <xsl:element name="field_name">primary_access_info_id</xsl:element>
                </xsl:element>              
                <xsl:element name="effective_date">
                  <xsl:value-of select="$desiredDate"/>
                </xsl:element>
                <xsl:element name="access_information_type_rd">
                  <xsl:value-of select="request-param[@name='accessInformationTyp']"/>
                </xsl:element>
                <xsl:element name="contact_name">
                  <xsl:value-of select="request-param[@name='contactName']"/>
                  <xsl:if test="request-param[@name='contactName'] = ''">**NULL**</xsl:if>
                </xsl:element>
                <xsl:element name="phone_number">
                  <xsl:value-of select="request-param[@name='phoneNumber']"/>
                  <xsl:if test="request-param[@name='phoneNumber'] = ''">**NULL**</xsl:if>
                </xsl:element>
                <xsl:element name="mobile_number">
                  <xsl:value-of select="$mobileNumber"/>
                  <xsl:if test="$mobileNumber = ''">**NULL**</xsl:if>
                </xsl:element>
                <xsl:element name="fax_number">
                  <xsl:value-of select="request-param[@name='faxNumber']"/>
                  <xsl:if test="request-param[@name='faxNumber'] = ''">**NULL**</xsl:if>
                </xsl:element>
                <xsl:element name="email_address">
                  <xsl:value-of select="request-param[@name='emailAddress']"/>
                  <xsl:if test="request-param[@name='emailAddress'] = ''">**NULL**</xsl:if>
                </xsl:element>
                <xsl:element name="email_validation_indicator">
                  <xsl:value-of select="request-param[@name='emailValidationIndicator']"/>
                </xsl:element>
                <xsl:element name="electronic_contact_indicator">
                  <xsl:value-of select="request-param[@name='electronicContactIndicator']"/>
                </xsl:element>
                <xsl:element name="ignore_if_object_exists">Y</xsl:element>
                <xsl:element name="delete_future_dated_entries">
                  <xsl:value-of select="request-param[@name='deleteFutureDatedEntries']"/>
                </xsl:element>                
              </xsl:element>
            </xsl:element>
          </xsl:when>
          <xsl:when test="request-param[@name='accessInformationChangeType'] = 'IGNORE'"/>
          <xsl:otherwise>
            <xsl:element name="CcmFifRaiseErrorCmd">
              <xsl:element name="command_id">illegal_parameter_combination</xsl:element>
              <xsl:element name="CcmFifRaiseErrorInCont">
                <xsl:element name="error_text">
                  <xsl:text>Die folgende Kombination ist nicht erlaubt: relatedObjectType = </xsl:text>
                  <xsl:value-of select="request-param[@name='relatedObjectType']"/>
                  <xsl:text>, entityChangeType = </xsl:text>
                  <xsl:value-of select="request-param[@name='entityChangeType']"/>
                  <xsl:text>, addressChangeType = </xsl:text>
                  <xsl:value-of select="request-param[@name='addressChangeType']"/>
                  <xsl:text>, accessInformationChangeType = </xsl:text>
                  <xsl:value-of select="request-param[@name='accessInformationChangeType']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
                
        <xsl:choose>
          <xsl:when test="request-param[@name='entityChangeType'] = 'CHANGE'">
            <!-- Change Customer Information -->      
            <xsl:element name="CcmFifModifyCustomerInfoCmd">
              <xsl:element name="command_id">modify_customer_info</xsl:element>
              <xsl:element name="CcmFifModifyCustomerInfoInCont">              
                <xsl:element name="customer_number">
                  <xsl:value-of select="request-param[@name='relatedObjectId']"/>
                </xsl:element>
                <xsl:element name="effective_date">
                  <xsl:value-of select="$desiredDate"/>
                </xsl:element>              
                <xsl:if test="request-param[@name='entityType'] = 'I'">
                  <xsl:element name="CcmFifIndividualCont">
                    <xsl:element name="ind_salutation_description">
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
                    <xsl:element name="individual_name">
                      <xsl:value-of select="request-param[@name='name']"/>
                    </xsl:element>
                    <xsl:element name="birth_date">
                      <xsl:value-of select="request-param[@name='birthDate']"/>
                    </xsl:element>
                    <xsl:element name="spoken_language_rd">
                      <xsl:value-of select="request-param[@name='spokenLanguageRd']"/>
                    </xsl:element>
                    <xsl:element name="marital_status_rd">
                      <xsl:value-of select="request-param[@name='maritalStatusRd']"/>
                    </xsl:element>
                    <xsl:element name="profession_name">
                      <xsl:value-of select="request-param[@name='professionName']"/>
                    </xsl:element>
                    <xsl:element name="id_card_number">
                      <xsl:value-of select="request-param[@name='idCardNumber']"/>
                    </xsl:element>
                    <xsl:element name="id_card_country_rd">
                      <xsl:value-of select="request-param[@name='idCardCountryRd']"/>
                    </xsl:element>
                    <xsl:element name="id_card_type_rd">
                      <xsl:value-of select="request-param[@name='idCardTypeRd']"/>
                    </xsl:element>
                    <xsl:element name="id_card_expiration_date">
                      <xsl:value-of select="request-param[@name='idCardExpirationDate']"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='entityType'] = 'O'">
                  <xsl:element name="CcmFifOrganizationCont">
                    <xsl:element name="org_salutation_description">
                      <xsl:value-of select="request-param[@name='salutationDescription']"/>
                    </xsl:element>
                    <xsl:element name="organization_name">
                      <xsl:value-of select="request-param[@name='name']"/>
                    </xsl:element>
                    <xsl:element name="organization_suffix_name">
                      <xsl:value-of select="request-param[@name='organizationSuffixName']"/>
                    </xsl:element>
                    <xsl:element name="organization_type_rd">
                      <xsl:value-of select="request-param[@name='organizationType']"/>
                    </xsl:element>
                    <xsl:element name="industrial_sector_rd">
                      <xsl:value-of select="request-param[@name='industrialSectorRd']"/>
                    </xsl:element>
                    <xsl:element name="domestic_organization_ind">
                      <xsl:value-of select="request-param[@name='domesticOrganizationInd']"/>
                    </xsl:element>
                    <xsl:element name="incorporation_number_id">
                      <xsl:value-of select="request-param[@name='incorporationNumber']"/>
                    </xsl:element>
                    <xsl:element name="incorporation_city_name">
                      <xsl:value-of select="request-param[@name='incorporationCityName']"/>
                    </xsl:element>
                    <xsl:element name="incorporation_type_rd">
                      <xsl:value-of select="request-param[@name='incorporationType']"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:if>
              </xsl:element>
            </xsl:element>
          </xsl:when>
          <xsl:when test="request-param[@name='entityChangeType'] = 'IGNORE'"/>
          <xsl:otherwise>
            <xsl:element name="CcmFifRaiseErrorCmd">
              <xsl:element name="command_id">illegal_parameter_combination</xsl:element>
              <xsl:element name="CcmFifRaiseErrorInCont">
                <xsl:element name="error_text">
                  <xsl:text>Die folgende Kombination ist nicht erlaubt: relatedObjectType = </xsl:text>
                  <xsl:value-of select="request-param[@name='relatedObjectType']"/>
                  <xsl:text>, entityChangeType = </xsl:text>
                  <xsl:value-of select="request-param[@name='entityChangeType']"/>
                  <xsl:text>, addressChangeType = </xsl:text>
                  <xsl:value-of select="request-param[@name='addressChangeType']"/>
                  <xsl:text>, accessInformationChangeType = </xsl:text>
                  <xsl:value-of select="request-param[@name='accessInformationChangeType']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>


      <xsl:if test="request-param[@name='relatedObjectType'] = 'ACCESS'">        
        <xsl:choose>
          <xsl:when test="request-param[@name='addressChangeType'] = 'CHANGE'">
            
            <xsl:element name="CcmFifFindServiceSubsCmd">
              <xsl:element name="command_id">find_main_service</xsl:element>
              <xsl:element name="CcmFifFindServiceSubsInCont">
                <xsl:element name="service_subscription_id">
                  <xsl:value-of select="request-param[@name='relatedObjectId']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            
            <xsl:element name="CcmFifFindServiceTicketPositionCmd">
              <xsl:element name="command_id">find_main_access_stp</xsl:element>
              <xsl:element name="CcmFifFindServiceTicketPositionInCont">
                <xsl:element name="service_subscription_id">
                  <xsl:value-of select="request-param[@name='relatedObjectId']"/>
                </xsl:element>
                <xsl:element name="find_stp_parameters">
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="usage_mode_value_rd">2</xsl:element>
                    <xsl:element name="customer_order_state">RELEASED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="usage_mode_value_rd">2</xsl:element>
                    <xsl:element name="customer_order_state">FINAL</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="customer_order_state">RELEASED</xsl:element>
                  </xsl:element>
                  <xsl:element name="CcmFifFindStpParameterCont">
                    <xsl:element name="usage_mode_value_rd">1</xsl:element>
                    <xsl:element name="customer_order_state">FINAL</xsl:element>
                  </xsl:element>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            
            <!-- find address CSC for location address -->
            <xsl:element name="CcmFifFindServCharValueForServCharCmd">
              <xsl:element name="command_id">find_location_address</xsl:element>
              <xsl:element name="CcmFifFindServCharValueForServCharInCont">
                <xsl:element name="service_ticket_position_id_ref">
                  <xsl:element name="command_id">find_main_access_stp</xsl:element>
                  <xsl:element name="field_name">service_ticket_position_id</xsl:element>
                </xsl:element>
                <xsl:element name="service_char_code">V0014</xsl:element>
                <xsl:element name="retrieve_all_characteristics">Y</xsl:element>                
              </xsl:element>
            </xsl:element>							
            
            <!-- change it -->
            <xsl:element name="CcmFifModifyAddressCmd">
              <xsl:element name="command_id">modify_location_address</xsl:element>
              <xsl:element name="CcmFifModifyAddressInCont">                
                <xsl:element name="customer_number_ref">
                  <xsl:element name="command_id">find_main_service</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
                </xsl:element>
                <xsl:element name="effective_date">
                  <xsl:value-of select="$desiredDate"/>
                </xsl:element>                
                <xsl:element name="address_ref">
                  <xsl:element name="command_id">find_location_address</xsl:element>
                  <xsl:element name="field_name">address_id</xsl:element>
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
                  <xsl:value-of select="request-param[@name='numberSuffix']"/>
                </xsl:element>
                <xsl:element name="post_office_box">
                  <xsl:value-of select="request-param[@name='postOfficeBox']"/>
                </xsl:element>
                <xsl:element name="postal_code">
                  <xsl:value-of select="request-param[@name='postalCode']"/>
                </xsl:element>
                <xsl:element name="city_name">
                  <xsl:value-of select="request-param[@name='cityName']"/>
                </xsl:element>
                <xsl:if test="request-param[@name='countryCode'] != ''">
                <xsl:element name="country">
                  <xsl:value-of select="request-param[@name='countryCode']"/>
                </xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='countryCode'] = ''">
		  <xsl:element name="country">DE</xsl:element>
		</xsl:if>
                <xsl:element name="ignore_if_object_exists">Y</xsl:element>
                <xsl:if test="request-param[@name='validationTypeRd'] != ''">
                  <xsl:element name="validation_type_rd">
                    <xsl:value-of select="request-param[@name='validationTypeRd']"/>
                  </xsl:element>
                </xsl:if>
                <xsl:element name="delete_future_dated_entries">
                  <xsl:value-of select="request-param[@name='deleteFutureDatedEntries']"/>
                </xsl:element>                
              </xsl:element>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="CcmFifRaiseErrorCmd">
              <xsl:element name="command_id">illegal_parameter_combination</xsl:element>
              <xsl:element name="CcmFifRaiseErrorInCont">
                <xsl:element name="error_text">
                  <xsl:text>Die folgende Kombination ist nicht erlaubt: relatedObjectType = </xsl:text>
                  <xsl:value-of select="request-param[@name='relatedObjectType']"/>
                  <xsl:text>, entityChangeType = </xsl:text>
                  <xsl:value-of select="request-param[@name='entityChangeType']"/>
                  <xsl:text>, addressChangeType = </xsl:text>
                  <xsl:value-of select="request-param[@name='addressChangeType']"/>
                  <xsl:text>, accessInformationChangeType = </xsl:text>
                  <xsl:value-of select="request-param[@name='accessInformationChangeType']"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>            
          </xsl:otherwise>
        </xsl:choose>        
      </xsl:if>
      

      <xsl:if test="request-param[@name='relatedObjectType'] != 'CUSTOMER' and
        request-param[@name='relatedObjectType'] != 'ACCOUNT' and
        request-param[@name='relatedObjectType'] != 'CONTACT_ROLE' and 
        request-param[@name='relatedObjectType'] != 'ACCESS'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">illegal_parameter_combination</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">
              <xsl:text>Die folgende Kombination ist nicht erlaubt: relatedObjectType = </xsl:text>
              <xsl:value-of select="request-param[@name='relatedObjectType']"/>
              <xsl:text>, entityChangeType = </xsl:text>
              <xsl:value-of select="request-param[@name='entityChangeType']"/>
              <xsl:text>, addressChangeType = </xsl:text>
              <xsl:value-of select="request-param[@name='addressChangeType']"/>
              <xsl:text>, accessInformationChangeType = </xsl:text>
              <xsl:value-of select="request-param[@name='accessInformationChangeType']"/>
            </xsl:element>
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
        
      <xsl:if test="request-param[@name='createContact'] = 'Y'
        and request-param[@name='relatedObjectType'] != 'CONTACT_ROLE'">
        <xsl:element name="CcmFifCreateContactCmd">
            <xsl:element name="CcmFifCreateContactInCont">
                <xsl:if test="request-param[@name='relatedObjectType'] = 'ACCESS'">        
                   <xsl:element name="customer_number_ref">
                       <xsl:element name="command_id">find_main_service</xsl:element>
                       <xsl:element name="field_name">customer_number</xsl:element>
                   </xsl:element>
                </xsl:if> 
                <xsl:if test="request-param[@name='relatedObjectType'] = 'ACCOUNT'">        
                   <xsl:element name="customer_number_ref">
                       <xsl:element name="command_id">get_account_data</xsl:element>
                       <xsl:element name="field_name">customer_number</xsl:element>
                   </xsl:element>
                </xsl:if> 
                <xsl:if test="request-param[@name='relatedObjectType'] = 'CUSTOMER'">        
                   <xsl:element name="customer_number">
                     <xsl:value-of select="request-param[@name='relatedObjectId']"/>
                   </xsl:element>
                </xsl:if> 
                <xsl:element name="contact_type_rd">
                    <xsl:value-of select="request-param[@name='contactType']"/>
                </xsl:element>
                <xsl:element name="short_description">
                    <xsl:value-of select="request-param[@name='shortDescription']"/>
                </xsl:element>
                <xsl:element name="long_description_text">
                    <xsl:value-of select="request-param[@name='longDescription']"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>	
      </xsl:if>
      
    </xsl:element>
    
  </xsl:template>
</xsl:stylesheet>
