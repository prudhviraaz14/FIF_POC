<?xml version="1.0" encoding="utf-8"?>
<!--xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"-->
	<!--
  XSLT file for creating a FIF request for Adding Directory Entry
  @author Vinit Sawalkar
-->
	<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  	xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
	<xsl:template match="/">
		<xsl:element name="CcmFifCommandList">
			<xsl:apply-templates select="request/request-params"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="request-params">
		<!-- Copy over transaction ID, client name, override system date and action name -->
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
		
		<xsl:variable name="today"
			select="dateutils:getCurrentDate()"/>
		<xsl:variable name="tomorrow"
			select="dateutils:createFIFDateOffset($today, 'DATE', '1')"/>
		
		<xsl:element name="Command_List">
			
			<xsl:variable name="Type" select="request-param[@name='type']"/> 

			<xsl:if test="(request-param[@name='serviceSubscriptionId'] = '')
				and (request-param[@name='accessNumber'] = '')
				and ($Type = '')">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">type_error_1</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">The paramter type has to be set if serviceSubscriptionId and accessNumber are empty!</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
						
			<!-- Validate the parameter type -->
			<xsl:if test="(($Type != '')
				and ($Type != 'VoIP')
				and ($Type != 'NGNVoIP')      
				and ($Type != 'VOICE')
				and ($Type != 'ISDN')
                and ($Type != 'BitVoIP')     				
				and (request-param[@name='serviceSubscriptionId'] = '')
				and (request-param[@name='accessNumber'] = ''))">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">type_error_2</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">The parameter type has to  be set to ISDN, VoIP, BitVoIP or NGNVoIP!</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
					
			    <!--Get Detailed Reason Rd -->     
		        <xsl:element name="CcmFifReadExternalNotificationCmd">
		               <xsl:element name="command_id">read_external_notification_3</xsl:element>
		               <xsl:element name="CcmFifReadExternalNotificationInCont">
		                   <xsl:element name="transaction_id">
		                    <xsl:value-of select="request-param[@name='requestListId']"/>
		                   </xsl:element>
		                   <xsl:element name="parameter_name">DETAILED_REASON_RD</xsl:element>
		                   <xsl:element name="ignore_empty_result">Y</xsl:element>
		              </xsl:element>
		        </xsl:element>
					
			<!-- Find Service Subscription by access number, STP Id or Service Subscription Id-->
			<xsl:if test="(request-param[@name='accessNumber'] != '') or (request-param[@name='serviceSubscriptionId'] != '')or (request-param[@name='productSubscriptionID'] != '')" >
				<xsl:element name="CcmFifFindServiceSubsCmd">
					<xsl:element name="command_id">find_service_1</xsl:element>
					<xsl:element name="CcmFifFindServiceSubsInCont">
	
						<xsl:if test="((request-param[@name='accessNumber'] != '' )and (request-param[@name='serviceSubscriptionId'] = ''))">
							<xsl:element name="access_number">
								<xsl:value-of select="request-param[@name='accessNumber']"/>
							</xsl:element>
							<xsl:element name="access_number_format">SEMICOLON_DELIMITED</xsl:element>
						</xsl:if>
						<xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
							<xsl:element name="service_subscription_id">
								<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="effective_date">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:element>						
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="contract_number">
							<xsl:value-of select="request-param[@name='contractNumber']"/>
						</xsl:element>						
						<!--IT 16902 Changes-->
				           <xsl:if test="((request-param[@name='productSubscriptionID'] != '' )and ((request-param[@name='accessNumber'] = '' ) and (request-param[@name='serviceSubscriptionId'] = '')))">
							   <xsl:element name="product_subscription_id">
								   <xsl:value-of select="request-param[@name='productSubscriptionID']"/>
							   </xsl:element>
							   <xsl:element name="fetch_main_ss_from_ps_Ind">Y</xsl:element>
					       </xsl:if>
				   <!--IT 16902 Changes ended-->	
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- Take value of serviceSubscriptionId from ccm external notification if accessNumber,serviceTicketPositionId,serviceSubscriptionId not provided -->
			<xsl:if test="(request-param[@name='accessNumber'] = '')  and (request-param[@name='serviceSubscriptionId'] = '') and (request-param[@name='productSubscriptionID'] = '')">

				<xsl:if test="$Type != ''">                          
					<xsl:element name="CcmFifReadExternalNotificationCmd">
						<xsl:element name="command_id">read_external_notification_1</xsl:element>
						<xsl:element name="CcmFifReadExternalNotificationInCont">
							<xsl:element name="transaction_id">
								<xsl:value-of select="request-param[@name='requestListId']"/>
							</xsl:element>
							<xsl:element name="parameter_name">
								<xsl:value-of select="concat($Type, '_SERVICE_SUBSCRIPTION_ID')"/>
							</xsl:element>                        
						</xsl:element>
					</xsl:element>
				</xsl:if>
				
				<xsl:element name="CcmFifFindServiceSubsCmd">
					<xsl:element name="command_id">find_service_1</xsl:element>
					<xsl:element name="CcmFifFindServiceSubsInCont">
						<xsl:element name="service_subscription_id_ref">
							<xsl:element name="command_id">read_external_notification_1</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>
						</xsl:element>
						<xsl:element name="effective_date">
							<xsl:value-of select="request-param[@name='desiredDate']"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>

			<!-- find an open customer order for the main access service  for ISDN-->
			<xsl:element name="CcmFifFindCustomerOrderCmd">
				<xsl:element name="command_id">find_customer_order_1</xsl:element>
				<xsl:element name="CcmFifFindCustomerOrderInCont">
					<xsl:element name="service_subscription_id_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="state_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">ASSIGNED</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">RELEASED</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">PROVISIONED</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">INSTALLED</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="allow_children">Y</xsl:element>
					<xsl:element name="usage_mode">1</xsl:element>
				</xsl:element>
			</xsl:element>

			<xsl:variable name="inverseSearchIndicator">
				<xsl:if test="request-param[@name='inverseSearchIndicator'] = 'Y'">J</xsl:if>
				<xsl:if test="request-param[@name='inverseSearchIndicator'] != 'Y'">
					<xsl:value-of select="request-param[@name='inverseSearchIndicator']"/>
				</xsl:if>
			</xsl:variable>
			
			<!-- Add Directory Entry-->
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_service_1</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">V0100</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element> 					
					<xsl:element name="desired_date">
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:element>	
					<xsl:element name="desired_schedule_type">START_BEFORE</xsl:element>
					<xsl:if test="(request-param[@name='reasonRd'] = '')">
						<xsl:element name="reason_rd">CUST_REQUEST</xsl:element>
					</xsl:if>	
					<xsl:if test="(request-param[@name='reasonRd'] != '')">
						<xsl:element name="reason_rd">
							<xsl:value-of select="request-param[@name='reasonRd']"/>
						</xsl:element>
					</xsl:if>					
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_service_1</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>
					</xsl:element>
					<xsl:element name="service_characteristic_list">
						<xsl:element name="CcmFifDirectoryEntryCont">
							<xsl:element name="service_char_code">V0100</xsl:element>
							<xsl:element name="data_type">DIRECTORY_ENTRY</xsl:element>
							<xsl:element name="type">01  PRN  ELewAUS</xsl:element>
							<!--IT-16902 Changes-->
							<xsl:if test="(request-param[@name='accessNumber'] != '')
								and (request-param[@name='listedAccessNumber'] = '') ">
								<xsl:variable name="CountryCode" select="number(substring-before(request-param[@name='accessNumber'], ';'))"/>
								<xsl:variable name="CityCode" select="number(substring-before(substring-after(request-param[@name='accessNumber'],';'), ';'))"/>
								<xsl:variable name="LocalNumber" select="number(substring-after(substring-after(request-param[@name='accessNumber'],';'), ';'))"/>
								<xsl:element name="access_number">
									<xsl:value-of select="concat('RUF 00',$CountryCode,' 0',$CityCode,'/',$LocalNumber)"/>
								</xsl:element>
							</xsl:if> 
							
							<xsl:if test="request-param[@name='listedAccessNumber'] != '' ">
								<xsl:variable name="CountryCode" select="number(substring-before(request-param[@name='listedAccessNumber'], ';'))"/>
								<xsl:variable name="CityCode" select="number(substring-before(substring-after(request-param[@name='listedAccessNumber'],';'), ';'))"/>
								<xsl:variable name="LocalNumber" select="number(substring-after(substring-after(request-param[@name='listedAccessNumber'],';'), ';'))"/>
								<xsl:element name="access_number">
									<xsl:value-of select="concat('RUF 00',$CountryCode,' 0',$CityCode,'/',$LocalNumber)"/>
								</xsl:element>
							</xsl:if>
							
							<xsl:if test="(request-param[@name='accessNumber'] = '')
								and (request-param[@name='listedAccessNumber'] = '')">
								<xsl:element name="access_number">123456789</xsl:element>
							</xsl:if>
							<!--IT-16902 Changes Ended-->
							
							<xsl:element name="name">
								<xsl:value-of select="request-param[@name='name']"/>
							</xsl:element>
							<xsl:element name="forename">
								<xsl:value-of select="request-param[@name='forename']"/>
							</xsl:element>
							<xsl:element name="nobility_prefix">
								<xsl:value-of select="request-param[@name='nobilityPrefixDescription']"/>
							</xsl:element>
							<xsl:element name="title">
								<xsl:value-of select="request-param[@name='titleDescription']"/>
							</xsl:element>
							<xsl:element name="surname_prefix">
								<xsl:value-of select="request-param[@name='surnamePrefix']"/>
							</xsl:element>
							<xsl:element name="profession">
								<xsl:value-of select="request-param[@name='profession']"/>
							</xsl:element>
							<xsl:element name="industry_group">
								<xsl:value-of select="request-param[@name='industrialSectorRd']"/>
							</xsl:element>
							<xsl:element name="address_additional_text">
								<xsl:value-of select="request-param[@name='additionalText']"/>
							</xsl:element>                                                                                                                                                                                                                                
							<xsl:element name="street_name">
								<xsl:value-of select="request-param[@name='streetName']"/>
							</xsl:element>
							<xsl:element name="street_number">
								<xsl:value-of select="request-param[@name='streetNumber']"/>
							</xsl:element>
							<xsl:element name="street_number_suffix">
								<xsl:value-of select="request-param[@name='numberSuffix']"/>
							</xsl:element>
							<xsl:element name="post_office_box">
								<xsl:value-of select="request-param[@name='postOfficeBox']"/>
							</xsl:element>
							<xsl:element name="postal_code">
								<xsl:value-of select="request-param[@name='postalCode']"/>
							</xsl:element>
							<xsl:element name="city_name">
								<xsl:value-of select="request-param[@name='city']"/>
							</xsl:element>
							<xsl:element name="city_suffix">
								<xsl:value-of select="request-param[@name='citySuffix']"/>
							</xsl:element>
							<xsl:element name="country">DE</xsl:element>
						</xsl:element>					
						<!-- Artikelnumber -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0101</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="request-param[@name='directoryEntryType']"/>
							</xsl:element>
						</xsl:element>
						<!-- Inverssuche -->
						<xsl:element name="CcmFifConfiguredValueCont">
							<xsl:element name="service_char_code">V0148</xsl:element>
							<xsl:element name="data_type">STRING</xsl:element>
							<xsl:element name="configured_value">
								<xsl:value-of select="$inverseSearchIndicator"/>
							</xsl:element>
						</xsl:element>						
					</xsl:element>
					<xsl:element name="detailed_reason_ref">
                      <xsl:element name="command_id">read_external_notification_3</xsl:element>
                      <xsl:element name="field_name">parameter_value</xsl:element>
                    </xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Customer Order for new service  -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="cust_order_description">Add Directory Entry</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
					</xsl:element>
					<xsl:element name="lan_path_file_string">
						<xsl:value-of select="request-param[@name='lanPathFileString']"/>
					</xsl:element>
					<xsl:element name="sales_rep_dept">
						<xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
					</xsl:element>
					<xsl:if test="request-param[@name='providerTrackingNumber']!=''">
						<xsl:element name="provider_tracking_no">
							<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='providerTrackingNumber']=''">
						<xsl:element name="provider_tracking_no">003t</xsl:element>	
					</xsl:if>
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
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_service_1</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>	
			<!-- Release delayed CO  populated -->                   
				<xsl:element name="CcmFifReleaseCustOrderCmd">
					<xsl:element name="CcmFifReleaseCustOrderInCont">
						<xsl:element name="customer_number">
							<xsl:value-of select="request-param[@name='customerNumber']"/>
						</xsl:element>
						<xsl:element name="customer_order_ref">
							<xsl:element name="command_id">create_co_1</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>
						</xsl:element>
						<xsl:element name="parent_customer_order_id_ref">
							<xsl:element name="command_id">find_customer_order_1</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>          	
						</xsl:element>
					</xsl:element>
				</xsl:element>

			<!-- Create Contact for Directory Entry -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number">
						<xsl:value-of select="request-param[@name='customerNumber']"/>
					</xsl:element>
					<xsl:element name="contact_type_rd">TELBUCH</xsl:element>
					<xsl:element name="short_description">
						<xsl:text>Directory entry created </xsl:text>
						<xsl:value-of select="request-param[@name='clientName']"/>
					</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>Transaction ID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
						<xsl:if test="(request-param[@name='userName'] != '')">
							<xsl:text>&#xA;UserName: </xsl:text>
							<xsl:value-of select="request-param[@name='userName']"/>
						</xsl:if>
						<xsl:text>&#xA;</xsl:text>
						<xsl:if test="(request-param[@name='desiredDate'] != '')">
							<xsl:variable name="Contact1" select="request-param[@name='desiredDate']"/>
							<xsl:value-of select="concat('Der Telephonbucheintrag wurde am ',$Contact1,' angelegt')"/>
						</xsl:if>						 
						<xsl:if test="(request-param[@name='desiredDate'] = '')">
							<xsl:variable name="Contact1" select="$today"/>
							<xsl:value-of select="concat('Der Telephonbucheintrag wurde am ',$Contact1,' angelegt')"/>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
