<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
XSLT file for handling ONB licences and options

@author schwarje
-->
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
xmlns:xalan="http://xml.apache.org/xalan"
exclude-result-prefixes="dateutils">
	<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
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
		
			<!-- Calculate today and one day before the desired date -->
			<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
			
			<xsl:variable name="desiredDate">
				<xsl:choose>
					<xsl:when test="request-param[@name='desiredDate'] = '' or
							request-param[@name='desiredDate'] = 'today' or
							request-param[@name='processingStatus'] = 'completedOPM'">
						<xsl:value-of select="$today"/>
					</xsl:when>
					<xsl:when test ="dateutils:compareString(request-param[@name='desiredDate'], $today) = '-1'">
						<xsl:value-of select="$today"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='desiredDate']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="processingStatus">
				<xsl:choose>
					<xsl:when test ="dateutils:compareString($desiredDate, $today) = '0'">
						<xsl:text>completedOPM</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='processingStatus']"/>
					</xsl:otherwise>
				</xsl:choose>			
			</xsl:variable>
			
			<xsl:variable name="terminationDate" >
				<xsl:choose>          
					<xsl:when test="request-param[@name='synchronizeTermination'] = 'Y'">
						<xsl:value-of select="$desiredDate"/>
					</xsl:when>          
					<xsl:when test="$processingStatus = ''">
						<xsl:value-of select="dateutils:createFIFDateOffset($desiredDate, 'DATE', '-1')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$today"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="reason">
				<xsl:choose>
					<xsl:when test="$processingStatus = 'completedOPM'">COM_BW_CHANGE</xsl:when>
					<xsl:otherwise>MODIFY_FEATURES</xsl:otherwise>
				</xsl:choose>						
			</xsl:variable>
			
			<xsl:variable name="skipCheckForOpenTermination" >
				<xsl:value-of select="request-param[@name='skipCheckForOpenTermination']"/>
			</xsl:variable>
			
			<xsl:variable name="serviceSubscriptionId">
				<xsl:choose>
					<xsl:when test="request-param[@name='useAlternativeFunction'] = 'Y'">
						<xsl:value-of select="request-param[@name='alternativeServiceSubscriptionId']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
					</xsl:otherwise>
				</xsl:choose>       
			</xsl:variable>
			
			<xsl:variable name="functionID">
				<xsl:choose>
					<xsl:when test="request-param[@name='useAlternativeFunction'] = 'Y'">
						<xsl:value-of select="request-param[@name='alternativeFunctionID']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='functionID']"/>
					</xsl:otherwise>
				</xsl:choose>               
			</xsl:variable>
			
			<xsl:variable name="requestListId">
				<xsl:value-of select="request-param[@name='requestListId']"/>
			</xsl:variable>
			
			<xsl:element name="CcmFifReadExternalNotificationCmd">
				<xsl:element name="command_id">read_customer_order</xsl:element>
				<xsl:element name="CcmFifReadExternalNotificationInCont">
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="parameter_name">
						<xsl:value-of select="$functionID"/>
						<xsl:if test="$processingStatus = ''">
							<xsl:text>_OP</xsl:text>
						</xsl:if>
						<xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
					</xsl:element>
					<xsl:element name="ignore_empty_result">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="CcmFifReadExternalNotificationCmd">
				<xsl:element name="command_id">read_detailed_reason</xsl:element>
				<xsl:element name="CcmFifReadExternalNotificationInCont">
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="parameter_name">
						<xsl:value-of select="$functionID"/>
						<xsl:text>_DETAILED_REASON_RD</xsl:text>
					</xsl:element>
					<xsl:element name="ignore_empty_result">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_main_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:element name="service_subscription_id">
						<xsl:value-of select="$serviceSubscriptionId"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- loop through the configured list and
					- create, if no service exists and quantity > 0 
					- reconfigure, if service exists and quantity > 0 and different from old quantity 
					- terminate, if service exists and quantity = 0 -->
			<xsl:for-each select="request-param-list[@name='configuredServiceList']/request-param-list-item">
									
				<!-- look for open STP for the respective service in state ASSIGNED or UNASSIGNED -->
				<xsl:element name="CcmFifFindServiceTicketPositionCmd">
					<xsl:element name="command_id">
						<xsl:text>find_open_stp_</xsl:text>
						<xsl:value-of select="request-param[@name='serviceCode']"/>
					</xsl:element>
					<xsl:element name="CcmFifFindServiceTicketPositionInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="parent_service_subs_id">
							<xsl:value-of select="$serviceSubscriptionId"/>
						</xsl:element>
						<xsl:element name="no_stp_error">N</xsl:element>
						<xsl:element name="find_stp_parameters">
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">
									<xsl:value-of select="request-param[@name='serviceCode']"/>
								</xsl:element>
								<xsl:element name="service_ticket_position_state">UNASSIGNED</xsl:element>                                            
							</xsl:element>
							<xsl:element name="CcmFifFindStpParameterCont">
								<xsl:element name="service_code">
									<xsl:value-of select="request-param[@name='serviceCode']"/>
								</xsl:element>
								<xsl:element name="service_ticket_position_state">ASSIGNED</xsl:element>                                            
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<!-- cancel the ASSIGNED or UNASSIGNED STP -->
				<xsl:element name="CcmFifCancelServiceTicketPositionCmd">
					<xsl:element name="command_id">cancel_open_stp</xsl:element>
					<xsl:element name="CcmFifCancelServiceTicketPositionInCont">
						<xsl:element name="service_ticket_position_id_ref">
							<xsl:element name="command_id">
								<xsl:text>find_open_stp_</xsl:text>
								<xsl:value-of select="request-param[@name='serviceCode']"/>
							</xsl:element>
							<xsl:element name="field_name">service_ticket_position_id</xsl:element>          	
						</xsl:element>
						<xsl:element name="cancel_reason_rd">CUST_REQUEST</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">
								<xsl:text>find_open_stp_</xsl:text>
								<xsl:value-of select="request-param[@name='serviceCode']"/>
							</xsl:element>
							<xsl:element name="field_name">stp_found</xsl:element>          	
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>            
					</xsl:element>
				</xsl:element>              
				
				<!-- raise an error, if there's still an open termination -->
				<xsl:if test="$skipCheckForOpenTermination != 'Y'">
					<xsl:element name="CcmFifFindServiceTicketPositionCmd">
						<xsl:element name="command_id">
							<xsl:text>find_terminate_stp_</xsl:text>
							<xsl:value-of select="request-param[@name='serviceCode']"/>
						</xsl:element>
						<xsl:element name="CcmFifFindServiceTicketPositionInCont">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
							<xsl:element name="parent_service_subs_id">
								<xsl:value-of select="$serviceSubscriptionId"/>
							</xsl:element>
							<xsl:element name="no_stp_error">N</xsl:element>
							<xsl:element name="find_stp_parameters">
								<xsl:element name="CcmFifFindStpParameterCont">
									<xsl:element name="service_code">
										<xsl:value-of select="request-param[@name='serviceCode']"/>
									</xsl:element>
									<xsl:element name="usage_mode_value_rd">4</xsl:element>
									<xsl:element name="customer_order_state">RELEASED</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					
					<xsl:element name="CcmFifRaiseErrorCmd">
						<xsl:element name="command_id">termination_stp_exists</xsl:element>
						<xsl:element name="CcmFifRaiseErrorInCont">
							<xsl:element name="error_text">
								<xsl:text>Offene Kuendigung besteht bereits für Dienst </xsl:text>
								<xsl:value-of select="request-param[@name='serviceCode']"/>
								<xsl:text>. Bitte vor erneuter Verarbeitung stornieren.</xsl:text>
							</xsl:element>
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">
									<xsl:text>find_terminate_stp_</xsl:text>
									<xsl:value-of select="request-param[@name='serviceCode']"/>
								</xsl:element>
								<xsl:element name="field_name">stp_found</xsl:element>
							</xsl:element>
							<xsl:element name="required_process_ind">Y</xsl:element>                  
						</xsl:element>
					</xsl:element>                                      
				</xsl:if>
				
				<!-- read SS for current serviceCode -->					
				<xsl:element name="CcmFifFindServiceSubsCmd">
					<xsl:element name="command_id">
						<xsl:text>find_onb_service_</xsl:text>
						<xsl:value-of select="request-param[@name='serviceCode']"/>
					</xsl:element>
					<xsl:element name="CcmFifFindServiceSubsInCont">
						<xsl:element name="product_subscription_id_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">product_subscription_id</xsl:element>
						</xsl:element>
						<xsl:element name="service_code">
							<xsl:value-of select="request-param[@name='serviceCode']"/>            
						</xsl:element>
						<xsl:element name="no_service_error">N</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<xsl:choose>
					<xsl:when test="request-param[@name='quantity'] > 0">
					
						<!-- Add Feature Service -->
						<xsl:element name="CcmFifAddServiceSubsCmd">
							<xsl:element name="command_id">
								<xsl:text>add_</xsl:text>
								<xsl:value-of select="request-param[@name='serviceCode']"/>
							</xsl:element>
							<xsl:element name="CcmFifAddServiceSubsInCont">
								<xsl:element name="product_subscription_ref">
									<xsl:element name="command_id">find_main_service</xsl:element>
									<xsl:element name="field_name">product_subscription_id</xsl:element>
								</xsl:element>
								<xsl:element name="service_code">
									<xsl:value-of select="request-param[@name='serviceCode']"/>
								</xsl:element>
								<xsl:element name="sales_organisation_number">
									<xsl:value-of select="../../request-param[@name='salesOrganisationNumber']"/>
								</xsl:element>
								<xsl:element name="sales_organisation_number_vf">
									<xsl:value-of select="../../request-param[@name='salesOrganisationNumberVF']"/>
								</xsl:element>
								<xsl:element name="parent_service_subs_ref">
									<xsl:element name="command_id">find_main_service</xsl:element>
									<xsl:element name="field_name">service_subscription_id</xsl:element>
								</xsl:element>
								<xsl:element name="desired_date">
									<xsl:value-of select="$desiredDate"/>
								</xsl:element>
								<xsl:element name="desired_schedule_type">
									<xsl:choose>
										<xsl:when test="$desiredDate = $today">ASAP</xsl:when>
										<xsl:otherwise>START_AFTER</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
								<xsl:element name="reason_rd">
									<xsl:value-of select="$reason"/>
								</xsl:element>
								<xsl:element name="account_number_ref">
									<xsl:element name="command_id">find_main_service</xsl:element>
									<xsl:element name="field_name">account_number</xsl:element>
								</xsl:element>
								<xsl:element name="use_current_pc_version">Y</xsl:element>
								<xsl:element name="ignore_wrong_service_code">N</xsl:element>
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">
										<xsl:text>find_onb_service_</xsl:text>
										<xsl:value-of select="request-param[@name='serviceCode']"/>
									</xsl:element>
									<xsl:element name="field_name">service_found</xsl:element>          	
								</xsl:element>
								<xsl:element name="required_process_ind">N</xsl:element>            
								<xsl:element name="service_characteristic_list">
									<xsl:choose>
										<xsl:when test="../../request-param[@name='listType'] = 'licencesList'">
											<!-- Anzahl UC_Licence -->
											<xsl:element name="CcmFifConfiguredValueCont">
												<xsl:element name="service_char_code">VI113</xsl:element>
												<xsl:element name="data_type">INTEGER</xsl:element>
												<xsl:element name="configured_value">
													<xsl:value-of select="request-param[@name='quantity']"/>
												</xsl:element>
											</xsl:element>                                  		
										</xsl:when>
										<xsl:when test="../../request-param[@name='listType'] = 'licenceOptionsList'">
											<!-- Anzahl UC_Option -->
											<xsl:element name="CcmFifConfiguredValueCont">
												<xsl:element name="service_char_code">VI114</xsl:element>
												<xsl:element name="data_type">INTEGER</xsl:element>
												<xsl:element name="configured_value">
													<xsl:value-of select="request-param[@name='quantity']"/>
												</xsl:element>
											</xsl:element>                                  		              		
										</xsl:when>
										<xsl:otherwise>listType not supported</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
								<xsl:element name="sub_order_id">
									<xsl:value-of select="../../request-param[@name='subOrderId']"/>
								</xsl:element>
								<xsl:choose>
									<xsl:when test="../../request-param[@name='detailedReason'] != ''">
										<xsl:element name="detailed_reason">
											<xsl:value-of select="../../request-param[@name='detailedReason']"/>
										</xsl:element>
									</xsl:when>
									<xsl:otherwise>
										<xsl:element name="detailed_reason_ref">
											<xsl:element name="command_id">read_detailed_reason</xsl:element>
											<xsl:element name="field_name">parameter_value</xsl:element>
										</xsl:element>									
									</xsl:otherwise>
								</xsl:choose>
								<xsl:element name="provider_tracking_no">
									<xsl:value-of select="../../request-param[@name='providerTrackingNumber']"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					
						<xsl:variable name="currentServiceCode">
							<xsl:value-of select="request-param[@name='serviceCode']"/>
						</xsl:variable>
					
						<xsl:if test="
							request-param[@name='quantity'] !=
							../../request-param-list[@name='existingServiceList']/request-param-list-item[
							request-param[@name='serviceCode'] = $currentServiceCode]/request-param[@name='quantity']">
						
							<xsl:element name="CcmFifReconfigServiceCmd">
								<xsl:element name="command_id">
									<xsl:text>reconfigure_</xsl:text>
									<xsl:value-of select="request-param[@name='serviceCode']"/>
								</xsl:element>
								<xsl:element name="CcmFifReconfigServiceInCont">
									<xsl:element name="service_subscription_ref">
										<xsl:element name="command_id">
											<xsl:text>find_onb_service_</xsl:text>
											<xsl:value-of select="request-param[@name='serviceCode']"/>
										</xsl:element>
										<xsl:element name="field_name">service_subscription_id</xsl:element>
									</xsl:element>
									<xsl:element name="desired_date">
										<xsl:value-of select="$desiredDate"/>
									</xsl:element>
									<xsl:element name="desired_schedule_type">
										<xsl:choose>
											<xsl:when test="$desiredDate = $today">ASAP</xsl:when>
											<xsl:otherwise>START_AFTER</xsl:otherwise>
										</xsl:choose>
									</xsl:element>
									<xsl:element name="reason_rd">
										<xsl:value-of select="$reason"/>
									</xsl:element>
									<xsl:element name="service_characteristic_list">
										<xsl:choose>
											<xsl:when test="../../request-param[@name='listType'] = 'licencesList'">
												<!-- Anzahl UC_Licence -->
												<xsl:element name="CcmFifConfiguredValueCont">
													<xsl:element name="service_char_code">VI113</xsl:element>
													<xsl:element name="data_type">INTEGER</xsl:element>
													<xsl:element name="configured_value">
														<xsl:value-of select="request-param[@name='quantity']"/>
													</xsl:element>
												</xsl:element>                                  		
											</xsl:when>
											<xsl:when test="../../request-param[@name='listType'] = 'licenceOptionsList'">
												<!-- Anzahl UC_Option -->
												<xsl:element name="CcmFifConfiguredValueCont">
													<xsl:element name="service_char_code">VI114</xsl:element>
													<xsl:element name="data_type">INTEGER</xsl:element>
													<xsl:element name="configured_value">
														<xsl:value-of select="request-param[@name='quantity']"/>
													</xsl:element>
												</xsl:element>                                  		              		
											</xsl:when>
											<xsl:otherwise>listType not supported</xsl:otherwise>
										</xsl:choose>
									</xsl:element>
									<xsl:element name="process_ind_ref">
										<xsl:element name="command_id">
											<xsl:text>find_onb_service_</xsl:text>
											<xsl:value-of select="request-param[@name='serviceCode']"/>
										</xsl:element>
										<xsl:element name="field_name">service_found</xsl:element>          	
									</xsl:element>
									<xsl:element name="required_process_ind">Y</xsl:element>            
									<xsl:choose>
										<xsl:when test="../../request-param[@name='detailedReason'] != ''">
											<xsl:element name="detailed_reason">
												<xsl:value-of select="../../request-param[@name='detailedReason']"/>
											</xsl:element>
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="detailed_reason_ref">
												<xsl:element name="command_id">read_detailed_reason</xsl:element>
												<xsl:element name="field_name">parameter_value</xsl:element>
											</xsl:element>									
										</xsl:otherwise>
									</xsl:choose>
									<xsl:element name="provider_tracking_no">
										<xsl:value-of select="../../request-param[@name='providerTrackingNumber']"/>
									</xsl:element>
									<xsl:if test="$processingStatus = 'completedOPM'">
										<xsl:element name="allow_stp_modification">Y</xsl:element>
									</xsl:if>
								</xsl:element>
							</xsl:element>
						</xsl:if>
					
					</xsl:when>
				
					<xsl:when test="request-param[@name='quantity'] = 0">
					
						<!-- Terminate serviceSubscription -->
						<xsl:element name="CcmFifTermSuspReactServiceSubsCmd">
								<xsl:element name="command_id">
									<xsl:text>terminate_</xsl:text>
									<xsl:value-of select="request-param[@name='serviceCode']"/>
								</xsl:element>
							<xsl:element name="CcmFifTermSuspReactServiceSubsInCont">
								<xsl:element name="service_subscription_ref">
									<xsl:element name="command_id">
										<xsl:text>find_onb_service_</xsl:text>
										<xsl:value-of select="request-param[@name='serviceCode']"/>
									</xsl:element>
									<xsl:element name="field_name">service_subscription_id</xsl:element>
								</xsl:element>
								<xsl:element name="usage_mode">4</xsl:element>
								<xsl:element name="desired_date">
									<xsl:value-of select="$terminationDate"/>
								</xsl:element>
								<xsl:element name="desired_schedule_type">
									<xsl:choose>
										<xsl:when test="$terminationDate = $today">ASAP</xsl:when>
										<xsl:otherwise>START_AFTER</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
								<xsl:element name="reason_rd">
									<xsl:value-of select="$reason"/>
								</xsl:element>
								<xsl:element name="provider_tracking_no">
									<xsl:value-of select="../../request-param[@name='providerTrackingNumber']"/>
								</xsl:element>
								<xsl:element name="process_ind_ref">
									<xsl:element name="command_id">
										<xsl:text>find_onb_service_</xsl:text>
										<xsl:value-of select="request-param[@name='serviceCode']"/>
									</xsl:element>
									<xsl:element name="field_name">service_found</xsl:element>          	
								</xsl:element>
								<xsl:element name="required_process_ind">Y</xsl:element>            
							</xsl:element>
						</xsl:element>                        
					
					
					</xsl:when>
				</xsl:choose>
				
			</xsl:for-each>
			
			<xsl:if test="request-param[@name='listType'] = 'licencesList' 
					and request-param[@name='addSetupFee'] = 'Y'
					and count(request-param-list[@name='configuredServiceList']/request-param-list-item) > 0">
				
				<xsl:variable name="itemList">
					<xsl:for-each select="request-param-list[@name='configuredServiceList']/request-param-list-item">
						<xsl:variable name="serviceCode">
							<xsl:value-of select="request-param[@name='serviceCode']"/>
						</xsl:variable>
						<xsl:element name="item">
							<xsl:element name="serviceCode">
								<xsl:value-of select="request-param[@name='serviceCode']"/>
							</xsl:element>
							<xsl:element name="newQuantity">
								<xsl:value-of select="request-param[@name='quantity']"/>
							</xsl:element>
							<xsl:element name="oldQuantity">
								<xsl:choose>
									<xsl:when test="count(../../request-param-list[@name='existingServiceList']/request-param-list-item[request-param[@name='serviceCode'] = $serviceCode]) > 0">
										<xsl:value-of select="../../request-param-list[@name='existingServiceList']/request-param-list-item[request-param[@name='serviceCode'] = $serviceCode]/request-param[@name='quantity']"/>
									</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>								
							</xsl:element>
							<xsl:element name="difference">
								<xsl:value-of select="
									request-param[@name='quantity'] - 
									../../request-param-list[@name='existingServiceList']/request-param-list-item[request-param[@name='serviceCode'] = $serviceCode]/request-param[@name='quantity']"/>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
				</xsl:variable>

				<xsl:variable name="upscaledQuantity">
					<xsl:value-of select="sum(xalan:nodeset($itemList)/item/newQuantity) - sum(xalan:nodeset($itemList)/item/oldQuantity)"/>
				</xsl:variable>
				<xsl:variable name="upgradedQuantity"> 
					<xsl:value-of select="sum(xalan:nodeset($itemList)/item[difference > 0]/difference)"/>
				</xsl:variable>
				
				<xsl:if test="$upscaledQuantity > 0 or $upscaledQuantity = 0 and $upgradedQuantity > 0">
					<!-- Add service for setup fee -->
					<xsl:element name="CcmFifAddServiceSubsCmd">
						<xsl:element name="command_id">add_setup_fee</xsl:element>
						<xsl:element name="CcmFifAddServiceSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="service_code">VI034</xsl:element>
							<xsl:element name="sales_organisation_number">
								<xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
							</xsl:element>
							<xsl:element name="sales_organisation_number_vf">
								<xsl:value-of select="request-param[@name='salesOrganisationNumberVF']"/>
							</xsl:element>
							<xsl:element name="parent_service_subs_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="desired_date">
								<xsl:value-of select="$desiredDate"/>
							</xsl:element>
							<xsl:element name="desired_schedule_type">
								<xsl:choose>
									<xsl:when test="$desiredDate = $today">ASAP</xsl:when>
									<xsl:otherwise>START_AFTER</xsl:otherwise>
								</xsl:choose>
							</xsl:element>
							<xsl:element name="reason_rd">
								<xsl:value-of select="$reason"/>
							</xsl:element>
							<xsl:element name="account_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">account_number</xsl:element>
							</xsl:element>
							<xsl:element name="use_current_pc_version">Y</xsl:element>
							<xsl:element name="ignore_wrong_service_code">N</xsl:element>
							<xsl:element name="service_characteristic_list">
								<!-- Anzahl -->
								<xsl:element name="CcmFifConfiguredValueCont">
									<xsl:element name="service_char_code">VI115</xsl:element>
									<xsl:element name="data_type">INTEGER</xsl:element>
									<xsl:element name="configured_value">
										<xsl:choose>
											<xsl:when test="$upscaledQuantity > 0">
												<xsl:value-of select="$upscaledQuantity"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$upgradedQuantity"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:element>
								</xsl:element>                                  		
							</xsl:element>
							<xsl:element name="sub_order_id">
								<xsl:value-of select="request-param[@name='subOrderId']"/>
							</xsl:element>
							<xsl:choose>
								<xsl:when test="request-param[@name='detailedReason'] != ''">
									<xsl:element name="detailed_reason">
										<xsl:value-of select="request-param[@name='detailedReason']"/>
									</xsl:element>
								</xsl:when>
								<xsl:otherwise>
									<xsl:element name="detailed_reason_ref">
										<xsl:element name="command_id">read_detailed_reason</xsl:element>
										<xsl:element name="field_name">parameter_value</xsl:element>
									</xsl:element>									
								</xsl:otherwise>
							</xsl:choose>
							<xsl:element name="provider_tracking_no">
								<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
			</xsl:if>
						
			<xsl:if test="count(request-param-list[@name='configuredServiceList']/request-param-list-item) = 0
					and request-param[@name='isMovedService'] = 'Y'
					and request-param[@name='action'] != 'remove'">
				<xsl:for-each select="request-param-list[@name='existingServiceList']/request-param-list-item">

					<xsl:if test="request-param[@name='quantity'] > 0">
					
						<!-- Add licence / option service -->
						<xsl:element name="CcmFifAddServiceSubsCmd">
							<xsl:element name="command_id">
								<xsl:text>add_</xsl:text>
								<xsl:value-of select="request-param[@name='serviceCode']"/>
							</xsl:element>
							<xsl:element name="CcmFifAddServiceSubsInCont">
								<xsl:element name="product_subscription_ref">
									<xsl:element name="command_id">find_main_service</xsl:element>
									<xsl:element name="field_name">product_subscription_id</xsl:element>
								</xsl:element>
								<xsl:element name="service_code">
									<xsl:value-of select="request-param[@name='serviceCode']"/>
								</xsl:element>
								<xsl:element name="sales_organisation_number">
									<xsl:value-of select="../../request-param[@name='salesOrganisationNumber']"/>
								</xsl:element>
								<xsl:element name="sales_organisation_number_vf">
									<xsl:value-of select="../../request-param[@name='salesOrganisationNumberVF']"/>
								</xsl:element>
								<xsl:element name="parent_service_subs_ref">
									<xsl:element name="command_id">find_main_service</xsl:element>
									<xsl:element name="field_name">service_subscription_id</xsl:element>
								</xsl:element>
								<xsl:element name="desired_date">
									<xsl:value-of select="$desiredDate"/>
								</xsl:element>
								<xsl:element name="desired_schedule_type">
									<xsl:choose>
										<xsl:when test="$desiredDate = $today">ASAP</xsl:when>
										<xsl:otherwise>START_AFTER</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
								<xsl:element name="reason_rd">
									<xsl:value-of select="$reason"/>
								</xsl:element>
								<xsl:element name="account_number_ref">
									<xsl:element name="command_id">find_main_service</xsl:element>
									<xsl:element name="field_name">account_number</xsl:element>
								</xsl:element>
								<xsl:element name="use_current_pc_version">Y</xsl:element>
								<xsl:element name="ignore_wrong_service_code">N</xsl:element>
								<xsl:element name="service_characteristic_list">
									<xsl:choose>
										<xsl:when test="../../request-param[@name='listType'] = 'licencesList'">
											<!-- Anzahl UC_Licence -->
											<xsl:element name="CcmFifConfiguredValueCont">
												<xsl:element name="service_char_code">VI113</xsl:element>
												<xsl:element name="data_type">INTEGER</xsl:element>
												<xsl:element name="configured_value">
													<xsl:value-of select="request-param[@name='quantity']"/>
												</xsl:element>
											</xsl:element>                                  		
										</xsl:when>
										<xsl:when test="../../request-param[@name='listType'] = 'licenceOptionsList'">
											<!-- Anzahl UC_Option -->
											<xsl:element name="CcmFifConfiguredValueCont">
												<xsl:element name="service_char_code">VI114</xsl:element>
												<xsl:element name="data_type">INTEGER</xsl:element>
												<xsl:element name="configured_value">
													<xsl:value-of select="request-param[@name='quantity']"/>
												</xsl:element>
											</xsl:element>                                  		              		
										</xsl:when>
										<xsl:otherwise>listType not supported</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
								<xsl:element name="sub_order_id">
									<xsl:value-of select="../../request-param[@name='subOrderId']"/>
								</xsl:element>
								<xsl:choose>
									<xsl:when test="../../request-param[@name='detailedReason'] != ''">
										<xsl:element name="detailed_reason">
											<xsl:value-of select="../../request-param[@name='detailedReason']"/>
										</xsl:element>
									</xsl:when>
									<xsl:otherwise>
										<xsl:element name="detailed_reason_ref">
											<xsl:element name="command_id">read_detailed_reason</xsl:element>
											<xsl:element name="field_name">parameter_value</xsl:element>
										</xsl:element>									
									</xsl:otherwise>
								</xsl:choose>
								<xsl:element name="provider_tracking_no">
									<xsl:value-of select="../../request-param[@name='providerTrackingNumber']"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
			
					</xsl:if>
			
				</xsl:for-each>
			</xsl:if>
			
			<!-- Add STPs to subscribe customer order if exists -->
			<xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
				<xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
					<xsl:element name="customer_order_id_ref">
						<xsl:element name="command_id">read_customer_order</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_setup_fee</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:for-each select="request-param-list[@name='configuredServiceList']/request-param-list-item">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">
									<xsl:text>reconfigure_</xsl:text>
									<xsl:value-of select="request-param[@name='serviceCode']"/>
								</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:for-each>
						<xsl:for-each select="request-param-list[@name='configuredServiceList']/request-param-list-item">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">
									<xsl:text>add_</xsl:text>
									<xsl:value-of select="request-param[@name='serviceCode']"/>
								</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:for-each>
						<xsl:if test="count(request-param-list[@name='configuredServiceList']/request-param-list-item) = 0">
							<xsl:for-each select="request-param-list[@name='existingServiceList']/request-param-list-item">
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">
										<xsl:text>add_</xsl:text>
										<xsl:value-of select="request-param[@name='serviceCode']"/>
									</xsl:element>
									<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
								</xsl:element>
							</xsl:for-each>
						</xsl:if>
						<xsl:if test="$desiredDate = $terminationDate">
							<xsl:for-each select="request-param-list[@name='configuredServiceList']/request-param-list-item">
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">
										<xsl:text>terminate_</xsl:text>
										<xsl:value-of select="request-param[@name='serviceCode']"/>
									</xsl:element>
									<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
								</xsl:element>
							</xsl:for-each>
						</xsl:if>
					</xsl:element>
					<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
					<xsl:element name="processing_status">
						<xsl:value-of select="$processingStatus"/>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">read_customer_order</xsl:element>
						<xsl:element name="field_name">value_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<!-- Create Customer Order if neither reconfigure or subscribe customer orders not exist -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_co_1</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="cust_order_description">Featureänderung</xsl:element>
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
					<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
					<xsl:element name="scan_date">
						<xsl:value-of select="request-param[@name='scanDate']"/>
					</xsl:element>
					<xsl:element name="order_entry_date">
						<xsl:value-of select="request-param[@name='entryDate']"/>
					</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_setup_fee</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
						<xsl:for-each select="request-param-list[@name='configuredServiceList']/request-param-list-item">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">
									<xsl:text>reconfigure_</xsl:text>
									<xsl:value-of select="request-param[@name='serviceCode']"/>
								</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:for-each>
						<xsl:for-each select="request-param-list[@name='configuredServiceList']/request-param-list-item">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">
									<xsl:text>add_</xsl:text>
									<xsl:value-of select="request-param[@name='serviceCode']"/>
								</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:for-each>
						<xsl:if test="count(request-param-list[@name='configuredServiceList']/request-param-list-item) = 0">
							<xsl:for-each select="request-param-list[@name='existingServiceList']/request-param-list-item">
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">
										<xsl:text>add_</xsl:text>
										<xsl:value-of select="request-param[@name='serviceCode']"/>
									</xsl:element>
									<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
								</xsl:element>
							</xsl:for-each>
						</xsl:if>
						<xsl:if test="$desiredDate = $terminationDate">
							<xsl:for-each select="request-param-list[@name='configuredServiceList']/request-param-list-item">
								<xsl:element name="CcmFifCommandRefCont">
									<xsl:element name="command_id">
										<xsl:text>terminate_</xsl:text>
										<xsl:value-of select="request-param[@name='serviceCode']"/>
									</xsl:element>
									<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
								</xsl:element>
							</xsl:for-each>
						</xsl:if>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">read_customer_order</xsl:element>
						<xsl:element name="field_name">value_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">N</xsl:element>
					<xsl:element name="e_shop_id">
						<xsl:value-of select="request-param[@name='eShopID']"/>
					</xsl:element>
					<xsl:element name="processing_status">
						<xsl:value-of select="$processingStatus"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:if test="$processingStatus = ''">
			
				<!-- release only for OP scenarios -->
				<xsl:element name="CcmFifReleaseCustOrderCmd">
					<xsl:element name="CcmFifReleaseCustOrderInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="customer_order_ref">
							<xsl:element name="command_id">create_co_1</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">create_co_1</xsl:element>
							<xsl:element name="field_name">customer_order_created</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>
					</xsl:element>
				</xsl:element>
			
				<xsl:if test="$desiredDate != $terminationDate">
					<xsl:element name="CcmFifReadExternalNotificationCmd">
						<xsl:element name="command_id">read_term_customer_order</xsl:element>
						<xsl:element name="CcmFifReadExternalNotificationInCont">
							<xsl:element name="transaction_id">
								<xsl:value-of select="request-param[@name='requestListId']"/>
							</xsl:element>
							<xsl:element name="parameter_name">
								<xsl:value-of select="$functionID"/>
								<xsl:if test="request-param[@name='workflowType'] = 'COM-OPM-FIF'
										and $processingStatus = ''">
									<xsl:text>_OP</xsl:text>
								</xsl:if>
								<xsl:if test="request-param[@name='useOneCustomerOrder'] != 'Y'">_TERM</xsl:if>
								<xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
							</xsl:element>
							<xsl:element name="ignore_empty_result">Y</xsl:element>
						</xsl:element>
					</xsl:element>
					
					<!-- Add STPs to subscribe customer order if exists -->
					<xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
						<xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
							<xsl:element name="customer_order_id_ref">
								<xsl:element name="command_id">read_term_customer_order</xsl:element>
								<xsl:element name="field_name">parameter_value</xsl:element>
							</xsl:element>
							<xsl:element name="service_ticket_pos_list">
								<xsl:for-each select="request-param-list[@name='existingServiceList']/request-param-list-item">
									<xsl:element name="CcmFifCommandRefCont">
										<xsl:element name="command_id">
											<xsl:text>terminate_</xsl:text>
											<xsl:value-of select="request-param[@name='serviceCode']"/>
										</xsl:element>
										<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
									</xsl:element>
								</xsl:for-each>
							</xsl:element>
							<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
							<xsl:element name="processing_status">
								<xsl:value-of select="$processingStatus"/>
							</xsl:element>
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">read_term_customer_order</xsl:element>
								<xsl:element name="field_name">value_found</xsl:element>
							</xsl:element>
							<xsl:element name="required_process_ind">Y</xsl:element>
						</xsl:element>
					</xsl:element>
					
					<!-- Create a 2nd customer order for the terminations in  scenario with OP products -->
					<xsl:element name="CcmFifCreateCustOrderCmd">
						<xsl:element name="command_id">create_co_2</xsl:element>
						<xsl:element name="CcmFifCreateCustOrderInCont">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
							<xsl:element name="cust_order_description">Featureänderung</xsl:element>
							<xsl:element name="customer_tracking_id">
								<xsl:value-of select="request-param[@name='OMTSOrderID']"/>
							</xsl:element>
							<xsl:element name="lan_path_file_string">
								<xsl:value-of select="request-param[@name='lanPathFileString']"/>
							</xsl:element>
							<xsl:element name="sales_rep_dept">
								<xsl:value-of select="request-param[@name='salesRepresentativeDept']"/>
							</xsl:element>
							<xsl:element name="super_customer_tracking_id">
								<xsl:value-of select="request-param[@name='superCustomerTrackingId']"/>
							</xsl:element>
							<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
							<xsl:element name="scan_date">
								<xsl:value-of select="request-param[@name='scanDate']"/>
							</xsl:element>
							<xsl:element name="order_entry_date">
								<xsl:value-of select="request-param[@name='entryDate']"/>
							</xsl:element>
							<xsl:element name="service_ticket_pos_list">
								<xsl:for-each select="request-param-list[@name='existingServiceList']/request-param-list-item">
									<xsl:element name="CcmFifCommandRefCont">
										<xsl:element name="command_id">
											<xsl:text>terminate_</xsl:text>
											<xsl:value-of select="request-param[@name='serviceCode']"/>
										</xsl:element>
										<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
									</xsl:element>
								</xsl:for-each>
							</xsl:element>
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">read_term_customer_order</xsl:element>
								<xsl:element name="field_name">value_found</xsl:element>
							</xsl:element>
							<xsl:element name="required_process_ind">N</xsl:element>
							<xsl:element name="e_shop_id">
							<xsl:value-of select="request-param[@name='eShopID']"/>
							</xsl:element>
							<xsl:element name="processing_status">
								<xsl:value-of select="$processingStatus"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					
					<xsl:element name="CcmFifReleaseCustOrderCmd">
						<xsl:element name="CcmFifReleaseCustOrderInCont">
							<xsl:element name="customer_number_ref">
								<xsl:element name="command_id">find_main_service</xsl:element>
								<xsl:element name="field_name">customer_number</xsl:element>
							</xsl:element>
							<xsl:element name="customer_order_ref">
								<xsl:element name="command_id">create_co_2</xsl:element>
								<xsl:element name="field_name">customer_order_id</xsl:element>
							</xsl:element>
							<xsl:element name="process_ind_ref">
								<xsl:element name="command_id">create_co_2</xsl:element>
								<xsl:element name="field_name">customer_order_created</xsl:element>
							</xsl:element>
							<xsl:element name="required_process_ind">Y</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
			</xsl:if>
			
			<!-- Create Contact for Feature Service Addition -->
			<xsl:element name="CcmFifCreateContactCmd">
				<xsl:element name="CcmFifCreateContactInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
					<xsl:element name="contact_type_rd">ADD_FEATURE_SERV</xsl:element>
					<xsl:element name="short_description">Featuredienste geändert</xsl:element>
					<xsl:element name="long_description_text">
						<xsl:text>Featuredienste geändert für Dienst </xsl:text>
						<xsl:value-of select="$serviceSubscriptionId"/>
						<xsl:text>&#xA;TransactionID: </xsl:text>
						<xsl:value-of select="request-param[@name='transactionID']"/>
						<xsl:text> (</xsl:text>
						<xsl:value-of select="request-param[@name='clientName']"/>
						<xsl:text>)</xsl:text>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">service_found</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<xsl:element name="command_id">create_notification_1</xsl:element>
				<xsl:element name="CcmFifCreateExternalNotificationInCont">
					<xsl:element name="effective_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="processed_indicator">Y</xsl:element>
					<xsl:element name="notification_action_name">
						<xsl:value-of select="//request/action-name"/>
					</xsl:element>
					<xsl:element name="target_system">FIF</xsl:element>
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">
								<xsl:value-of select="$functionID"/>
									<xsl:if test="request-param[@name='workflowType'] = 'COM-OPM-FIF'
											and $processingStatus = ''">
										<xsl:text>_OP</xsl:text>
									</xsl:if>
								<xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
							</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">create_co_1</xsl:element>
								<xsl:element name="field_name">customer_order_id</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">create_co_1</xsl:element>
						<xsl:element name="field_name">customer_order_created</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="CcmFifCreateExternalNotificationCmd">
				<xsl:element name="command_id">create_notification_2</xsl:element>
				<xsl:element name="CcmFifCreateExternalNotificationInCont">
					<xsl:element name="effective_date">
						<xsl:value-of select="$today"/>
					</xsl:element>
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="processed_indicator">Y</xsl:element>
					<xsl:element name="notification_action_name">
						<xsl:value-of select="//request/action-name"/>
					</xsl:element>
					<xsl:element name="target_system">FIF</xsl:element>
					<xsl:element name="parameter_value_list">
						<xsl:element name="CcmFifParameterValueCont">
							<xsl:element name="parameter_name">
								<xsl:value-of select="$functionID"/>
								<xsl:if test="request-param[@name='workflowType'] = 'COM-OPM-FIF'
										and $processingStatus = ''">
									<xsl:text>_OP</xsl:text>
								</xsl:if>
								<xsl:text>_TERM_CUSTOMER_ORDER_ID</xsl:text>
							</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">create_co_2</xsl:element>
								<xsl:element name="field_name">customer_order_id</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">create_co_2</xsl:element>
						<xsl:element name="field_name">customer_order_created</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:if test="
				request-param[@name='action'] = 'remove' or
				request-param[@name='isMovedService'] = 'Y' or
				count(request-param-list[@name='configuredServiceList']/request-param-list-item) > 0">
				
				<xsl:element name="CcmFifMapStringCmd">
					<xsl:element name="command_id">functionStatus</xsl:element>
					<xsl:element name="CcmFifMapStringInCont">
						<xsl:element name="input_string_type">CustomerOrderCreated</xsl:element>
						<xsl:element name="input_string_list">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">
									<xsl:choose>
										<xsl:when test="$processingStatus = 'completedOPM'">SUCCESS</xsl:when>
										<xsl:otherwise>ACKNOWLEDGED</xsl:otherwise>                  
									</xsl:choose>
									<xsl:text>;</xsl:text>
								</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">create_co_1</xsl:element>
								<xsl:element name="field_name">customer_order_created</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">;</xsl:element>							
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">create_co_2</xsl:element>
								<xsl:element name="field_name">customer_order_created</xsl:element>							
							</xsl:element>
						</xsl:element>
						<xsl:element name="output_string_type">functionStatus</xsl:element>
						<xsl:element name="string_mapping_list">
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">SUCCESS;N;N</xsl:element>
								<xsl:element name="output_string">SUCCESS</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">ACKNOWLEDGED;N;N</xsl:element>
								<xsl:element name="output_string">SUCCESS</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">SUCCESS;Y;N</xsl:element>
								<xsl:element name="output_string">SUCCESS</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">ACKNOWLEDGED;Y;N</xsl:element>
								<xsl:element name="output_string">ACKNOWLEDGED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">SUCCESS;N;Y</xsl:element>
								<xsl:element name="output_string">SUCCESS</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">ACKNOWLEDGED;N;Y</xsl:element>
								<xsl:element name="output_string">ACKNOWLEDGED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">SUCCESS;Y;Y</xsl:element>
								<xsl:element name="output_string">SUCCESS</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">ACKNOWLEDGED;Y;Y</xsl:element>
								<xsl:element name="output_string">ACKNOWLEDGED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">SUCCESS;N;</xsl:element>
								<xsl:element name="output_string">SUCCESS</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">ACKNOWLEDGED;N;</xsl:element>
								<xsl:element name="output_string">SUCCESS</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">SUCCESS;Y;</xsl:element>
								<xsl:element name="output_string">SUCCESS</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">ACKNOWLEDGED;Y;</xsl:element>
								<xsl:element name="output_string">ACKNOWLEDGED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">SUCCESS;;Y</xsl:element>
								<xsl:element name="output_string">SUCCESS</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">ACKNOWLEDGED;;Y</xsl:element>
								<xsl:element name="output_string">ACKNOWLEDGED</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">SUCCESS;;</xsl:element>
								<xsl:element name="output_string">SUCCESS</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifStringMappingCont">
								<xsl:element name="input_string">ACKNOWLEDGED;;</xsl:element>
								<xsl:element name="output_string">SUCCESS</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="no_mapping_error">N</xsl:element>
					</xsl:element>
				</xsl:element>          
				
				<xsl:element name="CcmFifConcatStringsCmd">
					<xsl:element name="command_id">functionID</xsl:element>
					<xsl:element name="CcmFifConcatStringsInCont">
						<xsl:element name="input_string_list">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">
									<xsl:value-of select="$functionID"/>
								</xsl:element>
							</xsl:element>              
						</xsl:element>
					</xsl:element>
				</xsl:element>
				
				<xsl:element name="CcmFifConcatStringsCmd">
					<xsl:element name="command_id">ccbId</xsl:element>
					<xsl:element name="CcmFifConcatStringsInCont">
						<xsl:element name="input_string_list">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="value">
									<xsl:value-of select="$serviceSubscriptionId"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			
		
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
