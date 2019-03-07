<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for sending service bus notification for link-db
	
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
 
			<!-- Determine trigger type -->
			<xsl:variable name="TriggerType">TEA</xsl:variable>

			<!-- Determine customer origin, we are taking only the first letter (A or V) -->
			<xsl:variable name="CustomerOrigin">
				<xsl:value-of select="substring(request-param[@name='SERVICE_PROVIDER'],1,1)"/>
			</xsl:variable>

			<!-- Generate Trigger ID -->
			<xsl:element name="CcmFifGenerateTriggerIdCmd">
				<xsl:element name="command_id">generate_trigger_id_1</xsl:element>
			</xsl:element>


			<!-- validate if customer is link db type -->
			<xsl:element name="CcmFifValidateCustIsForLinkDbCmd">
				<xsl:element name="command_id">validate_cust_is_for_link_db_1</xsl:element>
				<xsl:element name="CcmFifValidateCustIsForLinkDbInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>


			<!-- call the bus for master data update request -->
			<xsl:element name="CcmFifProcessServiceBusRequestCmd">
				<xsl:element name="command_id">request_master_data_update</xsl:element>
				<xsl:element name="CcmFifProcessServiceBusRequestInCont">
					<xsl:element name="package_name">net.arcor.custwg.epsm_custwg_whsvf_001</xsl:element>
					<xsl:element name="service_name">SetTrigger</xsl:element>
					<xsl:element name="synch_ind">N</xsl:element>
					<xsl:element name="external_system_id">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="priority">3</xsl:element>
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TriggerRequest;TriggerType</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="$TriggerType"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TriggerRequest;SequenceNumber</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">generate_trigger_id_1</xsl:element>
								<xsl:element name="field_name">trigger_id</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TriggerRequest;TriggerDate</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TriggerRequest;CustomerNumber</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TriggerRequest;CustomerType</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='CUSTOMER_TYPE']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TriggerRequest;CustomerOrigin</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="$CustomerOrigin"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TriggerRequest;Ban</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='VODAFONE_ID']"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">TriggerRequest;Ioid</xsl:element>
							<xsl:element name="parameter_value">
								<xsl:value-of select="request-param[@name='INTEGRATED_ORDER_ID']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">validate_cust_is_for_link_db_1</xsl:element>
						<xsl:element name="field_name">customer_is_for_link_db_ind</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- create contact  -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">LINK_DB</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>Link-DB </xsl:text>
						<xsl:value-of select="$TriggerType"/>
						<xsl:text> Trigger</xsl:text>
					</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>Schließen des letzten Rechnungskontos des Kunden </xsl:text>
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
						<xsl:text> am </xsl:text>
						<xsl:value-of select="request-param[@name='TERMINATION_DATE']"/>
						<xsl:text>&#xA;wurde an Vodafone-Link-DB kommuniziert.</xsl:text>						
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">validate_cust_is_for_link_db_1</xsl:element>
						<xsl:element name="field_name">customer_is_for_link_db_ind</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>

		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
