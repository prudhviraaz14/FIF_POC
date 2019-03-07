<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file checking if teh customer is innactive, and deactivating it if needed
	
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

			<!-- Check And Deactivate Inactive Customer -->
			
			<xsl:element name="CcmFifCheckAndDeactInactiveCustomerCmd">
				<xsl:element name="command_id">check_and_deact_inactiv_cust_1</xsl:element>
				<xsl:element name="CcmFifCheckAndDeactInactiveCustomerInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
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
					<xsl:element name="contact_type_rd">CUSTOMER</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>Rechnungskonten autom. geschl.</xsl:text>						         
					</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>Rechnungskonten des inaktiven Kunden </xsl:text>
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
						<xsl:text> wurden automatisch geschlossen.</xsl:text>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">check_and_deact_inactiv_cust_1</xsl:element>
						<xsl:element name="field_name">customer_will_be_deactivated_ind</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
						
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
