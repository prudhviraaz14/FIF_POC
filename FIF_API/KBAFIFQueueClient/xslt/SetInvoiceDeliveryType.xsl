<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for setting the invoice delivery type

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
      
      <xsl:if test="request-param[@name='accountNumber'] = ''">
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_account_number</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">
              <xsl:if test="request-param[@name='somElementID'] != ''">
                <xsl:value-of select="request-param[@name='somElementID']"/>
                <xsl:text>_</xsl:text>
              </xsl:if>
              <xsl:text>ACCOUNT_NUMBER</xsl:text>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- use the input, if provided or the value from ext notification, 
        used in the child XSLT files --> 
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">find_account_number</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:choose>
              <xsl:when test="request-param[@name='accountNumber'] != ''">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">
                    <xsl:value-of select="request-param[@name='accountNumber']"/>
                  </xsl:element>							
                </xsl:element>                
              </xsl:when>
              <xsl:otherwise>
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">read_account_number</xsl:element>
                  <xsl:element name="field_name">parameter_value</xsl:element>							
                </xsl:element>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:element>
      </xsl:element>      
      
      <!-- raise error for wrong values -->
      <xsl:choose>
        <xsl:when test="request-param[@name='enableEgn'] != 'Y'
          and request-param[@name='enableEgn'] != 'N'
          and request-param[@name='enableEgn'] != 'none'
          and request-param[@name='enableEgn'] != 'electronic'
          and request-param[@name='enableEgn'] != 'paper'">
          <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">raiseError_enableEgn</xsl:element>
            <xsl:element name="CcmFifRaiseErrorInCont">
              <xsl:element name="error_text">Angegebener Wert für Parameter enableEgn ist nicht erlaubt. Bitte einen der folgenden verwenden: "N", "Y", "paper", "electronic", "none"</xsl:element>          
            </xsl:element>
          </xsl:element>
        </xsl:when>
        <xsl:when test="request-param[@name='deliveryType'] != 'EMAIL'
          and request-param[@name='deliveryType'] != 'WEBBILL'
          and request-param[@name='deliveryType'] != 'LETTER'">
          <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">raiseError_deliveryType</xsl:element>
            <xsl:element name="CcmFifRaiseErrorInCont">
              <xsl:element name="error_text">Angegebener Wert für Parameter deliveryType ist nicht erlaubt. Bitte einen der folgenden verwenden: "WEBBILL", "LETTER", "EMAIL"</xsl:element>          
            </xsl:element>
          </xsl:element>
        </xsl:when>        
      <xsl:otherwise>
      <xsl:variable name="retentionPeriod">
        <xsl:choose>
          <xsl:when test="request-param[@name='enableEgn'] = 'Y'">80DETL</xsl:when>
          <xsl:when test="request-param[@name='enableEgn'] = 'N'">80NODT</xsl:when>
          <xsl:when test="request-param[@name='enableEgn'] = 'none'">80NODT</xsl:when>
          <xsl:when test="request-param[@name='enableEgn'] = 'electronic'">80DETL</xsl:when>
          <xsl:when test="request-param[@name='enableEgn'] = 'paper'">80DETL</xsl:when>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="egnType">
        <xsl:choose>
          <xsl:when test="request-param[@name='enableEgn'] = 'Y'">
            <xsl:if test="request-param[@name='deliveryType'] = 'LETTER'">paper</xsl:if>
            <xsl:if test="request-param[@name='deliveryType'] != 'LETTER'">electronic</xsl:if>
          </xsl:when>
          <xsl:when test="request-param[@name='enableEgn'] = 'N'">none</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='enableEgn']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="egnEnabled">
        <xsl:choose>
          <xsl:when test="$egnType = 'none'">N</xsl:when>
          <xsl:otherwise>Y</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="outputDevice">
        <xsl:choose>
        <xsl:when test="request-param[@name='deliveryType'] = 'WEBBILL'
          or request-param[@name='deliveryType'] = 'EMAIL'">WEBBILL</xsl:when>
          <xsl:otherwise>
            <xsl:if test="$egnType = 'electronic'">WEBBILL</xsl:if>
            <xsl:if test="$egnType != 'electronic'">PRINTER</xsl:if>            
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="today"
        select="dateutils:getCurrentDate()"/>
      
      <xsl:variable name="tomorrow"
        select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
      
        <xsl:variable name="desiredDate">
          <xsl:choose>
            <xsl:when test="request-param[@name='desiredDate'] = 'today'">
              <xsl:value-of select="$tomorrow"/>
            </xsl:when>
            <xsl:when test="request-param[@name='desiredDate'] = 'tomorrow'">
              <xsl:value-of select="$tomorrow"/>
            </xsl:when>
            <xsl:when test="request-param[@name='desiredDate'] != ''
              and dateutils:compareString(request-param[@name='desiredDate'], $tomorrow) = '1'">
              <xsl:value-of select="request-param[@name='desiredDate']"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$tomorrow"/>
            </xsl:otherwise>
          </xsl:choose>          
        </xsl:variable>
      
      <!-- get account data to retrieve cycle name -->
      <xsl:element name="CcmFifGetAccountDataCmd">
        <xsl:element name="command_id">get_account_for_cycle</xsl:element>
        <xsl:element name="CcmFifGetAccountDataInCont">
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_account_number</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$tomorrow"/>
          </xsl:element>
        </xsl:element>    
      </xsl:element>
      
      <!-- lock account to avoid concurrency problems -->
      <xsl:element name="CcmFifLockObjectCmd">
        <xsl:element name="CcmFifLockObjectInCont">
          <xsl:element name="object_id_ref">
            <xsl:element name="command_id">get_account_for_cycle</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="object_type">CUSTOMER</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- get cycle due date, if it will be used -->      
      <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
        <xsl:element name="CcmFifGetCycleCmd">
          <xsl:element name="command_id">get_cycle</xsl:element>
          <xsl:element name="CcmFifGetCycleInCont">
            <xsl:element name="cycle_name_ref">
              <xsl:element name="command_id">get_account_for_cycle</xsl:element>
              <xsl:element name="field_name">cycle_name</xsl:element>
            </xsl:element>
            <xsl:element name="offset_days">1</xsl:element>
          </xsl:element>    
        </xsl:element>
      </xsl:if>
      
      <!-- get account data -->
      <xsl:element name="CcmFifGetAccountDataCmd">
        <xsl:element name="command_id">get_account_data</xsl:element>
        <xsl:element name="CcmFifGetAccountDataInCont">
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_account_number</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
            <xsl:element name="effective_date">
              <xsl:value-of select="$desiredDate"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
            <xsl:element name="effective_date_ref">
              <xsl:element name="command_id">get_cycle</xsl:element>
              <xsl:element name="field_name">due_date_with_offset</xsl:element>              
            </xsl:element>
          </xsl:if>
        </xsl:element>    
      </xsl:element>      
      
      <!-- check if a future dated object exists to make sure no similar transaction was processed -->
      <xsl:element name="CcmFifValidateFutureDatedObjectCmd">
        <xsl:element name="command_id">validate_future_dated_mailing</xsl:element>
        <xsl:element name="CcmFifValidateFutureDatedObjectInCont">
          <xsl:element name="object_id_ref">
            <xsl:element name="command_id">get_account_data</xsl:element>
            <xsl:element name="field_name">mailing_id</xsl:element>
          </xsl:element>
          <xsl:element name="object_type">MAILING</xsl:element>
          <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
            <xsl:element name="effective_date">
              <xsl:value-of select="$desiredDate"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
            <xsl:element name="effective_date_ref">
              <xsl:element name="command_id">get_cycle</xsl:element>
              <xsl:element name="field_name">due_date_with_offset</xsl:element>              
            </xsl:element>
          </xsl:if>
        </xsl:element>    
      </xsl:element>
        
      <!-- update masking digits on customer, if desired -->
      <xsl:if test="request-param[@name='maskingDigits'] != '' 
        or request-param[@name='storageMaskingDigits'] != ''
        or $retentionPeriod != ''">        
        <xsl:element name="CcmFifChangeCustomerCmd">
          <xsl:element name="command_id">change_customer</xsl:element>
          <xsl:element name="CcmFifChangeCustomerInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">get_account_data</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="$today"/>
            </xsl:element>
            <xsl:element name="retention_period_rd">
              <xsl:value-of select="$retentionPeriod"/>
            </xsl:element>
            <xsl:element name="cascade_mask_retention_ind">
              <xsl:value-of select="request-param[@name='updateAccessNumbers']"/>
            </xsl:element>
            <xsl:element name="masking_digits_rd">
              <xsl:value-of select="request-param[@name='maskingDigits']"/>
            </xsl:element>
            <xsl:element name="storage_masking_digits_rd">
              <xsl:value-of select="request-param[@name='storageMaskingDigits']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <xsl:if test="request-param[@name='emailAddress'] != ''">
        <!-- Get doc recpt Information -->
        <xsl:element name="CcmFifGetDocumentRecipientInfoCmd">
          <xsl:element name="command_id">get_document_recipient</xsl:element>
          <xsl:element name="CcmFifGetDocumentRecipientInfoInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">get_account_data</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_account_number</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
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
            <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
              <xsl:element name="effective_date">
                <xsl:value-of select="$desiredDate"/>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
              <xsl:element name="effective_date_ref">
                <xsl:element name="command_id">get_cycle</xsl:element>
                <xsl:element name="field_name">due_date_with_offset</xsl:element>              
              </xsl:element>
            </xsl:if>            
            <xsl:element name="email_address">
              <xsl:value-of select="request-param[@name='emailAddress']"/>
            </xsl:element>
            <xsl:element name="email_validation_indicator">
                <xsl:value-of select="request-param[@name='emailValidationIndicator']"/>
            </xsl:element>
            <xsl:element name="electronic_contact_indicator">Y</xsl:element>              
          </xsl:element>
        </xsl:element>
        
        <!-- attach the new access information to the doc recpt -->
        <xsl:element name="CcmFifModifyDocumentRecipientCmd">
          <xsl:element name="command_id">modify_doc_recpt</xsl:element>
          <xsl:element name="CcmFifModifyDocumentRecipientInCont">
            <xsl:element name="document_recipient_ref">
              <xsl:element name="command_id">get_document_recipient</xsl:element>
              <xsl:element name="field_name">document_recipient_id</xsl:element>
            </xsl:element>              
            <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
              <xsl:element name="effective_date">
                <xsl:value-of select="$desiredDate"/>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
              <xsl:element name="effective_date_ref">
                <xsl:element name="command_id">get_cycle</xsl:element>
                <xsl:element name="field_name">due_date_with_offset</xsl:element>              
              </xsl:element>
            </xsl:if>            
            <xsl:element name="access_information_ref">
              <xsl:element name="command_id">save_email_address</xsl:element>
              <xsl:element name="field_name">access_information_id</xsl:element>
            </xsl:element>   
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">get_document_recipient</xsl:element>
              <xsl:element name="field_name">access_information_found</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>            
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- get customer data to retrieve customer category-->
      <xsl:element name="CcmFifGetCustomerDataCmd">
        <xsl:element name="command_id">get_customer_data</xsl:element>
        <xsl:element name="CcmFifGetCustomerDataInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">get_account_data</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
            <xsl:element name="effective_date">
              <xsl:value-of select="$desiredDate"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
            <xsl:element name="effective_date_ref">
              <xsl:element name="command_id">get_cycle</xsl:element>
              <xsl:element name="field_name">due_date_with_offset</xsl:element>              
            </xsl:element>
          </xsl:if>
        </xsl:element>
      </xsl:element>
            
      <!-- check, if the payment method is direct debit if the customer wants webbill -->
      <xsl:if test="request-param[@name='deliveryType'] = 'WEBBILL'">        
        <!-- concat the category of the customer and the payment method for 
          validation of payment method for residential customers --> 
        <xsl:element name="CcmFifConcatStringsCmd">
          <xsl:element name="command_id">concat_payment_string</xsl:element>
          <xsl:element name="CcmFifConcatStringsInCont">
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">get_customer_data</xsl:element>
                <xsl:element name="field_name">category_rd</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">;</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">get_account_data</xsl:element>
                <xsl:element name="field_name">method_of_payment_rd</xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>							

        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_sepa_functional_error</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">
              <xsl:if test="request-param[@name='somElementID'] != ''">
                <xsl:value-of select="request-param[@name='somElementID']"/>
                <xsl:text>_</xsl:text>
              </xsl:if>
              <xsl:text>SEPA_FUNCTIONAL_ERROR</xsl:text>
            </xsl:element>
            <xsl:element name="ignore_empty_result">Y</xsl:element>
          </xsl:element>
        </xsl:element>
                
        <xsl:element name="CcmFifValidateValueCmd">
          <xsl:element name="command_id">validate_payment_method</xsl:element>
          <xsl:element name="CcmFifValidateValueInCont">
            <xsl:element name="value_ref">
              <xsl:element name="command_id">concat_payment_string</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="object_type">CUSTOMER;ACCOUNT</xsl:element>
            <xsl:element name="value_type">CATEGORY_RD;PAYMENT_METHOD_RD</xsl:element>
            <xsl:element name="allowed_values">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">RESIDENTIAL;DIRECT_DEBIT</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">BUSINESS;DIRECT_DEBIT</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">BUSINESS;MANUAL</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">BUSINESS;MANUAL_FEE</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">read_sepa_functional_error</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>
          </xsl:element>
        </xsl:element>    
                
        <xsl:element name="CcmFifValidateValueCmd">
          <xsl:element name="command_id">validate_payment_method</xsl:element>
          <xsl:element name="CcmFifValidateValueInCont">
            <xsl:element name="value_ref">
              <xsl:element name="command_id">concat_payment_string</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="object_type">CUSTOMER;ACCOUNT</xsl:element>
            <xsl:element name="value_type">CATEGORY_RD;PAYMENT_METHOD_RD</xsl:element>
            <xsl:element name="allowed_values">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">RESIDENTIAL;DIRECT_DEBIT</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">RESIDENTIAL;MANUAL</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">BUSINESS;DIRECT_DEBIT</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">BUSINESS;MANUAL</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">BUSINESS;MANUAL_FEE</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">read_sepa_functional_error</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>
          </xsl:element>
        </xsl:element>    
      </xsl:if>
      
      <!-- check, which general code group the classification belongs to to determine
        if the customer is an Arcor or Vodafone customer -->
      <xsl:element name="CcmFifGetGeneralCodeGroupCmd">
        <xsl:element name="command_id">get_classification_group</xsl:element>
        <xsl:element name="CcmFifGetGeneralCodeGroupInCont">
          <xsl:element name="value_ref">
            <xsl:element name="command_id">get_customer_data</xsl:element>
            <xsl:element name="field_name">classification_rd</xsl:element>
          </xsl:element>
          <xsl:element name="group_code_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">ARCUSTCLAS</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">VFCUSTCLAS</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
        
        <xsl:if test="$egnType = 'paper' and request-param[@name='deliveryType'] = 'WEBBILL' or
          $egnType = 'electronic' and request-param[@name='deliveryType'] = 'LETTER'">
          <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">wrongOptionForVF</xsl:element>
            <xsl:element name="CcmFifRaiseErrorInCont">
              <xsl:element name="error_text">
                <xsl:text>Ungültige Kombination für Vodafone-Kunden: EGN-Typ = </xsl:text> 
                <xsl:value-of select="$egnType"/>
                <xsl:text>, Zustellungsart = </xsl:text> 
                <xsl:value-of select="request-param[@name='deliveryType']"/>
              </xsl:element>            
              <xsl:element name="process_ind_ref">
                <xsl:element name="command_id">get_classification_group</xsl:element>
                <xsl:element name="field_name">group_code</xsl:element>
              </xsl:element>
              <xsl:element name="required_process_ind">VFCUSTCLAS</xsl:element>            
            </xsl:element>          
          </xsl:element>
        </xsl:if>
        
        <!-- in case of electronic invoice, the mapping is simple -->
      <xsl:choose>
        <xsl:when test="request-param[@name='deliveryType'] = 'LETTER'">
          <xsl:element name="CcmFifMapStringCmd">
            <xsl:element name="command_id">map_printer_destination</xsl:element>
            <xsl:element name="CcmFifMapStringInCont">
              <xsl:element name="input_string_type">Kundenkategorie;Kundenklassengruppe;EGN-Typ</xsl:element>
              <xsl:element name="input_string_list">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">get_customer_data</xsl:element>
                  <xsl:element name="field_name">category_rd</xsl:element>							
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">;</xsl:element>							
                </xsl:element>
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">get_classification_group</xsl:element>
                  <xsl:element name="field_name">group_code</xsl:element>							
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">
                    <xsl:text>;</xsl:text>
                    <xsl:value-of select="$egnType"/>
                  </xsl:element>							
                </xsl:element>
              </xsl:element>
              <xsl:element name="output_string_type">Druckerstandort</xsl:element>
              <xsl:element name="string_mapping_list">
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">RESIDENTIAL;VFCUSTCLAS;none</xsl:element>
                  <xsl:element name="output_string">MDV</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">RESIDENTIAL;VFCUSTCLAS;paper</xsl:element>
                  <xsl:element name="output_string">MDV</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">RESIDENTIAL;VFCUSTCLAS;electronic</xsl:element>
                  <xsl:element name="output_string">MDV</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">BUSINESS;VFCUSTCLAS;none</xsl:element>
                  <xsl:element name="output_string">MDV</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">BUSINESS;VFCUSTCLAS;paper</xsl:element>
                  <xsl:element name="output_string">MDV</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">BUSINESS;VFCUSTCLAS;electronic</xsl:element>
                  <xsl:element name="output_string">MDV</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">RESIDENTIAL;ARCUSTCLAS;none</xsl:element>
                  <xsl:element name="output_string">MDV</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">RESIDENTIAL;ARCUSTCLAS;paper</xsl:element>
                  <xsl:element name="output_string">MDV</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">RESIDENTIAL;ARCUSTCLAS;electronic</xsl:element>
                  <xsl:element name="output_string">MDV</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">BUSINESS;ARCUSTCLAS;none</xsl:element>
                  <xsl:element name="output_string">MDV</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">BUSINESS;ARCUSTCLAS;paper</xsl:element>
                  <xsl:element name="output_string">MDV</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">BUSINESS;ARCUSTCLAS;electronic</xsl:element>
                  <xsl:element name="output_string">Papier&amp;Webbill</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="no_mapping_error">Y</xsl:element>
            </xsl:element>
          </xsl:element>          
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="CcmFifMapStringCmd">
            <xsl:element name="command_id">map_printer_destination</xsl:element>
            <xsl:element name="CcmFifMapStringInCont">
              <xsl:element name="input_string_type">Kundenklassengruppe</xsl:element>
              <xsl:element name="input_string_list">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">get_customer_data</xsl:element>
                  <xsl:element name="field_name">category_rd</xsl:element>							
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">;</xsl:element>							
                </xsl:element>
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">get_classification_group</xsl:element>
                  <xsl:element name="field_name">group_code</xsl:element>							
                </xsl:element>
              </xsl:element>
              <xsl:element name="output_string_type">Druckerstandort</xsl:element>
              <xsl:element name="string_mapping_list">
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">BUSINESS;ARCUSTCLAS</xsl:element>
                  <xsl:element name="output_string">webBill</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">RESIDENTIAL;ARCUSTCLAS</xsl:element>
                  <xsl:element name="output_string">webBill</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">BUSINESS;VFCUSTCLAS</xsl:element>
                  <xsl:element name="output_string">Papier&amp;Webbill</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">RESIDENTIAL;VFCUSTCLAS</xsl:element>
                  <xsl:element name="output_string">webBill</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="no_mapping_error">Y</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
      
      <xsl:choose>
        <xsl:when test="request-param[@name='deliveryType'] = 'LETTER'">
          <xsl:element name="CcmFifMapStringCmd">
            <xsl:element name="command_id">map_invoice_template</xsl:element>
            <xsl:element name="CcmFifMapStringInCont">
              <xsl:element name="input_string_type">Kundenkategorie;Kundenklassengruppe</xsl:element>
              <xsl:element name="input_string_list">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">get_customer_data</xsl:element>
                  <xsl:element name="field_name">category_rd</xsl:element>							
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">;</xsl:element>							
                </xsl:element>
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">get_classification_group</xsl:element>
                  <xsl:element name="field_name">group_code</xsl:element>							
                </xsl:element>
              </xsl:element>
              <xsl:element name="output_string_type">Rechnungsvorlage</xsl:element>
              <xsl:element name="string_mapping_list">
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">RESIDENTIAL;VFCUSTCLAS</xsl:element>
                  <xsl:element name="output_string">Vodafone PK-Rechnung</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">RESIDENTIAL;ARCUSTCLAS</xsl:element>
                  <xsl:element name="output_string">Privatkunden Rechnung</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">BUSINESS;VFCUSTCLAS</xsl:element>
                  <xsl:element name="output_string">VF Rechnung</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">BUSINESS;ARCUSTCLAS</xsl:element>
                  <xsl:element name="output_string">Rechnung</xsl:element>
                </xsl:element>                
              </xsl:element>
              <xsl:element name="no_mapping_error">Y</xsl:element>
            </xsl:element>    
          </xsl:element>                    
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="CcmFifMapStringCmd">
            <xsl:element name="command_id">map_invoice_template</xsl:element>
            <xsl:element name="CcmFifMapStringInCont">
              <xsl:element name="input_string_type">Kundenkategorie;Kundenklassengruppe</xsl:element>
              <xsl:element name="input_string_list">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">get_customer_data</xsl:element>
                  <xsl:element name="field_name">category_rd</xsl:element>							
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">;</xsl:element>							
                </xsl:element>
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">get_classification_group</xsl:element>
                  <xsl:element name="field_name">group_code</xsl:element>							
                </xsl:element>
              </xsl:element>              
              <xsl:element name="output_string_type">Rechnungsvorlage</xsl:element>
              <xsl:element name="string_mapping_list">
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">RESIDENTIAL;VFCUSTCLAS</xsl:element>
                  <xsl:element name="output_string">Vodafone PK-Rechnung</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">RESIDENTIAL;ARCUSTCLAS</xsl:element>
                  <xsl:element name="output_string">Privatkunden Rechnung</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">BUSINESS;VFCUSTCLAS</xsl:element>
                  <xsl:element name="output_string">VF Rechnung</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">BUSINESS;ARCUSTCLAS</xsl:element>
                  <xsl:element name="output_string">Webbill signiert</xsl:element>
                </xsl:element>                
              </xsl:element>
              <xsl:element name="no_mapping_error">Y</xsl:element>
            </xsl:element>    
          </xsl:element>                              
        </xsl:otherwise>
      </xsl:choose>                                                                        
      
      <!-- check if a future dated object exists to make sure no similar transaction was processed -->
      <xsl:element name="CcmFifValidateFutureDatedObjectCmd">
        <xsl:element name="command_id">validate_future_dated_account</xsl:element>
        <xsl:element name="CcmFifValidateFutureDatedObjectInCont">
          <xsl:element name="object_id_ref">
            <xsl:element name="command_id">find_account_number</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="object_type">ACCOUNT</xsl:element>
          <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
            <xsl:element name="effective_date">
              <xsl:value-of select="$desiredDate"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
            <xsl:element name="effective_date_ref">
              <xsl:element name="command_id">get_cycle</xsl:element>
              <xsl:element name="field_name">due_date_with_offset</xsl:element>              
            </xsl:element>
          </xsl:if>
        </xsl:element>    
      </xsl:element>
      
      <!-- set the invoice template on the account -->
      <xsl:element name="CcmFifModifyAccountCmd">
        <xsl:element name="command_id">modify_account</xsl:element>
        <xsl:element name="CcmFifModifyAccountInCont">
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_account_number</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
            <xsl:element name="effective_date">
              <xsl:value-of select="$desiredDate"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
            <xsl:element name="effective_date_ref">
              <xsl:element name="command_id">get_cycle</xsl:element>
              <xsl:element name="field_name">due_date_with_offset</xsl:element>              
            </xsl:element>
          </xsl:if>
          <xsl:element name="doc_template_name_ref">
            <xsl:element name="command_id">map_invoice_template</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>              
          </xsl:element>
        </xsl:element>
      </xsl:element>    
      
      <xsl:choose>
        <xsl:when test="request-param[@name='deliveryType'] = 'WEBBILL'">
          <!-- map document template name from customer category, delivery type and egn -->
          <xsl:element name="CcmFifMapStringCmd">
            <xsl:element name="command_id">mapWebbillPattern</xsl:element>
            <xsl:element name="CcmFifMapStringInCont">
              <xsl:element name="input_string_type">Kundenklassengruppe;EGN-Typ</xsl:element>
              <xsl:element name="input_string_list">
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">get_classification_group</xsl:element>
                  <xsl:element name="field_name">group_code</xsl:element>							
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">
                    <xsl:text>;</xsl:text>
                    <xsl:value-of select="$egnType"/>
                  </xsl:element>							
                </xsl:element>
              </xsl:element>
              <xsl:element name="output_string_type">Berichtvorlage</xsl:element>
              <xsl:element name="string_mapping_list">
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">ARCUSTCLAS;electronic</xsl:element>
                  <xsl:element name="output_string">webBill mit EGN</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">ARCUSTCLAS;paper</xsl:element>
                  <xsl:element name="output_string">webBill mit EGN</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">ARCUSTCLAS;none</xsl:element>
                  <xsl:element name="output_string">webBill ohne EGN</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">VFCUSTCLAS;electronic</xsl:element>
                  <xsl:element name="output_string">Vodafone webBill mit EGN</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">VFCUSTCLAS;paper</xsl:element>
                  <xsl:element name="output_string">Vodafone webBill mit EGN</xsl:element>
                </xsl:element>
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">VFCUSTCLAS;none</xsl:element>
                  <xsl:element name="output_string">Vodafone webBill ohne EGN</xsl:element>
                </xsl:element>                
              </xsl:element>
              <xsl:element name="no_mapping_error">Y</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:when>
        
        <xsl:when test="request-param[@name='deliveryType'] = 'EMAIL'">
          <xsl:element name="CcmFifMapStringCmd">
            <xsl:element name="command_id">mapWebbillPattern</xsl:element>
            <xsl:element name="CcmFifMapStringInCont">
              <xsl:element name="input_string_type">Kundenklassengruppe;Kundenkategorie</xsl:element>
              <xsl:element name="input_string_list">                
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">get_classification_group</xsl:element>
                  <xsl:element name="field_name">group_code</xsl:element>							
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">;</xsl:element>							
                </xsl:element>
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">get_customer_data</xsl:element>
                  <xsl:element name="field_name">category_rd</xsl:element>							
                </xsl:element>
              </xsl:element>
              <xsl:element name="output_string_type">Berichtvorlage</xsl:element>
              <xsl:element name="string_mapping_list">
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">ARCUSTCLAS;RESIDENTIAL</xsl:element>
                  <xsl:element name="output_string">Rechnung per E-Mail</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="no_mapping_error">Y</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:when>
        
        <xsl:otherwise>
          <xsl:element name="CcmFifMapStringCmd">
            <xsl:element name="command_id">mapWebbillPattern</xsl:element>
            <xsl:element name="CcmFifMapStringInCont">
              <xsl:element name="input_string_type">Kundenklassengruppe;Kundenkategorie;EGN-Typ</xsl:element>
              <xsl:element name="input_string_list">                
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">get_classification_group</xsl:element>
                  <xsl:element name="field_name">group_code</xsl:element>							
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">;</xsl:element>							
                </xsl:element>
                <xsl:element name="CcmFifCommandRefCont">
                  <xsl:element name="command_id">get_customer_data</xsl:element>
                  <xsl:element name="field_name">category_rd</xsl:element>							
                </xsl:element>
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">
                    <xsl:text>;</xsl:text>
                    <xsl:value-of select="$egnType"/>			
                  </xsl:element>			
                </xsl:element>
              </xsl:element>
              <xsl:element name="output_string_type">Berichtvorlage</xsl:element>
              <xsl:element name="string_mapping_list">
                <xsl:element name="CcmFifStringMappingCont">
                  <xsl:element name="input_string">ARCUSTCLAS;BUSINESS;electronic</xsl:element>
                  <xsl:element name="output_string">webBill mit EGN</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="no_mapping_error">N</xsl:element>
            </xsl:element>
          </xsl:element>          
        </xsl:otherwise>
      </xsl:choose>
          
      <!-- map document template name from customer category, delivery type and egn -->
      <xsl:element name="CcmFifMapStringCmd">
        <xsl:element name="command_id">mapSummaryPattern</xsl:element>
        <xsl:element name="CcmFifMapStringInCont">
          <xsl:element name="input_string_type">Kundenklassengruppe;Kundenkategorie;EGN-Typ</xsl:element>
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">get_classification_group</xsl:element>
              <xsl:element name="field_name">group_code</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">;</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">get_customer_data</xsl:element>
              <xsl:element name="field_name">category_rd</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text>;</xsl:text>
                <xsl:value-of select="$egnType"/>
              </xsl:element>							
            </xsl:element>
          </xsl:element>
          <xsl:element name="output_string_type">Berichtvorlage</xsl:element>
          <xsl:element name="string_mapping_list">
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">ARCUSTCLAS;BUSINESS;none</xsl:element>
              <xsl:element name="output_string">Sprach Serv. Anschl. Übersicht</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">ARCUSTCLAS;BUSINESS;paper</xsl:element>
              <xsl:element name="output_string">Sprach Serv. Anschl. Übersicht</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">ARCUSTCLAS;BUSINESS;electronic</xsl:element>
              <xsl:element name="output_string">Sprach Serv. Anschl. Übersicht</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifStringMappingCont">
              <xsl:element name="input_string">VFCUSTCLAS;BUSINESS;none</xsl:element>
              <xsl:element name="output_string">VF Sprach Serv. Anschl. Übers.</xsl:element>
            </xsl:element>
          </xsl:element>
          <xsl:element name="no_mapping_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
            
      
      <xsl:if test="$egnEnabled = 'Y'">        
        <!-- map document template name from customer category, delivery type and egn -->
        <xsl:element name="CcmFifMapStringCmd">
          <xsl:element name="command_id">mapEVNPattern</xsl:element>
          <xsl:element name="CcmFifMapStringInCont">
            <xsl:element name="input_string_type">Kundenklassengruppe;Kundenkategorie;Zustellungsart</xsl:element>
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">get_classification_group</xsl:element>
                <xsl:element name="field_name">group_code</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">;</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">get_customer_data</xsl:element>
                <xsl:element name="field_name">category_rd</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">
                  <xsl:text>;</xsl:text>
                  <xsl:value-of select="request-param[@name='deliveryType']"/>
                </xsl:element>							
              </xsl:element>
            </xsl:element>
            <xsl:element name="output_string_type">Berichtvorlage</xsl:element>
            <xsl:element name="string_mapping_list">
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">ARCUSTCLAS;RESIDENTIAL;EMAIL</xsl:element>
                <xsl:element name="output_string">Privatkunden EVN</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">ARCUSTCLAS;RESIDENTIAL;LETTER</xsl:element>
                <xsl:element name="output_string">Privatkunden EVN</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">ARCUSTCLAS;BUSINESS;LETTER</xsl:element>
                <xsl:element name="output_string">Sprach Serv. EVN Gesch.kunden</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">ARCUSTCLAS;BUSINESS;WEBBILL</xsl:element>
                <xsl:element name="output_string">Sprach Serv. EVN Gesch.kunden</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">VFCUSTCLAS;RESIDENTIAL;LETTER</xsl:element>
                <xsl:element name="output_string">Vodafone PK-EVN</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">VFCUSTCLAS;BUSINESS;LETTER</xsl:element>
                <xsl:element name="output_string">VF Sprach Serv. EVN GK</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">VFCUSTCLAS;BUSINESS;WEBBILL</xsl:element>
                <xsl:element name="output_string">VF Sprach Serv. EVN GK</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="no_mapping_error">N</xsl:element>
          </xsl:element>
        </xsl:element>
                
        <xsl:element name="CcmFifMapStringCmd">
          <xsl:element name="command_id">mapDataPattern</xsl:element>
          <xsl:element name="CcmFifMapStringInCont">
            <xsl:element name="input_string_type">Kundenklassengruppe;Kundenkategorie</xsl:element>
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">get_classification_group</xsl:element>
                <xsl:element name="field_name">group_code</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">;</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">get_customer_data</xsl:element>
                <xsl:element name="field_name">category_rd</xsl:element>							
              </xsl:element>
            </xsl:element>
            <xsl:element name="output_string_type">Berichtvorlage</xsl:element>
            <xsl:element name="string_mapping_list">
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">ARCUSTCLAS;BUSINESS</xsl:element>
                <xsl:element name="output_string">Daten Serv. EVN Gesch.kunden</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="no_mapping_error">N</xsl:element>
          </xsl:element>
        </xsl:element>                          
      </xsl:if>
      
       <xsl:element name="CcmFifMapStringCmd">
          <xsl:element name="command_id">mapInternetPattern</xsl:element>
          <xsl:element name="CcmFifMapStringInCont">
            <xsl:element name="input_string_type">Kundenklassengruppe;Kundenkategorie</xsl:element>
            <xsl:element name="input_string_list">
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">get_classification_group</xsl:element>
                <xsl:element name="field_name">group_code</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">;</xsl:element>							
              </xsl:element>
              <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id">get_customer_data</xsl:element>
                <xsl:element name="field_name">category_rd</xsl:element>							
              </xsl:element>
            </xsl:element>
            <xsl:element name="output_string_type">Berichtvorlage</xsl:element>
            <xsl:element name="string_mapping_list">
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">ARCUSTCLAS;BUSINESS</xsl:element>
                <xsl:element name="output_string">IP-Internet Übersicht</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">VFCUSTCLAS;BUSINESS</xsl:element>
                <xsl:element name="output_string">VF IP-Internet Übersicht</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="no_mapping_error">N</xsl:element>
          </xsl:element>
        </xsl:element>  
        	  
      <!-- find document patterns to deactivate -->
      <xsl:element name="CcmFifFindDocumentPatternCmd">
        <xsl:element name="command_id">find_obsolete_docpatt</xsl:element>
        <xsl:element name="CcmFifFindDocumentPatternInCont">
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">find_account_number</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">ACCOUNT</xsl:element>
          <xsl:element name="include_document_template_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">webBill mit EGN</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">webBill ohne EGN</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">Vodafone webBill mit EGN</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">Vodafone webBill ohne EGN</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">Rechnung per E-Mail</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">Privatkunden EVN</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">Vodafone PK-EVN</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">Sprach Serv. Anschl. Übersicht</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">Sprach Serv. EVN Gesch.kunden</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">Daten Serv. EVN Gesch.kunden</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">VF Sprach Serv. Anschl. Übers.</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">VF Sprach Serv. EVN GK</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">IP-Internet Übersicht</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">VF IP-Internet Übersicht</xsl:element>							
            </xsl:element>
            <xsl:for-each select="request-param-list[@name='oldDocumentPatternList']/request-param-list-item">
              <xsl:if test="request-param[@name='documentTemplateName'] != 'webBill mit EGN' and
                request-param[@name='documentTemplateName'] != 'webBill ohne EGN' and
                request-param[@name='documentTemplateName'] != 'Vodafone webBill mit EGN' and
                request-param[@name='documentTemplateName'] != 'Vodafone webBill ohne EGN' and
                request-param[@name='documentTemplateName'] != 'Rechnung per E-Mail' and
                request-param[@name='documentTemplateName'] != 'Privatkunden EVN' and
                request-param[@name='documentTemplateName'] != 'Vodafone PK-EVN' and
                request-param[@name='documentTemplateName'] != 'Sprach Serv. Anschl. Übersicht' and
                request-param[@name='documentTemplateName'] != 'Sprach Serv. EVN Gesch.kunden' and
                request-param[@name='documentTemplateName'] != 'Daten Serv. EVN Gesch.kunden' and
                request-param[@name='documentTemplateName'] != 'VF Sprach Serv. Anschl. Übers.' and
                request-param[@name='documentTemplateName'] != 'VF Sprach Serv. EVN GK' and
                request-param[@name='documentTemplateName'] != 'IP-Internet Übersicht' and
                request-param[@name='documentTemplateName'] != 'VF IP-Internet Übersicht'">
                <xsl:element name="CcmFifPassingValueCont">
                  <xsl:element name="value">
                    <xsl:value-of select="request-param[@name='documentTemplateName']"/>
                  </xsl:element>
                </xsl:element>
              </xsl:if>
            </xsl:for-each>                
          </xsl:element>
          <xsl:element name="exclude_document_template_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">mapSummaryPattern</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>              
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">mapWebbillPattern</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>              
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">mapEVNPattern</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>              
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">mapDataPattern</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>              
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">mapInternetPattern</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>              
            </xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
            <xsl:element name="effective_date">
              <xsl:value-of select="$desiredDate"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
            <xsl:element name="effective_date_ref">
              <xsl:element name="command_id">get_cycle</xsl:element>
              <xsl:element name="field_name">due_date_with_offset</xsl:element>              
            </xsl:element>
          </xsl:if>            
        </xsl:element>
      </xsl:element>
      
      <!-- stop the obsolete document patterns -->
      <xsl:element name="CcmFifStopDocumentPatternCmd">
        <xsl:element name="command_id">stop_obsolete_docpatt</xsl:element>
        <xsl:element name="CcmFifStopDocumentPatternInCont">
          <xsl:element name="document_pattern_id_list_ref">
            <xsl:element name="command_id">find_obsolete_docpatt</xsl:element>
            <xsl:element name="field_name">document_pattern_id_list</xsl:element>              
          </xsl:element>
          <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
            <xsl:element name="effective_date">
              <xsl:value-of select="$desiredDate"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
            <xsl:element name="effective_date_ref">
              <xsl:element name="command_id">get_cycle</xsl:element>
              <xsl:element name="field_name">due_date_with_offset</xsl:element>              
            </xsl:element>
          </xsl:if>            
        </xsl:element>
      </xsl:element>
      
      <!-- find document patterns we need to create with wrong output device. They also have to be deactivated -->
      <xsl:element name="CcmFifFindDocumentPatternCmd">
        <xsl:element name="command_id">findDPWrongOutputDevice</xsl:element>
        <xsl:element name="CcmFifFindDocumentPatternInCont">
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">find_account_number</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">ACCOUNT</xsl:element>
          <xsl:element name="include_document_template_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">mapSummaryPattern</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>              
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">mapWebbillPattern</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>              
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">mapEVNPattern</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>              
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">mapDataPattern</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>              
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">mapInternetPattern</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>              
            </xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
            <xsl:element name="effective_date">
              <xsl:value-of select="$desiredDate"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
            <xsl:element name="effective_date_ref">
              <xsl:element name="command_id">get_cycle</xsl:element>
              <xsl:element name="field_name">due_date_with_offset</xsl:element>              
            </xsl:element>
          </xsl:if>
          <xsl:element name="output_device_rd">
            <xsl:if test="$outputDevice = 'WEBBILL'">PRINTER</xsl:if>            
            <xsl:if test="$outputDevice = 'PRINTER'">WEBBILL</xsl:if>            
          </xsl:element>            
        </xsl:element>
      </xsl:element>
      
      <!-- stop the wrong document patterns -->
      <xsl:element name="CcmFifStopDocumentPatternCmd">
        <xsl:element name="command_id">stopDPWrongOutputDevice</xsl:element>
        <xsl:element name="CcmFifStopDocumentPatternInCont">
          <xsl:element name="document_pattern_id_list_ref">
            <xsl:element name="command_id">findDPWrongOutputDevice</xsl:element>
            <xsl:element name="field_name">document_pattern_id_list</xsl:element>              
          </xsl:element>
          <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
            <xsl:element name="effective_date">
              <xsl:value-of select="$desiredDate"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
            <xsl:element name="effective_date_ref">
              <xsl:element name="command_id">get_cycle</xsl:element>
              <xsl:element name="field_name">due_date_with_offset</xsl:element>              
            </xsl:element>
          </xsl:if>            
        </xsl:element>
      </xsl:element>
      
      <!-- find customer document patterns to deactivate -->
      <xsl:element name="CcmFifFindDocumentPatternCmd">
        <xsl:element name="command_id">find_customer_docpatt</xsl:element>
        <xsl:element name="CcmFifFindDocumentPatternInCont">
          <xsl:element name="supported_object_id_ref">
            <xsl:element name="command_id">get_account_data</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="supported_object_type_rd">CUST</xsl:element>
          <xsl:element name="include_document_template_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">webBill mit EGN</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">webBill ohne EGN</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">Vodafone webBill mit EGN</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">Vodafone webBill ohne EGN</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">Rechnung per E-Mail</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">Privatkunden EVN</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">Vodafone PK-EVN</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">Sprach Serv. Anschl. Übersicht</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">Sprach Serv. EVN Gesch.kunden</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">Daten Serv. EVN Gesch.kunden</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">VF Sprach Serv. Anschl. Übers.</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">VF Sprach Serv. EVN GK</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">IP-Internet Übersicht</xsl:element>							
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">VF IP-Internet Übersicht</xsl:element>							
            </xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
			<xsl:value-of select="$tomorrow"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- stop the obsolete document patterns -->
      <xsl:element name="CcmFifStopDocumentPatternCmd">
        <xsl:element name="command_id">stop_customer_docpatt</xsl:element>
        <xsl:element name="CcmFifStopDocumentPatternInCont">
          <xsl:element name="document_pattern_id_list_ref">
            <xsl:element name="command_id">find_customer_docpatt</xsl:element>
            <xsl:element name="field_name">document_pattern_id_list</xsl:element>              
          </xsl:element>
          <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
            <xsl:element name="effective_date">
              <xsl:value-of select="$desiredDate"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
            <xsl:element name="effective_date_ref">
              <xsl:element name="command_id">get_cycle</xsl:element>
              <xsl:element name="field_name">due_date_with_offset</xsl:element>              
            </xsl:element>
          </xsl:if>            
        </xsl:element>
      </xsl:element>
      
      <!-- set printer destination on mailing depending on delivery type and customer category -->
      <xsl:element name="CcmFifModifyMailingCmd">
        <xsl:element name="command_id">modify_mailing</xsl:element>
        <xsl:element name="CcmFifModifyMailingInCont">
          <xsl:element name="mailing_id_ref">
            <xsl:element name="command_id">get_account_data</xsl:element>
            <xsl:element name="field_name">mailing_id</xsl:element>
          </xsl:element>
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">get_account_data</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
            <xsl:element name="effective_date">
              <xsl:value-of select="$desiredDate"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
            <xsl:element name="effective_date_ref">
              <xsl:element name="command_id">get_cycle</xsl:element>
              <xsl:element name="field_name">due_date_with_offset</xsl:element>              
            </xsl:element>
          </xsl:if>
          <xsl:element name="printer_destination_rd_ref">
            <xsl:element name="command_id">map_printer_destination</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- concat the results of the find doc patt command and the indicator, if a
        suitable document template was found --> 
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">concat_indicator_string</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">find_delivery_type_docpatt</xsl:element>
              <xsl:element name="field_name">document_pattern_found</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">_</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
              <xsl:element name="command_id">map_document_template</xsl:element>
              <xsl:element name="field_name">output_string_empty</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>							
      
      <!-- Create Document Pattern for invoice delivery type -->
      <xsl:element name="CcmFifCreateDocumentPatternCmd">
        <xsl:element name="command_id">createWebbillPattern</xsl:element>
        <xsl:element name="CcmFifCreateDocumentPatternInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">get_account_data</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_account_number</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="mailing_id_ref">
            <xsl:element name="command_id">get_account_data</xsl:element>
            <xsl:element name="field_name">mailing_id</xsl:element>
          </xsl:element>
          <xsl:element name="output_device_rd">
            <xsl:value-of select="$outputDevice"/>
          </xsl:element>
          <xsl:element name="doc_template_name_ref">
            <xsl:element name="command_id">mapWebbillPattern</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>              
          </xsl:element>
          <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
            <xsl:element name="effective_date">
              <xsl:value-of select="$desiredDate"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
            <xsl:element name="effective_date_ref">
              <xsl:element name="command_id">get_cycle</xsl:element>
              <xsl:element name="field_name">due_date_with_offset</xsl:element>              
            </xsl:element>
          </xsl:if>
          <xsl:element name="ignore_if_exists">Y</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">mapWebbillPattern</xsl:element>
            <xsl:element name="field_name">output_string_empty</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create Document Pattern for invoice delivery type -->
      <xsl:element name="CcmFifCreateDocumentPatternCmd">
        <xsl:element name="command_id">createSummaryPattern</xsl:element>
        <xsl:element name="CcmFifCreateDocumentPatternInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">get_account_data</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="account_number_ref">
            <xsl:element name="command_id">find_account_number</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>
          </xsl:element>
          <xsl:element name="mailing_id_ref">
            <xsl:element name="command_id">get_account_data</xsl:element>
            <xsl:element name="field_name">mailing_id</xsl:element>
          </xsl:element>
          <xsl:element name="output_device_rd">
            <xsl:value-of select="$outputDevice"/>
          </xsl:element>
          <xsl:element name="doc_template_name_ref">
            <xsl:element name="command_id">mapSummaryPattern</xsl:element>
            <xsl:element name="field_name">output_string</xsl:element>              
          </xsl:element>
          <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
            <xsl:element name="effective_date">
              <xsl:value-of select="$desiredDate"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
            <xsl:element name="effective_date_ref">
              <xsl:element name="command_id">get_cycle</xsl:element>
              <xsl:element name="field_name">due_date_with_offset</xsl:element>              
            </xsl:element>
          </xsl:if>
          <xsl:element name="ignore_if_exists">Y</xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">mapSummaryPattern</xsl:element>
            <xsl:element name="field_name">output_string_empty</xsl:element>
          </xsl:element>
          <xsl:element name="required_process_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:if test="$egnEnabled = 'Y'">
        <!-- Create Document Pattern for invoice delivery type -->
        <xsl:element name="CcmFifCreateDocumentPatternCmd">
          <xsl:element name="command_id">createEVNPattern</xsl:element>
          <xsl:element name="CcmFifCreateDocumentPatternInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">get_account_data</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_account_number</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="mailing_id_ref">
              <xsl:element name="command_id">get_account_data</xsl:element>
              <xsl:element name="field_name">mailing_id</xsl:element>
            </xsl:element>
            <xsl:element name="output_device_rd">
              <xsl:value-of select="$outputDevice"/>
            </xsl:element>
            <xsl:element name="doc_template_name_ref">
              <xsl:element name="command_id">mapEVNPattern</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>              
            </xsl:element>
            <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
              <xsl:element name="effective_date">
                <xsl:value-of select="$desiredDate"/>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
              <xsl:element name="effective_date_ref">
                <xsl:element name="command_id">get_cycle</xsl:element>
                <xsl:element name="field_name">due_date_with_offset</xsl:element>              
              </xsl:element>
            </xsl:if>
            <xsl:element name="ignore_if_exists">Y</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">mapEVNPattern</xsl:element>
              <xsl:element name="field_name">output_string_empty</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- Create Document Pattern for invoice delivery type -->
        <xsl:element name="CcmFifCreateDocumentPatternCmd">
          <xsl:element name="command_id">createDataPattern</xsl:element>
          <xsl:element name="CcmFifCreateDocumentPatternInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">get_account_data</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_account_number</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="mailing_id_ref">
              <xsl:element name="command_id">get_account_data</xsl:element>
              <xsl:element name="field_name">mailing_id</xsl:element>
            </xsl:element>
            <xsl:element name="output_device_rd">
              <xsl:value-of select="$outputDevice"/>
            </xsl:element>
            <xsl:element name="doc_template_name_ref">
              <xsl:element name="command_id">mapDataPattern</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>              
            </xsl:element>
            <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
              <xsl:element name="effective_date">
                <xsl:value-of select="$desiredDate"/>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
              <xsl:element name="effective_date_ref">
                <xsl:element name="command_id">get_cycle</xsl:element>
                <xsl:element name="field_name">due_date_with_offset</xsl:element>              
              </xsl:element>
            </xsl:if>
            <xsl:element name="ignore_if_exists">Y</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">mapDataPattern</xsl:element>
              <xsl:element name="field_name">output_string_empty</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
        <!-- Create Document Pattern for invoice delivery type -->
        <xsl:element name="CcmFifCreateDocumentPatternCmd">
          <xsl:element name="command_id">createInternetPattern</xsl:element>
          <xsl:element name="CcmFifCreateDocumentPatternInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">get_account_data</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">find_account_number</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
            <xsl:element name="mailing_id_ref">
              <xsl:element name="command_id">get_account_data</xsl:element>
              <xsl:element name="field_name">mailing_id</xsl:element>
            </xsl:element>
            <xsl:element name="output_device_rd">
              <xsl:value-of select="$outputDevice"/>
            </xsl:element>
            <xsl:element name="doc_template_name_ref">
              <xsl:element name="command_id">mapInternetPattern</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>              
            </xsl:element>
            <xsl:if test="request-param[@name='useBillCycleDate'] != 'Y'">
              <xsl:element name="effective_date">
                <xsl:value-of select="$desiredDate"/>
              </xsl:element>
            </xsl:if>
            <xsl:if test="request-param[@name='useBillCycleDate'] = 'Y'">
              <xsl:element name="effective_date_ref">
                <xsl:element name="command_id">get_cycle</xsl:element>
                <xsl:element name="field_name">due_date_with_offset</xsl:element>              
              </xsl:element>
            </xsl:if>
            <xsl:element name="ignore_if_exists">Y</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">mapInternetPattern</xsl:element>
              <xsl:element name="field_name">output_string_empty</xsl:element>
            </xsl:element>
            <xsl:element name="required_process_ind">N</xsl:element>
          </xsl:element>
        </xsl:element>
      
      <!-- create the document patterns which according to KBA don't exist yet -->
      <xsl:variable name="useBillCycleDate" select="request-param[@name='useBillCycleDate']" />
      <xsl:for-each select="request-param-list[@name='newDocumentPatternList']/request-param-list-item">
        <xsl:if test="request-param[@name='documentTemplateName'] != 'webBill mit EGN' and
          request-param[@name='documentTemplateName'] != 'webBill ohne EGN' and
          request-param[@name='documentTemplateName'] != 'Vodafone webBill mit EGN' and
          request-param[@name='documentTemplateName'] != 'Vodafone webBill ohne EGN' and
          request-param[@name='documentTemplateName'] != 'Rechnung per E-Mail' and
          request-param[@name='documentTemplateName'] != 'Privatkunden EVN' and
          request-param[@name='documentTemplateName'] != 'Vodafone PK-EVN' and
          request-param[@name='documentTemplateName'] != 'Sprach Serv. Anschl. Übersicht' and
          request-param[@name='documentTemplateName'] != 'Sprach Serv. EVN Gesch.kunden' and
          request-param[@name='documentTemplateName'] != 'Daten Serv. EVN Gesch.kunden' and
          request-param[@name='documentTemplateName'] != 'VF Sprach Serv. Anschl. Übers.' and
          request-param[@name='documentTemplateName'] != 'VF Sprach Serv. EVN GK' and
          request-param[@name='documentTemplateName'] != 'IP-Internet Übersicht' and
          request-param[@name='documentTemplateName'] != 'VF IP-Internet Übersicht'">
	        <xsl:element name="CcmFifCreateDocumentPatternCmd">
	          <xsl:element name="command_id">create_desired_docpatt</xsl:element>
	          <xsl:element name="CcmFifCreateDocumentPatternInCont">
	            <xsl:element name="customer_number_ref">
	              <xsl:element name="command_id">get_account_data</xsl:element>
	              <xsl:element name="field_name">customer_number</xsl:element>
	            </xsl:element>
	            <xsl:element name="account_number_ref">
	              <xsl:element name="command_id">find_account_number</xsl:element>
	              <xsl:element name="field_name">output_string</xsl:element>
	            </xsl:element>
	            <xsl:element name="mailing_id_ref">
	              <xsl:element name="command_id">get_account_data</xsl:element>
	              <xsl:element name="field_name">mailing_id</xsl:element>
	            </xsl:element>
	            <xsl:element name="output_device_rd">
                  <xsl:value-of select="$outputDevice"/>
	            </xsl:element>
	            <xsl:element name="doc_template_name">
	              <xsl:value-of select="request-param[@name='documentTemplateName']"/>
	            </xsl:element>
	            <xsl:if test="$useBillCycleDate != 'Y'">
	              <xsl:element name="effective_date">
	                <xsl:value-of select="$desiredDate"/>
	              </xsl:element>
	            </xsl:if>
	            <xsl:if test="$useBillCycleDate = 'Y'">
	              <xsl:element name="effective_date_ref">
	                <xsl:element name="command_id">get_cycle</xsl:element>
	                <xsl:element name="field_name">due_date_with_offset</xsl:element>              
	              </xsl:element>
	            </xsl:if>
	          </xsl:element>
	        </xsl:element>
	     </xsl:if>
      </xsl:for-each>
            
      <xsl:variable name="contactText">
        <xsl:text>Rechnungszustellung über </xsl:text>
        <xsl:value-of select="request-param[@name='clientName']"/>
        <xsl:text> auf </xsl:text>
        <xsl:value-of select="request-param[@name='deliveryType']"/>
        <xsl:text> geändert.&#xA;TransactionID: </xsl:text>
        <xsl:value-of select="request-param[@name='transactionID']"/>
        <xsl:text>&#xA;Rechnungskonto: </xsl:text>
        <xsl:value-of select="request-param[@name='accountNumber']"/>
      </xsl:variable>
            
      <!-- Create Contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">get_account_data</xsl:element>
            <xsl:element name="field_name">customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="contact_type_rd">SET_DELIV_TYPE</xsl:element>
          <xsl:element name="short_description">Rechnungszustellung geändert</xsl:element>
          <xsl:element name="long_description_text">
            <xsl:value-of select="$contactText"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:if test="request-param[@name='clientName'] != 'CODB'">
        <!-- Create KBA notification  -->
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <!-- Get today's date -->
          <xsl:element name="command_id">create_kba_notification_1</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="notification_action_name">createKBANotification</xsl:element>
            <xsl:element name="target_system">KBA</xsl:element>
            <xsl:element name="parameter_value_list">
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                <xsl:element name="parameter_value_ref">
                  <xsl:element name="command_id">get_account_data</xsl:element>
                  <xsl:element name="field_name">customer_number</xsl:element>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TYPE</xsl:element>
                <xsl:element name="parameter_value">CONTACT</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CATEGORY</xsl:element>
                <xsl:element name="parameter_value">Bill</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">USER_NAME</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="request-param[@name='clientName']"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">INPUT_CHANNEL</xsl:element>
                <xsl:element name="parameter_value">CCB</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">WORK_DATE</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="$today"/>
                </xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TEXT</xsl:element>
                <xsl:element name="parameter_value">
                  <xsl:value-of select="$contactText"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>     
          </xsl:element>
        </xsl:element>
      </xsl:if>          
        
      </xsl:otherwise>
      </xsl:choose>
      
    </xsl:element>    
  </xsl:template>
</xsl:stylesheet>
