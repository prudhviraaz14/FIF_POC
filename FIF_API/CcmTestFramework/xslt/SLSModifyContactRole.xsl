<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--
  XSLT file for doing modifications on contactRoles

  @author schwarje
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
            <xsl:value-of select="request-param[@name='clientName']"/>
        </xsl:element>
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
		</xsl:element>
		<xsl:element name="Command_List">
			
	        <xsl:if test="count(request-param-list[@name='contactRoleReferenceList']/request-param-list-item) != 0
	        			and request-param[@name='contactRoleReferenceAction'] != ''">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">onlyUseListsOrSimpleParameters</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">Bitte contactRoleReferenceList ODER einfache Parameter nutzen, nicht beide.</xsl:element>
					</xsl:element>                                      
	       		</xsl:element>        			
	        </xsl:if>
	        
	        <xsl:if test="request-param[@name='createContactRoleEntity'] = 'N' 
	        			and request-param[@name='contactRoleReferenceAction'] = ''
	        			and count(request-param-list[@name='contactRoleReferenceList']/request-param-list-item) = 0">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">nothingToDo</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">Überflüssige FIF-Transaktion, nichts zu tun (createContactRoleEntity = N und contactRoleReferenceAction nicht gesetzt).</xsl:element>
					</xsl:element>                                      
	       		</xsl:element>        			
	        </xsl:if>
        
			<xsl:if test="request-param[@name='createContactRoleEntity'] = 'Y'">
				<xsl:choose>
					<xsl:when test="request-param[@name='entityId'] = ''">
						<!-- Create Entity-->
						<xsl:element name="CcmFifCreateEntityCmd">
							<xsl:element name="command_id">create_entity</xsl:element>
							<xsl:element name="CcmFifCreateEntityInCont">
								<xsl:element name="entity_type">
									<xsl:choose>
										<xsl:when test="request-param[@name='organizationType'] != ''">O</xsl:when>
										<xsl:otherwise>I</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
								<xsl:element name="salutation_description">
									<xsl:value-of select="request-param[@name='salutationDescription']"/>
								</xsl:element>
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
									<xsl:value-of select="request-param[@name='surnamePrefix']"/>
								</xsl:element>
								<xsl:element name="name">
									<xsl:value-of select="request-param[@name='name']"/>
								</xsl:element>
								<xsl:element name="birth_date">
									<xsl:value-of select="request-param[@name='birthDate']"/>
								</xsl:element>
								<xsl:element name="organization_type_rd">
									<xsl:value-of select="request-param[@name='organizationType']"/>
								</xsl:element>	
								<xsl:element name="organization_suffix_name">
									<xsl:value-of select="request-param[@name='organizationSuffixName']"/>
								</xsl:element>
								<xsl:element name="incorporation_number_id">
									<xsl:value-of select="request-param[@name='incorporationNumber']"/>
								</xsl:element>	
								<xsl:element name="incorporation_type_rd">
									<xsl:value-of select="request-param[@name='incorporationType']"/>
								</xsl:element>	
								<xsl:element name="incorporation_city_name">
									<xsl:value-of select="request-param[@name='incorporationCityName']"/>
								</xsl:element>		
							</xsl:element>
						</xsl:element>
					
						<!-- Create Access Information -->
						<xsl:element name="CcmFifUpdateAccessInformCmd">
							<xsl:element name="command_id">create_access_information</xsl:element>
							<xsl:element name="CcmFifUpdateAccessInformInCont">
								<xsl:element name="entity_ref">
									<xsl:element name="command_id">create_entity</xsl:element>
									<xsl:element name="field_name">entity_id</xsl:element>
								</xsl:element>
								<xsl:element name="access_information_type_rd">
									<xsl:value-of select="request-param[@name='accessInformationType']"/>							
								</xsl:element>
								<xsl:element name="contact_name">
									<xsl:choose>
										<xsl:when test="request-param[@name='contactName'] != ''">
											<xsl:value-of select="request-param[@name='contactName']"/>		
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat(request-param[@name='forename'],' ',request-param[@name='name'])"/>		
										</xsl:otherwise>
									</xsl:choose>							
								</xsl:element>
								<xsl:element name="phone_number">
									<xsl:value-of select="request-param[@name='phoneNumber']"/>
								</xsl:element>
								<xsl:element name="mobile_number">
									<xsl:choose>
										<xsl:when test="starts-with(request-param[@name='mobileNumber'], '0049')">
											<xsl:text>0</xsl:text>
											<xsl:value-of select="substring-after(request-param[@name='mobileNumber'], '0049')"/>
										</xsl:when>
										<xsl:when test="starts-with(request-param[@name='mobileNumber'], '+49')">
											<xsl:text>0</xsl:text>
											<xsl:value-of select="substring-after(request-param[@name='mobileNumber'], '+49')"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="request-param[@name='mobileNumber']"/>
										</xsl:otherwise>
									</xsl:choose>							
								</xsl:element>
								<xsl:element name="fax_number">
									<xsl:value-of select="request-param[@name='faxNumber']"/>
								</xsl:element>
								<xsl:element name="email_address">
									<xsl:value-of select="request-param[@name='emailAddress']"/>
								</xsl:element>
								<xsl:element name="electronic_contact_indicator">
									<xsl:value-of select="request-param[@name='electronicContactIndicator']"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					
						<xsl:if test="request-param[@name='cityName'] != ''">
							<!-- Create Address-->
							<xsl:element name="CcmFifCreateAddressCmd">
								<xsl:element name="command_id">create_address</xsl:element>
								<xsl:element name="CcmFifCreateAddressInCont">
									<xsl:element name="entity_ref">
										<xsl:element name="command_id">create_entity</xsl:element>
										<xsl:element name="field_name">entity_id</xsl:element>
									</xsl:element>
									<xsl:element name="address_type">
										<xsl:value-of select="request-param[@name='addressType']"/>
									</xsl:element>
									<xsl:choose>
										<xsl:when test="request-param[@name='streetName'] != ''">
											<xsl:element name="street_name">
												<xsl:value-of select="request-param[@name='streetName']"/>
											</xsl:element>
											<xsl:element name="street_number">
												<xsl:value-of select="request-param[@name='streetNumber']"/>
											</xsl:element>							
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="post_office_box">
												<xsl:value-of select="request-param[@name='postOfficeBox']"/>
											</xsl:element>														
										</xsl:otherwise>
									</xsl:choose>
									<xsl:element name="street_number_suffix">
										<xsl:value-of select="request-param[@name='numberSuffix']"/>							
									</xsl:element>
									<xsl:element name="postal_code">
										<xsl:value-of select="request-param[@name='postalCode']"/>
									</xsl:element>
									<xsl:element name="city_name">
										<xsl:value-of select="request-param[@name='cityName']"/>
									</xsl:element>
									<xsl:element name="city_suffix_name">
										<xsl:value-of select="request-param[@name='citySuffix']"/>
									</xsl:element>
									<xsl:if test="request-param[@name='countryCode'] != ''">
									<xsl:element name="country_code">
										<xsl:value-of select="request-param[@name='countryCode']"/>
									</xsl:element>
									</xsl:if>
									<xsl:if test="request-param[@name='countryCode'] = ''">
									  <xsl:element name="country_code">DE</xsl:element>
									</xsl:if>
									<xsl:element name="set_primary_address">Y</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="CcmFifGetEntityCmd">
							<xsl:element name="command_id">get_entity</xsl:element>
							<xsl:element name="CcmFifGetEntityInCont">
								<xsl:element name="entity_id">
									<xsl:value-of select="request-param[@name='entityId']"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>          
					</xsl:otherwise>
				</xsl:choose>
				
				<!-- Create Contact Role-->
				<xsl:element name="CcmFifCreateContactRoleCmd">
					<xsl:element name="command_id">create_contact_role_entity</xsl:element>
					<xsl:element name="CcmFifCreateContactRoleInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:choose>
							<xsl:when test="request-param[@name='entityId'] = ''">
								<xsl:element name="entity_id_ref">
									<xsl:element name="command_id">create_entity</xsl:element>
									<xsl:element name="field_name">entity_id</xsl:element>
								</xsl:element>
								<xsl:element name="supported_object_id"/>
								<xsl:element name="address_id_ref">
									<xsl:element name="command_id">create_address</xsl:element>
									<xsl:element name="field_name">address_id</xsl:element>
								</xsl:element>
								<xsl:element name="access_information_ref">
									<xsl:element name="command_id">create_access_information</xsl:element>
									<xsl:element name="field_name">access_information_id</xsl:element>
								</xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="entity_id_ref">
									<xsl:element name="command_id">get_entity</xsl:element>
									<xsl:element name="field_name">entity_id</xsl:element>
								</xsl:element>
								<xsl:element name="supported_object_id"/>
								<xsl:element name="address_id_ref">
									<xsl:element name="command_id">get_entity</xsl:element>
									<xsl:element name="field_name">primary_address_id</xsl:element>
								</xsl:element>
								<xsl:element name="access_information_ref">
									<xsl:element name="command_id">get_entity</xsl:element>
									<xsl:element name="field_name">primary_access_info_id</xsl:element>
								</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:element name="supported_object_type_rd"/>
						<xsl:element name="contact_role_type_rd">
							<xsl:value-of select="request-param[@name='contactRoleType']"/>
						</xsl:element>
						<xsl:element name="contact_role_position_name">
							<xsl:value-of select="request-param[@name='contactRolePositionName']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>				
			</xsl:if>
			
			<xsl:choose>
				<xsl:when test="request-param[@name='contactRoleReferenceAction'] = 'ADD'">
					<!-- Create Contact Role-->
					<xsl:element name="CcmFifCreateContactRoleCmd">
						<xsl:element name="command_id">create_contact_role_reference</xsl:element>
						<xsl:element name="CcmFifCreateContactRoleInCont">
							<xsl:element name="customer_number"/>
							<xsl:choose>
								<xsl:when test="request-param[@name='createContactRoleEntity'] = 'N'">
									<xsl:element name="contact_role_entity_id">
										<xsl:value-of select="request-param[@name='contactRoleEntityId']"/>
									</xsl:element>
								</xsl:when>
								<xsl:otherwise>							
									<xsl:element name="contact_role_entity_id_ref">
										<xsl:element name="command_id">create_contact_role_entity</xsl:element>
										<xsl:element name="field_name">contact_role_entity_id</xsl:element>
									</xsl:element>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:element name="supported_object_id">
								<xsl:value-of select="request-param[@name='supportedObjectId']"/>
							</xsl:element>							
							<xsl:element name="supported_object_type_rd">
								<xsl:value-of select="request-param[@name='supportedObjectType']"/>						
							</xsl:element>
							<xsl:element name="contact_role_type_rd">
<!-- 								<xsl:value-of select="request-param[@name='contactRoleType']"/>						 -->
							</xsl:element>
						</xsl:element>				
					</xsl:element>
				</xsl:when>
				<xsl:when test="request-param[@name='contactRoleReferenceAction'] = 'REMOVE'">
					<xsl:choose>
                  <!-- terminate contactRole referenced by supportedObjectId -->
                  <!--  only old type of contact role having contactRoleEntityId equal null -->
						<xsl:when test="request-param[@name='contactRoleEntityId'] = 'OLD_CONTACT_ROLE'">
							<xsl:element name="CcmFifGetContactRoleDataCmd">
								<xsl:element name="command_id">get_contact_role</xsl:element>
								<xsl:element name="CcmFifGetContactRoleDataInCont">
									<xsl:element name="supported_object_id">
										<xsl:value-of select="request-param[@name='supportedObjectId']"/>
									</xsl:element>														
									<xsl:element name="supported_object_type_rd">
										<xsl:value-of select="request-param[@name='supportedObjectType']"/>						
									</xsl:element>
									<xsl:element name="contact_role_entity_id">
										<xsl:value-of select="request-param[@name='contactRoleEntityId']"/>
									</xsl:element>
								</xsl:element>
							</xsl:element>
							
                     <!-- terminate also contact_role referenced by contactRoleId -->
							<xsl:element name="CcmFifTerminateContactRoleCmd">
								<xsl:element name="command_id">term_contact_role</xsl:element>
								<xsl:element name="CcmFifTerminateContactRoleInCont">
									<xsl:element name="contact_role_id_ref">
										<xsl:element name="command_id">get_contact_role</xsl:element>
										<xsl:element name="field_name">contact_role_id</xsl:element>
									</xsl:element>														
								</xsl:element>
							</xsl:element>
						</xsl:when>

                  <!-- terminate contactRole and contactRoleEntity referenced by supportedObjectId and contactRoleEntityId -->
                  <!-- if last last active contactRole then terminate contactRoleEntity -->
						<xsl:when test="request-param[@name='contactRoleEntityId'] != '' and request-param[@name='supportedObjectId'] != ''">
                     <xsl:element name="CcmFifGetContactRoleDataCmd">
								<xsl:element name="command_id">get_contact_role</xsl:element>
								<xsl:element name="CcmFifGetContactRoleDataInCont">
									<xsl:element name="supported_object_id">
										<xsl:value-of select="request-param[@name='supportedObjectId']"/>
									</xsl:element>														
									<xsl:element name="supported_object_type_rd">
										<xsl:value-of select="request-param[@name='supportedObjectType']"/>						
									</xsl:element>
									<xsl:element name="contact_role_entity_id">
										<xsl:value-of select="request-param[@name='contactRoleEntityId']"/>
									</xsl:element>
								</xsl:element>
							</xsl:element>

                     <!-- terminate also contact_role referenced by contactRoleId and contact_role_entity_id -->
							<xsl:element name="CcmFifTerminateContactRoleCmd">
								<xsl:element name="command_id">term_contact_role_entity</xsl:element>
								<xsl:element name="CcmFifTerminateContactRoleInCont">
									<xsl:element name="contact_role_id_ref">
										<xsl:element name="command_id">get_contact_role</xsl:element>
										<xsl:element name="field_name">contact_role_id</xsl:element>
									</xsl:element>
									<xsl:element name="contact_role_entity_id">
										<xsl:value-of select="request-param[@name='contactRoleEntityId']"/>
									</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:when>

                  <!-- terminate contactRoleEntity with all references to contactRole, if any existing -->
						<xsl:when test="request-param[@name='contactRoleEntityId'] != ''">

                     <!-- this cmd terminated also contact_role referenced by contact_role_entity_id -->
							<xsl:element name="CcmFifTerminateContactRoleCmd">
								<xsl:element name="command_id">term_contact_role_entity</xsl:element>
								<xsl:element name="CcmFifTerminateContactRoleInCont">
									<xsl:element name="contact_role_entity_id">
										<xsl:value-of select="request-param[@name='contactRoleEntityId']"/>
									</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:when>

						<xsl:otherwise>
							<xsl:element name="CcmFifRaiseErrorCmd">
								<xsl:element name="command_id">removeForExistingCRE</xsl:element>
								<xsl:element name="CcmFifRaiseErrorInCont">
									<xsl:element name="error_text">Bitte contactRoleEntityId angeben, falls Referenzen entfernt werden sollen.</xsl:element>
								</xsl:element>                                      
				       		</xsl:element>        			
						</xsl:otherwise>
					</xsl:choose>
				
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="request-param-list[@name='contactRoleReferenceList']/request-param-list-item">
						<xsl:choose>
						
							<xsl:when test="request-param[@name='contactRoleReferenceAction'] = 'ADD'">
								<!-- Create Contact Role-->
								<xsl:element name="CcmFifCreateContactRoleCmd">
									<xsl:element name="command_id">create_contact_role_reference</xsl:element>
									<xsl:element name="CcmFifCreateContactRoleInCont">
										<xsl:element name="customer_number"/>
										<xsl:choose>
											<xsl:when test="../../request-param[@name='createContactRoleEntity'] = 'N'">
												<xsl:element name="contact_role_entity_id">
													<xsl:value-of select="../../request-param[@name='contactRoleEntityId']"/>
												</xsl:element>
											</xsl:when>
											<xsl:otherwise>							
												<xsl:element name="contact_role_entity_id_ref">
													<xsl:element name="command_id">create_contact_role_entity</xsl:element>
													<xsl:element name="field_name">contact_role_entity_id</xsl:element>
												</xsl:element>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:element name="supported_object_id">
											<xsl:value-of select="request-param[@name='supportedObjectId']"/>
										</xsl:element>							
										<xsl:element name="supported_object_type_rd">
											<xsl:value-of select="request-param[@name='supportedObjectType']"/>						
										</xsl:element>
										<xsl:element name="contact_role_type_rd">
<!-- 											<xsl:value-of select="request-param[@name='contactRoleType']"/>						 -->
										</xsl:element>
									</xsl:element>				
								</xsl:element>
							</xsl:when>
							<xsl:when test="request-param[@name='contactRoleReferenceAction'] = 'REMOVE'">
								<xsl:choose>
                           <!-- terminate contactRole referenced by supportedObjectId -->
                           <!--  only old type of contact role having contactRoleEntityId equal null -->
					            <xsl:when test="../../request-param[@name='contactRoleEntityId'] = 'OLD_CONTACT_ROLE'">
						            <xsl:element name="CcmFifGetContactRoleDataCmd">
							            <xsl:element name="command_id">get_contact_role</xsl:element>
							            <xsl:element name="CcmFifGetContactRoleDataInCont">
								            <xsl:element name="supported_object_id">
									            <xsl:value-of select="request-param[@name='supportedObjectId']"/>
								            </xsl:element>														
								            <xsl:element name="supported_object_type_rd">
									            <xsl:value-of select="request-param[@name='supportedObjectType']"/>						
								            </xsl:element>
								            <xsl:element name="contact_role_entity_id">
									            <xsl:value-of select="../../request-param[@name='contactRoleEntityId']"/>
								            </xsl:element>
							            </xsl:element>
						            </xsl:element>

                              <!-- terminate also contact_role referenced by contactRoleId -->
						            <xsl:element name="CcmFifTerminateContactRoleCmd">
							            <xsl:element name="command_id">term_contact_role</xsl:element>
							            <xsl:element name="CcmFifTerminateContactRoleInCont">
								            <xsl:element name="contact_role_id_ref">
									            <xsl:element name="command_id">get_contact_role</xsl:element>
									            <xsl:element name="field_name">contact_role_id</xsl:element>
								            </xsl:element>														
							            </xsl:element>
						            </xsl:element>
					            </xsl:when>

                           <!-- terminate contactRole and contactRoleEntity referenced by supportedObjectId and contactRoleEntityId -->
                           <!-- if last last active contactRole then terminate contactRoleEntity -->
					            <xsl:when test="../../request-param[@name='contactRoleEntityId'] != '' and request-param[@name='supportedObjectId'] != ''">
                              <xsl:element name="CcmFifGetContactRoleDataCmd">
							            <xsl:element name="command_id">get_contact_role</xsl:element>
							            <xsl:element name="CcmFifGetContactRoleDataInCont">
								            <xsl:element name="supported_object_id">
									            <xsl:value-of select="request-param[@name='supportedObjectId']"/>
								            </xsl:element>														
								            <xsl:element name="supported_object_type_rd">
									            <xsl:value-of select="request-param[@name='supportedObjectType']"/>						
								            </xsl:element>
								            <xsl:element name="contact_role_entity_id">
									            <xsl:value-of select="../../request-param[@name='contactRoleEntityId']"/>
								            </xsl:element>
							            </xsl:element>
						            </xsl:element>

                              <!-- terminate also contact_role referenced by contactRoleId and contact_role_entity_id -->
						            <xsl:element name="CcmFifTerminateContactRoleCmd">
							            <xsl:element name="command_id">term_contact_role_entity</xsl:element>
							            <xsl:element name="CcmFifTerminateContactRoleInCont">
								            <xsl:element name="contact_role_id_ref">
									            <xsl:element name="command_id">get_contact_role</xsl:element>
									            <xsl:element name="field_name">contact_role_id</xsl:element>
								            </xsl:element>
								            <xsl:element name="contact_role_entity_id">
									            <xsl:value-of select="../../request-param[@name='contactRoleEntityId']"/>
								            </xsl:element>
							            </xsl:element>
						            </xsl:element>
					            </xsl:when>

                           <!-- terminate contactRoleEntity with all references to contactRole, if any existing -->
					            <xsl:when test="../../request-param[@name='contactRoleEntityId'] != ''">

                              <!-- this cmd terminated also contact_role referenced by contact_role_entity_id -->
						            <xsl:element name="CcmFifTerminateContactRoleCmd">
							            <xsl:element name="command_id">term_contact_role_entity</xsl:element>
							            <xsl:element name="CcmFifTerminateContactRoleInCont">
								            <xsl:element name="contact_role_entity_id">
									            <xsl:value-of select="../../request-param[@name='contactRoleEntityId']"/>
								            </xsl:element>
							            </xsl:element>
						            </xsl:element>
					            </xsl:when>

									<xsl:otherwise>
										<xsl:element name="CcmFifRaiseErrorCmd">
											<xsl:element name="command_id">removeForExistingCRE</xsl:element>
											<xsl:element name="CcmFifRaiseErrorInCont">
												<xsl:element name="error_text">Bitte contactRoleEntityId angeben, falls Referenzen entfernt werden sollen.</xsl:element>
											</xsl:element>                                      
							       		</xsl:element>        			
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
				
				</xsl:otherwise>
			</xsl:choose>

			<!-- Create Contact -->
			<xsl:if test="request-param[@name='createContact'] != 'N'">
			    <xsl:element name="CcmFifCreateContactCmd">
					<xsl:element name="command_id">create_contact</xsl:element>
					<xsl:element name="CcmFifCreateContactInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="contact_type_rd">
							<xsl:choose>
								<xsl:when test="request-param[@name='contactTypeRd'] != ''">
									<xsl:value-of select="request-param[@name='contactTypeRd']"/>
								</xsl:when>
								<xsl:otherwise>CUSTOMER</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="short_description">
							<xsl:choose>
								<xsl:when test="request-param[@name='shortDescription'] != ''">
									<xsl:value-of select="request-param[@name='shortDescription']"/>
								</xsl:when>
								<xsl:otherwise>Ansprechpartner geändert</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						
						<xsl:element name="description_text_list">
							
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="contact_text">
									<xsl:if test="request-param[@name='longDescriptionText'] != ''">
						    			<xsl:value-of select="request-param[@name='longDescriptionText']"/>
										<xsl:text>&#xA;</xsl:text>
									</xsl:if>
									<xsl:text>Ansprechpartner </xsl:text>
								</xsl:element>
							</xsl:element>
								
							<xsl:choose>
								<xsl:when test="request-param[@name='createContactRoleEntity'] = 'Y'">
									<xsl:element name="CcmFifCommandRefCont">
										<xsl:element name="command_id">create_contact_role_entity</xsl:element>
										<xsl:element name="field_name">contact_role_entity_id</xsl:element>
									</xsl:element>
									<xsl:element name="CcmFifPassingValueCont">
										<xsl:element name="contact_text">
											<xsl:text> erstellt.</xsl:text>
										</xsl:element>
									</xsl:element>									
								</xsl:when>
								<xsl:otherwise>
									<xsl:element name="CcmFifPassingValueCont">
										<xsl:element name="contact_text">
											<xsl:value-of select="request-param[@name='contactRoleEntityId']"/>
											<xsl:text> geändert.</xsl:text>
										</xsl:element>
									</xsl:element>									
								</xsl:otherwise>
							</xsl:choose>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="contact_text">
									<xsl:if test="request-param[@name='contactRoleReferenceAction'] != ''">
										<xsl:text>&#xA;- Verknüpfung zu </xsl:text>
										<xsl:choose>
											<xsl:when test="request-param[@name='supportedObjectType'] = 'CUSTOMER'">Kunde </xsl:when>
											<xsl:when test="request-param[@name='supportedObjectType'] = 'ACCOUNT'">Rechnungskonto </xsl:when>
											<xsl:when test="request-param[@name='supportedObjectType'] = 'SERVDLVRY'">Dienstleistungsvertrag </xsl:when>
											<xsl:when test="request-param[@name='supportedObjectType'] = 'SKELCNTR'">Rahmenvertrag </xsl:when>
											<xsl:when test="request-param[@name='supportedObjectType'] = 'ONE_GROUP'">ONE-Group </xsl:when>
											<xsl:when test="request-param[@name='supportedObjectType'] = 'SERVICE_SUBSC'">Dienstenutzung </xsl:when>
										</xsl:choose>
										<xsl:value-of select="request-param[@name='supportedObjectId']"/>
										<xsl:choose>
											<xsl:when test="request-param[@name='contactRoleReferenceAction'] = 'ADD'"> hinzugefügt.</xsl:when>
											<xsl:when test="request-param[@name='contactRoleReferenceAction'] = 'REMOVE'"> entfernt.</xsl:when>
										</xsl:choose>
									</xsl:if>
									<xsl:for-each select="request-param-list[@name='contactRoleReferenceList']/request-param-list-item">
										<xsl:text>&#xA;- Verknüpfung zu </xsl:text>
										<xsl:choose>
											<xsl:when test="request-param[@name='supportedObjectType'] = 'CUSTOMER'">Kunde </xsl:when>
											<xsl:when test="request-param[@name='supportedObjectType'] = 'ACCOUNT'">Rechnungskonto </xsl:when>
											<xsl:when test="request-param[@name='supportedObjectType'] = 'SERVDLVRY'">Dienstleistungsvertrag </xsl:when>
											<xsl:when test="request-param[@name='supportedObjectType'] = 'SKELCNTR'">Rahmenvertrag </xsl:when>
											<xsl:when test="request-param[@name='supportedObjectType'] = 'ONE_GROUP'">ONE-Group </xsl:when>
											<xsl:when test="request-param[@name='supportedObjectType'] = 'SERVICE_SUBSC'">Dienstenutzung </xsl:when>
										</xsl:choose>
										<xsl:value-of select="request-param[@name='supportedObjectId']"/>
										<xsl:choose>
											<xsl:when test="request-param[@name='contactRoleReferenceAction'] = 'ADD'"> hinzugefügt.</xsl:when>
											<xsl:when test="request-param[@name='contactRoleReferenceAction'] = 'REMOVE'"> entfernt.</xsl:when>
										</xsl:choose>									
									</xsl:for-each>
								</xsl:element>
							</xsl:element>									
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="contact_text">
									<xsl:text>&#xA;TransactionID: </xsl:text>
									<xsl:value-of select="request-param[@name='transactionID']"/>
									<xsl:text> (</xsl:text>
									<xsl:value-of select="request-param[@name='clientName']"/>
									<xsl:text>)</xsl:text>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>

		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
			
