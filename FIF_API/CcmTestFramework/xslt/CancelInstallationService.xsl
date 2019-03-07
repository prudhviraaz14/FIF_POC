<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for setting the invoice delivery type

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

    	<!-- look for the service subscription, that KBA provided -->
    	<xsl:element name="CcmFifFindServiceSubsCmd">
    		<xsl:element name="command_id">find_installation_service</xsl:element>
    		<xsl:element name="CcmFifFindServiceSubsInCont">
    			<xsl:element name="service_subscription_id">
    				<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
    			</xsl:element>
    		</xsl:element>
    	</xsl:element>										
    	
    	<!-- validate that the service code is one of an installation service -->
    	<xsl:element name="CcmFifValidateGeneralCodeItemCmd">
    		<xsl:element name="command_id">validate_service_code_1</xsl:element>
    		<xsl:element name="CcmFifValidateGeneralCodeItemInCont">
    			<xsl:element name="group_code">INST_SERV</xsl:element>
    			<xsl:element name="value_ref">
    				<xsl:element name="command_id">find_installation_service</xsl:element>
    				<xsl:element name="field_name">service_code</xsl:element>							
    			</xsl:element>
    		</xsl:element>
    	</xsl:element>
    	
    	<!-- raise an error here, if the previous command returned N -->
    	<xsl:element name="CcmFifValidateValueCmd">
    		<xsl:element name="command_id">validate_service_code_2</xsl:element>
    		<xsl:element name="CcmFifValidateValueInCont">
    			<xsl:element name="value_ref">
    				<xsl:element name="command_id">validate_service_code_1</xsl:element>
    				<xsl:element name="field_name">is_valid</xsl:element>
    			</xsl:element>
    			<xsl:element name="object_type"/>
    			<xsl:element name="value_type">installation service code</xsl:element>
    			<xsl:element name="allowed_values">
    				<xsl:element name="CcmFifPassingValueCont">
    					<xsl:element name="value">Y</xsl:element>
    				</xsl:element>
    			</xsl:element>
    		</xsl:element>
    	</xsl:element>    
    	
    	<!-- find STP -->
    	<xsl:element name="CcmFifFindServiceTicketPositionCmd">
    		<xsl:element name="command_id">find_installation_stp</xsl:element>
    		<xsl:element name="CcmFifFindServiceTicketPositionInCont">
    			<xsl:element name="service_subscription_id_ref">
    				<xsl:element name="command_id">find_installation_service</xsl:element>
    				<xsl:element name="field_name">service_subscription_id</xsl:element>
    			</xsl:element>
    			<xsl:element name="usage_mode_value_rd">1</xsl:element>
    		</xsl:element>
    	</xsl:element>
    	
    	<!-- get stp data -->
    	<xsl:element name="CcmFifGetServiceTicketPositionDataCmd">
    		<xsl:element name="command_id">get_installation_stp_data</xsl:element>
    		<xsl:element name="CcmFifGetServiceTicketPositionDataInCont">
    			<xsl:element name="service_ticket_position_id_ref">
    				<xsl:element name="command_id">find_installation_stp</xsl:element>
    				<xsl:element name="field_name">service_ticket_position_id</xsl:element>
    			</xsl:element>
    		</xsl:element>
    	</xsl:element>							
    	
    	<!-- check the status of the STP -->
    	<xsl:element name="CcmFifValidateValueCmd">
    		<xsl:element name="command_id">validate_stp_state</xsl:element>
    		<xsl:element name="CcmFifValidateValueInCont">
    			<xsl:element name="value_ref">
    				<xsl:element name="command_id">get_installation_stp_data</xsl:element>
    				<xsl:element name="field_name">state_rd</xsl:element>
    			</xsl:element>
    			<xsl:element name="object_type">SERVICE_TICKET_POSITION</xsl:element>
    			<xsl:element name="value_type">STATE_RD</xsl:element>
    			<xsl:element name="allowed_values">
    				<xsl:element name="CcmFifPassingValueCont">
    					<xsl:element name="value">RELEASED</xsl:element>
    				</xsl:element>
    				<xsl:element name="CcmFifPassingValueCont">
    					<xsl:element name="value">INSTALLED</xsl:element>
    				</xsl:element>
    				<xsl:element name="CcmFifPassingValueCont">
    					<xsl:element name="value">PROVISIONED</xsl:element>
    				</xsl:element>
    			</xsl:element>
    		</xsl:element>
    	</xsl:element>    
    	
    	<!-- create contact -->
    	<xsl:element name="CcmFifCreateContactCmd">
    		<xsl:element name="command_id">create_contact</xsl:element>
    		<xsl:element name="CcmFifCreateContactInCont">
    			<xsl:element name="customer_number_ref">
    				<xsl:element name="command_id">find_installation_service</xsl:element>
    				<xsl:element name="field_name">customer_number</xsl:element>
    			</xsl:element>
    			<xsl:element name="contact_type_rd">CAN_INST_SERVICE</xsl:element>
    			<xsl:element name="short_description">Installationsdienst storniert</xsl:element>
    			<xsl:element name="long_description_text">
    				<xsl:text>Installationsdienst storniert über </xsl:text>
    				<xsl:value-of select="request-param[@name='clientName']"/>
    				<xsl:text>&#xA;TransactionID:</xsl:text>
    				<xsl:value-of select="request-param[@name='transactionID']"/>
    				<xsl:if test="request-param[@name='requestListId'] != ''">
    					<xsl:text>&#xA;RequestListId:</xsl:text>
    					<xsl:value-of select="request-param[@name='requestListId']"/>
    				</xsl:if>
    			</xsl:element>
    		</xsl:element>
    	</xsl:element>
    	
    	<!-- cancel the service in OPM -->
    	<xsl:element name="CcmFifCancelCustomerOrderCmd">
    		<xsl:element name="command_id">cancel_opm_order</xsl:element>
    		<xsl:element name="CcmFifCancelCustomerOrderInCont">
    			<xsl:element name="customer_order_id_ref">
    				<xsl:element name="command_id">get_installation_stp_data</xsl:element>
    				<xsl:element name="field_name">customer_order_id</xsl:element>            
    			</xsl:element>
    			<xsl:element name="cancel_reason_rd">INST</xsl:element>
    			<xsl:element name="cancel_opm_order_ind">Y</xsl:element>
    			<xsl:element name="do_not_reject_op_order_ind">Y</xsl:element>
    		</xsl:element>
    	</xsl:element>
    	
    </xsl:element>    
  </xsl:template>
</xsl:stylesheet>
