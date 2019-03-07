<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for migrating customer permissions

  @author sibanipa
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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
    <xsl:element name="client_name">SLS</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">
    
      <xsl:variable name="ReasonCode">
          <xsl:value-of select="request-param[@name='reasonCode']"/>
      </xsl:variable> 
            
       <!-- get customer data to retrieve customer category-->
      <xsl:element name="CcmFifGetCustomerDataCmd">
        <xsl:element name="command_id">get_customer_data</xsl:element>
        <xsl:element name="CcmFifGetCustomerDataInCont">
          <xsl:element name="customer_number">
             <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="no_customer_error">N</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <xsl:element name="CcmFifChangeCustomerCmd">
        <xsl:element name="CcmFifChangeCustomerInCont">
          <xsl:element name="customer_number">
             <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <!-- <xsl:element name="usage_data_indicator">Y</xsl:element> -->
    	  <xsl:element name="process_ind_ref">
          <xsl:element name="command_id">get_customer_data</xsl:element>
          <xsl:element name="field_name">state_rd</xsl:element>
        </xsl:element>
      	<xsl:element name="required_process_ind">ACTIVATED</xsl:element>
         </xsl:element>
       </xsl:element>
 	</xsl:element>

    
  </xsl:template>
</xsl:stylesheet>
