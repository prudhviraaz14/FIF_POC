<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for releasing a customer order

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
    <xsl:element name="client_name">CCM</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">

      <!-- lock customer to avoid concurrency problems -->
      <xsl:element name="CcmFifLockObjectCmd">
        <xsl:element name="CcmFifLockObjectInCont">
          <xsl:element name="object_id">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="object_type">CUSTOMER</xsl:element>
        </xsl:element>
      </xsl:element>

      <!-- get data from customer order -->
      <xsl:element name="CcmFifGetCustomerOrderDataCmd">
        <xsl:element name="command_id">get_co_data</xsl:element>
        <xsl:element name="CcmFifGetCustomerOrderDataInCont">
          <xsl:element name="customer_order_id">
            <xsl:value-of select="request-param[@name='CUSTOMER_ORDER_ID']"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>      

      <!-- Release Customer Order, if in state DEFINED -->
      <xsl:element name="CcmFifReleaseCustOrderCmd">
        <xsl:element name="CcmFifReleaseCustOrderInCont">
          <xsl:element name="customer_number">
            <xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
          </xsl:element>
          <xsl:element name="customer_order_id">
            <xsl:value-of select="request-param[@name='CUSTOMER_ORDER_ID']"/>
          </xsl:element>
          <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">get_co_data</xsl:element>
            <xsl:element name="field_name">state_rd</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">DEFINED</xsl:element>
        </xsl:element>
      </xsl:element>
    
	<xsl:element name="CcmFifFindBundleCmd">
		<xsl:element name="command_id">find_bundle</xsl:element>
		<xsl:element name="CcmFifFindBundleInCont">
			<xsl:element name="customer_order_id">
				<xsl:value-of select="request-param[@name='CUSTOMER_ORDER_ID']"/>
			</xsl:element>            
			<xsl:element name="process_ind_ref">
				<xsl:element name="command_id">get_co_data</xsl:element>
				<xsl:element name="field_name">action_name</xsl:element>							
			</xsl:element>
			<xsl:element name="required_process_ind">moveProductSubscription</xsl:element>
		</xsl:element>
	</xsl:element>
    
	<xsl:element name="CcmFifSetSalesPacketOnBundleCmd">
		<xsl:element name="CcmFifSetSalesPacketOnBundleInCont">
			<xsl:element name="bundle_id_ref">
				<xsl:element name="command_id">find_bundle</xsl:element>
				<xsl:element name="field_name">bundle_id</xsl:element>          
			</xsl:element>
			<xsl:element name="omts_order_id"/>
			<xsl:element name="suppress_error">Y</xsl:element>
			<xsl:element name="process_ind_ref">
				<xsl:element name="command_id">find_bundle</xsl:element>
				<xsl:element name="field_name">bundle_found</xsl:element>							
			</xsl:element>
			<xsl:element name="required_process_ind">Y</xsl:element>
		</xsl:element>
	</xsl:element>
    
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
