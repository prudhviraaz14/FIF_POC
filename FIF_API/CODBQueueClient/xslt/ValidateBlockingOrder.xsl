<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for validating pricing structure code
	
	@author wlazlow
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0" xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
			
			<xsl:if test="request-param[@name='validateProductCommitment'] = 'Y'">
				<xsl:element name="CcmFifValidateBlockingOrderCmd">
					<xsl:element name="command_id">validate_blocking_order</xsl:element>
					<xsl:element name="CcmFifValidateBlockingOrderInCont">
						<xsl:element name="product_commitment_number">
							<xsl:value-of select="request-param[@name='productCommitmentNumber']"/>
						</xsl:element>
						<xsl:element name="barcode">
							<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>

			<xsl:element name="CcmFifFindServiceTicketPositionCmd">
			    <xsl:element name="command_id">find_open_stp</xsl:element>
			    <xsl:element name="CcmFifFindServiceTicketPositionInCont">
			        <xsl:element name="service_subscription_id">
			            <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
			        </xsl:element>
			        <xsl:element name="no_stp_error">N</xsl:element>
			        <xsl:element name="find_stp_parameters">
			            <xsl:element name="CcmFifFindStpParameterCont">
			                <xsl:element name="service_ticket_position_state">ASSIGNED</xsl:element>
			                <xsl:element name="action_name">moveProductSubscription</xsl:element>
			            </xsl:element>
			        </xsl:element>
			    </xsl:element>
			</xsl:element>
			
	        <xsl:element name="CcmFifRaiseErrorCmd">
	            <xsl:element name="command_id">open_stp_found</xsl:element>
	            <xsl:element name="CcmFifRaiseErrorInCont">
	                <xsl:element name="error_text">
	                    <xsl:text>Verschieben einer Produktnutzung ist noch nicht abgeschlossen. Bitte vor Erfassung eines COM-Auftrags erst abschließen / stornieren. Betroffene Dienstenutzung: </xsl:text>
	                    <xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
	                </xsl:element>
	                <xsl:element name="process_ind_ref">
	                    <xsl:element name="command_id">find_open_stp</xsl:element>
	                    <xsl:element name="field_name">stp_found</xsl:element>
	                </xsl:element>
	                <xsl:element name="required_process_ind">Y</xsl:element>                  
	            </xsl:element>
	        </xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
