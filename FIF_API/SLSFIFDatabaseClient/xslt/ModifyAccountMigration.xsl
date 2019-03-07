<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for modifying an account
  
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

    <xsl:variable name="bank_account_id">
      <xsl:value-of select="substring(request-param[@name='INTERNAL_TEXT'],1,16)"/>
    </xsl:variable>

    <xsl:variable name="effective_date">
      <xsl:value-of select="substring(request-param[@name='INTERNAL_TEXT'],18,10)"/>
    </xsl:variable>

    <xsl:variable name="effective_date_ccb">
      <xsl:value-of select="dateutils:convertOPMDate(substring(request-param[@name='INTERNAL_TEXT'],18,10))"/>        
    </xsl:variable>  
    
    
    
    <xsl:variable name="error_text">
      <xsl:choose>
        <xsl:when
          test="(request-param[@name='ERROR_CODE'] = '00') or (request-param[@name='ERROR_CODE'] = '0')">
          <xsl:text/>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '10')">
          <xsl:text>BLZ is not valid</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '11')">
          <xsl:text>Account number check sum is invalid.</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '13')">
          <xsl:text>The BLZ is marked for deletion and has been replaced by its following BLZ. This is not an error</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '14')">
          <xsl:text>The BLZ is marked for deletion, but no following BLZ is noted. The IBAN has been created using the given BLZ. This is not an error. </xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '15')">
          <xsl:text>BIC not found in directory.</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '22')">
          <xsl:text>Structure of the BIC is invalid. A BIC must conform to the pattern '[a-zA-Z]{6}[a-zA-Z0-9]{2}([a-zA-Z0-9]{3})?.</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '23')">
          <xsl:text>Neither BIC11 nor BIC8 where found in the repository, however the structure was valid.</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '24')">
          <xsl:text>The BIC11 was not found in the repository, however the BIC8 was. The structure is valid.</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '30')">
          <xsl:text>The country code is not compliant to ISO3166 (http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '31')">
          <xsl:text>The country code is no supported.</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '32')">
          <xsl:text>The IBAN checksum is invalid.</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '33')">
          <xsl:text>BLZ is not valid. A possible account number can not be checked. (account number part of IBAN is wrong)</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '34')">
          <xsl:text>Account number check sum is invalid. (account number part of IBAN is wrong)</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '35')">
          <xsl:text>IBAN has an invalid length</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '36')">
          <xsl:text>The generic IBAN algorithm was used though there might exist an unknown special rule that is unknown to the current converter.</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '38')">
          <xsl:text>IBAN to verify is not equal to ist recomputed value, usually due to using a follow-up BLZ.</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '39')">
          <xsl:text>IBAN Structure is invalid.</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '99')">
          <xsl:text>Technical Error</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>unexpected result</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>



    <xsl:variable name="error_text_suggestion">
      <xsl:choose>
        <xsl:when
          test="(request-param[@name='ERROR_CODE'] = '00') or (request-param[@name='ERROR_CODE'] = '0')">
          <xsl:text/>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '10')">
          <xsl:text>Failure, but should not occur since all BLZ of existing customers should be correct</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '11')">
          <xsl:text>Failure, but should not occur since all KTO of existing customers should be correct</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '13')">
          <xsl:text>Success,  IBAN and BIC is stored with entered BLZ and KTO</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '14')">
          <xsl:text>Success: IBAN is created using existing BLZ, entered BLZ and KTO are stored</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '15')">
          <xsl:text>Failure: Bank Code can not be converted into BIC.</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '22')">
          <xsl:text>N/A This error code is only provided by Tuxedo</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '23')">
          <xsl:text>N/A This error code is only provided by Tuxedo</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '24')">
          <xsl:text>N/A This error code is only provided by Tuxedo</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '30')">
          <xsl:text>Failure: country code is invalid. Unlikely to happen If it happens this is a technical error, Country Code should be normally be defaulted to DE</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '31')">
          <xsl:text>Failure: country code is invalid. Unlikely to happen If it happens this is a technical error, Country Code should be normally be defaulted to DE</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '32')">
          <xsl:text>N/A</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '33')">
          <xsl:text>N/A</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '34')">
          <xsl:text>N/A</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '35')">
          <xsl:text>N/A</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '36')">
          <xsl:text>Failure: IBAN might be invalid During conversion is should be checked how often this error will occur. </xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '38')">
          <xsl:text>N/A</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '39')">
          <xsl:text>N/A</xsl:text>
        </xsl:when>
        <xsl:when test="(request-param[@name='ERROR_CODE'] = '99')">
          <xsl:text>Failure: Technical Error</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Failure: Unexpected error code.</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <xsl:variable name="status">
      <xsl:choose>
        <xsl:when
          test="(request-param[@name='ERROR_CODE'] = '0') or 
          (request-param[@name='ERROR_CODE'] = '00') or 
          (request-param[@name='ERROR_CODE'] = '13') or 
          (request-param[@name='ERROR_CODE'] = '14') or 
          (request-param[@name='ERROR_CODE'] = '22') or 
          (request-param[@name='ERROR_CODE'] = '23') or 
          (request-param[@name='ERROR_CODE'] = '24') or 
          (request-param[@name='ERROR_CODE'] = '32') or 
          (request-param[@name='ERROR_CODE'] = '33') or 
          (request-param[@name='ERROR_CODE'] = '34') or 
          (request-param[@name='ERROR_CODE'] = '35') or 
          (request-param[@name='ERROR_CODE'] = '38') or 
          (request-param[@name='ERROR_CODE'] = '39')">
          <xsl:text>COMPLETED</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>ERROR</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>






    <xsl:element name="Command_List">
    


      <!-- concat text parts for sql update -->
      <xsl:element name="CcmFifConcatStringsCmd">
        <xsl:element name="command_id">concat_sql_1</xsl:element>
        <xsl:element name="CcmFifConcatStringsInCont">
          <xsl:element name="input_string_list">
            <xsl:element name="CcmFifPassingValueCont">
              <xsl:element name="value">
                <xsl:text>update bank_account_migration t set t.status =&apos;</xsl:text>
                <xsl:value-of select="$status"/>
                <xsl:text>&apos;, </xsl:text>
                <xsl:text> t.error_code =&apos;</xsl:text>
                <xsl:value-of select="request-param[@name='ERROR_CODE']"/>
                <xsl:text>&apos;, </xsl:text>
                <xsl:choose>
                  <xsl:when test="request-param[@name='ERROR_CODE'] = '00' or request-param[@name='ERROR_CODE'] = '0'">
                    <xsl:text> t.error_text =&apos;&apos;</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text> t.error_text =&apos;</xsl:text>
                    <xsl:value-of select="$error_text"/>
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="$error_text_suggestion"/>
                    <xsl:text>)&apos; </xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text> where t.bank_account_id=&apos;</xsl:text>
                <xsl:value-of select="$bank_account_id"/>
                <xsl:text>&apos; </xsl:text>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      

      <xsl:if test="$status='COMPLETED'">
     
        <!-- get bank account data -->
        <xsl:element name="CcmFifGetBankAccountDataCmd">
          <xsl:element name="command_id">get_bank_account_data_1</xsl:element>
          <xsl:element name="CcmFifGetBankAccountDataInCont">
            <xsl:element name="bank_account_id">
              <xsl:value-of select="$bank_account_id"/>
            </xsl:element>
          </xsl:element>
        </xsl:element>
 
        <!-- compare effective date -->
        <xsl:element name="CcmFifValidateDateCmd">
          <xsl:element name="command_id">validate_effective_date_1</xsl:element>
          <xsl:element name="CcmFifValidateDateInCont">
            <xsl:element name="value_ref">
              <xsl:element name="command_id">get_bank_account_data_1</xsl:element>
              <xsl:element name="field_name">effective_date</xsl:element>
            </xsl:element>
            <xsl:element name="object_type">BANK_ACCOUNT</xsl:element>
            <xsl:element name="value_type">EFFECTIVE_DATE</xsl:element>
            <xsl:element name="allowed_values">
              <xsl:element name="CcmFifPassingValueCont">
                <xsl:element name="value">
                  <xsl:value-of select="$effective_date_ccb"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="operator">EQUAL</xsl:element>
            <xsl:element name="raise_error_if_invalid">N</xsl:element>        
          </xsl:element>
        </xsl:element>
        
    
       <!-- update bank account -->
        <xsl:element name="CcmFifCreateBankAccountCmd">
          <xsl:element name="command_id">create_bank_account_1</xsl:element>
          <xsl:element name="CcmFifCreateBankAccountInCont">
            <xsl:element name="customer_number_ref">
              <xsl:element name="command_id">get_bank_account_data_1</xsl:element>
              <xsl:element name="field_name">customer_number</xsl:element>              
            </xsl:element>         
            <xsl:element name="bank_account_id">
              <xsl:value-of select="$bank_account_id"/>
            </xsl:element>       
            <xsl:element name="bank_identifier_code">
              <xsl:value-of select="request-param[@name='BIC_NEW']"/>
            </xsl:element>                
            <xsl:element name="internat_bank_account_number">
              <xsl:value-of select="request-param[@name='IBAN_NEW']"/>
            </xsl:element>

          
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">validate_effective_date_1</xsl:element>
              <xsl:element name="field_name">is_valid</xsl:element>          	
            </xsl:element>
            <xsl:element name="required_process_ind">Y</xsl:element>               
          </xsl:element>
        </xsl:element>
 
 
        <!-- update bank account migration table -->
        <xsl:element name="CcmFifModifyRowForMigrationCmd">
          <xsl:element name="command_id">update_bank_account_migration_1</xsl:element>
          <xsl:element name="CcmFifModifyRowForMigrationInCont">
            <xsl:element name="sql_where_ref">
              <xsl:element name="command_id">concat_sql_1</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        
        
      </xsl:if>



      <xsl:if test="$status='ERROR'">

        <!-- update bank account migration table -->
        <xsl:element name="CcmFifModifyRowForMigrationCmd">
          <xsl:element name="command_id">update_bank_account_migration_2</xsl:element>
          <xsl:element name="CcmFifModifyRowForMigrationInCont">
            <xsl:element name="sql_where_ref">
              <xsl:element name="command_id">concat_sql_1</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>





    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
