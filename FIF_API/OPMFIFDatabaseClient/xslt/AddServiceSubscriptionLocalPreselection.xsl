<!--
  XSLT file for converting an OPM AddServiceSubscription request
  to a FIF transaction

  @author goethalo
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
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
    <xsl:element name="client_name">OPM</xsl:element>
    <!-- Action name -->
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>

    <xsl:element name="Command_List">
    <xsl:element name="CcmFifFindServiceSubsCmd">
      <xsl:element name="command_id"><![CDATA[find_service_1]]></xsl:element>
      <xsl:element name="CcmFifFindServiceSubsInCont">
        <xsl:element name="access_number"><xsl:value-of select="request-param[@name='ACCESS_NUMBER']"/></xsl:element>
        <xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
        <xsl:element name="customer_number"><xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/></xsl:element>
		<xsl:element name="technical_service_code">VOICE</xsl:element>
      </xsl:element>
    </xsl:element>
    <xsl:element name="CcmFifLockObjectCmd">
      <xsl:element name="CcmFifLockObjectInCont">
        <xsl:element name="object_id_ref">
          <xsl:element name="command_id">find_service_1</xsl:element>
          <xsl:element name="field_name">product_subscription_id</xsl:element>
        </xsl:element>
        <xsl:element name="object_type">PROD_SUBS</xsl:element>
      </xsl:element>
    </xsl:element>    
    <xsl:element name="CcmFifAddServiceSubsCmd">
      <xsl:element name="command_id"><![CDATA[add_service_1]]></xsl:element>
      <xsl:element name="CcmFifAddServiceSubsInCont">
        <xsl:element name="product_subscription_ref">
          <xsl:element name="command_id"><![CDATA[find_service_1]]></xsl:element>
          <xsl:element name="field_name"><![CDATA[product_subscription_id]]></xsl:element>
        </xsl:element>
        <xsl:element name="service_code"><xsl:value-of select="request-param[@name='SERVICE_CODE_LOCAL_PRESEL']"/></xsl:element>
        <xsl:element name="parent_service_subs_ref">
          <xsl:element name="command_id"><![CDATA[find_service_1]]></xsl:element>
          <xsl:element name="field_name"><![CDATA[service_subscription_id]]></xsl:element>
        </xsl:element>
        <xsl:element name="account_number_ref">
          <xsl:element name="command_id"><![CDATA[find_service_1]]></xsl:element>
          <xsl:element name="field_name"><![CDATA[account_number]]></xsl:element>
        </xsl:element>
        <xsl:element name="service_characteristic_list">
        </xsl:element>
       </xsl:element>
     </xsl:element>
    <xsl:element name="CcmFifAddServiceSubsCmd">
      <xsl:element name="command_id"><![CDATA[add_service_2]]></xsl:element>
      <xsl:element name="CcmFifAddServiceSubsInCont">
        <xsl:element name="product_subscription_ref">
          <xsl:element name="command_id"><![CDATA[find_service_1]]></xsl:element>
          <xsl:element name="field_name"><![CDATA[product_subscription_id]]></xsl:element>
        </xsl:element>
        <xsl:element name="service_code">
          <xsl:value-of select="request-param[@name='SERVICE_CODE_WECHSEL']"/>
        </xsl:element>
        <xsl:element name="parent_service_subs_ref">
          <xsl:element name="command_id"><![CDATA[find_service_1]]></xsl:element>
          <xsl:element name="field_name"><![CDATA[service_subscription_id]]></xsl:element>
        </xsl:element>
        <xsl:element name="account_number_ref">
          <xsl:element name="command_id"><![CDATA[find_service_1]]></xsl:element>
          <xsl:element name="field_name"><![CDATA[account_number]]></xsl:element>
        </xsl:element>
        <xsl:element name="service_characteristic_list">
        </xsl:element>
       </xsl:element>
     </xsl:element>
    <xsl:element name="CcmFifCreateCustOrderCmd">
      <xsl:element name="command_id"><![CDATA[create_co_1]]></xsl:element>
      <xsl:element name="CcmFifCreateCustOrderInCont">
        <xsl:element name="customer_number"><xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/></xsl:element>
        <xsl:element name="customer_tracking_id"><xsl:value-of select="request-param[@name='BARCODE']"/></xsl:element>
        <xsl:element name="provider_tracking_no"><xsl:value-of select="request-param[@name='AUFTRAGSPOSITION_ID']"/></xsl:element>
        <xsl:element name="service_ticket_pos_list">
            <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id"><![CDATA[add_service_1]]></xsl:element>
                <xsl:element name="field_name"><![CDATA[service_ticket_pos_id]]></xsl:element>
            </xsl:element>
            <xsl:element name="CcmFifCommandRefCont">
                <xsl:element name="command_id"><![CDATA[add_service_2]]></xsl:element>
                <xsl:element name="field_name"><![CDATA[service_ticket_pos_id]]></xsl:element>
            </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    <xsl:element name="CcmFifReleaseCustOrderCmd">
      <xsl:element name="CcmFifReleaseCustOrderInCont">
        <xsl:element name="customer_number"><xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/></xsl:element>
        <xsl:element name="customer_order_ref">
          <xsl:element name="command_id"><![CDATA[create_co_1]]></xsl:element>
          <xsl:element name="field_name"><![CDATA[customer_order_id]]></xsl:element>
        </xsl:element>
     </xsl:element>
   </xsl:element>
   </xsl:element>
  </xsl:template>
</xsl:stylesheet>
