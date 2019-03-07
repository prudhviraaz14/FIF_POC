<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a BIT VOIP contract

  @author pranjali
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
		<!-- Calculate today and one day before the desired date -->
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
		<!-- Convert the desired date to OPM format -->
		<xsl:variable name="desiredDateOPM"
				select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
				
		<xsl:element name="Command_List">
 
			<xsl:variable name="maskingDigits">
				<xsl:choose>
					<xsl:when test="request-param[@name='cdrEgnFormat'] = 'NO_EGN'">0</xsl:when>
					<xsl:when test="request-param[@name='cdrEgnFormat'] = 'ABBREVIATED_EGN'">20</xsl:when>
					<xsl:when test="request-param[@name='cdrEgnFormat'] = 'FULL_EGN'">-1</xsl:when>
					<xsl:when test="request-param[@name='cdrEgnFormat'] = 'NORMAL_EGN'">-1</xsl:when>
					<xsl:otherwise>unknown</xsl:otherwise>
				</xsl:choose>
				
			</xsl:variable>
			
			<xsl:variable name="storageMaskingDigits">
				<xsl:choose>
					<xsl:when test="request-param[@name='cdrStorageFormat'] = 'IMMEDIATE_DELETION'">0</xsl:when>
					<xsl:when test="request-param[@name='cdrStorageFormat'] = 'ABBREVIATED_STORAGE'">20</xsl:when>
					<xsl:when test="request-param[@name='cdrStorageFormat'] = 'FULL_STORAGE'">-1</xsl:when>
					<xsl:when test="request-param[@name='cdrStorageFormat'] = 'NORMAL_STORAGE'">-1</xsl:when>
					<xsl:otherwise>unknown</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="retentionPeriod">				
				<xsl:choose>
					<xsl:when test="request-param[@name='cdrEgnFormat'] = 'NO_EGN'">80NODT</xsl:when>
					<xsl:when test="request-param[@name='cdrEgnFormat'] = 'ABBREVIATED_EGN'">80DETL</xsl:when>
					<xsl:when test="request-param[@name='cdrEgnFormat'] = 'FULL_EGN'">80DETL</xsl:when>
					<xsl:when test="request-param[@name='cdrEgnFormat'] = 'NORMAL_EGN'">80DETL</xsl:when>						
					<xsl:otherwise>unknown</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="VoIPServiceType" select="request-param[@name='VoIPServiceType']"/>

			<xsl:if test="$VoIPServiceType  != 'Premium'
				and $VoIPServiceType != 'Basis'">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">raise_error_unknown_value</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">Unbekannter Wert für VoIPServiceType gewaehlt.</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="$maskingDigits = 'unknown'
				or $storageMaskingDigits = 'unknown'
				or $retentionPeriod = 'unknown'">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">raise_error_unknown_value</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">Unbekannter Wert für EGN gewaehlt.</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!--Get Customer Number if not provided-->
			<xsl:if test="(request-param[@name='customerNumber'] = '')">
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_external_notification_1</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="parameter_name">CUSTOMER_NUMBER</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!--Get Account Number if not provided-->
			<xsl:if test="(request-param[@name='accountNumber'] = '')">
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_external_notification_2</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="parameter_name">ACCOUNT_NUMBER</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>

			<!-- Take value of serviceSubscriptionId of Bit Main service from ccm external notification  -->
			<xsl:if test="(request-param[@name='serviceSubscriptionId'] = '')">
				<!-- Get Service Subscription ID -->
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_external_notification_3</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="parameter_name">BitDSL_SERVICE_SUBSCRIPTION_ID</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Get Entity Information -->
			<xsl:element name="CcmFifGetEntityCmd">
				<xsl:element name="command_id">get_entity_1</xsl:element>
				<xsl:element name="CcmFifGetEntityInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:element>
			<!-- Create Address if not provided -->
			<xsl:if test="request-param[@name='addressId'] = ''">

				<xsl:element name="CcmFifCreateAddressCmd">
					<xsl:element name="command_id">create_address</xsl:element>
					<xsl:element name="CcmFifCreateAddressInCont">
						<xsl:element name="entity_ref">
							<xsl:element name="command_id">get_entity_1</xsl:element>
							<xsl:element name="field_name">entity_id</xsl:element>
						</xsl:element>
						<xsl:element name="address_type">STD</xsl:element>
						<xsl:element name="street_name">
							<xsl:value-of select="request-param[@name='streetName']"/>
						</xsl:element>
						<xsl:element name="street_number">
							<xsl:value-of select="request-param[@name='streetNumber']"/>
						</xsl:element>
						<xsl:element name="street_number_suffix">
							<xsl:value-of select="request-param[@name='numberSuffix']"/>
						</xsl:element>
						<xsl:element name="postal_code">
							<xsl:value-of select="request-param[@name='postalCode']"/>
						</xsl:element>
						<xsl:element name="city_name">
							<xsl:value-of select="request-param[@name='city']"/>
						</xsl:element>
						<xsl:element name="city_suffix_name">
							<xsl:value-of select="request-param[@name='citySuffix']"/>
						</xsl:element>
						<xsl:if test="request-param[@name='country']!=''">
							<xsl:element name="country_code">
								<xsl:value-of select="request-param[@name='country']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='country']=''">
							<xsl:element name="country_code">DE</xsl:element>
						</xsl:if>
						<xsl:element name="address_additional_text">
							<xsl:value-of select="request-param[@name='additionalText']"/>
						</xsl:element>
						<xsl:element name="set_primary_address">N</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>

      		<!-- Normalize Address  if the address id is provided. -->
      		<xsl:if test="request-param[@name='addressId'] != ''">
				<xsl:element name="CcmFifNormalizeAddressCmd">
					<xsl:element name="command_id">normalize_address_1</xsl:element>
					<xsl:element name="CcmFifNormalizeAddressInCont">
						<xsl:if test="request-param[@name='customerNumber']=''">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">read_external_notification_1</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='customerNumber']!=''">
							<xsl:element name="customer_number">
								<xsl:value-of select="request-param[@name='customerNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="address_id">
							<xsl:value-of select="request-param[@name='addressId']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
      		</xsl:if>

			<!-- Create Line Owner Address  -->
			<xsl:element name="CcmFifCreateAddressCmd">
				<xsl:element name="command_id">create_line_owner_address</xsl:element>
				<xsl:element name="CcmFifCreateAddressInCont">
					<xsl:element name="entity_ref">
						<xsl:element name="command_id">get_entity_1</xsl:element>
						<xsl:element name="field_name">entity_id</xsl:element>
					</xsl:element>
					<xsl:element name="address_type">STD</xsl:element>
					<xsl:element name="street_name">
						<xsl:value-of select="request-param[@name='lineOwnerAddressStreetName']"/>
					</xsl:element>
					<xsl:element name="street_number">
						<xsl:value-of select="request-param[@name='lineOwnerAddressNumber']"/>
					</xsl:element>
					<xsl:element name="street_number_suffix">
						<xsl:value-of select="request-param[@name='lineOwnerAddressNumberSuffix']"/>
					</xsl:element>
					<xsl:element name="postal_code">
						<xsl:value-of select="request-param[@name='lineOwnerAddressPostalCode']"/>
					</xsl:element>
					<xsl:element name="city_name">
						<xsl:value-of select="request-param[@name='lineOwnerAddressCity']"/>
					</xsl:element>
					<xsl:element name="city_suffix_name">
						<xsl:value-of select="request-param[@name='lineOwnerAddressCitySuffix']"/>
					</xsl:element>
					<xsl:if test="request-param[@name='country']!=''">
						<xsl:element name="country_code">
							<xsl:value-of select="request-param[@name='country']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='country']=''">
						<xsl:element name="country_code">DE</xsl:element>
					</xsl:if>
					<xsl:element name="address_additional_text">
						<xsl:value-of select="request-param[@name='additionalText']"/>
					</xsl:element>
					<xsl:element name="set_primary_address">N</xsl:element>
				</xsl:element>
			</xsl:element>
			
            <!-- Get sales oranisation numbers from previous contract-->	
	    	<xsl:if test="request-param[@name='salesRepresentativeDept'] != ''   and
		                   ( request-param[@name='reasonRd'] = 'MIG_PRE_BIT'  or request-param[@name='reasonRd'] = 'MIG_VOIP_BIT' )"> 
                <!-- Get PC data to retrievecontract number-->
                <xsl:element name="CcmFifGetProductCommitmentDataCmd">
                    <xsl:element name="command_id">get_old_contr_num</xsl:element>
                    <xsl:element name="CcmFifGetProductCommitmentDataInCont">
                            <xsl:element name="product_commitment_number">
                                <xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
                            </xsl:element>                       
                       <xsl:element name="retrieve_signed_version">Y</xsl:element>
                    </xsl:element>
                </xsl:element>			
                <!-- Get the sales org number  -->
                <xsl:element name="CcmFifGetCommissioningInformationDataCmd">
                    <xsl:element name="command_id">get_sales_org_number</xsl:element>
                    <xsl:element name="CcmFifGetCommissioningInformationDataInCont">
                       <xsl:element name="supported_object_id_ref">
                           <xsl:element name="command_id">get_old_contr_num</xsl:element>
                           <xsl:element name="field_name">contract_number</xsl:element>
                       </xsl:element>
                       <xsl:element name="supported_object_type_rd">O</xsl:element>
                       <xsl:element name="no_sales_org_number_error">Y</xsl:element>
                       <xsl:element name="cio_type_rd">Initial CIO</xsl:element>
                    </xsl:element>
                </xsl:element>
                   <!-- Get the sales org number VF  -->
                <xsl:element name="CcmFifGetCommissioningInformationDataCmd">
                    <xsl:element name="command_id">get_sales_org_number_vf</xsl:element>
                    <xsl:element name="CcmFifGetCommissioningInformationDataInCont">
                       <xsl:element name="supported_object_id_ref">
                           <xsl:element name="command_id">get_old_contr_num</xsl:element>
                           <xsl:element name="field_name">contract_number</xsl:element>
                       </xsl:element>
                       <xsl:element name="supported_object_type_rd">O</xsl:element>
                         <xsl:element name="no_sales_org_number_error">N</xsl:element>
                       <xsl:element name="cio_type_rd">VODAFONE</xsl:element>
                    </xsl:element>
                </xsl:element>
		    </xsl:if>			

		    <xsl:if test="request-param[@name='productCommitmentNumber']= ''">
		        <!-- Create Order Form-->
				<xsl:element name="CcmFifCreateOrderFormCmd">
					<xsl:element name="command_id">create_order_form_1</xsl:element>
					<xsl:element name="CcmFifCreateOrderFormInCont">
						<xsl:if test="request-param[@name='customerNumber']=''">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">read_external_notification_1</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='customerNumber']!=''">
							<xsl:element name="customer_number">
								<xsl:value-of select="request-param[@name='customerNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="min_per_dur_value">
							<xsl:value-of select="request-param[@name='minPeriodDurationValue']"/>
						</xsl:element>
						<xsl:element name="min_per_dur_unit">
							<xsl:value-of select="request-param[@name='minPeriodDurationUnit']"/>
						</xsl:element>
						  <xsl:choose>
					        <xsl:when test="request-param[@name='salesRepresentativeDept'] != ''   and
			                                ( request-param[@name='reasonRd'] = 'MIG_PRE_BIT'  or request-param[@name='reasonRd'] = 'MIG_VOIP_BIT' )"> 
					              <xsl:element name="sales_org_num_value_ref">
                                    <xsl:element name="command_id">get_sales_org_number</xsl:element>
                                    <xsl:element name="field_name">sales_org_number</xsl:element>
                                </xsl:element>
                                <xsl:element name="sales_org_num_value_vf_ref">
                                    <xsl:element name="command_id">get_sales_org_number_vf</xsl:element>
                                    <xsl:element name="field_name">sales_org_number</xsl:element>
                                </xsl:element>
					        </xsl:when>  										       
					        <xsl:otherwise>
					             <xsl:element name="sales_org_num_value">
						   	         <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
						        </xsl:element>												
						        <xsl:element name="sales_org_num_value_vf">
							        <xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
						        </xsl:element>
					        </xsl:otherwise>					        
				        </xsl:choose>																						
						<xsl:element name="doc_template_name">Vertrag</xsl:element>
						<xsl:if test="request-param[@name='assocSkeletonContNum']!=''">
							<xsl:element name="assoc_skeleton_cont_num">
								<xsl:value-of select="request-param[@name='assocSkeletonContNum']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="auto_extent_period_value">
							<xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>
						</xsl:element>                         
						<xsl:element name="auto_extent_period_unit">
							<xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>
						</xsl:element>                         
						<xsl:element name="auto_extension_ind">
							<xsl:value-of select="request-param[@name='autoExtensionInd']"/>
						</xsl:element>
					   <xsl:element name="name">Bitstrom-Voice Vertrag</xsl:element>
					</xsl:element>
				</xsl:element>
		        
			<!-- Add Order Form Product Commitment -->
				<xsl:element name="CcmFifAddProductCommitCmd">
					<xsl:element name="command_id">add_product_commitment_1</xsl:element>
					<xsl:element name="CcmFifAddProductCommitInCont">
						<xsl:if test="request-param[@name='customerNumber']=''">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">read_external_notification_1</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='customerNumber']!=''">
							<xsl:element name="customer_number">
								<xsl:value-of select="request-param[@name='customerNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="contract_number_ref">
							<xsl:element name="command_id">create_order_form_1</xsl:element>
							<xsl:element name="field_name">contract_number</xsl:element>
						</xsl:element>
						<xsl:element name="product_code">VI203</xsl:element>
						<xsl:element name="pricing_structure_code">
							<xsl:value-of select="request-param[@name='tariff']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			
			<!-- Sign Order Form -->
				<xsl:element name="CcmFifSignOrderFormCmd">
					<xsl:element name="command_id">sign_of_1</xsl:element>
					<xsl:element name="CcmFifSignOrderFormInCont">
						<xsl:element name="contract_number_ref">
							<xsl:element name="command_id">create_order_form_1</xsl:element>
							<xsl:element name="field_name">contract_number</xsl:element>
						</xsl:element>
						<xsl:element name="board_sign_name">ARCOR</xsl:element>
						<xsl:element name="primary_cust_sign_name">ARC</xsl:element>
						<xsl:element name="primary_cust_sign_date">
							<xsl:if test="request-param[@name='primaryCustSignDate'] != ''">
								<xsl:value-of select="request-param[@name='primaryCustSignDate']"/>
							</xsl:if>
							<xsl:if test="request-param[@name='primaryCustSignDate'] = ''">
								<xsl:value-of select="$today"/>
							</xsl:if>

						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
		    
			<!-- Add Product Subscription -->
			<xsl:element name="CcmFifAddProductSubsCmd">
				<xsl:element name="command_id">add_product_subscription_1</xsl:element>
				<xsl:element name="CcmFifAddProductSubsInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='productCommitmentNumber']!=''">
						<xsl:element name="product_commitment_number">
							<xsl:value-of select="request-param[@name='productCommitmentNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='productCommitmentNumber']=''">
						<xsl:element name="product_commitment_number_ref">
							<xsl:element name="command_id">add_product_commitment_1</xsl:element>
							<xsl:element name="field_name">product_commitment_number</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:element name="vis_tracking_position">
						<xsl:value-of select="request-param[@name='VISTrackingPosition']"/>
					</xsl:element>					
				</xsl:element>
			</xsl:element>
			<!-- Add Main Service  VI006(Premium) -->
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_1</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:if test="$VoIPServiceType = 'Basis'">VI009</xsl:if>
							<xsl:if test="$VoIPServiceType = 'Premium'">VI006</xsl:if>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
							<!-- Standort  Addresse -->
							<xsl:if test="request-param[@name='addressId']=''">
							<xsl:element name="CcmFifAddressCharacteristicCont">
								<xsl:element name="service_char_code">V0014</xsl:element>
								<xsl:element name="data_type">ADDRESS</xsl:element>
								<xsl:element name="address_ref">
									<xsl:element name="command_id">create_address</xsl:element>
									<xsl:element name="field_name">address_id</xsl:element>
								</xsl:element>
							</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='addressId']!=''">
								<xsl:element name="CcmFifAddressCharacteristicCont">
									<xsl:element name="service_char_code">V0014</xsl:element>
									<xsl:element name="data_type">ADDRESS</xsl:element>
									<xsl:element name="address_id">
										<xsl:value-of select="request-param[@name='addressId']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Aktivierungsdatum -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0909</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="$desiredDateOPM"/>
								</xsl:element>
							</xsl:element>
							<!-- Bearbeitungsart -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0971</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">TAL</xsl:element>
							</xsl:element>
							<!-- Bemerkung -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0008</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='remarks']"/>
								</xsl:element>
							</xsl:element>
							<!-- Mailbox Aliasname -->
							<xsl:element name="CcmFifAccessNumberCont">
								<xsl:element name="service_char_code">VI051</xsl:element>
                                <xsl:element name="data_type">USER_ACCOUNT_NUM</xsl:element>
								<xsl:element name="network_account">
									<xsl:value-of select="request-param[@name='mailboxAliasName']"/>
								</xsl:element>
							</xsl:element>
							<!-- Old VNB -->
							<xsl:if test="request-param[@name='oldTNB'] != ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0062</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='oldTNB']"/>
									</xsl:element>
								</xsl:element>
								<!--  Old TNB -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0060</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='oldTNB']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!--  New TNB -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0061</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">ARCOR</xsl:element>
							</xsl:element>
							<!-- Neuer VNB -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0063</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">ARCOR</xsl:element>
							</xsl:element>
							<!-- Type of Activation-->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0133</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='typeOfNewActivation']"/>
								</xsl:element>
							</xsl:element>

							<!-- Kondition/Rabatt -->
							<xsl:if test="request-param[@name='rabatt']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0097</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='rabatt']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!--  Kondition/RabattID -->
							<xsl:if test="request-param[@name='rabattIndicator']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0162</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='rabattIndicator']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!--  Sales Segment -->
							<xsl:if test="request-param[@name='salesSegment']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0105</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='salesSegment']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!--  Project Order Indicator-->
							<xsl:if test="request-param[@name='projectOrderIndicator']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0104</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='projectOrderIndicator']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Customer call back number-->
							<xsl:if test="request-param[@name='customerCallBackNumber']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0125</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='customerCallBackNumber']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Line Owner Address -->
							<xsl:element name="CcmFifAddressCharacteristicCont">
								<xsl:element name="service_char_code">V0126</xsl:element>
								<xsl:element name="data_type">ADDRESS</xsl:element>
								<xsl:element name="address_ref">
									<xsl:element name="command_id">create_line_owner_address</xsl:element>
									<xsl:element name="field_name">address_id</xsl:element>
								</xsl:element>
							</xsl:element>

							<!--  Line Owner Last Name -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0127</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='lineOwnerLastName']"
									/>
								</xsl:element>
							</xsl:element>

							<!--  Line owner first name -->
							<xsl:if test="request-param[@name='lineOwnerFirstName']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0128</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='lineOwnerFirstName']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!--  Second line owner last name -->
							<xsl:if test="request-param[@name='secondLineOwnerLastName']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0129</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='secondLineOwnerLastName']"
										/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!--  Second line owner first name -->
							<xsl:if test="request-param[@name='secondLineOwnerFirstName']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0130</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='secondLineOwnerFirstName']"
										/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!--  DTAG Free text -->
							<xsl:if test="request-param[@name='DTAGFreetext']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0141</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='DTAGFreetext']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!--  Number of New Access Number -->
							<xsl:if test="$VoIPServiceType != 'Basis'">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0936</xsl:element>
								<xsl:element name="data_type">INTEGER</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of
										select="request-param[@name='numberOfNewAccessNumber']"/>
								</xsl:element>
							</xsl:element>
							</xsl:if>
							<!--  Automatic Mailing ID -->
						
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0131</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='automaticMailingIndicator']"
										/>
									</xsl:element>
								</xsl:element>
							
							<!-- Order Variant -->
							<xsl:if test="request-param[@name='orderVariant']!=''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0810</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of select="request-param[@name='orderVariant']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
											
						
							
							<!-- Owner Access Number 1-->
							<xsl:if test="request-param[@name='ownerAccessNumber1']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0976</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='ownerAccessNumber1']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>

							<!--  Rufnummer -->							
							<xsl:element name="CcmFifAccessNumberCont">
								<xsl:element name="service_char_code">V0001</xsl:element>
								<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
								<xsl:element name="masking_digits_rd">
									<xsl:value-of select="$maskingDigits"/>
								</xsl:element>
								<xsl:element name="retention_period_rd">
									<xsl:value-of select="$retentionPeriod"/>
								</xsl:element>
								<xsl:element name="storage_masking_digits_rd">
									<xsl:value-of select="$storageMaskingDigits"/>
								</xsl:element>
								<xsl:element name="country_code">
									<xsl:value-of select="substring-before(request-param[@name='accessNumber1'], ';')"/>
								</xsl:element>
								<xsl:element name="city_code">
									<xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber1'],';'), ';')"/>
								</xsl:element>
								<xsl:element name="local_number">
									<xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber1'],';'), ';')"/>
								</xsl:element>
							</xsl:element>
							<xsl:if test="$VoIPServiceType != 'Basis'">
								<!--  Additional Access Number 2 -->
								<xsl:if test="request-param[@name='accessNumber2'] != ''">
									<xsl:element name="CcmFifAccessNumberCont">
										<xsl:element name="service_char_code">V0070</xsl:element>
										<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
										<xsl:element name="masking_digits_rd">
											<xsl:value-of select="$maskingDigits"/>
										</xsl:element>
										<xsl:element name="retention_period_rd">
											<xsl:value-of select="$retentionPeriod"/>
										</xsl:element>
										<xsl:element name="storage_masking_digits_rd">
											<xsl:value-of select="$storageMaskingDigits"/>
										</xsl:element>
										<xsl:element name="country_code">
											<xsl:value-of select="substring-before(request-param[@name='accessNumber2'], ';')"/>
										</xsl:element>
										<xsl:element name="city_code">
											<xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber2'],';'), ';')"/>
										</xsl:element>
										<xsl:element name="local_number">
											<xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber2'],';'), ';')"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Additional Access Number 3 -->
								<xsl:if test="request-param[@name='accessNumber3'] != ''">
									<xsl:element name="CcmFifAccessNumberCont">
										<xsl:element name="service_char_code">V0071</xsl:element>
										<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
										<xsl:element name="masking_digits_rd">
											<xsl:value-of select="$maskingDigits"/>
										</xsl:element>
										<xsl:element name="retention_period_rd">
											<xsl:value-of select="$retentionPeriod"/>
										</xsl:element>
										<xsl:element name="storage_masking_digits_rd">
											<xsl:value-of select="$storageMaskingDigits"/>
										</xsl:element>
										<xsl:element name="country_code">
											<xsl:value-of select="substring-before(request-param[@name='accessNumber3'], ';')"/>
										</xsl:element>
										<xsl:element name="city_code">
											<xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber3'],';'), ';')"/>
										</xsl:element>
										<xsl:element name="local_number">
											<xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber3'],';'), ';')"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Additional Access Number 4 -->
								<xsl:if test="request-param[@name='accessNumber4'] != ''">
									<xsl:element name="CcmFifAccessNumberCont">
										<xsl:element name="service_char_code">V0072</xsl:element>
										<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
										<xsl:element name="masking_digits_rd">
											<xsl:value-of select="$maskingDigits"/>
										</xsl:element>
										<xsl:element name="retention_period_rd">
											<xsl:value-of select="$retentionPeriod"/>
										</xsl:element>
										<xsl:element name="storage_masking_digits_rd">
											<xsl:value-of select="$storageMaskingDigits"/>
										</xsl:element>
										<xsl:element name="country_code">
											<xsl:value-of select="substring-before(request-param[@name='accessNumber4'], ';')"/>
										</xsl:element>
										<xsl:element name="city_code">
											<xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber4'],';'), ';')"/>
										</xsl:element>
										<xsl:element name="local_number">
											<xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber4'],';'), ';')"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Additional Access Number 5 -->
								<xsl:if test="request-param[@name='accessNumber5'] != ''">
									<xsl:element name="CcmFifAccessNumberCont">
										<xsl:element name="service_char_code">V0073</xsl:element>
										<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
										<xsl:element name="masking_digits_rd">
											<xsl:value-of select="$maskingDigits"/>
										</xsl:element>
										<xsl:element name="retention_period_rd">
											<xsl:value-of select="$retentionPeriod"/>
										</xsl:element>
										<xsl:element name="storage_masking_digits_rd">
											<xsl:value-of select="$storageMaskingDigits"/>
										</xsl:element>
										<xsl:element name="country_code">
											<xsl:value-of select="substring-before(request-param[@name='accessNumber5'], ';')"/>
										</xsl:element>
										<xsl:element name="city_code">
											<xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber5'],';'), ';')"/>
										</xsl:element>
										<xsl:element name="local_number">
											<xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber5'],';'), ';')"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Additional Access Number 6 -->
								<xsl:if test="request-param[@name='accessNumber6'] != ''">
									<xsl:element name="CcmFifAccessNumberCont">
										<xsl:element name="service_char_code">V0074</xsl:element>
										<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
										<xsl:element name="masking_digits_rd">
											<xsl:value-of select="$maskingDigits"/>
										</xsl:element>
										<xsl:element name="retention_period_rd">
											<xsl:value-of select="$retentionPeriod"/>
										</xsl:element>
										<xsl:element name="storage_masking_digits_rd">
											<xsl:value-of select="$storageMaskingDigits"/>
										</xsl:element>
										<xsl:element name="country_code">
											<xsl:value-of select="substring-before(request-param[@name='accessNumber6'], ';')"/>
										</xsl:element>
										<xsl:element name="city_code">
											<xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber6'],';'), ';')"/>
										</xsl:element>
										<xsl:element name="local_number">
											<xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber6'],';'), ';')"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Additional Access Number 7 -->
								<xsl:if test="request-param[@name='accessNumber7'] != ''">
									<xsl:element name="CcmFifAccessNumberCont">
										<xsl:element name="service_char_code">V0075</xsl:element>
										<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
										<xsl:element name="masking_digits_rd">
											<xsl:value-of select="$maskingDigits"/>
										</xsl:element>
										<xsl:element name="retention_period_rd">
											<xsl:value-of select="$retentionPeriod"/>
										</xsl:element>
										<xsl:element name="storage_masking_digits_rd">
											<xsl:value-of select="$storageMaskingDigits"/>
										</xsl:element>
										<xsl:element name="country_code">
											<xsl:value-of select="substring-before(request-param[@name='accessNumber7'], ';')"/>
										</xsl:element>
										<xsl:element name="city_code">
											<xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber7'],';'), ';')"/>
										</xsl:element>
										<xsl:element name="local_number">
											<xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber7'],';'), ';')"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Additional Access Number 8 -->
								<xsl:if test="request-param[@name='accessNumber8'] != ''">
									<xsl:element name="CcmFifAccessNumberCont">
										<xsl:element name="service_char_code">V0076</xsl:element>
										<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
										<xsl:element name="masking_digits_rd">
											<xsl:value-of select="$maskingDigits"/>
										</xsl:element>
										<xsl:element name="retention_period_rd">
											<xsl:value-of select="$retentionPeriod"/>
										</xsl:element>
										<xsl:element name="storage_masking_digits_rd">
											<xsl:value-of select="$storageMaskingDigits"/>
										</xsl:element>
										<xsl:element name="country_code">
											<xsl:value-of select="substring-before(request-param[@name='accessNumber8'], ';')"/>
										</xsl:element>
										<xsl:element name="city_code">
											<xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber8'],';'), ';')"/>
										</xsl:element>
										<xsl:element name="local_number">
											<xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber8'],';'), ';')"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Additional Access Number 9 -->
								<xsl:if test="request-param[@name='accessNumber9'] != ''">
									<xsl:element name="CcmFifAccessNumberCont">
										<xsl:element name="service_char_code">V0077</xsl:element>
										<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
										<xsl:element name="masking_digits_rd">
											<xsl:value-of select="$maskingDigits"/>
										</xsl:element>
										<xsl:element name="retention_period_rd">
											<xsl:value-of select="$retentionPeriod"/>
										</xsl:element>
										<xsl:element name="storage_masking_digits_rd">
											<xsl:value-of select="$storageMaskingDigits"/>
										</xsl:element>
										<xsl:element name="country_code">
											<xsl:value-of select="substring-before(request-param[@name='accessNumber9'], ';')"/>
										</xsl:element>
										<xsl:element name="city_code">
											<xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber9'],';'), ';')"/>
										</xsl:element>
										<xsl:element name="local_number">
											<xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber9'],';'), ';')"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Additional Access Number 10 -->
								<xsl:if test="request-param[@name='accessNumber10'] != ''">
									<xsl:element name="CcmFifAccessNumberCont">
										<xsl:element name="service_char_code">V0078</xsl:element>
										<xsl:element name="data_type">MAIN_ACCESS_NUM</xsl:element>
										<xsl:element name="masking_digits_rd">
											<xsl:value-of select="$maskingDigits"/>
										</xsl:element>
										<xsl:element name="retention_period_rd">
											<xsl:value-of select="$retentionPeriod"/>
										</xsl:element>
										<xsl:element name="storage_masking_digits_rd">
											<xsl:value-of select="$storageMaskingDigits"/>
										</xsl:element>
										<xsl:element name="country_code">
											<xsl:value-of select="substring-before(request-param[@name='accessNumber10'], ';')"/>
										</xsl:element>
										<xsl:element name="city_code">
											<xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumber10'],';'), ';')"/>
										</xsl:element>
										<xsl:element name="local_number">
											<xsl:value-of select="substring-after(substring-after(request-param[@name='accessNumber10'],';'), ';')"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
							</xsl:if>
							<!--  Porting Access Number 1 -->
							<xsl:if test="request-param[@name='portingAccessNumber1']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0165</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='portingAccessNumber1']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>							
							<xsl:if test="$VoIPServiceType != 'Basis'">
								<!--  Porting Access Number2 -->
								<xsl:if test="request-param[@name='portingAccessNumber2']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0166</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='portingAccessNumber2']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Porting Access Number 3 -->
								<xsl:if test="request-param[@name='portingAccessNumber3']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0167</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='portingAccessNumber3']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Porting Access Number 4 -->
								<xsl:if test="request-param[@name='portingAccessNumber4']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0168</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='portingAccessNumber4']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Porting Access Number 5 -->
								<xsl:if test="request-param[@name='portingAccessNumber5']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0169</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='portingAccessNumber5']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Porting Access Number 6 -->
								<xsl:if test="request-param[@name='portingAccessNumber6']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0170</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='portingAccessNumber6']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Porting Access Number 7 -->
								<xsl:if test="request-param[@name='portingAccessNumber7']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0171</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='portingAccessNumber7']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Porting Access Number 8 -->
								<xsl:if test="request-param[@name='portingAccessNumber8']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0172</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='portingAccessNumber8']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Porting Access Number 9 -->
								<xsl:if test="request-param[@name='portingAccessNumber9']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0173</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='portingAccessNumber9']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Porting Access Number 10 -->
								<xsl:if test="request-param[@name='portingAccessNumber10']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0174</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='portingAccessNumber10']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
							</xsl:if>
							<xsl:if test="$VoIPServiceType != 'Basis'">
								<!--  Owner Access Number 2-->
								<xsl:if test="request-param[@name='ownerAccessNumber2']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0977</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='ownerAccessNumber2']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Owner Access Number 3-->
								<xsl:if test="request-param[@name='ownerAccessNumber3']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0978</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='ownerAccessNumber3']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Owner Access Number 4-->
								<xsl:if test="request-param[@name='ownerAccessNumber4']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0979</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='ownerAccessNumber4']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Owner Access Number 5-->
								<xsl:if test="request-param[@name='ownerAccessNumber5']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0980</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='ownerAccessNumber5']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Owner Access Number 6-->
								<xsl:if test="request-param[@name='ownerAccessNumber6']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0981</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='ownerAccessNumber6']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Owner Access Number 7-->
								<xsl:if test="request-param[@name='ownerAccessNumber7']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0982</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='ownerAccessNumber7']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Owner Access Number 8-->
								<xsl:if test="request-param[@name='ownerAccessNumber8']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0983</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='ownerAccessNumber8']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Owner Access Number 9-->
								<xsl:if test="request-param[@name='ownerAccessNumber9']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0984</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='ownerAccessNumber9']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<!--  Owner Access Number 10-->
								<xsl:if test="request-param[@name='ownerAccessNumber10']!= ''">
									<xsl:element name="CcmFifConfiguredValueCont">
										<xsl:element name="service_char_code">V0985</xsl:element>
										<xsl:element name="data_type">STRING</xsl:element>
										<xsl:element name="configured_value">
											<xsl:value-of
												select="request-param[@name='ownerAccessNumber10']"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
							</xsl:if>
							
						
							<!-- V0152 -->
						<xsl:if test="request-param[@name='technicalServiceId']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">V0152</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='technicalServiceId']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>
							<!-- Z0100 -->
						<xsl:if test="request-param[@name='networkElementId']!= ''">
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">Z0100</xsl:element>
									<xsl:element name="data_type">STRING</xsl:element>
									<xsl:element name="configured_value">
										<xsl:value-of
											select="request-param[@name='networkElementId']"/>
									</xsl:element>
								</xsl:element>
							</xsl:if>	
                    	<!-- ONKZ -->
						<xsl:if test="request-param[@name='ONKZ']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0124</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='ONKZ']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>

                        <!-- ASB -->
						<xsl:if test="request-param[@name='ASB']!= ''">
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V0934</xsl:element>
								<xsl:element name="data_type">INTEGER</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='ASB']"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>	
						<!-- Restliche DTAG-Rufnummern kundigen -->
						<xsl:if test="request-param[@name='terminateRemainingDTAGNumbers']!= ''">
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0215</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='terminateRemainingDTAGNumbers']"/>
							</xsl:element>
						</xsl:element>
					</xsl:if>	
						</xsl:element>
					</xsl:element>
				</xsl:element>

			<!-- Add Feature  Service V0017 Monthly Charge  -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_2</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0017</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:if test="request-param[@name='reasonRd'] != ''">
						<xsl:element name="reason_rd">
							<xsl:value-of select="request-param[@name='reasonRd']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='reasonRd'] = ''">
						<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='accountNumber']=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='accountNumber']!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="request-param[@name='accountNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">
					
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Add Feature  Service VI219 Einrichtungspreis if installationCharge  is set -->

			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_4</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">VI219</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:if test="request-param[@name='reasonRd'] != ''">
						<xsl:element name="reason_rd">
							<xsl:value-of select="request-param[@name='reasonRd']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='reasonRd'] = ''">
						<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='accountNumber']=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='accountNumber']!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="request-param[@name='accountNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list">
				
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Add Feature  Service V0099 Bonus My Company  if bonusMyCompany is set -->
			<xsl:if test="request-param[@name='bonusMyCompany'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_5</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0099</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<!-- Bemerkung -->
						<xsl:element name="service_characteristic_list">
						
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Add Feature  Service for Service Level  -->
			<xsl:if test="request-param[@name='serviceLevel'] != ''">
				<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_6</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">
						<xsl:if test="request-param[@name='serviceLevel'] = 'classic'">
							<xsl:text>S0106</xsl:text>
						</xsl:if>
						<xsl:if test="request-param[@name='serviceLevel'] = 'classicPlus'">
							<xsl:text>S0144</xsl:text>
						</xsl:if>
					    <xsl:if test="request-param[@name='serviceLevel'] = 'premium'">
					        <xsl:text>V0459</xsl:text>
					    </xsl:if>
					    <xsl:if test="request-param[@name='serviceLevel'] = 'comfort'">
					        <xsl:text>V0461</xsl:text>
					    </xsl:if>
					</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="desired_schedule_type">ASAP</xsl:element>
					<xsl:if test="request-param[@name='reasonRd'] != ''">
						<xsl:element name="reason_rd">
							<xsl:value-of select="request-param[@name='reasonRd']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='reasonRd'] = ''">
						<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='accountNumber']=''">
						<xsl:element name="account_number_ref">
							<xsl:element name="command_id">read_external_notification_2</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='accountNumber']!=''">
						<xsl:element name="account_number">
							<xsl:value-of select="request-param[@name='accountNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="service_characteristic_list"/>
				</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Add Feature  Service V0025 Block International   if blockInternational  is set -->
			<xsl:if test="request-param[@name='blockInternational'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_7</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0025</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
					
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Add Feature  Service V0026 Block Outside EU if blockOutsideEU  is set -->
			<xsl:if test="request-param[@name='blockOutsideEu'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_8</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0026</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<!-- Bemerkung -->
						<xsl:element name="service_characteristic_list">
					
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Add Feature  Service V0027 Block 0190/0900 if  block0190/0900  is set -->
			<xsl:if test="request-param[@name='block0190/0900'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_9</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0027</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
						
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Add Feature  Service V0254 Sperre 0137   if block0137calls  is set -->
			<xsl:if test="request-param[@name='block0137Calls'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_13</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0254</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
						
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 
			<!-- Add Feature  Service V0255 Sperre 01805 Calls   if block01805calls  is set -->
			<xsl:if test="request-param[@name='block01805Calls'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_14</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0255</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
					
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 
			<!-- Add Feature  Service V0256 Sperre  Premium  if blockPremium  is set -->
			<xsl:if test="request-param[@name='blockPremiumCalls'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_15</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0256</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>

						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
					
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 
			<!-- Add Feature  Service V0257 Sperre abgehender Verkehr  if blockOutgoingTraffic  is set -->
			<xsl:if test="request-param[@name='blockOutgoingTraffic'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_16</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0257</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
				
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 
			<!-- Add Feature  Service V0258 Sperre abgehender Verkehr(Ausname Ortsgesprache,0800,011xy)  if blockOutgoingTrafficExceptLocal  is set -->
			<xsl:if test="request-param[@name='blockOutgoingTrafficExceptLocal'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_17</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0258</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
					
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 
			<!-- Add Feature  Service V0259 Sperre MobilFunk  if blockMobileNumbers  is set -->
			<xsl:if test="request-param[@name='blockMobileNumbers'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_18</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0259</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
						
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 
			<!-- Add Feature  Service V0260 Sperre 0900  if block0900  is set -->
			<xsl:if test="request-param[@name='block0900'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_19</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0260</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
							
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 
			<!-- Add Feature  Service V0261 Sperre 118xy  if block118xy  is set -->
			<xsl:if test="request-param[@name='block118xy'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_20</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0261</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 

 	         <!-- Add Feature  Service V0281 Sperre Servicerufnummer (0180 1 bis 0180-5)  is set -->
			<xsl:if test="request-param[@name='block0180x'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_21</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0281</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 
			
            <!-- Add Feature  Service V0282 Sperre Persönliche Rufnummer (0700)  is set -->
			<xsl:if test="request-param[@name='block0700'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_22</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0282</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 			
			
			
            <!-- Add Feature  Service V0283 Sperre 0181 bis 0189 is set -->
			<xsl:if test="request-param[@name='block018x'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_23</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0283</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 						
			
			
           <!-- Add Feature  Service V0284 Sperre Online-Dienste (19xx) is set -->
			<xsl:if test="request-param[@name='block019xx'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_24</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0284</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 									
			
            <!-- Add Feature  Service V0285 Sperre Nationale Teilnehmer-rufnummern (032) is set -->
			<xsl:if test="request-param[@name='block032'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_25</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0285</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 												
			


	
            <!-- Add Feature  Service V0286 Sperre Innovative Dienste (012xx) is set -->
			<xsl:if test="request-param[@name='block012xx'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_26</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0286</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 												
						

            <!-- Add Feature  Service V0287 Sperre R-Gespräche is set -->
			<xsl:if test="request-param[@name='blockRCalls'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_27</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0287</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 												
			
			
			 <!-- Add Feature  Service V0510 Anruferidentifizierung is set -->
			<xsl:if test="request-param[@name='callerID'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_28</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0510</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 												
			
			
			 <!-- Add Feature  Service V0038 Anruferidentifizierung (mtl.) is set -->
			<xsl:if test="request-param[@name='callerIDMonthly'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_29</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0038</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 															
			
			 <!-- Add Feature  Service V0058 Anruferidentifizierung (tgl.) is set -->
			<xsl:if test="request-param[@name='callerIDDaily'] = 'Y'">
				<xsl:element name="CcmFifAddServiceSubsCmd">
					<xsl:element name="command_id">add_service_30</xsl:element>
					<xsl:element name="CcmFifAddServiceSubsInCont">
						<xsl:element name="product_subscription_ref">
							<xsl:element name="command_id">add_product_subscription_1</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">V0058</xsl:element>
						<xsl:element name="parent_service_subs_ref">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:if test="request-param[@name='reasonRd'] != ''">
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='reasonRd']"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='reasonRd'] = ''">
							<xsl:element name="reason_rd">CREATE_BIT_VOIP</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']=''">
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">read_external_notification_2</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='accountNumber']!=''">
							<xsl:element name="account_number">
								<xsl:value-of select="request-param[@name='accountNumber']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="service_characteristic_list">
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if> 															
						
												
			
			<!-- look for a  bundle  -->
			<xsl:element name="CcmFifFindBundleCmd">
				<xsl:element name="command_id">find_bundle_1</xsl:element>
				<xsl:element name="CcmFifFindBundleInCont">
                                        <xsl:element name="bundle_item_type_rd">BITACCESS</xsl:element>
					<xsl:if test="request-param[@name='serviceSubscriptionId']=''">
						<xsl:element name="supported_object_id_ref">
							<xsl:element name="command_id">read_external_notification_3</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='serviceSubscriptionId']!=''">
						<xsl:element name="supported_object_id">
							<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
						</xsl:element>
					</xsl:if>
                        <xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>                                        
				</xsl:element>
			</xsl:element>
			<!-- Add the new voice over IP  bundle item -->
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item_1</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">find_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd">BITVOIP</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">add_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
					<xsl:element name="bundle_found_ref">
						<xsl:element name="command_id">find_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>
					</xsl:element>
					<xsl:element name="action_name">ADD</xsl:element>
				</xsl:element>
			</xsl:element>
			<!-- Create Customer Order for new services  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
					</xsl:element>
					<xsl:element name="lan_path_file_string">
						<xsl:value-of select="request-param[@name='lanPathFileString']"/>
					</xsl:element>
					<xsl:element name="sales_rep_dept">
						<xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">
						<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
					</xsl:element>
					<xsl:element name="super_customer_tracking_id">
						<xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
					</xsl:element>
					<xsl:element name="scan_date">
						<xsl:value-of select="request-param[@name='scanDate']"/>
					</xsl:element>
					<xsl:element name="order_entry_date">
						<xsl:value-of select="request-param[@name='entryDate']"/>
					</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<!-- VI002 or V1003 -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<!--V0017-->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_2</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>

						<!-- VI219 -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_4</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>

						<!-- V0099 -->
						<xsl:if test="request-param[@name='bonusMyCompany'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_5</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- service level -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_6</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<!--V0025-->
						<xsl:if test="request-param[@name='blockInternational'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_7</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--V0026-->
						<xsl:if test="request-param[@name='blockOutsideEu'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_8</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<!--V0027-->
						<xsl:if test="request-param[@name='block0190/0900'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_9</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>

						<!-- V0254 -->
						<xsl:if test="request-param[@name='block0137Calls'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_13</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- V0255 -->
						<xsl:if test="request-param[@name='block01805Calls'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_14</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- V0256 -->
						<xsl:if test="request-param[@name='blockPremiumCalls'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_15</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- V0257 -->
						<xsl:if test="request-param[@name='blockOutgoingTraffic'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_16</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- V0258 -->
						<xsl:if test="request-param[@name='blockOutgoingTrafficExceptLocal'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_17</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- V0259 -->
						<xsl:if test="request-param[@name='blockMobileNumbers'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_18</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- V0260 -->
						<xsl:if test="request-param[@name='block0900'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_19</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>
						<!-- V0261 -->
						<xsl:if test="request-param[@name='block118xy'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_20</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>			
						
					    <!-- V0281 -->
						<xsl:if test="request-param[@name='block0180x'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_21</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>			
  					   <!-- V0282 -->
						<xsl:if test="request-param[@name='block0700'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_22</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>			
					<!-- V0283 -->
						<xsl:if test="request-param[@name='block018x'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_23</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>			
					<!-- V0284 -->
						<xsl:if test="request-param[@name='block019xx'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_24</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>			
					<!-- V0285 -->
						<xsl:if test="request-param[@name='block032'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_25</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>			
					<!-- V0286 -->
						<xsl:if test="request-param[@name='block012xx'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_26</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>			
					<!-- V0287 -->
						<xsl:if test="request-param[@name='blockRCalls'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_27</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>			
					<!-- V0510 -->
						<xsl:if test="request-param[@name='callerID'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_28</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>			
					<!-- V0038 -->
						<xsl:if test="request-param[@name='callerIDMonthly'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_29</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>					
                    <!-- V0058 -->
						<xsl:if test="request-param[@name='callerIDDaily'] = 'Y'">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">add_service_30</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:if>																										
																																													
					</xsl:element>
					<xsl:element name="e_shop_id">
						<xsl:value-of select="request-param[@name='eShopID']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Release stand alone Customer Order -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:if test="request-param[@name='customerNumber'] != ''">	
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber'] = ''">					
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_1</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>        
				</xsl:element>
			</xsl:element>      
			
			<xsl:if test="request-param[@name='orderVariant'] = 'Echte Neuanschaltung' and
				request-param[@name='typeOfNewActivation'] = 'Neuanschluss'">
				
				<!-- create contact role -->
				<xsl:choose>
					<xsl:when test="request-param[@name='lineOwnerAddressStreetName'] != '' and (
						request-param[@name='lineOwnerAddressStreetName'] != request-param[@name='streetName'] or
						request-param[@name='lineOwnerAddressNumber'] != request-param[@name='streetNumber'] or
						request-param[@name='lineOwnerAddressNumberSuffix'] != request-param[@name='numberSuffix'] or
						request-param[@name='lineOwnerAddressPostalCode'] != request-param[@name='postalCode'] or
						request-param[@name='lineOwnerAddressCity'] != request-param[@name='city'])">
						
						<xsl:element name="CcmFifCreateEntityCmd">
							<xsl:element name="command_id">create_entity_for_contactrole</xsl:element>
							<xsl:element name="CcmFifCreateEntityInCont">
								<xsl:element name="entity_type">I</xsl:element>
								<xsl:element name="salutation_description">Herr</xsl:element>
								<xsl:element name="forename">
									<xsl:value-of select="request-param[@name='lineOwnerFirstName']"/>
								</xsl:element>
								<xsl:element name="name">
									<xsl:value-of select="request-param[@name='lineOwnerLastName']"/>
								</xsl:element>
								<xsl:element name="birth_date"></xsl:element>
							</xsl:element>
						</xsl:element>
						
						<xsl:element name="CcmFifCreateContactRoleCmd">
							<xsl:element name="command_id">create_contact_role_1</xsl:element>
							<xsl:element name="CcmFifCreateContactRoleInCont">
								<xsl:if test="request-param[@name='customerNumber']=''">
									<xsl:element name="customer_number_ref">
										<xsl:element name="command_id">read_external_notification_1</xsl:element>
										<xsl:element name="field_name">parameter_value</xsl:element>
									</xsl:element>
								</xsl:if>
								<xsl:if test="request-param[@name='customerNumber']!=''">
									<xsl:element name="customer_number">
										<xsl:value-of select="request-param[@name='customerNumber']"/>
									</xsl:element>
								</xsl:if>
								<xsl:element name="entity_id_ref">
									<xsl:element name="command_id">create_entity_for_contactrole</xsl:element>
									<xsl:element name="field_name">entity_id</xsl:element>
								</xsl:element>					
								<xsl:element name="supported_object_id"/>
								<xsl:element name="address_id_ref">
									<xsl:element name="command_id">create_line_owner_address</xsl:element>
									<xsl:element name="field_name">address_id</xsl:element>
								</xsl:element>
								<xsl:element name="supported_object_type_rd"/>
								<xsl:element name="contact_role_type_rd">ACCESS_OWNER</xsl:element>
								<xsl:element name="contact_role_position_name"></xsl:element>
							</xsl:element>
						</xsl:element>
						
						<xsl:element name="CcmFifCreateContactRoleCmd">
							<xsl:element name="command_id">create_contact_role_link</xsl:element>
							<xsl:element name="CcmFifCreateContactRoleInCont">
								<xsl:element name="customer_number"/>
								<xsl:element name="contact_role_entity_id_ref">
									<xsl:element name="command_id">create_contact_role_1</xsl:element>
									<xsl:element name="field_name">contact_role_entity_id</xsl:element>
								</xsl:element>
								<xsl:if test="request-param[@name='serviceSubscriptionId'] = ''">
									<xsl:element name="supported_object_id_ref">
										<xsl:element name="command_id">read_external_notification_3</xsl:element>
										<xsl:element name="field_name">parameter_value</xsl:element>
									</xsl:element>
								</xsl:if>
								<xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
									<xsl:element name="supported_object_id">
										<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
									</xsl:element>
								</xsl:if>
								<xsl:element name="supported_object_type_rd">SERVICE_SUBS</xsl:element>
								<xsl:element name="contact_role_type_rd"/>
							</xsl:element>
						</xsl:element>
					</xsl:when>
					
					<xsl:otherwise>					
						<xsl:element name="CcmFifMapStringCmd">
							<xsl:element name="command_id">map_line_owner_equals_contact_person</xsl:element>
							<xsl:element name="CcmFifMapStringInCont">
								<xsl:element name="input_string_type">Kundenvorname;Kundenname</xsl:element>
								<xsl:element name="input_string_list">
									<xsl:element name="CcmFifCommandRefCont">
										<xsl:element name="command_id">get_entity_1</xsl:element>
										<xsl:element name="field_name">forename</xsl:element>							
									</xsl:element>
									<xsl:element name="CcmFifPassingValueCont">
										<xsl:element name="value">;</xsl:element>							
									</xsl:element>
									<xsl:element name="CcmFifCommandRefCont">
										<xsl:element name="command_id">get_entity_1</xsl:element>
										<xsl:element name="field_name">surname</xsl:element>							
									</xsl:element>
								</xsl:element>
								<xsl:element name="output_string_type">Y,N</xsl:element>
								<xsl:element name="string_mapping_list">
									<xsl:element name="CcmFifStringMappingCont">
										<xsl:element name="input_string">
											<xsl:value-of select="request-param[@name='lineOwnerFirstName']"/>
											<xsl:text>;</xsl:text>	
											<xsl:value-of select="request-param[@name='lineOwnerLastName']"/>									
										</xsl:element>
										<xsl:element name="output_string">Y</xsl:element>
									</xsl:element>
								</xsl:element>
								<xsl:element name="no_mapping_error">N</xsl:element>
							</xsl:element>
						</xsl:element>     
						
						<xsl:element name="CcmFifCreateEntityCmd">
							<xsl:element name="command_id">create_entity_for_contactrole</xsl:element>
							<xsl:element name="CcmFifCreateEntityInCont">
								<xsl:element name="entity_type">I</xsl:element>
								<xsl:element name="salutation_description">Herr</xsl:element>
								<xsl:element name="forename">
									<xsl:value-of select="request-param[@name='lineOwnerFirstName']"/>
								</xsl:element>
								<xsl:element name="name">
									<xsl:value-of select="request-param[@name='lineOwnerLastName']"/>
								</xsl:element>
								<xsl:element name="birth_date"></xsl:element>
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">map_line_owner_equals_contact_person</xsl:element>
									<xsl:element name="field_name">output_string_found</xsl:element>
								</xsl:element>
								<xsl:element name="required_process_ind">N</xsl:element>            
							</xsl:element>
						</xsl:element>
						
						<xsl:element name="CcmFifCreateContactRoleCmd">
							<xsl:element name="command_id">create_contact_role_1</xsl:element>
							<xsl:element name="CcmFifCreateContactRoleInCont">
								<xsl:if test="request-param[@name='customerNumber']=''">
									<xsl:element name="customer_number_ref">
										<xsl:element name="command_id">read_external_notification_1</xsl:element>
										<xsl:element name="field_name">parameter_value</xsl:element>
									</xsl:element>
								</xsl:if>
								<xsl:if test="request-param[@name='customerNumber']!=''">
									<xsl:element name="customer_number">
										<xsl:value-of select="request-param[@name='customerNumber']"/>
									</xsl:element>
								</xsl:if>
								<xsl:element name="entity_id_ref">
									<xsl:element name="command_id">create_entity_for_contactrole</xsl:element>
									<xsl:element name="field_name">entity_id</xsl:element>
								</xsl:element>					
								<xsl:element name="supported_object_id"/>
								<xsl:element name="address_id_ref">
									<xsl:element name="command_id">create_line_owner_address</xsl:element>
									<xsl:element name="field_name">address_id</xsl:element>
								</xsl:element>
								<xsl:element name="supported_object_type_rd"/>
								<xsl:element name="contact_role_type_rd">ACCESS_OWNER</xsl:element>
								<xsl:element name="contact_role_position_name"></xsl:element>														
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">map_line_owner_equals_contact_person</xsl:element>
									<xsl:element name="field_name">output_string_found</xsl:element>
								</xsl:element>
								<xsl:element name="required_process_ind">N</xsl:element>            
							</xsl:element>
						</xsl:element>
						
						<xsl:element name="CcmFifCreateContactRoleCmd">
							<xsl:element name="command_id">create_contact_role_link</xsl:element>
							<xsl:element name="CcmFifCreateContactRoleInCont">
								<xsl:element name="customer_number"/>
								<xsl:element name="contact_role_entity_id_ref">
									<xsl:element name="command_id">create_contact_role_1</xsl:element>
									<xsl:element name="field_name">contact_role_entity_id</xsl:element>
								</xsl:element>
								<xsl:if test="request-param[@name='serviceSubscriptionId'] = ''">
									<xsl:element name="supported_object_id_ref">
										<xsl:element name="command_id">read_external_notification_3</xsl:element>
										<xsl:element name="field_name">parameter_value</xsl:element>
									</xsl:element>
								</xsl:if>
								<xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
									<xsl:element name="supported_object_id">
										<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
									</xsl:element>
								</xsl:if>
								<xsl:element name="supported_object_type_rd">SERVICE_SUBS</xsl:element>
								<xsl:element name="contact_role_type_rd"/>
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">map_line_owner_equals_contact_person</xsl:element>
									<xsl:element name="field_name">output_string_found</xsl:element>
								</xsl:element>
								<xsl:element name="required_process_ind">N</xsl:element>            
							</xsl:element>
						</xsl:element>
						
					</xsl:otherwise>			
				</xsl:choose>
			</xsl:if>
			
			
			<!-- Create contact  for Service Addition -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact_1</xsl:element>
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:if test="request-param[@name='customerNumber']=''">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='customerNumber']!=''">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
					</xsl:if>

					<xsl:element name="contact_type_rd">VOIP_CONTRACT</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>Bit VoIP contract created.</xsl:text>
					</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
						<xsl:text>&#xA;BIT_VOIP Contract has been created on:</xsl:text>
						<xsl:if test="request-param[@name='desiredDate']!=''">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:if>
						<xsl:if test="request-param[@name='desiredDate'] = ''">
							<xsl:value-of select="$today"/>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:element>


			
			<!-- Create External notification  if requestListId is  set -->
			<xsl:if test="request-param[@name='requestListId'] != ''">
				<xsl:element name="CcmFifCreateExternalNotificationCmd">
					<xsl:element name="command_id">create_external_notification_2</xsl:element>
					<xsl:element name="CcmFifCreateExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="processed_indicator">Y</xsl:element>
						<xsl:element name="notification_action_name">CreateBitVoIPContract</xsl:element>
						<xsl:element name="target_system">FIF</xsl:element>
						<xsl:element name="parameter_value_list">
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">BitVoIP_SERVICE_SUBSCRIPTION_ID</xsl:element>
								<xsl:element name="parameter_value_ref">
									<xsl:element name="command_id">add_service_1</xsl:element>
									<xsl:element name="field_name">service_subscription_id</xsl:element>
								</xsl:element>
							</xsl:element>						
							<xsl:if test="request-param[@name='productCommitmentNumber']=''">
								<xsl:element name="CcmFifParameterValueCont">
								    <xsl:element name="parameter_name">CONTRACT_NUMBER</xsl:element>
								    <xsl:element name="parameter_value_ref">
									    <xsl:element name="command_id">create_order_form_1</xsl:element>
									    <xsl:element name="field_name">contract_number</xsl:element>
								    </xsl:element>
							    </xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='reasonRd'] != ''">
						    	<xsl:element name="CcmFifParameterValueCont">
	                				<xsl:element name="parameter_name">BitVoIP_DETAILED_REASON_RD</xsl:element>
	                				<xsl:element name="parameter_value">
										<xsl:value-of select="request-param[@name='reasonRd']"/>
	                				</xsl:element>
	              				</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='reasonRd'] = ''">
						    	<xsl:element name="CcmFifParameterValueCont">
	                				<xsl:element name="parameter_name">BitVoIP_DETAILED_REASON_RD</xsl:element>
	                				<xsl:element name="parameter_value">CREATE_BIT_VOIP</xsl:element>
	              				</xsl:element>
							</xsl:if>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>

	</xsl:template>
</xsl:stylesheet>
