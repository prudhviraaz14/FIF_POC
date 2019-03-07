<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for reconfiguring and terminating a service or product subsccription
  @author schwarje
-->
<!DOCTYPE XSL [
<!ENTITY GenericServiceCharacteristicList SYSTEM "GenericServiceCharacteristicList.xsl">
<!ENTITY GenericCreateAddress SYSTEM "GenericCreateAddress.xsl">
]>

<xsl:stylesheet 
    exclude-result-prefixes="dateutils" 
    version="1.0"
    xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
			<xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
		</xsl:element>
		<xsl:element name="action_name">
			<xsl:value-of select="//request/action-name"/>
		</xsl:element>
		<xsl:element name="override_system_date">
			<xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
		</xsl:element>
		
		<xsl:element name="Command_List">
	
	        <xsl:if test="count(request-param-list[@name='CONF_SERVICE_CHAR_LIST']/request-param-list-item) != 0
	        			and request-param[@name='SERVICE_CHAR_CODE'] != ''">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">onlyUseListsOrSimpleParameters</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">Bitte CONF_SERVICE_CHAR_LIST ODER einfache Parameter nutzen, nicht beide.</xsl:element>
					</xsl:element>                                      
	       		</xsl:element>
	        </xsl:if>
	
	        <xsl:if test="request-param[@name='ACTIVATE_TERMINATION'] = 'Y' and
	        			request-param[@name='DESIRED_DATE'] != ''">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">noDesiredDateForAutomaticTermination</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">Dienste werden bei ACTIVATE_TERMINATION = Y automatisch am gleichen Tag gekündigt. In diesem Fall bitte kein DESIRED_DATE setzen.</xsl:element>
					</xsl:element>                                      
	       		</xsl:element>        			
	        </xsl:if>
	
	        <xsl:if test="request-param[@name='ACTIVATE_TERMINATION'] = 'Y' and
	        			request-param[@name='RECONFIGURE_SERVICE'] = 'Y'">
				<xsl:element name="CcmFifRaiseErrorCmd">
					<xsl:element name="command_id">noReconfigurationAndAutomaticTermination</xsl:element>
					<xsl:element name="CcmFifRaiseErrorInCont">
						<xsl:element name="error_text">RECONFIGURE_SERVICE = Y ist nur bei OP-Kündigungen erlaubt. Diese sind mit ACTIVATE_TERMINATION = Y nicht möglich, da OP hierbei umgangen wird.</xsl:element>
					</xsl:element>                                      
	       		</xsl:element>        			
	        </xsl:if>

			<xsl:variable name="today" select="dateutils:getCurrentDate()"/>
	
			<xsl:variable name="terminationDate">
				<xsl:choose>
					<xsl:when test ="request-param[@name='DESIRED_DATE'] = '' or
							request-param[@name='DESIRED_DATE'] = 'today' or
							request-param[@name='ACTIVATE_TERMINATION'] = 'Y'">
						<xsl:value-of select="$today"/>
					</xsl:when>
					<xsl:when test ="dateutils:compareString(request-param[@name='DESIRED_DATE'], $today) = '-1'">
						<xsl:value-of select="$today"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='DESIRED_DATE']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
	
			<xsl:variable name="desiredScheduleType">
				<xsl:choose>
					<xsl:when test ="dateutils:compareString($terminationDate, $today) = '0'">ASAP</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="request-param[@name='DESIRED_SCHEDULE_TYPE']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
	
			<!-- Find Service Subscription by service_subscription id  -->
			<xsl:element name="CcmFifFindServiceSubsCmd">
				<xsl:element name="command_id">find_service</xsl:element>
				<xsl:element name="CcmFifFindServiceSubsInCont">
					<xsl:choose>
						<xsl:when test="request-param[@name='SERVICE_SUBSCRIPTION_ID'] != ''">
							<xsl:element name="service_subscription_id">
								<xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
							</xsl:element>						
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="product_subscription_id">
								<xsl:value-of select="request-param[@name='PRODUCT_SUBSCRIPTION_ID']"/>
							</xsl:element>
							<xsl:element name="fetch_main_ss_from_ps_Ind">Y</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:element>
	
			<!-- lock product to avoid concurrency problems -->
			<xsl:element name="CcmFifLockObjectCmd">
				<xsl:element name="CcmFifLockObjectInCont">
					<xsl:element name="object_id_ref">
						<xsl:element name="command_id">find_service</xsl:element>
						<xsl:element name="field_name">product_subscription_id</xsl:element>
					</xsl:element>
					<xsl:element name="object_type">PROD_SUBS</xsl:element>
				</xsl:element>
			</xsl:element>
	
			<xsl:if test="request-param[@name='RECONFIGURE_SERVICE'] = 'Y'">
				<xsl:element name="CcmFifGetEntityCmd">
					<xsl:element name="command_id">get_entity</xsl:element>
					<xsl:element name="CcmFifGetEntityInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>          
		
				<xsl:choose>
					<xsl:when test="count(request-param-list[@name='CONF_SERVICE_CHAR_LIST']/request-param-list-item) != 0">
						<xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST']/request-param-list-item">
							&GenericCreateAddress;
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						&GenericCreateAddress;
					</xsl:otherwise>
				</xsl:choose>
		
				<!-- reconfigure service subscription -->
				<xsl:element name="CcmFifReconfigServiceCmd">
					<xsl:element name="command_id">reconfigure_service</xsl:element>
					<xsl:element name="CcmFifReconfigServiceInCont">
						<xsl:element name="service_subscription_id">
							<xsl:value-of select="request-param[@name='SERVICE_SUBSCRIPTION_ID']"/>
						</xsl:element>
						<xsl:element name="desired_date">
							<xsl:value-of select="$today"/>
						</xsl:element>
						<xsl:element name="desired_schedule_type">ASAP</xsl:element>
						<xsl:element name="reason_rd">
							<xsl:value-of select="request-param[@name='REASON_RD']"/>
						</xsl:element>
						<xsl:element name="service_characteristic_list">
							<xsl:choose>
								<xsl:when test="count(request-param-list[@name='CONF_SERVICE_CHAR_LIST']/request-param-list-item) != 0">
									<xsl:for-each select="request-param-list[@name='CONF_SERVICE_CHAR_LIST']/request-param-list-item">
										&GenericServiceCharacteristicList;
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									&GenericServiceCharacteristicList;
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:element>
				</xsl:element>
		      
				<!-- create customer order  -->
				<xsl:element name="CcmFifCreateCustOrderCmd">
					<xsl:element name="command_id">create_reconf_co</xsl:element>
					<xsl:element name="CcmFifCreateCustOrderInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>            
						</xsl:element>
						<xsl:element name="service_ticket_pos_list">
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">reconfigure_service</xsl:element>
								<xsl:element name="field_name">service_ticket_pos_id</xsl:element>
							</xsl:element>
						</xsl:element>       
					</xsl:element>
				</xsl:element>
		
				<!-- release customer order -->
				<xsl:element name="CcmFifReleaseCustOrderCmd">
					<xsl:element name="command_id">release_reconf_co</xsl:element>
					<xsl:element name="CcmFifReleaseCustOrderInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>            
						</xsl:element>
						<xsl:element name="customer_order_ref">
							<xsl:element name="command_id">create_reconf_co</xsl:element>
							<xsl:element name="field_name">customer_order_id</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>

			<xsl:choose>			
				<xsl:when test="request-param[@name='TERMINATE_PRODUCT_SUBSCRIPTION'] = 'Y'">
					<xsl:element name="CcmFifTerminateProductSubsCmd">
						<xsl:element name="command_id">terminate_ps</xsl:element>
						<xsl:element name="CcmFifTerminateProductSubsInCont">
							<xsl:element name="product_subscription_ref">
								<xsl:element name="command_id">find_service</xsl:element>
								<xsl:element name="field_name">product_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="desired_date">
								<xsl:value-of select="$terminationDate"/>
							</xsl:element>                
							<xsl:element name="desired_schedule_type">
								<xsl:value-of select="$desiredScheduleType"/>
							</xsl:element>
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='REASON_RD']"/>
							</xsl:element>
							<xsl:element name="auto_customer_order">N</xsl:element>
							<xsl:element name="detailed_reason_rd">
								<xsl:value-of select="request-param[@name='TERMINATION_REASON']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="CcmFifTermSuspReactServiceSubsCmd">
						<xsl:element name="command_id">terminate_ss</xsl:element>
						<xsl:element name="CcmFifTermSuspReactServiceSubsInCont">
							<xsl:element name="service_subscription_ref">
								<xsl:element name="command_id">find_service</xsl:element>
								<xsl:element name="field_name">service_subscription_id</xsl:element>
							</xsl:element>
							<xsl:element name="usage_mode">4</xsl:element>
							<xsl:element name="desired_date">
								<xsl:value-of select="$terminationDate"/>
							</xsl:element>
							<xsl:element name="desired_schedule_type">
								<xsl:value-of select="$desiredScheduleType"/>
							</xsl:element>
							<xsl:element name="reason_rd">
								<xsl:value-of select="request-param[@name='REASON_RD']"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>                        
				</xsl:otherwise>
			</xsl:choose>

			<!-- Create Customer Order -->
			<xsl:element name="CcmFifCreateCustOrderCmd">
				<xsl:element name="command_id">create_term_co</xsl:element>
				<xsl:element name="CcmFifCreateCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>            
					</xsl:element>
					<xsl:element name="customer_tracking_id">
						<xsl:value-of select="request-param[@name='OMTS_ORDER_ID']"/>
					</xsl:element>
					<xsl:element name="provider_tracking_no">
						<xsl:value-of select="request-param[@name='PROVIDER_TRACKING_NUMBER']"/>
					</xsl:element>			
					<xsl:element name="service_ticket_pos_list">
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_ss</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
						<xsl:element name="CcmFifCommandRefCont">
							<xsl:element name="command_id">terminate_ps</xsl:element>
							<xsl:element name="field_name">service_ticket_pos_list</xsl:element>
						</xsl:element>
					</xsl:element>
					<xsl:if test="request-param[@name='ACTIVATE_TERMINATION'] = 'Y'">
						<xsl:element name="processing_status">completedOPM</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:element>

			<!-- Release Customer Order -->
			<xsl:element name="CcmFifReleaseCustOrderCmd">
				<xsl:element name="CcmFifReleaseCustOrderInCont">
					<xsl:element name="customer_number_ref">
						<xsl:element name="command_id">find_service</xsl:element>
						<xsl:element name="field_name">customer_number</xsl:element>            
					</xsl:element>
					<xsl:element name="customer_order_ref">
						<xsl:element name="command_id">create_term_co</xsl:element>
						<xsl:element name="field_name">customer_order_id</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Create Contact -->
			<xsl:if test="request-param[@name='CREATE_CONTACT'] != 'N'">
			    <xsl:element name="CcmFifCreateContactCmd">
					<xsl:element name="command_id">create_contact</xsl:element>
					<xsl:element name="CcmFifCreateContactInCont">
						<xsl:element name="customer_number_ref">
							<xsl:element name="command_id">find_service</xsl:element>
							<xsl:element name="field_name">customer_number</xsl:element>
						</xsl:element>
						<xsl:element name="contact_type_rd">
							<xsl:choose>
								<xsl:when test="request-param[@name='CONTACT_TYPE_RD'] != ''">
									<xsl:value-of select="request-param[@name='CONTACT_TYPE_RD']"/>
								</xsl:when>
								<xsl:otherwise>KUEN</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="short_description">
							<xsl:choose>
								<xsl:when test="request-param[@name='SHORT_DESCRIPTION'] != ''">
									<xsl:value-of select="request-param[@name='SHORT_DESCRIPTION']"/>
								</xsl:when>
								<xsl:when test="request-param[@name='TERMINATE_PRODUCT_SUBSCRIPTION'] = 'Y'">
									<xsl:text>Produktnutzung gekündigt</xsl:text>
								</xsl:when>								
								<xsl:otherwise>Dienstenutzung gekündigt</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						
						<xsl:element name="description_text_list">
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="contact_text">
									<xsl:if test="request-param[@name='LONG_DESCRIPTION_TEXT'] != ''">
										<xsl:value-of select="request-param[@name='LONG_DESCRIPTION_TEXT']"/>
										<xsl:text>&#xA;</xsl:text>
									</xsl:if>
									<xsl:choose>
										<xsl:when test="request-param[@name='TERMINATE_PRODUCT_SUBSCRIPTION'] = 'Y'">Produktnutzung </xsl:when>								
										<xsl:otherwise>Dienstenutzung </xsl:otherwise>										
									</xsl:choose>
								</xsl:element>
							</xsl:element>
							<xsl:element name="CcmFifCommandRefCont">
								<xsl:element name="command_id">find_service</xsl:element>
								<xsl:element name="field_name">
									<xsl:choose>
										<xsl:when test="request-param[@name='TERMINATE_PRODUCT_SUBSCRIPTION'] = 'Y'">product_subscription_id</xsl:when>								
										<xsl:otherwise>service_subscription_id</xsl:otherwise>										
									</xsl:choose>
								</xsl:element>          
							</xsl:element>
							<xsl:element name="CcmFifPassingValueCont">
								<xsl:element name="contact_text">
								    <xsl:text> wurde</xsl:text>
								    <xsl:if test="request-param[@name='RECONFIGURE_SERVICE'] = 'Y'"> umkonfiguriert und</xsl:if>
								    <xsl:text> gekündigt.&#xA;TransactionID: </xsl:text>
									<xsl:value-of select="request-param[@name='transactionID']"/>
									<xsl:text> (</xsl:text>
									<xsl:value-of select="request-param[@name='CLIENT_NAME']"/>
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
