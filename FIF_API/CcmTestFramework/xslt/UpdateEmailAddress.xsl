<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for modifying access information

  @author iarizova
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
  exclude-result-prefixes="dateutils">
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

		<xsl:variable name="desiredDate">  
			<xsl:value-of select="dateutils:createFIFDateOffset(dateutils:getCurrentDate(), 'DATE', '1')"/>
		</xsl:variable>
		      
		<xsl:element name="CcmFifGetAccountDataCmd">
			<xsl:element name="command_id">get_account_data</xsl:element>
			<xsl:element name="CcmFifGetAccountDataInCont">
				<xsl:element name="account_number">
					<xsl:value-of select="request-param[@name='accountNumber']"/>
				</xsl:element>                    
				<xsl:element name="effective_date">
					<xsl:value-of select="$desiredDate"/>
				</xsl:element>
			</xsl:element>    
		</xsl:element>        

		<xsl:element name="CcmFifGetDocumentRecipientInfoCmd">
			<xsl:element name="command_id">get_document_recipient</xsl:element>
			<xsl:element name="CcmFifGetDocumentRecipientInfoInCont">
				<xsl:element name="customer_number_ref">
					<xsl:element name="command_id">get_account_data</xsl:element>
					<xsl:element name="field_name">customer_number</xsl:element>
				</xsl:element>
				<xsl:element name="account_number">
					<xsl:value-of select="request-param[@name='accountNumber']"/>
				</xsl:element>                    
				<xsl:element name="effective_date">
					<xsl:value-of select="$desiredDate"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
		
		<xsl:if test="request-param[@name='synchronizePrimaryContact'] = 'N'">

			<xsl:element name="CcmFifGetEntityCmd">
				<xsl:element name="command_id">get_entity</xsl:element>
				<xsl:element name="CcmFifGetEntityInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">get_account_data</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>          

	        <!-- checks, if customer's entity and document recipient's are the same -->
			<xsl:element name="CcmFifValidateValueCmd">
				<xsl:element name="command_id">one_entity</xsl:element>
				<xsl:element name="CcmFifValidateValueInCont">
					<xsl:element name="value_ref">
						<xsl:element name="command_id">get_entity</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element>
					<xsl:element name="object_type">Entity</xsl:element>
					<xsl:element name="value_type">EntityID</xsl:element>
					<xsl:element name="allowed_values">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">get_document_recipient</xsl:element>
							<xsl:element name="field_name">entity_id</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="ignore_failure_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>			

	        <!-- checks, if customer's entity and document recipient's are the same -->
			<xsl:element name="CcmFifCloneEntityCmd">
				<xsl:element name="command_id">clone_entity</xsl:element>
				<xsl:element name="CcmFifCloneEntityInCont">
					<xsl:element name="entity_id_ref">
						<xsl:element name="command_id">get_entity</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">one_entity</xsl:element>
						<xsl:element name="field_name">success_ind</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- attach the new access information to the doc recpt -->
			<xsl:element name="CcmFifModifyDocumentRecipientCmd">
				<xsl:element name="command_id">modify_doc_recpt</xsl:element>
				<xsl:element name="CcmFifModifyDocumentRecipientInCont">
					<xsl:element name="document_recipient_ref">
						<xsl:element name="command_id">get_document_recipient</xsl:element>
						<xsl:element name="field_name">document_recipient_id</xsl:element>
					</xsl:element>
					<xsl:element name="effective_date">
						<xsl:value-of select="$desiredDate"/>
					</xsl:element>
					<xsl:element name="entity_ref">
						<xsl:element name="command_id">clone_entity</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element> 
					<xsl:element name="access_information_ref">
						<xsl:element name="command_id">clone_entity</xsl:element>
						<xsl:element name="field_name">access_information_id</xsl:element>
					</xsl:element> 
					<xsl:element name="address_ref">
						<xsl:element name="command_id">clone_entity</xsl:element>
						<xsl:element name="field_name">address_id</xsl:element>
					</xsl:element> 
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">one_entity</xsl:element>
						<xsl:element name="field_name">success_ind</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>

			<xsl:element name="CcmFifGetDocumentRecipientInfoCmd">
				<xsl:element name="command_id">get_document_recipient</xsl:element>
				<xsl:element name="CcmFifGetDocumentRecipientInfoInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">get_account_data</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="account_number">
						<xsl:value-of select="request-param[@name='accountNumber']"/>
					</xsl:element>                    
					<xsl:element name="effective_date">
						<xsl:value-of select="$desiredDate"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>
		
		<!-- Update Access Information -->
		<xsl:element name="CcmFifUpdateAccessInformCmd">
			<xsl:element name="command_id">change_account_email_address</xsl:element>
			<xsl:element name="CcmFifUpdateAccessInformInCont">
				<xsl:element name="entity_ref">
					<xsl:element name="command_id">get_document_recipient</xsl:element>
					<xsl:element name="field_name">entity_id</xsl:element>
				</xsl:element>          
				<xsl:element name="access_information_ref">
					<xsl:element name="command_id">get_document_recipient</xsl:element>
					<xsl:element name="field_name">access_information_id</xsl:element>
				</xsl:element>          
				<xsl:element name="effective_date">
					<xsl:value-of select="$desiredDate"/>
				</xsl:element>
				<xsl:element name="email_address">
					<xsl:value-of select="request-param[@name='emailAddress']"/>
				</xsl:element>
				<xsl:element name="electronic_contact_indicator">Y</xsl:element>
			</xsl:element>
		</xsl:element>
        
        <xsl:if test="request-param[@name='synchronizePrimaryContact'] = 'Y'">
			<xsl:element name="CcmFifGetEntityCmd">
				<xsl:element name="command_id">get_entity</xsl:element>
				<xsl:element name="CcmFifGetEntityInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">get_account_data</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>          
        
			<!-- Update Access Information -->
			<xsl:element name="CcmFifUpdateAccessInformCmd">
				<xsl:element name="command_id">change_customer_email_address</xsl:element>
				<xsl:element name="CcmFifUpdateAccessInformInCont">
					<xsl:element name="entity_ref">
						<xsl:element name="command_id">get_entity</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element>          
					<xsl:element name="access_information_ref">
						<xsl:element name="command_id">get_entity</xsl:element>
						<xsl:element name="field_name">primary_access_info_id</xsl:element>
					</xsl:element>          
					<xsl:element name="effective_date">
						<xsl:value-of select="$desiredDate"/>
					</xsl:element>
					<xsl:element name="email_address">
						<xsl:value-of select="request-param[@name='emailAddress']"/>
					</xsl:element>
					<xsl:element name="electronic_contact_indicator">Y</xsl:element>
				</xsl:element>
			</xsl:element>
        </xsl:if>
        
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
