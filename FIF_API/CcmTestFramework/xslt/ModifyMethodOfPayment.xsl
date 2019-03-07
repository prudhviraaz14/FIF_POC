<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for modifying method of payment

  @author iarizova
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1"
    indent="yes" method="xml"/>
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
     
      <!-- use directDebitAuthorizDate if it is provided, validFrom otherwise -->
      <xsl:variable name="DirectDebitAuthorizDate">  
        <xsl:choose>
          <xsl:when test="request-param[@name='directDebitAuthorizDate'] != ''">
            <xsl:value-of select="request-param[@name='directDebitAuthorizDate']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='validFrom']"/>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>
      
      <xsl:if test="request-param[@name='accountNumber'] = ''">
        <xsl:element name="CcmFifReadExternalNotificationCmd">
          <xsl:element name="command_id">read_account_number</xsl:element>
          <xsl:element name="CcmFifReadExternalNotificationInCont">
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
          </xsl:element>
        </xsl:element>        
      </xsl:if>

      <xsl:if test="request-param[@name='customerNumber'] = ''">
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
      
      <xsl:if test="request-param[@name='customerNumber'] != '' and 
        request-param[@name='customerNumber'] != ''">
        <xsl:element name="CcmFifValidateObjectOwnerCmd">
          <xsl:element name="command_id">validate_account_owner_1</xsl:element>
          <xsl:element name="CcmFifValidateObjectOwnerInCont">
            <xsl:element name="object_type">AC</xsl:element>
            <xsl:element name="object_id">
              <xsl:value-of select="request-param[@name='accountNumber']"/>
            </xsl:element>
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="raise_error">Y</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- the following command is only executed if bank account info is provided -->
      <xsl:if test="request-param[@name='paymentMethod'] = 'DIRECT_DEBIT' and
      		(request-param[@name='bankAccountNumber'] != ''
      	    or request-param[@name='bankCode'] != ''
      	    or request-param[@name='owner'] != ''
            or request-param[@name='iban'] != '')">
      <!-- create bank account -->
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
              <xsl:element name="command_id">read_customer_number</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>              
            </xsl:element>
          </xsl:if>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='validFrom']"/>
          </xsl:element>
          <xsl:element name="bank_account_number">
            <xsl:value-of select="request-param[@name='bankAccountNumber']"/>
          </xsl:element>
          <xsl:element name="owner_full_name">
            <xsl:value-of select="request-param[@name='owner']"/>
          </xsl:element>
          <xsl:element name="bank_clearing_code">
            <xsl:value-of select="request-param[@name='bankCode']"/>
          </xsl:element>
          <xsl:element name="bank_identifier_code">
            <xsl:value-of select="request-param[@name='bic']"/>
          </xsl:element>
          <xsl:element name="internat_bank_account_number">
            <xsl:value-of select="request-param[@name='iban']"/>
          </xsl:element>        
          <xsl:element name="bank_name">
            <xsl:value-of select="request-param[@name='bankName']"/>
          </xsl:element>               
          <xsl:element name="sepa_check_functional_error_ind">
            <xsl:value-of select="request-param[@name='sepaCheckFunctionalErrorInd']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      </xsl:if>

      <!-- Modify Account -->
      <xsl:element name="CcmFifModifyAccountCmd">
        <xsl:element name="command_id">modify_account_1</xsl:element>
        <xsl:element name="CcmFifModifyAccountInCont">
          <xsl:if test="request-param[@name='accountNumber'] != ''">
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='accountNumber']"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="request-param[@name='accountNumber'] = ''">
            <xsl:element name="account_number_ref">
              <xsl:element name="command_id">read_account_number</xsl:element>
              <xsl:element name="field_name">parameter_value</xsl:element>              
            </xsl:element>
          </xsl:if>
          <xsl:element name="bank_account_id_ref">
            <xsl:element name="command_id">create_bank_account_1</xsl:element>
            <xsl:element name="field_name">bank_account_id</xsl:element>
          </xsl:element>
          <xsl:element name="mailing_id">
            <xsl:value-of select="request-param[@name='mailingId']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='validFrom']"/>
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
          <xsl:element name="payment_term_rd">
            <xsl:value-of select="request-param[@name='paymentTermRd']"/>
          </xsl:element>
          <xsl:element name="zero_charge_ind">
            <xsl:value-of select="request-param[@name='zeroChargeInd']"/>
          </xsl:element>
          <xsl:element name="usage_limit">
            <xsl:value-of select="request-param[@name='usageLimit']"/>
          </xsl:element>
          <xsl:element name="customer_account_id">
            <xsl:value-of select="request-param[@name='customerAccountId']"/>
          </xsl:element>
          <xsl:element name="output_device_rd">
            <xsl:value-of select="request-param[@name='outputDeviceRd']"/>
          </xsl:element>
          <xsl:element name="direct_debit_authoriz_date">
              <xsl:value-of select="$DirectDebitAuthorizDate"/>
          </xsl:element>  
          <xsl:element name="mandate_reference_id">
            <xsl:value-of select="request-param[@name='mandateReferenceID']"/>
          </xsl:element>
          <xsl:element name="mandate_signature_date">
            <xsl:value-of select="request-param[@name='signatureDate']"/>
          </xsl:element>            
          <xsl:element name="mandate_recurring_indicator">
            <xsl:value-of select="request-param[@name='recurringIndicator']"/>
          </xsl:element>            
          <xsl:element name="mandate_b2b_indicator">
            <xsl:value-of select="request-param[@name='mandateB2BIndicator']"/>
          </xsl:element>            
          <xsl:element name="mandate_status_rd">
            <xsl:value-of select="request-param[@name='mandateStatus']"/>
          </xsl:element>            
          <xsl:element name="force_manual_payment_ind_ref">
            <xsl:element name="command_id">create_bank_account_1</xsl:element>
            <xsl:element name="field_name">sepa_functional_error_occured</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create KBA notification -->
      <xsl:if test="request-param[@name='paymentMethod'] = 'DIRECT_DEBIT' and
					(request-param[@name='bankAccountNumber'] != ''
					or request-param[@name='bankCode'] != ''
					or request-param[@name='owner'] != ''
					or request-param[@name='iban'] != '')">
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
                              <xsl:element name="command_id">read_customer_number</xsl:element>
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
                <xsl:if test="request-param[@name='accountNumber'] != ''">
                  <xsl:element name="parameter_value">
                    <xsl:value-of select="request-param[@name='accountNumber']"/>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="request-param[@name='accountNumber'] = ''">
                  <xsl:element name="parameter_value_ref">
                    <xsl:element name="command_id">read_account_number</xsl:element>
                    <xsl:element name="field_name">parameter_value</xsl:element>              
                  </xsl:element>
                </xsl:if>
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
                  <xsl:text>Bitte anhand der Kontonummer und Bankleitzahl die IBAN und BIC ermitteln und die Zahlungsart auf Bankeinzug ändern: BLZ </xsl:text>
                  <xsl:value-of select="request-param[@name='bankCode']"/>
                  <xsl:text> Konto-Nr.  </xsl:text>
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
			

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
