<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- XSLT file for creating a terminate a mobile product subscription FIF request 
	@author wlazlow -->
<xsl:stylesheet exclude-result-prefixes="dateutils"
	version="1.0"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1"
		doctype-system="fif_transaction.dtd" />
	<xsl:template match="/">
		<xsl:element name="CcmFifCommandList">
			<xsl:apply-templates select="request/request-params" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="request-params">
		<!-- Copy over transaction ID and action name -->
		<xsl:element name="transaction_id">
			<xsl:value-of select="request-param[@name='transactionID']" />
		</xsl:element>
		<xsl:element name="client_name">SLS</xsl:element>
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name" />
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']" />
		</xsl:element>


		<xsl:variable name="today" select="dateutils:getCurrentDate()" />



		<xsl:variable name="TerminationReason">
			<xsl:text>Mobiledienst mit der ID:</xsl:text>
			<xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']" />
			<xsl:text> über SLS gekündigt.</xsl:text>
		</xsl:variable>

		<xsl:element name="Command_List">

			<!-- Generate Barcode -->
			<xsl:element name="CcmFifGenerateCustomerOrderBarcodeCmd">
				<xsl:element name="command_id">generate_barcode_1</xsl:element>
			</xsl:element>


			<!-- Find service -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_service_1</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="service_subscription_id">
						<xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']" />
					</xsl:element>
					<xsl:element name="effective_date">
						<xsl:value-of select="$today" />
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Cancel not completed STPs -->
			<xsl:element name="CcmFifCancelNonCompleteStpForProductCmd">
            	<xsl:element name="command_id">cancel_stp_1</xsl:element>
            	<xsl:element name="CcmFifCancelNonCompleteStpForProductInCont">
              		<xsl:element name="product_subscription_ref">
                		<xsl:element name="command_id">find_service_1</xsl:element>
                		<xsl:element name="field_name">product_subscription_id</xsl:element>
              		</xsl:element>
              		<xsl:element name="reason_rd">TERMINATION</xsl:element>
            	</xsl:element>
          	</xsl:element>

			<!-- Terminate Product Subscription -->
			<xsl:element name="CcmFifTerminateProductSubsCmd">
				<xsl:element name="command_id">terminate_ps_1</xsl:element>
				<xsl:element name="CcmFifTerminateProductSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:if test="request-param[@name='TERMINATION_DATE'] != ''">
							<xsl:value-of select="request-param[@name='TERMINATION_DATE']" />
						</xsl:if>
						<xsl:if test="request-param[@name='TERMINATION_DATE'] = ''">
							<!-- Get today's date -->
							<xsl:variable name="today" select="dateutils:getCurrentDate()" />
							<xsl:value-of select="$today" />
						</xsl:if>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:element name="reason_rd">TERMINATION</xsl:element>
					<xsl:element name="auto_customer_order">N</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Create customer order -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:if test="request-param[@name='OMTS_ORDER_ID'] != ''">
						<xsl:element name="customer_tracking_id">
							<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']" />
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='OMTS_ORDER_ID'] = ''">
						<xsl:element name="customer_tracking_id_ref">
							<xsl:element name="command_id">generate_barcode_1</xsl:element>
							<xsl:element name="field_name">customer_tracking_id</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_ticket_pos_list">
                        <xsl:element name="CcmFifCommandRefCont">
                            <xsl:element name="command_id">terminate_ps_1</xsl:element>
                            <xsl:element name="field_name">service_ticket_pos_list</xsl:element>
                        </xsl:element>                
                    </xsl:element>				
					<xsl:element name="processing_status">
						<xsl:value-of select="request-param[@name='PROCESSING_STATUS']" />
					</xsl:element>
				</xsl:element>
			</xsl:element>

            <!--  Activate Customer Order -->

	        <xsl:element name="CcmFifActivateCustomerOrderCmd">
				<xsl:element name="command_id">activate_co_1</xsl:element>
				<xsl:element name="CcmFifActivateCustomerOrderInCont">
					<xsl:element name="customer_order_id_ref">
						<xsl:element name="command_id">create_co_1</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>      

			<!-- Create contact -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact_1</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="contact_type_rd">AUTO_TERM</xsl:element>
					<xsl:element name="short_description">Kündigung</xsl:element>
					<xsl:element name="description_text_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>Die Produktnutzung </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text> (Vertrag </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">contract_number</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>, Serviceschein </xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">find_service_1</xsl:element>
							<xsl:element name="field_name">product_commitment_number</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>) wurde gekündigt.</xsl:text>
								<xsl:if test="request-param[@name='PROCESSING_STATUS'] != ''">
									<xsl:text>Die Kündigung wurde sofort aktiviert, da der </xsl:text>
									<xsl:text>Anschluss technisch bereits abgeschaltet war.</xsl:text>
								</xsl:if>

								<xsl:text>&#xA;Kündigungsgrund: </xsl:text>
								<xsl:value-of select="$TerminationReason" />

								<xsl:text>&#xA;TransactionID: </xsl:text>
								<xsl:value-of select="request-param[@name='transactionID']" />
								<xsl:text>&#xA;FIF-Client: </xsl:text>
								<xsl:value-of select="request-param[@name='clientName']" />
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>


		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
