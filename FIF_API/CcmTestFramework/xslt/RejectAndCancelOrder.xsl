<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for setting the invoice delivery type

  @author Marcin Leja
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
    	<xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">
  	
      <!-- Lock the customer to avoid concurrent updates -->
      <xsl:element name="CcmFifLockObjectCmd">
        <xsl:element name="command_id">lock_customer_order</xsl:element>
        <xsl:element name="CcmFifLockObjectInCont">
          <xsl:element name="object_id">
    				<xsl:value-of select="request-param[@name='CUSTOMER_ORDER_ID']"/>
          </xsl:element>
          <xsl:element name="object_type">CUSTOMER_ORDER</xsl:element>
        </xsl:element>
      </xsl:element>

    	<!-- get customer order data -->
    	<xsl:element name="CcmFifGetCustomerOrderDataCmd">
    		<xsl:element name="command_id">get_co_data_1</xsl:element>
    		<xsl:element name="CcmFifGetCustomerOrderDataInCont">
    			<xsl:element name="customer_order_id">
    				<xsl:value-of select="request-param[@name='CUSTOMER_ORDER_ID']"/>
    			</xsl:element>
    		</xsl:element>
    	</xsl:element>

    	<xsl:element name="CcmFifRaiseErrorCmd">
    		<xsl:element name="command_id">raise_error_complete</xsl:element>
    		<xsl:element name="CcmFifRaiseErrorInCont">
    			<xsl:variable name="errorText">
    				<xsl:text>The customer order </xsl:text>                 
    				<xsl:value-of select="request-param[@name='CUSTOMER_ORDER_ID']"/>
    				<xsl:text> is already COMPLETED in CCM.</xsl:text>
    			</xsl:variable> 
    			<xsl:element name="error_text">
    				<xsl:value-of select="$errorText"/>
    			</xsl:element>
    			<xsl:element name="process_ind_ref">
    				<xsl:element name="command_id">get_co_data_1</xsl:element>
    				<xsl:element name="field_name">state_rd</xsl:element>          	
    			</xsl:element>
    			<xsl:element name="required_process_ind">COMPLETED</xsl:element>
    		</xsl:element>
    	</xsl:element>  
    	
    	<xsl:element name="CcmFifRaiseErrorCmd">
    		<xsl:element name="command_id">raise_error_complete</xsl:element>
    		<xsl:element name="CcmFifRaiseErrorInCont">
    			<xsl:variable name="errorText">
    				<xsl:text>The customer order </xsl:text>                 
    				<xsl:value-of select="request-param[@name='CUSTOMER_ORDER_ID']"/>
    				<xsl:text> is already FINAL in CCM.</xsl:text>
    			</xsl:variable> 
    			<xsl:element name="error_text">
    				<xsl:value-of select="$errorText"/>
    			</xsl:element>
    			<xsl:element name="process_ind_ref">
    				<xsl:element name="command_id">get_co_data_1</xsl:element>
    				<xsl:element name="field_name">state_rd</xsl:element>          	
    			</xsl:element>
    			<xsl:element name="required_process_ind">FINAL</xsl:element>
    		</xsl:element>
    	</xsl:element>  

    	<!-- reject the service in OP -->
    	<xsl:element name="CcmFifRejectCustomerOrderCmd">
    		<xsl:element name="command_id">reject_customer_order</xsl:element>
    		<xsl:element name="CcmFifRejectCustomerOrderInCont">
    			<xsl:element name="customer_order_id">
    				<xsl:value-of select="request-param[@name='CUSTOMER_ORDER_ID']"/>
    			</xsl:element>
    			<xsl:element name="cancel_reason_rd">
    				<xsl:value-of select="request-param[@name='CANCEL_REASON_RD']"/>
    			</xsl:element>
    			<xsl:if test="request-param[@name='RESET_CUSTOMER_ORDER_IND'] != ''">
    				<xsl:element name="reset_customer_order_ind">
						<xsl:value-of select="request-param[@name='RESET_CUSTOMER_ORDER_IND']"/>
    				</xsl:element>
    			</xsl:if>
    			<xsl:if test="request-param[@name='REJECT_FOR_BARCODE_IND'] != ''">
    				<xsl:element name="reject_for_barcode_ind">
    					<xsl:value-of select="request-param[@name='REJECT_FOR_BARCODE_IND']"/>
    				</xsl:element>
    			</xsl:if>
    			<xsl:element name="process_ind_ref">
    				<xsl:element name="command_id">get_co_data_1</xsl:element>
    				<xsl:element name="field_name">state_rd</xsl:element>          	
    			</xsl:element>
    			<xsl:element name="required_process_ind">RELEASED</xsl:element>
    		</xsl:element>
    	</xsl:element>

      
    	<!-- cancel contract termination -->
      <xsl:element name="CcmFifCancelContractTermWithBarCodeCmd">
        <xsl:element name="command_id">cancel_of_term_1</xsl:element>
        <xsl:element name="CcmFifCancelContractTermWithBarCodeInCont">
          <xsl:element name="customer_tracking_id_ref">
    				<xsl:element name="command_id">get_co_data_1</xsl:element>
    				<xsl:element name="field_name">customer_tracking_id</xsl:element>          	
          </xsl:element>
    	    <xsl:element name="process_ind_ref">
            <xsl:element name="command_id">get_co_data_1</xsl:element>
            <xsl:element name="field_name">state_rd</xsl:element>          	
          </xsl:element>
          <xsl:element name="required_process_ind">RELEASED</xsl:element>
        </xsl:element>
      </xsl:element>
    	
    	<!-- create contact -->
    	<xsl:element name="CcmFifCreateContactCmd">
    		<xsl:element name="command_id">create_contact</xsl:element>
    		<xsl:element name="CcmFifCreateContactInCont">
    			<xsl:element name="customer_number_ref">
    				<xsl:element name="command_id">get_co_data_1</xsl:element>
    				<xsl:element name="field_name">customer_number</xsl:element>
    			</xsl:element>
    			<xsl:element name="contact_type_rd">REJECT_CO</xsl:element>
    			<xsl:element name="short_description">Internen Auftrags ablehnung.</xsl:element>
    			<xsl:element name="long_description_text">
    				<xsl:text>Interne Auftrag </xsl:text>
    				<xsl:value-of select="request-param[@name='CUSTOMER_ORDER_ID']"/>
    				<xsl:text> abgelehnt von </xsl:text>
    				<xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
    				<xsl:text>&#xA;TransactionID:</xsl:text>
    				<xsl:value-of select="request-param[@name='transactionID']"/>
    			</xsl:element>
    			<xsl:element name="process_ind_ref">
    				<xsl:element name="command_id">get_co_data_1</xsl:element>
    				<xsl:element name="field_name">state_rd</xsl:element>          	
    			</xsl:element>
    			<xsl:element name="required_process_ind">RELEASED</xsl:element>
    		</xsl:element>
    	</xsl:element>
    	
    </xsl:element>    
  </xsl:template>
</xsl:stylesheet>
