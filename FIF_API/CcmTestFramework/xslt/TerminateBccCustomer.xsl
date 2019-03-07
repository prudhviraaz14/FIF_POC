<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for converting an OPM terminateBccCustomer request
  to a FIF transaction

  @author goethalo
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
    exclude-result-prefixes="dateutils">
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
  <xsl:template match="/">
    <xsl:element name="CcmFifCommandList">
      <xsl:apply-templates select="request/request-params"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="request-params">
    <!-- Transaction ID -->
    <xsl:element name="transaction_id">
      <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="client_name">OPM</xsl:element>
    <!-- Action name -->
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">
      <!-- Terminate Order Form -->
      <xsl:element name="CcmFifTerminateOrderFormCmd">
        <xsl:element name="command_id">terminate_of_1</xsl:element>
        <xsl:element name="CcmFifTerminateOrderFormInCont">
          <xsl:element name="contract_number">
            <xsl:value-of select="request-param[@name='CONTRACT.CONTRACT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="termination_date">
            <xsl:value-of select="dateutils:convertOPMDate(request-param[@name='TRANSACTION.TERMINATION_DATE'])"/>
          </xsl:element>
          <xsl:element name="notice_per_start_date">
            <xsl:value-of select="request-param[@name='CONTRACT.NOTICE_PERIOD_START_DATE']"/>
          </xsl:element>
          <xsl:element name="override_restriction">Y</xsl:element>
        </xsl:element>
      </xsl:element>
      
      <!-- Stop Mailing -->
      <xsl:element name="CcmFifStopMailingCmd">
        <xsl:element name="command_id">stop_mailing_1</xsl:element>
        <xsl:element name="CcmFifStopMailingInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER.CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="mailing_id">
            <xsl:value-of select="request-param[@name='MAILING.MAILING_ID']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="dateutils:convertOPMDate(request-param[@name='TRANSACTION.TERMINATION_DATE'])"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      
	  <!-- Finalize Account -->      
      <xsl:element name="CcmFifFinalizeAccountCmd">
        <xsl:element name="command_id">finalize_account_1</xsl:element>
        <xsl:element name="CcmFifFinalizeAccountInCont">
          <xsl:element name="account_number">
            <xsl:value-of select="request-param[@name='ACCOUNT.ACCOUNT_NUMBER']"/>
          </xsl:element>
          <xsl:element name="effective_date">
            <xsl:value-of select="dateutils:convertOPMDate(request-param[@name='TRANSACTION.TERMINATION_DATE'])"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>	  

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
