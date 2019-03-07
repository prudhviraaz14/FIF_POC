<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--
  XSLT file for creating a FIF request for creating a full customer. It creates following:
  Entity, Address, Mailing, Account and Customer

  @author makuier
-->
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
	<xsl:template match="/">
		<xsl:element name="CcmFifCommandList">
			<xsl:apply-templates select="request/request-params"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="request-params">
		<!-- Copy over transaction ID,action name & override_system_date -->
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
			<!-- Validate address details -->
			<xsl:if test="(request-param[@name='CREATE_ADDRESS'] = 'Y')
				and (( request-param[@name='STREET_NAME'] = '' )
			 	  or( request-param[@name='STREET_NUMBER'] = '' )
			 	  or( request-param[@name='POSTAL_CODE'] = '' )
			 	  or( request-param[@name='CITY_NAME'] = '' ))">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">address_field_error</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">All address details must be provided.</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>		

			<!-- Create Entity-->
			<xsl:element name="CcmFifCreateEntityCmd">
				<xsl:element name="command_id">create_entity_1</xsl:element>
				<xsl:element name="CcmFifCreateEntityInCont">
					<xsl:element name="entity_type">I</xsl:element>
					<xsl:element name="salutation_description">
						<xsl:value-of select="request-param[@name='SALUTATION_DESCRIPTION']"/>
					</xsl:element>
					<xsl:element name="title_description">
						<xsl:value-of select="request-param[@name='TITLE_DESCRIPTION']"/>
					</xsl:element>
					<xsl:element name="nobility_prefix_description">
						<xsl:value-of select="request-param[@name='NOBILITY_PREFIX_DESCRIPTION']"/>
					</xsl:element>
					<xsl:element name="forename">
						<xsl:value-of select="request-param[@name='FORENAME']"/>
					</xsl:element>
                    <xsl:element name="surname_prefix_description">
                       <xsl:value-of select="request-param[@name='SURNAME_PREFIX_DESCRIPTION']"/>
                    </xsl:element>
					<xsl:element name="name">
						<xsl:value-of select="request-param[@name='NAME']"/>
					</xsl:element>
					<xsl:element name="birth_date">
						<xsl:value-of select="request-param[@name='BIRTH_DATE']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Create Access Information -->
			<xsl:if test="request-param[@name='CREATE_ACCESS_INFORMATION'] = 'Y'">
            <xsl:element name="CcmFifUpdateAccessInformCmd">
               <xsl:element name="command_id">create_access_information_1</xsl:element>
				<xsl:element name="CcmFifUpdateAccessInformInCont">
					<xsl:element name="entity_ref">
						<xsl:element name="command_id">create_entity_1</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element>
					<xsl:element name="access_information_type_rd">
						<xsl:value-of select="request-param[@name='ACCESS_INFORMATION_TYPE']"/>
					</xsl:element>
					<xsl:element name="contact_name">
						<xsl:value-of select="concat(request-param[@name='FORENAME'],' ',request-param[@name='NAME'])"/>
					</xsl:element>
					<xsl:element name="phone_number">
						<xsl:value-of select="request-param[@name='PHONE_NUMBER']"/>
					</xsl:element>
					<xsl:element name="mobile_number">
						<xsl:value-of select="request-param[@name='MOBILE_NUMBER']"/>
					</xsl:element>
					<xsl:element name="fax_number">
						<xsl:value-of select="request-param[@name='FAX_NUMBER']"/>
					</xsl:element>
					<xsl:element name="email_address">
						<xsl:value-of select="request-param[@name='EMAIL_ADDRESS']"/>
					</xsl:element>
					<xsl:element name="electronic_contact_indicator">
						<xsl:value-of select="request-param[@name='ELECTRONIC_CONTACT_INDICATOR']"/>
					</xsl:element>
				</xsl:element>
            </xsl:element>
            </xsl:if>
			<!-- Create Address-->
			<xsl:if test="request-param[@name='CREATE_ADDRESS'] = 'Y'">
			<xsl:element name="CcmFifCreateAddressCmd">
				<xsl:element name="command_id">create_address_1</xsl:element>
				<xsl:element name="CcmFifCreateAddressInCont">
					<xsl:element name="entity_ref">
						<xsl:element name="command_id">create_entity_1</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element>
					<xsl:element name="address_type">
						<xsl:value-of select="request-param[@name='ADDRESS_TYPE']"/>
					</xsl:element>
					<xsl:element name="street_name">
						<xsl:value-of select="request-param[@name='STREET_NAME']"/>
					</xsl:element>
					<xsl:element name="street_number">
						<xsl:value-of select="request-param[@name='STREET_NUMBER']"/>
					</xsl:element>
                    <xsl:element name="street_number_suffix">
                        <xsl:value-of select="request-param[@name='STREET_NUMBER_SUFFIX']"/>
                    </xsl:element>
					<xsl:element name="postal_code">
						<xsl:value-of select="request-param[@name='POSTAL_CODE']"/>
					</xsl:element>
					<xsl:element name="city_name">
						<xsl:value-of select="request-param[@name='CITY_NAME']"/>
					</xsl:element>
                    <xsl:element name="city_suffix_name">
                        <xsl:value-of select="request-param[@name='CITY_SUFFIX_NAME']"/>
                    </xsl:element>
					<xsl:element name="country_code">
						<xsl:value-of select="request-param[@name='COUNTRY_CODE']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
            </xsl:if>
			<!-- Create Contact Role-->
			<xsl:element name="CcmFifCreateContactRoleCmd">
				<xsl:element name="command_id">create_contact_role_1</xsl:element>
				<xsl:element name="CcmFifCreateContactRoleInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
					<xsl:element name="entity_id_ref">
						<xsl:element name="command_id">create_entity_1</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_id">
						<xsl:value-of select="request-param[@name='CUSTOMER_NUMBER']"/>
					</xsl:element>
			        <xsl:if test="request-param[@name='CREATE_ADDRESS'] = 'Y'">
					   <xsl:element name="address_id_ref">
						   <xsl:element name="command_id">create_address_1</xsl:element>
						   <xsl:element name="field_name">address_id</xsl:element>
					   </xsl:element>
                    </xsl:if>
			        <xsl:if test="request-param[@name='CREATE_ADDRESS'] != 'Y'">
					   <xsl:element name="address_id">
						   <xsl:value-of select="request-param[@name='ADDRESS_ID']"/>
					   </xsl:element>
                    </xsl:if>
			        <xsl:if test="request-param[@name='CREATE_ACCESS_INFORMATION'] = 'Y'">
					   <xsl:element name="access_information_ref">
						   <xsl:element name="command_id">create_access_information_1</xsl:element>
						   <xsl:element name="field_name">access_information_id</xsl:element>
					   </xsl:element>
                    </xsl:if>
			        <xsl:if test="request-param[@name='CREATE_ACCESS_INFORMATION'] != 'Y'">
					   <xsl:element name="access_information_id">
						   <xsl:value-of select="request-param[@name='ACCESS_INFORMATION_ID']"/>
					   </xsl:element>
                    </xsl:if>
					<xsl:element name="supported_object_type_rd">CUSTOMER</xsl:element>
					<xsl:element name="contact_role_type_rd">
						<xsl:value-of select="request-param[@name='CONTACT_ROLE_TYPE_RD']"/>
					</xsl:element>
					<xsl:element name="contact_role_position_name">
						<xsl:value-of select="request-param[@name='CONTACT_ROLE_POSITION_NAME']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
			
