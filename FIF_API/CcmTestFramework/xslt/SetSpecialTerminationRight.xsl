<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for setting special termination right

  @author Naveen
-->
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" exclude-result-prefixes="dateutils" version="1.0">
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
		<xsl:element name="Command_List">
			<xsl:element name="CcmFifGetProductCommitmentDataCmd">
				<xsl:element name="command_id">Find_Product_Commitment_1</xsl:element>
				<xsl:element name="CcmFifGetProductCommitmentDataInCont">
					<xsl:element name="product_commitment_number">
						<xsl:value-of select="request-param[@name='PRODUCT_COMMITMENT_NUMBER']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifGetOwningCustomerCmd">
				<xsl:element name="command_id">Get_Customer_1</xsl:element>
				<xsl:element name="CcmFifGetOwningCustomerInCont">
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">Find_Product_Commitment_1</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifGetContractTypeCmd">
				<xsl:element name="command_id">Get_Contract_Type_1</xsl:element>
				<xsl:element name="CcmFifGetContractTypeInCont">
					<xsl:element name="contract_number_ref">
						<xsl:element name="command_id">Find_Product_Commitment_1</xsl:element>
						<xsl:element name="field_name">contract_number</xsl:element>
					</xsl:element>
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">Get_Customer_1</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="CcmFifModifyContractDataCmd">
				<xsl:element name="command_id">Modify_Contract_data</xsl:element>
				<xsl:element name="CcmFifModifyContractDataInCont">
					<xsl:element name="product_commitment_number">
						<xsl:value-of select="request-param[@name='PRODUCT_COMMITMENT_NUMBER']"/>
					</xsl:element>
					<xsl:element name="contract_type_rd_ref">
						<xsl:element name="command_id">Get_Contract_Type_1</xsl:element>
						<xsl:element name="field_name">contract_type_rd</xsl:element>
					</xsl:element>
					<xsl:element name="special_termination_right">
						<xsl:value-of select="request-param[@name='SPECIAL_TERMINATION_RIGHT']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Contact -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact_1</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">Get_Customer_1</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="contact_type_rd">CONTRACT</xsl:element>
					<xsl:element name="short_description">Vertragsänderung</xsl:element>
					<xsl:element name="description_text_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>Das Fristloses Kündigungsrecht wurde geändert</xsl:text>
							</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="contact_text">
								<xsl:text>;&#xA;Serviceschein ID: </xsl:text>
								<xsl:value-of select="request-param[@name='PRODUCT_COMMITMENT_NUMBER']"/>
								<xsl:text>;&#xA;TransactionID: </xsl:text>
								<xsl:value-of select="request-param[@name='transactionID']"/>
								<xsl:text>;&#xA;FIF-Client: </xsl:text>
								<xsl:value-of select="request-param[@name='clientName']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
		
