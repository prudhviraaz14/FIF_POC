<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a FIF request that changes the state of account to FINAL
  
  @author banania
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
      <xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
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

      <!-- lock account to avoid concurrency problems -->
      <xsl:element name="CcmFifLockObjectCmd">
        <xsl:element name="CcmFifLockObjectInCont">
          <xsl:element name="object_id">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="object_type">ACCOUNT</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- get account data to retrieve cycle name -->
      <xsl:element name="CcmFifGetAccountDataCmd">
        <xsl:element name="command_id">get_account_final</xsl:element>
        <xsl:element name="CcmFifGetAccountDataInCont">
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="$tomorrow"/>
          </xsl:element>
          <xsl:element name="deact_ind">Y</xsl:element>
        </xsl:element>    
      </xsl:element>
      
        <xsl:element name="CcmFifMapStringCmd">
          <xsl:element name="command_id">map_account_final</xsl:element>
          <xsl:element name="CcmFifMapStringInCont">
            <xsl:element name="input_string_type">xxx</xsl:element>
            <xsl:element name="input_string_ref">
              <xsl:element name="command_id">get_account_final</xsl:element>
              <xsl:element name="field_name">state_rd</xsl:element>
            </xsl:element>
            <xsl:element name="output_string_type">xxx</xsl:element>
            <xsl:element name="string_mapping_list">
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">FINAL</xsl:element>
                <xsl:element name="output_string">Y</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">TERMINATED</xsl:element>
                <xsl:element name="output_string">Y</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="no_mapping_error">N</xsl:element>
          </xsl:element>
        </xsl:element>

      <!-- Change state of account -->
      <xsl:element name="CcmFifFinalizeAccountCmd">
        <xsl:element name="command_id">finalize_account_1</xsl:element>
        <xsl:element name="CcmFifFinalizeAccountInCont">
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="bypass_command_ref">
              <xsl:element name="command_id">map_account_final</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>							
          </xsl:element>
        </xsl:element>
      </xsl:element>

      <xsl:if test="request-param[@name='CLIENT_NAME'] != 'CCM'">
        <xsl:variable name="today"
          select="dateutils:getCurrentDate()"/>
        
        <xsl:variable name="tomorrow"
          select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
        
        <!-- get account data to retrieve cycle name -->
        <xsl:element name="CcmFifGetAccountDataCmd">
          <xsl:element name="command_id">get_account_data</xsl:element>
          <xsl:element name="CcmFifGetAccountDataInCont">
            <xsl:element name="account_number">
              <xsl:value-of select="request-param[@name='ACCOUNT_NUMBER']"/>
            </xsl:element>
            <xsl:element name="effective_date">
              <xsl:value-of select="$tomorrow"/>
            </xsl:element>
          </xsl:element>    
        </xsl:element>
        
        <xsl:element name="CcmFifMapStringCmd">
          <xsl:element name="command_id">map_account_active</xsl:element>
          <xsl:element name="CcmFifMapStringInCont">
            <xsl:element name="input_string_type">xxx</xsl:element>
            <xsl:element name="input_string_ref">
              <xsl:element name="command_id">get_account_data</xsl:element>
              <xsl:element name="field_name">state_rd</xsl:element>
            </xsl:element>
            <xsl:element name="output_string_type">xxx</xsl:element>
            <xsl:element name="string_mapping_list">
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">ACTIVATED</xsl:element>
                <xsl:element name="output_string">Y</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">CREATED</xsl:element>
                <xsl:element name="output_string">Y</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">SUSPENDED</xsl:element>
                <xsl:element name="output_string">Y</xsl:element>
              </xsl:element>
              <xsl:element name="CcmFifStringMappingCont">
                <xsl:element name="input_string">PENDING_SUSPEND</xsl:element>
                <xsl:element name="output_string">Y</xsl:element>
              </xsl:element>
            </xsl:element>
            <xsl:element name="no_mapping_error">N</xsl:element>
          </xsl:element>
        </xsl:element>
        
        <!-- raise error to initiate functional recycling -->      
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">raise_error_account_active</xsl:element>
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Rechnungskonto konnte nicht beendet werden, da noch aktive Objekte mit dem Rechnungskonto verbunden sind.</xsl:element>
            <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">map_account_active</xsl:element>
              <xsl:element name="field_name">output_string</xsl:element>							
            </xsl:element>          
            <xsl:element name="required_process_ind">Y</xsl:element>          
          </xsl:element>
        </xsl:element>           
      </xsl:if>
      
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
