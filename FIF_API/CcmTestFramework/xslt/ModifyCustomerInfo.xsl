<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for updating customer information
exclude-result-prefixes="dateutils" 
  @author makuier
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
	  <xsl:variable name="riskCategory">
    	<xsl:choose>
    	<xsl:when test="request-param[@name='riskCategory'] != ''">
    	   <xsl:value-of select="request-param[@name='riskCategory']"/>
    	</xsl:when>
    	<xsl:otherwise>
    		<xsl:value-of select="request-param[@name='riskCategoryRd']"/>
    	</xsl:otherwise>
    	</xsl:choose>
      </xsl:variable>
      
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
        <xsl:if test="request-param[@name='marketingAuthorizationDate'] = '' and 
          (request-param[@name='marketingPhoneIndicator'] != '' 
          or request-param[@name='marketingMailIndicator'] != ''
          or request-param[@name='marketingFaxIndicator'] != ''
          or request-param[@name='marketingCoopIndicator'] != ''
          or request-param[@name='marketingUseDataIndicator'] != ''
          or request-param[@name='personalDataIndicator'] != ''
          or request-param[@name='customerDataIndicator'] != '')">
          <xsl:value-of select="dateutils:getCurrentDate()"/>
        </xsl:if>
      </xsl:variable>      


      <!-- lock customer to avoid concurrency problems -->
      <xsl:element name="CcmFifLockObjectCmd">
        <xsl:element name="CcmFifLockObjectInCont">
          <xsl:element name="object_id">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="object_type">CUSTOMER</xsl:element>
        </xsl:element>
      </xsl:element>


      <!-- Change Customer Information -->
      
      <xsl:element name="CcmFifModifyCustomerInfoCmd">
        <xsl:element name="command_id">modify_customer_info_1</xsl:element>
        <xsl:element name="CcmFifModifyCustomerInfoInCont">

          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$desiredDate"/>
          </xsl:element>
          <xsl:element name="masking_digits_rd">
            <xsl:value-of select="request-param[@name='maskingDigitsRd']"/>
          </xsl:element>
          <xsl:element name="retention_period_rd">
            <xsl:value-of select="request-param[@name='retentionPeriodRd']"/>
          </xsl:element>
          <xsl:element name="storage_masking_digits_rd">
            <xsl:value-of select="request-param[@name='storageMaskingDigitsRd']"/>
          </xsl:element>
          <xsl:if test="request-param[@name='retentionPeriodRd'] != ''
            or request-param[@name='maskingDigitsRd'] != ''
            or request-param[@name='storageMaskingDigitsRd'] != ''">
            <xsl:element name="cascade_mask_retention_ind">Y</xsl:element> 
          </xsl:if>
          <xsl:element name="payment_term_rd">
            <xsl:value-of select="request-param[@name='paymentTermRd']"/>
          </xsl:element>
          <xsl:element name="user_password">
            <xsl:value-of select="request-param[@name='userPassword']"/>
          </xsl:element>
          <xsl:element name="usage_limit_amount">
            <xsl:value-of select="request-param[@name='usageLimitAmount']"/>
          </xsl:element>
          <xsl:element name="risk_category_rd">
            <xsl:value-of select="$riskCategory"/>
          </xsl:element>
          <xsl:element name="document_language_rd">
            <xsl:value-of select="request-param[@name='documentLanguageRd']"/>
          </xsl:element>
          <xsl:element name="classification_rd">
            <xsl:value-of select="request-param[@name='classificationRd']"/>
          </xsl:element>
          <xsl:element name="customer_group_rd">
            <xsl:value-of select="request-param[@name='customerGroupRd']"/>
          </xsl:element>
          <xsl:element name="customer_internal_ref_number">
            <xsl:value-of select="request-param[@name='customerInternalRefNumber']"/>
          </xsl:element>
          <xsl:element name="payment_method_rd">
            <xsl:value-of select="request-param[@name='paymentMethodRd']"/>
          </xsl:element>
          <xsl:element name="match_code_id">
            <xsl:value-of select="request-param[@name='matchCodeId']"/>
          </xsl:element>
          <xsl:element name="credit_check_result_state_rd">
            <xsl:value-of select="request-param[@name='creditCheckResultStateRd']"/>
          </xsl:element>
          <xsl:element name="credit_check_result_indicator">
            <xsl:value-of select="request-param[@name='creditCheckResultIndicator']"/>
          </xsl:element>
          <xsl:element name="prospect_indicator">
            <xsl:value-of select="request-param[@name='prospectIndicator']"/>
          </xsl:element>
          <xsl:element name="reference_indicator">
            <xsl:value-of select="request-param[@name='referenceIndicator']"/>
          </xsl:element>
          <xsl:element name="service_customer_indicator">
            <xsl:value-of select="request-param[@name='serviceCustomerIndicator']"/>
          </xsl:element>
          <xsl:element name="usage_data_indicator">
            <xsl:value-of select="request-param[@name='usageDataIndicator']"/>
          </xsl:element>
          <xsl:if test="request-param[@name='entityType'] = 'I'">
            <xsl:element name="CcmFifIndividualCont">
              <xsl:element name="ind_salutation_description">
                <xsl:value-of select="request-param[@name='indSalutationDescription']"/>
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
              <xsl:element name="individual_name">
                <xsl:value-of select="request-param[@name='individualName']"/>
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
                <xsl:value-of select="request-param[@name='orgSalutationDescription']"/>
              </xsl:element>
              <xsl:element name="organization_name">
                <xsl:value-of select="request-param[@name='organizationName']"/>
              </xsl:element>
              <xsl:element name="organization_suffix_name">
                <xsl:value-of select="request-param[@name='organizationSuffixName']"/>
              </xsl:element>
              <xsl:element name="organization_type_rd">
                <xsl:value-of select="request-param[@name='organizationTypeRd']"/>
              </xsl:element>
              <xsl:element name="industrial_sector_rd">
                <xsl:value-of select="request-param[@name='industrialSectorRd']"/>
              </xsl:element>
              <xsl:element name="domestic_organization_ind">
                <xsl:value-of select="request-param[@name='domesticOrganizationInd']"/>
              </xsl:element>
              <xsl:element name="incorporation_number_id">
                <xsl:value-of select="request-param[@name='incorporationNumberId']"/>
              </xsl:element>
              <xsl:element name="incorporation_city_name">
                <xsl:value-of select="request-param[@name='incorporationCityName']"/>
              </xsl:element>
              <xsl:element name="incorporation_type_rd">
                <xsl:value-of select="request-param[@name='incorporationTypeRd']"/>
              </xsl:element>
            </xsl:element>
          </xsl:if>
		  <xsl:element name="service_level_rd">
			<xsl:value-of select="request-param[@name='serviceLevelRd']"/>
		  </xsl:element>
          <xsl:element name="post_ident_indicator">
            <xsl:value-of select="request-param[@name='postIdentIndicator']"/>
          </xsl:element>	  
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
          <xsl:element name="billing_account_number">
            <xsl:value-of select="request-param[@name='billingAccountNumber']"/>
          </xsl:element>					          
       </xsl:element>
      </xsl:element>
      <xsl:if test="request-param[@name='championId'] != ''">
        <xsl:element name="CcmFifAddCcmParameterMapCmd">
          <xsl:element name="CcmFifAddCcmParameterMapInCont">
            <xsl:element name="supported_object_id">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="supported_object_type_rd">CUST_NUMB</xsl:element>
            <xsl:element name="param_name_rd">CHAMPION_ID</xsl:element>
            <xsl:element name="param_value">
              <xsl:value-of select="request-param[@name='championId']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>				
      </xsl:if>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
