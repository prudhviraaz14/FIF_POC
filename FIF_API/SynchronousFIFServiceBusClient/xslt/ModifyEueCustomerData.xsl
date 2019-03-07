<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for activating an inporting order

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
    <xsl:element name="package_name">
      <xsl:value-of select="request-param[@name='packageName']"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    
    <xsl:element name="Command_List">
            
      <xsl:variable name="today"
        select="dateutils:getCurrentDate()"/>
      
      <xsl:variable name="tomorrow"
        select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>      
      
      <xsl:variable name="methodOfPayment">
        <xsl:choose>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;MethodOfPayment'] = 'E'">
            <xsl:text>DIRECT_DEBIT</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;MethodOfPayment'] = 'R' or
                          request-param[@name='CustomerData;CustomerDataImpl;MethodOfPayment'] = 'F'">
            <xsl:text>MANUAL</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>      
   
      <xsl:variable name="paymentTermRd">
        <xsl:choose>
          <xsl:when test="$methodOfPayment = 'DIRECT_DEBIT' and
            request-param[@name='CustomerData;CustomerDataImpl;PaymentDays'] = ''">
            <xsl:text>2</xsl:text>
          </xsl:when>
          <xsl:when test="$methodOfPayment = 'MANUAL' and
            request-param[@name='CustomerData;CustomerDataImpl;PaymentDays'] = ''">
            <xsl:text>10</xsl:text>
          </xsl:when>
          <xsl:otherwise> 
            <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;PaymentDays']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable> 
      
      <xsl:variable name="taxExemptIndicator">
        <xsl:choose>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TaxExempted'] = '1'">
            <xsl:text>Y</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TaxExempted'] = '0'">
            <xsl:text>N</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>      
            
      <xsl:variable name="EUECustomerNumber">
        <!-- 1und1 Kundennummer -->
        <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;CustomerID']"/>
      </xsl:variable>
      
      <xsl:variable name="maskingDigits">
        <xsl:choose>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '30'">
            <xsl:text>-1</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '20'">
            <xsl:text>6</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '10'">
            <xsl:text>0</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '32'">
            <xsl:text>-1</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '21'">
            <xsl:text>6</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '12'">
            <xsl:text>-1</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '11'">
            <xsl:text>6</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>                  
      
      <xsl:variable name="retentionPeriod">
        <xsl:choose>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '30'">
            <xsl:text>80NODT</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '20'">
            <xsl:text>80NODT</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '10'">
            <xsl:text>DELDET</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '32'">
            <xsl:text>80DETL</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '21'">
            <xsl:text>80DETL</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '12'">
            <xsl:text>DELDET</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '11'">
            <xsl:text>DELDET</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>                  
      
      <xsl:variable name="egnEnabled">
        <xsl:choose>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '30'">
            <xsl:text>N</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '20'">
            <xsl:text>N</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '10'">
            <xsl:text>N</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '32'">
            <xsl:text>Y</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '21'">
            <xsl:text>Y</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '12'">
            <xsl:text>Y</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TSDV'] = '11'">
            <xsl:text>Y</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>                  
      
      <!-- billingAddressPostalCode -->
      <xsl:variable name="billingAddressPostalCode">
        <xsl:choose>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;Postbox'] != ''">
            <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;ZipCodePostbox']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;ZipCode']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
            
      <!-- billingAddressEffectiveDate -->
      <xsl:variable name="billingAddressEffectiveDate">
        <xsl:value-of select="dateutils:create1Und1Date(request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;ValidFrom'])"/>
      </xsl:variable>

      <!-- entityType -->      
      <xsl:variable name="entityType">
        <xsl:choose>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;NameCo'] != ''">O</xsl:when>
          <xsl:otherwise>I</xsl:otherwise>
        </xsl:choose>				
      </xsl:variable>			
      
      <!-- customerName -->
      <xsl:variable name="customerName">
        <xsl:choose>
          <xsl:when test="$entityType = 'I'">
            <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;Surname1']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;Name']"/>
          </xsl:otherwise>
        </xsl:choose> 
      </xsl:variable>     
      
      <!-- default salutation, if none is provided -->
      <xsl:variable name="billingAddressSalutation">
        <xsl:choose>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;Salutation'] = '1'">
            <xsl:text>Frau</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;Salutation'] = '2'">
            <xsl:text>Herr</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;Salutation'] = '3'">
            <xsl:text>Firma</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="$entityType = 'I'">Herr</xsl:if>
            <xsl:if test="$entityType = 'O'">Firma</xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <!-- classification -->
      <xsl:variable name="classificationRd">
        <xsl:choose>
          <xsl:when test="$entityType = 'I'">R1E</xsl:when>
          <xsl:otherwise>R1C</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <!-- category -->
      <xsl:variable name="categoryRd">
        <xsl:choose>
          <xsl:when test="$entityType = 'I'">RESIDENTIAL</xsl:when>
          <xsl:otherwise>BUSINESS</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="invoiceDeliveryType">
        <xsl:choose>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TypeOfDispatch'] = '1'">
            <xsl:text>EMAIL</xsl:text>
          </xsl:when>
          <xsl:when test="request-param[@name='CustomerData;CustomerDataImpl;TypeOfDispatch'] = '2'">
            <xsl:text>LETTER</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="invoiceTemplateName">
        <xsl:choose>
          <xsl:when test="$invoiceDeliveryType = 'EMAIL' and $entityType = 'O'">
            <xsl:text>1und1 Rechnung signiert</xsl:text>
          </xsl:when>
          <xsl:otherwise>1und1 Rechnung</xsl:otherwise>          
        </xsl:choose>
      </xsl:variable>      
      
      <xsl:variable name="accessNumberSemicolonDelimited">
        <xsl:value-of select="request-param[@name='Phonenumber;InternationalAreaCode']"/>
        <xsl:text>;</xsl:text>
        <xsl:value-of select="request-param[@name='Phonenumber;Prefix']"/>
        <xsl:text>;</xsl:text>
        <xsl:value-of select="request-param[@name='Phonenumber;Number']"/>
      </xsl:variable>
      
      <xsl:if test="request-param[@name='CustomerData;CustomerDataImpl;BankAccount;IBAN'] != ''
        and request-param[@name='CustomerData;CustomerDataImpl;MandateReferenceID'] = ''">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">IBAN_without_UMR</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">
              <xsl:text>Bei Uebermittlung von BIC und IBAN ist die UMR ein Pflichtfeld.</xsl:text>
            </xsl:element>
          </xsl:element>
        </xsl:element>                                      
      </xsl:if>
      
      <!-- Find Service -->      
      <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_wholesale_customer</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="access_number">
            <xsl:value-of select="$accessNumberSemicolonDelimited"/>
          </xsl:element>
          <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Get customer data -->
      <xsl:element name="CcmFifGetCustomerDataCmd">
        <xsl:element name="command_id">get_customer_data</xsl:element>
        <xsl:element name="CcmFifGetCustomerDataInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_wholesale_customer</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$tomorrow"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <xsl:element name="CcmFifGetEntityCmd">
        <xsl:element name="command_id">get_entity</xsl:element>
        <xsl:element name="CcmFifGetEntityInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_wholesale_customer</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- map change entity -->
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">concat_change_entity</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">get_customer_data</xsl:element>
              <xsl:element name="field_name">classification_rd</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text>;</xsl:text>
                <xsl:value-of select="$classificationRd"/>
              </xsl:element>							
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <xsl:element name="CcmFifMapStringCmd">
        <xsl:element name="command_id">map_change_entity</xsl:element>
        <xsl:element name="CcmFifMapStringInCont">
          <xsl:element name="input_string_type">OldClassification;NewClassification</xsl:element>
          <xsl:element name="input_string_ref">
            <xsl:element name="command_id">concat_change_entity</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="output_string_type">ChangeEntityType</xsl:element>
          <xsl:element name="string_mapping_list">
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">R1C;R1E</xsl:element>
              <xsl:element name="output_string">Y</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">R1C;R1C</xsl:element>
              <xsl:element name="output_string">N</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">R1E;R1E</xsl:element>
              <xsl:element name="output_string">N</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">R1E;R1C</xsl:element>
              <xsl:element name="output_string">Y</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="no_mapping_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifChangeCustomerCmd">
        <xsl:element name="command_id">change_masking_digits</xsl:element>
        <xsl:element name="CcmFifChangeCustomerInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_wholesale_customer</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="retention_period_rd">
            <xsl:value-of select="$retentionPeriod"/>
          </xsl:element>
          <xsl:if test="$maskingDigits != '' or $retentionPeriod != ''">
            <xsl:element name="cascade_mask_retention_ind">Y</xsl:element> 
          </xsl:if>
          <xsl:element name="masking_digits_rd">
            <xsl:value-of select="$maskingDigits"/>
          </xsl:element>
          <xsl:element name="storage_masking_digits_rd">
            <xsl:value-of select="$maskingDigits"/>
          </xsl:element>
          <xsl:element name="ignore_if_object_exists">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifChangeCustomerCmd">
        <xsl:element name="command_id">change_customer_data</xsl:element>
        <xsl:element name="CcmFifChangeCustomerInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_wholesale_customer</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$tomorrow"/>
          </xsl:element>
          <xsl:element name="payment_term_rd">
            <xsl:value-of select="$paymentTermRd"/>
          </xsl:element>
          <xsl:element name="category_rd">
            <xsl:value-of select="$categoryRd"/>
          </xsl:element>
          <xsl:element name="classification_rd">
            <xsl:value-of select="$classificationRd"/>
          </xsl:element>
          <xsl:element name="customer_internal_ref_number">
            <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;CustomerID']"/>
          </xsl:element>
          <xsl:element name="payment_method_rd">
            <xsl:value-of select="$methodOfPayment"/>
          </xsl:element>
          <xsl:element name="match_code_id">
            <xsl:value-of select="substring(translate(dateutils:toUpperCase($customerName),'ÖÄÜß -_',''),1,20)"/>
          </xsl:element>
          <xsl:element name="ignore_if_object_exists">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!--  change entity --> 
      <xsl:element name="CcmFifModifyCustomerInfoCmd">
        <xsl:element name="command_id">change_entity</xsl:element>
        <xsl:element name="CcmFifModifyCustomerInfoInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_wholesale_customer</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$tomorrow"/>
          </xsl:element>          
          <xsl:if test="$entityType = 'I'">
            <xsl:element name="CcmFifIndividualCont">
              <xsl:element name="ind_salutation_description">
                <xsl:value-of select="$billingAddressSalutation"/>
              </xsl:element>
              <xsl:element name="title_description">
                <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;Title']"/>
              </xsl:element>
              <xsl:element name="forename">
                <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;Name']"/>
              </xsl:element>
              <xsl:element name="individual_name">
                <xsl:value-of select="$customerName"/>
              </xsl:element>
              <xsl:element name="birth_date">1920.01.01 00:00:00</xsl:element>              
            </xsl:element>
          </xsl:if>
          <xsl:if test="$entityType = 'O'">
            <xsl:element name="CcmFifOrganizationCont">
              <xsl:element name="org_salutation_description">
                <xsl:value-of select="$billingAddressSalutation"/>
              </xsl:element>
              <xsl:element name="organization_name">
                <xsl:value-of select="$customerName"/>
              </xsl:element>
              <xsl:element name="organization_type_rd">BLANK</xsl:element>
              <xsl:element name="incorporation_type_rd">UNREGISTERED</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="change_entity_type_ref">
            <xsl:element name="command_id">map_change_entity</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="ignore_if_object_exists">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- find STD address -->
      <xsl:element name="CcmFifFindAddressCmd">
        <xsl:element name="command_id">find_std_address</xsl:element>
        <xsl:element name="CcmFifFindAddressInCont">
          <xsl:element name="entity_id_ref">
            <xsl:element name="command_id">get_entity</xsl:element>
            <xsl:element name="field_name">entity_id</xsl:element>
          </xsl:element>
          <xsl:element name="address_type_rd">STD</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- modify STD address -->
      <xsl:element name="CcmFifModifyAddressCmd">
        <xsl:element name="command_id">modify_address</xsl:element>
        <xsl:element name="CcmFifModifyAddressInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_wholesale_customer</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$tomorrow"/>
          </xsl:element>            
          <xsl:element name="address_ref">
            <xsl:element name="command_id">find_std_address</xsl:element>
            <xsl:element name="field_name">address_id</xsl:element>
          </xsl:element>
          <xsl:element name="address_type">STD</xsl:element>
          <xsl:element name="street_name">
            <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;Street']"/>
          </xsl:element>            
          <!--  
          <xsl:element name="street_number">
            <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;Hausnumber']"/>
          </xsl:element>
          <xsl:element name="street_number_suffix">
            <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;HausnumberAdd']"/>
          </xsl:element>
          -->
          <xsl:element name="post_office_box">
            <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;Postbox']"/>              
          </xsl:element>
          <xsl:element name="postal_code">
            <xsl:value-of select="$billingAddressPostalCode"/>
          </xsl:element>
          <xsl:element name="city_name">
            <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;City']"/>
          </xsl:element>
          <xsl:element name="country">
            <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;CountryId']"/>
          </xsl:element>
          <xsl:element name="ignore_if_object_exists">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifFindAccountCmd">
        <xsl:element name="command_id">find_own_account</xsl:element>
        <xsl:element name="CcmFifFindAccountInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_wholesale_customer</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="no_account_error">Y</xsl:element>
        </xsl:element>
      </xsl:element>			        
      
      <xsl:if test="request-param[@name='CustomerData;CustomerDataImpl;EmailAddress'] != ''"> 
        <!-- modify doc recpt -->
        <xsl:element name="CcmFifGetDocumentRecipientInfoCmd">
          <xsl:element name="command_id">get_document_recipient</xsl:element>
          <xsl:element name="CcmFifGetDocumentRecipientInfoInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_wholesale_customer</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_own_account</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>        
        
        <!-- update the primary access information, or create if it doesn't exist -->
        <xsl:element name="CcmFifUpdateAccessInformCmd">
          <xsl:element name="command_id">save_email_address</xsl:element>
          <xsl:element name="CcmFifUpdateAccessInformInCont">
            <xsl:element name="entity_ref">
              <xsl:element name="command_id">get_document_recipient</xsl:element>
              <xsl:element name="field_name">entity_id</xsl:element>
            </xsl:element>              
            <xsl:element name="access_information_ref">
              <xsl:element name="command_id">get_document_recipient</xsl:element>
              <xsl:element name="field_name">access_information_id</xsl:element>
            </xsl:element>              
            <xsl:element name="effective_date">
              <xsl:value-of select="$tomorrow"/>
            </xsl:element>
            <xsl:element name="contact_name">
              <xsl:if test="$entityType = 'O'">
                <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;NameCo']"/>
              </xsl:if>
              <xsl:if test="$entityType = 'I'">
                <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;Name']"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BillingAddressData;Surname1']"/>
              </xsl:if>
            </xsl:element>
            <xsl:element name="email_address">
              <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;EmailAddress']"/>
            </xsl:element>
            <xsl:element name="electronic_contact_indicator">Y</xsl:element>
            <xsl:element name="ignore_if_object_exists">Y</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- the following command is only executed if bank account info is provided -->
      <xsl:if test="request-param[@name='CustomerData;CustomerDataImpl;BankAccount;AccountNumber'] != ''
          or request-param[@name='CustomerData;CustomerDataImpl;BankAccount;IBAN'] != ''">
        <!-- create bank account -->
        <xsl:element name="CcmFifCreateBankAccountCmd">
          <xsl:element name="command_id">create_bank_account</xsl:element>
          <xsl:element name="CcmFifCreateBankAccountInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_wholesale_customer</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="$tomorrow"/>
            </xsl:element>
            <xsl:element name="bank_account_number">
              <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BankAccount;AccountNumber']"/>
            </xsl:element>
            <xsl:element name="owner_full_name">
              <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BankAccount;AccountOwner']"/>
            </xsl:element>
            <xsl:element name="bank_clearing_code">
              <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BankAccount;BankCodeNumber']"/>
            </xsl:element>
            <xsl:element name="ignore_if_object_exists">Y</xsl:element>
            <xsl:element name="bank_identifier_code">
              <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BankAccount;BIC']"/>
            </xsl:element>
            <xsl:element name="internat_bank_account_number">
              <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;BankAccount;IBAN']"/>
            </xsl:element> 
			<xsl:element name="bank_name">
              <xsl:value-of select="substring(request-param[@name='CustomerData;CustomerDataImpl;BankAccount;BankName'], 1, 60)"/>
			</xsl:element>
			<xsl:element name="sepa_check_functional_error_ind">1AND1</xsl:element>			         
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- Modify Account -->
      <xsl:element name="CcmFifModifyAccountCmd">
        <xsl:element name="CcmFifModifyAccountInCont">
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_own_account</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='CustomerData;CustomerDataImpl;BankAccount;AccountNumber'] != ''
              or request-param[@name='CustomerData;CustomerDataImpl;BankAccount;IBAN'] != ''">
            <xsl:element name="bank_account_id_ref">
              <xsl:element name="command_id">create_bank_account</xsl:element>
              <xsl:element name="field_name">bank_account_id</xsl:element>
            </xsl:element>
          </xsl:if>
          <xsl:element name="effective_date">
            <xsl:value-of select="$tomorrow"/>
          </xsl:element>
          <xsl:element name="doc_template_name">
            <xsl:value-of select="$invoiceTemplateName"/>
          </xsl:element>
          <xsl:element name="method_of_payment">
            <xsl:value-of select="$methodOfPayment"/>
          </xsl:element>
          <xsl:element name="payment_term_rd">
            <xsl:value-of select="$paymentTermRd"/>
          </xsl:element>
          <xsl:element name="customer_account_id">
            <xsl:value-of select="request-param[@name='CustomerData;ContractID;ContractID']"/>
          </xsl:element>
          <xsl:element name="direct_debit_authoriz_date">
            <xsl:value-of select="$today"/>
          </xsl:element>
          <xsl:element name="tax_exempt_indicator">
            <xsl:value-of select="$taxExemptIndicator"/>
          </xsl:element>
          <xsl:element name="state_rd">ACTIVATED</xsl:element>
          <xsl:element name="last_masterdata_update">
            <xsl:value-of select="$today"/>
          </xsl:element>            
          <xsl:element name="mandate_reference_id">
            <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;MandateReferenceID']"/>
          </xsl:element>
          <xsl:element name="mandate_signature_date">
            <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;MandateSignatureDate']"/>
          </xsl:element>            
          <xsl:element name="mandate_status_rd">
            <xsl:value-of select="request-param[@name='CustomerData;CustomerDataImpl;MandateStatus']"/>
          </xsl:element>                     
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifGetAccountDataCmd">
        <xsl:element name="command_id">get_account_data</xsl:element>
        <xsl:element name="CcmFifGetAccountDataInCont">
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_own_account</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>              
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$tomorrow"/>
          </xsl:element>
        </xsl:element>    
      </xsl:element>        
      
      <!-- find document pattern for desired invoice delivery type -->
      <xsl:element name="CcmFifFindDocumentPatternCmd">
        <xsl:element name="command_id">find_email_docpatt</xsl:element>
        <xsl:element name="CcmFifFindDocumentPatternInCont">
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">find_own_account</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>              
          </xsl:element>
          <xsl:element name="supported_object_type_rd">ACCOUNT</xsl:element>
          <xsl:element name="document_template_name">Rechnung per E-Mail</xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$tomorrow"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
            
      <xsl:if test="$invoiceDeliveryType = 'LETTER'">
        <!-- stop the obsolete document patterns -->
        <xsl:element name="CcmFifStopDocumentPatternCmd">
          <xsl:element name="command_id">stop_email_pattern</xsl:element>
          <xsl:element name="CcmFifStopDocumentPatternInCont">
            <xsl:element name="document_pattern_id_list_ref">
              <xsl:element name="command_id">find_email_docpatt</xsl:element>
              <xsl:element name="field_name">document_pattern_id_list</xsl:element>              
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="$tomorrow"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>      
      </xsl:if>
      
      <!-- set printer destination on mailing depending on delivery type and customer category -->
      <xsl:element name="CcmFifModifyMailingCmd">
        <xsl:element name="command_id">modify_mailing</xsl:element>
        <xsl:element name="CcmFifModifyMailingInCont">
          <xsl:element name="mailing_id_ref">
            <xsl:element name="command_id">get_account_data</xsl:element>
            <xsl:element name="field_name">mailing_id</xsl:element>
          </xsl:element>
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_wholesale_customer</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$tomorrow"/>
          </xsl:element>
          <xsl:element name="printer_destination_rd">
            <xsl:choose>
              <xsl:when test="$invoiceDeliveryType = 'LETTER'">MDV</xsl:when>
              <xsl:otherwise>webBill</xsl:otherwise>
            </xsl:choose>            
          </xsl:element>
          <xsl:element name="ignore_if_object_exists">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- find document pattern for desired invoice delivery type -->
      <xsl:element name="CcmFifFindDocumentPatternCmd">
        <xsl:element name="command_id">find_evn_docpatt</xsl:element>
        <xsl:element name="CcmFifFindDocumentPatternInCont">
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">find_own_account</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>              
          </xsl:element>
          <xsl:element name="supported_object_type_rd">ACCOUNT</xsl:element>
          <xsl:element name="document_template_name">1und1 EVN</xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$tomorrow"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>            
      
      <!-- Create Document Pattern for invoice delivery type -->
      <xsl:element name="CcmFifCreateDocumentPatternCmd">
        <xsl:element name="command_id">create_evn_docpatt</xsl:element>
        <xsl:element name="CcmFifCreateDocumentPatternInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_wholesale_customer</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_own_account</xsl:element>
            <xsl:element name="field_name">account_number</xsl:element>              
          </xsl:element>
          <xsl:element name="mailing_id_ref">
            <xsl:element name="command_id">get_account_data</xsl:element>
            <xsl:element name="field_name">mailing_id</xsl:element>
          </xsl:element>
          <xsl:element name="output_device_rd">PRINTER</xsl:element>
          <xsl:element name="doc_template_name">1und1 EVN</xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$tomorrow"/>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">find_evn_docpatt</xsl:element>
            <xsl:element name="field_name">document_pattern_found</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>          
        </xsl:element>
      </xsl:element>
            
      <xsl:if test="$invoiceDeliveryType = 'EMAIL'">
        <!-- Create Document Pattern for invoice delivery type -->
        <xsl:element name="CcmFifCreateDocumentPatternCmd">
          <xsl:element name="command_id">create_email_docpatt</xsl:element>
          <xsl:element name="CcmFifCreateDocumentPatternInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">find_wholesale_customer</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_own_account</xsl:element>
              <xsl:element name="field_name">account_number</xsl:element>              
            </xsl:element>
            <xsl:element name="mailing_id_ref">
              <xsl:element name="command_id">get_account_data</xsl:element>
              <xsl:element name="field_name">mailing_id</xsl:element>
            </xsl:element>
            <xsl:element name="output_device_rd">WEBBILL</xsl:element>
            <xsl:element name="doc_template_name">Rechnung per E-Mail</xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="$tomorrow"/>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_email_docpatt</xsl:element>
              <xsl:element name="field_name">document_pattern_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>          
          </xsl:element>
        </xsl:element>        
      </xsl:if>      

      <!-- Create Contact for Service Addition -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">find_wholesale_customer</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">MASTERDATAUPDATE</xsl:element>
          <xsl:element name="short_description">1und1-Kundendaten aktualisiert</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:text>1und1-Kundendaten wurden aktualisiert (SBUS-TransactionID: </xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
            <xsl:text>).</xsl:text>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
    
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
