<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for rolling back a tarif change
  
  @author wlazlow
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output doctype-system="fif_transaction.dtd" encoding="ISO-8859-1" indent="yes" method="xml"/>
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

	<!-- Find service subscription -->	
    <xsl:element name="CcmFifFindServiceSubsCmd">
        <xsl:element name="command_id">find_main_service_1</xsl:element>
        <xsl:element name="CcmFifFindServiceSubsInCont">
          <xsl:element name="service_subscription_id">
            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
          </xsl:element>
	      <xsl:element name="no_service_error">N</xsl:element>			
        </xsl:element>
    </xsl:element>
		
		
      <!-- Rollback Tariff Change OF -->
      <xsl:element name="CcmFifRollbackApplyNewPriceStructCmd">
        <xsl:element name="command_id">rollback_1</xsl:element>
        <xsl:element name="CcmFifRollbackApplyNewPriceStructInCont">
          <xsl:element name="supported_object_ref">
			  <xsl:element name="command_id">find_main_service_1</xsl:element>
              <xsl:element name="field_name">contract_number</xsl:element>					           
          </xsl:element>
          <xsl:element name="supported_object_type_rd">ORDERFORM</xsl:element>		  
		  <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_main_service_1</xsl:element>
              <xsl:element name="field_name">contract_type_rd</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">O</xsl:element>
		  <xsl:element name="omts_order_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>			
        </xsl:element>
      </xsl:element>
		
		
	  <!-- Rollback Tariff Change SDC-->
      <xsl:element name="CcmFifRollbackApplyNewPriceStructCmd">
        <xsl:element name="command_id">rollback_2</xsl:element>
        <xsl:element name="CcmFifRollbackApplyNewPriceStructInCont">
          <xsl:element name="supported_object_ref">
			  <xsl:element name="command_id">find_main_service_1</xsl:element>
              <xsl:element name="field_name">product_commitment_number</xsl:element>					           
          </xsl:element>
          <xsl:element name="supported_object_type_rd">SERVDLVRY</xsl:element>		  
		  <xsl:element name="process_ind_ref">
              <xsl:element name="command_id">find_main_service_1</xsl:element>
              <xsl:element name="field_name">contract_type_rd</xsl:element>							
          </xsl:element>
          <xsl:element name="required_process_ind">S</xsl:element>
		  <xsl:element name="omts_order_id">
            <xsl:value-of select="request-param[@name='OMTSOrderID']"/>
          </xsl:element>				
        </xsl:element>
      </xsl:element>	

    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
