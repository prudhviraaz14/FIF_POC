<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for activating service without OP.
  @author schwarje
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

    <xsl:variable name="DesiredDate" select="request-param[@name='desiredDate']"/>
    
    <xsl:element name="Command_List">
      
		<!-- Get customer order id -->     
		<xsl:element name="CcmFifReadExternalNotificationCmd">
			<xsl:element name="command_id">read_customer_order_id</xsl:element>
			<xsl:element name="CcmFifReadExternalNotificationInCont">
				<xsl:element name="transaction_id">
					<xsl:value-of select="request-param[@name='requestListId']"/>
				</xsl:element>
				<xsl:element name="parameter_name">
					<xsl:if test="request-param[@name='isMovedService'] = 'Y'">
						<xsl:text>MOVED_</xsl:text>
					</xsl:if>                              
					<xsl:value-of select="request-param[@name='functionID']"/>
					<xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
				</xsl:element>
				<xsl:element name="ignore_empty_result">Y</xsl:element>
			</xsl:element>
		</xsl:element>
      
		<xsl:element name="CcmFifActivateCustomerOrderCmd">
			<xsl:element name="command_id">activate_co</xsl:element>
			<xsl:element name="CcmFifActivateCustomerOrderInCont">
				<xsl:element name="customer_order_id_ref">
					<xsl:element name="command_id">read_customer_order_id</xsl:element>
					<xsl:element name="field_name">parameter_value</xsl:element>
				</xsl:element>
				<xsl:if test="request-param[@name='offsetDays'] != ''">
					<xsl:element name="offset_days">
						<xsl:value-of select="request-param[@name='offsetDays']"/>
					</xsl:element>
				</xsl:if>                              
			</xsl:element>
		</xsl:element>
		
		<xsl:if test="request-param[@name='isMovedService'] != 'Y'">      
			<!-- Get customer order id -->     
			<xsl:element name="CcmFifReadExternalNotificationCmd">
				<xsl:element name="command_id">read_op_activation_co</xsl:element>
				<xsl:element name="CcmFifReadExternalNotificationInCont">
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="parameter_name">
						<xsl:value-of select="request-param[@name='functionID']"/>
						<xsl:text>_OP_CUSTOMER_ORDER_ID</xsl:text>
					</xsl:element>
					<xsl:element name="ignore_empty_result">Y</xsl:element>
				</xsl:element>
			</xsl:element>
      
			<!-- get data from CO -->
			<xsl:element name="CcmFifGetCustomerOrderDataCmd">
				<xsl:element name="command_id">get_op_activation_co</xsl:element>
				<xsl:element name="CcmFifGetCustomerOrderDataInCont">
					<xsl:element name="customer_order_id_ref">
						<xsl:element name="command_id">read_op_activation_co</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">read_op_activation_co</xsl:element>
						<xsl:element name="field_name">value_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>										
				</xsl:element>
			</xsl:element>      
        
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">get_op_activation_co</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">read_op_activation_co</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">get_op_activation_co</xsl:element>
						<xsl:element name="field_name">state_rd</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">DEFINED</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Get customer order id -->     
			<xsl:element name="CcmFifReadExternalNotificationCmd">
				<xsl:element name="command_id">read_op_termination_co</xsl:element>
				<xsl:element name="CcmFifReadExternalNotificationInCont">
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="parameter_name">
						<xsl:value-of select="request-param[@name='functionID']"/>
						<xsl:text>_OP_TERM_CUSTOMER_ORDER_ID</xsl:text>
					</xsl:element>
					<xsl:element name="ignore_empty_result">Y</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- get data from CO -->
			<xsl:element name="CcmFifGetCustomerOrderDataCmd">
				<xsl:element name="command_id">get_op_termination_co</xsl:element>
				<xsl:element name="CcmFifGetCustomerOrderDataInCont">
					<xsl:element name="customer_order_id_ref">
						<xsl:element name="command_id">read_op_termination_co</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">read_op_termination_co</xsl:element>
						<xsl:element name="field_name">value_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>										
				</xsl:element>
			</xsl:element>      

			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">get_op_termination_co</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">read_op_termination_co</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">get_op_termination_co</xsl:element>
						<xsl:element name="field_name">state_rd</xsl:element>
					</xsl:element>
				<xsl:element name="required_process_ind">DEFINED</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>   
 
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>

