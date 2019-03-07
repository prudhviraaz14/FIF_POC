<?xml version="1.0" encoding="ISO-8859-1"?>   
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--   XSLT file for Changing Entity Type from Individual to Organization and vice versa
            @author Shrikant -->
            
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
	<xsl:template match="/">
		<xsl:element name="CcmFifCommandList">
			<xsl:apply-templates select="request/request-params"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="request-params">
		<!-- Copy over transaction ID,action name -->
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
		    <!-- Get Entity Information using customer number-->
			<xsl:element name="CcmFifGetEntityCmd">
			  <xsl:element name="command_id">get_entity_1</xsl:element>
				<xsl:element name="CcmFifGetEntityInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Check the mandatory parametrs for entity type as Individual -->
			<xsl:if test="(request-param[@name='entityType'] = 'I') and ((request-param[@name='forename'] = '') or (request-param[@name='birthDate'] = ''))">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">entity_parameters_error</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">Mandatory parameters missing [Forename or BirthDate]</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 
			
	    	<!-- Update Entity Information depending upon the entity type-->	
            <xsl:element name="CcmFifUpdateEntityCmd">
				<xsl:element name="command_id">update_entity_1</xsl:element>
				  <xsl:element name="CcmFifUpdateEntityInCont">
				  <xsl:element name="entity_ref">
					<xsl:element name="command_id">get_entity_1</xsl:element>
					<xsl:element name="field_name">entity_id</xsl:element>
				</xsl:element>
				<xsl:element name="salutation_description">
					<xsl:value-of select="request-param[@name='salutationDescription']"/>
				</xsl:element>
				<xsl:element name="name">
						<xsl:value-of select="request-param[@name='name']"/>
				</xsl:element>
			<!-- If entity type is I means Individual then update only Individual specific fields-->
				<xsl:if test="(request-param[@name='entityType'] = 'I')">  
					<xsl:element name="entity_type">I</xsl:element>				
					<xsl:element name="title_description">
						<xsl:value-of select="request-param[@name='titleDescription']"/>
					</xsl:element>
						<xsl:element name="nobility_prefix_description">
					<xsl:value-of select="request-param[@name='nobilityPrefixDescription']"/>
					</xsl:element>
					<xsl:element name="forename">
						<xsl:value-of select="request-param[@name='forename']"/>
					</xsl:element>
					<xsl:element name="surname_prefix_description">
						<xsl:value-of select="request-param[@name='surnamePrefixDescription']"/>
					</xsl:element>
					<xsl:element name="birth_date">
						<xsl:value-of select="request-param[@name='birthDate']"/>
					</xsl:element>
					<xsl:element name="id_card_country_rd">
						<xsl:value-of select="request-param[@name='idCardCountryRd']"/>
					</xsl:element>
					<xsl:element name="id_card_expiration_date">
						<xsl:value-of select="request-param[@name='idCardExpirationDate']"/>
					</xsl:element>
					<xsl:element name="id_card_type_rd">
						<xsl:value-of select="request-param[@name='idCardTypeRd']"/>
					</xsl:element>
					<xsl:element name="marital_status_rd">
						<xsl:value-of select="request-param[@name='maritalStatusRd']"/>
					</xsl:element>
					<xsl:element name="profession_name">
						<xsl:value-of select="request-param[@name='professionName']"/>
					</xsl:element>
					<xsl:element name="id_card_number">
						<xsl:value-of select="request-param[@name='idCardNumber']"/>
					</xsl:element>
					<xsl:element name="spoken_language_rd">
						<xsl:value-of select="request-param[@name='spokenLanguageRd']"/>
					</xsl:element>		
			</xsl:if>
			<!-- If entity type is O means Organization then update only organization specific fields-->
				<xsl:if test="(request-param[@name='entityType'] = 'O')">	
					<xsl:element name="entity_type">O</xsl:element>				  
					<xsl:element name="organization_type_rd">
						<xsl:value-of select="request-param[@name='organizationTypeRd']"/>
					</xsl:element>
					<xsl:element name="organization_suffix_name">
						<xsl:value-of select="request-param[@name='organizationSuffixName']"/>
					</xsl:element>
					<xsl:element name="domestic_organization_ind">
						<xsl:value-of select="request-param[@name='domesticOrganizationInd']"/>
					</xsl:element>
					<xsl:element name="incorporation_number_id">
						<xsl:value-of select="request-param[@name='incorporationNumberId']"/>
					</xsl:element>
					<xsl:element name="industrial_sector_rd">
						<xsl:value-of select="request-param[@name='industrialSectorRd']"/>
					</xsl:element>
					<xsl:element name="incorporation_type_rd">
						<xsl:value-of select="request-param[@name='incorporationTypeRd']"/>
					</xsl:element>
					<xsl:element name="incorporation_city_name">
						<xsl:value-of select="request-param[@name='incorporationCityName']"/>
					</xsl:element>	
				</xsl:if>	
			</xsl:element>  
		</xsl:element>  
    </xsl:element>
</xsl:template>
</xsl:stylesheet>
