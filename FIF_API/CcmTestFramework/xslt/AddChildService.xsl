<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for creating a child service

  @author schwarje 
-->

<!DOCTYPE XSL [

<!ENTITY CSCMapping SYSTEM "CSCMapping.xsl">
<!ENTITY CSCMapping_FixedIPAddress SYSTEM "CSCMapping_FixedIPAddress.xsl">
<!ENTITY CSCMapping_ISDNDSL SYSTEM "CSCMapping_ISDNDSL.xsl">
<!ENTITY CSCMapping_InstantAccess SYSTEM "CSCMapping_InstantAccess.xsl">
<!ENTITY CSCMapping_ISDNP2PExtraLine SYSTEM "CSCMapping_ISDNP2PExtraLine.xsl">
<!ENTITY CSCMapping_AddressCreation SYSTEM "CSCMapping_AddressCreation.xsl">
<!ENTITY CSCMapping_MobileUsage SYSTEM "CSCMapping_MobileUsage.xsl">
<!ENTITY CSCMapping_ReferenceOrder SYSTEM "CSCMapping_ReferenceOrder.xsl">
]>

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
		
		<!-- variable for indicating that this is not a reconfiguration -->
		<xsl:variable name="isReconfiguration">N</xsl:variable>
		<xsl:variable name="accessType">N/A</xsl:variable>
		<xsl:variable name="functionType">N/A</xsl:variable>
		<xsl:variable name="serviceType">N/A</xsl:variable>
		
		<!-- Calculate today and one day before the desired date -->
		<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
		
		<xsl:variable name="desiredDate">  
			<xsl:choose>
				<xsl:when test ="request-param[@name='desiredDate'] = '' or 
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
		
		<xsl:variable name="scheduleType">
			<xsl:choose>
				<xsl:when test="$desiredDate = $today">ASAP</xsl:when>          
				<xsl:otherwise>START_AFTER</xsl:otherwise>
			</xsl:choose>                              
		</xsl:variable>
		
		<xsl:element name="Command_List">
			<xsl:if test="request-param[@name='serviceSubscriptionId'] = ''">
				<xsl:element name="CcmFifReadExternalNotificationCmd">
					<xsl:element name="command_id">read_service_subscription</xsl:element>
					<xsl:element name="CcmFifReadExternalNotificationInCont">
						<xsl:element name="transaction_id">
							<xsl:value-of select="request-param[@name='requestListId']"/>
						</xsl:element>
						<xsl:element name="parameter_name">
							<xsl:value-of select="request-param[@name='functionID']"/>
							<xsl:text>_SERVICE_SUBSCRIPTION_ID</xsl:text>
						</xsl:element>
						<xsl:element name="ignore_empty_result">N</xsl:element>
					</xsl:element>
				</xsl:element>				
			</xsl:if>
			
			<!-- service subscription ID of main service (of parent function) -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_main_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:if test="request-param[@name='serviceSubscriptionId'] != ''">
						<xsl:element name="service_subscription_id">
							<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="request-param[@name='serviceSubscriptionId'] = ''">
						<xsl:element name="service_subscription_id_ref">
							<xsl:element name="command_id">read_service_subscription</xsl:element>
							<xsl:element name="field_name">parameter_value</xsl:element>              
						</xsl:element>
					</xsl:if>					
				</xsl:element>
			</xsl:element>			
			
			<xsl:variable name="serviceCode">
				<xsl:value-of select="request-param[@name='serviceCode']"/>
			</xsl:variable>												
						
			<!-- Get Entity Information -->
			<xsl:element name="CcmFifGetEntityCmd">
				<xsl:element name="command_id">get_entity</xsl:element>
				<xsl:element name="CcmFifGetEntityInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
				<xsl:choose>
					<xsl:when test="$serviceCode = 'V0014'">
						&CSCMapping_ISDNP2PExtraLine;
						&CSCMapping_AddressCreation;
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
			
			<xsl:element name="CcmFifAddServiceSubsCmd">
				<xsl:element name="command_id">add_child_service</xsl:element>
				<xsl:element name="CcmFifAddServiceSubsInCont">
					<xsl:element name="product_subscription_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="service_code">
						<xsl:value-of select="request-param[@name='serviceCode']"/>
					</xsl:element>
					<xsl:element name="service_subscription_id">
						<xsl:value-of select="request-param[@name='allocatedServiceSubscriptionId']"/>
					</xsl:element>
					<xsl:element name="parent_service_subs_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">service_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="desired_date">
						<xsl:value-of select="$desiredDate"/>
					</xsl:element>          
					<xsl:element name="desired_schedule_type">
						<xsl:value-of select="$scheduleType"/>
					</xsl:element>
					<xsl:element name="reason_rd">
						<xsl:value-of select="request-param[@name='reason']"/>
					</xsl:element>
					<xsl:element name="account_number_ref">
						<xsl:element name="command_id">find_main_service</xsl:element>
						<xsl:element name="field_name">account_number</xsl:element>
					</xsl:element>
					<xsl:element name="use_current_pc_version">Y</xsl:element>
					<xsl:element name="service_characteristic_list">
						<xsl:for-each select="request-param-list[@name='parameterList']/request-param-list-item">
							<xsl:if test="$serviceCode = 'I1222' or $serviceCode = 'I104B'">
								&CSCMapping_FixedIPAddress;
								&CSCMapping;
							</xsl:if>
							<xsl:if test="$serviceCode = 'V0113'">
								&CSCMapping_ISDNDSL;
								&CSCMapping;
							</xsl:if>
							<xsl:if test="$serviceCode = 'V8042'">
								&CSCMapping_InstantAccess;
								&CSCMapping;
							</xsl:if>
							<xsl:if test="$serviceCode = 'V0014'">
								&CSCMapping_ISDNP2PExtraLine;
								&CSCMapping;
							</xsl:if>
							<xsl:if test="$serviceCode = 'V0305'">
								&CSCMapping_MobileUsage;
								&CSCMapping;
							</xsl:if>
							<xsl:if test="$serviceCode = 'VI081'">
                        &CSCMapping_ReferenceOrder;
								&CSCMapping;
							</xsl:if>
						</xsl:for-each>						
					</xsl:element>
					<xsl:element name="provider_tracking_no">
						<xsl:value-of select="request-param[@name='providerTrackingNumber']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="CcmFifReadExternalNotificationCmd">
				<xsl:element name="command_id">read_customer_order</xsl:element>
				<xsl:element name="CcmFifReadExternalNotificationInCont">
					<xsl:element name="transaction_id">
						<xsl:value-of select="request-param[@name='requestListId']"/>
					</xsl:element>
					<xsl:element name="parameter_name">
						<xsl:choose>
							<xsl:when test="request-param[@name='parentFunctionID'] != ''">
								<xsl:value-of select="request-param[@name='parentFunctionID']"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="request-param[@name='functionID']"/>		
							</xsl:otherwise>
						</xsl:choose>						
						<xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
					</xsl:element>
					<xsl:element name="ignore_empty_result">Y</xsl:element>
				</xsl:element>
			</xsl:element>      
			
			<!-- Add STPs to subscribe customer order if exists -->   
			<xsl:element name="CcmFifAddSTPToCustomerOrderCmd">
				<xsl:element name="CcmFifAddSTPToCustomerOrderInCont">
					<xsl:element name="customer_order_id_ref">
						<xsl:element name="command_id">read_customer_order</xsl:element>
						<xsl:element name="field_name">parameter_value</xsl:element>
					</xsl:element>
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">add_child_service</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:element name="ignore_empty_list_ind">Y</xsl:element>
					<xsl:element name="processing_status">
						<xsl:value-of select="request-param[@name='processingStatus']"/>
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
				<xsl:element name="command_id">create_co</xsl:element>
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
							<xsl:element name="command_id">add_child_service</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
						</xsl:element>
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
						<xsl:value-of select="request-param[@name='processingStatus']"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<xsl:if test="request-param[@name='processingStatus'] = ''">
				<xsl:element name="CcmFifReleaseCustOrderCmd">
					<xsl:element name="CcmFifReleaseCustOrderInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_main_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="customer_order_ref">
							<xsl:element name="command_id">create_co</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>
						</xsl:element>
						<xsl:element name="process_ind_ref">
							<xsl:element name="command_id">create_co</xsl:element>
							<xsl:element name="field_name">customer_order_created</xsl:element>
						</xsl:element>
						<xsl:element name="required_process_ind">Y</xsl:element>   
					</xsl:element>
				</xsl:element>        
			</xsl:if>
			
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
								<xsl:value-of select="request-param[@name='functionID']"/>
								<xsl:text>_CUSTOMER_ORDER_ID</xsl:text>
							</xsl:element>
							<xsl:element name="parameter_value_ref">
								<xsl:element name="command_id">create_co</xsl:element>
								<xsl:element name="field_name">customer_order_id</xsl:element>
							</xsl:element>
						</xsl:element>	
					</xsl:element>          
					<xsl:element name="process_ind_ref">
						<xsl:element name="command_id">create_co</xsl:element>
						<xsl:element name="field_name">customer_order_created</xsl:element>
					</xsl:element>
					<xsl:element name="required_process_ind">Y</xsl:element>   
				</xsl:element>
			</xsl:element>
			  
			<xsl:element name="CcmFifConcatStringsCmd">
				<xsl:element name="command_id">functionID</xsl:element>
				<xsl:element name="CcmFifConcatStringsInCont">
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">
								<xsl:value-of select="request-param[@name='functionID']"/>
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
								<xsl:choose>
									<xsl:when test="request-param[@name='ccbId'] != ''">
										<xsl:value-of select="request-param[@name='ccbId']"/>
									</xsl:when>
									<xsl:when test="request-param[@name='allocatedServiceSubscriptionId'] != ''">
										<xsl:value-of select="request-param[@name='allocatedServiceSubscriptionId']"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="request-param[@name='serviceSubscriptionId']"/>
									</xsl:otherwise>
								</xsl:choose>								
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="CcmFifConcatStringsCmd">
				<xsl:element name="command_id">functionStatus</xsl:element>
				<xsl:element name="CcmFifConcatStringsInCont">
					<xsl:element name="input_string_list">
						<xsl:element name="CcmFifPassingValueCont">
							<xsl:element name="value">
								<xsl:choose>
									<xsl:when test="request-param[@name='processingStatus'] = 'completedOPM'">SUCCESS</xsl:when>
									<xsl:otherwise>ACKNOWLEDGED</xsl:otherwise>                  
								</xsl:choose>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>      
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
