<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for triggering the automatic data reconciliation

  @author schwarje
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
      <xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">

      <!-- check for external orders? Or disregard from some orders? -->

      <!-- send request to BKS -->
      <xsl:element name="CcmFifProcessServiceBusRequestCmd">
        <xsl:element name="command_id">send_bks_request</xsl:element>
        <xsl:element name="CcmFifProcessServiceBusRequestInCont">
          <xsl:element name="package_name">net.arcor.ccm.epsm_ccm_consolidatesubscriptiondata_001</xsl:element>
          <xsl:element name="service_name">ConsolidateSubscriptionData</xsl:element>
          <xsl:element name="synch_ind">N</xsl:element>
          <xsl:element name="external_system_id">
            <xsl:value-of select="request-param[@name='customerNumber']"/>
            <xsl:text>;</xsl:text>
            <xsl:value-of select="request-param[@name='transactionID']"/>
          </xsl:element>
          <xsl:element name="priority">3</xsl:element>					
          <xsl:element name="parameter_value_list">
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">OrderId</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='orderId']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">OrderPositionNumber</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='orderPositionNumber']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">BundleId</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='bundleId']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SkipZar</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='skipZARValidation']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SkipAida</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='skipAIDAValidation']"/>
              </xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SkipCramer</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='skipCRAMERValidation']"/>
              </xsl:element>
            </xsl:element>   
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SkipInfPort</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='skipINFPORTValidation']"/>
              </xsl:element>
            </xsl:element>       
            <xsl:element name="CcmFifParameterValueCont">
              <xsl:element name="parameter_name">SkipOpenOrderValidation</xsl:element>
              <xsl:element name="parameter_value">
                <xsl:value-of select="request-param[@name='skipOPENORDERValidation']"/>
              </xsl:element>
            </xsl:element>       
          </xsl:element>
          <!--
            <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">validate_cust_is_for_link_db_1</xsl:element>
            <xsl:element name="field_name">customer_is_for_link_db_ind</xsl:element>
          </xsl:element>
          -->
        </xsl:element>
      </xsl:element>
        
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
