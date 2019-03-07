<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
	XSLT file for creating a FIF request for a Preselect contract.
	
	@author banania
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
		<!-- Convert the desired date to OPM format -->
		<xsl:variable name="desiredDateOPM"
			select="dateutils:createOPMDate(request-param[@name='desiredDate'])"/>
		<xsl:variable name="bandwidthCheckDate"
			select="dateutils:createOPMDate(request-param[@name='bandwidthCheckDate'])"/>
		<xsl:variable name="bandwidthCheckSourceDate"
			select="dateutils:createOPMDate(request-param[@name='bandwidthCheckSourceDate'])"/>
		
	    <xsl:variable name="AddServCommandId">add_ss_</xsl:variable>
	    
	    <xsl:variable name="MaskingDigits">
	        <xsl:choose>
	            <xsl:when test="request-param[@name='cdrEgnFormat'] = 'NO_EGN'">0</xsl:when>
	            <xsl:when test="request-param[@name='cdrEgnFormat'] = 'ABBREVIATED_EGN'">20</xsl:when>
	            <xsl:when test="request-param[@name='cdrEgnFormat'] = 'FULL_EGN'">-1</xsl:when>
	            <xsl:when test="request-param[@name='cdrEgnFormat'] = 'NORMAL_EGN'">-1</xsl:when>
	            <xsl:otherwise>unknown</xsl:otherwise>
	        </xsl:choose>
	        
	    </xsl:variable>
	    
	    <xsl:variable name="StorageMaskingDigits">
	        <xsl:choose>
	            <xsl:when test="request-param[@name='cdrStorageFormat'] = 'IMMEDIATE_DELETION'">0</xsl:when>
	            <xsl:when test="request-param[@name='cdrStorageFormat'] = 'ABBREVIATED_STORAGE'">20</xsl:when>
	            <xsl:when test="request-param[@name='cdrStorageFormat'] = 'FULL_STORAGE'">-1</xsl:when>
	            <xsl:when test="request-param[@name='cdrStorageFormat'] = 'NORMAL_STORAGE'">-1</xsl:when>
	            <xsl:otherwise>unknown</xsl:otherwise>
	        </xsl:choose>
	    </xsl:variable>
	    
	    <xsl:variable name="RetentionPeriod">				
	        <xsl:choose>
	            <xsl:when test="request-param[@name='cdrEgnFormat'] = 'NO_EGN'">80NODT</xsl:when>
	            <xsl:when test="request-param[@name='cdrEgnFormat'] = 'ABBREVIATED_EGN'">80DETL</xsl:when>
	            <xsl:when test="request-param[@name='cdrEgnFormat'] = 'FULL_EGN'">80DETL</xsl:when>
	            <xsl:when test="request-param[@name='cdrEgnFormat'] = 'NORMAL_EGN'">80DETL</xsl:when>						
	            <xsl:otherwise>unknown</xsl:otherwise>
	        </xsl:choose>
	    </xsl:variable>
	    
	    
		<!-- Calculate today and one day before the desired date -->
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
		<xsl:element name="Command_List">
			<xsl:variable name="VoiceServiceCode">
			  <xsl:if test="request-param[@name='serviceType'] = 'ISDN'">
					<xsl:text>V0001</xsl:text>
				</xsl:if>		
			  <xsl:if test="request-param[@name='serviceType'] = 'Analog'">
					<xsl:text>V0004</xsl:text>
			  </xsl:if>
			    <xsl:if test="request-param[@name='serviceType'] = 'Anlagenanschluss'">
		        <xsl:text>V0002</xsl:text>
		    </xsl:if>
			</xsl:variable>

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
			
			<!-- Get Customer number if not provided-->
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
			
			<!-- Get Account number if not provided -->
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
				<!-- Create Address-->
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
		  
			<!-- Create Order Form-->
			<xsl:if test="request-param[@name='productCommitmentNumber']=''">
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
						<xsl:element name="assoc_skeleton_cont_num">
							<xsl:value-of select="request-param[@name='assocSkeletonContNum']"/>
						</xsl:element>
						<xsl:element name="auto_extent_period_value">
							<xsl:value-of select="request-param[@name='autoExtentPeriodValue']"/>
						</xsl:element>                         
						<xsl:element name="auto_extent_period_unit">
							<xsl:value-of select="request-param[@name='autoExtentPeriodUnit']"/>
						</xsl:element>                         
						<xsl:element name="auto_extension_ind">
							<xsl:value-of select="request-param[@name='autoExtensionInd']"/>
						</xsl:element>
						<xsl:element name="name">Preselect Vertrag</xsl:element>
					</xsl:element>
				
				</xsl:element>
			</xsl:if>
			
			<!-- Add Order Form Product Commitment -->
			<xsl:if test="request-param[@name='productCommitmentNumber']=''">
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
						<xsl:element name="product_code">V0001</xsl:element>
						<xsl:element name="pricing_structure_code">
							<xsl:value-of select="request-param[@name='tariff']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- Sign Order Form -->
			<xsl:if test="request-param[@name='productCommitmentNumber']=''">
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
							<xsl:value-of select="request-param[@name='primaryCustSignDate']"/>
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
			
			<!-- Add Main Service Subscription V0001 or V0004 -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_preselect_voice</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">		
						<xsl:value-of select="$VoiceServiceCode"/>
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
						<xsl:element name="reason_rd">ADD_PRESELECT</xsl:element>
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
					  <!-- Service Provider -->
					  <xsl:element name="CcmFifConfiguredValueCont">
					    <xsl:element name="service_char_code">V0010</xsl:element>
					    <xsl:element name="data_type">STRING</xsl:element>
					    <xsl:element name="configured_value">
					        <xsl:value-of select="request-param[@name='oldTNB']"/>
					    </xsl:element>
					  </xsl:element>
						<!-- Address -->
						<xsl:element name="CcmFifAddressCharacteristicCont">
							<xsl:element name="service_char_code">V0014</xsl:element>
							<xsl:element name="data_type">ADDRESS</xsl:element>
							<xsl:if test="request-param[@name='addressId'] = ''">
								<xsl:element name="address_ref">
									<xsl:element name="command_id">create_address</xsl:element>
									<xsl:element name="field_name">address_id</xsl:element>
								</xsl:element>
							</xsl:if>
							<xsl:if test="request-param[@name='addressId'] != ''">
								<xsl:element name="address_id">
									<xsl:value-of select="request-param[@name='addressId']"/>
								</xsl:element>
							</xsl:if>
						</xsl:element>
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
					      <xsl:value-of select="request-param[@name='lineOwnerLastName']"/>
					    </xsl:element>
					  </xsl:element>
					  <!-- STANDORT DES ANSCHLUSSES -->
					  <xsl:element name="CcmFifServiceLocationCont">
					    <xsl:element name="service_char_code">V0015</xsl:element>
					    <xsl:element name="data_type">SERVICE_LOCATION</xsl:element>
					    <xsl:element name="jack_location">
					      <xsl:value-of select="request-param[@name='serviceLocation']"/>
					    </xsl:element>
					  </xsl:element>
					  <!-- Old TNB -->
					  <xsl:element name="CcmFifConfiguredValueCont">
					    <xsl:element name="service_char_code">V0060</xsl:element>
					    <xsl:element name="data_type">STRING</xsl:element>
					    <xsl:element name="configured_value">
					      <xsl:value-of select="request-param[@name='oldTNB']"/>
					    </xsl:element>
					  </xsl:element>
					  <!--  New TNB -->
					  <xsl:element name="CcmFifConfiguredValueCont">
					    <xsl:element name="service_char_code">V0061</xsl:element>
					    <xsl:element name="data_type">STRING</xsl:element>
					    <xsl:element name="configured_value">
					      <xsl:value-of select="request-param[@name='newTNB']"/>
					    </xsl:element>
					  </xsl:element>
					  <!-- Old VNB -->
					  <xsl:element name="CcmFifConfiguredValueCont">
					    <xsl:element name="service_char_code">V0062</xsl:element>
					    <xsl:element name="data_type">STRING</xsl:element>
					    <xsl:element name="configured_value">
					      <xsl:value-of select="request-param[@name='oldVNB']"/>
					    </xsl:element>
					  </xsl:element>
					  <!--  New VNB -->
					  <xsl:element name="CcmFifConfiguredValueCont">
					    <xsl:element name="service_char_code">V0063</xsl:element>
					    <xsl:element name="data_type">STRING</xsl:element>
					    <xsl:element name="configured_value">
					      <xsl:value-of select="request-param[@name='newVNB']"/>
					    </xsl:element>
					  </xsl:element>
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
					  <!--  Kondition/Rabatt -->
					  <xsl:element name="CcmFifConfiguredValueCont">
					    <xsl:element name="service_char_code">V0097</xsl:element>
					    <xsl:element name="data_type">STRING</xsl:element>
					    <xsl:element name="configured_value">
					      <xsl:value-of select="request-param[@name='rabatt']"/>
					    </xsl:element>
					  </xsl:element> 
					  <!--  Kondition/Rabatt -->
					  <xsl:element name="CcmFifConfiguredValueCont">
					    <xsl:element name="service_char_code">V0162</xsl:element>
					    <xsl:element name="data_type">STRING</xsl:element>
					    <xsl:element name="configured_value">
					      <xsl:value-of select="request-param[@name='rabattId']"/>
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
					        <xsl:value-of select="request-param[@name='secondLineOwnerLastName']"/>
					      </xsl:element>
					    </xsl:element>
					  </xsl:if>
					  <!--  Second line owner first name -->
					  <xsl:if test="request-param[@name='secondLineOwnerFirstName']!= ''">
					    <xsl:element name="CcmFifConfiguredValueCont">
					      <xsl:element name="service_char_code">V0130</xsl:element>
					      <xsl:element name="data_type">STRING</xsl:element>
					      <xsl:element name="configured_value">
					        <xsl:value-of select="request-param[@name='secondLineOwnerFirstName']"/>
					      </xsl:element>
					    </xsl:element>
					  </xsl:if>
					  <!--  Kondition/Rabatt -->
					  <xsl:element name="CcmFifConfiguredValueCont">
					    <xsl:element name="service_char_code">V0162</xsl:element>
					    <xsl:element name="data_type">STRING</xsl:element>
					    <xsl:element name="configured_value">
					      <xsl:value-of select="request-param[@name='rabattId']"/>
					    </xsl:element>
					  </xsl:element> 
					  <!--  Tasi -->
					  <xsl:element name="CcmFifAccessNumberCont">
					    <xsl:element name="service_char_code">A0050</xsl:element>
					    <xsl:element name="data_type">USER_ACCOUNT_NUM</xsl:element>
					    <xsl:element name="network_account">
					      <xsl:value-of select="request-param[@name='tasi']"/>
					    </xsl:element>
					  </xsl:element>
					    <!-- Rufnummer (Zentrale) -->
					    <xsl:element name="CcmFifConfiguredValueCont">
					        <xsl:element name="service_char_code">V0016</xsl:element>
					        <xsl:element name="data_type">STRING</xsl:element>
					        <xsl:element name="configured_value">
					            <xsl:value-of select="request-param[@name='centralOffice']"/>
					        </xsl:element>
					    </xsl:element>
					    <!-- Billing Account Number -->
							<xsl:element name="CcmFifConfiguredValueCont">
								<xsl:element name="service_char_code">V1002</xsl:element>
								<xsl:element name="data_type">STRING</xsl:element>
								<xsl:element name="configured_value">
									<xsl:value-of select="request-param[@name='billingAccountNumber']"/>
								</xsl:element>
							</xsl:element>
					    <!-- Anschlußnummernbereich -->
					    <xsl:if test="request-param[@name='accessNumberRange'] != ''">
					        <xsl:element name="CcmFifAccessNumberCont">
					            <xsl:element name="service_char_code">V0002</xsl:element>
					            <xsl:element name="data_type">ACC_NUM_RANGE</xsl:element>
					            <xsl:element name="masking_digits_rd">
					                <xsl:value-of select="$MaskingDigits"/>
					            </xsl:element>
					            <xsl:element name="retention_period_rd">
					                <xsl:value-of select="$RetentionPeriod"/>
					            </xsl:element>
					            <xsl:element name="storage_masking_digits_rd">
					                <xsl:value-of select="$StorageMaskingDigits"/>
					            </xsl:element>
					            <xsl:element name="country_code">
					                <xsl:value-of select="substring-before(request-param[@name='accessNumberRange'], ';')"/>
					            </xsl:element>
					            <xsl:element name="city_code">
					                <xsl:value-of select="substring-before(substring-after(request-param[@name='accessNumberRange'],';'), ';')"/>
					            </xsl:element>
					            <xsl:element name="local_number">
					                <xsl:value-of 
					                    select= "substring-before(substring-after(substring-after(request-param[@name='accessNumberRange'],';'), ';'), ';')"/>
					            </xsl:element>
					            <xsl:element name="from_ext_num">
					                <xsl:value-of 
					                    select="substring-before(substring-after(substring-after(substring-after(request-param[@name='accessNumberRange'],';'), ';'), ';'), ';')"/>
					            </xsl:element>
					            <xsl:element name="to_ext_num">
					                <xsl:value-of 
					                    select="substring-after(substring-after(substring-after(substring-after(request-param[@name='accessNumberRange'],';'), ';'), ';'), ';')"/>
					            </xsl:element>
					        </xsl:element>
					    </xsl:if>
					    <!-- Anschlußnummernbereich-extra1 -->
					    <xsl:if test="request-param[@name='additionalAccessNumberRange1'] != ''">
					        <xsl:element name="CcmFifAccessNumberCont">
					            <xsl:element name="service_char_code">W9002</xsl:element>
					            <xsl:element name="data_type">ACC_NUM_RANGE</xsl:element>
					            <xsl:element name="masking_digits_rd">
					                <xsl:value-of select="$MaskingDigits"/>
					            </xsl:element>
					            <xsl:element name="retention_period_rd">
					                <xsl:value-of select="$RetentionPeriod"/>
					            </xsl:element>
					            <xsl:element name="storage_masking_digits_rd">
					                <xsl:value-of select="$StorageMaskingDigits"/>
					            </xsl:element>
					            <xsl:element name="country_code">
					                <xsl:value-of select="substring-before(request-param[@name='additionalAccessNumberRange1'], ';')"/>
					            </xsl:element>
					            <xsl:element name="city_code">
					                <xsl:value-of select="substring-before(substring-after(request-param[@name='additionalAccessNumberRange1'],';'), ';')"/>
					            </xsl:element>
					            <xsl:element name="local_number">
					                <xsl:value-of 
					                    select= "substring-before(substring-after(substring-after(request-param[@name='additionalAccessNumberRange1'],';'), ';'), ';')"/>
					            </xsl:element>
					            <xsl:element name="from_ext_num">
					                <xsl:value-of 
					                    select="substring-before(substring-after(substring-after(substring-after(request-param[@name='additionalAccessNumberRange1'],';'), ';'), ';'), ';')"/>
					            </xsl:element>
					            <xsl:element name="to_ext_num">
					                <xsl:value-of 
					                    select="substring-after(substring-after(substring-after(substring-after(request-param[@name='additionalAccessNumberRange1'],';'), ';'), ';'), ';')"/>
					            </xsl:element>
					        </xsl:element>
					    </xsl:if>
					    <!-- Anschlußnummernbereich-extra2  -->
					    <xsl:if test="request-param[@name='additionalAccessNumberRange2'] != ''">
					        <xsl:element name="CcmFifAccessNumberCont">
					            <xsl:element name="service_char_code">W9003</xsl:element>
					            <xsl:element name="data_type">ACC_NUM_RANGE</xsl:element>
					            <xsl:element name="masking_digits_rd">
					                <xsl:value-of select="$MaskingDigits"/>
					            </xsl:element>
					            <xsl:element name="retention_period_rd">
					                <xsl:value-of select="$RetentionPeriod"/>
					            </xsl:element>
					            <xsl:element name="storage_masking_digits_rd">
					                <xsl:value-of select="$StorageMaskingDigits"/>
					            </xsl:element>
					            <xsl:element name="country_code">
					                <xsl:value-of select="substring-before(request-param[@name='additionalAccessNumberRange2'], ';')"/>
					            </xsl:element>
					            <xsl:element name="city_code">
					                <xsl:value-of select="substring-before(substring-after(request-param[@name='additionalAccessNumberRange2'],';'), ';')"/>
					            </xsl:element>
					            <xsl:element name="local_number">
					                <xsl:value-of 
					                    select= "substring-before(substring-after(substring-after(request-param[@name='additionalAccessNumberRange2'],';'), ';'), ';')"/>
					            </xsl:element>
					            <xsl:element name="from_ext_num">
					                <xsl:value-of 
					                    select="substring-before(substring-after(substring-after(substring-after(request-param[@name='additionalAccessNumberRange2'],';'), ';'), ';'), ';')"/>
					            </xsl:element>
					            <xsl:element name="to_ext_num">
					                <xsl:value-of 
					                    select="substring-after(substring-after(substring-after(substring-after(request-param[@name='additionalAccessNumberRange2'],';'), ';'), ';'), ';')"/>
					            </xsl:element>
					        </xsl:element>
					    </xsl:if>
					    <!-- Comment -->          
					    <xsl:element name="CcmFifConfiguredValueCont">
					        <xsl:element name="service_char_code">V0008</xsl:element>
					        <xsl:element name="data_type">STRING</xsl:element>
					        <xsl:element name="configured_value">
					            <xsl:value-of select="request-param[@name='remarks']"/>
					        </xsl:element>
					    </xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element> 
			<!-- Add monthly charge V0006 -->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_monthly_charge</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">add_product_subscription_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0006</xsl:element>
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
						<xsl:element name="reason_rd">ADD_PRESELECT</xsl:element>
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
				  <xsl:element name="service_characteristic_list" />				
				</xsl:element>
			</xsl:element>	
		  
		  <!-- Add Wechselgebührerstattung V0000 -->
		  <xsl:element name="CcmFifAddServiceSubsCmd">
		    <xsl:element name="command_id">add_service_wge</xsl:element>
		    <xsl:element name="CcmFifAddServiceSubsInCont">
		      <xsl:element name="product_subscription_ref">
		        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
		        <xsl:element name="field_name">product_subscription_id</xsl:element>
		      </xsl:element>
		      <xsl:element name="service_code">V0000</xsl:element>
		      <xsl:element name="parent_service_subs_ref">
		        <xsl:element name="command_id">add_preselect_voice</xsl:element>
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
		        <xsl:element name="reason_rd">ADD_PRESELECT</xsl:element>
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
		      <xsl:element name="service_characteristic_list" />				
		    </xsl:element>
		  </xsl:element>	

		  <!-- Add  Service V0008 (Ort) if the parameter addLocalService is set -->
		  <xsl:if test="request-param[@name='addLocalService'] = 'Y'">
		    <xsl:element name="CcmFifAddServiceSubsCmd">
		      <xsl:element name="command_id">add_local_service</xsl:element>
		      <xsl:element name="CcmFifAddServiceSubsInCont">
		        <xsl:element name="product_subscription_ref">
		          <xsl:element name="command_id">add_product_subscription_1</xsl:element>
		          <xsl:element name="field_name">product_subscription_id</xsl:element>
		        </xsl:element>
		        <xsl:element name="service_code">V0008</xsl:element> 
		        <xsl:element name="parent_service_subs_ref">
		          <xsl:element name="command_id">add_preselect_voice</xsl:element>
		          <xsl:element name="field_name">service_subscription_id</xsl:element>
		        </xsl:element>
		        <xsl:element name="desired_date">
		          <xsl:value-of select="$today"/>
		        </xsl:element>
		        <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
		        <xsl:if test="request-param[@name='reasonRd'] != ''">
		          <xsl:element name="reason_rd">
		            <xsl:value-of select="request-param[@name='reasonRd']"/>
		          </xsl:element>
		        </xsl:if>
		        <xsl:if test="request-param[@name='reasonRd'] = ''">
		          <xsl:element name="reason_rd">CREATE_DSLR</xsl:element>
		        </xsl:if>    
		        <xsl:if test="request-param[@name='accountNumber'] = ''">          
		          <xsl:element name="account_number_ref">
		            <xsl:element name="command_id">find_service_1</xsl:element>
		            <xsl:element name="field_name">account_number</xsl:element>
		          </xsl:element> 
		        </xsl:if> 
		        <xsl:if test="request-param[@name='accountNumber'] != ''">          
		          <xsl:element name="account_number">
		            <xsl:value-of select="request-param[@name='accountNumber']"/>
		          </xsl:element>  
		        </xsl:if> 
		        <xsl:element name="service_characteristic_list"/>
		      </xsl:element>
		    </xsl:element>
		  </xsl:if>	
		  
		  <!-- Add  Service V0009 (Fern) if the parameter addLongDistance is set -->
		  <xsl:if test="request-param[@name='addLongDistance'] = 'Y'">
		    <xsl:element name="CcmFifAddServiceSubsCmd">
		      <xsl:element name="command_id">add_longdistance_service</xsl:element>
		      <xsl:element name="CcmFifAddServiceSubsInCont">
		        <xsl:element name="product_subscription_ref">
		          <xsl:element name="command_id">add_product_subscription_1</xsl:element>
		          <xsl:element name="field_name">product_subscription_id</xsl:element>
		        </xsl:element>
		        <xsl:element name="service_code">V0009</xsl:element> 
		        <xsl:element name="parent_service_subs_ref">
		          <xsl:element name="command_id">add_preselect_voice</xsl:element>
		          <xsl:element name="field_name">service_subscription_id</xsl:element>
		        </xsl:element>
		        <xsl:element name="desired_date">
		          <xsl:value-of select="$today"/>
		        </xsl:element>
		        <xsl:element name="desired_schedule_type">START_AFTER</xsl:element>
		        <xsl:if test="request-param[@name='reasonRd'] != ''">
		          <xsl:element name="reason_rd">
		            <xsl:value-of select="request-param[@name='reasonRd']"/>
		          </xsl:element>
		        </xsl:if>
		        <xsl:if test="request-param[@name='reasonRd'] = ''">
		          <xsl:element name="reason_rd">CREATE_DSLR</xsl:element>
		        </xsl:if>    
		        <xsl:if test="request-param[@name='accountNumber'] = ''">          
		          <xsl:element name="account_number_ref">
		            <xsl:element name="command_id">find_service_1</xsl:element>
		            <xsl:element name="field_name">account_number</xsl:element>
		          </xsl:element> 
		        </xsl:if> 
		        <xsl:if test="request-param[@name='accountNumber'] != ''">          
		          <xsl:element name="account_number">
		            <xsl:value-of select="request-param[@name='accountNumber']"/>
		          </xsl:element>  
		        </xsl:if> 
		        <xsl:element name="service_characteristic_list"/>
		      </xsl:element>
		    </xsl:element>
		  </xsl:if>	
	
		    <!-- Create Feature Services -->
                <xsl:variable name ="accountNum"
                select="request-param[@name='accountNumber']"/> 
		    <xsl:if	test="count(request-param-list[@name='featureServiceList']/request-param-list-item) != 0">	
		        <xsl:for-each select="request-param-list[@name='featureServiceList']/request-param-list-item">
		            <xsl:variable name="featureServiceCode" select="request-param[@name='serviceCode']"/>
		            <xsl:element name="CcmFifAddServiceSubsCmd">
		                <xsl:element name="command_id">
		                    <xsl:value-of select="concat($AddServCommandId, $featureServiceCode)"/>
		                </xsl:element>
                     <xsl:element name="CcmFifAddServiceSubsInCont">
		                    <xsl:element name="product_subscription_ref">
		                        <xsl:element name="command_id">add_product_subscription_1</xsl:element>
		                        <xsl:element name="field_name">product_subscription_id</xsl:element>
		                    </xsl:element>
		                    <xsl:element name="service_code">
		                        <xsl:value-of select="$featureServiceCode"/>
		                    </xsl:element>
		                    <xsl:element name="parent_service_subs_ref">
		                        <xsl:element name="command_id">add_preselect_voice</xsl:element>
		                        <xsl:element name="field_name">service_subscription_id</xsl:element>
		                    </xsl:element>
		                    <xsl:element name="desired_schedule_type">ASAP</xsl:element>
		                    <xsl:element name="reason_rd">CUST_REQUEST</xsl:element>              
		                    <xsl:if test="$accountNum=''">
		                        <xsl:element name="account_number_ref">
		                            <xsl:element name="command_id">read_account_num_from_ext_noti</xsl:element>
		                            <xsl:element name="field_name">parameter_value</xsl:element>
		                        </xsl:element>
		                    </xsl:if>
                                            
                       <xsl:if test="$accountNum != ''">          
                       <xsl:element name="account_number">
		                   <xsl:value-of select="$accountNum"/>
		                   </xsl:element>  
		                   </xsl:if>
		                   
                                            
		                    <xsl:element name="service_characteristic_list"/>
		                </xsl:element>
		            </xsl:element>
		        </xsl:for-each>
		    </xsl:if>
		    
			<!-- check for existing bundle if bundleId id was provided -->
			<xsl:if test="request-param[@name='bundleId'] != ''">			
				<xsl:element name="CcmFifFindBundleCmd">
					<xsl:element name="command_id">find_bundle_1</xsl:element>
					<xsl:element name="CcmFifFindBundleInCont">
						<xsl:element name="bundle_id">
							<xsl:value-of select="request-param[@name='bundleId']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
			<!-- create new bundle -->
			<xsl:element name="CcmFifModifyBundleCmd">
				<xsl:element name="command_id">modify_bundle_1</xsl:element>
				<xsl:element name="CcmFifModifyBundleInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">find_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
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
					<xsl:element name="bundle_found_ref">
						<xsl:element name="command_id">find_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_found</xsl:element>							
					</xsl:element>		
				</xsl:element>
			</xsl:element>

		    <!-- Set ao_status on bundle -->
		    <xsl:element name="CcmFifModifyBundleCmd">
		        <xsl:element name="command_id">set_ao_status_on_bundle</xsl:element>
		        <xsl:element name="CcmFifModifyBundleInCont">
		            <xsl:element name="bundle_id_ref">
		                <xsl:element name="command_id">modify_bundle_1</xsl:element>
		                <xsl:element name="field_name">bundle_id</xsl:element>
		            </xsl:element>
		            <xsl:element name="ao_status">
		                <xsl:value-of select="request-param[@name='aoMastered']"/>
		            </xsl:element>
		        </xsl:element>
		    </xsl:element>
			
			<!-- add the new  bundle item of type PRESELECT -->
			<xsl:element name="CcmFifModifyBundleItemCmd">
				<xsl:element name="command_id">modify_bundle_item_1</xsl:element>
				<xsl:element name="CcmFifModifyBundleItemInCont">
					<xsl:element name="bundle_id_ref">
						<xsl:element name="command_id">modify_bundle_1</xsl:element>
						<xsl:element name="field_name">bundle_id</xsl:element>
					</xsl:element>
					<xsl:element name="bundle_item_type_rd">PRESELECT_SERV</xsl:element>
					<xsl:element name="supported_object_id_ref">
						<xsl:element name="command_id">add_preselect_voice</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="supported_object_type_rd">SERVSUB</xsl:element>
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
						<!-- Preselct Voice -->
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_preselect_voice</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					    <!-- Monthly charge -->
					    <xsl:element name="CcmFifCommandRefCont">
					        <xsl:element name="command_id">add_service_monthly_charge</xsl:element>
					        <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
					    </xsl:element>					    
						<!-- Wechselgebührerstattung -->
						<xsl:element name="CcmFifCommandRefCont">
						  <xsl:element name="command_id">add_service_wge</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					  <!-- Ort -->
					  <xsl:element name="CcmFifCommandRefCont">
					    <xsl:element name="command_id">add_local_service</xsl:element>
					    <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
					  </xsl:element>
					  <!-- Fern -->
					  <xsl:element name="CcmFifCommandRefCont">
					    <xsl:element name="command_id">add_longdistance_service</xsl:element>
					    <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
					  </xsl:element>
				      <xsl:for-each select="request-param-list[@name='featureServiceListAdd']/request-param-list-item">
				        <xsl:variable name="featureServiceCode" select="request-param[@name='serviceCode']"/>
				        <xsl:variable name="addServCommandId">add_ss_</xsl:variable>
				        <xsl:element name="CcmFifCommandRefCont">
				            <xsl:element name="command_id">
				                <xsl:value-of select="concat($addServCommandId, $featureServiceCode)"/>
				            </xsl:element>
				            <xsl:element name="field_name">service_ticket_pos_id</xsl:element>
				        </xsl:element>
				      </xsl:for-each>	
					</xsl:element>
					<xsl:element name="e_shop_id">
						<xsl:value-of select="request-param[@name='eShopID']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Release stand alone customer Order --> 
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="command_id">release_co_1</xsl:element>
				<xsl:element name="CcmFifReleaseCustOrderInCont">
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
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_co_1</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
				</xsl:element>
				</xsl:element>

			<!-- Create contact  for Service Addition -->
		    <xsl:if test="request-param[@name='productCommitmentNumber']=''">
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
					<xsl:element name="contact_type_rd">ADD_PRESELECT</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>Anlage Preselect Vertrag.</xsl:text>
					</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
						<xsl:text>&#xA;Preselect Contract has been created on:</xsl:text>
						<xsl:if test="request-param[@name='desiredDate']!=''">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:if>
						<xsl:if test="request-param[@name='desiredDate'] = ''">
							<xsl:value-of select="$today"/>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		    </xsl:if>
			
            <!-- Create contact  for Service Addition -->
		    <xsl:if test="request-param[@name='productCommitmentNumber']!=''">
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="command_id">create_contact_1_ps</xsl:element>
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
					<xsl:element name="contact_type_rd">ADD_PRESELECT</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>Anlage PS.</xsl:text>
					</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
						<xsl:text>&#xA;Preselect Product subscription has been added on:</xsl:text>
						<xsl:if test="request-param[@name='desiredDate']!=''">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:if>
						<xsl:if test="request-param[@name='desiredDate'] = ''">
							<xsl:value-of select="$today"/>
						</xsl:if>
						<xsl:text>&#xA;Username:</xsl:text>
						<xsl:value-of select="request-param[@name='userName']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			</xsl:if>

			<!--  Create  external notification if the requestListId is set  -->
			<xsl:if test="request-param[@name='requestListId'] != ''">
				<xsl:element name="CcmFifCreateExternalNotificationCmd">
					<xsl:element name="command_id">create_notification_1</xsl:element>
					<xsl:element name="CcmFifCreateExternalNotificationInCont">
						<xsl:element name="effective_date">
							<xsl:if test="request-param[@name='desiredDate'] != ''">
								<xsl:value-of select="request-param[@name='desiredDate']"/>
							</xsl:if>
							<xsl:if test="request-param[@name='desiredDate'] = ''">
								<xsl:value-of select="$today"/>
							</xsl:if>
						</xsl:element>
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="processed_indicator">Y</xsl:element>
						<xsl:element name="notification_action_name">CreateDSLRContract</xsl:element>
						<xsl:element name="target_system">FIF</xsl:element>
						<xsl:element name="parameter_value_list">
							<xsl:element name="CcmFifParameterValueCont">
							  <xsl:element name="parameter_name">PRESELECT_SERVICE_SUBSCRIPTION_ID</xsl:element>
								<xsl:element name="parameter_value_ref">
									<xsl:element name="command_id">add_preselect_voice</xsl:element>
									<xsl:element name="field_name">service_subscription_id</xsl:element>
								</xsl:element>
							</xsl:element>	
							<xsl:element name="CcmFifParameterValueCont">
								<xsl:element name="parameter_name">CUSTOMER_ORDER_ID</xsl:element>
								<xsl:element name="parameter_value_ref">
									<xsl:element name="command_id">create_co_1</xsl:element>
									<xsl:element name="field_name">customer_order_id</xsl:element>
								</xsl:element>
							</xsl:element>					
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>

		</xsl:element>

	</xsl:template>
</xsl:stylesheet>
