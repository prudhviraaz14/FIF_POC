<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for switching customers to webbill

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
    <xsl:element name="client_name">SLS</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>    
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">
      <!-- lock the account to avoid concurrent updates -->      	
      <xsl:element name="CcmFifLockObjectCmd">
        <xsl:element name="CcmFifLockObjectInCont">
          <xsl:element name="object_id">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="object_type">ACCOUNT</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- Validate preconditions for webbill -->
      <xsl:element name="CcmFifValidateWebbillPreconditionsCmd">
        <xsl:element name="command_id">validate_webbill_preconditions_1</xsl:element>
        <xsl:element name="CcmFifValidateWebbillPreconditionsInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="effective_date">
          	<xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
          </xsl:element>
          <xsl:element name="bank_account_number">
            <xsl:value-of select="request-param[@name='BANK_ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="bank_clearing_code">
            <xsl:value-of select="request-param[@name='BANK_CLEARING_CODE']"/>
          </xsl:element>
          <xsl:element name="owner_full_name">
            <xsl:value-of select="request-param[@name='OWNER_FULL_NAME']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- update acc inf only when email address is provided -->
      <xsl:if test="(request-param[@name='EMAIL_ADDRESS'] != '')">
        <!-- modify Access Information -->
        <xsl:element name="CcmFifUpdateAccessInformCmd">
          <xsl:element name="CcmFifUpdateAccessInformInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
            </xsl:element>
            <xsl:element name="entity_ref">
              <xsl:element name="command_id">validate_webbill_preconditions_1</xsl:element>
              <xsl:element name="field_name">entity_id</xsl:element>
            </xsl:element>
            <xsl:element name="access_information_ref">
              <xsl:element name="command_id">validate_webbill_preconditions_1</xsl:element>
              <xsl:element name="field_name">access_information_id</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
            </xsl:element>
            <xsl:element name="access_information_type_ref">
              <xsl:element name="command_id">validate_webbill_preconditions_1</xsl:element>
              <xsl:element name="field_name">access_information_type</xsl:element>
            </xsl:element>
            <xsl:element name="email_address">
              <xsl:value-of select="request-param[@name='EMAIL_ADDRESS']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        <!-- end if -->
      </xsl:if>  
      
      <!-- stop the obsolete document patterns -->
      <xsl:variable name="EffectiveDate" select="request-param[@name='EFFECTIVE_DATE']" />
      <xsl:element name="CcmFifStopDocumentPatternCmd">
        <xsl:element name="CcmFifStopDocumentPatternInCont">
          <xsl:element name="document_pattern_id_list">
            <xsl:for-each select="request-param-list[@name='DOCUMENT_PATTERN_LIST']/request-param-list-item">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="document_pattern_id">
                  <xsl:value-of select="request-param[@name='DOCUMENT_PATTERN_ID']"/>
                </xsl:element>
              </xsl:element>
            </xsl:for-each>  
          </xsl:element>
          <xsl:element name="effective_date">
       	    <xsl:value-of select="$EffectiveDate"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
            
      <!-- modify mailing -->
      <xsl:element name="CcmFifModifyMailingCmd">
        <xsl:element name="CcmFifModifyMailingInCont">
          <xsl:element name="mailing_id_ref">
            <xsl:element name="command_id">validate_webbill_preconditions_1</xsl:element>
            <xsl:element name="field_name">mailing_id</xsl:element>
          </xsl:element>
          <!-- not the customer number from the request, but the customer number that owns 
               the account and the mailing -->
          <xsl:element name="customer_number_ref">
            <xsl:element name="command_id">validate_webbill_preconditions_1</xsl:element>
            <xsl:element name="field_name">account_customer_number</xsl:element>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
          </xsl:element>
          <xsl:element name="document_type_rd">BILL</xsl:element>          
          <xsl:element name="printer_destination_rd">
            <xsl:if test="request-param[@name='CLASSIFICATION_RD'] = 'A1' or
              request-param[@name='CLASSIFICATION_RD'] = 'A2' or
              request-param[@name='CLASSIFICATION_RD'] = 'A3' or
              request-param[@name='CLASSIFICATION_RD'] = 'A4' or
              request-param[@name='CLASSIFICATION_RD'] = 'VC'">
              <xsl:text>Papier&amp;Webbill</xsl:text>
            </xsl:if>      
            <xsl:if test="request-param[@name='CLASSIFICATION_RD'] != 'A1' and
              request-param[@name='CLASSIFICATION_RD'] != 'A2' and
              request-param[@name='CLASSIFICATION_RD'] != 'A3' and
              request-param[@name='CLASSIFICATION_RD'] != 'A4' and
              request-param[@name='CLASSIFICATION_RD'] != 'VC'">
              <xsl:text>webBill</xsl:text>
            </xsl:if>            
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- modify account -->
      <xsl:if test="request-param[@name='CLASSIFICATION_RD'] = 'B1' or
        request-param[@name='CLASSIFICATION_RD'] = 'B2' or
        request-param[@name='CLASSIFICATION_RD'] = 'B3' or
        request-param[@name='CLASSIFICATION_RD'] = 'B4' or
        request-param[@name='CLASSIFICATION_RD'] = 'C1' or
        request-param[@name='CLASSIFICATION_RD'] = 'C2' or
        request-param[@name='CLASSIFICATION_RD'] = 'C3'">
        <xsl:element name="CcmFifModifyAccountCmd">
          <xsl:element name="CcmFifModifyAccountInCont">
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
            </xsl:element>
            <xsl:element name="doc_template_name">Webbill signiert</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <!-- create document pattern  -->
      <xsl:element name="CcmFifCreateDocumentPatternCmd">
        <xsl:element name="CcmFifCreateDocumentPatternInCont">
          <xsl:element name="customer_number"></xsl:element>
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="mailing_id_ref">
            <xsl:element name="command_id">validate_webbill_preconditions_1</xsl:element>
            <xsl:element name="field_name">mailing_id</xsl:element>
          </xsl:element>
          <xsl:element name="output_device_rd">WEBBILL</xsl:element>
          <xsl:element name="doc_template_name">
          	<xsl:value-of select="request-param[@name='DOCUMENT_TEMPLATE_NAME']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- the two following commands are only executed if bank account info is provided -->
      <xsl:if test="(request-param[@name='BANK_ACCOUNT_NUMBER'] != '')
        or (request-param[@name='BANK_CLEARING_CODE'] != '')
        or (request-param[@name='OWNER_FULL_NAME'] != '')">
        <!-- create bank account -->
        <xsl:element name="CcmFifCreateBankAccountCmd">
          <xsl:element name="command_id">create_bank_account_1</xsl:element>
          <xsl:element name="CcmFifCreateBankAccountInCont">
            <!-- not the customer number from the request, but the customer number that owns 
              the account and the mailing -->
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">validate_webbill_preconditions_1</xsl:element>
              <xsl:element name="field_name">account_customer_number</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
            </xsl:element>
            <xsl:element name="bank_account_number">
              <xsl:value-of select="request-param[@name='BANK_ACCOUNT_NUMBER']"/>
            </xsl:element>
            <xsl:element name="owner_full_name">
              <xsl:value-of select="request-param[@name='OWNER_FULL_NAME']"/>
            </xsl:element>
            <xsl:element name="bank_clearing_code">
              <xsl:value-of select="request-param[@name='BANK_CLEARING_CODE']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- modify account -->
        <xsl:element name="CcmFifModifyAccountCmd">
          <xsl:element name="CcmFifModifyAccountInCont">
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:element>
            <xsl:element name="bank_account_id_ref">
              <xsl:element name="command_id">create_bank_account_1</xsl:element>
              <xsl:element name="field_name">bank_account_id</xsl:element>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
            </xsl:element>
            <xsl:element name="method_of_payment">DIRECT_DEBIT</xsl:element>
            <xsl:element name="direct_debit_authoriz_date">
              <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
      </xsl:if>
      
      <!-- create contact -->
      <xsl:element name="CcmFifCreateContactCmd">
        <xsl:element name="CcmFifCreateContactInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="contact_type_rd">STAMM_AEND</xsl:element>
          <xsl:element name="caller_name">SYSTEM</xsl:element>
          <xsl:element name="caller_phone_number">SYSTEM</xsl:element>
          <xsl:element name="author_name">webBill</xsl:element>
          <xsl:element name="short_description">webBill-Migration</xsl:element>
          <xsl:element name="long_description_text">Kunde auf webBill umgestellt. Quelle: <xsl:value-of select="request-param[@name='DATA_SOURCE']"/></xsl:element>
          <xsl:element name="trouble_ticket_requested_ind">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Create KBA notification  -->
      <xsl:element name="CcmFifCreateExternalNotificationCmd">
        <!-- Get today's date -->
        <xsl:variable name="today" select="dateutils:getCurrentDate()"/> 
        <xsl:element name="command_id">create_kba_notification_1</xsl:element>
        <xsl:element name="CcmFifCreateExternalNotificationInCont">
          <xsl:element name="effective_date">
              <xsl:if test="request-param[@name='EFFECTIVE_DATE'] != ''">
                <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
              </xsl:if>            
              <xsl:if test="request-param[@name='EFFECTIVE_DATE'] = ''">
                <xsl:value-of select="$today"/>
              </xsl:if>                          
          </xsl:element>                
          <xsl:element name="notification_action_name">createKBANotification</xsl:element>
          <xsl:element name="target_system">KBA</xsl:element>
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
                <xsl:element name="parameter_value"><xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/></xsl:element>
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
                <xsl:element name="parameter_value">SLS-Clearing</xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">WORK_DATE</xsl:element>
                <xsl:element name="parameter_value">
                    <xsl:if test="request-param[@name='EFFECTIVE_DATE'] != ''">
                      <xsl:value-of select="request-param[@name='EFFECTIVE_DATE']"/>
                    </xsl:if>            
                    <xsl:if test="request-param[@name='EFFECTIVE_DATE'] = ''">
                      <xsl:value-of select="$today"/>
                    </xsl:if>                          
                </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
                <xsl:element name="parameter_name">TEXT</xsl:element>
                <xsl:element name="parameter_value">
                    <xsl:text>Kunde auf webBill umgestellt. Quelle: </xsl:text>
                    <xsl:value-of select="request-param[@name='DATA_SOURCE']"/>
                    <xsl:text>.</xsl:text>
                </xsl:element>
            </xsl:element>
          </xsl:element>     
        </xsl:element>
      </xsl:element>          

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
